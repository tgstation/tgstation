/turf/open/floor/goonplaque
	name = "commemorative plaque"
	icon_state = "plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/vault
	icon_state = "rockvault"
	floor_tile = /obj/item/stack/tile/plasteel

//Circuit flooring, glows a little
/turf/open/floor/circuit
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	var/icon_normal = "bcircuit"
	light_color = LIGHT_COLOR_CYAN
	floor_tile = /obj/item/stack/tile/circuit
	var/on = TRUE

/turf/open/floor/circuit/Initialize()
	SSmapping.nuke_tiles += src
	update_icon()
	..()

/turf/open/floor/circuit/Destroy()
	SSmapping.nuke_tiles -= src
	return ..()

/turf/open/floor/circuit/update_icon()
	if(on)
		if(LAZYLEN(SSmapping.nuke_threats))
			icon_state = "rcircuitanim"
			light_color = LIGHT_COLOR_FLARE
		else
			icon_state = icon_normal
			light_color = initial(light_color)
		set_light(1.4, 0.5)
	else
		icon_state = "[icon_normal]off"
		set_light(0)

/turf/open/floor/circuit/off
	icon_state = "bcircuitoff"
	on = FALSE

/turf/open/floor/circuit/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/circuit/killroom
	name = "Killroom Floor"
	initial_gas_mix = "n2=500;TEMP=80"

/turf/open/floor/circuit/telecomms
	initial_gas_mix = "n2=100;TEMP=80"

/turf/open/floor/circuit/telecomms/mainframe
	name = "Mainframe Base"

/turf/open/floor/circuit/telecomms/server
	name = "Server Base"

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
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/circuit/green/telecomms
	initial_gas_mix = "n2=100;TEMP=80"

/turf/open/floor/circuit/green/telecomms/mainframe
	name = "Mainframe Base"

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
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/circuit/red/telecomms
	initial_gas_mix = "n2=100;TEMP=80"

/turf/open/floor/pod
	name = "pod floor"
	icon_state = "podfloor"
	icon_regular_floor = "podfloor"
	floor_tile = /obj/item/stack/tile/pod

/turf/open/floor/pod/light
	icon_state = "podfloor_light"
	icon_regular_floor = "podfloor_light"
	floor_tile = /obj/item/stack/tile/pod/light

/turf/open/floor/pod/dark
	icon_state = "podfloor_dark"
	icon_regular_floor = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/pod/dark


/turf/open/floor/noslip
	name = "high-traction floor"
	icon_state = "noslip"
	floor_tile = /obj/item/stack/tile/noslip
	broken_states = list("noslip-damaged1","noslip-damaged2","noslip-damaged3")
	burnt_states = list("noslip-scorched1","noslip-scorched2")
	slowdown = -0.3

/turf/open/floor/noslip/MakeSlippery()
	return

/turf/open/floor/oldshuttle
	icon = 'icons/turf/shuttleold.dmi'
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/bluespace
	slowdown = -1
	icon_state = "bluespace"
	desc = "Through a series of micro-teleports these tiles let people move at incredible speeds"
	floor_tile = /obj/item/stack/tile/bluespace


/turf/open/floor/sepia
	slowdown = 2
	icon_state = "sepia"
	desc = "Time seems to flow very slowly around these tiles"
	floor_tile = /obj/item/stack/tile/sepia



// VINE FLOOR

/turf/open/floor/vines
	color = "#aa77aa"
	icon_state = "vinefloor"
	broken_states = list()


//All of this shit is useless for vines

/turf/open/floor/vines/attackby()
	return

/turf/open/floor/vines/burn_tile()
	return

/turf/open/floor/vines/break_tile()
	return

/turf/open/floor/vines/make_plating()
	return

/turf/open/floor/vines/break_tile_to_plating()
	return

/turf/open/floor/vines/ex_act(severity, target)
	..()
	if(severity < 3 || target == src)
		ChangeTurf(src.baseturf)

/turf/open/floor/vines/narsie_act(force, ignore_mobs, probability = 20)
	if(prob(probability) || force)
		ChangeTurf(baseturf) //nar sie eats this shit
		narsie_act(force, ignore_mobs, probability)

/turf/open/floor/vines/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			ChangeTurf(src.baseturf)

/turf/open/floor/vines/ChangeTurf(turf/open/floor/T)
	. = ..()
	//Do this *after* the turf has changed as qdel in spacevines will call changeturf again if it hasn't
	for(var/obj/structure/spacevine/SV in src)
		if(!QDESTROYING(SV))//Helps avoid recursive loops
			qdel(SV)
