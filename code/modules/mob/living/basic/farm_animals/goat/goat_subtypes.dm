/mob/living/basic/goat/pete // Pete!
	name = "Pete"
	gender = MALE

/mob/living/basic/goat/pete/Initialize(mapload)
	if(mapload && prob(40))
		new /mob/living/basic/goat/pete/petricia // woaw time for some udder
		return INITIALIZE_HINT_QDEL

	return ..()

/mob/living/basic/goat/pete/examine()
	. = ..()
	var/area/goat_area = get_area(src)
	if((bodytemperature < T20C) || istype(goat_area, /area/station/service/kitchen/coldroom))
		. += span_notice("[p_They()] [p_do()]n't seem to be too bothered about the cold.") // special for pete

/mob/living/basic/goat/pete/petricia // A female Pete!
	name = "Petricia"
	gender = FEMALE
