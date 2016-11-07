/obj/mecha/medical/odysseus
	desc = "These exosuits are developed and produced by Vey-Med. (&copy; All rights reserved)."
	name = "\improper Odysseus"
	icon_state = "odysseus"
	step_in = 3
	max_temperature = 15000
	obj_integrity = 120
	max_integrity = 120
	wreckage = /obj/structure/mecha_wreckage/odysseus
	internal_damage_threshold = 35
	deflect_chance = 15
	step_energy_drain = 6
	var/builtin_hud_user = 0

/obj/mecha/medical/odysseus/moved_inside(mob/living/carbon/human/H)
	if(..())
		if(H.glasses && istype(H.glasses, /obj/item/clothing/glasses/hud))
			occupant_message("<span class='warning'>Your [H.glasses] prevent you from using the built-in medical hud.</span>")
		else
			var/datum/atom_hud/data/human/medical/advanced/A = huds[DATA_HUD_MEDICAL_ADVANCED]
			A.add_hud_to(H)
			builtin_hud_user = 1
		return 1
	else
		return 0

/obj/mecha/medical/odysseus/go_out()
	if(ishuman(occupant) && builtin_hud_user)
		var/mob/living/carbon/human/H = occupant
		var/datum/atom_hud/data/human/medical/advanced/A = huds[DATA_HUD_MEDICAL_ADVANCED]
		A.remove_hud_from(H)
	..()
	return

