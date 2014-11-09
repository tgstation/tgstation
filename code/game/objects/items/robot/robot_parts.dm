/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	w_type=RECYK_ELECTRONIC
	var/list/part = null
	var/sabotaged = 0 //Emagging limbs can have repercussions when installed as prosthetics.

/*
/obj/item/robot_parts/recycle(var/datum/materials/rec)
	for(var/material in materials)
		var/rec_mat=material
		var/CCPS=CC_PER_SHEET_MISC
		if(rec_mat=="metal")
			rec_mat="iron"
			CCPS=CC_PER_SHEET_METAL
		if(rec_mat=="glass")
			CCPS=CC_PER_SHEET_GLASS
		rec.addAmount(material,materials[material]/CCPS)
	return 1
*/

/obj/item/robot_parts/l_arm
	name = "robot left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	part = list("l_arm","l_hand")

/obj/item/robot_parts/r_arm
	name = "robot right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	part = list("r_arm","r_hand")

/obj/item/robot_parts/l_leg
	name = "robot left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	part = list("l_leg","l_foot")

/obj/item/robot_parts/r_leg
	name = "robot right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	part = list("r_leg","r_foot")

/obj/item/robot_parts/chest
	name = "robot torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"
	var/wires = 0.0
	var/obj/item/weapon/cell/cell = null

/obj/item/robot_parts/head
	name = "robot head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"
	var/obj/item/device/flash/flash1 = null
	var/obj/item/device/flash/flash2 = null

/obj/item/robot_parts/robot_suit
	name = "robot endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null
	var/created_name = ""

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

/obj/item/robot_parts/robot_suit/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/stack/sheet/metal) && !l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
		var/obj/item/weapon/ed209_assembly/B = new /obj/item/weapon/ed209_assembly
		B.loc = get_turf(src)
		user << "You armed the robot frame"
		W:use(1)
		if (user.get_inactive_hand()==src)
			user.before_take_item(src)
			user.put_in_inactive_hand(B)
		del(src)
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
			user << "\blue You need to attach wires to it first!"
		else
			user << "\blue You need to attach a cell to it first!"

	if(istype(W, /obj/item/robot_parts/head))
		if(src.head)	return
		if(W:flash2 && W:flash1)
			user.drop_item()
			W.loc = src
			src.head = W
			src.updateicon()
		else
			user << "\blue You need to attach a flash to it first!"

	if(istype(W, /obj/item/device/mmi) || istype(W, /obj/item/device/mmi/posibrain))
		var/obj/item/device/mmi/M = W
		if(check_completion())
			if(!istype(loc,/turf))
				user << "\red You can't put the [W] in, the frame has to be standing on the ground to be perfectly precise."
				return
			if(!M.brainmob)
				user << "\red Sticking an empty [W] into the frame would sort of defeat the purpose."
				return
			if(!M.brainmob.key)
				var/ghost_can_reenter = 0
				if(M.brainmob.mind)
					for(var/mob/dead/observer/G in player_list)
						if(G.can_reenter_corpse && G.mind == M.brainmob.mind)
							ghost_can_reenter = 1
							break
				if(!ghost_can_reenter)
					user << "<span class='notice'>The [W] is completely unresponsive; there's no point.</span>"
					return

			if(M.brainmob.stat == DEAD)
				user << "\red Sticking a dead [W] into the frame would sort of defeat the purpose."
				return

			if(M.brainmob.mind in ticker.mode.head_revolutionaries)
				user << "\red The frame's firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept the [W]."
				return

			if(jobban_isbanned(M.brainmob, "Cyborg"))
				user << "\red This [W] does not seem to fit."
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc), unfinished = 1)
			if(!O)	return

			user.drop_item()

			O.mmi = W
			O.invisibility = 0
			O.custom_name = created_name
			O.updatename("Default")

			M.brainmob.mind.transfer_to(O)

			if(O.mind && O.mind.special_role)
				O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")

			O.job = "Cyborg"

			O.cell = chest.cell
			O.cell.loc = O
			W.loc = O //Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.

			// Since we "magically" installed a cell, we also have to update the correct component.
			if(O.cell)
				var/datum/robot_component/cell_component = O.components["power cell"]
				cell_component.wrapped = O.cell
				cell_component.installed = 1

			feedback_inc("cyborg_birth",1)
			O.Namepick()

			del(src)
		else
			user << "\blue The MMI must go in after everything else!"

	if (istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter new robot name", src.name, src.created_name, MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t

	return

/obj/item/robot_parts/chest/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/cell))
		if(src.cell)
			user << "\blue You have already inserted a cell!"
			return
		else
			user.drop_item()
			W.loc = src
			src.cell = W
			user << "\blue You insert the cell!"
	if(istype(W, /obj/item/weapon/cable_coil))
		if(src.wires)
			user << "\blue You have already inserted wire!"
			return
		else
			var/obj/item/weapon/cable_coil/coil = W
			coil.use(1)
			src.wires = 1.0
			user << "\blue You insert the wire!"
	return

/obj/item/robot_parts/head/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/device/flash))
		if(src.flash1 && src.flash2)
			user << "\blue You have already inserted the eyes!"
			return
		else if(src.flash1)
			user.drop_item()
			W.loc = src
			src.flash2 = W
			user << "\blue You insert the flash into the eye socket!"
		else
			user.drop_item()
			W.loc = src
			src.flash1 = W
			user << "\blue You insert the flash into the eye socket!"
	else if(istype(W, /obj/item/weapon/stock_parts/manipulator))
		user << "\blue You install some manipulators and modify the head, creating a functional spider-bot!"
		new /mob/living/simple_animal/spiderbot(get_turf(loc))
		user.drop_item()
		del(W)
		del(src)
		return
	return

/obj/item/robot_parts/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/card/emag))
		if(sabotaged)
			user << "\red [src] is already sabotaged!"
		else
			user << "\red You slide [W] into the dataport on [src] and short out the safeties."
			sabotaged = 1
		return
	..()