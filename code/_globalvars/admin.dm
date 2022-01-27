GLOBAL_LIST_EMPTY(stickybanadminexemptions) //stores a list of ckeys exempted from a stickyban (workaround for a bug)
GLOBAL_LIST_EMPTY(stickybanadmintexts) //stores the entire stickyban list temporarily
GLOBAL_VAR(stickbanadminexemptiontimerid) //stores the timerid of the callback that restores all stickybans after an admin joins

/proc/init_smites()
	var/list/smites = list()
	for (var/_smite_path in subtypesof(/datum/smite))
		var/datum/smite/smite_path = _smite_path
		smites[initial(smite_path.name)] = smite_path
	return smites

GLOBAL_LIST_INIT_TYPED(smites, /datum/smite, init_smites())

GLOBAL_VAR_INIT(admin_notice, "") // Admin notice that all clients see when joining the server
