/datum/outfit/sapper
	name = "Space Sapper"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/sapper

	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/sapper
	belt = /obj/item/storage/belt/utility/sapper
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/workboots/sapper
	back = /obj/item/fireaxe

	l_pocket = /obj/item/paper/fluff/sapper_intro
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double

	skillchips = list(/obj/item/skillchip/job/engineer)

/datum/outfit/sapper/pre_equip(mob/living/carbon/human/equipped)
	if(equipped.jumpsuit_style == PREF_SKIRT)
		uniform = /obj/item/clothing/under/sapper/skirt

/datum/outfit/sapper/post_equip(mob/living/carbon/human/equipped)
	equipped.faction |= ROLE_SPACE_SAPPER
	var/obj/item/radio/headset/outfit_radio = equipped.ears
	if(outfit_radio)
		outfit_radio.keyslot2 = new /obj/item/encryptionkey/syndicate()
		outfit_radio.special_channels |= RADIO_SPECIAL_SYNDIE
		outfit_radio.set_frequency(FREQ_SYNDICATE)
		outfit_radio.recalculateChannels()
	var/obj/item/card/id/outfit_id = equipped.wear_id
	if(outfit_id)
		outfit_id.registered_name = equipped.real_name
		outfit_id.update_label()
		outfit_id.update_icon()

/obj/item/clothing/mask/gas/atmos/sapper
	name = "\improper Sapper Heatsilk gas mask"
	desc = "A modified black gas mask with a yellow painted bottom and digitally expressive eyes, its framing is <b>laser-reflective</b>."
	icon_state = "gas_sapper_one"
	var/hit_reflect_chance = 45

/obj/item/clothing/mask/gas/atmos/sapper/partner
	icon_state = "gas_sapper_two"

/obj/item/clothing/mask/gas/atmos/sapper/IsReflect(def_zone)
	if(def_zone in list(BODY_ZONE_HEAD))
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE
	return FALSE

/obj/item/clothing/under/sapper
	name = "\improper Sapper Heatsilk slacks"
	desc = "A sleek black jacket with <b>laser-reflective</b> 'heatsilk' lining and a high-visibility pair of slacks, comfortable, safe, efficient."
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	icon_state = "sapper_heatsilk"
	body_parts_covered = CHEST|GROIN|ARMS // The pants or skirt grant no protection, that's what the boots are for
	inhand_icon_state = "engi_suit"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/rank_security
	can_adjust = FALSE
	var/hit_reflect_chance = 65

/obj/item/clothing/under/sapper/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)))
		return FALSE
	if(prob(hit_reflect_chance))
		return TRUE
	return

/obj/item/clothing/under/sapper/skirt
	name = "\improper Sapper Heatsilk skirt"
	desc = "A sleek black jacket with <b>laser-reflective</b> 'heatsilk' lining and a high-visibility skirt, comfortable, safe, efficient."
	icon_state = "sapper_heatsilk_skirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/shoes/workboots/sapper
	name = "black work boots"
	desc = "Lace-up steel-tipped shiny black workboots, nothing can get through these."
	icon_state = "workboots_rubber"
	body_parts_covered = FEET|LEGS
	inhand_icon_state = "jackboots"
	armor_type = /datum/armor/shoes_combat

/obj/item/clothing/shoes/workboots/sapper/Initialize(mapload)
	. = ..()
	new /obj/item/screwdriver(src)

/obj/item/storage/belt/utility/sapper
	name = "black toolbelt"
	desc = "A tactical toolbelt, what makes it tactical? The color."
	icon_state = "utility_tactical"
	inhand_icon_state = "security"
	worn_icon_state = "utility_tactical"
	preload = FALSE

/obj/item/storage/belt/utility/sapper/PopulateContents() //its just a complete mishmash
	new /obj/item/wirecutters/caravan(src)
	new /obj/item/multitool(src)
	new /obj/item/wrench/combat(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/screwdriver/caravan(src)
	new /obj/item/crowbar/large/old(src)
	new /obj/item/weldingtool/abductor(src)

/datum/id_trim/sapper
	assignment = "Sapper"
	trim_state = "trim_sapper"
	department_color = COLOR_ENGINEERING_ORANGE
	subdepartment_color = COLOR_ENGINEERING_ORANGE
	sechud_icon_state = SECHUD_SAPPER
	access = list(ACCESS_SAPPER_SHIP)
	threat_modifier = 2

/datum/job/space_sapper
	title = ROLE_SPACE_SAPPER
	policy_index = ROLE_SPACE_SAPPER

////
// Preview icon outfits
/datum/outfit/sapper_preview
	name = "Space Sapper 1 (Preview Only)"
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/sapper
	belt = /obj/item/storage/belt/utility/sapper
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/workboots/sapper
	mask = /obj/item/clothing/mask/gas/atmos/sapper

/datum/outfit/sapper_preview/partner
	name = "Space Sapper 2 (Preview Only)"
	uniform = /obj/item/clothing/under/sapper/skirt
	mask = /obj/item/clothing/mask/gas/atmos/sapper/partner

/datum/outfit/sapper_preview/pre_equip(mob/living/carbon/human/equipped)
	return

/datum/outfit/sapper_preview/post_equip(mob/living/carbon/human/equipped)
	return
