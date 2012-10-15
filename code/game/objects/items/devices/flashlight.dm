/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon_state = "flight0"
	w_class = 2
	item_state = "flight"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	m_amt = 50
	g_amt = 20
	icon_action_button = "action_flashlight"
	var/on = 0
	var/brightness_on = 4 //luminosity when on
	var/icon_on = "flight1"
	var/icon_off = "flight0"

/obj/item/device/flashlight/initialize()
	..()
	if (on)
		icon_state = icon_on
		src.SetLuminosity(brightness_on)
	else
		icon_state = icon_off
		src.SetLuminosity(0)

/obj/item/device/flashlight/proc/update_brightness(var/mob/user = null)
	if(on)
		icon_state = icon_on
		if(src.loc == user)
			user.SetLuminosity(user.luminosity + brightness_on)
		else if(isturf(loc))
			SetLuminosity(brightness_on)
	else
		icon_state = icon_off
		if(src.loc == user)
			user.SetLuminosity(user.luminosity - brightness_on)
		else if(isturf(loc))
			SetLuminosity(0)

/obj/item/device/flashlight/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
		return
	on = !on
	update_brightness(user)
	return


/obj/item/device/flashlight/attack(mob/living/M as mob, mob/living/user as mob)
	src.add_fingerprint(user)
	if(src.on && user.zone_sel.selecting == "eyes")

		if (((CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))//too dumb to use flashlight properly
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
			if(M.stat == DEAD || M.sdisabilities & BLIND)//mob is dead or fully blind
				if(M!=user)
					user.show_message("\red [M] pupils does not react to the light!",1)
			else if(XRAY in M.mutations)//mob has X-RAY vision
				if(M!=user)
					user.show_message("\red [M] pupils give an eerie glow!",1)
			else //nothing wrong
				if(!M.blinded)
					flick("flash", M.flash)//flash the affected mob
					if(M!=user)
						user.show_message("\blue [M] pupils narrow",1)
	else
		return ..()


/obj/item/device/flashlight/pickup(mob/user)
	if(on)
		user.SetLuminosity(user.luminosity + brightness_on)
		SetLuminosity(0)


/obj/item/device/flashlight/dropped(mob/user)
	if(on)
		user.SetLuminosity(user.luminosity - brightness_on)
		SetLuminosity(brightness_on)


/obj/item/device/flashlight/pen
	name = "penlight"
	desc = "A pen-sized light. It shines as well as a flashlight."
	icon_state = "plight0"
	flags = FPRINT | TABLEPASS | CONDUCT
	item_state = ""
	icon_on = "plight1"
	icon_off = "plight0"
	brightness_on = 3



/obj/item/device/flashlight/pen/paralysis/attack(mob/M as mob, mob/user as mob)
	if(!ismob(M))
		return
	user << "\red You stab [M] with the pen."
	M << "\red You feel a tiny prick!"
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stabbed with [src.name]  by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to stab [M.name] ([M.ckey])</font>")

	log_attack("<font color='red'>[user.name] ([user.ckey]) Used the [src.name] to stab [M.name] ([M.ckey])</font>")

	log_admin("ATTACK: [user.name] ([user.ckey]) Used the [src.name] to stab [M.name] ([M.ckey])")
	msg_admin_attack("ATTACK: [user.name] ([user.ckey]) Used the [src.name] to stab [M.name] ([M.ckey])") //BS12 EDIT ALG

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

// the desk lamps are a bit special
/obj/item/device/flashlight/lamp
	name = "desk lamp"
	desc = "A desk lamp"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lamp0"
	brightness_on = 5
	icon_on = "lamp1"
	icon_off = "lamp0"
	w_class = 4
	flags = FPRINT | TABLEPASS | CONDUCT
	m_amt = 0
	g_amt = 0
	on = 1

// green-shaded desk lamp
/obj/item/device/flashlight/lamp/green
	icon_state = "green0"
	icon_on = "green1"
	icon_off = "green0"
	desc = "A green-shaded desk lamp"

/obj/item/device/flashlight/lamp/verb/toggle_light()
	set name = "Toggle light"
	set category = "Object"
	set src in oview(1)

	if(!usr.stat)
		attack_self(usr)