/mob/living/basic/goat/peta // Peta!
	name = "Peta"
	gender = FEMALE

/mob/living/basic/goat/peta/examine()
	. = ..()
	var/area/goat_area = get_area(src)
	if((bodytemperature < T20C) || istype(goat_area, /area/station/service/kitchen/coldroom))
		. += span_notice("[p_They()] [p_do()]n't seem to be too bothered about the cold.") // special for peta

