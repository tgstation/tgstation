/mob/living/carbon/human/attack_paw(mob/living/M as mob)
	..()
	if (M.a_intent == "help")
		help_shake_act(M)
	else
		M.do_attack_animation(src)
		if (M.is_muzzled())
			return

		visible_message("<span class='danger'>[M.name] bites [src]!</span>", \
			"<span class='userdanger'>[M.name] bites [src]!</span>")
		playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)

		var/damage = rand(1, 3)
		var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
		var/obj/item/organ/limb/affecting = get_organ(ran_zone(dam_zone))
		apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee"))

		for(var/datum/disease/D in M.viruses)
			contract_disease(D,1,0)
	return
