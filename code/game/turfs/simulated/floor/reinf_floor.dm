
/turf/open/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = INFINITY
	floor_tile = /obj/item/stack/rods

/turf/open/floor/engine/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/engine/break_tile()
	return //unbreakable

/turf/open/floor/engine/burn_tile()
	return //unburnable

/turf/open/floor/engine/make_plating(force = 0)
	if(force)
		..()
	return //unplateable

/turf/open/floor/engine/attackby(obj/item/C, mob/user, params)
	if(!C || !user)
		return
	if(istype(C, /obj/item/wrench))
		to_chat(user, "<span class='notice'>You begin removing rods...</span>")
		playsound(src, C.usesound, 80, 1)
		if(do_after(user, 30*C.toolspeed, target = src))
			if(!istype(src, /turf/open/floor/engine))
				return
			new /obj/item/stack/rods(src, 2)
			ChangeTurf(/turf/open/floor/plating)
			return

/turf/open/floor/engine/acid_act(acidpwr, acid_volume)
	acidpwr = min(acidpwr, 50) //we reduce the power so reinf floor never get melted.
	. = ..()

/turf/open/floor/engine/ex_act(severity,target)
	var/shielded = is_shielded()
	contents_explosion(severity, target)
	if(severity != 1 && shielded && target != src)
		return
	if(target == src)
		src.ChangeTurf(src.baseturf)
		return
	switch(severity)
		if(1)
			if(prob(80))
				ReplaceWithLattice()
			else if(prob(50))
				ChangeTurf(src.baseturf)
			else
				make_plating(1)
		if(2)
			if(prob(50))
				make_plating(1)

/turf/open/floor/engine/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(30))
				new floor_tile(src)
				make_plating()
		else if(prob(30))
			ReplaceWithLattice()

/turf/open/floor/engine/attack_paw(mob/user)
	return src.attack_hand(user)

/turf/open/floor/engine/attack_hand(mob/user)
	user.Move_Pulled(src)


//air filled floors; used in atmos pressure chambers

/turf/open/floor/engine/n2o
	name = "n2o floor"
	initial_gas_mix = "n2o=6000;TEMP=293.15"

/turf/open/floor/engine/co2
	name = "co2 floor"
	initial_gas_mix = "co2=50000;TEMP=293.15"

/turf/open/floor/engine/plasma
	name = "plasma floor"
	initial_gas_mix = "plasma=70000;TEMP=293.15"

/turf/open/floor/engine/o2
	name = "o2 floor"
	initial_gas_mix = "o2=100000;TEMP=293.15"

/turf/open/floor/engine/n2
	name = "n2 floor"
	initial_gas_mix = "n2=100000;TEMP=293.15"

/turf/open/floor/engine/air
	name = "air floor"
	initial_gas_mix = "o2=2644;n2=10580;TEMP=293.15"



/turf/open/floor/engine/cult
	name = "engraved floor"
	icon_state = "plating"
	var/obj/effect/clockwork/overlay/floor/bloodcult/realappearence

/turf/open/floor/engine/cult/Initialize()
	..()
	new /obj/effect/temp_visual/cult/turf/floor(src)
	realappearence = new /obj/effect/clockwork/overlay/floor/bloodcult(src)
	realappearence.linked = src

/turf/open/floor/engine/cult/Destroy()
	be_removed()
	return ..()

/turf/open/floor/engine/cult/ChangeTurf(path, defer_change = FALSE)
	if(path != type)
		be_removed()
	return ..()

/turf/open/floor/engine/cult/proc/be_removed()
	qdel(realappearence)
	realappearence = null

/turf/open/floor/engine/cult/ratvar_act()
	. = ..()
	if(istype(src, /turf/open/floor/engine/cult)) //if we haven't changed type
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 8)

/turf/open/floor/engine/cult/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/engine/vacuum
	name = "vacuum floor"
	initial_gas_mix = "TEMP=2.7"
