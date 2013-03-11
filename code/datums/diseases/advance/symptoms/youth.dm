/*
//////////////////////////////////////
Eternal Youth

	Moderate stealth boost.
	Increases resistance tremendously.
	Increases stage speed tremendously.
	Reduces transmission tremendously.
	Critical Level.

BONUS
	Gives you immortality and eternal youth!!!
	Can be used to buff your virus

//////////////////////////////////////
*/

/datum/symptom/youth

	name = "Eternal Youth"
	stealth = 3
	resistance = 4
	stage_speed = 4
	transmittable = -4
	level = 5

/datum/symptom/youth/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 2))
		var/mob/living/M = A.affected_mob
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			switch(A.stage)
				if(1)
					if(H.age > 41)
						H.age = 41
						H << "<span class='notice'>You haven't had this much energy in years!</span>"
				if(2)
					if(H.age > 36)
						H.age = 36
						H << "<span class='notice'>You're suddenly in a good mood.</span>"
				if(3)
					if(H.age > 31)
						H.age = 31
						H << "<span class='notice'>You begin to feel more lithe.</span>"
				if(4)
					if(H.age > 26)
						H.age = 26
						H << "<span class='notice'>You feel reinvigorated.</span>"
				if(5)
					if(H.age > 21)
						H.age = 21
						H << "<span class='notice'>You feel like you can take on the world!</span>"

	return