/*
//////////////////////////////////////

Scarab Infestation

	Visible.
	Lowers resistance.
	Decreases stage speed.
	Not very transmittable.
	Intense Level.

Bonus
	Creates a Scarab Injector after a while while harming the mob. Self-Cures.

//////////////////////////////////////
*/

/datum/symptom/scarab

	name = "Confusion"
	stealth = 1
	resistance = -1
	stage_speed = -3
	transmittable = 0
	level = 10
	severity = 2


/datum/symptom/scarab/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='notice'>[pick("You feel itchy.", "You scratch yourself.")]</span>"
			if(3,4)
				M << "<span class='alert'>[pick("You feel something crawling under your skin!", "You feel something biting your insides!")]</span>"
				M.adjustBruteLoss(-1)
			else
				M.visible_message("<span class='danger'>[M] skin bursts like a bubble releasing a scarab!</span>", \
					"<span class='userdanger'>Your skin bursts like a bubble releasing the scarab!</span>")
				M.confused = min(100, M.confused + 2)
				M.adjustBruteLoss(-60)
				var/obj/item/weapon/guardiancreator/biological/choose/spawn_scarab = new/obj/item/weapon/guardiancreator/biological/choose ( M.loc )
				A.cure()

	return
