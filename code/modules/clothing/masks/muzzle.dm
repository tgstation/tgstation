/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	inhand_icon_state = "blindfold"
	clothing_flags = BLOCKS_SPEECH
	flags_cover = MASKCOVERSMOUTH
	atom_size = WEIGHT_CLASS_SMALL
	equip_delay_other = 20

/obj/item/clothing/mask/muzzle/attack_paw(mob/user, list/modifiers)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(src == carbon_user.wear_mask)
			to_chat(user, span_warning("You need help taking this off!"))
			return
	..()

/obj/item/clothing/mask/muzzle/breath
	name = "surgery mask"
	desc = "To silence those pesky patients before putting them under."
	icon_state = "breathmuzzle"
	inhand_icon_state = "breathmuzzle"
	body_parts_covered = NONE
	clothing_flags = MASKINTERNALS | BLOCKS_SPEECH
	permeability_coefficient = 0.01
	equip_delay_other = 25 // my sprite has 4 straps, a-la a head harness. takes a while to equip, longer than a muzzle
