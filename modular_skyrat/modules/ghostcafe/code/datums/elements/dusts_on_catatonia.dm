/datum/element/dusts_on_catatonia
	element_flags = ELEMENT_DETACH
	var/list/mob/attached_mobs = list()

/datum/element/dusts_on_catatonia/Attach(datum/target,penalize = FALSE)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/M = target
	if(!(M in attached_mobs))
		attached_mobs += M
	START_PROCESSING(SSprocessing,src)

/datum/element/dusts_on_catatonia/Detach(mob/M)
	. = ..()
	if(M in attached_mobs)
		attached_mobs -= M
	if(!attached_mobs.len)
		STOP_PROCESSING(SSprocessing,src)

/datum/element/dusts_on_catatonia/process()
	for(var/m in attached_mobs)
		var/mob/living/M = m
		if(!M.key && !M.get_ghost())
			M.dust(TRUE, force = TRUE)
			Detach(M)
