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

//this init is handled far differently than others. it parses data from the DB for information about the unusual itself
//it than loads this info into the component itself, the particle_path is purely for spawning temporary ones in round
/datum/component/unusual_handler/Initialize(list/parsed_variables = list(), particle_path = /datum/component/particle_spewer/confetti)
	. = ..()
	if(!length(parsed_variables))
		src.particle_path = particle_path
	else
		setup_from_list(parsed_variables)

	source_object = parent

	source_object.AddComponent(particle_path)
	
	source_object.desc += span_notice("\n Unboxed by: [original_owner_ckey]")
	source_object.desc += span_notice("\n Unboxed on: [round_id]")
	source_object.desc += span_notice("\n Unusual Type: [unusual_description]")
	
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
	return

/obj/item/clothing/head/costume/chicken/confetti_unusual/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/unusual_handler)

/obj/item/clothing/head/costume/chicken/snow_unusual/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/unusual_handler, particle_path = /datum/component/particle_spewer/snow)

