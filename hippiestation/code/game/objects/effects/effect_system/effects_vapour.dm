//not actually a gas because real reagent gas is literally impossible without rewriting gases
/obj/effect/particle_effect/vapour/master//handles redistributing the volume to prevent a ton of duplicate for loops
	var/volume = 0
	var/list/newvapes = list()
	var/spread_delay = 10
	var/decay_factor = 2//the rate at which it dies


/obj/effect/particle_effect/vapour/master/Initialize()
	VM = src
	LAZYADD(newvapes, src)
	addtimer(CALLBACK(src, .proc/Merge_Master), 0)
	START_PROCESSING(SSreagent_states, src)
	. = ..()

/obj/effect/particle_effect/vapour/master/kill_vapour()
	LAZYREMOVE(newvapes, src)
	STOP_PROCESSING(SSreagent_states, src)
	if(LAZYLEN(newvapes))
		for(var/I in newvapes)
			var/obj/effect/particle_effect/vapour/V = I
			V.VM = null
			V.On_Tick()
	..()


/obj/effect/particle_effect/vapour/master/Destroy()
	LAZYREMOVE(VM.newvapes, src)
	STOP_PROCESSING(SSreagent_states, src)
	if(LAZYLEN(newvapes))
		for(var/I in newvapes)
			var/obj/effect/particle_effect/vapour/V = I
			V.VM = null
			V.On_Tick()
	return ..()


/obj/effect/particle_effect/vapour/master/proc/Merge_Master()
	for(var/obj/effect/particle_effect/vapour/master/M in orange(5, src))//a little costly but it only does it once and is much better than calling it on process
		if(M.reagent_type == reagent_type)
			volume += M.volume * 0.05
			M.kill_vapour()

	spread_delay = Clamp(100 / (volume * 0.001), 2, 60) //spread delay is inversely proportional to volume
	decay_factor = min(volume * 0.00005, 10)//decay is proportional to volume so higher volume means faster spread but also a relatively faster death


/obj/effect/particle_effect/vapour/master/process()
	volume -= decay_factor * LAZYLEN(newvapes)
	if(volume <= 40)
		kill_vapour()

	for(var/I in newvapes)//scrubbing
		var/obj/effect/particle_effect/vapour/V = I
		V.On_Tick()
		var/turf/T = get_turf(V)
		if(!T)
			V.kill_vapour()

	CHECK_TICK
	..()


GLOBAL_LIST_EMPTY(vapour)
/obj/effect/particle_effect/vapour
	name = "vapour"
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "chem_gas"
	opacity = 0
	layer = FLY_LAYER
	anchored = TRUE
	animate_movement = 0
	var/datum/reagent/reagent_type//much simpler than having it actually store and transfer
	var/obj/effect/particle_effect/vapour/master/VM
	var/reac_count = 0//running tally of the amount of inter gas reactions that have occured
	var/spread_cooldown = 0

/obj/effect/particle_effect/vapour/Initialize()
	. = ..()
	LAZYADD(GLOB.vapour, src)


/obj/effect/particle_effect/vapour/Destroy()
	LAZYREMOVE(GLOB.vapour, src)
	return ..()

/obj/effect/particle_effect/vapour/proc/kill_vapour()
	LAZYREMOVE(GLOB.vapour, src)
	qdel(src)

/obj/effect/particle_effect/vapour/proc/On_Tick()//attempts to spread and smoke mobs, slowly decays at a fixed rate + the amount of mobs currently being affected
	var/turf/t_loc = get_turf(src)
	if(!t_loc)
		return
	if(!reagent_type)
		return
	if(isspaceturf(t_loc) || isnull(reagent_type) || isnull(VM))
		kill_vapour()

	if(!QDELETED(src) && spread_cooldown <= world.time)
		spread_vapour()
		spread_cooldown = world.time + VM.spread_delay

	if(color != reagent_type.color)
		add_atom_colour(reagent_type.color, FIXED_COLOUR_PRIORITY)


	for(var/mob/living/L in range(0,src))
		vape_mob(L)
		VM.volume -= 10

	reagent_type.reaction_turf(t_loc, rand(1, 5))
	var/obj/machinery/portable_atmospherics/scrubber/PS = locate() in t_loc.contents
	if(PS && PS.on && !PS.holding)
		VM.volume -= PS.volume_rate * 0.5
		kill_vapour()

	var/obj/machinery/atmospherics/components/unary/vent_scrubber/S = locate() in view(t_loc, 3)//max range is 3x3 for a unary scrubber
	if(S && S.on && !S.welded && S.is_operational() && src != VM)
		if(S.scrubbing == FALSE || S.widenet)//if either panic siphoning or set to contaminated mode
			VM.volume -= S.volume_rate * 0.5
			kill_vapour()


/obj/effect/particle_effect/vapour/proc/spread_vapour()
	var/turf/t_loc = get_turf(src)
	var/clear = TRUE
	var/supply = 0
	if(!t_loc)
		return


	for(var/turf/T in t_loc.GetAtmosAdjacentTurfs())
		if(isspaceturf(T))//space will drain volume
			VM.volume -= 100
			continue

		for(var/I in T)
			if(istype(I, /obj/effect/particle_effect/vapour))//checks the tile for any vapour, prevents stacking of the same type
				var/obj/effect/particle_effect/vapour/foundvape = I
				if(foundvape && foundvape.reagent_type != reagent_type)
					clear = TRUE
					if(prob(3) && reac_count < 1)//BIG safety check
						create_reagents(50)//used just for in air reactions
						reagents.add_reagent(reagent_type.id, 5)
						reagents.add_reagent(foundvape.reagent_type.id, 5)
						qdel(reagents)
						reac_count++

				if(foundvape && foundvape.reagent_type == reagent_type)
					clear = FALSE
					supply++
					break
			else
				clear = TRUE

		if(supply <= 0 && src != VM)//prevents master from dying instantly
			kill_vapour()//no connecting tiles of same type

		if(clear)
			if(VM.volume > 40)
				var/obj/effect/particle_effect/vapour/V = new(T)
				V.reagent_type = reagent_type
				V.VM = VM
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


/obj/effect/particle_effect/vapour/ex_act()//just in case
	return