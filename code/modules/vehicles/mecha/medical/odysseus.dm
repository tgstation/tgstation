/obj/vehicle/sealed/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "\improper Odysseus"
	icon_state = "odysseus"
	base_icon_state = "odysseus"
	allow_diagonal_movement = TRUE
	movedelay = 2
	max_temperature = 15000
	max_integrity = 120
	wreckage = /obj/structure/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_MEDICAL)

/obj/vehicle/sealed/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && !HAS_TRAIT(H, TRAIT_MEDICAL_HUD))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		hud.add_hud_to(H)
		ADD_TRAIT(H, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT)

/obj/vehicle/sealed/mecha/medical/odysseus/remove_occupant(mob/living/carbon/human/H)
	if(isliving(H) && HAS_TRAIT_FROM(H, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		hud.remove_hud_from(H)
		REMOVE_TRAIT(H, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT)
	return ..()

/obj/vehicle/sealed/mecha/medical/odysseus/mmi_moved_inside(obj/item/mmi/M, mob/user)
	. = ..()
	if(. && !HAS_TRAIT(M, TRAIT_MEDICAL_HUD))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		var/mob/living/brain/B = M.brainmob
		hud.add_hud_to(B)
