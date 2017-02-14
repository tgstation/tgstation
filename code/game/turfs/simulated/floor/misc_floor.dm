/turf/open/floor/goonplaque
	name = "commemorative plaque"
	icon_state = "plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/vault
	icon_state = "rockvault"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/bluegrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "bcircuit"
	floor_tile = /obj/item/stack/tile/plasteel

/turf/open/floor/bluegrid/Initialize()
	SSmapping.nuke_tiles += src
	..()

/turf/open/floor/bluegrid/Destroy()
	SSmapping.nuke_tiles -= src
	return ..()

/turf/open/floor/greengrid
	icon = 'icons/turf/floors.dmi'
	icon_state = "gcircuit"
	floor_tile = /obj/item/stack/tile/plasteel


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

//Clockwork floor: Slowly heals toxin damage on nearby servants.
/turf/open/floor/clockwork
	name = "clockwork floor"
	desc = "Tightly-pressed brass tiles. They emit minute vibration."
	icon_state = "plating"
	var/obj/effect/clockwork/overlay/floor/realappearence

/turf/open/floor/clockwork/Initialize()
	..()
	new /obj/effect/overlay/temp/ratvar/floor(src)
	new /obj/effect/overlay/temp/ratvar/beam(src)
	realappearence = new /obj/effect/clockwork/overlay/floor(src)
	realappearence.linked = src
	change_construction_value(1)

/turf/open/floor/clockwork/Destroy()
	STOP_PROCESSING(SSobj, src)
	change_construction_value(-1)
	if(realappearence)
		qdel(realappearence)
		realappearence = null
	return ..()

/turf/open/floor/clockwork/ReplaceWithLattice()
	..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/open/floor/clockwork/Entered(atom/movable/AM)
	..()
	START_PROCESSING(SSobj, src)

/turf/open/floor/clockwork/process()
	if(!healservants())
		STOP_PROCESSING(SSobj, src)

/turf/open/floor/clockwork/proc/healservants()
	for(var/mob/living/L in src)
		if(L.stat == DEAD)
			continue
		. = 1
		if(!is_servant_of_ratvar(L) || !L.toxloss)
			continue

		var/image/I = new('icons/effects/effects.dmi', src, "heal", ABOVE_MOB_LAYER) //fake a healing glow for servants
		I.appearance_flags = RESET_COLOR
		I.color = "#5A6068"
		I.pixel_x = rand(-12, 12)
		I.pixel_y = rand(-9, 0)
		var/list/viewing = list()
		for(var/mob/M in viewers(src))
			if(M.client && (is_servant_of_ratvar(M) || isobserver(M) || M.stat == DEAD))
				viewing += M.client
		flick_overlay(I, viewing, 8)
		L.adjustToxLoss(-3, TRUE, TRUE)

/turf/open/floor/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		user.visible_message("<span class='notice'>[user] begins slowly prying up [src]...</span>", "<span class='notice'>You begin painstakingly prying up [src]...</span>")
		playsound(src, I.usesound, 20, 1)
		if(!do_after(user, 70*I.toolspeed, target = src))
			return 0
		user.visible_message("<span class='notice'>[user] pries up [src]!</span>", "<span class='notice'>You pry up [src]!</span>")
		playsound(src, I.usesound, 80, 1)
		make_plating()
		return 1
	return ..()

/turf/open/floor/clockwork/make_plating()
	new /obj/item/stack/tile/brass(src)
	return ..()

/turf/open/floor/clockwork/narsie_act()
	..()
	if(istype(src, /turf/open/floor/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)


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

/turf/open/floor/vines/narsie_act()
	if(prob(20))
		ChangeTurf(src.baseturf) //nar sie eats this shit

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
	UpdateAffectingLights()
