#define DOOM_SINGULARITY "singularity"
#define DOOM_TESLA "tesla"
#define DOOM_METEORS "meteors"
#define DOOM_EVENTS "events" //monkestation edit: we can get singalos and teslas normally, so im adding a few more
#define DOOM_ANTAGS "threats" //monkestation edit
#define DOOM_ROD "rod" //monkestation edit

/// Kill yourself and probably a bunch of other people
/datum/grand_finale/armageddon
	name = "Annihilation"
	desc = "This crew have offended you beyond the realm of pranks. Make the ultimate sacrifice to teach them a lesson your elders can really respect. \
		YOU WILL NOT SURVIVE THIS."
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "wounded"
	minimum_time = 90 MINUTES // This will probably immediately end the round if it gets finished.
	ritual_invoke_time = 60 SECONDS // Really give the crew some time to interfere with this one.
	dire_warning = TRUE
	glow_colour = "#be000048"
	/// Things to yell before you die
	var/static/list/possible_last_words = list(
		"Flames and ruin!",
		"Dooooooooom!!",
		"HAHAHAHAHAHA!! AHAHAHAHAHAHAHAHAA!!",
		"Hee hee hee!! Hoo hoo hoo!! Ha ha haaa!!",
		"Ohohohohohoho!!",
		"Cower in fear, puny mortals!",
		"Tremble before my glory!",
		"Pick a god and pray!",
		"It's no use!",
		"If the gods wanted you to live, they would not have created me!",
		"God stays in heaven out of fear of what I have created!",
		"Ruination is come!",
		"All of creation, bend to my will!",
	)

/datum/grand_finale/armageddon/trigger(mob/living/carbon/human/invoker)
	priority_announce(pick(possible_last_words), null, 'sound/magic/voidblink.ogg', sender_override = "[invoker.real_name]", color_override = "purple")
	var/turf/current_location = get_turf(invoker)
	invoker.gib()

	var/static/list/doom_options = list()
	if (!length(doom_options))
//		doom_options = list(DOOM_SINGULARITY, DOOM_TESLA) //monkestation removal
		doom_options = list(DOOM_EVENTS, DOOM_ANTAGS, DOOM_ROD) //monkestation edit
		if (!SSmapping.config.planetary)
			doom_options += DOOM_METEORS

	switch(pick(doom_options))
//monkestation removal start
		/*if (DOOM_SINGULARITY)
			var/obj/singularity/singulo = new(current_location)
			singulo.energy = 300
		if (DOOM_TESLA)
			var/obj/energy_ball/tesla = new (current_location)
			tesla.energy = 200*/
//monkestation removal end
		if (DOOM_METEORS)
			var/datum/dynamic_ruleset/roundstart/meteor/meteors = new()
			meteors.meteordelay = 0
			var/datum/game_mode/dynamic/mode = SSticker.mode
			mode.execute_roundstart_rule(meteors) // Meteors will continue until morale is crushed.
			priority_announce("Meteors have been detected on collision course with the station.", "Meteor Alert", ANNOUNCER_METEORS)
//monkestation edit start
		if (DOOM_EVENTS) //triggers a MASSIVE amount of events pretty quickly
			summon_events() //wont effect the events created directly from this, but it will effect any events that happen after
			var/list/possible_events = list()
			for(var/datum/round_event_control/possible_event as anything in SSevents.control)
				if(possible_event.max_wizard_trigger_potency < 6) //only run the decently big ones
					continue
				possible_events += possible_event
			var/timer_counter = 1
			for(var/i in 1 to 50) //high chance this number needs tweaking, but we do want this to be a round ending amount of events
				var/datum/round_event_control/event = pick(possible_events)
				addtimer(CALLBACK(event, TYPE_PROC_REF(/datum/round_event_control, run_event)), (10 * timer_counter) SECONDS)
				timer_counter++
		if (DOOM_ANTAGS) //so I heard you like antags
			var/datum/game_mode/dynamic/dynamic = SSticker.mode
			dynamic.create_threat(100, dynamic.threat_log, "Final grand ritual")
			ASYNC //sleeps
				for(var/i in 1 to 4) //spawn 4 midrounds
					sleep(50) //sleep 5 seconds between each one
					var/list/possible_rulesets = dynamic.init_rulesets(/datum/dynamic_ruleset/midround/from_ghosts)
					if(i == 1) //always draft at least one heavy, although funny, it would be kind of lame if we just got 4 abductors
						for(var/datum/dynamic_ruleset/midround/entry in possible_rulesets)
							if(!entry.midround_ruleset_style == MIDROUND_RULESET_STYLE_HEAVY)
								possible_rulesets -= entry
					var/picked_ruleset = pick(possible_rulesets)
					dynamic.picking_specific_rule(picked_ruleset, TRUE)
		if (DOOM_ROD) //spawns a ghost controlled, forced looping rod, only technically less damaging then singaloth or tesloose
			var/obj/effect/immovablerod/rod = new(current_location)
			rod.loopy_rod = TRUE
			rod.can_suplex = FALSE
			rod.deadchat_plays(ANARCHY_MODE, 4 SECONDS)
//monkestation edit end

#undef DOOM_SINGULARITY
#undef DOOM_TESLA
#undef DOOM_METEORS
#undef DOOM_EVENTS //monkestation edit
#undef DOOM_ANTAGS //monkestation edit
#undef DOOM_ROD //monkestation edit
