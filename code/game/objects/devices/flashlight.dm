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


	attack_self(mob/user)
		on = !on
		if (on)
			icon_state = icon_on
			user.sd_SetLuminosity(user.luminosity + brightness_on)
		else
			icon_state = icon_off
			user.sd_SetLuminosity(user.luminosity - brightness_on)
		return


	attack(mob/M as mob, mob/user as mob)
		src.add_fingerprint(user)
		if(src.on && user.zone_sel.selecting == "eyes")
			if ((user.mutations & CLOWN || user.brainloss >= 60) && prob(50))//too dumb to use flashlight properly
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
				if(M.stat > 1 || M.sdisabilities & 1)//mob is dead or fully blind
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


	pickup(mob/user)
		if(on)
			src.sd_SetLuminosity(0)
			user.sd_SetLuminosity(user.luminosity + brightness_on)


	dropped(mob/user)
		if(on)
			user.sd_SetLuminosity(user.luminosity - brightness_on)
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



//Looks like most of the clothing lights are here
/obj/item/clothing/head/helmet/hardhat/attack_self(mob/user)
	on = !on
	icon_state = "hardhat[on]_[color]"
	item_state = "hardhat[on]_[color]"

	if(on)
		user.sd_SetLuminosity(user.luminosity + brightness_on)
	else
		user.sd_SetLuminosity(user.luminosity - brightness_on)

/obj/item/clothing/head/helmet/hardhat/pickup(mob/user)
	if(on)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + brightness_on)

/obj/item/clothing/head/helmet/hardhat/dropped(mob/user)
	if(on)
		user.sd_SetLuminosity(user.luminosity - brightness_on)
		src.sd_SetLuminosity(brightness_on)

/*
/obj/item/clothing/head/helmet/space/engineering/verb/toggle()
	set name = "Toggle Helmet Light"
	set category = "Object"
	on = !on
	icon_state = "helm_engineering[on]"

	if(on)
		usr.sd_SetLuminosity(usr.luminosity + brightness_on)
	else
		usr.sd_SetLuminosity(usr.luminosity - brightness_on)

/obj/item/clothing/head/helmet/space/engineering/attack_self(mob/user)
	on = !on
	icon_state = "helm_engineering[on]"

	if(on)
		user.sd_SetLuminosity(user.luminosity + brightness_on)
	else
		user.sd_SetLuminosity(user.luminosity - brightness_on)

/obj/item/clothing/head/helmet/space/engineering/pickup(mob/user)
	if(on)
		src.sd_SetLuminosity(0)
		usr.sd_SetLuminosity(usr.luminosity + brightness_on)

/obj/item/clothing/head/helmet/space/engineering/dropped(mob/user)
	if(on)
		usr.sd_SetLuminosity(usr.luminosity - brightness_on)
		src.sd_SetLuminosity(brightness_on)

/obj/item/clothing/head/helmet/space/command/chief_engineer/verb/toggle()
	set name = "Toggle Helmet Light"
	set category = "Object"
	on = !on
	icon_state = "helm_ce[on]"

	if(on)
		usr.sd_SetLuminosity(usr.luminosity + brightness_on)
	else
		usr.sd_SetLuminosity(usr.luminosity - brightness_on)

/obj/item/clothing/head/helmet/space/command/chief_engineer/attack_self(mob/user)
	on = !on
	icon_state = "helm_ce[on]"

	if(on)
		user.sd_SetLuminosity(user.luminosity + brightness_on)
	else
		user.sd_SetLuminosity(user.luminosity - brightness_on)

/obj/item/clothing/head/helmet/space/command/chief_engineer/pickup(mob/user)
	if(on)
		src.sd_SetLuminosity(0)
		usr.sd_SetLuminosity(usr.luminosity + brightness_on)

/obj/item/clothing/head/helmet/space/command/chief_engineer/dropped(mob/user)
	if(on)
		usr.sd_SetLuminosity(usr.luminosity - brightness_on)
		src.sd_SetLuminosity(brightness_on)

*/