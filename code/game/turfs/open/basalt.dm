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
		set_basalt_light(src)

/turf/open/misc/basalt/safe
	planetary_atmos = FALSE
