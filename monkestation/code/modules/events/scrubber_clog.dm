/datum/round_event_control/scrubber_clog
	shared_occurence_type = SHARED_SCRUBBERS

/datum/round_event_control/scrubber_clog/flood //I have it here cause of the extra silly spaghetti code all of the scrubbers depend on being in here
	name = "Scrubber Clog: Flood"
	typepath = /datum/round_event/scrubber_clog/flood
	weight = 0
	max_occurrences = 0
	description = "Bees absolutely flood out of a scrubber, used by the Rayne corp bee nuke."
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 6

/datum/round_event/scrubber_clog/flood
	maximum_spawns = 250

/datum/round_event/scrubber_clog/flood/setup()
	. = ..()
	end_when = rand(2000, 4000)
	spawn_delay = rand(1, 2) //IT MUST FLOOD

/datum/round_event/scrubber_clog/flood/announce()
	priority_announce("Unusual lifesign readings detected in the entire ventilation network.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/round_event/scrubber_clog/flood/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/bee,
	)
	return pick(mob_list)
