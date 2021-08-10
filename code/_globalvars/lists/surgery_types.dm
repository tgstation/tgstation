///assoc list of surgery names = their type
GLOBAL_LIST_INIT(surgeries_list, generate_global_surgeries())

///creates the surgeries_list global
/proc/generate_global_surgeries()
	var/list/surgeries = list()
	for(var/datum/component/surgery/surgery_type in subtypesof(/datum/component/surgery))
		surgery_type = SSdcs.AddComponent(surgery_type)
		surgeries[initial(surgery_type.name)] = surgery_type
	return surgeries
