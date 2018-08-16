// THIS IS NOW MERELY LEGACY, because memes. hopefully it won't be dumb.

//
//	The belly object is what holds onto a mob while they're inside a predator.
//	It takes care of altering the pred's decription, digesting the prey, relaying struggles etc.
//

// If you change what variables are on this, then you need to update the copy() proc.

//
// Parent type of all the various "belly" varieties.
//
/datum/belly
	var/name								// Name of this location
	var/inside_flavor						// Flavor text description of inside sight/sound/smells/feels.
	var/vore_sound = 'sound/vore/pred/swallow_01.ogg'	// Sound when ingesting someone
	var/vore_verb = "ingest"				// Verb for eating with this in messages
	var/human_prey_swallow_time = 10 SECONDS		// Time in deciseconds to swallow /mob/living/carbon/human
	var/nonhuman_prey_swallow_time = 5 SECONDS		// Time in deciseconds to swallow anything else
	var/emoteTime = 30 SECONDS				// How long between stomach emotes at prey
	var/digest_brute = 0					// Brute damage per tick in digestion mode
	var/digest_burn = 1						// Burn damage per tick in digestion mode
	var/digest_tickrate = 9					// Modulus this of air controller tick number to iterate gurgles on
	var/immutable = FALSE					// Prevents this belly from being deleted
	var/escapable = FALSE					// Belly can be resisted out of at any time
	var/escapetime = 60 SECONDS				// Deciseconds, how long to escape this belly
	var/digestchance = 0					// % Chance of stomach beginning to digest if prey struggles
//	var/silenced = FALSE					// Will the heartbeat/fleshy internal loop play?
	var/escapechance = 0 					// % Chance of prey beginning to escape if prey struggles.

	var/datum/belly/transferlocation = null	// Location that the prey is released if they struggle and get dropped off.
	var/transferchance = 0 					// % Chance of prey being transferred to transfer location when resisting
	var/autotransferchance = 0 				// % Chance of prey being autotransferred to transfer location
	var/autotransferwait = 10 				// Time between trying to transfer.
	var/can_taste = FALSE					// If this belly prints the flavor of prey when it eats someone.

	var/tmp/digest_mode = DM_HOLD			// Whether or not to digest. Default to not digest.
	var/tmp/list/digest_modes = list(DM_HOLD,DM_DIGEST,DM_HEAL,DM_NOISY)	// Possible digest modes
	var/tmp/mob/living/owner				// The mob whose belly this is.
	var/tmp/list/internal_contents = list()	// People/Things you've eaten into this belly!
	var/tmp/is_full							// Flag for if digested remeans are present. (for disposal messages)
	var/tmp/emotePend = FALSE				// If there's already a spawned thing counting for the next emote
	var/swallow_time = 10 SECONDS			// for mob transfering automation
	var/vore_capacity = 1				// The capacity (in people) this person can hold

	// Don't forget to watch your commas at the end of each line if you change these.
	var/list/struggle_messages_outside = list(
		"%pred's %belly wobbles with a squirming meal.",
		"%pred's %belly jostles with movement.",
		"%pred's %belly briefly swells outward as someone pushes from inside.",
		"%pred's %belly fidgets with a trapped victim.",
		"%pred's %belly jiggles with motion from inside.",
		"%pred's %belly sloshes around.",
		"%pred's %belly gushes softly.",
		"%pred's %belly lets out a wet squelch.")

	var/list/struggle_messages_inside = list(
		"Your useless squirming only causes %pred's slimy %belly to squelch over your body.",
		"Your struggles only cause %pred's %belly to gush softly around you.",
		"Your movement only causes %pred's %belly to slosh around you.",
		"Your motion causes %pred's %belly to jiggle.",
		"You fidget around inside of %pred's %belly.",
		"You shove against the walls of %pred's %belly, making it briefly swell outward.",
		"You jostle %pred's %belly with movement.",
		"You squirm inside of %pred's %belly, making it wobble around.")

	var/list/digest_messages_owner = list(
		"You feel %prey's body succumb to your digestive system, which breaks it apart into soft slurry.",
		"You hear a lewd glorp as your %belly muscles grind %prey into a warm pulp.",
		"Your %belly lets out a rumble as it melts %prey into sludge.",
		"You feel a soft gurgle as %prey's body loses form in your %belly. They're nothing but a soft mass of churning slop now.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your thighs.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your rump.",
		"Your %belly begins gushing %prey's remains through your system, adding some extra weight to your belly.",
		"Your %belly groans as %prey falls apart into a thick soup. You can feel their remains soon flowing deeper into your body to be absorbed.",
		"Your %belly kneads on every fiber of %prey, softening them down into mush to fuel your next hunt.",
		"Your %belly churns %prey down into a hot slush. You can feel the nutrients coursing through your digestive track with a series of long, wet glorps.")

	var/list/digest_messages_prey = list(
		"Your body succumbs to %pred's digestive system, which breaks you apart into soft slurry.",
		"%pred's %belly lets out a lewd glorp as their muscles grind you into a warm pulp.",
		"%pred's %belly lets out a rumble as it melts you into sludge.",
		"%pred feels a soft gurgle as your body loses form in their %belly. You're nothing but a soft mass of churning slop now.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's thighs.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's rump.",
		"%pred's %belly begins gushing your remains through their system, adding some extra weight to %pred's belly.",
		"%pred's %belly groans as you fall apart into a thick soup. Your remains soon flow deeper into %pred's body to be absorbed.",
		"%pred's %belly kneads on every fiber of your body, softening you down into mush to fuel their next hunt.",
		"%pred's %belly churns you down into a hot slush. Your nutrient-rich remains course through their digestive track with a series of long, wet glorps.")

	var/list/examine_messages = list(
		"They have something solid in their %belly!",
		"It looks like they have something in their %belly!")

	//Mostly for being overridden on precreated bellies on mobs. Could be VV'd into
	//a carbon's belly if someone really wanted. No UI for carbons to adjust this.
	//List has indexes that are the digestion mode strings, and keys that are lists of strings.
	var/list/emote_lists = list()

//OLD: This only exists for legacy conversion purposes
//It's called whenever an old datum-style belly is loaded
/datum/belly/proc/copy(obj/belly/new_belly)

	//// Non-object variables
	new_belly.name = name
	new_belly.desc = inside_flavor
	new_belly.vore_sound = vore_sound
	new_belly.vore_verb = vore_verb
	new_belly.human_prey_swallow_time = human_prey_swallow_time
	new_belly.nonhuman_prey_swallow_time = nonhuman_prey_swallow_time
	new_belly.emote_time = emoteTime
	new_belly.digest_brute = digest_brute
	new_belly.digest_burn = digest_burn
	new_belly.immutable = immutable
	new_belly.can_taste = can_taste
	new_belly.escapable = escapable
	new_belly.escapetime = escapetime
	new_belly.digestchance = digestchance
	new_belly.escapechance = escapechance
	new_belly.transferchance = transferchance
	new_belly.transferlocation = transferlocation

	//// Object-holding variables
	//struggle_messages_outside - strings
	new_belly.struggle_messages_outside.Cut()
	for(var/I in struggle_messages_outside)
		new_belly.struggle_messages_outside += I

	//struggle_messages_inside - strings
	new_belly.struggle_messages_inside.Cut()
	for(var/I in struggle_messages_inside)
		new_belly.struggle_messages_inside += I

	//digest_messages_owner - strings
	new_belly.digest_messages_owner.Cut()
	for(var/I in digest_messages_owner)
		new_belly.digest_messages_owner += I

	//digest_messages_prey - strings
	new_belly.digest_messages_prey.Cut()
	for(var/I in digest_messages_prey)
		new_belly.digest_messages_prey += I

	//examine_messages - strings
	new_belly.examine_messages.Cut()
	for(var/I in examine_messages)
		new_belly.examine_messages += I

	//emote_lists - index: digest mode, key: list of strings
	new_belly.emote_lists.Cut()
	for(var/K in emote_lists)
		new_belly.emote_lists[K] = list()
		for(var/I in emote_lists[K])
			new_belly.emote_lists[K] += I

	return new_belly

// // // // // // // // // // // //
// // // LEGACY USE ONLY!! // // //
// // // // // // // // // // // //
//       See top of file!        //
// // // // // // // // // // // //
