/*
 * Transforming weapon component. For weapons that swap between states.
 * For example: Energy swords, cleaving saws, switch blades.
 *
 * Values will not update/change on transform if no values are passed in initalize.
 */
/datum/component/transforming_weapon
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
	/// List of attack verbs used when the weapon is enabled
	var/list/attack_verb_on = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	/// Whether clumsy people need to succeed an RNG check to turn it on without hurting themselves
	var/clumsy_check = TRUE
	/// If we get sharpened with a whetstone, save the bonus here for later use if we un/redeploy
	var/sharpened_bonus
	/// Callback to be invoked whenever the weapon is transformed.
	var/datum/callback/on_transform_callback
	/// Cooldown in between transforms
	COOLDOWN_DECLARE(transform_cooldown)

/datum/component/transforming_weapon/Initialize(
		start_transformed = FALSE,
		transform_cooldown_time,
		force_on,
		throwforce_on,
		sharpness_on,
		hitsound_on,
		w_class_on,
		clumsy_check = TRUE,
		list/attack_verb_on,
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
	if(islist(attack_verb_on))
		src.attack_verb_on = attack_verb_on
	src.clumsy_check = clumsy_check
	src.on_transform_callback = on_transform_callback

	if(start_transformed)
		toggle_active(parent)

/datum/component/transforming_weapon/RegisterWithParent()
	var/obj/item/item_parent = parent

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/try_transform_weapon)
	if(item_parent.sharpness || sharpness_on)
		RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, .proc/on_sharpen)

/datum/component/transforming_weapon/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_SHARPEN_ACT))

/datum/component/transforming_weapon/proc/try_transform_weapon(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, transform_cooldown))
		to_chat(user, span_warning("Wait a bit before trying to use [source] again!"))
		return

	if(do_transform_weapon(source, user))
		clumsy_transform_effect(user)

/datum/component/transforming_weapon/proc/do_transform_weapon(obj/item/source, mob/user)
	toggle_active(source)
	if(on_transform_callback)
		on_transform_callback.Invoke(user, active)
	else
		default_transform_message(user)

	if(isnum(transform_cooldown_time))
		COOLDOWN_START(src, transform_cooldown, transform_cooldown_time)
	if(user)
		source.add_fingerprint(user)
	return TRUE

/datum/component/transforming_weapon/proc/default_transform_message(mob/user)
	balloon_alert(user, "[active ? "enabled" : "disabled"] [src]")
	playsound(user ? user : parent.loc, 'sound/weapons/batonextend.ogg', 50, TRUE)

/datum/component/transforming_weapon/proc/toggle_active(obj/item/source)
	active = !active
	if(active)
		set_active(source)
	else
		set_inactive(source)

/datum/component/transforming_weapon/proc/set_active(obj/item/source)
	if(isnum(force_on))
		source.force = force_on + (sharpness_on ? sharpened_bonus : 0)
	if(isnum(throwforce_on))
		source.throwforce = throwforce_on + (sharpness_on ? sharpened_bonus : 0)
		source.throw_speed = 4
	if(hitsound_on)
		source.hitsound = hitsound_on
	if(attack_verb_on)
		source.attack_verb_continuous = attack_verb_on
		source.attack_verb_simple = attack_verb_on
	if(sharpness_on)
		source.sharpness = sharpness_on
	if(w_class_on)
		source.w_class = w_class_on

	source.icon_state = "[source.icon_state]_on"

/datum/component/transforming_weapon/proc/set_inactive(obj/item/source)
	if(isnum(force_on))
		source.force = initial(source.force) + (initial(source.sharpness) ? sharpened_bonus : 0)
	if(isnum(throwforce_on))
		source.throwforce = initial(source.throwforce) + (initial(source.sharpness) ? sharpened_bonus : 0)
		source.throw_speed = initial(source.throw_speed)
	if(hitsound_on)
		source.hitsound = initial(source.hitsound)
	if(attack_verb_on)
		source.attack_verb_continuous = initial(source.attack_verb_continuous)
		source.attack_verb_simple = initial(source.attack_verb_simple)
	if(sharpness_on)
		source.sharpness = initial(source.sharpness)
	if(w_class_on)
		source.w_class = initial(source.w_class)

	source.icon_state = initial(source.icon_state)

/datum/component/transforming_weapon/proc/clumsy_transform_effect(mob/living/user)
	if(!clumsy_check)
		return FALSE

	if(!HAS_TRAIT(user, TRAIT_CLUMSY))
		return FALSE

	if(prob(50))
		to_chat(user, span_warning("You accidentally cut yourself with [parent], like a doofus!"))
		user.take_bodypart_damage(5, 5)
		return TRUE
	return FALSE

/datum/component/transforming_weapon/proc/on_sharpen(obj/item/source, increment, max)
	SIGNAL_HANDLER

	if(!source.sharpness)
		return COMPONENT_BLOCK_SHARPEN_BLOCKED
	if(sharpened_bonus)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	if(force_on + increment > max)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	sharpened_bonus = increment
