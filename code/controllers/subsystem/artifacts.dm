/proc/spawn_artifact(turf/loc,var/forced_origin)
	if (!loc)
		return

	var/list/weighted_list
	if(forced_origin)
		weighted_list = SSartifacts.artifact_rarities[forced_origin]
	else
		weighted_list = SSartifacts.artifact_rarities["all"]
	
	var/type = pick_weight(weighted_list).associated_object
	return new type(loc)

/// Subsystem for managing artifacts.
SUBSYSTEM_DEF(artifacts)
	name = "Artifacts"

	flags = SS_NO_FIRE | SS_NO_INIT

	///instances of object artifacts
	var/list/artifacts = list()
	///artifact comp instances
	var/list/datum/component/artifact/artifact_types = list()
	//var/list/artifact_types_from_name = list()
	/// instances of origins
	var/list/artifact_origins = list()
	var/list/artifact_origins_by_name = list()
	/// artifact rarities for weighted picking
	var/list/artifact_rarities = list()

/datum/controller/subsystem/artifacts/New()
	..()
	artifact_rarities["all"] = list()

	// origin list
	for (var/origin_type in subtypesof(/datum/artifact_origin))
		var/datum/artifact_origin/origin = new origin_type
		artifact_origins += origin
		artifact_origins_by_name[origin.type_name] = origin
		artifact_rarities[origin.type_name] = list()
	for (var/artifact_type in subtypesof(/datum/component/artifact))
		var/datum/component/artifact/artifact = new artifact_type
		artifact_types += artifact
		//artifact_types_from_name[artifact.type_name] = artifact

		artifact_rarities["all"][artifact] = artifact.weight
		for (var/origin in artifact_rarities)
			if(origin in artifact.valid_origins)
				artifact_rarities[origin][artifact] = artifact.weight