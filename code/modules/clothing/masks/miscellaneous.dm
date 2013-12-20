/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "blindfold"
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/muzzle/gag
	name = "gag"
	desc = "Stick this in their mouth to stop the noise."
	icon_state = "gag"
	w_class = 1

/obj/item/clothing/mask/muzzle/attack_paw(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.wear_mask)
			user << "<span class='notice'>You need help taking this off!</span>"
			return
	..()

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = 1
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.01
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 25, rad = 0)

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	flags = FPRINT|TABLEPASS
	flags_inv = HIDEFACE

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask."
	icon_state = "pig"
	item_state = "pig"
	flags = FPRINT|TABLEPASS|BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags = FPRINT|TABLEPASS|BLOCKHAIR
	flags_inv = HIDEFACE
	w_class = 2
	var/voicechange = 0
	var/temporaryname = " the Horse"
	var/originalname = ""

/obj/item/clothing/mask/horsehead/equipped(mob/user, slot)
	if(!canremove)	//cursed masks only
		originalname = user.real_name
		if(!user.real_name || user.real_name == "Unknown")
			user.real_name = "A Horse With No Name" //it felt good to be out of the rain
		else
			user.real_name = "[user.name][temporaryname]"
		..()

/obj/item/clothing/mask/horsehead/dropped() //this really shouldn't happen, but call it extreme caution
	if(!canremove)
		goodbye_horses(usr)
	..()

/obj/item/clothing/mask/horsehead/Del()
	if(!canremove)
		goodbye_horses(loc)
	..()

/obj/item/clothing/mask/horsehead/proc/goodbye_horses(mob/user) //I'm flying over you
	if(!ismob(user))
		return
	if(user.real_name == "[originalname][temporaryname]" || user.real_name == "A Horse With No Name") //if it's somehow changed while the mask is on it doesn't revert
		user.real_name = originalname
