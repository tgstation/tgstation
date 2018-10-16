/obj/effect/proc_holder/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal cords shift, allowing us to briefly emit a noise that deafens and confuses the weak-minded."
	helptext = "Emits a high-frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors."
	chemical_cost = 20
	dna_cost = 1
	req_human = 1

//A flashy ability, good for crowd control and sewing chaos.
/obj/effect/proc_holder/changeling/resonant_shriek/sting_action(mob/user)
	for(var/mob/living/M in get_hearers_in_view(4, user))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.mind || !C.mind.has_antag_datum(/datum/antagonist/changeling))
				C.adjustEarDamage(0, 30)
				C.confused += 25
				C.Jitter(50)
			else
				SEND_SOUND(C, sound('sound/effects/screech.ogg'))

		if(issilicon(M))
			SEND_SOUND(M, sound('sound/weapons/flash.ogg'))
			M.Paralyze(rand(100,200))

	for(var/obj/machinery/light/L in range(4, user))
		L.on = 1
		L.break_light_tube()
	return TRUE

/obj/effect/proc_holder/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a high-frequency sound that overloads nearby electronics."
	chemical_cost = 20
	dna_cost = 1

//A flashy ability, good for crowd control and sewing chaos.
/obj/effect/proc_holder/changeling/dissonant_shriek/sting_action(mob/user)
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = 1
		L.break_light_tube()
	empulse(get_turf(user), 2, 5, 1)
	return TRUE
