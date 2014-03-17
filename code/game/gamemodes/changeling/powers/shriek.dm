/obj/effect/proc_holder/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal chords shift, allowing us to briefly emit a noise that deafens and confuses the weak-minded."
	helptext = "Emits a high-frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors."
	chemical_cost = 25
	dna_cost = 1
	req_human = 1

//A flashy ability, good for crowd control and sewing chaos.
/obj/effect/proc_holder/changeling/resonant_shriek/sting_action(var/mob/user)
	for(var/mob/living/M in hearers(4, user))
		if(iscarbon(M))
			if(!M.mind || !M.mind.changeling)
				M.ear_deaf += 30
				M.confused += 20
				M.Jitter(50)
			else
				M << sound('sound/effects/screech.ogg')

		if(issilicon(M))
			M << sound('sound/weapons/flash.ogg')
			M.Weaken(rand(5,10))

	for(var/obj/machinery/light/L in range(4, user))
		L.on = 1
		L.broken()

	feedback_add_details("changeling_powers","RS")
	return 1

/obj/effect/proc_holder/changeling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We shift our vocal cords to release a high-frequency sound that overloads nearby electronics."
	chemical_cost = 20
	dna_cost = 1

//A flashy ability, good for crowd control and sewing chaos.
/obj/effect/proc_holder/changeling/dissonant_shriek/sting_action(var/mob/user)
	for(var/obj/machinery/light/L in range(5, usr))
		L.on = 1
		L.broken()
	empulse(get_turf(user), 2, 5, 1)
	return 1


