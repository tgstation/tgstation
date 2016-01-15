/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/M)
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/obj/item/organ/limb/affecting = get_organ(ran_zone(dam_zone))

	if(M.a_intent == "help")
		..() //shaking
		return 0

	if(can_inject(M, 1, affecting))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/damage = rand(1, 3)
			if(stat != DEAD)
				apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee"))
				updatehealth()
		return 1