/// Number of times you need to cast on the rune to complete it
#define GRAND_RUNE_INVOKES_TO_COMPLETE 3
/// Base time to take to invoke one stage of the rune. This is done three times to complete the rune.
#define BASE_INVOKE_TIME 7 SECONDS
/// Time to add on to each step every time a previous rune is completed.
#define ADD_INVOKE_TIME 2 SECONDS

/**
 * Magic rune used in the grand ritual.
 * A wizard sits themselves on this thing and waves their hands for a while shouting silly words.
 * Then something (usually bad) happens.
 */
/obj/effect/grand_rune
	name = "grand rune"
	desc = "A flowing circle of shapes and runes is etched into the floor, the lines twist and move before your eyes."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "wizard_rune"
	pixel_x = -28
	pixel_y = -33
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	/// How many prior grand rituals have been completed?
	var/potency = 0
	/// Time to take per invocation of rune.
	var/invoke_time = BASE_INVOKE_TIME
	/// Prevent ritual spam click.
	var/is_in_use = FALSE
	/// Number of times this rune has been cast
	var/times_invoked = 0
	/// What colour you glow while channeling
	var/spell_colour = "#de3aff48"
	/// Magic words you say to invoke the ritual
	var/list/magic_words = list()
	/// Things you might yell when invoking a rune
	var/static/list/possible_magic_words = list(
		list("*scream", "*scream", "*scream"),
		list("Abra...", "Cadabra...", "Alakazam!"),
		list("Azarath!", "Metrion!", "Zinthos!!"),
		list("Bibbity!", "Bobbity!", "Boo!"),
		list("Bish", "Bash", "Bosh!"),
		list("Eenie... ", "Meenie... ", "Minie'Mo!!"),
		list("Esaelp!", "Ouy Knaht!", "Em Esucxe!!"),
		list("Fus", "Roh", "Dah!!"),
		list("git checkout origin master", "git reset --hard HEAD~2", "git push origin master --force!!"),
		list("Hocus Pocus!", "Flim Flam!", "Wabbajack!"),
		list("I wish I may...", "I wish I might...", "Have this wish I wish tonight!"),
		list("Klaatu!", "Barada!", "Nikto!!"),
		list("Let expanse contract!", "Let eon become instant!", "Throw wide the gates!!"),
		list("Levios!", "Graviole!", "Explomb!!"),
		list("Micrato", "Raepij", "Sathonich!"),
		list("Noctu!", "Orfei!", "Aude! Fraetor!"),
		list("Quas!", "Wex!", "Exort!"),
		list("Sim!", "Sala!", "Bim!"),
		list("Seven shadows cast, seven fates foretold!", "Let their words echo in your empty soul!", "Ruination is come!!"),
		list("Swiftcast! Hastega! Abjurer's Ward II! Extend IV! Tenser's Advanced Enhancement! Protection from Good! Enhance Effect III! Arcane Re...",
			"...inforcement IV! Turn Vermin X! Protection from Evil II! Mage's Shield! Venerious's Mediocre Enhancement II! Expand Power! Banish Hu...",
			"...nger II! Protection from Neutral! Surecastaga! Refresh! Refresh II! Sharpcast X! Aetherial Manipulation! Ley Line Absorption! Invoke Grand Ritual!!"),
		list("Ten!", "Chi!", "Jin!"),
		list("Ultimate School of Magic!", "Ultimate Ritual!", "Macrocosm!!"),
		list("Y-abbaa", "Dab'Bah", "Doom!!"),
	)

/// Prepare magic words and hide from silicons
/obj/effect/grand_rune/Initialize(mapload, potency = 0)
	. = ..()
	src.potency = potency
	invoke_time = get_invoke_time()
	magic_words = pick(possible_magic_words)
	var/image/silicon_image = image(icon = 'icons/effects/eldritch.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "wizard_rune", silicon_image)
	announce_rune()

/// I cast Summon Security
/obj/effect/grand_rune/proc/announce_rune()
	var/area/created_area = get_area(src)
	if (potency >= GRAND_RITUAL_IMMINENT_FINALE_POTENCY)
		priority_announce("Major anomalous fluctuations to local spacetime detected in: [created_area.name].", "Anomaly Alert")
		return
	if (potency >= GRAND_RITUAL_RUNES_WARNING_POTENCY)
		priority_announce("Unusual anomalous energy fluctuations detected in: [created_area.name].", "Anomaly Alert")
		return

/obj/effect/grand_rune/examine(mob/user)
	. = ..()
	if (times_invoked >= GRAND_RUNE_INVOKES_TO_COMPLETE)
		. += span_notice("Its power seems to have been expended.")
		return
	if(!IS_WIZARD(user))
		return
	. += span_notice("Invoke this rune [GRAND_RUNE_INVOKES_TO_COMPLETE - times_invoked] more times to complete the ritual.")

/obj/effect/grand_rune/can_interact(mob/living/user)
	. = ..()
	if(!.)
		return
	if(!IS_WIZARD(user))
		return FALSE
	if(is_in_use)
		return FALSE
	if (times_invoked >= GRAND_RUNE_INVOKES_TO_COMPLETE)
		return FALSE
	return TRUE

/obj/effect/grand_rune/interact(mob/living/user)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(invoke_rune), user)
	return TRUE

/// Actually does the whole invoking thing
/obj/effect/grand_rune/proc/invoke_rune(mob/living/user)
	is_in_use = TRUE
	add_channel_effect(user)
	user.balloon_alert(user, "invoking rune...")
	if(!do_after(user, invoke_time, src))
		remove_channel_effect(user)
		user.balloon_alert(user, "interrupted!")
		is_in_use = FALSE
		return

	times_invoked++
	user.say(magic_words[times_invoked], forced = "grand ritual invocation")
	remove_channel_effect(user)

	for(var/obj/machinery/light/light in orange(4, src.loc))
		light.flicker()

	if(times_invoked >= GRAND_RUNE_INVOKES_TO_COMPLETE)
		on_invocation_complete(user)
		return
	flick("wizard_rune_flash", src)
	playsound(src,'sound/magic/staff_animation.ogg', 75, TRUE)
	INVOKE_ASYNC(src, PROC_REF(invoke_rune), user)

/// Add special effects for casting a spell, basically you glow and hover in the air.
/obj/effect/grand_rune/proc/add_channel_effect(mob/living/user)
	user.AddElement(/datum/element/forced_gravity, 0)
	user.add_filter("channeling_glow", 2, list("type" = "outline", "color" = spell_colour, "size" = 2))

/// Remove special effects for casting a spell
/obj/effect/grand_rune/proc/remove_channel_effect(mob/living/user)
	user.RemoveElement(/datum/element/forced_gravity, 0)
	user.remove_filter("channeling_glow")

/obj/effect/grand_rune/proc/get_invoke_time()
	return  (BASE_INVOKE_TIME) + (potency * (ADD_INVOKE_TIME))

/// Called when you actually finish the damn thing
/obj/effect/grand_rune/proc/on_invocation_complete(mob/living/user)
	is_in_use = FALSE
	playsound(src,'sound/magic/staff_change.ogg', 75, TRUE)
	INVOKE_ASYNC(src, PROC_REF(summon_round_event), user) // Running the event sleeps
	trigger_side_effects()
	tear_reality()
	SEND_SIGNAL(src, COMSIG_GRAND_RUNE_COMPLETE)
	flick("activate", src)
	addtimer(CALLBACK(src, PROC_REF(remove_rune)), 6)

/obj/effect/grand_rune/proc/remove_rune()
	new /obj/effect/decal/cleanable/grand_remains(get_turf(src))
	qdel(src)

/// Triggers some form of event somewhere on the station
/obj/effect/grand_rune/proc/summon_round_event(mob/living/user)
	var/list/possible_events = list()

	var/player_count = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	for(var/datum/round_event_control/possible_event as anything in SSevents.control)
		if (!possible_event.can_spawn_event(player_count, allow_magic = TRUE))
			continue
		if (possible_event.min_wizard_trigger_potency > potency)
			continue
		if (possible_event.max_wizard_trigger_potency < potency)
			continue
		possible_events += possible_event

	if (!length(possible_events))
		visible_message(span_notice("[src] makes a sad whizzing noise."))
		return

	var/datum/round_event_control/final_event = pick (possible_events)
	final_event.runEvent()
	to_chat(user, span_notice("Your released magic afflicts the crew: [final_event.name]!"))

/// Applies some local side effects to the area
/obj/effect/grand_rune/proc/trigger_side_effects(mob/living/user)
	if (potency == 0) // Not on the first one
		return
	var/list/possible_effects = list()
	for (var/effect_path in subtypesof(/datum/grand_side_effect))
		var/datum/grand_side_effect/effect = new effect_path()
		if (!effect.can_trigger(loc))
			continue
		possible_effects += effect

	var/datum/grand_side_effect/final_effect = pick(possible_effects)
	final_effect.trigger(potency, loc, user)

/**
 * Invoking the ritual spawns up to three reality tears based on potency.
 * Each of these has a 50% chance to spawn already expended.
 */
/obj/effect/grand_rune/proc/tear_reality()
	var/max_tears = 0
	switch(potency)
		if(0 to 2)
			max_tears = 1
		if (3 to 5)
			max_tears = 2
		if (6 to 7)
			max_tears = 3

	var/to_create = rand(0, max_tears)
	if (to_create == 0)
		return
	var/created = 0
	var/location_sanity = 0
	// Copied from the influences manager, but we don't want to obey the cap on influences per heretic.
	while(created < to_create && location_sanity < 100)
		var/turf/chosen_location = get_safe_random_station_turf()

		// We don't want them close to each other - at least 1 tile of seperation
		var/list/nearby_things = range(1, chosen_location)
		var/obj/effect/heretic_influence/what_if_i_have_one = locate() in nearby_things
		var/obj/effect/visible_heretic_influence/what_if_i_had_one_but_its_used = locate() in nearby_things
		if(what_if_i_have_one || what_if_i_had_one_but_its_used)
			location_sanity++
			continue

		var/obj/effect/heretic_influence/new_influence = new(chosen_location)
		if (prob(50))
			new_influence.after_drain()
		created++

#undef GRAND_RUNE_INVOKES_TO_COMPLETE

#undef BASE_INVOKE_TIME
#undef ADD_INVOKE_TIME

/**
 * Variant rune used for the Final Ritual
 */
/obj/effect/grand_rune/finale
	/// What does the player want to do?
	var/datum/grand_finale/finale_effect
	/// Has the player chosen an outcome?
	var/chosen_effect = FALSE
	/// If we need to warn the crew, have we done so?
	var/dire_warnings_given = 0

/obj/effect/grand_rune/finale/invoke_rune(mob/living/user)
	if(!finale_effect)
		return ..()
	if (!finale_effect.dire_warning)
		return ..()
	if (dire_warnings_given != times_invoked)
		return ..()
	var/area/created_area = get_area(src)
	var/announce = null
	switch (dire_warnings_given)
		if (0)
			announce = "Large anomalous energy spike detected in: [created_area.name]."
		if (1)
			announce = "Automatic causality stabilisation failed, recommend urgent intervention in: [created_area.name]."
		if (2)
			announce = "Imminent local reality failure in: [created_area.name]. All crew please prepare to evacuate."
	if (announce)
		priority_announce(announce, "Anomaly Alert")
	dire_warnings_given++
	return ..()

/obj/effect/grand_rune/finale/interact(mob/living/user)
	if (chosen_effect)
		return ..()
	select_finale(user)

#define PICK_NOTHING "Continuation"

/// Make a selection from a radial menu.
/obj/effect/grand_rune/finale/proc/select_finale(mob/living/user)
	var/list/options = list()
	var/list/picks_to_instances = list()
	for (var/typepath in subtypesof(/datum/grand_finale))
		var/datum/grand_finale/finale_type = new typepath()
		var/datum/radial_menu_choice/choice = finale_type.get_radial_choice()
		if (!choice)
			continue
		options += list("[choice.name]" = choice)
		picks_to_instances[choice.name] = finale_type

	var/datum/radial_menu_choice/choice_none = new()
	choice_none.name = PICK_NOTHING
	choice_none.image = image(icon = 'icons/mob/actions/actions_cult.dmi', icon_state = "draw")
	choice_none.info = "The ultimate use of your gathered power! They will never expect you to continue to do \
		exactly the same kind of thing you've been doing this whole time!"
	options += list("[choice_none.name]" = choice_none)

	var/pick = show_radial_menu(user, user, options, require_near = TRUE, tooltips = TRUE)
	if (!pick)
		return
	chosen_effect = TRUE
	if (pick == PICK_NOTHING)
		return
	finale_effect = picks_to_instances[pick]
	invoke_time = get_invoke_time()
	if (finale_effect.glow_colour)
		spell_colour = finale_effect.glow_colour

/obj/effect/grand_rune/finale/summon_round_event(mob/living/user)
	if (!finale_effect)
		return ..()
	finale_effect.trigger(user)

/obj/effect/grand_rune/finale/get_invoke_time()
	if (!finale_effect)
		return ..()
	return finale_effect.ritual_invoke_time

/**
 * Spawned when we are done with the rune
 */
/obj/effect/decal/cleanable/grand_remains
	name = "circle of ash"
	desc = "Looks like someone's been drawing weird shapes with ash on the ground."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "wizard_rune_burned"
	pixel_x = -28
	pixel_y = -34
	anchored = TRUE
	mergeable_decal = FALSE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	clean_type = CLEAN_TYPE_HARD_DECAL
	layer = SIGIL_LAYER
