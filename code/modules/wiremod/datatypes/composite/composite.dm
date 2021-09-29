// An assoc list of all the possible datatypes.
GLOBAL_LIST_INIT_TYPED(circuit_composite_templates, /datum/circuit_composite_template, generate_circuit_composite_templates())

/proc/generate_circuit_composite_templates()
	var/list/datatypes_by_key = list()
	for(var/datum/circuit_datatype/type as anything in subtypesof(/datum/circuit_composite_template))
		if(!initial(type.datatype))
			continue
		datatypes_by_key[initial(type.datatype)] = new type()
	return datatypes_by_key

/datum/circuit_composite_template
	/// The datatype this composite template is of.
	var/datatype
	/// The path to the composite type
	var/composite_datatype_path

/datum/circuit_composite_template/proc/generate_composite_type(list/composite_datatypes)
	var/new_datatype = "[datatype]<[composite_datatypes.Join(", ")]>"

	if(GLOB.circuit_datatypes[new_datatype])
		return new_datatype
	for(var/datatype_to_check in composite_datatypes)
		if(!GLOB.circuit_datatypes[datatype_to_check])
			CRASH("Attempted to form an invalid composite datatype using datatypes that don't exist! (got [datatype_to_check], expected a valid datatype)")
	GLOB.circuit_datatypes[new_datatype] = new composite_datatype_path(new_datatype, composite_datatypes)
	return new_datatype

/**
 * Used to produce a composite datatype using another datatype, or
 * to get an already existing composite datatype.
 */
/proc/composite_datatype(datatype, ...)
	var/datum/circuit_composite_template/type = GLOB.circuit_composite_templates[datatype]
	if(!type)
		return
	return type.generate_composite_type(args.Copy(2))


/datum/circuit_datatype/composite_instance
	datatype_flags = DATATYPE_FLAG_COMPOSITE
	abstract = TRUE
	var/list/composite_datatypes = list()

/datum/circuit_datatype/composite_instance/New(datatype, list/composite_datatypes)
	. = ..()
	if(!datatype || !composite_datatypes)
		return

	src.datatype = datatype
	src.composite_datatypes = composite_datatypes
	src.abstract = FALSE

/datum/circuit_datatype/composite_instance/get_datatypes()
	return composite_datatypes
