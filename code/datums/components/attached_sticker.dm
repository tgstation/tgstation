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
	RegisterSignal(sticker, COMSIG_QDELETING, PROC_REF(peel))

/datum/component/attached_sticker/Destroy()
	var/atom/as_atom = parent
	as_atom.cut_overlay(sticker_overlay)
	sticker_overlay = null
	if(sticker)
		QDEL_NULL(sticker)
	return ..()

///Move sticker item from nullspace, delete this component, cut overlay
/datum/component/attached_sticker/proc/peel(atom/source)
	SIGNAL_HANDLER
	if(!QDELETED(sticker))
		var/atom/as_atom = parent
		sticker.forceMove(isturf(as_atom) ? as_atom : as_atom.drop_location())
		sticker.pixel_y = rand(-4,1)
		sticker.pixel_x = rand(-3,3)
	sticker = null
	if(!QDELETED(src))
		qdel(src)

/datum/component/attached_sticker/RegisterWithParent()
	if(sticker.resistance_flags & FLAMMABLE)
		RegisterSignal(parent, COMSIG_LIVING_IGNITED, PROC_REF(peel))
	if(washable)
		RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(peel))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(peel))
	ADD_TRAIT(parent, TRAIT_STICKERED, REF(sticker))

/datum/component/attached_sticker/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_IGNITED, COMSIG_QDELETING))
	if(signal_turf)
		UnregisterSignal(signal_turf, COMSIG_TURF_EXPOSE)
		signal_turf = null
	if(washable)
		UnregisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT)
	REMOVE_TRAIT(parent, TRAIT_STICKERED, REF(sticker))

///Signal handler for COMSIG_TURF_EXPOSE, deletes this sticker if the temperature is above 100C and it is flammable
/datum/component/attached_sticker/proc/on_turf_expose(datum/source, datum/gas_mixture/air, exposed_temperature)
	SIGNAL_HANDLER
	if(exposed_temperature <= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		return
	peel()
