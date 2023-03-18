/datum/component/sticker
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///The typepath for our attached sticker component
	var/stick_type = /datum/component/attached_sticker

/datum/component/sticker/Initialize(sticker_type)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(sticker_type)
		stick_type = sticker_type

/datum/component/sticker/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))

/datum/component/sticker/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_MOVABLE_IMPACT))

/datum/component/sticker/proc/on_afterattack(obj/item/source, atom/target, mob/living/user, prox, params)
	SIGNAL_HANDLER
	if(!prox)
		return
	if(!isatom(target))
		return
	var/list/parameters = params2list(params)
	if(!LAZYACCESS(parameters, ICON_X) || !LAZYACCESS(parameters, ICON_Y))
		return
	var/divided_size = world.icon_size / 2
	var/px = text2num(LAZYACCESS(parameters, ICON_X)) - divided_size
	var/py = text2num(LAZYACCESS(parameters, ICON_Y)) - divided_size

	user.do_attack_animation(target)
	do_stick(target,user,px,py)

/datum/component/sticker/proc/do_stick(atom/target, mob/living/user, px, py)
	target.AddComponent(stick_type, px, py, parent, user)

/datum/component/sticker/proc/on_throw_impact(atom/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(prob(50))
		do_stick(hit_atom,null,rand(-7,7),rand(-7,7))
		var/atom/as_atom = parent
		as_atom.balloon_alert_to_viewers("the sticker lands on its sticky side!")

/datum/component/attached_sticker
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///The overlay we apply to things we stick to
	var/mutable_appearance/sticker_overlay
	///The turf our COMSIG_TURF_EXPOSE is registered to, so we can unregister it later.
	var/turf/signal_turf
	///Our physical sticker to drop
	var/obj/item/sticker

/datum/component/attached_sticker/Initialize(px, py, obj/stick, mob/living/user)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	sticker = stick
	sticker_overlay = mutable_appearance(stick.icon, stick.icon_state , layer = atom_parent.layer + 1, appearance_flags = RESET_COLOR | PIXEL_SCALE)
	sticker_overlay.pixel_x = px
	sticker_overlay.pixel_y = py
	atom_parent.add_overlay(sticker_overlay)
	if(isliving(parent) && user)
		var/mob/living/victim = parent
		if(victim.client)
			user.log_message("stuck [sticker] to [key_name(victim)]", LOG_ATTACK)
			victim.log_message("had [sticker] stuck to them by [key_name(user)]", LOG_ATTACK)
	if(isturf(parent) && user)
		//register signals on the users turf instead because we can assume they are on flooring sticking it to a wall so it should burn (otherwise it would fruitlessly check wall temperature)
		signal_turf = (user && isclosedturf(parent)) ? get_turf(user) : parent
		RegisterSignal(signal_turf, COMSIG_TURF_EXPOSE, PROC_REF(on_turf_expose))
	sticker.moveToNullspace()

///Move sticker item from nullspace, delete this component, cut overlay
/datum/component/attached_sticker/proc/peel(atom/source)
	SIGNAL_HANDLER
	if(!parent) // just in case
		return
	var/atom/as_atom = parent
	as_atom.cut_overlay(sticker_overlay)
	sticker_overlay = null
	if(sticker)
		sticker.forceMove(isturf(parent) ? parent : as_atom.drop_location())
		sticker.pixel_y = rand(-4,1)
		sticker.pixel_x = rand(-3,3)
		sticker = null
	qdel(src)

/datum/component/attached_sticker/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(peel))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_attached_qdel))

/datum/component/attached_sticker/UnregisterFromParent()
	SIGNAL_HANDLER
	UnregisterSignal(parent, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_LIVING_IGNITED, COMSIG_PARENT_QDELETING))
	if(signal_turf)
		UnregisterSignal(signal_turf, COMSIG_TURF_EXPOSE)
		signal_turf = null

///Signal handler for COMSIG_TURF_EXPOSE, deletes this sticker if the temperature is above 100C and it is flammable
/datum/component/attached_sticker/proc/on_turf_expose(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER
	if(!(sticker.resistance_flags & FLAMMABLE) || exposed_temperature <= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		return
	qdel(sticker)
	peel()

///Signal handler for COMSIG_LIVING_IGNITED, deletes this sticker, if it is flammable
/datum/component/attached_sticker/proc/on_ignite(datum/source)
	SIGNAL_HANDLER
	if(!(sticker.resistance_flags & FLAMMABLE))
		return
	qdel(sticker)
	peel()

/// Signal handler for COMSIG_PARENT_QDELETING, deletes this sticker if the attached object is deleted
/datum/component/attached_sticker/proc/on_attached_qdel(datum/source)
	SIGNAL_HANDLER
	qdel(sticker)
	peel()