GLOBAL_LIST_EMPTY(acid_geysers)

/obj/structure/terrain
	name = "generic terrain feature"
	desc = "Extremely generic."
	layer = ABOVE_ALL_MOB_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/lavaland/terrain.dmi'

/obj/structure/terrain/Initialize(mapload)
	. = ..()
	for(var/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ChangeTurf(M.turf_type, null, CHANGETURF_IGNORE_AIR)

/obj/structure/terrain/geyser
	name = "acid geyser"
	desc = "A dormant geyser. It seems to be dripping acid."
	icon_state = "acid_geyser"

/obj/structure/terrain/geyser/Initialize()
	. = ..()
	GLOB.acid_geysers |= src

/obj/structure/terrain/geyser/Destroy()
	GLOB.acid_geysers -= src
	. = ..()

/obj/structure/terrain/geyser/proc/tremors()
	visible_message("<span class='warning'>[src] rumbles...</span>")
	flick("acid_spill", src)
	addtimer(CALLBACK(src, .proc/spill_smoke), rand(30, 90))

/obj/structure/terrain/geyser/proc/spill_smoke()
	visible_message("<span class='warning'>A cloud of acid smoke bursts out of [src]!</span>")
	var/datum/reagents/R = new/datum/reagents(1000)
	R.my_atom = src
	R.add_reagent("sacid", 1000)
	var/datum/effect_system/smoke_spread/chem/smoke = new
	smoke.set_up(R, 6, get_turf(src), silent = TRUE, _spread_delay = 20)
	smoke.start()
	qdel(R)