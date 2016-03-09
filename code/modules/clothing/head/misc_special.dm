/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	item_state = "welding"
	materials = list(MAT_METAL=1750, MAT_GLASS=400)
//	var/up = 0
	flash_protect = 2
	tint = 2
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	burn_state = FIRE_PROOF

/obj/item/clothing/head/welding/attack_self()
	toggle()


/obj/item/clothing/head/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding helmet"
	set src in usr

	weldingvisortoggle()


/*
 * Cakehat
 */
/obj/item/clothing/head/hardhat/cakehat
	name = "cakehat"
	desc = "You put the cake on your head. Brilliant."
	icon_state = "hardhat0_cakehat"
	item_state = "hardhat0_cakehat"
	item_color = "cakehat"
	flags_inv = HIDEEARS|HIDEHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES
	heat = 1000

/obj/item/clothing/head/hardhat/cakehat/process()
	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/hardhat/cakehat/turn_on()
	..()
	force = 15
	throwforce = 15
	damtype = BURN
	SSobj.processing |= src

/obj/item/clothing/head/hardhat/cakehat/turn_off()
	..()
	force = 0
	throwforce = 0
	damtype = BRUTE
	SSobj.processing -= src

/obj/item/clothing/head/hardhat/cakehat/is_hot()
	return on * heat
/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS|HIDEHAIR
	var/earflaps = 1
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/ushanka/attack_self(mob/user)
	if(earflaps)
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		earflaps = 0
		user << "<span class='notice'>You raise the ear flaps on the ushanka.</span>"
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		earflaps = 1
		user << "<span class='notice'>You lower the ear flaps on the ushanka.</span>"

/*
 * Pumpkin head
 */
/obj/item/clothing/head/hardhat/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"
	item_state = "hardhat0_pumpkin"
	item_color = "pumpkin"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 2 //luminosity when on
	flags_cover = HEADCOVERSEYES

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	color = "#999"

/obj/item/clothing/head/kitty/equipped(mob/user, slot)
	if(user && slot == slot_head)
		update_icon(user)
	..()

/obj/item/clothing/head/kitty/update_icon(mob/living/carbon/human/user)
	if(istype(user))
		color = "#[user.hair_color]"


/obj/item/clothing/head/hardhat/reindeer
	name = "novelty reindeer hat"
	desc = "Some fake antlers and a very fake red nose."
	icon_state = "hardhat0_reindeer"
	item_state = "hardhat0_reindeer"
	item_color = "reindeer"
	flags_inv = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 1 //luminosity when on
