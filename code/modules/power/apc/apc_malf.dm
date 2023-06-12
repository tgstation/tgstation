/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(!istype(malf) || !malf.malf_picker)
		return APC_AI_NO_MALF
	if(malfai != (malf.parent || malf))
		return APC_AI_NO_HACK
	if(occupier == malf)
		return APC_AI_HACK_SHUNT_HERE
	if(istype(malf.loc, /obj/machinery/power/apc))
		return APC_AI_HACK_SHUNT_ANOTHER
	return APC_AI_HACK_NO_SHUNT

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != 1)
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
	malf.ShutOffDoomsdayDevice()
	occupier = new /mob/living/silicon/ai(src, malf.laws, malf) //DEAR GOD WHY? //IKR????
	occupier.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(occupier.name, "APC Copy"))
		occupier.name = "[malf.name] APC Copy"
	if(malf.parent)
		occupier.parent = malf.parent
	else
		occupier.parent = malf
	malf.shunted = TRUE
	occupier.eyeobj.name = "[occupier.name] (AI Eye)"
	if(malf.parent)
		qdel(malf)
	for(var/obj/item/pinpointer/nuke/disk_pinpointers in GLOB.pinpointer_list)
		disk_pinpointers.switch_mode_to(TRACK_MALF_AI) //Pinpointer will track the shunted AI
	var/datum/action/innate/core_return/return_action = new
	return_action.Grant(occupier)
	occupier.cancel_camera()

/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	if(occupier.parent && occupier.parent.stat != DEAD)
		occupier.mind.transfer_to(occupier.parent)
		occupier.parent.shunted = FALSE
		occupier.parent.setOxyLoss(occupier.getOxyLoss())
		occupier.parent.cancel_camera()
		qdel(occupier)
		return
	to_chat(occupier, span_danger("Primary core damaged, unable to return core processes."))
	if(forced)
		occupier.forceMove(drop_location())
		INVOKE_ASYNC(occupier, TYPE_PROC_REF(/mob/living, death))
		occupier.gib()

	if(!occupier.nuking) //Pinpointers go back to tracking the nuke disk, as long as the AI (somehow) isn't mid-nuking.
		for(var/obj/item/pinpointer/nuke/disk_pinpointers in GLOB.pinpointer_list)
			disk_pinpointers.switch_mode_to(TRACK_NUKE_DISK)
			disk_pinpointers.alert = FALSE

/obj/machinery/power/apc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(card.AI)
		to_chat(user, span_warning("[card] is already occupied!"))
		return
	if(!occupier)
		to_chat(user, span_warning("There's nothing in [src] to transfer!"))
		return
	if(!occupier.mind || !occupier.client)
		to_chat(user, span_warning("[occupier] is either inactive or destroyed!"))
		return
	if(!occupier.parent.stat)
		to_chat(user, span_warning("[occupier] is refusing all attempts at transfer!") )
		return
	if(transfer_in_progress)
		to_chat(user, span_warning("There's already a transfer in progress!"))
		return
	if(interaction != AI_TRANS_TO_CARD || occupier.stat)
		return
	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		return
	transfer_in_progress = TRUE
	user.visible_message(span_notice("[user] slots [card] into [src]..."), span_notice("Transfer process initiated. Sending request for AI approval..."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	SEND_SOUND(occupier, sound('sound/misc/notice2.ogg')) //To alert the AI that someone's trying to card them if they're tabbed out
	if(tgui_alert(occupier, "[user] is attempting to transfer you to \a [card.name]. Do you consent to this?", "APC Transfer", list("Yes - Transfer Me", "No - Keep Me Here")) == "No - Keep Me Here")
		to_chat(user, span_danger("AI denied transfer request. Process terminated."))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		transfer_in_progress = FALSE
		return
	if(user.loc != user_turf)
		to_chat(user, span_danger("Location changed. Process terminated."))
		to_chat(occupier, span_warning("[user] moved away! Transfer canceled."))
		transfer_in_progress = FALSE
		return
	to_chat(user, span_notice("AI accepted request. Transferring stored intelligence to [card]..."))
	to_chat(occupier, span_notice("Transfer starting. You will be moved to [card] shortly."))
	if(!do_after(user, 50, target = src))
		to_chat(occupier, span_warning("[user] was interrupted! Transfer canceled."))
		transfer_in_progress = FALSE
		return
	if(!occupier || !card)
		transfer_in_progress = FALSE
		return
	user.visible_message(span_notice("[user] transfers [occupier] to [card]!"), span_notice("Transfer complete! [occupier] is now stored in [card]."))
	to_chat(occupier, span_notice("Transfer complete! You've been stored in [user]'s [card.name]."))
	occupier.forceMove(card)
	card.AI = occupier
	occupier.parent.shunted = FALSE
	occupier.cancel_camera()
	occupier = null
	transfer_in_progress = FALSE
	return
