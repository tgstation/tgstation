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
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	item_state = "welding"
	m_amt = 1750
	g_amt = 400
//	var/up = 0
	flash_protect = 2
	tint = 2
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	action_button_name = "Toggle Welding Helmet"
	visor_flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	burn_state = -1 //Won't burn in fires

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
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	flags = HEADCOVERSEYES
	var/onfire = 0.0
	var/status = 0
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage
	var/processing = 0 //I dont think this is used anywhere.

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		SSobj.processing.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"
		SSobj.processing |= src
	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
	return


/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS
	var/earflaps = 1
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
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
	flags = HEADCOVERSEYES | BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	action_button_name = "Toggle Pumpkin Light"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 2 //luminosity when on

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
	action_button_name = "Toggle Nose Light"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	brightness_on = 1 //luminosity when on