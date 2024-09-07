// Bonfires but with a grill pre-attached

/obj/structure/bonfire/grill_pre_attached

/obj/structure/bonfire/grill_pre_attached/Initialize(mapload)
	. = ..()

	grill = TRUE
	add_overlay("bonfire_grill")

// Dirt but icebox and also farmable

/turf/open/misc/dirt/icemoon
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = "ICEMOON_ATMOS"

/turf/open/misc/dirt/icemoon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_farm, set_plant = TRUE)

// Water that can be fished out of

/turf/open/water/hot_spring
	desc = "Water kept warm through some unknown heat source, possibly a geothermal heat source far underground. \
		Whatever it is, it feels pretty damn nice to swim in given the rest of the environment around here, and you \
		can even catch a glimpse of the odd fish darting through the water."
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = "ICEMOON_ATMOS"
	/// Holder for the steam particles that show up sometimes
	var/obj/effect/abstract/particle_holder/particle_effect

/turf/open/water/hot_spring/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/icecat_hot_spring)
	if(prob(60))
		particle_effect = new(src, /particles/hotspring_steam)

/turf/open/water/hot_spring/Destroy()
	QDEL_NULL(particle_effect)
	return ..()

/turf/open/water/hot_spring/Entered(atom/movable/arrived)
	..()
	wash_atom(arrived)
	wash_atom(loc)

/// Cleans the given atom of whatever dirties it
/turf/open/water/hot_spring/proc/wash_atom(atom/nasty)
	nasty.wash(CLEAN_WASH)

/turf/open/water/hot_spring/Entered(atom/movable/arrived)
	..()
	if(istype(arrived, /mob/living))
		hotspring_mood(arrived)

/// Applies the hot water mood buff on the passed mob
/turf/open/water/hot_spring/proc/hotspring_mood(mob/living/swimmer)
	swimmer.add_mood_event("hotspring", /datum/mood_event/hotspring/nerfed)

/datum/mood_event/hotspring/nerfed
	description = span_nicegreen("The water was enjoyably warm!\n")
	mood_change = 2

// Steam particles for pairing with the hotsprings above

/particles/hotspring_steam
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list(
		"steam_1" = 2,
		"steam_2" = 2,
		"steam_3" = 1,
	)
	width = 64
	height = 64
	count = 5
	spawning = 0.2
	lifespan = 1 SECONDS
	fade = 0.5 SECONDS
	color = "#ffffff"
	position = generator(GEN_BOX, list(-32,-32,0), list(32,32,0), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.9,0.9), list(1.1,1.1), NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-0.1,0), list(0.1,0.025), UNIFORM_RAND)
	spin = generator(GEN_NUM, list(-15,15), NORMAL_RAND)

// Fishing source for the above water turfs

/datum/fish_source/icecat_hot_spring
	fish_table = list(
		/obj/item/fish/dwarf_moonfish = 5,
		/obj/item/fish/needlefish = 10,
		/obj/item/fish/armorfish = 10,
		/obj/item/fish/chasm_crab/ice = 5,
		/obj/item/stack/sheet/bone = 5,
	)
	catalog_description = "Hot Springs"

// The area

/area/ruin/unpowered/primitive_catgirl_den
	name = "\improper Icewalker Camp"
