
/datum/round_event_control/alien_blessings
	name = "Alien Blessings"
	typepath = /datum/round_event/alien_blessings
	weight = 10
	max_occurrences = 2
	earliest_start = 15 MINUTES
	min_players = 35

/datum/round_event/alien_blessings

/datum/round_event/alien_blessings/start()
	//for(var/mob/living/carbon/human/H in apply_luck(GLOB.alive_mob_list, POSITIVE_EVENT))
	for(var/mob/living/carbon/human/H in shuffle(GLOB.alive_mob_list))
		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(!H.job)
			continue
		for(var/i in 1 to 3)
			to_chat(R, "<span class='italics'>You hear a faint beep.</span>")
			sleep(5)
		to_chat(H, "<span class='notice'>Something unlocks in your mind, and you feel like you have learned something new...</span>")
		sleep(10)
		if(H.mind.assigned_role == "Captain")
			to_chat(H, "<span class='notice'>...A ruthless leader, using questionable tactics to keep the throne... You have learned how to override permissions on devices!</span>")
		if(H.mind.assigned_role in GLOB.engineering_positions)
			to_chat(H, "<span class='notice'>...An MI13 Operative reroutes power to the APC, and escapes through the disposals... You have learned how to initiate emergency power routines on APCs!</span>")
		if(H.mind.assigned_role in GLOB.medical_positions)
			to_chat(H, "<span class='notice'>Flashes of advanced alien training courses through your mind... You have learned how to give improved CPR!</span>")
			H.cpr_power = CPR_GOOD
		if(H.mind.assigned_role in GLOB.science_positions)
			to_chat(H, "<span class='notice'>Eureka! The mad [job] has a dire revelation... You don't know what to do for special powers yet.</span>")//help
		if(H.mind.assigned_role in GLOB.supply_positions)
			to_chat(H, "<span class='notice'>You have learned how to craft makeshift guns? This one should change.</span>")//probably not a good perk jesus
		if(H.mind.assigned_role in GLOB.civilian_positions)
			to_chat(H, "<span class='notice'>Revelations of the universe... You feel at peace.</span>")
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "universe", /datum/mood_event/universe)
		if(H.job in GLOB.security_positions)
			to_chat(H, "<span class='notice'>Flashes of advanced alien training courses through your mind... You feel like you might be able to dodge projectiles!</span>")
			var/datum/martial_art/lightning_reflexes/reflex = new(null)
			reflex.teach(user)
		announce_to_ghosts(H)
		break

/datum/martial_art/lightning_reflexes
	name = "Lightning Reflexes"
	deflection_chance = 20