//Nanites built to lay dormant until manually triggered

/datum/reagent/nanites/programmed/triggered
	metabolization_rate = 0
	trigger_cost = 5
	trigger_cooldown = 5
	can_trigger = TRUE

/datum/reagent/nanites/programmed/triggered/shocking
	name = "Shock Nanites"
	description = "Shocks the host when triggered. Destroys a large amount of nanites!"
	id = "shock_nanites"
	metabolization_rate = 0
	trigger_cost = 5
	trigger_cooldown = 30
	nanite_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list("nervous_nanites","paralyzing_nanites")

/datum/reagent/nanites/programmed/triggered/shocking/trigger()
	if(!..())
		return
	host_mob.electrocute_act(rand(5,10), "shock nanites", TRUE, TRUE)

/datum/reagent/nanites/programmed/triggered/emp
	name = "EMP Nanites"
	description = "Causes an EMP around the host when triggered. Destroys a large amount of nanites!"
	id = "emp_nanites"
	metabolization_rate = 0
	trigger_cost = 7.5
	nanite_flags = NANITE_EMP_IMMUNE
	rogue_types = list("nervous_nanites","paralyzing_nanites")

/datum/reagent/nanites/programmed/triggered/emp/trigger()
	if(!..())
		return
	empulse(host_mob, 1, 2)

/datum/reagent/nanites/programmed/triggered/sleepy
	name = "Sleep Nanites"
	description = "Causes near-instant narcolepsy when triggered."
	id = "sleep_nanites"
	metabolization_rate = 0
	trigger_cost = 15
	trigger_cooldown = 45
	rogue_types = list("nervous_nanites","braindecay_nanites")

/datum/reagent/nanites/programmed/triggered/sleepy/trigger()
	if(!..())
		return
	to_chat(host_mob, "<span class='warning'>You suddenly feel very sleepy...</span>")
	host_mob.drowsyness += 15
	addtimer(CALLBACK(host_mob, /mob/living.proc/Sleeping, 200), rand(40,80))

/datum/reagent/nanites/programmed/triggered/explosive
	name = "Explosive Nanites"
	description = "Blows up all the nanites inside the host in a chain reaction when triggered."
	id = "explosive_nanites"
	metabolization_rate = 0
	trigger_cost = 10 //plus every idle nanite left afterwards
	rogue_types = list("toxic_nanites","pyro_nanites")

/datum/reagent/nanites/programmed/triggered/explosive/trigger()
	if(!..())
		return
	host_mob.visible_message("<span class='warning'>[host_mob] starts emitting a high-pitched buzzing, and [host_mob.p_their()] skin begins to glow...</span>",\
							"<span class='userdanger'>You start emitting a high-pitched buzzing, and your skin begins to glow...</span>")
	addtimer(CALLBACK(src, .proc/boom), 50)


/datum/reagent/nanites/programmed/triggered/explosive/proc/boom()
	holder.add_reagent("nanite_detonator",1)

/datum/reagent/nanites/detonator
	name = "Nanite Detonator"
	description = "This should not exist long enough for anyone to read this description."
	id = "nanite_detonator"
	metabolization_rate = 1

/datum/reagent/nanites/programmed/triggered/heart_stop
	name = "Heart-Stopping Nanites"
	description = "Stops the host's heart when triggered; restarts it if triggered again."
	id = "heartstop_nanites"
	metabolization_rate = 0
	trigger_cost = 25
	trigger_cooldown = 1
	rogue_types = list("toxic_nanites","necrotic_nanites","nervous_nanites","paralyzing_nanites")

/datum/reagent/nanites/programmed/triggered/heart_stop/trigger()
	if(!..())
		return
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
		if(heart)
			if(heart.beating)
				heart.Stop()
			else
				heart.Restart()