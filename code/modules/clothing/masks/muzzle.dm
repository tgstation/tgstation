/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	inhand_icon_state = "blindfold"
	clothing_flags = BLOCKS_SPEECH
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	equip_delay_other = 25 // my sprite has 4 straps, a-la a head harness. takes a while to equip, longer than a muzzle

/obj/item/clothing/mask/muzzle/tape
	name = "tape piece"
	desc = "A piece of tape that can be put over someone's mouth."
	icon_state = "tape_piece"
	worn_icon_state = "tape_piece_worn"
	inhand_icon_state = NONE
	w_class = WEIGHT_CLASS_TINY
	equip_delay_other = 40
	strip_delay = 40
	greyscale_config = /datum/greyscale_config/tape_piece
	greyscale_config_worn = /datum/greyscale_config/tape_piece/worn
	greyscale_colors = "#B2B2B2"
	moth_snack = FALSE

/obj/item/clothing/mask/muzzle/tape/attack(mob/living/M, mob/living/user, params)
	..()

/obj/item/clothing/mask/muzzle/tape/super
	name = "super tape piece"
	desc = "A piece of tape that can be put over someone's mouth. This one has extra strengh."
	greyscale_colors = "#4D4D4D"
	strip_delay = 80

/obj/item/clothing/mask/muzzle/tape/surgical
	name = "surgical tape piece"
	desc = "A piece of tape that can be put over someone's mouth. As long as you apply this to your patient, you won't hear their screams of pain!"
	greyscale_colors = "#FFFFFF"
	equip_delay_other = 30
	strip_delay = 30

/obj/item/clothing/mask/muzzle/tape/pointy
	name = "pointy tape piece"
	desc = "A piece of tape that can be put over someone's mouth. Looks like it will hurt if this is ripped off carelessly."
	icon_state = "tape_piece_spikes"
	worn_icon_state = "tape_piece_spikes_worn"
	greyscale_config = /datum/greyscale_config/tape_piece/spikes
	greyscale_config_worn = /datum/greyscale_config/tape_piece/worn/spikes
	greyscale_colors = "#E64539#AD2F45"
	var/stripping_damage = 10

/obj/item/clothing/mask/muzzle/tape/pointy/doStrip(mob/stripper, mob/living/owner)
	. = ..()
	owner.apply_damage(stripping_damage, BRUTE, BODY_ZONE_HEAD)
	owner.emote("scream")
	to_chat(owner, span_danger("You feel a massive pain as hundreds of tiny spikes tear free from your face!"))

/obj/item/clothing/mask/muzzle/tape/pointy/super
	name = "super pointy tape piece"
	desc = "A piece of tape that can be put over someone's mouth. This thing could rip your face into a thousand pieces if ripped off carelessly."
	greyscale_colors = "#8C0A00#300008"
	strip_delay = 60
	stripping_damage = 20
