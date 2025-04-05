/obj/item/clothing/suit
	name = "suit"
	icon = 'icons/obj/clothing/suits/default.dmi'
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	var/fire_resist = T0C+100
	allowed = list(
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/tank/jetpack/oxygen/captain,
		/obj/item/storage/belt/holster,
		)
	armor_type = /datum/armor/none
	drop_sound = 'sound/items/handling/cloth/cloth_drop1.ogg'
	pickup_sound = 'sound/items/handling/cloth/cloth_pickup1.ogg'
	slot_flags = ITEM_SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	limb_integrity = 0 // disabled for most exo-suits

/obj/item/clothing/suit/worn_overlays(mutable_appearance/standing, isinhands = FALSE)
	. = ..()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damaged[blood_overlay_type]")

	var/mob/living/carbon/human/wearer = loc
	if(!ishuman(wearer) || !wearer.w_uniform)
		return
	var/obj/item/clothing/under/undershirt = wearer.w_uniform
	if(!istype(undershirt) || !LAZYLEN(undershirt.attached_accessories))
		return

	var/obj/item/clothing/accessory/displayed = undershirt.attached_accessories[1]
	if(displayed.above_suit)
		. += undershirt.accessory_overlay

/obj/item/clothing/suit/separate_worn_overlays(mutable_appearance/standing, mutable_appearance/draw_target, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		return
	if(GET_ATOM_BLOOD_DNA_LENGTH(src))
		. += mutable_appearance('icons/effects/blood.dmi', "[blood_overlay_type]blood")

/obj/item/clothing/suit/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_worn_oversuit()

/obj/item/clothing/suit/generate_digitigrade_icons(icon/base_icon, greyscale_colors)
	var/icon/legs = icon(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/digitigrade, greyscale_colors), "oversuit_worn")
	return replace_icon_legs(base_icon, legs)

/obj/item/clothing/suit/generate_pony_icons(icon/base_icon, greyscale_colors)
	var/color_string_to_use = greyscale_colors
	if(!isnull(greyscale_colors) && length(greyscale_colors))
		var/datum/greyscale_config/config = SSgreyscale.configurations["[pony_config_path]"]
		var/list/finalized_colors = SSgreyscale.ParseColorString(greyscale_colors)
		var/colors_len = length(finalized_colors)
		if(colors_len > config.expected_colors) // more colors than our config supports
			var/list/filled_colors = finalized_colors.Copy()
			finalized_colors = list()
			for(var/index in 1 to config.expected_colors)
				finalized_colors += filled_colors[index]
			color_string_to_use = jointext(finalized_colors, "")
	var/icon/ponysuit = icon(SSgreyscale.GetColoredIconByType(pony_config_path, color_string_to_use), pony_icon_state)
	ponysuit.Insert(ponysuit, worn_icon_state ? worn_icon_state : icon_state)
	return ponysuit
