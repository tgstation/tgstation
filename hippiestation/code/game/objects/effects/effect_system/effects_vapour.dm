//not actually a gas because real reagent gas is literally impossible without rewriting gases
/obj/effect/particle_effect/vapour/master//handles redistributing the volume to prevent a ton of duplicate for loops
	var/volume = 0
	var/list/newvapes = list()

/obj/effect/particle_effect/vapour/master/Initialize()
	VM = src
	LAZYADD(newvapes, src)
	spawn(0)
		for(var/obj/effect/particle_effect/vapour/master/M in orange(10, src))//a little costly but it only does it once and is much better than calling it on process
			if(M.reagent_type == reagent_type)
				volume += M.volume * 0.05
				M.kill_vapour()
	. = ..()
/obj/effect/particle_effect/vapour/master/spread_vapour()
	..()
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return
	if(volume <= 0)
		for(var/I in newvapes)
			var/obj/effect/particle_effect/vapour/V = I
			V.kill_vapour()
		kill_vapour()
	volume -= 2 * LAZYLEN(newvapes)

/obj/effect/particle_effect/vapour
	name = "vapour"
	icon = 'hippiestation/icons/effects/32x32.dmi'
	icon_state = "chemgas"
	opacity = 0
	layer = FLY_LAYER
	anchored = TRUE
	animate_movement = 0
	var/datum/reagent/reagent_type//much simpler than having it actually store and transfer
	var/obj/effect/particle_effect/vapour/master/VM
	var/spread_delay = 10

/obj/effect/particle_effect/vapour/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/effect/particle_effect/vapour/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/particle_effect/vapour/proc/kill_vapour()
	STOP_PROCESSING(SSobj, src)
	qdel(src)

/obj/effect/particle_effect/vapour/process()//attempts to spread and smoke mobs, slowly decays at a fixed rate + the amount of mobs currently being affected
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return
	if(!reagent_type)
		return
	if(isspaceturf(t_loc) || isnull(reagent_type) || isnull(VM))
		kill_vapour()

	if(color != reagent_type.color)
		add_atom_colour(reagent_type.color, FIXED_COLOUR_PRIORITY)

	addtimer(CALLBACK(src, .proc/spread_vapour), spread_delay)

	for(var/mob/living/L in range(0,src))
		vape_mob(L)
		VM.volume -= 10

	reagent_type.reaction_turf(t_loc, rand(1, 5))

	CHECK_TICK

/obj/effect/particle_effect/vapour/proc/spread_vapour()
	var/turf/t_loc = get_turf(src)
	var/clear = TRUE
	if(!t_loc)
		return

	for(var/turf/T in t_loc.GetAtmosAdjacentTurfs())
		if(isspaceturf(T))
			continue

		for(var/I in T)
			if(istype(I, /obj/effect/particle_effect/vapour))//checks the tile for any vapour, prevents stacking of the same type
				var/obj/effect/particle_effect/vapour/foundvape = I
				if(foundvape && foundvape.reagent_type != reagent_type)
					clear = TRUE
				if(foundvape && foundvape.reagent_type == reagent_type)
					clear = FALSE
					break
			else
				clear = TRUE
		if(clear)
			if(VM.volume > 40)
				var/obj/effect/particle_effect/vapour/V = new(T)
				V.reagent_type = reagent_type
				V.VM = VM
				V.setDir(pick(GLOB.cardinals))
				V.add_atom_colour(color, FIXED_COLOUR_PRIORITY)
				VM.volume -= 40
				LAZYADD(VM.newvapes, V)

/obj/effect/particle_effect/vapour/proc/vape_mob(mob/living/carbon/M)
	if(VM.volume<1)
		return FALSE
	if(!istype(M))
		return FALSE

	var/mob/living/carbon/C = M
	C.reagents.reaction(C, TOUCH, 1)
	if(C.internal != null || C.has_smoke_protection())
		return FALSE

	C.reagents.add_reagent(reagent_type.id, 1.5)//doesn't actually carry reagents but just adds them to mobs at a slow fixed rate
	C.reagents.reaction(C, INGEST, 1.5)
	return FALSE