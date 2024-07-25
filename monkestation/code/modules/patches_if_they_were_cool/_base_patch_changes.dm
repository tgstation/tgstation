/obj/item/reagent_containers/pill/patch

	skips_attack = TRUE

	///rate at which chemicals are injected per process in a precentage
	var/reagent_consumption_rate = 0.05

	///The thing we are attached to
	var/mob/living/attached
	///The overlay we apply to things we stick to
	var/mutable_appearance/patch_overlay

/obj/item/reagent_containers/pill/patch/afterattack(atom/target, mob/living/user, prox, params)
	. = ..()
	if(!prox)
		return
	if(!isliving(target))
		return

	if(!do_after(user, CHEM_INTERACT_DELAY(0.1 SECONDS, user), target))
		return

	var/list/parameters = params2list(params)
	if(!LAZYACCESS(parameters, ICON_X) || !LAZYACCESS(parameters, ICON_Y))
		return
	var/divided_size = world.icon_size / 2
	var/px = text2num(LAZYACCESS(parameters, ICON_X)) - divided_size
	var/py = text2num(LAZYACCESS(parameters, ICON_Y)) - divided_size
	. |= AFTERATTACK_PROCESSED_ITEM
	user.do_attack_animation(target)
	stick(target,user,px,py)
	return .

/obj/item/reagent_containers/pill/patch/proc/stick(atom/target, mob/living/user, px,py)
	patch_overlay = mutable_appearance(icon, icon_state , layer = target.layer + 1, appearance_flags = RESET_COLOR)
	var/matrix/new_matrix = matrix()
	new_matrix.Scale(0.5, 0.5)
	patch_overlay.transform = new_matrix
	patch_overlay.pixel_x = px
	patch_overlay.pixel_y = py
	target.add_overlay(patch_overlay)
	attached = target
	if(isliving(target) && user)
		var/mob/living/victim = target
		if(victim.client)
			user.log_message("stuck [src] to [key_name(victim)]", LOG_ATTACK)
			victim.log_message("had [src] stuck to them by [key_name(user)]", LOG_ATTACK)
	register_signals(user)
	moveToNullspace()
	START_PROCESSING(SSobj, src)

///Registers signals to the object it is attached to
/obj/item/reagent_containers/pill/patch/proc/register_signals(mob/living/user)
	RegisterSignal(attached, COMSIG_LIVING_IGNITED, PROC_REF(on_ignite))
	RegisterSignal(attached, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(peel))
	RegisterSignal(attached, COMSIG_QDELETING, PROC_REF(on_attached_qdel))

//Unregisters signals from the object it is attached to
/obj/item/reagent_containers/pill/patch/proc/unregister_signals(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(attached, list(COMSIG_COMPONENT_CLEAN_ACT, COMSIG_LIVING_IGNITED, COMSIG_QDELETING))

/obj/item/reagent_containers/pill/patch/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!. && prob(15) && isliving(hit_atom))
		stick(hit_atom,rand(-7,7),rand(-7,7))
		attached.balloon_alert_to_viewers("[src] lands on its sticky side!")

///Signal handler for COMSIG_LIVING_IGNITED, deletes this patch, if it is flammable
/obj/item/reagent_containers/pill/patch/proc/on_ignite(datum/source)
	SIGNAL_HANDLER
	if(!(resistance_flags & FLAMMABLE))
		return
	peel()
	qdel(src)

/// Signal handler for COMSIG_QDELETING, deletes this patch if the attached object is deleted
/obj/item/reagent_containers/pill/patch/proc/on_attached_qdel(datum/source)
	SIGNAL_HANDLER
	peel()
	qdel(src)

///Makes this patch move from nullspace and cut the overlay from the object it is attached to, silent for no visible message.
/obj/item/reagent_containers/pill/patch/proc/peel(datum/source)
	SIGNAL_HANDLER
	if(!attached)
		return
	attached.cut_overlay(patch_overlay)
	patch_overlay = null
	forceMove(attached.drop_location())
	pixel_y = rand(-4,1)
	pixel_x = rand(-3,3)
	unregister_signals()
	attached = null
	STOP_PROCESSING(SSobj, src)

/obj/item/reagent_containers/pill/patch/process(seconds_per_tick)
	if(!reagents.total_volume)
		peel()
		qdel(src)
		return

	reagents.trans_to(attached, reagents.total_volume * reagent_consumption_rate, methods = PATCH)
