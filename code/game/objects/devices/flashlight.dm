//#define FLASHLIGHT_LUM 4

/obj/item/device/flashlight/attack_self(mob/user)
	on = !on
	if (on)
		icon_state = icon_on
	else
		icon_state = icon_off

	if(on)
		user.sd_SetLuminosity(user.luminosity + brightness_on)
	else
		user.sd_SetLuminosity(user.luminosity - brightness_on)


/obj/item/device/flashlight/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	if(src.on && user.zone_sel.selecting == "eyes")
		if ((user.mutations & CLOWN || user.brainloss >= 60) && prob(50))//too dumb to use flashlight properly
			return ..()//just hit them in the head
			/*user << "\blue You bounce the light spot up and down and drool."
			for(var/mob/O in viewers(M, null))
				O.show_message(text("\blue [] bounces the light spot up and down and drools", user), 1)
			src.add_fingerprint(user)
			return*/

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


/obj/item/device/flashlight/pickup(mob/user)
	if(on)
		src.sd_SetLuminosity(0)
		user.sd_SetLuminosity(user.luminosity + brightness_on)



/obj/item/device/flashlight/dropped(mob/user)
	if(on)
		user.sd_SetLuminosity(user.luminosity - brightness_on)
		src.sd_SetLuminosity(brightness_on)

/obj/item/clothing/head/helmet/hardhat/attack_self(mob/user)
	on = !on
	icon_state = "hardhat[on]"
	item_state = "hardhat[on]"

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