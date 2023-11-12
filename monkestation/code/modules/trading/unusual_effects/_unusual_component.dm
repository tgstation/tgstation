/datum/component/unusual_handler
	var/atom/source_object
	///the description added to the unusual.
	var/unusual_description = "Not Implemented Yet Teehee"
	///the round the unusual was created at
	var/round_id = 0
	///the particle spewer component path
	var/particle_path = /datum/component/particle_spewer/confetti
	/// The original owners name
	var/original_owner_ckey = "dwasint"
	/// the slot this item goes in used when creating the particle itself
	var/unusual_equip_slot = ITEM_SLOT_HEAD
	/// the icon_state of the overlay given to unusals
	var/unusal_overlay = "none"

//this init is handled far differently than others. it parses data from the DB for information about the unusual itself
//it than loads this info into the component itself, the particle_path is purely for spawning temporary ones in round
/datum/component/unusual_handler/Initialize(list/parsed_variables = list(), particle_path = /datum/component/particle_spewer/confetti, fresh_unusual = FALSE, client_ckey = "dwasint")
	. = ..()
	if(!length(parsed_variables))
		src.particle_path = particle_path
	else
		setup_from_list(parsed_variables)

	if(fresh_unusual)
		original_owner_ckey = client_ckey
		round_id = text2num(GLOB.round_id)
	source_object = parent

	source_object.AddComponent(src.particle_path)

	if(!length(parsed_variables))
		var/datum/component/particle_spewer/created = source_object.GetComponent(/datum/component/particle_spewer)
		unusual_description = created.unusual_description

	source_object.desc += span_notice("\n Unboxed by: [original_owner_ckey]")
	source_object.desc += span_notice("\n Unboxed on round: [round_id]")
	source_object.desc += span_notice("\n Unusual Type: [unusual_description]")

	source_object.name = "unusual [unusual_description] [source_object.name]"

	RegisterSignal(source_object, COMSIG_ATOM_UPDATE_DESC, PROC_REF(append_unusual))

/datum/component/unusual_handler/Destroy(force, silent)
	. = ..()
	UnregisterSignal(source_object, COMSIG_ATOM_UPDATE_DESC)

/datum/component/unusual_handler/proc/append_unusual(atom/source, updates)
	SIGNAL_HANDLER
	source_object.desc += span_notice("\n Unboxed by: [original_owner_ckey]")
	source_object.desc += span_notice("\n Unboxed on: [round_id]")
	source_object.desc += span_notice("\n Unusual Type: [unusual_description]")

/datum/component/unusual_handler/proc/setup_from_list(list/parsed_results)
	particle_path = text2path(parsed_results["type"])
	round_id = text2num(parsed_results["round"])
	original_owner_ckey = parsed_results["original_owner"]
	unusual_description = parsed_results["description"]
	unusual_equip_slot = text2num(parsed_results["equipslot"])
	unusal_overlay = parsed_results["item_overlay"]

/obj/item/clothing/head/costume/chicken/confetti_unusual/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/unusual_handler)

/obj/item/clothing/head/costume/chicken/snow_unusual/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/unusual_handler, particle_path = /datum/component/particle_spewer/snow)

/obj/item/clothing/head/costume/chicken/galaxies_unusual/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/unusual_handler, particle_path = /datum/component/particle_spewer/galaxies)

