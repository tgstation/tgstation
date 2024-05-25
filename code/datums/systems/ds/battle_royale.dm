/// Global list of areas which are considered to be inside the same department for our purposes
GLOBAL_LIST_INIT(battle_royale_regions, list(
	"Medical Bay" = list(
		/area/station/command/heads_quarters/cmo,
		/area/station/medical,
		/area/station/security/checkpoint/medical,
	),
	"Research Division" = list(
		/area/station/command/heads_quarters/rd,
		/area/station/security/checkpoint/science,
		/area/station/science,
	),
	"Engineering Bay" = list(
		/area/station/command/heads_quarters/ce,
		/area/station/engineering,
		/area/station/maintenance/disposal/incinerator,
		/area/station/security/checkpoint/engineering,
	),
	"Cargo Bay" = list(
		/area/station/cargo,
		/area/station/command/heads_quarters/qm,
		/area/station/security/checkpoint/supply,
	),
))

/// Basically just exists to hold references to datums so that they don't GC
DATASYSTEM_DEF(battle_royale)
	name = "Battle Royale"
	/// List of battle royale datums currently running
	var/list/active_battles

/// Start a new battle royale using a passed list of implants
/datum/system/battle_royale/proc/start_battle(list/competitors)
	var/datum/battle_royale_controller/controller = new()
	if (!controller.start(competitors))
		return FALSE
	LAZYADD(active_battles, controller)
	if (LAZYLEN(active_battles) == 1)
		start_broadcasting_network(BATTLE_ROYALE_CAMERA_NET)
	RegisterSignal(controller, COMSIG_QDELETING, PROC_REF(battle_ended))
	return TRUE

/// Drop reference when it kills itself
/datum/system/battle_royale/proc/battle_ended(datum/source)
	SIGNAL_HANDLER
	LAZYREMOVE(active_battles, source)
	if (!LAZYLEN(active_battles))
		stop_broadcasting_network(BATTLE_ROYALE_CAMERA_NET)


/// Datum which controls the conflict
/datum/battle_royale_controller
	/// Where is our battle taking place?
	var/chosen_area
	/// Is the battle currently in progress?
	var/battle_running = TRUE
	/// Should we let everyone know that someone has died?
	var/announce_deaths = TRUE
	/// List of implants involved
	var/list/contestant_implants = list()
	/// Ways to describe that someone has died
	var/static/list/euphemisms = list(
		"cashed their last paycheque.",
		"didn't make it...",
		"didn't make the cut.",
		"had their head blown clean off!",
		"has been killed!",
		"has failed the challenge!",
		"has passed away.",
		"has died.",
		"is in a better place now.",
		"isn't going to be clocking in tomorrow!",
		"just flatlined.",
		"isn't today's winner.",
		"seems to have exploded!",
		"was just murdered on live tv!",
		"won't be making it to retirement.",
		"won't be getting back up after that one.",
	)
	/// Ways to tell people not to salt in deadchat, surely effective
	var/static/list/condolences = list(
		"Better luck next time!",
		"But stay tuned, there's still everything to play for!",
		"Did you catch who did it?",
		"It looked like that one really hurt...",
		"Let's get that one on action replay!",
		"Let's have a moment of silence, please.",
		"Let's hope the next one does better.",
		"Someone please notify their next of kin.",
		"They had a good run.",
		"Too bad!",
		"What a shame!",
		"What an upset!",
		"What's going to happen next?",
		"Who could have seen that coming?",
		"Who will be next?",
	)

/datum/battle_royale_controller/Destroy(force)
	contestant_implants = null
	return ..()

/// Start a battle royale with the list of provided implants
/datum/battle_royale_controller/proc/start(list/implants, battle_time = 10 MINUTES)
	chosen_area = pick(GLOB.battle_royale_regions)
	for (var/obj/item/implant/explosive/battle_royale/contestant_implant in implants)
		contestant_implant.start_battle(chosen_area, GLOB.battle_royale_regions[chosen_area])
		if (isnull(contestant_implant))
			continue // Might have exploded if it was removed from a person
		RegisterSignal(contestant_implant, COMSIG_QDELETING, PROC_REF(implant_destroyed))
		contestant_implants |= contestant_implant

	if (length(contestant_implants) <= 1)
		return FALSE // Well there's not much point is there

	priority_announce(
		text = "Congratulations [station_name()], you have been chosen as the next site of the Rumble Royale! \n\
			Viewers across the sector will watch our [convert_integer_to_words(length(contestant_implants))] lucky contestants battle their way into your [chosen_area] and fight until only one is left standing! \n\
			If they don't make it in five minutes, they'll be disqualified. If you see one of our players struggling to get in, do lend them a hand... or don't, if you can live with the consequences!  \n\
			As a gesture of gratitude, we will be providing our premium broadcast to your entertainment monitors at no cost so that you can watch the excitement. \n\
			Bystanders are advised not to intervene... but if you do, make it look good for the camera!",
		title = "Rumble Royale Beginning",
		sound = 'sound/machines/alarm.ogg',
		has_important_message = TRUE,
		sender_override = "Rumble Royale Pirate Broadcast Station",
		color_override = "red",
	)

	for (var/obj/item/implant/explosive/battle_royale/contestant_implant as anything in contestant_implants)
		contestant_implant.announce()
	addtimer(CALLBACK(src, PROC_REF(limit_area)), battle_time / 2, TIMER_DELETE_ME)
	addtimer(CALLBACK(src, PROC_REF(finish)), battle_time, TIMER_DELETE_ME)
	return TRUE

/// An implant was destroyed, hopefully because it exploded. Count how many competitors remain.
/datum/battle_royale_controller/proc/implant_destroyed(obj/item/implant/implant)
	SIGNAL_HANDLER
	contestant_implants -= implant
	if (!battle_running)
		return

	if (length(contestant_implants) <= 1)
		announce_winner(implant)
	else if (announce_deaths)
		var/message = ""
		if (isnull(implant.imp_in))
			message = "Looks like someone removed and destroyed their implant, that's cheating!"
		else
			message = "[implant.imp_in.real_name] [pick(euphemisms)] [pick(condolences)]"
		priority_announce(
			text = message,
			title = "Rumble Royale Casualty Report",
			sound = 'sound/misc/notice1.ogg',
			has_important_message = TRUE,
			sender_override = "Rumble Royale Pirate Broadcast Station",
			color_override = "red",
		)

/// There's only one person left, we have a winner!
/datum/battle_royale_controller/proc/announce_winner(obj/item/implant/losing_implant)
	battle_running = FALSE
	if (length(contestant_implants) > 1)
		return

	var/message = ""
	var/mob/living/loser = losing_implant.imp_in
	var/obj/item/implant/winning_implant = pop(contestant_implants)
	var/mob/living/winner = winning_implant?.imp_in

	if (isnull(winner) && isnull(loser))
		message = "Somehow, it seems like there's no winner tonight. What a disappointment!"
	else
		var/loser_text = isnull(loser) ? "With the disqualification of the other remaining contestant" : "With the death of [loser.real_name]"
		var/winner_text = isnull(winner) ? "we must sadly announce that the would-be winner has also been disqualified. Such bad showmanship!" : "only [winner.real_name] remains. Congratulations, we have a winner!"
		message = "[loser_text], [winner_text]"

	if (!isnull(winner))
		podspawn(list(
			"target" = get_turf(winner),
			"style" = STYLE_SYNDICATE,
			"spawn" = /obj/item/food/roast_dinner,
		))

	priority_announce(
		text = message,
		title = "Rumble Royale Winner",
		sound = 'sound/misc/notice1.ogg',
		has_important_message = TRUE,
		sender_override = "Rumble Royale Pirate Broadcast Station",
		color_override = "red",
	)

	qdel(winning_implant) // You get to live!
	winner?.mind?.remove_antag_datum(/datum/antagonist/survivalist/battle_royale)
	qdel(src)

/// Called halfway through the battle, if you've not made it to the designated battle zone we kill you
/datum/battle_royale_controller/proc/limit_area()
	priority_announce(
		text = "We're halfway done folks! And bad news to anyone who hasn't made it to the [chosen_area]... you're out!",
		title = "Rumble Royale Update",
		sound = 'sound/misc/notice1.ogg',
		has_important_message = TRUE,
		sender_override = "Rumble Royale Pirate Broadcast Station",
		color_override = "red",
	)

	for (var/obj/item/implant/explosive/battle_royale/contestant_implant as anything in contestant_implants)
		contestant_implant.limit_areas()

/// Well you're out of time, bad luck
/datum/battle_royale_controller/proc/finish()
	battle_running = FALSE

	priority_announce(
		text = "Sorry remaining contestants, your time is up. \
			We're sorry to announce that this edition of Royal Rumble has no winner. \n\
			Better luck next time!",
		title = "Rumble Royale Concluded",
		sound = 'sound/misc/notice1.ogg',
		has_important_message = TRUE,
		sender_override = "Rumble Royale Pirate Broadcast Station",
		color_override = "red",
	)

	for (var/obj/item/implant/explosive/battle_royale/contestant_implant as anything in contestant_implants)
		contestant_implant.explode()

	qdel(src)
