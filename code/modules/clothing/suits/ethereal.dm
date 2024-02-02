/obj/item/clothing/suit/hooded/ethereal_raincoat
	name = "ethereal raincoat"
	desc = " A raincoat commonly worn by travelers or tourists not too fond of Sprout's rainy weather."
	icon = 'icons/obj/clothing/suits/ethereal.dmi'
	icon_state = "eth_raincoat"
	worn_icon = 'icons/mob/clothing/suits/ethereal.dmi'
	greyscale_config = /datum/greyscale_config/eth_raincoat
	greyscale_config_worn = /datum/greyscale_config/eth_raincoat/worn
	greyscale_colors = "#4e7cc7"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN|ARMS
	hoodtype = /obj/item/clothing/head/hooded/ethereal_rainhood

/obj/item/clothing/suit/hooded/ethereal_raincoat/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/suit/hooded/ethereal_raincoat/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance('icons/mob/clothing/suits/ethereal.dmi', "eth_raincoat_glow_worn", offset_spokesman = src, alpha = src.alpha)

/obj/item/clothing/suit/hooded/ethereal_raincoat/AltClick(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/char = user
		if((char.get_item_by_slot(ITEM_SLOT_NECK) == src) || (char.get_item_by_slot(ITEM_SLOT_OCLOTHING) == src))
			to_chat(user, span_warning("You can't adjust [src] while wearing it!"))
			return
		if(!user.is_holding(src))
			to_chat(user, span_warning("You must be holding [src] in order to adjust it!"))
			return
		if(slot_flags & ITEM_SLOT_OCLOTHING)
			slot_flags = ITEM_SLOT_NECK
			set_armor(/datum/armor/none) //Don't think they have armor, but I am not taking any chances
			user.visible_message(span_notice("[user] adjusts their [src] for ceremonial use."), span_notice("You adjust your [src] for ceremonial use."))
		else
			slot_flags = initial(slot_flags)
			set_armor(initial(armor_type))
			user.visible_message(span_notice("[user] adjusts their [src] for defensive use."), span_notice("You adjust your [src] for defensive use."))

/obj/item/clothing/suit/hooded/ethereal_raincoat/update_overlays()
	. = ..()
	. += emissive_appearance('icons/obj/clothing/suits/ethereal.dmi', "eth_raincoat_glow", offset_spokesman = src, alpha = src.alpha)

/obj/item/clothing/suit/hooded/ethereal_raincoat/trailwarden
	name = "trailwarden oilcoat"
	desc = "A masterfully handcrafted oilslick coat, supposedly makes for excellent camouflage among Sprout's vegetation. You can hear a faint electrical buzz emanating from the luminescent pattern."
	greyscale_colors = "#32a87d"

/obj/item/clothing/suit/hooded/ethereal_raincoat/trailwarden/equipped(mob/living/user, slot)
	. = ..()
	if(isethereal(user) && (slot & ITEM_SLOT_OCLOTHING))
		var/mob/living/carbon/human/ethereal = user
		to_chat(ethereal, span_notice("[src] gently quivers for a moment as you put it on."))
		set_greyscale(ethereal.dna.species.fixed_mut_color)
		ethereal.update_worn_oversuit()


/obj/item/clothing/head/hooded/ethereal_rainhood
	name = "ethereal rainhood"
	desc = "Protects against space rain."
	icon = 'icons/obj/clothing/head/ethereal.dmi'
	icon_state = "eth_rainhood"
	worn_icon = 'icons/mob/clothing/head/ethereal.dmi'
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACIALHAIR
