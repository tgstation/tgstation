/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon_state = "flight0"
	w_class = 2
	item_state = "flight"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	m_amt = 50
	g_amt = 20
	var
		on = 0
		brightness_on = 4 //luminosity when on
		icon_on = "flight1"
		icon_off = "flight0"

/obj/item/device/flashlight/initialize()
	..()
	if (on)
		icon_state = icon_on
		src.sd_SetLuminosity(brightness_on)
	else
		icon_state = icon_off
		src.sd_SetLuminosity(0)

/obj/item/device/flashlight/proc/update_brightness(var/mob/user = null)
	if (on)
		icon_state = icon_on
		if(src.loc == user)
			user.total_luminosity += brightness_on
		else if (isturf(src.loc))
			src.sd_SetLuminosity(brightness_on)

	else
		icon_state = icon_off
		if(src.loc == user)
			user.total_luminosity -= brightness_on
		else if (isturf(src.loc))
			src.sd_SetLuminosity(0)

/obj/item/device/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
		return
	on = !on
	update_brightness(user)
	return


/obj/item/device/flashlight/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	if(src.on && user.zone_sel.selecting == "eyes")
		if ((user.mutations & CLUMSY || user.getBrainLoss() >= 60) && prob(50))//too dumb to use flashlight properly
			return ..()//just hit them in the head

		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")//don't have dexterity
			usr.show_message("\red You don't have the dexterity to do this!",1)
			return

		var/mob/living/carbon/human/H = M//mob has protective eyewear
		if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
			user << text("\blue You're going to need to remove that [] first.", ((H.head && H.head.flags & HEADCOVERSEYES) ? "helmet" : ((H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) ? "mask": "glasses")))
			return

		for(var/mob/O in viewers(M, null))//echo message
			if ((O.client && !(O.blinded )))
				O.show_message("\blue [(O==user?"You direct":"[user] directs")] [src] to [(M==user? "your":"[M]")] eyes", 1)

		if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))//robots and aliens are unaffected
			if(M.stat > 1 || M.disabilities & 128)//mob is dead or fully blind
				if(M!=user)
					user.show_message(text("\red [] pupils does not react to the light!", M),1)
			else if(M.mutations & XRAY)//mob has X-RAY vision
				if(M!=user)
					user.show_message(text("\red [] pupils give an eerie glow!", M),1)
			else //nothing wrong
				flick("flash", M.flash)//flash the affected mob
				if(M!=user)
					user.show_message(text("\blue [] pupils narrow", M),1)
	else
		return ..()


/obj/item/device/flashlight/pickup(mob/user)
	if(on)
		user.total_luminosity += brightness_on
		src.sd_SetLuminosity(0)


/obj/item/device/flashlight/dropped(mob/user)
	if(on)
		user.total_luminosity -= brightness_on
		src.sd_SetLuminosity(brightness_on)


/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light. It shines as well as a flashlight."
	icon_state = "plight0"
	flags = FPRINT | TABLEPASS | CONDUCT
	item_state = ""
	icon_on = "plight1"
	icon_off = "plight0"
	brightness_on = 3
	w_class = 1



/obj/item/device/flashlight/pen/paralysis/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M))
		return
	user << "\red You stab [M] with the pen."
//	M << "\red You feel a tiny prick!"
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [src.name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to stab [M.name] ([M.ckey])</font>")

	log_admin("ATTACK: [user] ([user.ckey]) stabbed [M] ([M.ckey]) with [src].")
	message_admins("ATTACK: [user] ([user.ckey]) stabbed [M] ([M.ckey]) with [src].")
	log_attack("<font color='red'>[user.name] ([user.ckey]) Used the [src.name] to stab [M.name] ([M.ckey])</font>")


	..()
	return

/obj/item/device/flashlight/pen/paralysis/New()
	var/datum/reagents/R = new/datum/reagents(15)
	reagents = R
	R.my_atom = src
	R.add_reagent("zombiepowder", 15)
	..()
	return

/obj/item/device/flashlight/pen/paralysis/attack(mob/M as mob, mob/user as mob)
	if (!( istype(M, /mob) ))
		return
	..()
	if (reagents.total_volume)
		if(M.reagents) reagents.trans_to(M, 15)
	return


//Looks like most of the clothing lights are here
/obj/item/clothing/head/helmet/hardhat/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
		return
	on = !on
	icon_state = "hardhat[on]_[color]"
	item_state = "hardhat[on]_[color]"

	if(on)
		user.total_luminosity += brightness_on
	else
		user.total_luminosity -= brightness_on

/obj/item/clothing/head/helmet/hardhat/pickup(mob/user)
	if(on)
		user.total_luminosity += brightness_on
		user.UpdateLuminosity()
		src.sd_SetLuminosity(0)

/obj/item/clothing/head/helmet/hardhat/dropped(mob/user)
	if(on)
		user.total_luminosity -= brightness_on
		user.UpdateLuminosity()
		src.sd_SetLuminosity(brightness_on)

//RIG helmet light
/obj/item/clothing/head/helmet/space/rig/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
		return
	on = !on
	icon_state = "rig[on]-[color]"
	item_state = "rig[on]-[color]"

	if(on)
		user.total_luminosity += brightness_on
	else
		user.total_luminosity -= brightness_on

/obj/item/clothing/head/helmet/space/rig/pickup(mob/user)
	if(on)
		user.total_luminosity += brightness_on
		user.UpdateLuminosity()
		src.sd_SetLuminosity(0)

/obj/item/clothing/head/helmet/space/rig/dropped(mob/user)
	if(on)
		user.total_luminosity -= brightness_on
		user.UpdateLuminosity()
		src.sd_SetLuminosity(brightness_on)

/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)