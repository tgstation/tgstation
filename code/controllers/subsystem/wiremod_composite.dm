/**
 * This subsystem is to handle creating and storing
 * composite templates that are used to create composite datatypes
 * for integrated circuits
 *
 * See: https://en.wikipedia.org/wiki/Composite_data_type
 **/
SUBSYSTEM_DEF(wiremod_composite)
	name = "Wiremod Composite Templates"
	flags = SS_NO_FIRE
	/// The templates created and stored
	var/list/templates = list()

/datum/controller/subsystem/wiremod_composite/PreInit()
	. = ..()
	// This needs to execute before global variables have initialized.
	for(var/datum/circuit_composite_template/type as anything in subtypesof(/datum/circuit_composite_template))
		if(!initial(type.datatype))
			continue
		templates[initial(type.datatype)] = new type()

/datum/controller/subsystem/wiremod_composite/Initialize()
	for(var/type in templates)
		var/datum/circuit_composite_template/template = templates[type]
		template.Initialize()
	return SS_INIT_SUCCESS

/**
 * Used to produce a composite datatype using another datatype, or
 * to get an already existing composite datatype.
 */
/datum/controller/subsystem/wiremod_composite/proc/composite_datatype(datatype, ...)
	var/datum/circuit_composite_template/type = templates[datatype]
	if(!type)
		return
	return type.generate_composite_type(args.Copy(2))

/datum/controller/subsystem/wiremod_composite/proc/get_composite_type(base_type, datatype)
	var/datum/circuit_composite_template/template = templates[base_type]
	if(!template)
		return
	return template.generated_types[datatype]
