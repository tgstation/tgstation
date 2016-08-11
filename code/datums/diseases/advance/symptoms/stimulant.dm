/*
//////////////////////////////////////

Stimulant //gotta go fast

	Noticable.
	Lowers resistance significantly.
	Decreases stage speed moderately..
	Decreases transmittablity tremendously.
	Moderate Level.

Bonus
	The body generates Ephedrine.

//////////////////////////////////////
*/

/datum/symptom/stimulant

	name = "Stimulant"
	stealth = -1
	resistance = -3
	stage_speed = -2
	transmittable = -4
	level = 3

/datum/symptom/stimulant/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 10))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				if (M.reagents.get_reagent_amount("ephedrine") < 10)
					M.reagents.add_reagent("ephedrine", 10)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You feel restless.", "You feel like running laps around the station.")]</span>"
	return

/*
//////////////////////////////////////

Hormonal Hyperglands

	Noticeable.
	Lowers resistance.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Moderate Level.

Bonus
	The body starts generating high-power hormones, causing emotional imbalance.
	Emotions can be useful or harmful.

//////////////////////////////////////
*/

/datum/symptom/emotion

	name = "Hormonal Hyperglands"
	stealth = -1
	resistance = -1
	stage_speed = -4
	transmittable = -4
	level = 8

/datum/symptom/emotion/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB/2))
		var/mob/living/M = A.affected_mob
		var/mood = null
		switch(A.stage)
			if(5)
				mood = rand(1,5)
				if (M.health < 30)
					mood++ //Being wounded increases the odds of determination, and prevents depression
				switch (mood)
					if(1) //Depression: You just feel tired and slow down, because why bother.
						M << "<span class='warning'>You feel depressed.</span>"
						M.emote("sigh")
						M.reagents.add_reagent("tirizene", 10)
					if(2) //Happiness/calmness: You feel as if you're painless and healthy.
						M << "<span class='notice'>Your feel all your stress and pain washing away...</span>"
						if (M.reagents.get_reagent_amount("krokodil") < 4)
							M.reagents.add_reagent("krokodil", 5)
						if (M.reagents.get_reagent_amount("morphine") < 4)
							M.reagents.add_reagent("morphine", 5)
						if (M.reagents.get_reagent_amount("mine_salve") < 10)
							M.reagents.add_reagent("mine_salve", 10)
						M.drowsiness += 10
					if(3) //Focus: Removes anything that affects your mind, like drugs and alcohol.
						M << "<span class='notice'>You clear your thoughts, and all distractions fade into the background.</span>"
						M.reagents.add_reagent("mannitol", 10)
						M.reagents.add_reagent("antihol", 10)
						M.reagents.remove_all_type(/datum/reagent/drug, 10, 0, 1)
						M.set_drugginess(0)
						M.stuttering = 0
						M.hallucination = 0
					if(4) //Anger: You snap out of stuns and become harder to keep down, but you move oddly and get angry with unexistent things.
						M << "<span class='userdanger'>Your fly into a rage!</span>"
						if (M.reagents.get_reagent_amount("bath_salts") < 4)
							M.reagents.add_reagent("bath_salts", 5)
						M.setStunned(0, 0)
						M.setParalysis(0, 0)
						M.setWeakened(0, 0)
						M.setSleeping(0, 0)
						M.hallucination += 30
						M.emote("scream")
						if (prob(35)
							M.say( pick( list("DIE!!", "ALLAHU AKBAR!!", "BY THE POWER OF GREYSKULL!!", "HULK SMASH!!", "HONK!!") ) )

					if(5,6) //Determination: Lets you tough out your wounds. You ain't dying today.
						M << "<span class='notice'>You are filled with determination.</span>"
						if (M.reagents.get_reagent_amount("epinephrine") < 10)
							M.reagents.add_reagent("epinephrine", 10)
						if (M.reagents.get_reagent_amount("atropine") < 10)
							M.reagents.add_reagent("atropine", 10)
						if (M.reagents.get_reagent_amount("tricordrazine") < 10)
							M.reagents.add_reagent("tricordrazine", 10)

			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("You feel angry.", "You feel calm.", "You feel focused", "You feel happy.", "You feel depressed.", "You feel strong.")]</span>"
	return