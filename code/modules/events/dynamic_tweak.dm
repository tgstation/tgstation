// Simple hidden event that adds a few more latejoins and midrounds to the round
// Keeps Greenshifts on their toes and prevents metagaming
/datum/round_event_control/dynamic_tweak
	name = "Dynamic Tweak"
	typepath = /datum/round_event/dynamic_tweak
	weight = 10
	max_occurrences = 1
	earliest_start = 20 MINUTES
	alert_observers = FALSE
	category = EVENT_CATEGORY_INVASION
	description = "Allows Dynamic to spawn another midround or latejoin. Gives some spice to Greenshifts."

/datum/round_event_control/dynamic_tweak/New()
	. = ..()
	if(max_occurrences > 0)
		max_occurrences += rand(-1, 1)

/datum/round_event_control/dynamic_tweak/can_spawn_event(players_amt, allow_magic)
	return ..() && SSdynamic.antag_events_enabled && !EMERGENCY_PAST_POINT_OF_NO_RETURN

/datum/round_event/dynamic_tweak
	start_when = 1
	end_when = 2
	fakeable = FALSE

/datum/round_event/dynamic_tweak/start()
	var/new_lights = rand(0, 1)
	var/new_heavies = rand(1 - new_lights, 1) // guarantee a heavy if no new light
	var/new_latejoins = rand(1 - new_heavies, 1) // guarantee a latejoin if no new heavy

	SSdynamic.rulesets_to_spawn[LIGHT_MIDROUND] += new_lights
	SSdynamic.rulesets_to_spawn[HEAVY_MIDROUND] += new_heavies
	SSdynamic.rulesets_to_spawn[LATEJOIN] += new_latejoins

	message_admins("Event: Dynamic Tweak added [new_latejoins] latejoin\s, [new_lights] light midround\s and [new_heavies] heavy midround\s.")
