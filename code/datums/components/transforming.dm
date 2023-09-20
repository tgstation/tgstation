/*
 * Transforming weapon component. For weapons that swap between states.
 * For example: Energy swords, cleaving saws, switch blades.
 *
 * Used to easily make an item that can be attack_self'd to gain force or change mode.
 *
 * Only values passed on initialize will update when the item is activated (except the icon_state).
 * The icon_state of the item will swap between "[icon_state]" and "[icon_state]_on".
 */
/datum/component/transforming
	/// Whether the weapon is transformed
	var/active = FALSE
	/// Cooldown on transforming this item back and forth
	var/transform_cooldown_time
	/// Force of the weapon when active
	var/force_on
	/// Throwforce of the weapon when active
	var/throwforce_on
	/// Throw speed of the weapon when active
	var/throw_speed_on
	/// Weight class of the weapon when active
	var/w_class_on
	/// The sharpness of the weapon when active
	var/sharpness_on
	/// Hitsound played when active
	var/hitsound_on
	/// List of the original continuous attack verbs the item has.
	var/list/attack_verb_continuous_off
	/// List of the original simple attack verbs the item has.
	var/list/attack_verb_simple_off
	/// List of continuous attack verbs used when the weapon is enabled
	var/list/attack_verb_continuous_on
	/// List of simple attack verbs used when the weapon is enabled
	var/list/attack_verb_simple_on
	/// Whether clumsy people need to succeed an RNG check to turn it on without hurting themselves
	var/clumsy_check
	/// If we get sharpened with a whetstone, save the bonus here for later use if we un/redeploy
	var/sharpened_bonus = 0
	/// Dictate whether we change inhands or not
	var/inhand_icon_change = TRUE
	/// Cooldown in between transforms
	COOLDOWN_DECLARE(transform_cooldown)

/datum/component/transforming/Initialize(
	start_transformed = FALSE,
	transform_cooldown_time = 0 SECONDS,
	force_on = 0,
	throwforce_on = 0,
	throw_speed_on = 2,
	sharpness_on = NONE,
	hitsound_on = 'sound/weapons/blade1.ogg',
	w_class_on = WEIGHT_CLASS_BULKY,
	clumsy_check = TRUE,
	list/attack_verb_continuous_on,
	list/attack_verb_simple_on,
	inhand_icon_change = TRUE,
)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent

	src.transform_cooldown_time = transform_cooldown_time
	src.force_on = force_on
	src.throwforce_on = throwforce_on
	src.throw_speed_on = throw_speed_on
	src.sharpness_on = sharpness_on
	src.hitsound_on = hitsound_on
	src.w_class_on = w_class_on
	src.clumsy_check = clumsy_check
	src.inhand_icon_change = inhand_icon_change

	if(attack_verb_continuous_on)
		src.attack_verb_continuous_on = attack_verb_continuous_on
		attack_verb_continuous_off = item_parent.attack_verb_continuous
	if(attack_verb_simple_on)
		src.attack_verb_simple_on = attack_verb_simple_on
		attack_verb_simple_off = item_parent.attack_verb_simple

	if(start_transformed)
		toggle_active(parent)

/datum/component/transforming/RegisterWithParent()
	var/obj/item/item_parent = parent

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	if(item_parent.sharpness || sharpness_on)
		RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, PROC_REF(on_sharpen))

	RegisterSignal(parent, COMSIG_DETECTIVE_SCANNED, PROC_REF(on_scan))
	RegisterSignal(parent, COMSIG_ITEM_APPLY_FANTASY_BONUSES, PROC_REF(apply_fantasy_bonuses))
	RegisterSignal(parent, COMSIG_ITEM_REMOVE_FANTASY_BONUSES, PROC_REF(remove_fantasy_bonuses))

/datum/component/transforming/proc/apply_fantasy_bonuses(obj/item/source, bonus)
	SIGNAL_HANDLER
	active = FALSE
	set_inactive(source)
	force_on = source.modify_fantasy_variable("force_on", force_on, bonus)
	throwforce_on = source.modify_fantasy_variable("throwforce_on", throwforce_on, bonus)

/datum/component/transforming/proc/remove_fantasy_bonuses(obj/item/source, bonus)
	SIGNAL_HANDLER
	active = FALSE
	set_inactive(source)
	force_on = source.reset_fantasy_variable("force_on", force_on)
	throwforce_on = source.reset_fantasy_variable("throwforce_on", throwforce_on)


/datum/component/transforming/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_SHARPEN_ACT, COMSIG_DETECTIVE_SCANNED))

/datum/component/transforming/proc/on_scan(datum/source, mob/user, list/extra_data)
	SIGNAL_HANDLER
	LAZYADD(extra_data[DETSCAN_CATEGORY_NOTES], "Readings suggest some form of state changing.")


/*
 * Called on [COMSIG_ITEM_ATTACK_SELF].
 *
 * Check if we can transform our weapon, and if so, call [do_transform].
 * Sends signal [COMSIG_TRANSFORMING_PRE_TRANSFORM], and stops the transform action if it returns [COMPONENT_BLOCK_TRANSFORM].
 * And, if [do_transform] was successful, do a clumsy effect from [clumsy_transform_effect].
 *
 * source - source of the signal, the item being transformed / parent
 * user - the mob transforming the weapon
 */
/datum/component/transforming/proc/on_attack_self(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, transform_cooldown))
		to_chat(user, span_warning("Wait a bit before trying to use [source] again!"))
		return

	if(SEND_SIGNAL(source, COMSIG_TRANSFORMING_PRE_TRANSFORM, user, active) & COMPONENT_BLOCK_TRANSFORM)
		return

	if(do_transform(source, user))
		clumsy_transform_effect(user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/*
 * Transform the weapon into its alternate form, calling [toggle_active].
 *
 * Sends signal [COMSIG_TRANSFORMING_ON_TRANSFORM], and calls [default_transform_message] if it does not return [COMPONENT_NO_DEFAULT_MESSAGE].
 * Also starts the [transform_cooldown] if we have a set [transform_cooldown_time].
 *
 * source - the item being transformed / parent
 * user - the mob transforming the item
 *
 * returns TRUE.
 */
/datum/component/transforming/proc/do_transform(obj/item/source, mob/user)
	toggle_active(source)
	if(!(SEND_SIGNAL(source, COMSIG_TRANSFORMING_ON_TRANSFORM, user, active) & COMPONENT_NO_DEFAULT_MESSAGE))
		default_transform_message(source, user)

	if(isnum(transform_cooldown_time))
		COOLDOWN_START(src, transform_cooldown, transform_cooldown_time)
	if(user)
		source.add_fingerprint(user)
	return TRUE

/*
 * The default feedback message and sound effect for an item transforming.
 *
 * source - the item being transformed / parent
 * user - the mob transforming the item
 */
/datum/component/transforming/proc/default_transform_message(obj/item/source, mob/user)
	if(user)
		source.balloon_alert(user, "[active ? "enabled" : "disabled"] [source]")
	playsound(source, 'sound/weapons/batonextend.ogg', 50, TRUE)

/*
 * Toggle active between true and false, and call
 * either set_active or set_inactive depending on whichever state is toggled.
 *
 * source - the item being transformed / parent
 */
/datum/component/transforming/proc/toggle_active(obj/item/source)
	active = !active
	if(active)
		set_active(source)
	else
		set_inactive(source)

/*
 * Set our transformed item into its active state.
 * Updates all the values that were passed from init and the icon_state.
 *
 * source - the item being transformed / parent
 */
/datum/component/transforming/proc/set_active(obj/item/source)
	ADD_TRAIT(source, TRAIT_TRANSFORM_ACTIVE, REF(src))
	if(sharpness_on)
		source.sharpness = sharpness_on
	if(force_on)
		source.force = force_on + (source.sharpness ? sharpened_bonus : 0)
	if(throwforce_on)
		source.throwforce = throwforce_on + (source.sharpness ? sharpened_bonus : 0)
	if(throw_speed_on)
		source.throw_speed = throw_speed_on

	if(LAZYLEN(attack_verb_continuous_on))
		source.attack_verb_continuous = attack_verb_continuous_on
	if(LAZYLEN(attack_verb_simple_on))
		source.attack_verb_simple = attack_verb_simple_on

	source.hitsound = hitsound_on
	source.w_class = w_class_on
	source.icon_state = "[source.icon_state]_on"
	if(inhand_icon_change && source.inhand_icon_state)
		source.inhand_icon_state = "[source.inhand_icon_state]_on"
	source.update_inhand_icon()

/*
 * Set our transformed item into its inactive state.
 * Updates all the values back to the item's initial values.
 *
 * source - the item being un-transformed / parent
 */
/datum/component/transforming/proc/set_inactive(obj/item/source)
	REMOVE_TRAIT(source, TRAIT_TRANSFORM_ACTIVE, REF(src))
	if(sharpness_on)
		source.sharpness = initial(source.sharpness)
	if(force_on)
		source.force = initial(source.force) + (source.sharpness ? sharpened_bonus : 0)
	if(throwforce_on)
		source.throwforce = initial(source.throwforce) + (source.sharpness ? sharpened_bonus : 0)
	if(throw_speed_on)
		source.throw_speed = initial(source.throw_speed)

	if(LAZYLEN(attack_verb_continuous_on))
		source.attack_verb_continuous = attack_verb_continuous_off
	if(LAZYLEN(attack_verb_simple_off))
		source.attack_verb_simple = attack_verb_simple_off

	source.hitsound = initial(source.hitsound)
	source.w_class = initial(source.w_class)
	source.icon_state = initial(source.icon_state)
	source.inhand_icon_state = initial(source.inhand_icon_state)
	if(ismob(source.loc))
		var/mob/loc_mob = source.loc
		loc_mob.update_held_items()

/*
 * If [clumsy_check] is set to TRUE, attempt to cause a side effect for clumsy people activating this item.
 * Called after the transform is done, meaning [active] var has already updated.
 *
 * user - the clumsy mob, transforming our item (parent)
 *
 * Returns TRUE if side effects happened, FALSE otherwise
 */
/datum/component/transforming/proc/clumsy_transform_effect(mob/living/user)
	if(!clumsy_check)
		return FALSE

	if(!user || !HAS_TRAIT(user, TRAIT_CLUMSY))
		return FALSE

	if(active && prob(50))
		var/hurt_self_verb_simple = LAZYLEN(attack_verb_simple_on) ? pick(attack_verb_simple_on) : "hit"
		var/hurt_self_verb_continuous = LAZYLEN(attack_verb_continuous_on) ? pick(attack_verb_continuous_on) : "hits"
		user.visible_message(
			span_warning("[user] triggers [parent] while holding it backwards and [hurt_self_verb_continuous] themself, like a doofus!"),
			span_warning("You trigger [parent] while holding it backwards and [hurt_self_verb_simple] yourself, like a doofus!"),
		)
		user.take_bodypart_damage(10)
		return TRUE
	return FALSE

/*
 * Called on [COMSIG_ITEM_SHARPEN_ACT].
 * We need to track our sharpened bonus here, so we correctly apply and unapply it
 * if our item's sharpness state changes from transforming.
 *
 * source - the item being sharpened / parent
 * increment - the amount of force added
 * max - the maximum force that the item can be adjusted to.
 *
 * Does not return naturally [COMPONENT_BLOCK_SHARPEN_APPLIED] as this is only to track our sharpened bonus between transformation.
 */
/datum/component/transforming/proc/on_sharpen(obj/item/source, increment, max)
	SIGNAL_HANDLER

	if(sharpened_bonus)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	if(force_on + increment > max)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	sharpened_bonus = increment
