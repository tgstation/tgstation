/*!
 * Contains crusher trophies that are not obtained from fauna
 */

//cosmetic items for changing the crusher's look

/obj/item/crusher_trophy/retool_kit
	name = "crusher sword retool kit"
	desc = "A toolkit for changing the crusher's appearance without affecting the device's function. This one will make it look like a sword."
	icon = 'icons/obj/mining.dmi'
	icon_state = "retool_kit"
	denied_type = /obj/item/crusher_trophy/retool_kit
	///Specifies the sprite/icon state which the crusher is changed to as an item. Should appear in the icons/obj/mining.dmi file with accompanying "lit" and "recharging" sprites
	var/retool_icon = "crusher_sword"
	///Specifies the icon state for the crusher's appearance in hand. Should appear in both icons/mob/inhands/weapons/hammers_lefthand.dmi and icons/mob/inhands/weapons/hammers_righthand.dmi
	var/retool_inhand_icon = "crusher_sword"
	///For if the retool kit changes the projectile's appearance. The sprite should be in icons/obj/weapons/guns/projectiles.dmi
	var/retool_projectile_icon = "pulse1"

/obj/item/crusher_trophy/retool_kit/effect_desc()
	return "the crusher to have the appearance of a sword"

/obj/item/crusher_trophy/retool_kit/add_to(obj/item/kinetic_crusher/pkc, mob/user)
	. = ..()
	if(.)
		pkc.icon_state = retool_icon
		pkc.current_inhand_icon_state = retool_inhand_icon
		pkc.projectile_icon = retool_projectile_icon
		if(iscarbon(pkc.loc))
			var/mob/living/carbon/holder = pkc.loc
			holder.update_worn_back()
			holder.update_suit_storage()
			holder.update_held_items()
		pkc.update_appearance()

/obj/item/crusher_trophy/retool_kit/remove_from(obj/item/kinetic_crusher/pkc)
	pkc.icon_state = initial(pkc.icon_state)
	pkc.current_inhand_icon_state = initial(pkc.current_inhand_icon_state)
	pkc.projectile_icon = initial(pkc.projectile_icon)
	if(iscarbon(pkc.loc))
		var/mob/living/carbon/holder = pkc.loc
		holder.update_worn_back()
		holder.update_suit_storage()
		holder.update_held_items()
	pkc.update_appearance()
	..()

/obj/item/crusher_trophy/retool_kit/harpoon
	name = "crusher harpoon retool kit"
	desc = "A toolkit for changing the crusher's appearance without affecting the device's function. This one will make it look like a harpoon."
	icon = 'icons/obj/mining.dmi'
	icon_state = "retool_kit"
	denied_type = /obj/item/crusher_trophy/retool_kit
	retool_icon = "crusher_harpoon"
	retool_inhand_icon = "crusher_harpoon"
	retool_projectile_icon = "pulse_harpoon"

/obj/item/crusher_trophy/retool_kit/harpoon/effect_desc()
	return "the crusher to have the appearance of a harpoon"

/obj/item/crusher_trophy/retool_kit/dagger
	name = "crusher dagger retool kit"
	desc = "A toolkit for changing the crusher's appearance without affecting the device's function. This one will make it look like a dual dagger and mini-blaster on a chain."
	icon = 'icons/obj/mining.dmi'
	icon_state = "retool_kit"
	denied_type = /obj/item/crusher_trophy/retool_kit
	retool_icon = "crusher_dagger"
	retool_inhand_icon = "crusher_dagger"

/obj/item/crusher_trophy/retool_kit/dagger/effect_desc()
	return "the crusher to have the appearance of a dual dagger and blaster"

/obj/item/crusher_trophy/retool_kit/ashenskull
	name = "ashen skull"
	desc = "It burns with the flame of the necropolis, whispering in your ear. It demands to be bound to a suitable weapon."
	icon = 'icons/obj/mining.dmi'
	icon_state = "retool_kit_skull"
	denied_type = /obj/item/crusher_trophy/retool_kit
	retool_icon = "crusher_skull"
	retool_inhand_icon = "crusher_skull"
	retool_projectile_icon = "pulse_skull"

/obj/item/crusher_trophy/retool_kit/ashenskull/effect_desc()
	return "the crusher to appear corrupted by infernal powers"
