/*
//////////////////////////////////////

Sneezing

	Very Noticable.
	Increases resistance.
	Doesn't increase stage speed.
	Very transmissible.
	Low Level.

Bonus
	Forces a spread type of AIRBORNE
	with extra range!

//////////////////////////////////////
*/

/datum/symptom/sneeze
	name = "Sneezing"
	desc = "The virus causes irritation of the nasal cavity, making the host sneeze occasionally. Sneezes from this symptom will spread the virus in a 4 meter cone in front of the host."
	stealth = -2
	resistance = 3
	stage_speed = 0
	transmittable = 4
	level = 1
	severity = 1
	symptom_delay_min = 5
	symptom_delay_max = 35
	var/spread_range = 4
	threshold_desc = "<b>Transmission 9:</b> Increases sneezing range, spreading the virus over 6 meter cone instead of over a 4 meter cone.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/sneeze/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["transmittable"] >= 9) //longer spread range
		spread_range = 6
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE

/datum/symptom/sneeze/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3)
			if(!suppress_warning)
				M.emote("sniff")
		else
			M.emote("sneeze")
			if(M.CanSpreadAirborneDisease()) //don't spread germs if they covered their mouth
				for(var/mob/living/L in oview(spread_range, M))
					if(is_A_facing_B(M, L) && disease_air_spread_walk(get_turf(M), get_turf(L)))
						L.AirborneContractDisease(A, TRUE)
