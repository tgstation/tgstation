/datum/component/wound_converter
	///What priority does this converter have, higher priority will override lower priority converters if they both try and act on the same wound
	var/priority = 0

	var/list/exact_type_conversions = list()

	var/list/general_type_conversions = list()
	///Assoc list of wounds with values of their highest handled priority
	var/static/list/wounds_to_convert = list()

/datum/component/wound_converter/Initialize(priority = 0, exact_type_conversions = list(), general_type_conversions = list())
	if(!iscarbon(parent) && !isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.priority = priority
	src.exact_type_conversions = exact_type_conversions
	src.general_type_conversions = general_type_conversions

/datum/component/wound_converter/RegisterWithParent()
	if(iscarbon(parent))
//		RegisterSignal(parent, COMSIG_PRE_CARBON_GAIN_WOUND, PROC_REF(on_pre_wound))
		return
	if(istype(parent, /obj/item/bodypart))
		return

/datum/component/wound_converter/Destroy(force, silent)
	. = ..()
	//var/eee = exact_type_conversions[item] || general_type_conversions[item]

/datum/component/wound_converter/proc/on_pre_wound()
	SIGNAL_HANDLER
	return
