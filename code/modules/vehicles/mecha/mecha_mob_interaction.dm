/obj/vehicle/sealed/mecha/mob_try_enter(mob/M)
	if(!ishuman(M)) // no silicons or drones in mechas.
		return
	if(HAS_TRAIT(M, TRAIT_PRIMITIVE)) //no lavalizards either.
		to_chat(M, span_warning("The knowledge to use this device eludes you!"))
		return
	log_message("[M] tried to move into [src].", LOG_MECHA)
	if(dna_lock && M.has_dna())
		var/mob/living/carbon/entering_carbon = M
		if(entering_carbon.dna.unique_enzymes != dna_lock)
			to_chat(M, span_warning("Access denied. [name] is secured with a DNA lock."))
			log_message("Permission denied (DNA LOCK).", LOG_MECHA)
			return
	if((mecha_flags & ID_LOCK_ON) && !allowed(M))
		to_chat(M, span_warning("Access denied. Insufficient operation keycodes."))
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return
	. = ..()
	if(.)
		moved_inside(M)

/obj/vehicle/sealed/mecha/enter_checks(mob/M)
	if(M.incapacitated())
		return FALSE
	if(atom_integrity <= 0)
		to_chat(M, span_warning("You cannot get in the [src], it has been destroyed!"))
		return FALSE
	if(M.buckled)
		to_chat(M, span_warning("You can't enter the exosuit while buckled."))
		log_message("Permission denied (Buckled).", LOG_MECHA)
		return FALSE
	if(M.has_buckled_mobs())
		to_chat(M, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		log_message("Permission denied (Attached mobs).", LOG_MECHA)
		return FALSE
	return ..()

///proc called when a new non-mmi/AI mob enters this mech
/obj/vehicle/sealed/mecha/proc/moved_inside(mob/living/newoccupant)
	if(!(newoccupant?.client))
		return FALSE
	if(ishuman(newoccupant) && !Adjacent(newoccupant))
		return FALSE
	add_occupant(newoccupant)
	newoccupant.forceMove(src)
	newoccupant.update_mouse_pointer()
	add_fingerprint(newoccupant)
	log_message("[newoccupant] moved in as pilot.", LOG_MECHA)
	setDir(SOUTH)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	set_mouse_pointer()
	if(!internal_damage)
		SEND_SOUND(newoccupant, sound('sound/mecha/nominal.ogg',volume=50))
	return TRUE

///proc called when a new mmi mob tries to enter this mech
/obj/vehicle/sealed/mecha/proc/mmi_move_inside(obj/item/mmi/brain_obj, mob/user)
	if(!(mecha_flags & MMI_COMPATIBLE))
		to_chat(user, span_warning("This mecha is not compatible with MMIs!"))
		return FALSE
	if(!brain_obj.brain_check(user))
		return FALSE
	var/mob/living/brain/brain_mob = brain_obj.brainmob
	if(LAZYLEN(occupants) >= max_occupants)
		to_chat(user, span_warning("It's full!"))
		return FALSE
	if(dna_lock && (!brain_mob.stored_dna || (dna_lock != brain_mob.stored_dna.unique_enzymes)))
		to_chat(user, span_warning("Access denied. [name] is secured with a DNA lock."))
		return FALSE

	visible_message(span_notice("[user] starts to insert an MMI into [name]."))

	if(!do_after(user, 4 SECONDS, target = src))
		to_chat(user, span_notice("You stop inserting the MMI."))
		return FALSE
	if(LAZYLEN(occupants) < max_occupants)
		return mmi_moved_inside(brain_obj, user)
	to_chat(user, span_warning("Maximum occupants exceeded!"))
	return FALSE

///proc called when a new mmi mob enters this mech
/obj/vehicle/sealed/mecha/proc/mmi_moved_inside(obj/item/mmi/brain_obj, mob/user)
	if(!(Adjacent(brain_obj) && Adjacent(user)))
		return FALSE
	if(!brain_obj.brain_check(user))
		return FALSE

	var/mob/living/brain/brain_mob = brain_obj.brainmob
	if(!user.transferItemToLoc(brain_obj, src))
		to_chat(user, span_warning("[brain_obj] is stuck to your hand, you cannot put it in [src]!"))
		return FALSE

	brain_obj.set_mecha(src)
	add_occupant(brain_mob)//Note this forcemoves the brain into the mech to allow relaymove
	mecha_flags |= SILICON_PILOT
	brain_mob.reset_perspective(src)
	brain_mob.remote_control = src
	brain_mob.update_mouse_pointer()
	setDir(SOUTH)
	log_message("[brain_obj] moved in as pilot.", LOG_MECHA)
	if(!internal_damage)
		SEND_SOUND(brain_obj, sound('sound/mecha/nominal.ogg',volume=50))
	user.log_message("has put the MMI/posibrain of [key_name(brain_mob)] into [src]", LOG_GAME)
	brain_mob.log_message("was put into [src] by [key_name(user)]", LOG_GAME, log_globally = FALSE)
	return TRUE

/obj/vehicle/sealed/mecha/mob_exit(mob/M, silent = FALSE, randomstep = FALSE, forced = FALSE)
	var/atom/movable/mob_container
	var/turf/newloc = get_turf(src)
	if(ishuman(M))
		mob_container = M
	else if(isbrain(M))
		var/mob/living/brain/brain = M
		mob_container = brain.container
	else if(isAI(M))
		var/mob/living/silicon/ai/AI = M
		//stop listening to this signal, as the static update is now handled by the eyeobj's setLoc
		AI.eyeobj?.UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		AI.eyeobj?.forceMove(newloc) //kick the eye out as well
		if(forced)//This should only happen if there are multiple AIs in a round, and at least one is Malf.
			if(!AI.linked_core) //if the victim AI has no core
				AI.investigate_log("has been gibbed by being forced out of their mech by another AI.", INVESTIGATE_DEATHS)
				AI.gib()  //If one Malf decides to steal a mech from another AI (even other Malfs!), they are destroyed, as they have nowhere to go when replaced.
			AI = null
			mecha_flags &= ~SILICON_PILOT
			return
		else
			if(!AI.linked_core)
				if(!silent)
					to_chat(AI, span_userdanger("Inactive core destroyed. Unable to return."))
				AI.linked_core = null
				return
			if(!silent)
				to_chat(AI, span_notice("Returning to core..."))
			AI.controlled_equipment = null
			AI.remote_control = null
			mob_container = AI
			newloc = get_turf(AI.linked_core)
			qdel(AI.linked_core)
	else
		return ..()
	var/mob/living/ejector = M
	mecha_flags  &= ~SILICON_PILOT
	mob_container.forceMove(newloc)//ejecting mob container
	log_message("[mob_container] moved out.", LOG_MECHA)
	SStgui.close_user_uis(M, src)
	if(istype(mob_container, /obj/item/mmi))
		var/obj/item/mmi/mmi = mob_container
		if(mmi.brainmob)
			ejector.forceMove(mmi)
			ejector.reset_perspective()
			remove_occupant(ejector)
		mmi.set_mecha(null)
		mmi.update_appearance()
	setDir(SOUTH)
	return ..()

/obj/vehicle/sealed/mecha/add_occupant(mob/M, control_flags)
	RegisterSignal(M, COMSIG_MOB_CLICKON, PROC_REF(on_mouseclick), TRUE)
	RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(display_speech_bubble), TRUE)
	. = ..()
	update_appearance()

/obj/vehicle/sealed/mecha/remove_occupant(mob/M)
	UnregisterSignal(M, COMSIG_MOB_CLICKON)
	UnregisterSignal(M, COMSIG_MOB_SAY)
	M.clear_alert(ALERT_CHARGE)
	M.clear_alert(ALERT_MECH_DAMAGE)
	if(M.client)
		M.update_mouse_pointer()
		M.client.view_size.resetToDefault()
		zoom_mode = FALSE
	. = ..()
	update_appearance()

/obj/vehicle/sealed/mecha/container_resist_act(mob/living/user)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		if(!AI.can_shunt)
			to_chat(AI, span_notice("You can't leave a mech after dominating it!."))
			return FALSE
	to_chat(user, span_notice("You begin the ejection procedure. Equipment is disabled during this process. Hold still to finish ejecting."))
	is_currently_ejecting = TRUE
	if(do_after(user, has_gravity() ? exit_delay : 0 , target = src))
		to_chat(user, span_notice("You exit the mech."))
		if(cabin_sealed)
			set_cabin_seal(user, FALSE)
		mob_exit(user, silent = TRUE)
	else
		to_chat(user, span_notice("You stop exiting the mech. Weapons are enabled again."))
	is_currently_ejecting = FALSE
