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

	// This station trait modifies the atmosphere, which is too far past the time admins are able to revert it
	can_revert = FALSE

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

		// Makes this station trait more interesting. Ian probably won't go anywhere without a little external help.
		// Also gives him a couple extra lives to survive eventual tiders.
		dog.deadchat_plays(DEMOCRACY_MODE|MUTE_DEMOCRACY_MESSAGES, 3 SECONDS)
		dog.AddComponent(/datum/component/multiple_lives, 2)
		RegisterSignal(dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, .proc/do_corgi_respawn)

		// The extended safety checks at time of writing are about chasms and lava
		// if there are any chasms and lava on stations in the future, woah
		var/turf/current_turf = get_turf(dog)
		var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

		// Poof!
		do_smoke(location=current_turf)
		dog.forceMove(adventure_turf)
		do_smoke(location=adventure_turf)

/// Moves the new dog somewhere safe, equips it with the old one's inventory and makes it deadchat_playable.
/datum/station_trait/ian_adventure/proc/do_corgi_respawn(mob/living/simple_animal/pet/dog/corgi/old_dog, mob/living/simple_animal/pet/dog/corgi/new_dog, gibbed, lives_left)
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(new_dog)
	var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

	do_smoke(location=current_turf)
	new_dog.forceMove(adventure_turf)
	do_smoke(location=adventure_turf)

	if(old_dog.inventory_back)
		var/obj/item/old_dog_back = old_dog.inventory_back
		old_dog.inventory_back = null
		old_dog_back.forceMove(new_dog)
		new_dog.inventory_back = old_dog_back

	if(old_dog.inventory_head)
		var/obj/item/old_dog_hat = old_dog.inventory_head
		old_dog.inventory_head = null
		new_dog.place_on_head(old_dog_hat)

	new_dog.update_corgi_fluff()
	new_dog.regenerate_icons()
	new_dog.deadchat_plays(DEMOCRACY_MODE|MUTE_DEMOCRACY_MESSAGES, 3 SECONDS)
	if(lives_left)
		RegisterSignal(new_dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, .proc/do_corgi_respawn)

	if(!gibbed) //The old dog will now disappear so we won't have more than one Ian at a time.
		qdel(old_dog)

/datum/station_trait/glitched_pdas
	name = "PDA glitch"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 15
	show_in_report = TRUE
	report_message = "Something seems to be wrong with the PDAs issued to you all this shift. Nothing too bad though."
	trait_to_give = STATION_TRAIT_PDA_GLITCHED

/datum/station_trait/announcement_intern
	name = "Announcement Intern"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Please be nice to him."
	blacklist = list(/datum/station_trait/announcement_medbot)

/datum/station_trait/announcement_intern/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/intern

/datum/station_trait/announcement_medbot
	name = "Announcement \"System\""
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 1
	show_in_report = TRUE
	report_message = "Our announcement system is under scheduled maintanance at the moment. Thankfully, we have a backup."
	blacklist = list(/datum/station_trait/announcement_intern)

/datum/station_trait/announcement_medbot/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/medbot

/datum/station_trait/colored_assistants
	name = "Colored Assistants"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 10
	show_in_report = TRUE
	report_message = "Due to a shortage in standard issue jumpsuits, we have provided your assistants with one of our backup supplies."

/datum/station_trait/colored_assistants/New()
	. = ..()

	var/new_colored_assistant_type = pick(subtypesof(/datum/colored_assistant) - get_configured_colored_assistant_type())
	GLOB.colored_assistant = new new_colored_assistant_type


/**
 * Station traits that guarantee some ruin spawn.
 */
/datum/station_trait/ruin_spawn
	name = "Ruin Spawn"
	trait_type = STATION_TRAIT_ABSTRACT
	/// The map template to guarantee a spawn of.
	var/datum/map_template/ruin/ruin_path
	/// The z-level theme to spawn the ruin on.
	var/ruin_theme
	/// Whether to allow duplicates of the ruin to spawn. If null it has no affect.
	var/allow_duplicates
	/// Whether to prevent the ruin from spawning. If null it has no affect.
	var/prevent_spawn
	/// Whether to ensure that the ruin spawns. If null it has no affect.
	var/ensure_spawn
	/// What to set the cost of the ruin to. If null it has no affect.
	var/override_cost

/datum/station_trait/ruin_spawn/New()
	. = ..()
	if(!ispath(ruin, /datum/map_template/ruin) || !ruin_theme)
		stack_trace("A ruin spawn station trait without a ruin or ruin theme was loaded.")
		return

	RegisterSignal(SSmapping, COMSIG_MAPPING_PRELOADING_RUINS, .proc/modify_ruin)

/**
 * Modifies the ruin this station trait targets.
 *
 * Arguments:
 * - [source][/datum/controller/subsystem/mapping]:
 * - [map_templates][/list]:
 * - [ruin_templates][/list]:
 * - [themed_ruins][/list]: A set of lists of ruins indexed by z-level trait.
 */
/datum/station_trait/ruin_spawn/proc/modify_ruin(datum/controller/subsystem/mapping/source, list/map_templates, list/ruin_templates, list/themed_ruins)
	SIGNAL_HANDLER
	var/datum/map_template/ruin/ruin = ruin_templates[initial(ruin_path.name)]
	if(!ruin)
		stack_trace("A ruin spawn station trait could not fetch the target ruin.")
		return

	if(!isnull(ruin_theme) && ruin_theme != ruin.ruin_type)
		var/list/themes = islist(ruin.ruin_type) ? ruin.ruin_type : list(ruin.ruin_type)
		for(var/theme in themes)
			themed_ruins[ruin.ruin_type] -= ruin.name

		ruin.ruin_type = ruin_theme

		themes = islist(ruin.ruin_type) ? ruin.ruin_type : list(ruin.ruin_type)
		for(var/theme in themes)
			themed_ruins[ruin.ruin_type][ruin.name] = ruin

	if(!isnull(allow_duplicates))
		ruin.allow_duplicates = allow_duplicates
	if(!isnull(prevent_spawn))
		ruin.unpickable = prevent_spawn
	if(!isnull(ensure_spawn))
		ruin.always_place = ensure_spawn
	if(!isnull(override_cost))
		ruin.cost = override_cost
