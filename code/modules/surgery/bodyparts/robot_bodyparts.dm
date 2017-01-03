

/obj/item/bodypart/l_arm/robot
	name = "cyborg left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "l_arm"
	status = BODYPART_ROBOTIC


/obj/item/bodypart/r_arm/robot
	name = "cyborg right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "r_arm"
	status = BODYPART_ROBOTIC


/obj/item/bodypart/l_leg/robot
	name = "cyborg left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "l_leg"
	status = BODYPART_ROBOTIC


/obj/item/bodypart/r_leg/robot
	name = "cyborg right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "r_leg"
	status = BODYPART_ROBOTIC


/obj/item/bodypart/chest/robot
	name = "cyborg torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "chest"
	status = BODYPART_ROBOTIC
	var/wired = 0
	var/obj/item/weapon/stock_parts/cell/cell = null

/obj/item/bodypart/chest/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(src.cell)
			user << "<span class='warning'>You have already inserted a cell!</span>"
			return
		else
			if(!user.unEquip(W))
				return
			W.loc = src
			src.cell = W
			user << "<span class='notice'>You insert the cell.</span>"
	else if(istype(W, /obj/item/stack/cable_coil))
		if(src.wired)
			user << "<span class='warning'>You have already inserted wire!</span>"
			return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			src.wired = 1
			user << "<span class='notice'>You insert the wire.</span>"
		else
			user << "<span class='warning'>You need one length of coil to wire it!</span>"
	else
		return ..()

/obj/item/bodypart/chest/robot/Destroy()
	if(cell)
		qdel(cell)
		cell = null
	return ..()


/obj/item/bodypart/chest/robot/drop_organs(mob/user)
	if(wired)
		new /obj/item/stack/cable_coil(user.loc, 1)
	if(cell)
		cell.forceMove(user.loc)
		cell = null
	..()


/obj/item/bodypart/head/robot
	name = "cyborg head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "head"
	status = BODYPART_ROBOTIC
	var/obj/item/device/assembly/flash/handheld/flash1 = null
	var/obj/item/device/assembly/flash/handheld/flash2 = null



/obj/item/bodypart/head/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/assembly/flash/handheld))
		var/obj/item/device/assembly/flash/handheld/F = W
		if(src.flash1 && src.flash2)
			user << "<span class='warning'>You have already inserted the eyes!</span>"
			return
		else if(F.crit_fail)
			user << "<span class='warning'>You can't use a broken flash!</span>"
			return
		else
			if(!user.unEquip(W))
				return
			F.loc = src
			if(src.flash1)
				src.flash2 = F
			else
				src.flash1 = F
			user << "<span class='notice'>You insert the flash into the eye socket.</span>"
	else if(istype(W, /obj/item/weapon/crowbar))
		if(flash1 || flash2)
			playsound(src.loc, W.usesound, 50, 1)
			user << "<span class='notice'>You remove the flash from [src].</span>"
			if(flash1)
				flash1.forceMove(user.loc)
				flash1 = null
			if(flash2)
				flash2.forceMove(user.loc)
				flash2 = null
		else
			user << "<span class='warning'>There are no flash to remove from [src].</span>"

	else
		return ..()

/obj/item/bodypart/head/robot/Destroy()
	if(flash1)
		qdel(flash1)
		flash1 = null
	if(flash2)
		qdel(flash2)
		flash2 = null
	return ..()


/obj/item/bodypart/head/robot/drop_organs(mob/user)
	if(flash1)
		flash1.forceMove(user.loc)
		flash1 = null
	if(flash2)
		flash2.forceMove(user.loc)
		flash2 = null
	..()
