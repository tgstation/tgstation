/mob/living/carbon/alien/humanoid/special/chryssalid
	name = "Chryssalid"
	desc = "The crab-like claws of this creature are a powerful weapon in close combat. The high metabolism and strength of this creature give it speed and dexterity. Instead of killing its victim it impregnates it with an egg and injects a neurotoxin which turns it into a mindless drone. A new Chryssalid will burst from the victim shortly after impregnation. Chryssalids are associated with the Snakeman race. "
	xcom_state = "chryssalid"
	has_fine_manipulation = 0

	New()
		..()
		var/obj/item/weapon/tank/jetpack/jetpack = new(src)
		jetpack.on = !(jetpack.on)
		back = jetpack
		return

//	bullet_act(flags)
//		take_overall_damage(15,0)
//		return

	movement_delay()
		return -5

	handle_regular_status_updates()

		health = 200 - (oxyloss + fireloss + getBruteLoss())

		weakened = 0
		stunned = 0
		paralysis = 0

		if(health < -100 || src.brain_op_stage == 4.0)
			death()
		else if(src.health < 0)

			if(!src.reagents.has_reagent("plasma")) src.oxyloss++

			if(src.stat != 2)	src.stat = 1
			src.paralysis = max(src.paralysis, 5)

		if(stat == 2)
			lying = 1

		src.density = !(src.lying )

		return 1

	updatehealth()
		src.health = 200 - src.oxyloss - src.fireloss - src.getBruteLoss()

	xcom_attack(mob/living/carbon/human/target as mob)
		if(!ishuman(target))
			return
		if(target.stat != 2 || !target.client)
			target.take_overall_damage(20,0)
			target.visible_message(pick(
			"\red <b>[src] tears at [target]!</b>",
			"\red <b>[src] stabs [target] with it's claws!</b>",
			"\red <b>[src] slashes [target] with it's claws!</b>"))
		else
			if(target.client)
				target.client.mob = new/mob/living/carbon/alien/humanoid/special/chryssalid(src.loc)
				target.gib()
		..()