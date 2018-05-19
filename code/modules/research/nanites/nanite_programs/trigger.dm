//Nanites built to lay dormant until manually triggered

/datum/nanite_program/triggered
	use_rate = 0
	trigger_cost = 5
	trigger_cooldown = 5
	can_trigger = TRUE

/datum/nanite_program/triggered/shocking
	name = "Electric Shock"
	desc = "The nanites shock the host when triggered. Destroys a large amount of nanites!"
	trigger_cost = 7.5
	trigger_cooldown = 300
	program_flags = NANITE_SHOCK_IMMUNE
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/shocking/trigger()
	if(!..())
		return
	host_mob.electrocute_act(rand(5,10), "shock nanites", TRUE, TRUE)

/datum/nanite_program/triggered/stun
	name = "Neural Shock"
	desc = "The nanites pulse the host's nerves when triggered, inapacitating them for a short period."
	trigger_cost = 4
	trigger_cooldown = 300
	rogue_types = list(/datum/nanite_program/triggered/shocking, /datum/nanite_program/nerve_decay)

/datum/nanite_program/triggered/stun/trigger()
	if(!..())
		return
	playsound(host_mob, "sparks", 75, 1, -1)
	host_mob.Knockdown(80)

/datum/nanite_program/triggered/emp
	name = "Electromagnetic Resonance"
	desc = "The nanites cause an elctromagnetic pulse around the host when triggered. Will corrupt other nanite programs!"
	trigger_cost = 7.5
	program_flags = NANITE_EMP_IMMUNE
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/emp/trigger()
	if(!..())
		return
	empulse(host_mob, 1, 2)

/datum/nanite_program/triggered/sleepy
	name = "Sleep Induction"
	desc = "The nanites cause rapid narcolepsy when triggered."
	trigger_cost = 15
	trigger_cooldown = 1200
	rogue_types = list(/datum/nanite_program/brain_misfire, /datum/nanite_program/brain_decay)

/datum/nanite_program/triggered/sleepy/trigger()
	if(!..())
		return
	to_chat(host_mob, "<span class='warning'>You start to feel very sleepy...</span>")
	host_mob.drowsyness += 20
	addtimer(CALLBACK(host_mob, /mob/living.proc/Sleeping, 200), rand(60,200))

/datum/nanite_program/triggered/explosive
	name = "Chain Detonation"
	desc = "Detonates all the nanites inside the host in a chain reaction when triggered."
	trigger_cost = 25 //plus every idle nanite left afterwards
	trigger_cooldown = 100 //Just to avoid double-triggering
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/triggered/explosive/trigger()
	if(!..())
		return
	host_mob.visible_message("<span class='warning'>[host_mob] starts emitting a high-pitched buzzing, and [host_mob.p_their()] skin begins to glow...</span>",\
							"<span class='userdanger'>You start emitting a high-pitched buzzing, and your skin begins to glow...</span>")
	addtimer(CALLBACK(src, .proc/boom), CLAMP((nanites.nanite_volume * 0.35), 25, 150))

/datum/nanite_program/triggered/explosive/proc/boom()
	var/nanite_amount = nanites.nanite_volume
	var/dev_range = FLOOR(nanite_amount/200, 1) - 1
	var/heavy_range = FLOOR(nanite_amount/100, 1) - 1
	var/light_range = FLOOR(nanite_amount/50, 1) - 1
	explosion(host_mob, dev_range, heavy_range, light_range)
	qdel(nanites)

//TODO make it defuse if triggered again

/datum/nanite_program/triggered/heart_stop
	name = "Heart-Stopping Nanites"
	desc = "Stops the host's heart when triggered; restarts it if triggered again."
	trigger_cost = 12
	trigger_cooldown = 10
	rogue_types = list(/datum/nanite_program/nerve_decay)

/datum/nanite_program/triggered/heart_stop/trigger()
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