/datum/action/changeling/confusion_smoke
	name = "Confusion Smoke"
	desc = "We vaporize some of our blood to create a smoke cloud while steahlthy injecting hallucination reagents into nearby humans."
	helptext = "Create a smoke cloud and confuses nearby people, causing them to see everyone to have the same appearance as you"
	chemical_cost = 30
	dna_cost = 2

/datum/action/changeling/confusion_smoke/sting_action(mob/living/user, mob/living/target)
	. = ..()
	var/mob/living/carbon/our_ling = user
	for(var/dir in GLOB.alldirs)
		our_ling.spray_blood(dir)
	var/datum/effect_system/fluid_spread/smoke/blood_smoke/smoke_screen = new()
	smoke_screen.set_up(2, holder = user, location = user.loc)
	smoke_screen.start()
	var/list/targets = oviewers(5, user.loc)

	for(var/mob/confused_mob in targets)
		if(!isliving(confused_mob))
			continue
		var/mob/living/mob_to_confuse = confused_mob
		mob_to_confuse.cause_hallucination(\
		/datum/hallucination/delusion/changeling, \
		"[user.name]", \
		duration = 20 SECONDS, \
		affects_us = FALSE, \
		affects_others = TRUE, \
		skip_nearby = FALSE, \
		play_wabbajack = FALSE, \
		passed_appearance = user.appearance, \
	)

	return TRUE

/datum/effect_system/fluid_spread/smoke/blood_smoke
	effect_type = /obj/effect/particle_effect/fluid/smoke/red

/obj/effect/particle_effect/fluid/smoke/red
	name = "red smoke"
	color = COLOR_MAROON
	opacity = FALSE
	lifetime = 15 SECONDS
