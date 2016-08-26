/*
//////////////////////////////////////

Overloaded Nerves

	Noticeable.
	Resistant.
	Decreases stage speed.
	No transmittability.
	Fatal Level.

Bonus
	The mob will receive an electric shock once in a while. Insulation does not help.

//////////////////////////////////////
*/

/datum/symptom/shock

	name = "Overloaded Nerves"
	stealth = -2
	resistance = 1
	stage_speed = -1
	transmittable = 0
	level = 7
	severity = 5

/datum/symptom/shock/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1,2)
				M << "<span class='warning'>[pick("Your hairs stand on end.", "You feel a small static discharge.")]</span>"
			if(3,4)
				if(prob(25))
					M << "<span class='warning'>Your arm twitches.</span>"
					var/obj/item/I = M.get_active_hand()
					if(I && I.w_class == 1)
						M.drop_item()
				else
					M << "<span class='warning'>You feel a small shock run down your spine.</span>"
			if(5)
				M << "<span class='warning'>You feel a surge of static electricity.</span>"
				M.reagents.add_reagent("teslium", 4)



	return


/*
//////////////////////////////////////

Viral Electric Net

	Very noticeable.
	Lowers resistance.
	Decreases stage speed.
	Reduces transmittability.
	Fatal Level.

Bonus
	The mob will become immune to shocks and sometimes arc tesla bolts end emit EMP pulses.

//////////////////////////////////////
*/

/datum/symptom/tesla

	name = "Viral Electric Net"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 9
	severity = 5

	var/original_siemens

/datum/symptom/tesla/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB/2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4)
				if (prob(15))
					M << "<span class='warning'>You scramble nearby electronics.</span>"
					empulse(get_turf(M), 1, 1)
				else
					M << "<span class='warning'>Electricity arcs off you into the ground.</span>"
			if(5)
				if(prob(50))
					M << "<span class='userdanger'>[pick("You release your static charge!", "You emit a powerful shock!")]</span>"
					playsound(get_turf(M), 'sound/magic/LightningShock.ogg', 100, 1, extrarange = 5)
					tesla_zap(get_turf(M), 3, 8000)
				else
					M << "<span class='userdanger'>You emit an electromagnetic pulse!</span>"
					empulse(get_turf(M), 2, 4)

			else

				M << "<span class='warning'>[pick("You feel charged.", "You feel currents of electricity wash over your skin.", "You feel insulated.")]</span>"

	return

/datum/symptom/tesla/Start(datum/disease/advance/A) //Make the mob immune to shocks, mainly to prevent self-shocking
	var/mob/living/M = A.affected_mob
	original_siemens = M.siemens_coeff
	M.siemens_coeff = 0

/datum/symptom/tesla/End(datum/disease/advance/A)
	var/mob/living/M = A.affected_mob
	M.siemens_coeff = original_siemens
