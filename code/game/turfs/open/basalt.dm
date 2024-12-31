/turf/open/misc/basalt
	gender = NEUTER
	name = "volcanic floor"
	desc = "Rough volcanic floor that can be dug up for basalt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	initial_gas_mix = OPENTURF_LOW_PRESSURE

/turf/open/misc/basalt/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/diggable, /obj/item/stack/ore/glass/basalt, 2)
	if(prob(15))
		icon_state = "basalt[rand(0, 12)]"
		switch(icon_state)
			if("basalt1", "basalt2", "basalt3")
				set_light(BASALT_LIGHT_RANGE_BRIGHT, BASALT_LIGHT_POWER, LIGHT_COLOR_LAVA)
			if("basalt5", "basalt9")
				set_light(BASALT_LIGHT_RANGE_DIM, BASALT_LIGHT_POWER, LIGHT_COLOR_LAVA)

/turf/open/misc/basalt/safe
	planetary_atmos = FALSE
