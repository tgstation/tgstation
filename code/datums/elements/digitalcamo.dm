/datum/element/digitalcamo
	element_flags = ELEMENT_DETACH
	var/list/attached_mobs = list()

/datum/element/digitalcamo/New()
	. = ..()
	START_PROCESSING(SSdcs, src)

/datum/element/digitalcamo/Attach(datum/target)
	. = ..()
	if(!isliving(target) || target in attached_mobs)
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(target, COMSIG_LIVING_CAN_TRACK, .proc/can_track)
	var/image/img = image(loc = target)
	img.override = TRUE
	attached_mobs[target] = img

/datum/element/digitalcamo/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_PARENT_EXAMINE, COMSIG_LIVING_CAN_TRACK))
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		AI.client.images -= attached_mobs[target]
	attached_mobs -= target

/datum/element/digitalcamo/proc/on_examine(datum/source, mob/M)
	to_chat(M, "<span class = 'warning'>[source.p_they()] [source.p_are()] moving [source.p_their()] body in an unnatural and blatantly inhuman manner.</span>")

/datum/element/digitalcamo/proc/can_track(datum/source)
	return COMPONENT_CANT_TRACK

/datum/element/digitalcamo/process()
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		for(var/mob in attached_mobs)
			AI.client.images |= attached_mobs[mob]
