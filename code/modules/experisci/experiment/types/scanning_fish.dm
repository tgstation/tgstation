///a superlist containing typecaches shared between the several fish scanning experiments for each techweb.
GLOBAL_LIST_EMPTY(scanned_fish_by_techweb)

/**
 * A special scanning experiment that unlocks further settings for the fishing portal generator.
 * Mainly as an inventive solution to many a fish source being limited to maps that have it,
 * and to make the fishing portal generator a bit than just gubby and goldfish.
 */
/datum/experiment/scanning/fish
	name = "Fish Scanning Experiment 1"
	description = "An experiment requiring different fish species to be scanned to unlock the 'Beach' setting for the fishing portal generator."
	performance_hint = "Scan fish. Examine scanner to review progress. Unlock new fishing portals."
	allowed_experimentors = list(/obj/item/experi_scanner, /obj/machinery/destructive_scanner, /obj/item/fishing_rod/tech, /obj/item/fish_analyzer)
	traits = EXPERIMENT_TRAIT_TYPECACHE
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS )
	required_atoms = list(/obj/item/fish = 4)
	scan_message = "Scan different species of fish"
	///Further experiments added to the techweb when this one is completed.
	var/list/next_experiments = list(/datum/experiment/scanning/fish/second)
	///Completing a experiment may also enable a fish source to be used for use for the portal generator.
	var/fish_source_reward = /datum/fish_source/portal/beach

/**
 * We make sure the scanned list is shared between all fish scanning experiments for this techweb,
 * since this is about scanning each species, and having to redo it for each species is a hassle.
 */
/datum/experiment/scanning/fish/New(datum/techweb/techweb)
	. = ..()
	if(isnull(techweb))
		return
	var/techweb_ref = REF(techweb)
	var/list/scanned_fish = GLOB.scanned_fish_by_techweb[techweb_ref]
	if(isnull(scanned_fish))
		scanned_fish = list()
		GLOB.scanned_fish_by_techweb[techweb_ref] = scanned_fish
	for(var/atom_type in required_atoms)
		LAZYINITLIST(scanned_fish[atom_type])
	scanned = scanned_fish

/**
 * Registers a couple signals to review the fish scanned so far.
 * It'd be an hassle not having any way (beside memory) to know which fish species have been scanned already otherwise.
 */
/datum/experiment/scanning/fish/on_selected(datum/component/experiment_handler/experiment_handler)
	RegisterSignal(experiment_handler.parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_handler_examine))
	RegisterSignal(experiment_handler.parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_handler_examine_more))

/datum/experiment/scanning/fish/on_unselected(datum/component/experiment_handler/experiment_handler)
	UnregisterSignal(experiment_handler.parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_EXAMINE_MORE))

/datum/experiment/scanning/fish/proc/on_handler_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Examine again to review all the species of fish scanned so far.")

/datum/experiment/scanning/fish/proc/on_handler_examine_more(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/message = span_notice("Fish species scanned hitherto, if any:")
	message += "<span class='info ml-1'>"
	for(var/atom_type in required_atoms)
		for(var/obj/item/fish/fish_path as anything in scanned[atom_type])
			message += "\n[initial(fish_path.name)]"
	message += "</span>"
	examine_list += message

///Only scannable fish will contribute towards the experiment.
/datum/experiment/scanning/fish/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, obj/item/fish/target, typepath)
	return target.experisci_scannable

/**
 * After a fish scanning experiment is done, more may be unlocked. If so, add them to the techweb
 * and automatically link the handler to the next experiment in the list as a bit of qol.
 */
/datum/experiment/scanning/fish/finish_experiment(datum/component/experiment_handler/experiment_handler, ...)
	. = ..()
	if(next_experiments)
		experiment_handler.linked_web.add_experiments(next_experiments)
		var/datum/experiment/next_in_line = locate(next_experiments[1]) in experiment_handler.linked_web.available_experiments
		experiment_handler.link_experiment(next_in_line)

/datum/experiment/scanning/fish/second
	name = "Fish Scanning Experiment 2"
	description = "An experiment requiring more fish species to be scanned to unlock the 'Chasm' setting for the fishing portal."
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS )
	required_atoms = list(/obj/item/fish = 8)
	next_experiments = list(/datum/experiment/scanning/fish/third)
	fish_source_reward = /datum/fish_source/portal/chasm

/datum/experiment/scanning/fish/third
	name = "Fish Scanning Experiment 3"
	description = "An experiment requiring even more fish species to be scanned to unlock the 'Ocean' setting for the fishing portal."
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS )
	required_atoms = list(/obj/item/fish = 14)
	next_experiments = list(/datum/experiment/scanning/fish/fourth, /datum/experiment/scanning/fish/holographic)
	fish_source_reward = /datum/fish_source/portal/ocean

/datum/experiment/scanning/fish/holographic
	name = "Holographic Fish Scanning Experiment"
	description = "This one actually requires holographic fish to unlock the 'Randomizer' setting for the fishing portal."
	performance_hint = "Load in the 'Beach' template at the Holodeck to fish some holo-fish."
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS )
	required_atoms = list(/obj/item/fish/holo = 4)
	scan_message = "Scan different species of holographic fish"
	next_experiments = null
	fish_source_reward = /datum/fish_source/portal/random

///holo fishes are normally unscannable, but this is an experiment for them, so we don't care for the experisci_scannable variable.
/datum/experiment/scanning/fish/holographic/final_contributing_index_checks(datum/component/experiment_handler/experiment_handler, obj/item/fish/target, typepath)
	return TRUE

/datum/experiment/scanning/fish/fourth
	name = "Fish Scanning Experiment 4"
	description = "An experiment requiring lotsa fish species to unlock the 'Hyperspace' setting for the fishing portal."
	points_reward = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS )
	required_atoms = list(/obj/item/fish = 21)
	next_experiments = null
	fish_source_reward = /datum/fish_source/portal/hyperspace
