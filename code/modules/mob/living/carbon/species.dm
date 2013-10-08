/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species
	var/name                     // Species name.

	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.
	var/eyes = "eyes_s"                                  // Icon for eyes.

	var/primitive                // Lesser form, if any (ie. monkey for humans)
	var/tail                     // Name of tail image in species effects icon file.
	var/language                 // Default racial language, if any.
	var/attack_verb = "punch"    // Empty hand hurt intent verb.
	var/mutantrace               // Safeguard due to old code.

	var/breath_type = "oxygen"   // Non-oxygen gas breathed, if any.
	var/survival_gear = /obj/item/weapon/storage/box/survival // For spawnin'.

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 1000 // Heat damage level 2 above this point.

	var/darksight = 2
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/brute_resist    // Physical damage reduction.
	var/burn_resist     // Burn damage reduction.

	var/flags = 0       // Various specific features.

/datum/species/proc/equip(var/mob/living/carbon/human/H)

/datum/species/human
	name = "Human"
	primitive = /mob/living/carbon/monkey

	flags = HAS_SKIN_TONE | HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT

/datum/species/unathi
	name = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	language = "Sinta'unathi"
	tail = "sogtail"
	attack_verb = "scratch"
	primitive = /mob/living/carbon/monkey/unathi
	darksight = 3

	flags = WHITELISTED | HAS_LIPS | HAS_UNDERWEAR | HAS_TAIL

/datum/species/skellington // /vg/
	name = "Skellington"
	icobase = 'icons/mob/human_races/r_skeleton.dmi'
	deform = 'icons/mob/human_races/r_skeleton.dmi'  // TODO: Need deform.
	language = "Clatter"
	attack_verb = "punch"

	flags = WHITELISTED | HAS_LIPS | HAS_TAIL | NO_EAT | NO_BREATHE | NON_GENDERED

/datum/species/tajaran
	name = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	language = "Siik'tajr"
	tail = "tajtail"
	attack_verb = "scratch"
	darksight = 8

	cold_level_1 = 200
	cold_level_2 = 140
	cold_level_3 = 80

	heat_level_1 = 330
	heat_level_2 = 380
	heat_level_3 = 800

	primitive = /mob/living/carbon/monkey/tajara

	flags = WHITELISTED | HAS_LIPS | HAS_UNDERWEAR | HAS_TAIL

/datum/species/skrell
	name = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	language = "Skrellian"
	primitive = /mob/living/carbon/monkey/skrell

	flags = WHITELISTED | HAS_LIPS | HAS_UNDERWEAR

/datum/species/vox
	name = "Vox"
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	language = "Vox-pidgin"

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"
	breath_type = "nitrogen"

	flags = WHITELISTED | NO_SCAN

	equip(var/mob/living/carbon/human/H)
		// Unequip existing suits and hats.
		H.u_equip(H.wear_suit)
		H.u_equip(H.head)
		H.u_equip(H.wear_mask) // CLOOOOWN

		H.equip_to_slot_or_drop(new /obj/item/clothing/mask/breath/vox(H), slot_wear_mask)
		var/suit=/obj/item/clothing/suit/space/vox/casual
		var/helm=/obj/item/clothing/head/helmet/space/vox/casual
		switch(H.mind.assigned_role)
			if("Research Director","Scientist","Geneticist","Roboticist")
				suit=/obj/item/clothing/suit/space/vox/casual/science
				helm=/obj/item/clothing/head/helmet/space/vox/casual/science
			if("Chief Engineer","Station Engineer","Atmospheric Technician")
				suit=/obj/item/clothing/suit/space/vox/casual/engineer
				helm=/obj/item/clothing/head/helmet/space/vox/casual/engineer
			if("Head of Security","Warden","Detective","Security Officer")
				suit=/obj/item/clothing/suit/space/vox/casual/security
				helm=/obj/item/clothing/head/helmet/space/vox/casual/security
			if("Chief Medical Officer","Medical Doctor","Paramedic","Chemist")
				suit=/obj/item/clothing/suit/space/vox/casual/medical
				helm=/obj/item/clothing/head/helmet/space/vox/casual/medical
		H.equip_to_slot_or_drop(new suit(H), slot_wear_suit)
		H.equip_to_slot_or_drop(new helm(H), slot_head)
		H.equip_to_slot_or_drop(new/obj/item/weapon/tank/nitrogen(H), slot_s_store)
		H << "\blue You are now running on nitrogen internals from the [H.s_store] in your suit storage. Your species finds oxygen toxic, so you must breathe nitrogen only."
		H.internal = H.s_store
		if (H.internals)
			H.internals.icon_state = "internal1"

/datum/species/diona
	name = "Diona"
	icobase = 'icons/mob/human_races/r_plant.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	language = "Rootspeak"
	attack_verb = "slash"
	primitive = /mob/living/carbon/monkey/diona

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	flags = WHITELISTED | NO_BREATHE | REQUIRE_LIGHT | NON_GENDERED | NO_SCAN | IS_PLANT | RAD_ABSORB
