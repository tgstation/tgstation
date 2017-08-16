

/obj/item/bodypart/l_arm/robot
	name = "cyborg left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "borg_l_arm"
	status = BODYPART_ROBOTIC


/obj/item/bodypart/r_arm/robot
	name = "cyborg right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "borg_r_arm"
	status = BODYPART_ROBOTIC


/obj/item/bodypart/l_leg/robot
	name = "cyborg left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "borg_l_leg"
	status = BODYPART_ROBOTIC


/obj/item/bodypart/r_leg/robot
	name = "cyborg right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "borg_r_leg"
	status = BODYPART_ROBOTIC


/obj/item/bodypart/chest/robot
	name = "cyborg torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	item_state = "buildpipe"
	icon = 'icons/obj/robot_parts.dmi'
	flags = CONDUCT
	icon_state = "borg_chest"
	status = BODYPART_ROBOTIC
	var/wired = 0
	var/obj/item/stock_parts/cell/cell = null

/obj/item/bodypart/chest/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(src.cell)
			to_chat(user, "<span class='warning'>You have already inserted a cell!</span>")
			return
		else
			if(!user.transferItemToLoc(W, src))
				return
			src.cell = W
			to_chat(user, "<span class='notice'>You insert the cell.</span>")
	else if(istype(W, /obj/item/stack/cable_coil))
		if(src.wired)
			to_chat(user, "<span class='warning'>You have already inserted wire!</span>")
			return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			src.wired = 1
			to_chat(user, "<span class='notice'>You insert the wire.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of coil to wire it!</span>")
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
	icon_state = "borg_head"
	status = BODYPART_ROBOTIC
	var/obj/item/device/assembly/flash/handheld/flash1 = null
	var/obj/item/device/assembly/flash/handheld/flash2 = null



/obj/item/bodypart/head/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/assembly/flash/handheld))
		var/obj/item/device/assembly/flash/handheld/F = W
		if(src.flash1 && src.flash2)
			to_chat(user, "<span class='warning'>You have already inserted the eyes!</span>")
			return
		else if(F.crit_fail)
			to_chat(user, "<span class='warning'>You can't use a broken flash!</span>")
			return
		else
			if(!user.transferItemToLoc(F, src))
				return
			if(src.flash1)
				src.flash2 = F
			else
				src.flash1 = F
			to_chat(user, "<span class='notice'>You insert the flash into the eye socket.</span>")
	else if(istype(W, /obj/item/crowbar))
		if(flash1 || flash2)
			playsound(src.loc, W.usesound, 50, 1)
			to_chat(user, "<span class='notice'>You remove the flash from [src].</span>")
			if(flash1)
				flash1.forceMove(user.loc)
				flash1 = null
			if(flash2)
				flash2.forceMove(user.loc)
				flash2 = null
		else
			to_chat(user, "<span class='warning'>There are no flash to remove from [src].</span>")

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




/obj/item/bodypart/l_arm/robot/surplus
	name = "surplus prosthetic left arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	icon_state = "l_arm"
	max_damage = 20

/obj/item/bodypart/r_arm/robot/surplus
	name = "surplus prosthetic right arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	icon_state = "r_arm"
	max_damage = 20

/obj/item/bodypart/l_leg/robot/surplus
	name = "surplus prosthetic left leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	icon_state = "l_leg"
	max_damage = 20

/obj/item/bodypart/r_leg/robot/surplus
	name = "surplus prosthetic right leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	icon_state = "r_leg"
	max_damage = 20
