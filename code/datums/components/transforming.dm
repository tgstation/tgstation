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
	var/force_on = 0
	/// Throwforce of the weapon when active
	var/throwforce_on = 0
	/// Weight class of the weapon when active
	var/w_class_on = WEIGHT_CLASS_BULKY
	/// The sharpness of the weapon when active
	var/sharpness_on = NONE
	/// Hitsound played when active
	var/hitsound_on = 'sound/weapons/blade1.ogg'
	/// List of continuous attack verbs used when the weapon is enabled
	var/list/attack_verb_continuous_on = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	/// List of simple attack verbs used when the weapon is enabled
	var/list/attack_verb_simple_on = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	/// Whether clumsy people need to succeed an RNG check to turn it on without hurting themselves
	var/clumsy_check = TRUE
	/// If we get sharpened with a whetstone, save the bonus here for later use if we un/redeploy
	var/sharpened_bonus
	/// Callback to be invoked whenever the weapon is transformed.
	var/datum/callback/on_transform_callback
	/// Cooldown in between transforms
	COOLDOWN_DECLARE(transform_cooldown)

/datum/component/transforming/Initialize(
		start_transformed = FALSE,
		transform_cooldown_time,
		force_on,
		throwforce_on,
		sharpness_on,
		hitsound_on,
		w_class_on,
		clumsy_check = TRUE,
		list/attack_verb_continuous_on,
		list/attack_verb_simple_on,
		datum/callback/on_transform_callback,
		)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.transform_cooldown_time = transform_cooldown_time
	src.force_on = force_on
	src.throwforce_on = throwforce_on
	src.sharpness_on = sharpness_on
	src.hitsound_on = hitsound_on
	src.w_class_on = w_class_on
	src.clumsy_check = clumsy_check
	if(islist(attack_verb_continuous_on))
		src.attack_verb_continuous_on = attack_verb_continuous_on
	if(islist(attack_verb_simple_on))
		src.attack_verb_simple_on = attack_verb_simple_on
	src.on_transform_callback = on_transform_callback

	if(start_transformed)
		toggle_active(parent)

/datum/component/transforming/RegisterWithParent()
	var/obj/item/item_parent = parent

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/try_transform_weapon)
	if(item_parent.sharpness || sharpness_on)
		RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, .proc/on_sharpen)

/datum/component/transforming/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_SHARPEN_ACT))

/datum/component/transforming/Destroy()
	if(on_transform_callback)
		QDEL_NULL(on_transform_callback)
	return ..()

/*
 * Called on [COMSIG_ITEM_ATTACK_SELF].
 *
 * Check if we can transform our weapon, and if so, call [do_transform_weapon].
 * And, if [do_transform_weapon] was successful, do a clumsy effect from [clumsy_transform_effect].
 *
 * source - source of the signal, the item being transformed
 * user - the mob transforming the weapon
 */
/datum/component/transforming/proc/try_transform_weapon(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, transform_cooldown))
		to_chat(user, span_warning("Wait a bit before trying to use [source] again!"))
		return

	if(do_transform_weapon(source, user))
		clumsy_transform_effect(user)

/*
 * Transform the weapon into its alternate form, calling [toggle_active].
 *
 * Invokes [on_transform_callback] if we have one, or calls [default_transform_message] if we don't.
 * Starts [transform_cooldown] if we have a set [transform_cooldown_time].
 * *
 * source - the item being transformed
 * user - the mob transforming the item
 *
 * returns TRUE.
 */
/datum/component/transforming/proc/do_transform_weapon(obj/item/source, mob/user)
	toggle_active(source)
	if(on_transform_callback)
		on_transform_callback.Invoke(user, active)
	else
		default_transform_message(source, user)

	if(isnum(transform_cooldown_time))
		COOLDOWN_START(src, transform_cooldown, transform_cooldown_time)
	if(user)
		source.add_fingerprint(user)
	return TRUE

/*
 * The default feedback message and sound effect for an item transforming.
 *
 * source - the item being transformed
 * user - the mob transforming the item
 */
/datum/component/transforming/proc/default_transform_message(obj/item/source, mob/user)
	source.balloon_alert(user, "[active ? "enabled" : "disabled"] [source]")
	playsound(user ? user : source.loc, 'sound/weapons/batonextend.ogg', 50, TRUE)

/*
 * Toggle active between true and false, and call
 * either set_active or set_inactive depending on whichever state is toggled.
 *
 * source - the item being transformed
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
 * source - the item being transformed
 */
/datum/component/transforming/proc/set_active(obj/item/source)
	if(sharpness_on)
		source.sharpness = sharpness_on
	if(isnum(force_on))
		source.force = force_on + (source.sharpness ? sharpened_bonus : 0)
	if(isnum(throwforce_on))
		source.throwforce = throwforce_on + (source.sharpness ? sharpened_bonus : 0)
		source.throw_speed = 4
	if(hitsound_on)
		source.hitsound = hitsound_on
	if(attack_verb_continuous_on)
		source.attack_verb_continuous = attack_verb_continuous_on
	if(attack_verb_simple_on)
		source.attack_verb_simple = attack_verb_simple_on
	if(w_class_on)
		source.w_class = w_class_on

	source.icon_state = "[source.icon_state]_on"

/*
 * Set our transformed item into its inactive state.
 * Updates all the values back to the item's initial values.
 *
 * source - the item being un-transformed
 */
/datum/component/transforming/proc/set_inactive(obj/item/source)
	if(sharpness_on)
		source.sharpness = initial(source.sharpness)
	if(isnum(force_on))
		source.force = initial(source.force) + (source.sharpness ? sharpened_bonus : 0)
	if(isnum(throwforce_on))
		source.throwforce = initial(source.throwforce) + (source.sharpness ? sharpened_bonus : 0)
		source.throw_speed = initial(source.throw_speed)
	if(hitsound_on)
		source.hitsound = initial(source.hitsound)
	if(attack_verb_continuous_on)
		source.attack_verb_continuous = initial(source.attack_verb_continuous)
	if(attack_verb_simple_on)
		source.attack_verb_simple = initial(source.attack_verb_simple)
	if(w_class_on)
		source.w_class = initial(source.w_class)

	source.icon_state = initial(source.icon_state)

/*
 * If [clumsy_check] is set to TRUE, try to cause a side effect for clumsy people transforming this item.
 * Called after the transform is done.
 *
 * user - the clumsy mob
 *
 * Returns TRUE if side effects happened, FALSE otherwise
 */
/datum/component/transforming/proc/clumsy_transform_effect(mob/living/user)
	if(!clumsy_check)
		return FALSE

	if(!HAS_TRAIT(user, TRAIT_CLUMSY))
		return FALSE

	if(prob(50))
		to_chat(user, span_warning("You accidentally cut yourself with [parent], like a doofus!"))
		user.take_bodypart_damage(10)
		return TRUE
	return FALSE

/*
 * Called on [COMSIG_ITEM_SHARPEN_ACT].
 * We need to track our sharpened bonus here, so we correctly apply and unapply it
 * if our item's sharpness state changes from transforming.
 *
 * source - the item being sharpened
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
