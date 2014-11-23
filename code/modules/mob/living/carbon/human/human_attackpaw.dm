/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/M as mob)
	if(..()) //successful monkey bite.
		var/damage = rand(1, 3)
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/obj/item/organ/limb/affecting = get_organ(ran_zone(dam_zone))
		if(stat != DEAD)
			apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee"))
			updatehealth()

		for(var/datum/disease/D in M.viruses)
			ContractDisease(D)
	return
