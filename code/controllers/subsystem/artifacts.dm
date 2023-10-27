
/proc/spawn_artifact(turf/loc, forced_origin)
	if (!loc)
		return

	var/list/datum/component/artifact/weighted_list
	if(forced_origin)
		weighted_list = SSartifacts.artifact_rarities[forced_origin]
	else
		weighted_list = SSartifacts.artifact_rarities["all"]

	var/type = initial(pick_weight(weighted_list).associated_object)
	return new type(loc)


/// Subsystem for managing artifacts.
SUBSYSTEM_DEF(artifacts)
	name = "Artifacts"

	flags = SS_NO_FIRE | SS_NO_INIT

	///Currently existing artifacts with a component (key = obj artifact, value = component artifact)
	var/list/artifacts = list()
	/// typepaths of artifact components
	var/list/datum/component/artifact/artifact_types = list()
	/// names of all artifact subtype type_name
	var/list/artifact_type_names = list()
	/// artifact typepath from type_name
	var/list/artifact_types_from_name = list()
	/// instances of origins
	var/list/artifact_origins = list()
	/// assoc list of origin type name to instance
	var/list/artifact_origins_by_typename = list()
	/// assoc list of IC name to origin typename
	var/list/artifact_origin_name_to_typename = list()
	/// list of IC origin names
	var/list/artifact_origins_names = list()
	/// artifact rarities for weighted picking
	var/list/artifact_rarities = list()
	/// get an artifact trigger typepath by name
	var/list/artifact_trigger_name_to_type = list()

/datum/controller/subsystem/artifacts/New()
	..()
	artifact_rarities["all"] = list()

	// origin list
	for (var/origin_type in subtypesof(/datum/artifact_origin))
		var/datum/artifact_origin/origin = new origin_type
		artifact_origins += origin
		artifact_origins_names += origin.name
		artifact_origin_name_to_typename[origin.name] = origin.type_name
		artifact_origins_by_typename[origin.type_name] = origin
		artifact_rarities[origin.type_name] = list()
	for (var/datum/component/artifact/artifact_type as anything in subtypesof(/datum/component/artifact))
		var/weight = initial(artifact_type.weight)
		if(!weight)
			continue
		artifact_types += artifact_type
		artifact_type_names += initial(artifact_type.type_name)
		artifact_types_from_name[initial(artifact_type.type_name)] = artifact_type

		artifact_rarities["all"][artifact_type] = weight
		for (var/origin in artifact_rarities)
			if(origin in initial(artifact_type.valid_origins))
				artifact_rarities[origin][artifact_type] = weight
	for (var/datum/artifact_trigger/trigger_type as anything in subtypesof(/datum/artifact_trigger))
		artifact_trigger_name_to_type[initial(trigger_type.name)] = trigger_type
