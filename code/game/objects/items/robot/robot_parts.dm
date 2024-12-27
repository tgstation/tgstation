

//The robot bodyparts have been moved to code/module/surgery/bodyparts/robot_bodyparts.dm

/obj/item/robot_suit
	name = "cyborg endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "robo_suit"
	/// Left arm part of the endoskeleton
	var/obj/item/bodypart/arm/left/robot/l_arm = null
	/// Right arm part of the endoskeleton
	var/obj/item/bodypart/arm/right/robot/r_arm = null
	/// Left leg part of this endoskeleton
	var/obj/item/bodypart/leg/left/robot/l_leg = null
	/// Right leg part of this endoskeleton
	var/obj/item/bodypart/leg/right/robot/r_leg = null
	/// Chest part of this endoskeleton
	var/obj/item/bodypart/chest/robot/chest = null
	/// Head part of this endoskeleton
	var/obj/item/bodypart/head/robot/head = null
	/// Forced name of the cyborg
	var/created_name = ""

	/// Forced master AI of the cyborg
	var/mob/living/silicon/ai/forced_ai
	/// The name of the AI being forced, tracked separately to above
	/// so we can reference handle without worrying about making "AI got gibbed" detectors
	var/forced_ai_name

	/// If the cyborg starts movement free and not under lockdown
	var/locomotion = TRUE
	/// If the cyborg synchronizes its laws with its master AI
	var/lawsync = TRUE
	/// If the cyborg starts with a master AI
	var/aisync = TRUE
	/// If the cyborg's cover panel starts locked
	var/panel_locked = TRUE

/obj/item/robot_suit/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/item/robot_suit/Destroy()
	QDEL_NULL(l_arm)
	QDEL_NULL(r_arm)
	QDEL_NULL(l_leg)
	QDEL_NULL(r_leg)
	QDEL_NULL(chest)
	QDEL_NULL(head)
	return ..()

/obj/item/robot_suit/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == l_arm)
		l_arm = null
	if(gone == r_arm)
		r_arm = null
	if(gone == l_leg)
		l_leg = null
	if(gone == r_leg)
		r_leg = null
	if(gone == chest)
		chest = null
	if(gone == head)
		head = null

/obj/item/robot_suit/prebuilt/Initialize(mapload)
	. = ..()
	l_arm = new(src)
	r_arm = new(src)
	l_leg = new(src)
	r_leg = new(src)
	head = new(src)
	head.flash1 = new(head)
	head.flash2 = new(head)
	chest = new(src)
	chest.wired = TRUE
	chest.cell = new /obj/item/stock_parts/power_store/cell/high(chest)
	update_appearance()

/obj/item/robot_suit/update_overlays()
	. = ..()
	if(l_arm)
		. += "[initial(l_arm.icon_state)]+o"
	if(r_arm)
		. += "[initial(r_arm.icon_state)]+o"
	if(chest)
		. += "[initial(chest.icon_state)]+o"
	if(l_leg)
		. += "[initial(l_leg.icon_state)]+o"
	if(r_leg)
		. += "[initial(r_leg.icon_state)]+o"
	if(head)
		. += "[initial(head.icon_state)]+o"

/obj/item/robot_suit/proc/check_completion()
	if(l_arm && r_arm && l_leg && r_leg && head && head.flash1 && head.flash2 && chest && chest.wired && chest.cell)
		SSblackbox.record_feedback("amount", "cyborg_frames_built", 1)
		return TRUE
	return FALSE

/obj/item/robot_suit/wrench_act(mob/living/user, obj/item/I) //Deconstucts empty borg shell. Flashes remain unbroken because they haven't been used yet
	. = ..()
	var/turf/T = get_turf(src)
	if(l_leg || r_leg || chest || l_arm || r_arm || head)
		if(I.use_tool(src, user, 5, volume=50))
			drop_all_parts(T)
			to_chat(user, span_notice("You disassemble the cyborg shell."))
	else
		to_chat(user, span_warning("There is nothing to remove from the endoskeleton!"))
	update_appearance()

/// Drops all included parts to the passed location
/// This will also dissassemble the parts being dropped into components as well
/obj/item/robot_suit/proc/drop_all_parts(atom/drop_to = drop_location())
	l_leg?.forceMove(drop_to)
	r_leg?.forceMove(drop_to)
	l_arm?.forceMove(drop_to)
	r_arm?.forceMove(drop_to)

	if(chest)
		chest.forceMove(drop_to)
		chest.drop_organs()

	if(head)
		head.forceMove(drop_to)
		head.drop_organs()

/obj/item/robot_suit/proc/put_in_hand_or_drop(mob/living/user, obj/item/I) //normal put_in_hands() drops the item ontop of the player, this drops it at the suit's loc
	if(!user.put_in_hands(I))
		I.forceMove(drop_location())
		return FALSE
	return TRUE

/obj/item/robot_suit/screwdriver_act(mob/living/user, obj/item/I) //Swaps the power cell if you're holding a new one in your other hand.
	. = ..()
	if(.)
		return TRUE

	if(!chest) //can't remove a cell if there's no chest to remove it from.
		to_chat(user, span_warning("[src] has no attached torso!"))
		return

	var/obj/item/stock_parts/power_store/cell/temp_cell = user.is_holding_item_of_type(/obj/item/stock_parts/power_store/cell)
	var/swap_failed = FALSE
	if(!temp_cell) //if we're not holding a cell
		swap_failed = TRUE
	else if(!user.transferItemToLoc(temp_cell, chest))
		swap_failed = TRUE
		to_chat(user, span_warning("[temp_cell] is stuck to your hand, you can't put it in [src]!"))

	if(chest.cell) //drop the chest's current cell no matter what.
		put_in_hand_or_drop(user, chest.cell)

	if(swap_failed) //we didn't transfer any new items.
		if(chest.cell) //old cell ejected, nothing inserted.
			to_chat(user, span_notice("You remove [chest.cell] from [src]."))
			chest.cell = null
		else
			to_chat(user, span_warning("The power cell slot in [src]'s torso is empty!"))
		return

	to_chat(user, span_notice("You [chest.cell ? "replace [src]'s [chest.cell.name] with [temp_cell]" : "insert [temp_cell] into [src]"]."))
	chest.cell = temp_cell
	return TRUE

//ADD
/obj/item/robot_suit/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/M = W
		if(!l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
			if (M.use(1))
				var/obj/item/bot_assembly/ed209/B = new
				B.forceMove(drop_location())
				to_chat(user, span_notice("You arm the robot frame."))
				var/holding_this = user.get_inactive_held_item() == src
				qdel(src)
				if (holding_this)
					user.put_in_inactive_hand(B)
			else
				to_chat(user, span_warning("You need one sheet of iron to start building ED-209!"))
				return
	else if(istype(W, /obj/item/bodypart/leg/left/robot))
		if(l_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		l_leg = W
		update_appearance()

	else if(istype(W, /obj/item/bodypart/leg/right/robot))
		if(src.r_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		r_leg = W
		update_appearance()

	else if(istype(W, /obj/item/bodypart/arm/left/robot))
		if(l_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		l_arm = W
		update_appearance()

	else if(istype(W, /obj/item/bodypart/arm/right/robot))
		if(r_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)//in case it is a dismembered robotic limb
		W.cut_overlays()
		r_arm = W
		update_appearance()

	else if(istype(W, /obj/item/bodypart/chest/robot))
		var/obj/item/bodypart/chest/robot/CH = W
		if(chest)
			return
		if(CH.wired && CH.cell)
			if(!user.transferItemToLoc(CH, src))
				return
			CH.icon_state = initial(CH.icon_state) //in case it is a dismembered robotic limb
			CH.cut_overlays()
			chest = CH
			update_appearance()
		else if(!CH.wired)
			to_chat(user, span_warning("You need to attach wires to it first!"))
		else
			to_chat(user, span_warning("You need to attach a cell to it first!"))

	else if(istype(W, /obj/item/bodypart/head/robot))
		var/obj/item/bodypart/head/robot/HD = W
		if(locate(/obj/item/organ) in HD)
			to_chat(user, span_warning("There are organs inside [HD]!"))
			return
		if(head)
			return
		if(HD.flash2 && HD.flash1)
			if(!user.transferItemToLoc(HD, src))
				return
			HD.icon_state = initial(HD.icon_state)//in case it is a dismembered robotic limb
			HD.cut_overlays()
			head = HD
			update_appearance()
		else
			to_chat(user, span_warning("You need to attach a flash to it first!"))

	else if (W.tool_behaviour == TOOL_MULTITOOL)
		if(check_completion())
			ui_interact(user)
		else
			to_chat(user, span_warning("The endoskeleton must be assembled before debugging can begin!"))

	else if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/M = W
		if(check_completion())
			if(!chest.cell)
				to_chat(user, span_warning("The endoskeleton still needs a power cell!"))
				return
			if(!isturf(loc))
				to_chat(user, span_warning("You can't put [M] in, the frame has to be standing on the ground to be perfectly precise!"))
				return
			if(!M.brain_check(user))
				return

			var/mob/living/brain/brainmob = M.brainmob
			if(is_banned_from(brainmob.ckey, JOB_CYBORG) || QDELETED(src) || QDELETED(brainmob) || QDELETED(user) || QDELETED(M) || !Adjacent(user))
				if(!QDELETED(M))
					to_chat(user, span_warning("This [M.name] does not seem to fit!"))
				return
			if(!user.temporarilyRemoveItemFromInventory(W))
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot/nocell(get_turf(loc), user)
			if(!O)
				return
			if(M.laws && M.laws.id != DEFAULT_AI_LAWID)
				aisync = FALSE
				lawsync = FALSE
				O.laws = M.laws
				M.laws.associate(O)

			O.SetInvisibility(INVISIBILITY_NONE)
			//Transfer debug settings to new mob
			O.custom_name = created_name
			O.locked = panel_locked
			if(!aisync)
				lawsync = FALSE
				O.set_connected_ai(null)
			else
				O.notify_ai(AI_NOTIFICATION_NEW_BORG)
				if(forced_ai)
					O.set_connected_ai(forced_ai)
			if(!lawsync)
				O.lawupdate = FALSE
				if(M.laws.id == DEFAULT_AI_LAWID)
					O.make_laws()
					O.log_current_laws()

			brainmob.mind?.remove_antags_for_borging()
			O.job = JOB_CYBORG

			O.cell = chest.cell
			chest.cell.forceMove(O)

			W.forceMove(O)//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			QDEL_NULL(O.mmi)  //we delete the mmi created by robot/New()
			O.mmi = W //and give the real mmi to the borg.
			O.updatename(brainmob.client)
			// This canonizes that MMI'd cyborgs have memories of their previous life
			brainmob.add_mob_memory(/datum/memory/was_cyborged, protagonist = brainmob.mind, deuteragonist = user)
			brainmob.mind.transfer_to(O)
			playsound(O.loc, 'sound/mobs/non-humanoids/cyborg/liveagain.ogg', 75, TRUE)

			if(O.mind && O.mind.special_role)
				to_chat(O, span_userdanger("You have been robotized!"))
				to_chat(O, span_danger("You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead."))

			SSblackbox.record_feedback("amount", "cyborg_birth", 1)
			forceMove(O)
			O.robot_suit = src

			user.log_message("put the MMI/posibrain of [key_name(M.brainmob)] into a cyborg shell", LOG_GAME)
			M.brainmob.log_message("was put into a cyborg shell by [key_name(user)]", LOG_GAME, log_globally = FALSE)

			if(!locomotion)
				O.set_lockcharge(TRUE)
				to_chat(O, span_warning("Error: Servo motors unresponsive."))

		else
			to_chat(user, span_warning("The MMI must go in after everything else!"))

	else if(istype(W, /obj/item/borg/upgrade/ai))
		var/obj/item/borg/upgrade/ai/M = W
		if(check_completion())
			if(!isturf(loc))
				to_chat(user, span_warning("You cannot install [M], the frame has to be standing on the ground to be perfectly precise!"))
				return
			if(!user.temporarilyRemoveItemFromInventory(M))
				to_chat(user, span_warning("[M] is stuck to your hand!"))
				return
			qdel(M)
			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot/shell(get_turf(src))

			if(!aisync)
				lawsync = FALSE
				O.set_connected_ai(null)
			else
				if(forced_ai)
					O.set_connected_ai(forced_ai)
				O.notify_ai(AI_NOTIFICATION_AI_SHELL)
			if(!lawsync)
				O.lawupdate = FALSE
				O.make_laws()
				O.log_current_laws()

			O.cell = chest.cell
			chest.cell.forceMove(O)

			O.locked = panel_locked
			O.job = JOB_CYBORG
			forceMove(O)
			O.robot_suit = src
			if(!locomotion)
				O.set_lockcharge(TRUE)

	else if(IS_WRITING_UTENSIL(W))
		to_chat(user, span_warning("You need to use a multitool to name [src]!"))
	else
		return ..()

/obj/item/robot_suit/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return ..()
	var/obj/item/held_item = user.get_active_held_item()
	if(held_item?.tool_behaviour == TOOL_MULTITOOL)
		return ..()
	to_chat(user, span_warning("You need a multitool to access debug settings!"))
	return UI_CLOSE

/obj/item/robot_suit/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/robot_suit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CyborgBootDebug", "Cyborg Boot Debug")
		ui.open()

/obj/item/robot_suit/ui_data(mob/user)
	var/list/data = list()
	data["designation"] = created_name
	data["locomotion"] = locomotion
	data["panel"] = panel_locked
	data["aisync"] = aisync
	data["master"] = forced_ai_name
	data["lawsync"] = lawsync
	return data

/obj/item/robot_suit/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/user = usr

	switch(action)
		if("rename")
			var/new_name = reject_bad_name(html_encode(params["new_name"]), TRUE)
			if(!new_name)
				created_name = ""
				return
			created_name = new_name
			log_silicon("[key_name(user)] has set \"[new_name]\" as a cyborg shell name at [loc_name(user)]")
			return TRUE
		if("locomotion")
			locomotion = !locomotion
			log_silicon("[key_name(user)] has [locomotion ? "enabled" : "disabled"] movement on a cyborg shell at [loc_name(user)]")
			return TRUE
		if("panel")
			panel_locked = !panel_locked
			log_silicon("[key_name(user)] has [panel_locked ? "locked" : "unlocked"] the panel on a cyborg shell at [loc_name(user)]")
			return TRUE
		if("aisync")
			aisync = !aisync
			log_silicon("[key_name(user)] has [aisync ? "enabled" : "disabled"] the AI sync for a cyborg shell at [loc_name(user)]")
			return TRUE
		if("set_ai")
			if(length(active_ais(check_mind = FALSE, z = z)) <= 0)
				to_chat(user, span_alert("No active AIs detected."))
				return

			var/selected_ai = select_active_ai(user, z) // this one runs input()
			if(!in_range(src, user) && loc != user)
				return
			if(!selected_ai) // null = clear
				clear_forced_ai()
				return TRUE
			if(forced_ai == selected_ai) // same AI = clear
				clear_forced_ai()
				to_chat(user, span_notice("You reset [src]'s AI setting."))
				return TRUE

			set_forced_ai(selected_ai, user)
			to_chat(user, span_notice("You set [src]'s AI setting to [forced_ai_name]."))
			log_silicon("[key_name(user)] set the default AI for a cyborg shell to [key_name(selected_ai)] at [loc_name(user)]")
			return TRUE

		if("lawsync")
			lawsync = !lawsync
			log_silicon("[key_name(user)] has [lawsync ? "enabled" : "disabled"] the law sync for a cyborg shell at [loc_name(user)]")
			return TRUE

/// Sets [forced_ai] and [forced_ai_name] to the passed AI
/obj/item/robot_suit/proc/set_forced_ai(mob/living/silicon/ai/ai)
	forced_ai = ai
	forced_ai_name = ai.name
	RegisterSignal(ai, COMSIG_QDELETING, PROC_REF(ai_die))

/// Clears [forced_ai] and [forced_ai_name]
/obj/item/robot_suit/proc/clear_forced_ai()
	if(forced_ai)
		UnregisterSignal(forced_ai, COMSIG_QDELETING)
		forced_ai = null
	forced_ai_name = null

/// Clears the forced_ai ref
/obj/item/robot_suit/proc/ai_die(datum/source)
	SIGNAL_HANDLER
	// Does not use [proc/clear_forced_ai] because we'd like to keep the AI name tracked for metagaming purposes
	UnregisterSignal(forced_ai, COMSIG_QDELETING)
	forced_ai = null
