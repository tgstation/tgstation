/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = CONDUCT
	slot_flags = SLOT_BELT

/obj/item/robot_parts/l_arm
	name = "cyborg left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"

/obj/item/robot_parts/r_arm
	name = "cyborg right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"

/obj/item/robot_parts/l_leg
	name = "cyborg left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"

/obj/item/robot_parts/r_leg
	name = "cyborg right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"

/obj/item/robot_parts/chest
	name = "cyborg torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"
	var/wires = 0.0
	var/obj/item/weapon/stock_parts/cell/cell = null

/obj/item/robot_parts/head
	name = "cyborg head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"
	var/obj/item/device/flash/handheld/flash1 = null
	var/obj/item/device/flash/handheld/flash2 = null

/obj/item/robot_parts/robot_suit
	name = "cyborg endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null

	var/created_name = ""
	var/mob/living/silicon/ai/forced_ai
	var/locomotion = 1
	var/lawsync = 1
	var/aisync = 1
	var/panel_locked = 1

/obj/item/robot_parts/robot_suit/New()
	..()
	src.updateicon()

/obj/item/robot_parts/robot_suit/proc/updateicon()
	src.overlays.Cut()
	if(src.l_arm)
		src.overlays += "l_arm+o"
	if(src.r_arm)
		src.overlays += "r_arm+o"
	if(src.chest)
		src.overlays += "chest+o"
	if(src.l_leg)
		src.overlays += "l_leg+o"
	if(src.r_leg)
		src.overlays += "r_leg+o"
	if(src.head)
		src.overlays += "head+o"

/obj/item/robot_parts/robot_suit/proc/check_completion()
	if(src.l_arm && src.r_arm)
		if(src.l_leg && src.r_leg)
			if(src.chest && src.head)
				feedback_inc("cyborg_frames_built",1)
				return 1
	return 0

/obj/item/robot_parts/robot_suit/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/stack/sheet/metal) && !l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
		var/obj/item/stack/sheet/metal/M = W
		if (M.use(1))
			var/obj/item/weapon/ed209_assembly/B = new /obj/item/weapon/ed209_assembly
			B.loc = get_turf(src)
			user << "<span class='notice'>You arm the robot frame.</span>"
			if (user.get_inactive_hand()==src)
				user.unEquip(src)
				user.put_in_inactive_hand(B)
			qdel(src)
		else
			user << "<span class='warning'>You need one sheet of metal to start building ED-209!</span>"
			return
	if(istype(W, /obj/item/robot_parts/l_leg))
		if(src.l_leg)	return
		user.drop_item()
		W.loc = src
		src.l_leg = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/r_leg))
		if(src.r_leg)	return
		user.drop_item()
		W.loc = src
		src.r_leg = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/l_arm))
		if(src.l_arm)	return
		user.drop_item()
		W.loc = src
		src.l_arm = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/r_arm))
		if(src.r_arm)	return
		user.drop_item()
		W.loc = src
		src.r_arm = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/chest))
		if(src.chest)	return
		if(W:wires && W:cell)
			user.drop_item()
			W.loc = src
			src.chest = W
			src.updateicon()
		else if(!W:wires)
			user << "<span class='warning'>You need to attach wires to it first!</span>"
		else
			user << "<span class='warning'>You need to attach a cell to it first!</span>"

	if(istype(W, /obj/item/robot_parts/head))
		if(src.head)	return
		if(W:flash2 && W:flash1)
			user.drop_item()
			W.loc = src
			src.head = W
			src.updateicon()
		else
			user << "<span class='warning'>You need to attach a flash to it first!</span>"

	if (istype(W, /obj/item/device/multitool))
		if(check_completion())
			Interact(user)
		else
			user << "<span class='warning'>The endoskeleton must be assembled before debugging can begin!</span>"

	if(istype(W, /obj/item/device/mmi))
		var/obj/item/device/mmi/M = W
		if(check_completion())
			if(!istype(loc,/turf))
				user << "<span class='warning'>You can't put the MMI in, the frame has to be standing on the ground to be perfectly precise!</span>"
				return
			if(!M.brainmob)
				user << "<span class='warning'>Sticking an empty MMI into the frame would sort of defeat the purpose!</span>"
				return

			var/mob/living/carbon/brain/BM = M.brainmob
			if(!BM.key || !BM.mind)
				user << "<span class='warning'>The mmi indicates that their mind is completely unresponsive; there's no point!</span>"
				return

			if(!BM.client) //braindead
				user << "<span class='warning'>The mmi indicates that their mind is currently inactive; it might change!</span>"
				return

			if(BM.stat == DEAD)
				user << "<span class='warning'>Sticking a dead brain into the frame would sort of defeat the purpose!</span>"
				return

			if((BM.mind in ticker.mode.head_revolutionaries) || (BM.mind in ticker.mode.A_bosses) || (BM.mind in ticker.mode.B_bosses))
				user << "<span class='warning'>The frame's firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept the MMI!</span>"
				return

			if(jobban_isbanned(BM, "Cyborg"))
				user << "<span class='warning'>This MMI does not seem to fit!</span>"
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc))
			if(!O)	return

			user.drop_item()

			O.invisibility = 0
			//Transfer debug settings to new mob
			O.custom_name = created_name
			O.updatename("Default")
			O.locked = panel_locked
			if(!aisync)
				lawsync = 0
				O.connected_ai = null
			else
				O.notify_ai(1)
				if(forced_ai)
					O.connected_ai = forced_ai
			if(!lawsync)
				O.lawupdate = 0
				O.make_laws()
				if(ticker.mode.config_tag == "malfunction") //Don't let humans get a cyborg on their side during malf, for balance reasons.
					O.set_zeroth_law("<span class='danger'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK#*�&110010</span>")

			BM.mind.transfer_to(O)

			if(O.mind && O.mind.special_role)
				O.mind.store_memory("As a cyborg, any objectives listed here are null and void, and will be marked as failed. They are simply here for memory purposes.")

			O.job = "Cyborg"

			O.cell = chest.cell
			chest.cell.loc = O
			chest.cell = null
			W.loc = O//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			O.mmi = W
			O.updatename()

			feedback_inc("cyborg_birth",1)

			src.loc = O
			O.robot_suit = src

			if(!locomotion)
				O.lockcharge = 1
				O.update_canmove()
				O << "<span class='warning'>Error: Servo motors unresponsive.</span>"

		else
			user << "<span class='warning'>The MMI must go in after everything else!</span>"

	if(istype(W,/obj/item/weapon/pen))
		user << "<span class='warning'>You need to use a multitool to name [src]!</span>"
	return

/obj/item/robot_parts/robot_suit/proc/Interact(mob/user)
			var/t1 = text("Designation: <A href='?src=\ref[];Name=1'>[(created_name ? "[created_name]" : "Default Cyborg")]</a><br>\n",src)
			t1 += text("Master AI: <A href='?src=\ref[];Master=1'>[(forced_ai ? "[forced_ai.name]" : "Automatic")]</a><br><br>\n",src)

			t1 += text("LawSync Port: <A href='?src=\ref[];Law=1'>[(lawsync ? "Open" : "Closed")]</a><br>\n",src)
			t1 += text("AI Connection Port: <A href='?src=\ref[];AI=1'>[(aisync ? "Open" : "Closed")]</a><br>\n",src)
			t1 += text("Servo Motor Functions: <A href='?src=\ref[];Loco=1'>[(locomotion ? "Unlocked" : "Locked")]</a><br>\n",src)
			t1 += text("Panel Lock: <A href='?src=\ref[];Panel=1'>[(panel_locked ? "Engaged" : "Disengaged")]</a><br>\n",src)
			var/datum/browser/popup = new(user, "robotdebug", "Cyborg Boot Debug", 310, 220)
			popup.set_content(t1)
			popup.open()

/obj/item/robot_parts/robot_suit/Topic(href, href_list)
	if(usr.lying || usr.stat || usr.stunned || !Adjacent(usr))
		return

	var/mob/living/living_user = usr
	var/obj/item/item_in_hand = living_user.get_active_hand()
	if(!istype(item_in_hand, /obj/item/device/multitool))
		living_user << "<span class='warning'>You need a multitool!</span>"
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
			usr << "<span class='error'>No active AIs detected.</span>"

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
	return

/obj/item/robot_parts/chest/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(src.cell)
			user << "<span class='warning'>You have already inserted a cell!</span>"
			return
		else
			user.drop_item()
			W.loc = src
			src.cell = W
			user << "<span class='notice'>You insert the cell.</span>"
	if(istype(W, /obj/item/stack/cable_coil))
		if(src.wires)
			user << "<span class='warning'>You have already inserted wire!</span>"
			return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			src.wires = 1.0
			user << "<span class='notice'>You insert the wire.</span>"
		else
			user << "<span class='warning'>You need one length of coil to wire it!</span>"
	return

/obj/item/robot_parts/head/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/device/flash/handheld))
		var/obj/item/device/flash/handheld/F = W
		if(src.flash1 && src.flash2)
			user << "<span class='warning'>You have already inserted the eyes!</span>"
			return
		else if(F.broken)
			user << "<span class='warning'>You can't use a broken flash!</span>"
			return
		else
			user.drop_item()
			F.loc = src
			if(src.flash1)
				src.flash2 = F
			else
				src.flash1 = F
			user << "<span class='notice'>You insert the flash into the eye socket.</span>"
	return

