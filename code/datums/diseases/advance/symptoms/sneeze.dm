/*
//////////////////////////////////////

Sneezing

	Very Noticable.
	Increases resistance.
	Doesn't increase stage speed.
	Very transmittable.
	Low Level.
	Forces you to drop held items.

Bonus
	Forces a spread type of AIRBORNE
	with extra range!

//////////////////////////////////////
*/

/datum/symptom/sneeze

	name = "Sneezing"
	stealth = -2
	resistance = 3
	stage_speed = 0
	transmittable = 4
	level = 1
	severity = 1

/datum/symptom/sneeze/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3)
				M.emote("sniff")
			else
				M.emote("sneeze")
				Spreadzone(M, A)
				var/obj/item/I = M.get_active_hand()
				if(I && I.w_class > 0)
					M.drop_item()
	return

/datum/symptom/sneeze/proc/Spreadzone(mob/living/M, datum/disease/advance/A)
	var/sneeze_zone = ((sqrt(21+A.totalResistance()))+(sqrt(21+A.totalTransmittable()))/2)
	A.spread(A.holder, sneeze_zone)
	return 1
