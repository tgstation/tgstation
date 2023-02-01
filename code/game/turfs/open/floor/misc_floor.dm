//Circuit flooring, glows a little
/turf/open/floor/circuit
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	var/icon_normal = "bcircuit"
	light_color = LIGHT_COLOR_CYAN
	floor_tile = /obj/item/stack/tile/circuit
	var/on = TRUE

/turf/open/floor/circuit/Initialize(mapload)
	SSmapping.nuke_tiles += src
	update_appearance()
	. = ..()

/turf/open/floor/circuit/Destroy()
	SSmapping.nuke_tiles -= src
	return ..()

/turf/open/floor/circuit/update_appearance(updates)
	. = ..()
	if(!on)
		set_light(0)
		return

	set_light_color(LAZYLEN(SSmapping.nuke_threats) ? LIGHT_COLOR_FLARE : initial(light_color))
	set_light(1.4, 0.5)

/turf/open/floor/circuit/update_icon_state()
	icon_state = on ? (LAZYLEN(SSmapping.nuke_threats) ? "rcircuitanim" : icon_normal) : "[icon_normal]off"
	return ..()

/turf/open/floor/circuit/off
	icon_state = "bcircuitoff"
	on = FALSE

/turf/open/floor/circuit/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/telecomms/mainframe
	name = "mainframe base"

/turf/open/floor/circuit/telecomms/server
	name = "server base"

/turf/open/floor/circuit/green
	icon_state = "gcircuit"
	icon_normal = "gcircuit"
	light_color = LIGHT_COLOR_GREEN
	floor_tile = /obj/item/stack/tile/circuit/green

/turf/open/floor/circuit/green/off
	icon_state = "gcircuitoff"
	on = FALSE

/turf/open/floor/circuit/green/anim
	icon_state = "gcircuitanim"
	icon_normal = "gcircuitanim"
	floor_tile = /obj/item/stack/tile/circuit/green/anim

/turf/open/floor/circuit/green/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/green/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/circuit/green/telecomms/mainframe
	name = "mainframe base"

/turf/open/floor/circuit/red
	icon_state = "rcircuit"
	icon_normal = "rcircuit"
	light_color = LIGHT_COLOR_FLARE
	floor_tile = /obj/item/stack/tile/circuit/red

/turf/open/floor/circuit/red/off
	icon_state = "rcircuitoff"
	on = FALSE

/turf/open/floor/circuit/red/anim
	icon_state = "rcircuitanim"
	icon_normal = "rcircuitanim"
	floor_tile = /obj/item/stack/tile/circuit/red/anim

/turf/open/floor/circuit/red/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit/red/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/pod
	name = "pod floor"
	icon_state = "podfloor"
	floor_tile = /obj/item/stack/tile/pod

/turf/open/floor/pod/light
	icon_state = "podfloor_light"
	floor_tile = /obj/item/stack/tile/pod/light

/turf/open/floor/pod/dark
	icon_state = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/pod/dark


/turf/open/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	slowdown = -0.3

/turf/open/floor/noslip/tram_plate
	name = "linear induction plate"
	desc = "The linear induction plate that powers the tram."
	icon_state = "tram_plate"
	base_icon_state = "tram_plate"

/turf/open/floor/noslip/tram_platform
	name = "tram platform"
	desc = "A sturdy looking tram platform."
	icon_state = "tram_platform"
	base_icon_state = "tram_platform"

/turf/open/floor/noslip/broken_states()
	return list("noslip-damaged1","noslip-damaged2","noslip-damaged3")

/turf/open/floor/noslip/burnt_states()
	return list("noslip-scorched1","noslip-scorched2")

/turf/open/floor/noslip/tram_plate/broken_states()
	return list("tram_plate-damaged1","tram_plate-damaged2")

/turf/open/floor/noslip/tram_plate/burnt_states()
	return list("tram_plate-scorched1","tram_plate-scorched2")

/turf/open/floor/noslip/tram_platform/broken_states()
	return list("tram_platform-damaged1","tram_platform-damaged2")

/turf/open/floor/noslip/tram_platform/burnt_states()
	return list("tram_platform-scorched1","tram_platform-scorched2")

/turf/open/floor/noslip/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/oldshuttle
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/iron/base

/turf/open/floor/bluespace
	slowdown = -1
	icon_state = "bluespace"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds."
	floor_tile = /obj/item/stack/tile/bluespace


/turf/open/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Time seems to flow very slowly around these tiles."
	floor_tile = /obj/item/stack/tile/sepia


/turf/open/floor/bronze
	name = "bronze floor"
	desc = "Some heavy bronze tiles."
	icon_state = "clockwork_floor"
	floor_tile = /obj/item/stack/tile/bronze

/turf/open/floor/bronze/flat
	icon_state = "reebe"
	floor_tile = /obj/item/stack/tile/bronze/flat

/turf/open/floor/bronze/filled
	icon_state = "clockwork_floor_filled"
	floor_tile = /obj/item/stack/tile/bronze/filled

/turf/open/floor/bronze/filled/lavaland
	planetary_atmos = TRUE
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/floor/bronze/filled/icemoon
	planetary_atmos = TRUE
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS

/turf/open/floor/white
	name = "white floor"
	desc = "A tile in a pure white color."
	icon_state = "pure_white"

/turf/open/floor/black
	name = "black floor"
	icon_state = "black"

/turf/open/floor/plastic
	name = "plastic floor"
	desc = "Cheap, lightweight flooring. Melts easily."
	icon_state = "plastic"
	thermal_conductivity = 0.1
	heat_capacity = 900
	custom_materials = list(/datum/material/plastic=500)
	floor_tile = /obj/item/stack/tile/plastic

/turf/open/floor/plastic/broken_states()
	return list("plastic-damaged1","plastic-damaged2")

/turf/open/floor/eighties
	name = "retro floor"
	desc = "This one takes you back."
	icon_state = "eighties"
	floor_tile = /obj/item/stack/tile/eighties

/turf/open/floor/eighties/broken_states()
	return list("eighties_damaged")

/turf/open/floor/eighties/red
	name = "red retro floor"
	desc = "Totally RED-ICAL!"
	icon_state = "eightiesred"
	floor_tile = /obj/item/stack/tile/eighties/red

/turf/open/floor/eighties/red/broken_states()
	return list("eightiesred_damaged")

/turf/open/floor/plating/rust
	//SDMM supports colors, this is simply for easier mapping
	//and should be removed on initialize
	color = COLOR_BROWN

/turf/open/floor/plating/rust/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/rust)
	color = null

/turf/open/floor/plating/plasma
	initial_gas_mix = ATMOS_TANK_PLASMA

/turf/open/floor/plating/plasma/rust/Initialize(mapload)
	. = ..()
	// Because this is a fluff turf explicitly for KiloStation it doesn't make sense to ChangeTurf like usual
	// Especially since it looks like we don't even change the default icon/iconstate???
	AddElement(/datum/element/rust)

/turf/open/floor/stone
	name = "stone brick floor"
	desc = "Odd, really, how it looks exactly like the iron walls yet is stone instead of iron. Now, if that's really more of a complaint about\
		the ironness of walls or the stoneness of the floors, that's really up to you. But have you really ever seen iron that dull? I mean, it\
		makes sense for the station to have dull metal walls but we're talking how a rudimentary iron wall would be. Medieval ages didn't even\
		use iron walls, iron walls are actually not even something that exists because iron is an expensive and not-so-great thing to build walls\
		out of. It only makes sense in the context of space because you're trying to keep a freezing vacuum out. Is anyone following me on this? \
		The idea of a \"rudimentary\" iron wall makes no sense at all! Is anything i'm even saying here true? Someone's gotta fact check this!"
	icon_state = "stone_floor"

/turf/open/floor/vault
	name = "strange floor"
	desc = "You feel a strange nostalgia from looking at this..."
	icon_state = "rockvault"
	base_icon_state = "rockvault"

/turf/open/floor/vault/rock
	name = "rocky floor"

/turf/open/floor/vault/alien
	name = "alien floor"
	icon_state = "alienvault"
	base_icon_state = "alienvault"

/turf/open/floor/vault/sandstone
	name = "sandstone floor"
	icon_state = "sandstonevault"
	base_icon_state = "sandstonevault"

/turf/open/floor/cult
	name = "engraved floor"
	icon_state = "cult"
	base_icon_state = "cult"
	floor_tile = /obj/item/stack/tile/cult

/turf/open/floor/cult/broken_states()
	return list("cultdamage","cultdamage2","cultdamage3","cultdamage4","cultdamage5","cultdamage6","cultdamage7")

/turf/open/floor/cult/narsie_act()
	return

/turf/open/floor/cult/airless
	initial_gas_mix = AIRLESS_ATMOS
