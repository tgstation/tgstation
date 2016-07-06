/mob/living/carbon/human/attack_paw(mob/M as mob)
	..()
	//M.delayNextAttack(10)
	if (M.a_intent == I_HELP)
		help_shake_act(M)
	else
		if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
			return

		if(istype(M, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/Mo = M
			src.visible_message("<span class='danger'>[Mo.name] [Mo.attack_text] [name]!</span>")
		else
			src.visible_message("<span class='danger'>[M.name] bites [name]!</span>")

		var/damage = rand(1, 3)
		var/dam_zone = pick(LIMB_CHEST, LIMB_LEFT_HAND, LIMB_RIGHT_HAND, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
		var/datum/organ/external/affecting = get_organ(ran_zone(dam_zone))
		apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee"))

		for(var/datum/disease/D in M.viruses)
			if(istype(D, /datum/disease/jungle_fever))
				var/mob/living/carbon/human/H = src
				src = null
				src = H.monkeyize()
				contract_disease(D,1,0)
	return
