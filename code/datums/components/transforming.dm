/datum/component/transforming_weapon
	/// Whether the weapon is active
	var/active = FALSE
	/// Force of the weapon when active
	var/force_on = 30
	/// Throwforce of the weapon when active
	var/throwforce_on = 20
	/// Weight class of the weapon when active
	var/w_class_on = WEIGHT_CLASS_BULKY
	/// Hitsound played when active
	var/hitsound_on = 'sound/weapons/blade1.ogg'
	/// List of attack verbs used when the weapon is disabled
	var/list/attack_verb_off = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	/// List of attack verbs used when the weapon is enabled
	var/list/attack_verb_on = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	/// Whether clumsy people need to succeed an RNG check to turn it on without hurting themselves
	var/clumsy_check = TRUE
	/// If we get sharpened with a whetstone, save the bonus here for later use if we un/redeploy
	var/sharpened_bonus
	/// Callback to be invoked whenever the weapon is transformed.
	var/datum/callback/on_transform_callback

/datum/component/transforming_weapon/Initialize(
		force_on = 30,
		throwforce_on = 20,
		w_class_on = WEIGHT_CLASS_BULKY,
		hitsound_on,
		list/attack_verb_off,
		list/attack_verb_on,
		clumsy_check = TRUE,
		datum/callback/on_transform_callback,
		)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/item_parent = parent

	src.force_on = force_on
	src.throwforce_on = throwforce_on
	src.w_class_on = w_class_on
	if(hitsound_on)
		src.hitsound_on = hitsound_on
	if(islist(attack_verb_off))
		src.attack_verb_off = attack_verb_off
	if(islist(attack_verb_on))
		src.attack_verb_on = attack_verb_on
	src.clumsy_check = clumsy_check
	src.on_transform_callback = on_transform_callback

	if(item_parent.sharpness)
		item_parent.AddComponent(/datum/component/butchering, 50, 100, 0, item_parent.hitsound)

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/transform_weapon)
	RegisterSignal(parent, COMSIG_ITEM_SHARPEN_ACT, .proc/on_sharpen)

/datum/component/transforming_weapon/proc/try_transform_weapon(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(do_transform_weapon(source, user))
		clumsy_transform_effect(user)

/datum/component/transforming_weapon/proc/do_transform_weapon(obj/item/source, mob/user, suppress_message)
	toggle_active(source)
	on_transform_callback?.Invoke()

	if(user)
		transform_message(user, suppress_message)
		source.add_fingerprint(user)
	return TRUE

/datum/component/transforming_weapon/proc/toggle_active(obj/item/source)
	active = !active
	if(active)
		set_active(source)
	else
		set_inactive(source)

/datum/component/transforming_weapon/proc/set_active(obj/item/source)
	source.force = force_on + sharpened_bonus
	source.throwforce = throwforce_on + sharpened_bonus
	source.hitsound = hitsound_on
	source.throw_speed = 4
	source.attack_verb_continuous = attack_verb_on
	source.icon_state = "[source.icon_state]_on"
	source.w_class = w_class_on
	if(source.embedding)
		source.updateEmbedding()

/datum/component/transforming_weapon/proc/set_inactive(obj/item/source)
	source.force = initial(source.force) + (source.get_sharpness() ? sharpened_bonus : 0)
	source.throwforce = initial(source.throwforce) + (source.get_sharpness() ? sharpened_bonus : 0)
	source.hitsound = initial(source.hitsound)
	source.throw_speed = initial(source.throw_speed)
	source.attack_verb_continuous = attack_verb_off
	source.icon_state = initial(source.icon_state)
	source.w_class = initial(source.w_class)
	if(source.embedding)
		source.disableEmbedding()

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

/datum/component/transforming_weapon/proc/transform_message(mob/user, supress_message)
	playsound(user, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 35, TRUE)  //changed it from 50% volume to 35% because deafness
	if(!supress_message)
		to_chat(user, span_notice("[src] [active ? "is now active":"can now be concealed"]."))

/datum/component/transforming_weapon/proc/on_sharpen(datum/source, increment, max)
	SIGNAL_HANDLER

	if(sharpened_bonus)
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	if(force_on + increment > max)
		return COMPONENT_BLOCK_SHARPEN_MAXED
	sharpened_bonus = increment
