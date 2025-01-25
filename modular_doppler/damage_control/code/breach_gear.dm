// Yellow tank but empty, for the printer

/obj/item/tank/internals/oxygen/yellow/empty

/obj/item/tank/internals/oxygen/yellow/empty/populate_gas()
	return

// Breach helmet, its a hardhat but cooler

/obj/item/clothing/head/utility/hardhat/welding/doppler_dc
	name = "breach helmet"
	desc = "A heavy-duty hardhat with a pressure seal and fireproofing for when things go very wrong. \
		The headlamp is red to preserve eyesight in dark, damaged environments."
	icon = 'modular_doppler/damage_control/icons/gear.dmi'
	icon_state = "hardhat0_dc"
	hat_type = "dc"
	worn_icon = 'modular_doppler/damage_control/icons/mob/gear.dmi'
	mask_overlay_icon = 'modular_doppler/damage_control/icons/mob/gear.dmi'
	dog_fashion = null

	resistance_flags = FIRE_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE | STACKABLE_HELMET_EXEMPT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	light_range = 4
	light_color = "#ee243d"

/obj/item/clothing/head/utility/hardhat/welding/doppler_dc/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "hardhat_dc_emissive", src, alpha = src.alpha)

// Reflective fire jacket, like the shiny type super serious firefighters have to use

/obj/item/clothing/suit/utility/fire/doppler
	name = "reflective firecoat"
	desc = "A bulky firesuit clad in reflective material to deflect heat away from the wearer."
	icon = 'modular_doppler/damage_control/icons/gear.dmi'
	icon_state = "firecoat"
	worn_icon = 'modular_doppler/damage_control/icons/mob/gear.dmi'
	inhand_icon_state = "taperobe"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 0.75
	flags_inv = NONE

// Skinsuit, tight fitting jumpsuit that keeps you from exploding thanks to pressure damage

/obj/item/clothing/under/rank/engineering/breach_skinsuit
	name = "breach skinsuit"
	desc = "A special jumpsuit that, when properly worn and adjusted, fits extremely tightly around the wearer's body. \
		This is uncomfortable and slow to move in, but protects the wearer from exposure to vacuum."
	icon = 'modular_doppler/damage_control/icons/gear.dmi'
	icon_state = "skinsuit"
	worn_icon = 'modular_doppler/damage_control/icons/mob/gear.dmi'
	equip_sound = 'sound/items/equip/glove_equip.ogg'
	can_adjust = FALSE
	resistance_flags = FIRE_PROOF
	clothing_flags = STOPSPRESSUREDAMAGE
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	slowdown = 0.5

/obj/item/clothing/under/rank/engineering/breach_skinsuit/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

// Gas masks but they aren't flammable (its an atmos gas mask without the extra filters)

/obj/item/clothing/mask/gas/breach
	name = "gas mask"
	desc = "A fireproofed gas mask with a special layer on the faceplate that prevents being blinded by fire reflash. \
		Will not protect you from more intense lighting than that, however."
	icon = 'modular_doppler/damage_control/icons/gear.dmi'
	icon_state = "mask"
	worn_icon = 'modular_doppler/damage_control/icons/mob/gear.dmi'
	worn_icon_state = "mask"
	supported_bodyshapes = list(BODYSHAPE_HUMANOID)
	bodyshape_icon_files = list(
		BODYSHAPE_HUMANOID_T = 'modular_doppler/damage_control/icons/mob/gear.dmi',
	)
	armor_type = /datum/armor/gas_atmos
	resistance_flags = FIRE_PROOF

// Bag for storing the breach ensemble without cluttering fire lockers too bad

/obj/item/storage/bag/breach_bag
	name = "damage control ensemble bag"
	desc = "A fire and chemical proofed bag for storing breach gear when not in use. \
		A small label states that the bags should be inspected for contents every six months, \
		though the last inspection signature looks much older than that."
	icon = 'modular_doppler/damage_control/icons/gear.dmi'
	icon_state = "breach_bag"
	slot_flags = NONE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/storage/bag/breach_bag/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.numerical_stacking = FALSE
	atom_storage.max_total_storage = 200
	atom_storage.max_slots = 6
	atom_storage.insert_preposition = "in"
	atom_storage.set_holdable(list(
		/obj/item/clothing/head/utility,
		/obj/item/clothing/suit/utility,
		/obj/item/clothing/under/rank/engineering,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/shoes,
		/obj/item/clothing/gloves,
	))

/obj/item/storage/bag/breach_bag/PopulateContents()
	new /obj/item/clothing/head/utility/hardhat/welding/doppler_dc(src)
	new /obj/item/clothing/suit/utility/fire/doppler(src)
	new /obj/item/clothing/under/rank/engineering/breach_skinsuit(src)
	new /obj/item/clothing/mask/gas/breach(src)
	new /obj/item/clothing/shoes/jackboots/frontier_colonist(src)
	new /obj/item/clothing/gloves/frontier_colonist(src)

// Metal H2 axe if you ever actually saw one once in 200 rounds

/obj/item/fireaxe/metal_h2_axe/emergency_extraction
	name = "emergency extraction axe"

// Edits to fire lockers to include the new breach kit

/obj/structure/closet/firecloset/PopulateContents()
	new /obj/item/storage/bag/breach_bag(src)
	new /obj/item/storage/bag/breach_bag(src)
	new /obj/item/tank/internals/oxygen/yellow(src)
	new /obj/item/tank/internals/oxygen/yellow(src)
	new /obj/item/extinguisher(src)
	new /obj/item/crowbar/large/emergency(src)
	new /obj/item/emergency_bed(src)

	if(prob(30))
		new /obj/item/flatpacked_machine/damage_lathe(src)
		new /obj/item/flatpacked_machine/rtg(src)

/obj/structure/closet/firecloset/full/PopulateContents()
	new /obj/item/storage/bag/breach_bag(src)
	new /obj/item/storage/bag/breach_bag(src)
	new /obj/item/tank/internals/oxygen/yellow(src)
	new /obj/item/tank/internals/oxygen/yellow(src)
	new /obj/item/extinguisher(src)
	new /obj/item/crowbar/large/emergency(src)
	new /obj/item/emergency_bed(src)
	new /obj/item/door_seal(src)
	new /obj/item/door_seal(src)
	new /obj/item/door_seal(src)
	new /obj/item/stack/sheet/iron/ten(src)

	if(prob(50))
		new /obj/item/flatpacked_machine/damage_lathe(src)

// Emergency closets get a little lovin too

/obj/structure/closet/emcloset/PopulateContents()
	var/list/possible_spawn_pools = list(
		"air_only" = 3,
		"stretcher" = 2,
		"mixture" = 3,
		"get_out_while_you_still_can" = 2,
	)

	new /obj/item/storage/toolbox/emergency(src)

	switch (pick_weight(possible_spawn_pools))
		if ("air_only")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/gas/breach(src)
			new /obj/item/clothing/mask/gas/breach(src)
			new /obj/item/clothing/mask/gas/breach(src)
		if ("stretcher")
			new /obj/item/clothing/head/utility/hardhat/welding/doppler_dc(src)
			new /obj/item/clothing/head/utility/hardhat/welding/doppler_dc(src)
			new /obj/item/storage/backpack/duffelbag/deforest_medkit/stocked(src)
			new /obj/item/emergency_bed(src)
		if ("mixture")
			new /obj/item/clothing/head/utility/hardhat/welding/doppler_dc(src)
			new /obj/item/clothing/head/utility/hardhat/welding/doppler_dc(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/gas/breach(src)
			new /obj/item/clothing/mask/gas/breach(src)
			new /obj/item/storage/medkit/emergency(src)
			new /obj/item/emergency_bed(src)
		if ("get_out_while_you_still_can")
			new /obj/item/clothing/head/utility/hardhat/welding/doppler_dc(src)
			new /obj/item/clothing/head/utility/hardhat/welding/doppler_dc(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/gas/breach(src)
			new /obj/item/clothing/mask/gas/breach(src)
			new /obj/item/emergency_bed(src)
			new /obj/item/fireaxe/metal_h2_axe/emergency_extraction(src)
