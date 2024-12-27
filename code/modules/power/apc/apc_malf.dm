/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(!istype(malf) || !malf.malf_picker)
		return APC_AI_NO_MALF
	if(malfai != malf)
		return APC_AI_NO_HACK
	if(occupier == malf)
		return APC_AI_HACK_SHUNT_HERE
	if(istype(malf.loc, /obj/machinery/power/apc))
		return APC_AI_HACK_SHUNT_ANOTHER
	return APC_AI_HACK_NO_SHUNT

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != APC_AI_NO_HACK)
		return
	if(malf.malfhacking)
		to_chat(malf, span_warning("You are already hacking an APC!"))
		return
	to_chat(malf, span_notice("Beginning override of APC systems. This takes some time, and you cannot perform other actions during the process."))
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, TYPE_PROC_REF(/mob/living/silicon/ai/, malfhacked), src), 600, TIMER_STOPPABLE)

	var/atom/movable/screen/alert/hackingapc/hacking_apc
	hacking_apc = malf.throw_alert(ALERT_HACKING_APC, /atom/movable/screen/alert/hackingapc)
	hacking_apc.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, span_warning("You must evacuate your current APC first!"))
		return
	if(!malf.can_shunt)
		to_chat(malf, span_warning("You cannot shunt!"))
		return
	if(!is_station_level(z))
		return
	INVOKE_ASYNC(src, PROC_REF(malfshunt), malf)

/obj/machinery/power/apc/proc/malfshunt(mob/living/silicon/ai/malf)
	var/confirm = tgui_alert(malf, "Are you sure that you want to shunt? This will take you out of your core!", "Shunt to [name]?", list("Yes", "No"))
	if(confirm != "Yes")
		return
	malf.ShutOffDoomsdayDevice()
	occupier = malf
	if (isturf(malf.loc)) // create a deactivated AI core if the AI isn't coming from an emergency mech shunt
		malf.linked_core = new /obj/structure/ai_core/deactivated(malf.loc)
		malf.linked_core.remote_ai = malf // note that we do not set the deactivated core's core_mmi.brainmob
	malf.forceMove(src) // move INTO the APC, not to its tile
	if(!findtext(occupier.name, "APC Copy"))
		occupier.name = "[malf.name] APC Copy"
	malf.shunted = TRUE
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	occupier.eyeobj.forceMove(src.loc)
	for(var/obj/item/pinpointer/nuke/disk_pinpointers in GLOB.pinpointer_list)
		disk_pinpointers.switch_mode_to(TRACK_MALF_AI) //Pinpointer will track the shunted AI
	var/datum/action/innate/core_return/return_action = new
	return_action.Grant(occupier)
	SEND_SIGNAL(src, COMSIG_SILICON_AI_OCCUPY_APC, occupier)
	SEND_SIGNAL(occupier, COMSIG_SILICON_AI_OCCUPY_APC, occupier)
	occupier.cancel_camera()

/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	SEND_SIGNAL(occupier, COMSIG_SILICON_AI_VACATE_APC, occupier)
	SEND_SIGNAL(src, COMSIG_SILICON_AI_VACATE_APC, occupier)
	if(forced)
		occupier.forceMove(drop_location())
		INVOKE_ASYNC(occupier, TYPE_PROC_REF(/mob/living, death))
		occupier.gib(DROP_ALL_REMAINS)
		occupier = null
		return
	if(occupier.linked_core)
		occupier.shunted = FALSE
		occupier.forceMove(occupier.linked_core.loc)
		qdel(occupier.linked_core)
		occupier.cancel_camera()
		occupier = null
	else
		stack_trace("An AI: [occupier] has vacated an APC with no linked core and without being gibbed.")

	if(!occupier.nuking) //Pinpointers go back to tracking the nuke disk, as long as the AI (somehow) isn't mid-nuking.
		for(var/obj/item/pinpointer/nuke/disk_pinpointers in GLOB.pinpointer_list)
			disk_pinpointers.switch_mode_to(TRACK_NUKE_DISK)
			disk_pinpointers.alert = FALSE

/obj/machinery/power/apc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(card.AI)
		to_chat(user, span_warning("[card] is already occupied!"))
		return FALSE
	if(!occupier)
		to_chat(user, span_warning("There's nothing in [src] to transfer!"))
		return FALSE
	if(!occupier.mind || !occupier.client)
		to_chat(user, span_warning("[occupier] is either inactive or destroyed!"))
		return FALSE
	if(occupier.linked_core) //if they have an active linked_core, they can't be transferred from an APC
		to_chat(user, span_warning("[occupier] is refusing all attempts at transfer!") )
		return FALSE
	if(transfer_in_progress)
		to_chat(user, span_warning("There's already a transfer in progress!"))
		return FALSE
	if(interaction != AI_TRANS_TO_CARD || occupier.stat)
		return FALSE
	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		return FALSE
	transfer_in_progress = TRUE
	user.visible_message(span_notice("[user] slots [card] into [src]..."), span_notice("Transfer process initiated. Sending request for AI approval..."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	SEND_SOUND(occupier, sound('sound/announcer/notice/notice2.ogg')) //To alert the AI that someone's trying to card them if they're tabbed out
	if(tgui_alert(occupier, "[user] is attempting to transfer you to \a [card.name]. Do you consent to this?", "APC Transfer", list("Yes - Transfer Me", "No - Keep Me Here")) == "No - Keep Me Here")
		to_chat(user, span_danger("AI denied transfer request. Process terminated."))
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, TRUE)
		transfer_in_progress = FALSE
		return FALSE
	if(user.loc != user_turf)
		to_chat(user, span_danger("Location changed. Process terminated."))
		to_chat(occupier, span_warning("[user] moved away! Transfer canceled."))
		transfer_in_progress = FALSE
		return FALSE
	to_chat(user, span_notice("AI accepted request. Transferring stored intelligence to [card]..."))
	to_chat(occupier, span_notice("Transfer starting. You will be moved to [card] shortly."))
	if(!do_after(user, 5 SECONDS, target = src))
		to_chat(occupier, span_warning("[user] was interrupted! Transfer canceled."))
		transfer_in_progress = FALSE
		return FALSE
	if(!occupier || !card)
		transfer_in_progress = FALSE
		return FALSE
	user.visible_message(span_notice("[user] transfers [occupier] to [card]!"), span_notice("Transfer complete! [occupier] is now stored in [card]."))
	to_chat(occupier, span_notice("Transfer complete! You've been stored in [user]'s [card.name]."))
	occupier.forceMove(card)
	card.AI = occupier
	occupier.shunted = FALSE
	occupier.cancel_camera()
	occupier = null
	transfer_in_progress = FALSE
	return TRUE
