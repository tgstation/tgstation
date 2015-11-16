/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/M as mob)
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	dam_zone = ran_zone(dam_zone)

	if(M.a_intent == "help")
		..() //shaking
		return 0

	if(can_inject(M, 1, dam_zone))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/damage = rand(1, 3)
			if(stat != DEAD)
				apply_damage(damage, BRUTE, dam_zone, run_armor_check(dam_zone, "melee"))
				updatehealth()
		return 1