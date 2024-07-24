/obj/vehicle/sealed/mecha/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "\improper Odysseus"
	icon_state = "odysseus"
	base_icon_state = "odysseus"
	movedelay = 2
	max_temperature = 15000
	max_integrity = 120
	wreckage = /obj/structure/mecha_wreckage/odysseus
	mech_type = EXOSUIT_MODULE_ODYSSEUS
	step_energy_drain = 6
	accesses = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_MEDICAL)
	pivot_step = TRUE

/obj/vehicle/sealed/mecha/odysseus/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && !HAS_TRAIT(H, TRAIT_MEDICAL_HUD))
		ADD_TRAIT(H, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT)

/obj/vehicle/sealed/mecha/odysseus/remove_occupant(mob/living/carbon/human/H)
	if(isliving(H) && HAS_TRAIT_FROM(H, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT))
		REMOVE_TRAIT(H, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT)
	return ..()

/obj/vehicle/sealed/mecha/odysseus/mmi_moved_inside(obj/item/mmi/M, mob/user)
	. = ..()
	if(. && !HAS_TRAIT(M, TRAIT_MEDICAL_HUD))
		ADD_TRAIT(M, TRAIT_MEDICAL_HUD, VEHICLE_TRAIT)
