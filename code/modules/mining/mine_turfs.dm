/**********************Mineral deposits**************************/
/datum/controller/game_controller
	var/list/artifact_spawning_turfs = list()

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
	var/mineralType = null
	var/mineralName = "" //Used for some display purposes
	var/mineralAmt = 3
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/last_act = 0
	var/scan_state = null //Holder for the image we display when we're pinged by a mining scanner
	var/hidden = 1
	var/datum/geosample/geologic_data
	var/excavation_level = 0
	var/list/finds = list()//no longer null to prevent those pesky runtime errors
	var/next_rock = 0
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/weapon/last_find
	var/datum/artifact_find/artifact_find

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
	mining_turfs += src
	..()
	spawn(1)
		var/turf/T
		if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)))
			T = get_step(src, NORTH)
			if (T)
				T.overlays += image('icons/turf/mining.dmi', "rock_side_s")
		if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)))
			T = get_step(src, SOUTH)
			if (T)
				T.overlays += image('icons/turf/mining.dmi', "rock_side_n", layer=6)
		if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)))
			T = get_step(src, EAST)
			if (T)
				T.overlays += image('icons/turf/mining.dmi', "rock_side_w", layer=6)
		if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)))
			T = get_step(src, WEST)
			if (T)
				T.overlays += image('icons/turf/mining.dmi', "rock_side_e", layer=6)

	if (mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in cardinal)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/simulated/mineral/random))
					Spread(T)

	HideRock()


/turf/simulated/mineral/Destroy()
	mining_turfs -= src
	..()

/turf/simulated/mineral/proc/HideRock()
	if(hidden)
		icon_state = "rock"
	return

/turf/simulated/mineral/proc/Spread(var/turf/T)
	T.ChangeTurf(src.type)

/turf/simulated/mineral/random
	name = "mineral deposit"
	icon_state = "rock"
	var/mineralSpawnChanceList = list("Uranium" = 5, "Diamond" = 2, "Gold" = 10, "Silver" = 12, "Plasma" = 20, "Iron" = 40, "Gibtonite" = 4/*, "Adamantine" =5*/, "Cave" = 2, "BScrystal" = 1,)//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 13

/turf/simulated/mineral/random/New()
	..()
	if (prob(mineralChance))
		var/mName = pickweight(mineralSpawnChanceList) //temp mineral name

		if (mName)
			var/M
			switch(mName)
				if("Uranium")
					M = /turf/simulated/mineral/uranium
				if("Iron")
					M = /turf/simulated/mineral/iron
				if("Diamond")
					M = /turf/simulated/mineral/diamond
				if("Gold")
					M = /turf/simulated/mineral/gold
				if("Silver")
					M = /turf/simulated/mineral/silver
				if("Plasma")
					M = /turf/simulated/mineral/plasma
				if("Cave")
					M = /turf/simulated/floor/plating/asteroid/airless/cave
				if("Gibtonite")
					M = /turf/simulated/mineral/gibtonite
				if("Bananium")
					M = /turf/simulated/mineral/clown
				if("BScrystal")
					M = /turf/simulated/mineral/bscrystal
				/*if("Adamantine")
					M = new/turf/simulated/mineral/adamantine(src)*/
			if(M)
				src.ChangeTurf(M)
				src.levelupdate()
	return

/turf/simulated/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 25
	mineralSpawnChanceList = list("Uranium" = 35, "Diamond" = 30, "Gold" = 45, "Silver" = 50, "Plasma" = 50, "BScrystal" = 20)

/turf/simulated/mineral/random/high_chance/New()
	icon_state = "rock"
	..()

/turf/simulated/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 6
	mineralSpawnChanceList = list("Uranium" = 2, "Diamond" = 1, "Gold" = 4, "Silver" = 6, "Plasma" = 15, "Iron" = 40, "Gibtonite" = 2, , "BScrystal" = 1)

/turf/simulated/mineral/random/low_chance/New()
	icon_state = "rock"
	..()


/turf/simulated/mineral/iron
	name = "iron deposit"
	icon_state = "rock_Iron"
	mineralType = /obj/item/weapon/ore/iron
	mineralName = "Iron"
	spreadChance = 20
	spread = 1
	hidden = 0

/turf/simulated/mineral/uranium
	name = "uranium deposit"
	mineralType = /obj/item/weapon/ore/uranium
	mineralName = "Uranium"
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Uranium"

/turf/simulated/mineral/diamond
	name = "diamond deposit"
	mineralType = /obj/item/weapon/ore/diamond
	mineralName = "Diamond"
	spreadChance = 0
	spread = 1
	hidden = 1
	scan_state = "rock_Diamond"

/turf/simulated/mineral/gold
	name = "gold deposit"
	mineralType = /obj/item/weapon/ore/gold
	mineralName = "Gold"
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Gold"

/turf/simulated/mineral/silver
	name = "silver deposit"
	mineralType = /obj/item/weapon/ore/silver
	mineralName = "Silver"
	spreadChance = 5
	spread = 1
	hidden = 1
	scan_state = "rock_Silver"

/turf/simulated/mineral/plasma
	name = "plasma deposit"
	icon_state = "rock_Plasma"
	mineralType = /obj/item/weapon/ore/plasma
	mineralName = "Plasma"
	spreadChance = 8
	spread = 1
	hidden = 1
	scan_state = "rock_Plasma"

/turf/simulated/mineral/clown
	name = "bananium deposit"
	icon_state = "rock_Clown"
	mineralType = /obj/item/weapon/ore/bananium
	mineralName = "Bananium"
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	hidden = 0

/turf/simulated/mineral/bscrystal
	name = "bluespace crystal deposit"
	icon_state = "rock_BScrystal"
	mineralType = /obj/item/bluespace_crystal
	mineralName = "Bluespace Crystal"
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
	if (istype(I, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = I
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if(last_act+P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time
		user << "<span class='notice'>You start picking...</span>"
		P.playDigSound()

		if(do_after(user,P.digspeed, target = src))
			if(istype(src, /turf/simulated/mineral)) //sanity check against turf being deleted during digspeed delay
				user << "<span class='notice'>You finish cutting into the rock.</span>"
				P.update_icon()
				gets_drilled(user)
	else
		return attack_hand(user)
	return


/turf/simulated/mineral/gibtonite/proc/explosive_reaction(var/mob/user = null, triggered_by_explosion = 0)
	if(stage == 0)
		icon_state = "rock_Gibtonite_active"
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = 1
		visible_message("<span class='warning'>There was gibtonite inside! It's going to explode!</span>")
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)

		var/notify_admins = 0
		if(z != 5)
			notify_admins = 1
			if(!triggered_by_explosion)
				message_admins("[key_name_admin(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) has triggered a gibtonite deposit reaction at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else
				message_admins("An explosion has triggered a gibtonite deposit reaction at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")

		if(!triggered_by_explosion)
			log_game("[key_name(user)] has triggered a gibtonite deposit reaction at [A.name] ([A.x], [A.y], [A.z]).")
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


/turf/simulated/mineral/gibtonite/gets_drilled(var/mob/user, triggered_by_explosion = 0, artifact_fail)
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
	lighting_build_overlays()
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
		if(istype(S, /turf/space) || istype(S.loc, /area/space/mine/explored))
			sanity = 0
			break
	if(!sanity)
		return

	SpawnMonster(T)
	var/turf/simulated/floor/t = T.ChangeTurf(/turf/simulated/floor/plating/asteroid/airless)
	spawn(2)
		t.fullUpdateMineralOverlays()
	spawn (300)
		t.lighting_fix_overlays()
		t.update_overlay()

/turf/simulated/floor/plating/asteroid/airless/cave/proc/SpawnMonster(var/turf/T)
	if(prob(30))
		if(istype(loc, /area/space/mine/explored))
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

/turf/simulated/mineral/attackby(var/obj/item/weapon/W as obj, mob/user as mob, params)

	if (!user.IsAdvancedToolUser())
		usr << "<span class='danger'>You don't have the dexterity to do this!</span>"
		return

	if (istype(W, /obj/item/device/core_sampler))
		if(!geologic_data)
			geologic_data = new/datum/geosample(src)
		geologic_data.UpdateNearbyArtifactInfo(src)
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = W
		user.visible_message("<span class='notice'>[user] extends [P] towards [src].</span>","<span class='notice'>You extend [P] towards [src].</span>")
		if(do_after(user,25, target = src))
			user << "<span class='notice'>\icon[P] [src] has been excavated to a depth of [2*excavation_level]cm.</span>"
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if(last_act+P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time


		var/fail_message = ""
		if(finds && finds.len)
			var/datum/find/F = finds[1]
			if(excavation_level + P.excavation_amount > F.excavation_required)
				fail_message = ", <b>[pick("there is a crunching noise","[W] collides with some different rock","part of the rock face crumbles away","something breaks under [W]")]</b>"

		user << "<span class='danger'>You start picking.</span>"

		if(fail_message && prob(90))
			if(prob(25))
				excavate_find(5, finds[1])
			else if(prob(50))
				finds.Remove(finds[1])
				if(prob(50))
					artifact_debris()
		P.playDigSound()

		if(do_after(user,P.digspeed, target = src))
			if(istype(src, /turf/simulated/mineral)) //sanity check against turf being deleted during digspeed delay
				user << "<span class='notice'>You finish cutting into the rock.</span>"
				if(finds && finds.len)
					var/datum/find/F = finds[1]
					if(round(excavation_level + P.excavation_amount) == F.excavation_required)

						if(excavation_level + P.excavation_amount > F.excavation_required)

							excavate_find(100, F)
						else
							excavate_find(80, F)

					else if(excavation_level + P.excavation_amount > F.excavation_required - F.clearance_range)

						excavate_find(0, F)

				if( excavation_level + P.excavation_amount >= 100 )
					var/obj/structure/boulder/B
					if(artifact_find)
						if( excavation_level > 0 || prob(15) )

							B = new(src)
							if(artifact_find)
								B.artifact_find = artifact_find
						else
							artifact_debris(1)

					else if(prob(15))
						B = new(src)

					if(B)
						gets_drilled(user, artifact_fail = 0)
					else
						gets_drilled(user, artifact_fail = 1)
					return

				excavation_level += P.excavation_amount
			if(istype(src, /turf/simulated/mineral))
				if(!archaeo_overlay && finds && finds.len)
					var/datum/find/F = finds[1]
					if(F.excavation_required <= excavation_level + F.view_range)
						archaeo_overlay = "overlay_archaeo[rand(1,3)]"
						overlays += archaeo_overlay

				var/update_excav_overlay = 0

				var/subtractions = 0
				while(excavation_level - 25*(subtractions + 1) >= 0 && subtractions < 3)
					subtractions++
				if(excavation_level - P.excavation_amount < subtractions * 25)
					update_excav_overlay = 1

				//update overlays displaying excavation level
				if( !(excav_overlay && excavation_level > 0) || update_excav_overlay )
					var/excav_quadrant = round(excavation_level / 25) + 1
					excav_overlay = "overlay_excv[excav_quadrant]_[rand(1,3)]"
					overlays += excav_overlay

			//drop some rocks
				next_rock += P.excavation_amount * 10
				while(next_rock > 100)
					next_rock -= 100
					var/obj/item/weapon/ore/O = new(src)
					if(!geologic_data)
						geologic_data = new/datum/geosample(src)
					geologic_data.UpdateNearbyArtifactInfo(src)
					O.geologic_data = geologic_data
					P.update_icon()
	else
		return attack_hand(user)
	return

/turf/simulated/mineral/proc/gets_drilled(var/mob/user, triggered_by_explosion = 0, var/artifact_fail = 0)
	if(artifact_find && artifact_fail)
		for(var/mob/living/M in range(src, 200))
			M << "<span class='userdanger'>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fading away!</span>"
			if(prob(50)) //pain
		//		flick("pain",M.pain)
				M.adjustBruteLoss(5)
			else
				flick("flash",M.flash)
				if(prob(50))
					M.Stun(5)
			M.apply_effect(25, IRRADIATE)
	if (mineralType && (src.mineralAmt > 0) && (src.mineralAmt < 11))
		var/i
		for (i=0;i<mineralAmt;i++)
			new mineralType(src)
		feedback_add_details("ore_mined","[mineralType]|[mineralAmt]")

	if(rand(1,1000) == 1)
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		DropAbandonedCrate()
	var/turf/simulated/floor/plating/asteroid/airless/N = ChangeTurf(/turf/simulated/floor/plating/asteroid/airless)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction
	N.fullUpdateMineralOverlays()

	return

/turf/simulated/mineral/proc/excavate_find(var/prob_clean = 0, var/datum/find/F)
	//with skill and luck, players can cleanly extract finds
	//otherwise, they come out inside a chunk of rock
	var/obj/item/weapon/X
	if(prob_clean)
		X = new /obj/item/weapon/archaeological_find(src, new_item_type = F.find_type)
	else
		X = new /obj/item/weapon/strangerock(src, inside_item_type = F.find_type)
		if(!geologic_data)
			geologic_data = new/datum/geosample(src)
		geologic_data.UpdateNearbyArtifactInfo(src)
		X:geologic_data = geologic_data

	//some find types delete the /obj/item/weapon/archaeological_find and replace it with something else, this handles when that happens
	//yuck
	var/display_name = "something"
	if(!X)
		X = last_find
	if(X)
		display_name = X.name

	//many finds are ancient and thus very delicate - luckily there is a specialised energy suspension field which protects them when they're being extracted
	if(prob(F.prob_delicate))
		var/obj/effect/suspension_field/S = locate() in src
		if(!S || S.field_type != get_responsive_reagent(F.find_type))
			if(X)
				visible_message("<span class='danger'>[pick("[display_name] crumbles away into dust","[display_name] breaks apart")].</span>")
				del(X)

	finds.Remove(F)

/turf/simulated/mineral/proc/DropAbandonedCrate()
	new /obj/structure/closet/crate/secure/loot(src)

/turf/simulated/mineral/proc/artifact_debris(var/severity = 0)
	for(var/j in 1 to rand(1, 3 + max(min(severity, 1), 0) * 2))
		switch(rand(1,6))
			if(1)
				var/obj/item/stack/rods/R = new(src)
				R.amount = rand(5,25)

			if(2)
				var/obj/item/stack/tile/R = new(src)
				R.amount = rand(1,5)

			if(3)
				var/obj/item/stack/sheet/metal/M = new/obj/item/stack/sheet/metal(src)
				M.amount = rand(5,25)

			if(4)
				var/obj/item/stack/sheet/plasteel/R = new(src)
				R.amount = rand(5,25)

			if(5)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					new/obj/item/weapon/shard(loc)

//			if(6)
//				var/quantity = rand(1,3)
//				for(var/i=0, i<quantity, i++)
//					getFromPool(/obj/item/weapon/shard/plasma, loc)

			if(6)
				var/obj/item/stack/sheet/mineral/uranium/R = new(src)
				R.amount = rand(5,25)

/turf/simulated/mineral/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash >= 2)
		gets_drilled(artifact_fail = 1)
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
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	baseturf = /turf/simulated/floor/plating/asteroid
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	ignoredirt = 1

/turf/simulated/floor/plating/asteroid/airless
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/plating/asteroid/New()
	var/proper_name = name
	mining_turfs += src
	..()
	name = proper_name
	//if (prob(50))
	//	seedName = pick(list("1","2","3","4"))
	//	seedAmt = rand(1,4)
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"
//	spawn(2)
//O		updateMineralOverlays()

/turf/simulated/floor/plating/Destroy()
	mining_turfs -= src
	..()

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
			user << "<span class='danger'>This area has already been dug.</span>"
			return

		user << "<span class='danger'>You start digging.</span>"
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1) //FUCK YO RUSTLE I GOT'S THE DIGS SOUND HERE

		sleep(20)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "<span class='notice'>You dug a hole.</span>"
			gets_dug()
			return

	if ((istype(W, /obj/item/weapon/pickaxe)))
		var/obj/item/weapon/pickaxe/P = W
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "<span class='danger'>This area has already been dug.</span>"
			return

		user << "<span class='danger'>You start digging.</span>"
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1) //FUCK YO RUSTLE I GOT'S THE DIGS SOUND HERE

		sleep(P.digspeed)
		if (!user)
			return
		if ((user.loc == T && user.get_active_hand() == W))
			user << "<span class='notice'>You dug a hole.</span>"
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
		src.overlays += image('icons/turf/mining.dmi', "rock_side_n")
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		src.overlays += image('icons/turf/mining.dmi', "rock_side_s", layer=6)
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		src.overlays += image('icons/turf/mining.dmi', "rock_side_e", layer=6)
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		src.overlays += image('icons/turf/mining.dmi', "rock_side_w", layer=6)

/turf/simulated/mineral/updateMineralOverlays()
	return

/turf/proc/fullUpdateMineralOverlays()
	for (var/turf/t in range(1,src))
		t.updateMineralOverlays()
