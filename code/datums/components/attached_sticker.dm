// The attached sticker

/datum/component/attached_sticker
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///The overlay we apply to things we stick to
	var/mutable_appearance/sticker_overlay
	///The turf our COMSIG_TURF_EXPOSE is registered to, so we can unregister it later.
	var/turf/signal_turf
	///Our physical sticker to drop
	var/obj/item/sticker
	///Can we be washed off?
	var/washable = TRUE

/datum/component/attached_sticker/Initialize(px, py, obj/stick, mob/living/user, cleanable=TRUE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	washable = cleanable
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
	else if(isturf(parent) && (sticker.resistance_flags & FLAMMABLE))
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
	if(sticker.resistance_flags & FLAMMABLE)
		RegisterSignal(parent, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	if(washable)
		RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(peel))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_attached_qdel))

/datum/component/attached_sticker/UnregisterFromParent()
	if(sticker.resistance_flags & FLAMMABLE)
		UnregisterSignal(parent, list(COMSIG_LIVING_IGNITED, COMSIG_PARENT_QDELETING))
		if(signal_turf)
			UnregisterSignal(signal_turf, COMSIG_TURF_EXPOSE)
			signal_turf = null
	if(washable)
		UnregisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT)

///Signal handler for COMSIG_TURF_EXPOSE, deletes this sticker if the temperature is above 100C and it is flammable
/datum/component/attached_sticker/proc/on_turf_expose(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER
	if(exposed_temperature <= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		return
	qdel(sticker)
	peel()

///Signal handler for COMSIG_LIVING_IGNITED, deletes this sticker
/datum/component/attached_sticker/proc/on_ignite(datum/source)
	SIGNAL_HANDLER
	qdel(sticker)
	peel()

/// Signal handler for COMSIG_PARENT_QDELETING, deletes this sticker if the attached object is deleted
/datum/component/attached_sticker/proc/on_attached_qdel(datum/source)
	SIGNAL_HANDLER
	qdel(sticker)
	peel()
