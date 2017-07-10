

//The robot bodyparts have been moved to code/module/surgery/bodyparts/robot_bodyparts.dm


/obj/item/robot_suit
	name = "cyborg endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon =  'icons/obj/robot_parts.dmi'
	icon_state = "robo_suit"
	var/obj/item/bodypart/l_arm/robot/l_arm = null
	var/obj/item/bodypart/r_arm/robot/r_arm = null
	var/obj/item/bodypart/l_leg/robot/l_leg = null
	var/obj/item/bodypart/r_leg/robot/r_leg = null
	var/obj/item/bodypart/chest/robot/chest = null
	var/obj/item/bodypart/head/robot/head = null

	var/created_name = ""
	var/mob/living/silicon/ai/forced_ai
	var/locomotion = 1
	var/lawsync = 1
	var/aisync = 1
	var/panel_locked = TRUE

/obj/item/robot_suit/New()
	..()
	updateicon()

/obj/item/robot_suit/prebuilt/New()
	l_arm = new(src)
	r_arm = new(src)
	l_leg = new(src)
	r_leg = new(src)
	head = new(src)
	head.flash1 = new(head)
	head.flash2 = new(head)
	chest = new(src)
	chest.wired = TRUE
	chest.cell = new /obj/item/weapon/stock_parts/cell/high/plus(chest)
	..()

/obj/item/robot_suit/proc/updateicon()
	cut_overlays()
	if(l_arm)
		add_overlay("[l_arm.icon_state]+o")
	if(r_arm)
		add_overlay("[r_arm.icon_state]+o")
	if(chest)
		add_overlay("[chest.icon_state]+o")
	if(l_leg)
		add_overlay("[l_leg.icon_state]+o")
	if(r_leg)
		add_overlay("[r_leg.icon_state]+o")
	if(head)
		add_overlay("[head.icon_state]+o")

/obj/item/robot_suit/proc/check_completion()
	if(src.l_arm && src.r_arm)
		if(src.l_leg && src.r_leg)
			if(src.chest && src.head)
				SSblackbox.inc("cyborg_frames_built",1)
				return 1
	return 0

/obj/item/robot_suit/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		if(!l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
			if (M.use(1))
				var/obj/item/weapon/ed209_assembly/B = new /obj/item/weapon/ed209_assembly
				B.loc = get_turf(src)
				to_chat(user, "<span class='notice'>You arm the robot frame.</span>")
				var/holding_this = user.get_inactive_held_item()==src
				qdel(src)
				if (holding_this)
					user.put_in_inactive_hand(B)
			else
				to_chat(user, "<span class='warning'>You need one sheet of metal to start building ED-209!</span>")
				return
	else if(istype(W, /obj/item/bodypart/l_leg/robot))
		if(src.l_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		src.l_leg = W
		src.updateicon()

	else if(istype(W, /obj/item/bodypart/r_leg/robot))
		if(src.r_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		src.r_leg = W
		src.updateicon()

	else if(istype(W, /obj/item/bodypart/l_arm/robot))
		if(src.l_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		src.l_arm = W
		src.updateicon()

	else if(istype(W, /obj/item/bodypart/r_arm/robot))
		if(src.r_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)//in case it is a dismembered robotic limb
		W.cut_overlays()
		src.r_arm = W
		src.updateicon()

	else if(istype(W, /obj/item/bodypart/chest/robot))
		var/obj/item/bodypart/chest/robot/CH = W
		if(src.chest)
			return
		if(CH.wired && CH.cell)
			if(!user.transferItemToLoc(CH, src))
				return
			CH.icon_state = initial(CH.icon_state) //in case it is a dismembered robotic limb
			CH.cut_overlays()
			src.chest = CH
			src.updateicon()
		else if(!CH.wired)
			to_chat(user, "<span class='warning'>You need to attach wires to it first!</span>")
		else
			to_chat(user, "<span class='warning'>You need to attach a cell to it first!</span>")

	else if(istype(W, /obj/item/bodypart/head/robot))
		var/obj/item/bodypart/head/robot/HD = W
		for(var/X in HD.contents)
			if(istype(X, /obj/item/organ))
				to_chat(user, "<span class='warning'>There are organs inside [HD]!</span>")
				return
		if(src.head)
			return
		if(HD.flash2 && HD.flash1)
			if(!user.transferItemToLoc(HD, src))
				return
			HD.icon_state = initial(HD.icon_state)//in case it is a dismembered robotic limb
			HD.cut_overlays()
			src.head = HD
			src.updateicon()
		else
			to_chat(user, "<span class='warning'>You need to attach a flash to it first!</span>")

	else if (istype(W, /obj/item/device/multitool))
		if(check_completion())
			Interact(user)
		else
			to_chat(user, "<span class='warning'>The endoskeleton must be assembled before debugging can begin!</span>")

	else if(istype(W, /obj/item/device/mmi))
		var/obj/item/device/mmi/M = W
		if(check_completion())
			if(!isturf(loc))
				to_chat(user, "<span class='warning'>You can't put [M] in, the frame has to be standing on the ground to be perfectly precise!</span>")
				return
			if(!M.brainmob)
				to_chat(user, "<span class='warning'>Sticking an empty [M.name] into the frame would sort of defeat the purpose!</span>")
				return

			var/mob/living/brain/BM = M.brainmob
			if(!BM.key || !BM.mind)
				to_chat(user, "<span class='warning'>The MMI indicates that their mind is completely unresponsive; there's no point!</span>")
				return

			if(!BM.client) //braindead
				to_chat(user, "<span class='warning'>The MMI indicates that their mind is currently inactive; it might change!</span>")
				return

			if(BM.stat == DEAD || (M.brain && M.brain.damaged_brain))
				to_chat(user, "<span class='warning'>Sticking a dead brain into the frame would sort of defeat the purpose!</span>")
				return

			if(jobban_isbanned(BM, "Cyborg"))
				to_chat(user, "<span class='warning'>This [M.name] does not seem to fit!</span>")
				return

			if(!user.temporarilyRemoveItemFromInventory(W))
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc))
			if(!O)
				return

			if(M.laws && M.laws.id != DEFAULT_AI_LAWID)
				aisync = 0
				lawsync = 0
				O.laws = M.laws
				M.laws.associate(O)

			O.invisibility = 0
			//Transfer debug settings to new mob
			O.custom_name = created_name
			O.locked = panel_locked
			if(!aisync)
				lawsync = 0
				O.connected_ai = null
			else
				O.notify_ai(NEW_BORG)
				if(forced_ai)
					O.connected_ai = forced_ai
			if(!lawsync)
				O.lawupdate = 0
				if(M.laws.id == DEFAULT_AI_LAWID)
					O.make_laws()

			SSticker.mode.remove_antag_for_borging(BM.mind)
			if(!istype(M.laws, /datum/ai_laws/ratvar))
				remove_servant_of_ratvar(BM, TRUE)
			BM.mind.transfer_to(O)

			if(O.mind && O.mind.special_role)
				O.mind.store_memory("As a cyborg, you must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.")
				to_chat(O, "<span class='userdanger'>You have been robotized!</span>")
				to_chat(O, "<span class='danger'>You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.</span>")

			O.job = "Cyborg"

			O.cell = chest.cell
			chest.cell.loc = O
			chest.cell = null
			W.forceMove(O)//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			if(O.mmi) //we delete the mmi created by robot/New()
				qdel(O.mmi)
			O.mmi = W //and give the real mmi to the borg.
			O.updatename()

			SSblackbox.inc("cyborg_birth",1)

			forceMove(O)
			O.robot_suit = src

			if(!locomotion)
				O.lockcharge = 1
				O.update_canmove()
				to_chat(O, "<span class='warning'>Error: Servo motors unresponsive.</span>")

		else
			to_chat(user, "<span class='warning'>The MMI must go in after everything else!</span>")

	else if(istype(W, /obj/item/borg/upgrade/ai))
		var/obj/item/borg/upgrade/ai/M = W
		if(check_completion())
			if(!isturf(loc))
				to_chat(user, "<span class='warning'>You cannot install[M], the frame has to be standing on the ground to be perfectly precise!</span>")
				return
			if(!user.drop_item())
				to_chat(user, "<span class='warning'>[M] is stuck to your hand!</span>")
				return
			qdel(M)
			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot/shell(get_turf(src))

			if(!aisync)
				lawsync = FALSE
				O.connected_ai = null
			else
				if(forced_ai)
					O.connected_ai = forced_ai
				O.notify_ai(AI_SHELL)
			if(!lawsync)
				O.lawupdate = FALSE
				O.make_laws()


			O.cell = chest.cell
			chest.cell.loc = O
			chest.cell = null
			O.locked = panel_locked
			O.job = "Cyborg"
			forceMove(O)
			O.robot_suit = src
			if(!locomotion)
				O.lockcharge = TRUE
				O.update_canmove()

	else if(istype(W,/obj/item/weapon/pen))
		to_chat(user, "<span class='warning'>You need to use a multitool to name [src]!</span>")
	else
		return ..()

/obj/item/robot_suit/proc/Interact(mob/user)
			var/t1 = text("Designation: <A href='?src=\ref[];Name=1'>[(created_name ? "[created_name]" : "Default Cyborg")]</a><br>\n",src)
			t1 += text("Master AI: <A href='?src=\ref[];Master=1'>[(forced_ai ? "[forced_ai.name]" : "Automatic")]</a><br><br>\n",src)

			t1 += text("LawSync Port: <A href='?src=\ref[];Law=1'>[(lawsync ? "Open" : "Closed")]</a><br>\n",src)
			t1 += text("AI Connection Port: <A href='?src=\ref[];AI=1'>[(aisync ? "Open" : "Closed")]</a><br>\n",src)
			t1 += text("Servo Motor Functions: <A href='?src=\ref[];Loco=1'>[(locomotion ? "Unlocked" : "Locked")]</a><br>\n",src)
			t1 += text("Panel Lock: <A href='?src=\ref[];Panel=1'>[(panel_locked ? "Engaged" : "Disengaged")]</a><br>\n",src)
			var/datum/browser/popup = new(user, "robotdebug", "Cyborg Boot Debug", 310, 220)
			popup.set_content(t1)
			popup.open()

/obj/item/robot_suit/Topic(href, href_list)
	if(usr.incapacitated() || !Adjacent(usr))
		return

	var/mob/living/living_user = usr
	var/obj/item/item_in_hand = living_user.get_active_held_item()
	if(!istype(item_in_hand, /obj/item/device/multitool))
		to_chat(living_user, "<span class='warning'>You need a multitool!</span>")
		return

	if(href_list["Name"])
		var/new_name = reject_bad_name(input(usr, "Enter new designation. Set to blank to reset to default.", "Cyborg Debug", src.created_name),1)
		if(!in_range(src, usr) && src.loc != usr)
			return
		if(new_name)
			created_name = new_name
		else
			created_name = ""

	else if(href_list["Master"])
		forced_ai = select_active_ai(usr)
		if(!forced_ai)
			to_chat(usr, "<span class='error'>No active AIs detected.</span>")

	else if(href_list["Law"])
		lawsync = !lawsync
	else if(href_list["AI"])
		aisync = !aisync
	else if(href_list["Loco"])
		locomotion = !locomotion
	else if(href_list["Panel"])
		panel_locked = !panel_locked

	add_fingerprint(usr)
	Interact(usr)

