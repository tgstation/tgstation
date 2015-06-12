/**********************Mineral deposits**************************/

var/global/list/rockTurfEdgeCache
#define NORTH_EDGING	"north"
#define SOUTH_EDGING	"south"
#define EAST_EDGING		"east"
#define WEST_EDGING		"west"

/turf/simulated/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock_nochance"
	baseturf = /turf/simulated/floor/plating/asteroid
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = TCMB
	var/obj/mineralType = null
	var/mineralAmt = 3
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/last_act = 0
	var/scan_state = null //Holder for the image we display when we're pinged by a mining scanner
	var/hidden = 1

/turf/simulated/mineral/ex_act(severity, target)
	..()
	switch(severity)
		if(3.0)
			if (prob(75))
				src.gets_drilled(null, 1)
		if(2.0)
			if (prob(90))
				src.gets_drilled(null, 1)
		if(1.0)
			src.gets_drilled(null, 1)
	return

/turf/simulated/mineral/New()
	if(!rockTurfEdgeCache || !rockTurfEdgeCache.len)
		rockTurfEdgeCache = list()
		rockTurfEdgeCache.len = 4
		rockTurfEdgeCache[NORTH_EDGING] = image('icons/turf/mining.dmi', "rock_side_n", layer = 6)
		rockTurfEdgeCache[SOUTH_EDGING] = image('icons/turf/mining.dmi', "rock_side_s")
		rockTurfEdgeCache[EAST_EDGING] = image('icons/turf/mining.dmi', "rock_side_e", layer = 6)
		rockTurfEdgeCache[WEST_EDGING] = image('icons/turf/mining.dmi', "rock_side_w", layer = 6)

	spawn(1)
		var/turf/T
		if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)))
			T = get_step(src, NORTH)
			if (T)
				T.overlays += rockTurfEdgeCache[SOUTH_EDGING]
		if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)))
			T = get_step(src, SOUTH)
			if (T)
				T.overlays += rockTurfEdgeCache[NORTH_EDGING]
		if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)))
			T = get_step(src, EAST)
			if (T)
				T.overlays += rockTurfEdgeCache[WEST_EDGING]
		if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)))
			T = get_step(src, WEST)
			if (T)
				T.overlays += rockTurfEdgeCache[EAST_EDGING]

	if (mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in cardinal)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/simulated/mineral/random))
					Spread(T)

	HideRock()
	return

/turf/simulated/mineral/proc/HideRock()
	if(hidden)
		icon_state = "rock"
	return

/turf/simulated/mineral/proc/Spread(var/turf/T)
	new src.type(T)

/turf/simulated/mineral/random
	name = "mineral deposit"
	icon_state = "rock"
	var/mineralSpawnChanceList = list(
		"Uranium" = 5, "Diamond" = 1, "Gold" = 10,
		"Silver" = 12, "Plasma" = 20, "Iron" = 40,
		"Gibtonite" = 4, "Cave" = 2, "BScrystal" = 1,
		/*, "Adamantine" =5*/)
		//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 13

/turf/simulated/mineral/random/New()
	..()
	if (prob(mineralChance))
		var/mName = pickweight(mineralSpawnChanceList) //temp mineral name

		if (mName)
			var/turf/simulated/mineral/M
			switch(mName)
				if("Uranium")
					M = new/turf/simulated/mineral/uranium(src)
				if("Iron")
					M = new/turf/simulated/mineral/iron(src)
				if("Diamond")
					M = new/turf/simulated/mineral/diamond(src)
				if("Gold")
					M = new/turf/simulated/mineral/gold(src)
				if("Silver")
					M = new/turf/simulated/mineral/silver(src)
				if("Plasma")
					M = new/turf/simulated/mineral/plasma(src)
				if("Cave")
					new/turf/simulated/floor/plating/asteroid/airless/cave(src)
				if("Gibtonite")
					M = new/turf/simulated/mineral/gibtonite(src)
				if("Bananium")
					M = new/turf/simulated/mineral/clown(src)
				if("BScrystal")
					M = new/turf/simulated/mineral/bscrystal(src)
				/*if("Adamantine")
					M = new/turf/simulated/mineral/adamantine(src)*/
			if(M)
				src = M
				M.levelupdate()
	return

/turf/simulated/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 25
	mineralSpawnChanceList = list(
		"Uranium" = 35, "Diamond" = 30,
		"Gold" = 45, "Silver" = 50, "Plasma" = 50,
		"BScrystal" = 20)

/turf/simulated/mineral/random/high_chance/New()
	icon_state = "rock"
	..()

/turf/simulated/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 6
	mineralSpawnChanceList = list(
		"Uranium" = 2, "Diamond" = 1, "Gold" = 4,
		"Silver" = 6, "Plasma" = 15, "Iron" = 40,
		"Gibtonite" = 2, "BScrystal" = 1)

/turf/simulated/mineral/random/low_chance/New()
	icon_state = "rock"
	..()

/turf/simulated/mineral/iron
	name = "iron deposit"
	icon_state = "rock_Iron"
	mineralType = /obj/item/weapon/ore/iron
	spreadChance = 20
	spread = 1
	hidden = 0

/turf/simulated/mineral/uranium
	name = "uranium deposit"
	mineralType = /obj/item/weapon/ore/uranium
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Uranium"

/turf/simulated/mineral/diamond
	name = "diamond deposit"
	mineralType = /obj/item/weapon/ore/diamond
	spreadChance = 0
	spread = 1
	hidden = 1
	scan_state = "rock_Diamond"

/turf/simulated/mineral/gold
	name = "gold deposit"
	mineralType = /obj/item/weapon/ore/gold
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Gold"

/turf/simulated/mineral/silver
	name = "silver deposit"
	mineralType = /obj/item/weapon/ore/silver
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Silver"

/turf/simulated/mineral/plasma
	name = "plasma deposit"
	icon_state = "rock_Plasma"
	mineralType = /obj/item/weapon/ore/plasma
	spreadChance = 8
	spread = 1
	hidden = 1
	scan_state = "rock_Plasma"

/turf/simulated/mineral/clown
	name = "bananium deposit"
	icon_state = "rock_Clown"
	mineralType = /obj/item/weapon/ore/bananium
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	hidden = 0

/turf/simulated/mineral/bscrystal
	name = "bluespace crystal deposit"
	icon_state = "rock_BScrystal"
	mineralType = /obj/item/bluespace_crystal
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	hidden = 1
	scan_state = "rock_BScrystal"

////////////////////////////////Gibtonite
/turf/simulated/mineral/gibtonite
	name = "gibtonite deposit"
	icon_state = "rock_Gibtonite"
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	hidden = 1
	scan_state = "rock_Gibtonite"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = 0 //How far into the lifecycle of gibtonite we are, 0 is untouched, 1 is active and attempting to detonate, 2 is benign and ready for extraction
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null

/turf/simulated/mineral/gibtonite/New()
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	..()

/turf/simulated/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/mining_scanner) || istype(I, /obj/item/device/t_scanner/adv_mining_scanner) && stage == 1)
		user.visible_message("<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	..()

/turf/simulated/mineral/gibtonite/proc/explosive_reaction(var/mob/user = null, triggered_by_explosion = 0)
	if(stage == 0)
		icon_state = "rock_Gibtonite_active"
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = 1
		visible_message("<span class='danger'>There was gibtonite inside! It's going to explode!</span>")
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		if(user)
			activated_ckey = "[user.ckey]"
			activated_name = "[user.name]"
		var/notify_admins = 0
		if(z != 5)
			notify_admins = 1
			if(!triggered_by_explosion)
				message_admins("[src.activated_ckey]/([src.activated_name])<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has triggered a gibtonite deposit reaction at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else
				message_admins("An explosion has triggered a gibtonite deposit reaction at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")

		if(!triggered_by_explosion)
			log_game("[src.activated_ckey] ([src.activated_name]) has triggered a gibtonite deposit reaction at [A.name] ([A.x], [A.y], [A.z]).")
		else
			log_game("An explosion has triggered a gibtonite deposit reaction at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")

		countdown(notify_admins)

/turf/simulated/mineral/gibtonite/proc/countdown(notify_admins = 0)
	spawn(0)
		while(stage == 1 && det_time > 0 && mineralAmt >= 1)
			det_time--
			sleep(5)
		if(stage == 1 && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			explosion(bombturf,1,3,5, adminlog = notify_admins)
		if(stage == 0 || stage == 2)
			return

/turf/simulated/mineral/gibtonite/proc/defuse()
	if(stage == 1)
		icon_state = "rock_Gibtonite_inactive"
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = 2
		if(det_time < 0)
			det_time = 0
		visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [src.det_time] reactions left till the explosion!</span>")

/turf/simulated/mineral/gibtonite/gets_drilled(var/mob/user, triggered_by_explosion = 0)
	if(stage == 0 && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == 1 && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == 2) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/weapon/twohanded/required/gibtonite/G = new /obj/item/weapon/twohanded/required/gibtonite/(src)
		if(det_time <= 0)
			G.quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.quality = 2
			G.icon_state = "Gibtonite ore 2"
	var/turf/simulated/floor/plating/asteroid/airless/gibtonite_remains/G = ChangeTurf(/turf/simulated/floor/plating/asteroid/airless/gibtonite_remains)
	G.fullUpdateMineralOverlays()

/turf/simulated/floor/plating/asteroid/airless/gibtonite_remains
	var/det_time = 0
	var/stage = 0

////////////////////////////////End Gibtonite

/turf/simulated/floor/plating/asteroid/airless/cave
	var/length = 100
	var/mob_spawn_list = list("Goldgrub" = 1, "Goliath" = 5, "Basilisk" = 4, "Hivelord" = 3)
	var/sanity = 1

/turf/simulated/floor/plating/asteroid/airless/cave/New(loc, var/length, var/go_backwards = 1, var/exclude_dir = -1)

	// If length (arg2) isn't defined, get a random length; otherwise assign our length to the length arg.
	if(!length)
		src.length = rand(25, 50)
	else
		src.length = length

	// Get our directiosn
	var/forward_cave_dir = pick(alldirs - exclude_dir)
	// Get the opposite direction of our facing direction
	var/backward_cave_dir = angle2dir(dir2angle(forward_cave_dir) + 180)

	// Make our tunnels
	make_tunnel(forward_cave_dir)
	if(go_backwards)
		make_tunnel(backward_cave_dir)
	// Kill ourselves by replacing ourselves with a normal floor.
	SpawnFloor(src)
	..()

/turf/simulated/floor/plating/asteroid/airless/cave/proc/make_tunnel(var/dir)

	var/turf/simulated/mineral/tunnel = src
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IsOdd(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
			var/turf/simulated/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
			if(istype(edge))
				SpawnFloor(edge)

		// Move our tunnel forward
		tunnel = get_step(tunnel, dir)

		if(istype(tunnel))
			// Small chance to have forks in our tunnel; otherwise dig our tunnel.
			if(i > 3 && prob(20))
				new src.type(tunnel, rand(10, 15), 0, dir)
			else
				SpawnFloor(tunnel)
		else //if(!istype(tunnel, src.parent)) // We hit space/normal/wall, stop our tunnel.
			break

		// Chance to change our direction left or right.
		if(i > 2 && prob(33))
			// We can't go a full loop though
			next_angle = -next_angle
			dir = angle2dir(dir2angle(dir) + next_angle)


/turf/simulated/floor/plating/asteroid/airless/cave/proc/SpawnFloor(var/turf/T)
	for(var/turf/S in range(2,T))
		if(istype(S, /turf/space) || istype(S.loc, /area/mine/explored))
			sanity = 0
			break
	if(!sanity)
		return

	SpawnMonster(T)
	var/turf/simulated/floor/t = new /turf/simulated/floor/plating/asteroid/airless(T)
	spawn(2)
		t.fullUpdateMineralOverlays()

/turf/simulated/floor/plating/asteroid/airless/cave/proc/SpawnMonster(var/turf/T)
	if(prob(30))
		if(istype(loc, /area/mine/explored))
			return
		for(var/atom/A in range(15,T))//Lowers chance of mob clumps
			if(istype(A, /mob/living/simple_animal/hostile/asteroid))
				return
		var/randumb = pickweight(mob_spawn_list)
		switch(randumb)
			if("Goliath")
				new /mob/living/simple_animal/hostile/asteroid/goliath(T)
			if("Goldgrub")
				new /mob/living/simple_animal/hostile/asteroid/goldgrub(T)
			if("Basilisk")
				new /mob/living/simple_animal/hostile/asteroid/basilisk(T)
			if("Hivelord")
				new /mob/living/simple_animal/hostile/asteroid/hivelord(T)
	return

/turf/simulated/mineral/attackby(var/obj/item/weapon/pickaxe/P as obj, mob/user as mob, params)

	if (!user.IsAdvancedToolUser())
		usr << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	if (istype(P, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if(last_act+P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time
		user << "<span class='notice'>You start picking...</span>"
		P.playDigSound()

		if(do_after(user,P.digspeed))
			if(istype(src, /turf/simulated/mineral)) //sanity check against turf being deleted during digspeed delay
				user << "<span class='notice'>You finish cutting into the rock.</span>"
				P.update_icon()
				gets_drilled(user)
				feedback_add_details("pick_used_mining","[P.name]")
	else
		return attack_hand(user)
	return

/turf/simulated/mineral/proc/gets_drilled()
	if (mineralType && (src.mineralAmt > 0) && (src.mineralAmt < 11))
		var/i
		for (i=0;i<mineralAmt;i++)
			new mineralType(src)
		feedback_add_details("ore_mined","[mineralType.name]|[mineralAmt]")
	var/turf/simulated/floor/plating/asteroid/airless/N = ChangeTurf(/turf/simulated/floor/plating/asteroid/airless)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction
	N.fullUpdateMineralOverlays()
	return

/turf/simulated/mineral/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash >= 2)
		gets_drilled()
	..()

/*
/turf/simulated/mineral/proc/setRandomMinerals()
	var/s = pickweight(list("uranium" = 5, "iron" = 50, "gold" = 5, "silver" = 5, "plasma" = 50, "diamond" = 1))
	if (s)
		mineralName = s

	var/N = text2path("/turf/simulated/mineral/[s]")
	if (N)
		var/turf/simulated/mineral/M = new N
		src = M
		if (src.mineralName)
			mineralAmt = 5
	return*/

/turf/simulated/mineral/Bumped(AM as mob|obj)
	..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/weapon/pickaxe)) && (!H.hand))
			src.attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/weapon/pickaxe)) && H.hand)
			src.attackby(H.r_hand,H)
		return
	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			src.attackby(R.module_active,R)
			return
/*	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			src.attackby(M.selected,M)
			return*/
//Aparantly mechs are just TOO COOL to call Bump(), so fuck em (for now)
	else
		return

/**********************Asteroid**************************/

/turf/simulated/floor/plating/asteroid //floor piece
	name = "Asteroid"
	baseturf = /turf/simulated/floor/plating/asteroid
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	ignoredirt = 1

/turf/simulated/floor/plating/asteroid/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/plating/asteroid/New()
	var/proper_name = name
	..()
	name = proper_name
	//if (prob(50))
	//	seedName = pick(list("1","2","3","4"))
	//	seedAmt = rand(1,4)
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"
//	spawn(2)
//O		updateMineralOverlays()

/turf/simulated/floor/plating/asteroid/burn_tile()
	return

/turf/simulated/floor/plating/asteroid/ex_act(severity, target)
	contents_explosion(severity, target)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(20))
				src.gets_dug()
		if(1.0)
			src.gets_dug()
	return

/turf/simulated/floor/plating/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	//note that this proc does not call ..()
	if(!W || !user)
		return 0

	if ((istype(W, /obj/item/weapon/shovel)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "<span class='warning'>This area has already been dug!</span>"
			return

		user << "<span class='notice'>You start digging...</span>"
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1) //FUCK YO RUSTLE I GOT'S THE DIGS SOUND HERE

		sleep(20)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "<span class='notice'>You dig a hole.</span>"
			gets_dug()
			return

	if ((istype(W, /obj/item/weapon/pickaxe)))
		var/obj/item/weapon/pickaxe/P = W
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "<span class='warning'>This area has already been dug!</span>"
			return

		user << "<span class='notice'>You start digging...</span>"
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1) //FUCK YO RUSTLE I GOT'S THE DIGS SOUND HERE

		sleep(P.digspeed)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "<span class='notice'>You dig a hole.</span>"
			gets_dug()
			return

	if(istype(W,/obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/S = W
		if(S.collection_mode == 1)
			for(var/obj/item/weapon/ore/O in src.contents)
				O.attackby(W,user)
				return

	if(istype(W, /obj/item/stack/tile))
		var/obj/item/stack/tile/Z = W
		if(!Z.use(1))
			return
		var/turf/simulated/floor/T = ChangeTurf(Z.turf_type)
		if(istype(Z,/obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
			var/obj/item/stack/tile/light/L = Z
			var/turf/simulated/floor/light/F = T
			F.state = L.state
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/simulated/floor/plating/asteroid/proc/gets_dug()
	if(dug)
		return
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	dug = 1
	icon_plating = "asteroid_dug"
	icon_state = "asteroid_dug"
	return

/turf/proc/updateMineralOverlays()
	src.overlays.Cut()

	if(istype(get_step(src, NORTH), /turf/simulated/mineral))
		src.overlays += rockTurfEdgeCache[NORTH_EDGING]
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		src.overlays += rockTurfEdgeCache[SOUTH_EDGING]
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		src.overlays += rockTurfEdgeCache[EAST_EDGING]
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		src.overlays += rockTurfEdgeCache[WEST_EDGING]

/turf/simulated/mineral/updateMineralOverlays()
	return

/turf/proc/fullUpdateMineralOverlays()
	for (var/turf/t in range(1,src))
		t.updateMineralOverlays()


#undef NORTH_EDGING
#undef SOUTH_EDGING
#undef EAST_EDGING
#undef WEST_EDGING