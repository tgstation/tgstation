SUBSYSTEM_DEF(disease)
	name = "Disease"
	flags = SS_NO_FIRE

	var/list/active_diseases = list() //List of Active disease in all mobs; purely for quick referencing.
	var/list/diseases
	var/list/archive_diseases = list()

	var/list/list_symptoms_type
	var/list/symp_list = list()

/datum/controller/subsystem/disease/PreInit()
	if(!diseases)
		diseases = subtypesof(/datum/disease)
	if(!list_symptoms_type)
		list_symptoms_type = subtypesof(/datum/symptom)

/datum/controller/subsystem/disease/Initialize(timeofday)
	var/list/all_common_diseases = diseases - typesof(/datum/disease/advance)
	for(var/common_disease_type in all_common_diseases)
		var/datum/disease/prototype = new common_disease_type()
		archive_diseases[prototype.GetDiseaseID()] = prototype
	for(var/symp_type in list_symptoms_type)
		var/datum/symptom/symptom = new symp_type
		symp_list[symp_type] = symptom

	return ..()

/datum/controller/subsystem/disease/stat_entry(msg)
	..("P:[active_diseases.len]")

/datum/controller/subsystem/disease/proc/get_disease_name(id)
	var/datum/disease/advance/A = archive_diseases[id]
	if(A.name)
		return A.name
	else
		return "Unknown"
