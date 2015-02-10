//////SNOW//////(winter 2014, by Deity Link)

#define SNOWCOVERING_FULL 2
#define SNOWCOVERING_MEDIUM 1
#define SNOWCOVERING_LITTLE 0

#define TICK_JIGGLE(X) rand(((X)-((X)*0.1)),((X)+((X)*0.1)))

/obj/structure/snow
	name = "snow"
	layer = 2.5//above the plating and the vents, bellow most items and structures
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	alpha = 230
	anchored = 1
	density = 0
	mouse_opacity = 1

	var/snow_amount = SNOWCOVERING_FULL

	var/next_update = 0 // world.time

	var/list/foliage = list(
		"snowgrass1bb",
		"snowgrass2bb",
		"snowgrass3bb",
		"snowgrass1gb",
		"snowgrass2gb",
		"snowgrass3gb",
		"snowgrassall1",
		"snowgrassall2",
		"snowgrassall3",
		)

/obj/structure/snow/New()
	..()
	if(prob(17))
		overlays += image('icons/obj/flora/snowflora.dmi',pick(foliage))

/obj/structure/snow/attackby(obj/item/W,mob/user)
	if(istype(W,/obj/item/weapon/pickaxe/shovel))//using a shovel or spade harvests some snow and let's you click on the lower layers
		snow_amount = SNOWCOVERING_LITTLE
		icon_state = "snow_dug"
		mouse_opacity = 0
		new /obj/item/stack/sheet/snow(get_turf(src), 1)
		new /obj/item/stack/sheet/snow(get_turf(src), 1)
		new /obj/item/stack/sheet/snow(get_turf(src), 1)

		if(snow_amount==SNOWCOVERING_LITTLE)
			qdel(src)
			return

		// Start process(), if we need to.
		if(!(src in processing_objects))
			processing_objects.Add(src)

/obj/structure/snow/process()
	..()
	if(world.time < next_update)
		return
	switch(snow_amount)
		if(SNOWCOVERING_LITTLE)
			icon_state = "snow_grabbed"
			mouse_opacity = 1
			snow_amount = SNOWCOVERING_MEDIUM
		if(SNOWCOVERING_MEDIUM)
			icon_state = "snow"
			snow_amount = SNOWCOVERING_FULL
			processing_objects.Remove(src)
	next_update=world.time + TICK_JIGGLE(300) // 30 seconds


/obj/structure/snow/attack_hand(mob/user)
	if(snow_amount != SNOWCOVERING_FULL)
		return
	playsound(get_turf(src), "rustle", 50, 1)
	user << "<span class='notice'>You start digging the snow with your hands.</span>"
	if(do_after(user,30))
		snow_amount = SNOWCOVERING_MEDIUM
		user << "<span class='notice'>You form a snowball in your hands.</span>"
		user.put_in_hands(new /obj/item/stack/sheet/snow())
		icon_state = "snow_grabbed"

		if(snow_amount==SNOWCOVERING_LITTLE)
			qdel(src)
			return

		// Start process(), if we need to.
		if(!(src in processing_objects))
			processing_objects.Add(src)
	return

//////COSMIC SNOW(the one that spreads everywhere)//////

/* No.
/obj/structure/snow/cosmic
	desc = "Winter is coming."

	var/list/block_spread_turf = list(
		/turf/space,
		/turf/unsimulated,
		)

	var/list/block_spread_obj = list(		//these objects always block the spread of the snow
		/obj/structure/plasticflaps/mining,
		/obj/structure/snow,
		/obj/effect/forcefield,
		)

	var/list/block_spread_density = list(	//these objects only block the spread of the snow if they are dense
		/obj/machinery/door/firedoor,
		/obj/machinery/door/airlock,
		/obj/machinery/door/morgue,
		/obj/machinery/door/poddoor,
		)

	var/datum/gas_mixture/env = null

/obj/structure/snow/cosmic/New()
	..()
	snow_tiles++
	var/blocked = 0
	for(var/atom/A in get_turf(src))
		if(A.density)
			blocked = 1
	if((snow_tiles >= COSMICFREEZE_LEVEL_1) && !blocked && prob(15))
		if(prob(30))
			new/obj/structure/snow_flora/sappling/pine(get_turf(src))
		else
			new/obj/structure/snow_flora/sappling(get_turf(src))
	if((snow_tiles >= COSMICFREEZE_LEVEL_2) && !blocked && prob(2))
		new/mob/living/simple_animal/hostile/retaliate/snowman(get_turf(src))
	if(!bear_invasion && (snow_tiles >= COSMICFREEZE_LEVEL_4))
		bear_invasion = 1
		for(var/obj/effect/landmark/C in landmarks_list)
			if(C.name == "carpspawn")
				if(prob(50))
					new /mob/living/simple_animal/hostile/bear(C.loc)
	var/turf/simulated/TS = get_turf(src)
	if(!istype(TS))    return
	env = TS.return_air()
	for(var/obj/machinery/alarm/A in get_turf(src))
		A.stat |= FROZEN
		A.rcon_setting = RCON_NO
		A.update_icon()
	spawn(chill_delay)
		if(src)
			chill()
	spawn(rand(5,15))
		spread()
	return

/obj/structure/snow/cosmic/proc/update_env_air()
	var/turf/simulated/TS = get_turf(src)
	if(!istype(TS))	return
	env = TS.return_air()

/obj/structure/snow/cosmic/proc/spread()
	while(src && !src.gcDestroyed)
		if(snow_tiles >= COSMICFREEZE_END)	return
		update_env_air()
		if(!env)    return
		else if(env.temperature > MELTPOINT_SNOW)//above 30?C, the snow melts away)
			src.snowMelt()
			return
		else if(env.temperature < SNOWSPREAD_MAXTEMP)
			for(var/i in cardinal)
				var/turf/T = get_step(src,i)
				var/datum/gas_mixture/env2 = T.return_air()
				if(env2.temperature >= MELTPOINT_SNOW)	continue
				if(src.canSpreadTo(T))
					new/obj/structure/snow/cosmic(T)

		sleep(TICK_JIGGLE(spread_delay))
	return

/obj/structure/snow/cosmic/proc/snowMelt()
	var/turf/simulated/TS = get_turf(src)
	if(!istype(TS))    return
	TS.wet(300)
	snow_tiles--
	qdel(src)
	return


//The below proc is extremely expensive: consider minimizing the
//number of times it runs by calculating per map turfs
//maybe push the delay to something like 50 (or find a way to cut
//out some of these checks)
/obj/structure/snow/cosmic/proc/canSpreadTo(turf/T)
	if(is_type_in_list(T,block_spread_turf)) return 0
	if(T.density) return 0

	for(var/blockingA in block_spread_obj)
		if(locate(blockingA) in T) return 0

	for(var/blockingB in block_spread_density)
		var/obj/BB = (locate(blockingB) in T)
		if(BB && BB.density) return 0

	for(var/obj/structure/window/WA in get_turf(src))
		if(WA.dir & get_dir(get_turf(src),T)) return 0

	for(var/obj/machinery/door/window/WB in get_turf(src))
		if((WB.dir & get_dir(get_turf(src),T)) && WB.density)
			return 0

	for(var/obj/structure/window/WA in T)
		if(WA.is_fulltile()) return 0
		if(WA.dir & get_dir(T,get_turf(src))) return 0

	for(var/obj/machinery/door/window/WB in T)
		if((WB.dir & get_dir(T,get_turf(src))) && WB.density)
			return 0

	return 1

/obj/structure/snow/cosmic/proc/chill()
	while(src && !src.gcDestroyed)
		if(snow_tiles >= COSMICFREEZE_END)	return
		if(env.temperature > COSMICSNOW_MINIMALTEMP)//the snow will slowly lower the temperature until -40?C.
			env.temperature -= (0.01 * snow_amount)
		if(env.temperature < COSMICSNOW_MINIMALTEMP+1)//snow that reached its minimal temperature stops its reaction. should considerably reduce the lag.
			return
		sleep(TICK_JIGGLE(chill_delay * snowTickMod))
	return
*/

//////SNOWBALLS//////

/obj/item/stack/sheet/snow
	name = "snow"
	desc = "Technically water."
	singular_name = "snow ball"
	icon_state = "snow"
	melt_temperature = MELTPOINT_SNOW
	force = 0
	throwforce = 1
	throw_speed = 3
	throw_range = 6

	var/spawn_loc = null

/obj/item/stack/sheet/snow/New(var/loc, var/amount=null)
	recipes = snow_recipes
	pixel_x = rand(-13,13)
	pixel_y = rand(-13,13)

	spawn_loc = src.loc

	spawn(SNOWBALL_TIMELIMIT)
		remove_snowball()

	return ..()

/obj/item/stack/sheet/snow/proc/remove_snowball()
	if(src && (src.loc == spawn_loc) && istype(src.loc,/turf))
		qdel(src)

/obj/item/stack/sheet/snow/melt()
	var/turf/T = get_turf(src)
	if(istype(T,/turf/simulated))
		var/turf/simulated/TS = T
		TS.wet(100)
	qdel(src)

/obj/item/stack/sheet/snow/throw_at(atom/target, range, speed)
	playsound(src.loc, 'sound/weapons/punchmiss.ogg', 50, 1)
	..()

/obj/item/stack/sheet/snow/throw_impact(atom/hit_atom)
	if(istype(hit_atom,/mob/living/carbon/))
		var/mob/living/carbon/C = hit_atom
		if(C.stuttering < 1 && (!(M_HULK in C.mutations)))
			C.stuttering = 1
		C.Weaken(1)
		C.Stun(1)
		playsound(C.loc, "swing_hit", 50, 1)
		if(C.bodytemperature >= 265)
			C.bodytemperature -= 5
	else if(istype(hit_atom,/mob/living/simple_animal/hostile/retaliate/snowman))
		var/mob/living/simple_animal/hostile/retaliate/snowman/S = hit_atom
		playsound(S.loc, "swing_hit", 50, 1)
		if(S.enemies.len)
			if(prob(10))
				S.enemies = list()
				S.LoseTarget()
				S.say("Ah, I give up, you've got a pretty good swing.")
				call(/obj/item/weapon/winter_gift/proc/pick_a_gift)(S.loc)
			else
				S.say(pick("Didn't feel anything","You call that snowballing?"))
		else
			S.say(pick("A fight? With pleasure.","Don't forget that you're the one who started it all."))
			S.Retaliate()
		if(S.bodytemperature >= COSMICSNOW_MINIMALTEMP)
			S.bodytemperature -= 5
	else	..()

var/global/list/datum/stack_recipe/snow_recipes = list (
	new/datum/stack_recipe("snowman", /mob/living/simple_animal/hostile/retaliate/snowman, 10, time = 50, one_per_turf = 0, on_floor = 1),
	new/datum/stack_recipe("snow barricade", /obj/structure/barricade/snow, 20, time = 50, one_per_turf = 1, on_floor = 1),
	)


//////BARRICADE//////

/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "This space is blocked off by a snow barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "snowbarricade"
	anchored = 1.0
	density = 1.0
	var/health = 50.0
	var/maxhealth = 50.0

/obj/structure/barricade/snow/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/stack/sheet/snow))
		if (src.health < src.maxhealth)
			visible_message("<span class='warning'>[user] begins to repair the [src]!</span>")
			if(do_after(user,20))
				src.health = src.maxhealth
				W:use(1)
				visible_message("<span class='warning'>[user] repairs the [src]</span>")
				return
		else
			return
		return
	else
		switch(W.damtype)
			if("fire")
				src.health -= W.force * 1
			if("brute")
				src.health -= W.force * 0.75
			else
		if (src.health <= 0)
			visible_message("<span class='danger'>\the [src] is smashed apart!</span>")
			new /obj/item/stack/sheet/snow(get_turf(src), 1)
			new /obj/item/stack/sheet/snow(get_turf(src), 1)
			new /obj/item/stack/sheet/snow(get_turf(src), 1)
			del(src)
		..()

/obj/structure/barricade/snow/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>\the [src] is blown apart!</span>")
			qdel(src)
			return
		if(2.0)
			src.health -= 25
			if (src.health <= 0)
				visible_message("<span class='danger'>\the [src] is blown apart!</span>")
				new /obj/item/stack/sheet/snow(get_turf(src), 1)
				new /obj/item/stack/sheet/snow(get_turf(src), 1)
				new /obj/item/stack/sheet/snow(get_turf(src), 1)
				qdel(src)
			return

/obj/structure/barricade/snow/meteorhit()
	visible_message("<span class='danger'>\the [src] is blown apart!</span>")
	new /obj/item/stack/sheet/snow(get_turf(src), 1)
	new /obj/item/stack/sheet/snow(get_turf(src), 1)
	new /obj/item/stack/sheet/snow(get_turf(src), 1)
	del(src)
	return

/obj/structure/barricade/snow/blob_act()
	src.health -= 25
	if (src.health <= 0)
		visible_message("<span class='danger'>The blob eats through \the [src]!</span>")
		del(src)
	return

/obj/structure/barricade/snow/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)//So bullets will fly over and stuff.
	if(air_group || (height==0))
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0



//////TREES//////
/obj/structure/snow_flora
	name = "snow_flora"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	autoignition_temperature=AUTOIGNITION_WOOD

/obj/structure/snow_flora/sappling
	name = "sappling"
	desc = "Shh, it's growing..."
	density = 0
	anchored = 1
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"

	var/growth = 0
	var/growthlevel = 20

	pixel_x = 16
	pixel_y = 21

/obj/structure/snow_flora/sappling/New()
	..()
	icon_state = pick(
		"snowbush1",
		"snowbush2",
		"snowbush3",
		"snowbush4",
		"snowbush5",
		"snowbush6",
		)
	growthlevel = rand(15,25)
	spawn()
		growing()

/obj/structure/snow_flora/sappling/proc/growing()
	/* Performance.
	while(src && !src.gcDestroyed)

		if(growth > growthlevel)
			new/obj/structure/snow_flora/tree(get_turf(src))
			qdel(src)

		if(!(locate(/obj/structure/snow) in get_turf(src)))
			qdel(src)

		growth++

		sleep(TICK_JIGGLE(40 * snowTickMod))
	*/
	return

/obj/structure/snow_flora/sappling/attackby(obj/item/W,mob/user)
	var/list/cutting = list(
		/obj/item/weapon/minihoe,
		/obj/item/weapon/scythe,
		)
	if(is_type_in_list(W,cutting))
		qdel(src)

/obj/structure/snow_flora/sappling/pine
	pixel_x = 0
	pixel_y = 0

	growthlevel = 30

/obj/structure/snow_flora/sappling/pine/New()
	..()
	growthlevel = rand(25,35)

/obj/structure/snow_flora/sappling/pine/growing()
	/* Performance
	while(src && !src.gcDestroyed)

		if(growth > growthlevel)
			if(prob(20))
				new/obj/structure/snow_flora/tree/pine/xmas(get_turf(src))
			else
				new/obj/structure/snow_flora/tree/pine(get_turf(src))
			qdel(src)

		if(!(locate(/obj/structure/snow) in get_turf(src)))
			qdel(src)

		growth++

		sleep(TICK_JIGGLE(40 * snowTickMod))
	*/
	return

/obj/structure/snow_flora/tree
	name = "tree"
	desc = "Where's my axe when I need it?"
	density = 0
	anchored = 1
	layer = FLY_LAYER
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

	var/axe_hits = 0

	pixel_y = 21//regular dead trees appear slightly to the north east, so we can justify that they don't block players.

/obj/structure/snow_flora/tree/New()
	..()
	icon_state = pick(
		"tree_1",
		"tree_2",
		"tree_3",
		"tree_4",
		"tree_5",
		"tree_6",
		)
	spawn()
		idle()

/obj/structure/snow_flora/tree/proc/idle()
	/* Performance
	while(src && !src.gcDestroyed)

		if(!(locate(/obj/structure/snow) in get_turf(src)))
			axe_hits++
			if(axe_hits >= 3)
				new/obj/item/weapon/grown/log(get_turf(src))
				qdel(src)

		sleep(TICK_JIGGLE(50 * snowTickMod))
	*/
	return

/obj/structure/snow_flora/tree/attackby(obj/item/W,mob/user)
	var/list/cutting = list(
		/obj/item/weapon/hatchet,
		/obj/item/weapon/fireaxe,
		)
	if(is_type_in_list(W,cutting))
		axe_hits++
		user.visible_message("<span class='warning'>[user] hits \the [src] with \the [W].</span>")
		if(axe_hits >= 3)
			new/obj/item/weapon/grown/log(get_turf(src))
			qdel(src)

/obj/structure/snow_flora/tree/pine
	name = "pine tree"
	desc = "O Tannenbaum..."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"
	density = 1

	pixel_x = -16
	pixel_y = 0

/obj/structure/snow_flora/tree/pine/New()
	..()
	icon_state = pick(
		"pine_1",
		"pine_2",
		"pine_3",
		)
	/* No
	if((snow_tiles >= COSMICFREEZE_LEVEL_3) && prob(20))
		new /mob/living/simple_animal/hostile/giant_spider/spiderling(get_turf(src))

	if((snow_tiles >= COSMICFREEZE_LEVEL_5) && prob(20))
		new /mob/living/simple_animal/hostile/bear(get_turf(src))
	*/

/obj/structure/snow_flora/tree/pine/attackby(obj/item/W,mob/user)
	var/list/cutting = list(
		/obj/item/weapon/hatchet,
		/obj/item/weapon/fireaxe,
		)
	if(is_type_in_list(W,cutting))
		axe_hits++
		user.visible_message("<span class='warning'>[user] hits \the [src] with \the [W].</span>")
		if(axe_hits >= 5)
			new/obj/item/weapon/grown/log(get_turf(src))
			new/obj/item/weapon/grown/log(get_turf(src))
			new/obj/item/weapon/grown/log(get_turf(src))
			qdel(src)

/obj/structure/snow_flora/tree/pine/idle()
	/* Performance
	while(src && !src.gcDestroyed)
		if(!(locate(/obj/structure/snow) in get_turf(src)))
			axe_hits++
			if(axe_hits >= 5)
				new/obj/item/weapon/grown/log(get_turf(src))
				new/obj/item/weapon/grown/log(get_turf(src))
				new/obj/item/weapon/grown/log(get_turf(src))
				qdel(src)
				return
		sleep(TICK_JIGGLE(50 * snowTickMod))
	*/
	return

/obj/structure/snow_flora/tree/pine/xmas
	name = "christmas tree"
	desc = "Heck yeah!"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/snow_flora/tree/pine/xmas/New()
	..()
	icon_state = "pine_c"
	for(var/turf/simulated/floor/T in orange(1,src))
		var/blocked = 0
		for(var/atom/A in T)
			if(A.density)
				blocked = 1
		if(blocked)	continue

		for(var/i=1,i<=rand(1,3),i++)
			call(/obj/item/weapon/winter_gift/proc/pick_a_gift)(T,5)

#undef SNOWCOVERING_FULL
#undef SNOWCOVERING_MEDIUM
#undef SNOWCOVERING_LITTLE

#undef TICK_JIGGLE
