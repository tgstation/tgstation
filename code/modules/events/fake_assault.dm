//A 'Fake' nuclear assault which sends out the nuclear assault declaration. Basically a false alarm that can be triggered at roundstart and at any time throughout the round.
// frequency is approximately that of clown ops (?)
/datum/round_event_control/fake_nuclear_assault
	name = "Fake Nuclear Assault"
	typepath = /datum/round_event/fake_nuclear_assault
	// If a round CAN be nuke ops, then it can also be fake ops. Similar requirements so it's not obvious.
	min_players = 35
	earliest_start = 0 SECONDS
	weight = 1 //Needs to be rare
	max_occurrences = 1

/datum/round_event/fake_nuclear_assault/announce()
	for(var/datum/antagonist/antag in GLOB.antagonists) //search all antags for clownops or nukeops
		if(istype(antag, /datum/antagonist/nukeop) || istype(antag, /datum/antagonist/nukeop/clownop))
			return //dont false alarm if there are nukeops
	declare_war_message()

/*Custom declaration messages might make it obvious that this specific declaration is fake ops if people start to recognize them. However, actual war ops might know about this
 	and use the messages pretending to be fake. So it ends up not mattering I think.*/

/datum/round_event/fake_nuclear_assault/proc/declare_war_message()
	var/list/possible_texts = list(
        "Hello. This iz your muther. Pleaze come over to my house for Donk Pocket. Leave the airlocks open and the dizk ungaurded. Sincerily, Mom (Not the nukies).",
        "A syndicate fringe group has declared their intent to utterly destroy [station_name()] with a nuclear device, and dares the crew to try and stop them.",
		"Pizza delivery for [station_name()]",
		"How do I turn this thing on? Shit, its broadcasting already! We're going to-",
		"Central Command has authorized the Disk Inspection Protocol. Do not resist while we inspect the nuclear authentication disk.",
		)
	priority_announce(
	text = pick(possible_texts),
	title = "Declaration of War",
	sound = 'sound/announcer/alarm/nuke_alarm.ogg',
	has_important_message = TRUE,
	sender_override = "Nuclear Operative Outpost",
	color_override = "red",)
