//Water! Used for flooding, and has adverse effects depending on its depth. It also makes a great beverage. All water is considered salt water by default.

/obj/effect/water
	name = "surface water"
	desc = "Water you looking at?"
	icon = 'icons/effects/effects.dmi'
	icon_state = "water_shallow"
	alpha = 0 //Alpha is always (fullness * 2)
	layer = MASSIVE_OBJ_LAYER
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	mouse_opacity = 0
	var/depth = 1 //In meters, how deep under the surface of the ocean this water is, affecting temperature and pressure on anyone inside of it
	var/pressure = 100 //In kPa, how much pressure the water is exerting on everything within it
	var/fullness = 100 //In percentage, how much water is in this tile; once this reaches 100, anyone without internals starts drowning
	var/can_spread = TRUE //If this water is a "source" and can make more water
	var/active = FALSE //If this water is currently active

/obj/effect/water/New(loc, depth_num = 0, fullness_num = 100)
	..()
	depth = depth_num
	fullness = fullness_num
	alpha = (fullness * 2) + 25
	pressure = (depth / 10) * 100 //1000 meters = 100 * one atmosphere = 100 atmospheres of pressure
	switch(depth)
		if(100 to 250)
			name = "water"
			desc = "Dim sunlight filters through, but it's cold down here."
			luminosity = 1
		if(250 to 750)
			name = "dark water"
			desc = "The light here comes from sources of your own. Tread carefully."
			icon_state = "water_deep"
		if(750 to 1000)
			name = "lightless water"
			desc = "Inky blackness in all directions. Dark shadows shifting just out of sight"
			icon_state = "water_lightless"
		if(1000 to INFINITY)
			name = "abyssal water"
			desc = "Down here, only the penumbral darkness reigns, black as death."
			icon_state = "water_lightless"

/obj/effect/water/Crossed(atom/movable/AM)
	activate(AM)

/obj/effect/water/proc/activate(atom/movable/AM)
	active = TRUE
	SSfastprocess.processing |= src

/obj/effect/water/process()
	if(!run_effects())
		deactivate()

/obj/effect/water/proc/deactivate()
	active = FALSE
	SSfastprocess.processing -= src

/obj/effect/water/proc/run_effects()
	var/turf/U = get_turf(src)
	alpha = (fullness * 2) + 25
	var/remain_active = FALSE
	for(var/atom/movable/A in U)
		if(!isturf(A) && !A.invisibility)
			A.water_act(src)
			remain_active = TRUE
	/*if(fullness >= 50 && can_spread) //Spreading mechanics disabled pending rework
		for(var/turf/T in U.GetAtmosAdjacentTurfs()) //Water spreads to nearby tiles, allowing for flooding mechanics
			if(istype(T, /turf/open/space)) //No water spreading in space!
				continue
			var/obj/effect/water/W = locate() in T
			if(W && W.fullness < 100)
				W.fullness = min(W.fullness + (depth / 10), 100)
				remain_active = TRUE
			else if(!W)
				new/obj/effect/water(T, depth, 2)
				remain_active = TRUE*/
	return remain_active

/obj/item/water_spawner
	name = "glass of holding"
	desc = "This glass never runs out of water."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "glass_clear"
	w_class = 2

/obj/item/water_spawner/attack_self(mob/living/user)
	var/depth = input(user, "What depth?.", "GET THE WATER") as num|null
	if(depth)
		new/obj/effect/water(get_turf(user), depth, 100)
