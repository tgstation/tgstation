/datum/outfit/sapper
	name = "Space Sapper"

	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/sapper

	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/sapper
	belt = /obj/item/storage/belt/utility/sapper
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/workboots/sapper

	box = /obj/item/storage/box/survival/engineer
	back = /obj/item/storage/toolbox/guncase/modular/carwo_large_case/sapper
	backpack_contents = list(
		/obj/item/storage/backpack/satchel/flat/empty =1,
		/obj/item/grenade/chem_grenade/metalfoam = 1,
		/obj/item/stack/cable_coil/thirty = 1,
		/obj/item/fireaxe = 1,
		)

	l_pocket = /obj/item/paper/fluff/sapper_intro
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double

	skillchips = list(/obj/item/skillchip/job/engineer)

/datum/outfit/sapper/pre_equip(mob/living/carbon/human/equipped)
	if(equipped.jumpsuit_style == PREF_SKIRT)
		uniform = /obj/item/clothing/under/sapper/skirt

/datum/outfit/sapper/post_equip(mob/living/carbon/human/equipped)
	equipped.faction |= FACTION_SAPPER

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

	var/obj/item/clothing/under/outfit_uniform = equipped.w_uniform
	if(outfit_uniform)
		outfit_uniform.has_sensor = NO_SENSORS
		outfit_uniform.sensor_mode = SENSOR_OFF
		equipped.update_suit_sensors()

	SSquirks.AssignQuirks(equipped, equipped.client)


/obj/item/clothing/mask/gas/atmos/sapper
	name = "\improper Sapper gas mask"
	desc = "A modified black gas mask with a yellow painted bottom and digitally expressive eyes, its framing is <b>laser-reflective</b>."
	icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/sapper_obj.dmi'
	icon_state = "mask_one"
	worn_icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/sapper.dmi'
	var/hit_reflect_chance = 35

/obj/item/clothing/mask/gas/atmos/sapper/partner
	icon_state = "mask_two"

/obj/item/clothing/mask/gas/atmos/sapper/IsReflect(def_zone)
	if(def_zone in list(BODY_ZONE_HEAD))
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/under/sapper
	name = "\improper Sapper slacks"
	desc = "A sleek black jacket with <b>laser-reflective</b> 'heatsilk' lining and a high-visibility pair of slacks, comfortable, safe, efficient."
	icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/sapper_obj.dmi'
	icon_state = "suit_pants"
	body_parts_covered = CHEST|GROIN|ARMS // The pants or skirt grant no protection, that's what the boots are for
	worn_icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/sapper.dmi'
	inhand_icon_state = "engi_suit"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/rank_security
	can_adjust = FALSE
	var/hit_reflect_chance = 55

/obj/item/clothing/under/sapper/sapper/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)))
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/under/sapper/skirt
	name = "\improper Sapper skirt"
	desc = "A sleek black jacket with <b>laser-reflective</b> 'heatsilk' lining and a high-visibility skirt, comfortable, safe, efficient."
	icon_state = "suit_skirt"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
//	gets_cropped_on_taurs = FALSE

/obj/item/clothing/shoes/workboots/sapper
	name = "black work boots"
	desc = "Lace-up steel-tipped shiny black workboots, nothing can get through these."
	icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/sapper_obj.dmi'
	icon_state = "jackboots"
	body_parts_covered = FEET|LEGS
	worn_icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/sapper.dmi'
//	worn_icon_digi = DIGITIGRADE_SHOES_FILE
	inhand_icon_state = "jackboots"
	armor_type = /datum/armor/shoes_combat

/obj/item/clothing/shoes/workboots/sapper/Initialize(mapload)
	. = ..()
	contents += new /obj/item/screwdriver

/obj/item/storage/belt/utility/sapper
	name = "black toolbelt"
	desc = "A tactical toolbelt, what makes it tactical? The color."
	icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/sapper_obj.dmi'
	icon_state = "belt"
	worn_icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/sapper.dmi'
	inhand_icon_state = "security"
	worn_icon_state = "belt"
	preload = FALSE

/obj/item/storage/belt/utility/sapper/PopulateContents() //its just a complete mishmash
	new /obj/item/forcefield_projector(src)
	new /obj/item/multitool(src)
	new /obj/item/wrench/combat(src)
	new /obj/item/construction/rcd/loaded(src)
	new /obj/item/screwdriver/caravan(src)
	new /obj/item/inducer/syndicate(src)
	new /obj/item/weldingtool/abductor(src)

/obj/item/storage/toolbox/guncase/modular/carwo_large_case/sapper
	name = "compact tool case"
	desc = "A wide yellow tool case with foam inserts laid out to fit a fire axe, tools, cable coils and even grenades."

/obj/item/storage/toolbox/guncase/modular/carwo_large_case/sapper/PopulateContents()
	return

/datum/id_trim/sapper
	assignment = "Sapper"
	trim_state = "trim_sapper"
	trim_icon = 'modular_doppler/modular_antagonists/sapper_gang/icons/card.dmi'
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
/datum/outfit/sapper/preview
	name = "Space Sapper 1 (Preview Only)"
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/sapper
	belt = /obj/item/storage/belt/utility/sapper
	gloves = /obj/item/clothing/gloves/color/yellow
	shoes = /obj/item/clothing/shoes/workboots/sapper
	mask = /obj/item/clothing/mask/gas/atmos/sapper

/datum/outfit/sapper/preview/partner
	name = "Space Sapper 2 (Preview Only)"
	uniform = /obj/item/clothing/under/sapper/skirt
	mask = /obj/item/clothing/mask/gas/atmos/sapper/partner

/datum/outfit/sapper/preview/pre_equip(mob/living/carbon/human/equipped)
	return

/datum/outfit/sapper/preview/post_equip(mob/living/carbon/human/equipped)
	return
