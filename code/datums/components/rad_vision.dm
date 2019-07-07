/datum/component/rad_vision

/datum/component/rad_vision/Initialize()
	START_PROCESSING(SSradiation, src)

/datum/component/rad_vision/Destroy()
	STOP_PROCESSING(SSradiation, src)
	return ..()

/datum/component/rad_vision/process()
	show_rads()

/datum/component/rad_vision/proc/show_rads()
	var/mob/pvar
	pvar = parent
	var/mob/living/carbon/human/user = pvar.loc
	var/list/rad_places = list()
	for(var/datum/component/radioactive/thing in SSradiation.processing)
		var/atom/owner = thing.parent
		var/turf/place = get_turf(owner)
		if(rad_places[place])
			rad_places[place] += thing.strength
		else
			rad_places[place] = thing.strength

	for(var/i in rad_places)
		var/turf/place = i
		if(get_dist(user, place) > 2)	//Rads are easier to see than wires under the floor
			continue
		var/strength = round(rad_places[i] / 1000, 0.1)
		var/image/pic = new(loc = place)
		var/mutable_appearance/MA = new()
		MA.alpha = 180
		MA.maptext = "[strength]k"
		MA.color = "#64C864"
		MA.layer = FLY_LAYER
		pic.appearance = MA
		flick_overlay(pic, list(pvar.client), 8)
