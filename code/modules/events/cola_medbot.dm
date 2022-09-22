/*
	spawns medibots that sometimes inject cola, and also pays cargo.
	check medbot.dm for more info
*/

/datum/round_event_control/cola_bot
	name = "Cola-Sponsored Medibots"
	typepath = /datum/round_event/cola_bot
	weight = 20
	min_players = 3
	earliest_start = 5 MINUTES
	max_occurrences = 20
	category = EVENT_CATEGORY_FRIENDLY

	/// saves a turf in case an admin wants to target a specific tile when spawning
	var/atom/special_target

/datum/round_event_control/cola_bot/admin_setup()
	if(!check_rights(R_FUN))
		return

	if(alert("Spawn at current location?","Targeted Delivery", "Yes", "No") == "Yes")
		special_target = get_turf(usr)

/datum/round_event/cola_bot/announce(fake)
	priority_announce("After many negotiations, Robust Softdrinks has agreed to sponsor our station, in return for supplying specially modified medical bots. Nanotrasen and Robust Softdrinks are not responsible for any injuries or death that may occur as a result.", "General Alert")


/datum/round_event/cola_bot/start()
	var/datum/round_event_control/cola_bot/controller = control
	var/turf/special_target = controller.special_target  // typecast and simplify in the same line wow
	for(var/I in 1 to rand(5, 10))

		var/turf/airdrop = special_target || find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)
		special_target = null  // only spawns on loc the first time

		podspawn(list(
			"target" = airdrop,
			"style" = STYLE_BLUESPACE,
			"spawn" = /mob/living/simple_animal/bot/medbot/cola,
		))

		new /obj/effect/pod_landingzone(airdrop, pod)
