/datum/station_trait/bananium_shipment
	name = "Bananium Shipment"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	report_message = "Rumors has it that the clown planet has been sending support packages to clowns in this system"
	trait_to_give = STATION_TRAIT_BANANIUM_SHIPMENTS

/datum/station_trait/unnatural_atmosphere
	name = "Unnatural atmospherical properties"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "System's local planet has irregular atmospherical properties"
	trait_to_give = STATION_TRAIT_UNNATURAL_ATMOSPHERE

/datum/station_trait/unique_ai
	name = "Unique AI"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "For experimental purposes, this station AI might show divergence from default lawset. Do not meddle with this experiment."
	trait_to_give = STATION_TRAIT_UNIQUE_AI

/datum/station_trait/ian_adventure
	name = "Ian's Adventure"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = FALSE
	report_message = "Ian has gone exploring somewhere in the station."

/datum/station_trait/ian_adventure/on_round_start()
	for(var/mob/living/simple_animal/pet/dog/corgi/dog in GLOB.mob_list)
		if(!(istype(dog, /mob/living/simple_animal/pet/dog/corgi/ian) || istype(dog, /mob/living/simple_animal/pet/dog/corgi/puppy/ian)))
			continue

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)


/datum/station_trait/glitched_pdas
	name = "PDA glitch"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 8
	show_in_report = TRUE
	report_message = "Something seems to be wrong with the PDAs issues to you all this shift. Nothing too bad though."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_intern
	name = "Announcement Intern"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Please be nice to him."

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern
