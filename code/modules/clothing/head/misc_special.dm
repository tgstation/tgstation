/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *		Tinfoil Hat
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	flags = FPRINT
	item_state = "welding"
	starting_materials = list(MAT_IRON = 3000, MAT_GLASS = 1000)
	w_type = RECYK_MISC
	var/up = 0
	eyeprot = 3
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	body_parts_covered = HEAD|EYES|MOUTH|EARS //using this instead of FULL_HEAD to show how the flags change in the code
	action_button_name = "Toggle Welding Helmet"
	siemens_coefficient = 0.9
	species_fit = list("Vox")

/obj/item/clothing/head/welding/attack_self()
	toggle()


/obj/item/clothing/head/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr
	if(!usr) return //PANIC
	if(usr.canmove && !usr.stat && !usr.restrained())
		if(src.up)
			src.up = !src.up
			src.body_parts_covered |= (EYES|MOUTH|EARS)
			flags_inv |= (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			eyeprot = 3
			icon_state = initial(icon_state)
			to_chat(usr, "You flip the [src] down to protect your eyes.")
		else
			src.up = !src.up
			src.body_parts_covered &= ~(EYES|MOUTH|EARS)
			flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = "[initial(icon_state)]up"
			eyeprot = 0
			to_chat(usr, "You push the [src] up out of your face.")
		usr.update_inv_head()	//so our mob-overlays update
		usr.update_inv_wear_mask()
		usr.update_inv_glasses()
		usr.update_inv_ears()


/*
 * Cakehat
 */
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	flags = FPRINT
	body_parts_covered = HEAD|EYES
	light_power = 0.5
	var/onfire = 0.0
	var/status = 0
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage
	var/processing = 0 //I dont think this is used anywhere.

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_objects.Remove(src)
		return

	var/turf/location = src.loc
	if(istype(location, /mob/))
		var/mob/living/carbon/human/M = location
		if(istype(M))
			if(M.l_hand == src || M.r_hand == src || M.head == src)
				location = M.loc
		else
			return

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"
		processing_objects.Add(src)
		set_light(2)
	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
		set_light(0)
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

/obj/item/clothing/head/ushanka/attack_self(mob/user as mob)
	if(src.icon_state == "ushankadown")
		src.icon_state = "ushankaup"
		src.item_state = "ushankaup"
		to_chat(user, "You raise the ear flaps on the ushanka.")
	else
		src.icon_state = "ushankadown"
		src.item_state = "ushankadown"
		to_chat(user, "You lower the ear flaps on the ushanka.")

/*
 * Pumpkin head
 */
/obj/item/clothing/head/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	item_state = "hardhat0_pumpkin"
	_color = "pumpkin"
	flags = FPRINT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	body_parts_covered = FULL_HEAD
	var/brightness_on = 2 //luminosity when on
	var/on = 0

	attack_self(mob/user)
		if(!isturf(user.loc))
			to_chat(user, "You cannot turn the light on while in this [user.loc]")//To prevent some lighting anomalities.

			return
		on = !on
		icon_state = "hardhat[on]_[_color]"
		item_state = "hardhat[on]_[_color]"

		if(on)	set_light(brightness_on)
		else	set_light(0)

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	flags = FPRINT
	var/icon/mob
	var/icon/mob2
	siemens_coefficient = 1.5

	update_icon(var/mob/living/carbon/human/user)
		if(!istype(user)) return
		mob = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty")
		mob2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty2")
		mob.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)
		mob2.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)

		var/icon/earbit = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner")
		var/icon/earbit2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner2")
		mob.Blend(earbit, ICON_OVERLAY)
		mob2.Blend(earbit2, ICON_OVERLAY)

/obj/item/clothing/head/butt
	name = "butt"
	desc = "So many butts, so little time."
	icon_state = "butt"
	item_state = "butt"
	flags = 0
	force = 4.0
	w_class = 1.0
	throwforce = 2
	throw_speed = 3
	throw_range = 5

	wizard_garb = 1

	var/s_tone = 0.0
	var/created_name = "Buttbot"

/obj/item/clothing/head/butt/proc/transfer_buttdentity(var/mob/living/carbon/H)
	name = "[H.real_name]'s butt"
	return

/obj/item/clothing/head/tinfoil
	name = "tinfoil hat"
	desc = "There's no evidence that the security staff is NOT out to get you."
	icon_state = "foilhat"
	item_state = "paper"
	siemens_coefficient = 2
	flags_inv = HIDEHAIR
