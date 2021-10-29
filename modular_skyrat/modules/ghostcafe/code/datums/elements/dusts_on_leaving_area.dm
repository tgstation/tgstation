/datum/element/dusts_on_leaving_area
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2
	var/list/area_types = list()

/datum/element/dusts_on_leaving_area/Attach(datum/target,types)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE
	area_types = types
	RegisterSignal(target,COMSIG_ENTER_AREA,.proc/check_dust)

/datum/element/dusts_on_leaving_area/Detach(mob/M)
	. = ..()
	UnregisterSignal(M,COMSIG_ENTER_AREA)

/datum/element/dusts_on_leaving_area/proc/check_dust(datum/source, area/A)
	SIGNAL_HANDLER
	var/mob/living/M = source
	if(istype(M) && !(A.type in area_types))
		M.dust(TRUE, force = TRUE)
