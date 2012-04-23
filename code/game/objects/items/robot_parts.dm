/obj/item/robot_parts
	name = "robot parts"
	icon = 'robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	var/construction_time = 100
	var/list/construction_cost = list("metal"=20000,"glass"=5000)

/obj/item/robot_parts/l_arm
	name = "Cyborg Left Arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	construction_time = 200
	construction_cost = list("metal"=18000)

/obj/item/robot_parts/r_arm
	name = "Cyborg Right Arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	construction_time = 200
	construction_cost = list("metal"=18000)

/obj/item/robot_parts/l_leg
	name = "Cyborg Left Leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	construction_time = 200
	construction_cost = list("metal"=15000)

/obj/item/robot_parts/r_leg
	name = "Cyborg Right Leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	construction_time = 200
	construction_cost = list("metal"=15000)

/obj/item/robot_parts/chest
	name = "Cyborg Torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"
	construction_time = 350
	construction_cost = list("metal"=40000)
	var/wires = 0.0
	var/obj/item/weapon/cell/cell = null

/obj/item/robot_parts/head
	name = "Cyborg Head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"
	construction_time = 350
	construction_cost = list("metal"=25000)
	var/obj/item/device/flash/flash1 = null
	var/obj/item/device/flash/flash2 = null

/obj/item/robot_parts/robot_suit
	name = "Cyborg Endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
	construction_time = 500
	construction_cost = list("metal"=50000)
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null
	var/created_name = "Cyborg"

/obj/item/robot_parts/robot_suit/New()
	..()
	src.updateicon()

/obj/item/robot_parts/robot_suit/proc/updateicon()
	src.overlays = null
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
				//feedback_inc("cyborg_frames_built",1)
				return 1
	return 0

/obj/item/robot_parts/robot_suit/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/stack/sheet/metal))
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

	if(istype(W, /obj/item/device/mmi))
		var/obj/item/device/mmi/M = W
		if(check_completion())
			if(!istype(loc,/turf))
				user << "\red You can't put the MMI in, the frame has to be standing on the ground to be perfectly precise."
				return
			if(!M.brainmob)
				user << "\red Sticking an empty MMI into the frame would sort of defeat the purpose."
				return
			if(M.brainmob.stat == 2)
				user << "\red Sticking a dead brain into the frame would sort of defeat the purpose."
				return

			if(M.brainmob.mind in ticker.mode.head_revolutionaries)
				user << "\red The frame's firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'.  It refuses to accept the MMI."
				return

			if(jobban_isbanned(M.brainmob, "Cyborg"))
				user << "\red This MMI does not seem to fit."
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc))
			if(!O)	return

			user.drop_item()

			O.invisibility = 0
			O.name = created_name
			O.real_name = created_name

			if (M.brainmob && M.brainmob.mind)
				M.brainmob.mind.transfer_to(O)
			else
				for(var/mob/dead/observer/G in world)
					if(G.corpse == M.brainmob && G.client && G.corpse.mind)
						G.corpse.mind.transfer_to(O)
						del(G)
						break

			if(O.mind in ticker.mode:revolutionaries)
				ticker.mode:remove_revolutionary(O.mind , 1)

			if(O.mind && O.mind.special_role)
				O.mind.store_memory("In case you look at this after being borged, the objectives are only here until I find a way to make them not show up for you, as I can't simply delete them without screwing up round-end reporting. --NeoFite")

			O << "<B>You are playing a Robot. The Robot can interact with most electronic objects in its view point.</B>"
			O << "<B>You must follow the laws that the AI has. You are the AI's assistant to the station basically.</B>"
			O << "To use something, simply click it."
			O << {"Use say ":b to speak to fellow cyborgs and the AI through binary."}

			O.job = "Cyborg"

			O.cell = chest.cell
			O.cell.loc = O
			W.loc = O//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			O.mmi = W

			//feedback_inc("cyborg_birth",1)

			del(src)
		else
			user << "\blue The MMI must go in after everything else!"

	if (istype(W, /obj/item/weapon/pen))
		var/t = input(user, "Enter new robot name", src.name, src.created_name) as text
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.created_name = t
	user.update_clothing()

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
	return

