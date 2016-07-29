/**********************Mineral deposits**************************/

<<<<<<< HEAD
/turf/closed/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"
	var/smooth_icon = 'icons/turf/smoothrocks.dmi'
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/closed/mineral, /turf/closed/wall)
	baseturf = /turf/open/floor/plating/asteroid/airless
	initial_gas_mix = "TEMP=2.7"
	opacity = 1
	density = 1
	blocks_air = 1
	layer = EDGED_TURF_LAYER
	temperature = TCMB
	var/environment_type = "asteroid"
	var/turf/open/floor/plating/turf_type = /turf/open/floor/plating/asteroid/airless
	var/mineralType = null
	var/mineralAmt = 3
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/last_act = 0
	var/scan_state = null //Holder for the image we display when we're pinged by a mining scanner
	var/defer_change = 0

/turf/closed/mineral/New()
	pixel_y = -4
	pixel_x = -4
	icon = smooth_icon
	..()
	if (mineralType && mineralAmt && spread && spreadChance)
		for(var/dir in cardinal)
			if(prob(spreadChance))
				var/turf/T = get_step(src, dir)
				if(istype(T, /turf/closed/mineral/random))
					Spread(T)

/turf/closed/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt
	baseturf = /turf/open/floor/plating/asteroid/basalt
	initial_gas_mix = "o2=14;n2=23;TEMP=300"

/turf/closed/mineral/ex_act(severity, target)
	..()
	switch(severity)
		if(3)
			if (prob(75))
				src.gets_drilled(null, 1)
		if(2)
			if (prob(90))
				src.gets_drilled(null, 1)
		if(1)
			src.gets_drilled(null, 1)
	return

/turf/closed/mineral/Spread(turf/T)
	new src.type(T)

/turf/closed/mineral/random
	var/mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium = 5, /turf/closed/mineral/diamond = 1, /turf/closed/mineral/gold = 10,
		/turf/closed/mineral/silver = 12, /turf/closed/mineral/plasma = 20, /turf/closed/mineral/iron = 40, /turf/closed/mineral/titanium = 11,
		/turf/closed/mineral/gibtonite = 4, /turf/open/floor/plating/asteroid/airless/cave = 2, /turf/closed/mineral/bscrystal = 1)
		//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 13

/turf/closed/mineral/random/New()
	..()

	if (prob(mineralChance))
		var/path = pickweight(mineralSpawnChanceList)
		var/turf/T = new path(src)

		if(T && istype(T, /turf/closed/mineral))
			var/turf/closed/mineral/M = T
			M.mineralAmt = rand(1, 5)
			M.environment_type = src.environment_type
			M.turf_type = src.turf_type
			M.baseturf = src.baseturf
			src = M
			M.levelupdate()

/turf/closed/mineral/random/high_chance
	icon_state = "rock_highchance"
	mineralChance = 25
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium = 35, /turf/closed/mineral/diamond = 30, /turf/closed/mineral/gold = 45, /turf/closed/mineral/titanium = 45,
		/turf/closed/mineral/silver = 50, /turf/closed/mineral/plasma = 50, /turf/closed/mineral/bscrystal = 20)

/turf/closed/mineral/random/high_chance/New()
	icon_state = "rock"
	..()

/turf/closed/mineral/random/low_chance
	icon_state = "rock_lowchance"
	mineralChance = 6
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium = 2, /turf/closed/mineral/diamond = 1, /turf/closed/mineral/gold = 4, /turf/closed/mineral/titanium = 4,
		/turf/closed/mineral/silver = 6, /turf/closed/mineral/plasma = 15, /turf/closed/mineral/iron = 40,
		/turf/closed/mineral/gibtonite = 2, /turf/closed/mineral/bscrystal = 1)

/turf/closed/mineral/random/low_chance/New()
	icon_state = "rock"
	..()

/turf/closed/mineral/iron
	mineralType = /obj/item/weapon/ore/iron
	spreadChance = 20
	spread = 1
	scan_state = "rock_Iron"

/turf/closed/mineral/uranium
	mineralType = /obj/item/weapon/ore/uranium
	spreadChance = 5
	spread = 1
	scan_state = "rock_Uranium"

/turf/closed/mineral/diamond
	mineralType = /obj/item/weapon/ore/diamond
	spreadChance = 0
	spread = 1
	scan_state = "rock_Diamond"

/turf/closed/mineral/gold
	mineralType = /obj/item/weapon/ore/gold
	spreadChance = 5
	spread = 1
	scan_state = "rock_Gold"

/turf/closed/mineral/silver
	mineralType = /obj/item/weapon/ore/silver
	spreadChance = 5
	spread = 1
	scan_state = "rock_Silver"

/turf/closed/mineral/titanium
	mineralType = /obj/item/weapon/ore/titanium
	spreadChance = 5
	spread = 1
	scan_state = "rock_Titanium"

/turf/closed/mineral/plasma
	mineralType = /obj/item/weapon/ore/plasma
	spreadChance = 8
	spread = 1
	scan_state = "rock_Plasma"

/turf/closed/mineral/clown
	mineralType = /obj/item/weapon/ore/bananium
	mineralAmt = 3
	spreadChance = 0
	spread = 0
	scan_state = "rock_Clown"

/turf/closed/mineral/bscrystal
	mineralType = /obj/item/weapon/ore/bluespace_crystal
	mineralAmt = 1
	spreadChance = 0
	spread = 0
	scan_state = "rock_BScrystal"

////////////////////////////////Gibtonite
/turf/closed/mineral/gibtonite
	mineralAmt = 1
	spreadChance = 0
	spread = 0
=======
/datum/controller/game_controller
	var/list/artifact_spawning_turfs = list()

/turf/unsimulated/mineral //wall piece
	name = "Rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	//temperature = TCMB
	var/mineral/mineral
	var/mined_ore = 0
	var/last_act = 0
	var/datum/geosample/geologic_data
	var/excavation_level = 0
	var/list/finds = list()//no longer null to prevent those pesky runtime errors
//	var/next_rock = 0
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/weapon/last_find
	var/datum/artifact_find/artifact_find
	var/scan_state = null //Holder for the image we display when we're pinged by a mining scanner
	var/busy = 0 //Used for a bunch of do_after actions, because we can walk into the rock to trigger them

	var/mined_type = /turf/unsimulated/floor/asteroid

/turf/unsimulated/mineral/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
	mined_type = /turf/unsimulated/floor/asteroid/air

/turf/unsimulated/mineral/Destroy()
	return

/turf/unsimulated/mineral/New()
	mineral_turfs += src
	. = ..()
	MineralSpread()
	if(ticker)
		initialize()

turf/unsimulated/mineral/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = 0, var/allow = 1)
	mineral_turfs -= src
	return ..(N, tell_universe, 1, allow)

/turf/unsimulated/mineral/initialize()
	spawn(1)
		var/turf/T
		if((istype(get_step(src, NORTH), /turf/simulated/floor)) || (istype(get_step(src, NORTH), /turf/space)) || (istype(get_step(src, NORTH), /turf/simulated/shuttle/floor)))
			T = get_step(src, NORTH)
			if (T)
				T.overlays += image('icons/turf/walls.dmi', "rock_side_s")
		if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)) || (istype(get_step(src, SOUTH), /turf/simulated/shuttle/floor)))
			T = get_step(src, SOUTH)
			if (T)
				T.overlays += image('icons/turf/walls.dmi', "rock_side_n", layer=6)
		if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)) || (istype(get_step(src, EAST), /turf/simulated/shuttle/floor)))
			T = get_step(src, EAST)
			if (T)
				T.overlays += image('icons/turf/walls.dmi', "rock_side_w", layer=6)
		if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)) || (istype(get_step(src, WEST), /turf/simulated/shuttle/floor)))
			T = get_step(src, WEST)
			if (T)
				T.overlays += image('icons/turf/walls.dmi', "rock_side_e", layer=6)
	/*
	if (mineralName && mineralAmt && spread && spreadChance)
		for(var/trydir in list(1,2,4,8))
			if(prob(spreadChance))
				if(istype(get_step(src, trydir), /turf/unsimulated/mineral/random))
					var/turf/unsimulated/mineral/T = get_step(src, trydir)
					var/turf/unsimulated/mineral/M = new src.type(T)
					//keep any digsite data as constant as possible
					if(T.finds.len && !M.finds.len)
						M.finds = T.finds
						if(T.archaeo_overlay)
							M.overlays += archaeo_overlay


	//---- Xenoarchaeology BEGIN

	//put into spawn so that digsite data can be preserved over the turf replacements via spreading mineral veins
	spawn(0)
		if(mineralAmt > 0 && !excavation_minerals.len)
			for(var/i=0, i<mineralAmt, i++)
				excavation_minerals.Add(rand(5,95))
			excavation_minerals = insertion_sort_numeric_list_descending(excavation_minerals)

		if(!finds.len && prob(XENOARCH_SPAWN_CHANCE))
			//create a new archaeological deposit
			var/digsite = get_random_digsite_type()

			var/list/turfs_to_process = list(src)
			var/list/processed_turfs = list()
			while(turfs_to_process.len)
				var/turf/unsimulated/mineral/M = turfs_to_process[1]
				for(var/turf/unsimulated/mineral/T in orange(1, M))
					if(T.finds.len)
						continue
					if(T in processed_turfs)
						continue
					if(prob(XENOARCH_SPREAD_CHANCE))
						turfs_to_process.Add(T)

				turfs_to_process.Remove(M)
				processed_turfs.Add(M)
				if(!M.finds.len)
					if(prob(50))
						M.finds.Add(new/datum/find(digsite, rand(5,95)))
					else if(prob(75))
						M.finds.Add(new/datum/find(digsite, rand(5,45)))
						M.finds.Add(new/datum/find(digsite, rand(55,95)))
					else
						M.finds.Add(new/datum/find(digsite, rand(5,30)))
						M.finds.Add(new/datum/find(digsite, rand(35,75)))
						M.finds.Add(new/datum/find(digsite, rand(75,95)))

					//sometimes a find will be close enough to the surface to show
					var/datum/find/F = M.finds[1]
					if(F.excavation_required <= F.view_range)
						archaeo_overlay = "overlay_archaeo[rand(1,3)]"
						M.overlays += archaeo_overlay

			//dont create artifact machinery in animal or plant digsites, or if we already have one
			if(!artifact_find && digsite != 1 && digsite != 2 && prob(ARTIFACT_SPAWN_CHANCE))
				artifact_find = new()
				artifact_spawning_turfs.Add(src)

		if(!src.geological_data)
			src.geological_data = new/datum/geosample(src)
		src.geological_data.UpdateTurf(src)

		//for excavated turfs placeable in the map editor
		/*if(excavation_level > 0)
			if(excavation_level < 25)
				src.overlays += image('icons/obj/xenoarchaeology.dmi', "overlay_excv1_[rand(1,3)]")
			else if(excavation_level < 50)
				src.overlays += image('icons/obj/xenoarchaeology.dmi', "overlay_excv2_[rand(1,3)]")
			else if(excavation_level < 75)
				src.overlays += image('icons/obj/xenoarchaeology.dmi', "overlay_excv3_[rand(1,3)]")
			else
				src.overlays += image('icons/obj/xenoarchaeology.dmi', "overlay_excv4_[rand(1,3)]")
			desc = "It appears to be partially excavated."*/

	return
	*/

/turf/unsimulated/mineral/ex_act(severity)
	switch(severity)
		if(3.0)
			if (prob(75))
				GetDrilled()
		if(2.0)
			if (prob(90))
				GetDrilled()
		if(1.0)
			GetDrilled()


/turf/unsimulated/mineral/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(istype(H.get_active_hand(),/obj/item/weapon/pickaxe))
			attackby(H.get_active_hand(), H)
		else if(istype(H.get_inactive_hand(),/obj/item/weapon/pickaxe))
			attackby(H.get_inactive_hand(), H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			attackby(R.module_active, R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)

/turf/unsimulated/mineral/proc/MineralSpread()
	if(mineral && mineral.spread)
		for(var/trydir in cardinal)
			if(prob(mineral.spread_chance))
				var/turf/unsimulated/mineral/random/target_turf = get_step(src, trydir)
				if(istype(target_turf) && !target_turf.mineral)
					target_turf.mineral = mineral
					target_turf.UpdateMineral()
					target_turf.MineralSpread()

/turf/unsimulated/mineral/proc/UpdateMineral()
	icon_state = "rock"
	if(!mineral)
		name = "\improper Rock"
		return
	name = "\improper [mineral.display_name] deposit"
	icon_state = "rock_[mineral.name]"

/turf/unsimulated/mineral/proc/updateMineralOverlays()
	// TODO: Figure out what this is supposed to do.
	return

/turf/unsimulated/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(busy)
		return

	if (!usr.dexterity_check())
		to_chat(usr, "<span class='warning>You don't have the dexterity to do this!</span>")
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
		busy = 1
		if(do_after(user, src,25))
			to_chat(user, "<span class='notice'>[bicon(P)] [src] has been excavated to a depth of [2*excavation_level]cm.</span>")
			busy = 0
		else
			busy = 0
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		if(user.loc != get_turf(user))
			return //if we aren't in the tile we are located in, return

		var/obj/item/weapon/pickaxe/P = W

		if(!istype(P))
			return

		if(!(P.diggables & DIG_ROCKS))
			return

		if(last_act + P.digspeed > world.time)//prevents message spam
			return

		last_act = world.time

		playsound(user, P.drill_sound, 20, 1)

		//handle any archaeological finds we might uncover
		var/fail_message = ""
		if(finds && finds.len)
			var/datum/find/F = finds[1]
			if(excavation_level + P.excavation_amount > F.excavation_required)

				fail_message = ", <b>[pick("there is a crunching noise","[W] collides with some different rock","part of the rock face crumbles away","something breaks under [W]")]</b>"

		to_chat(user, "<span class='rose'>You start [P.drill_verb][fail_message].</span>")

		if(fail_message && prob(90))
			if(prob(25))
				excavate_find(5, finds[1])
			else if(prob(50))
				finds.Remove(finds[1])
				if(prob(50))
					artifact_debris()

		busy = 1

		if(do_after(user, src, P.digspeed) && user)
			to_chat(user, "<span class='notice'>You finish [P.drill_verb] the rock.</span>")

			busy = 0

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

						B = getFromPool(/obj/structure/boulder, src)
						if(artifact_find)
							B.artifact_find = artifact_find
					else
						artifact_debris(1)

				else if(prob(15))
					B = getFromPool(/obj/structure/boulder, src)

				var/mineral/has_minerals = mineral
				if(B)
					GetDrilled(0)
				else
					GetDrilled(1)

				if(!B && !has_minerals)
					var/I = rand(1,500)
					if(I == 1)
						switch(polarstar)
							if(0)
								new/obj/item/weapon/gun/energy/polarstar(src)
								polarstar = 1
								visible_message("<span class='notice'>A gun was buried within!</span>")
							if(1)
								new/obj/item/device/modkit/spur_parts(src)
								visible_message("<span class='notice'>Something came out of the wall! Looks like scrap metal.</span>")
								polarstar = 2
				return

			if(finds && finds.len)
				var/I = rand(1,100)
				if(I == 1)
					switch(polarstar)
						if(0)
							new/obj/item/weapon/gun/energy/polarstar(src)
							polarstar = 1
							visible_message("<span class='notice'>A gun was buried within!</span>")
						if(1)
							new/obj/item/device/modkit/spur_parts(src)
							visible_message("<span class='notice'>Something came out of the wall! Looks like scrap metal.</span>")
							polarstar = 2

			excavation_level += P.excavation_amount

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
/*
			//drop some rocks
			next_rock += P.excavation_amount * 10
			while(next_rock > 100)
				next_rock -= 100
				var/obj/item/weapon/ore/O = new(src)
				if(!geologic_data)
					geologic_data = new/datum/geosample(src)
				geologic_data.UpdateNearbyArtifactInfo(src)
				O.geologic_data = geologic_data
*/

		else //Note : If the do_after() fails
			busy = 0

	else
		return attack_hand(user)

/turf/unsimulated/mineral/proc/DropMineral()
	if(!mineral)
		return

	var/obj/item/weapon/ore/O = new mineral.ore (src)
	if(istype(O))
		if(!geologic_data)
			geologic_data = new/datum/geosample(src)
		geologic_data.UpdateNearbyArtifactInfo(src)
		O.geologic_data = geologic_data
	return O

/turf/unsimulated/mineral/proc/GetDrilled(var/artifact_fail = 0)
	if (mineral && mineral.result_amount)
		for (var/i = 1 to mineral.result_amount - mined_ore)
			DropMineral()

	//destroyed artifacts have weird, unpleasant effects
	//make sure to destroy them before changing the turf though
	if(artifact_find && artifact_fail)
		for(var/mob/living/M in range(src, 200))
			to_chat(M, "<font color='red'><b>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fading away!</b></font>")
			if(prob(50)) //pain
				flick("pain",M.pain)
				if(prob(50))
					M.adjustBruteLoss(5)
			else
				M.flash_eyes(visual = 1)
				if(prob(50))
					M.Stun(5)
			M.apply_effect(25, IRRADIATE)

	if(rand(1,500) == 1)
		visible_message("<span class='notice'>An old dusty crate was buried within!</span>")
		DropAbandonedCrate()

	var/turf/unsimulated/floor/asteroid/N = ChangeTurf(mined_type)
	N.fullUpdateMineralOverlays()

/turf/unsimulated/mineral/proc/DropAbandonedCrate()
	var/crate_type = pick(valid_abandoned_crate_types)
	new crate_type(src)

/turf/unsimulated/mineral/proc/excavate_find(var/prob_clean = 0, var/datum/find/F)
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
				qdel(X)
				X = null

	finds.Remove(F)

/turf/unsimulated/mineral/proc/artifact_debris(var/severity = 0)
	for(var/j in 1 to rand(1, 3 + max(min(severity, 1), 0) * 2))
		switch(rand(1,7))
			if(1)
				var/obj/item/stack/rods/R = new(src)
				R.amount = rand(5,25)

			if(2)
				var/obj/item/stack/tile/plasteel/R = new(src)
				R.amount = rand(1,5)

			if(3)
				var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, (src))
				M.amount = rand(5,25)

			if(4)
				var/obj/item/stack/sheet/plasteel/R = new(src)
				R.amount = rand(5,25)

			if(5)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					getFromPool(/obj/item/weapon/shard, loc)

			if(6)
				var/quantity = rand(1,3)
				for(var/i=0, i<quantity, i++)
					getFromPool(/obj/item/weapon/shard/plasma, loc)

			if(7)
				var/obj/item/stack/sheet/mineral/uranium/R = new(src)
				R.amount = rand(5,25)


/**********************Asteroid**************************/

/turf/unsimulated/floor/airless //floor piece
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/unsimulated/floor/asteroid //floor piece
	name = "Asteroid"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	//icon_plating = "asteroid"
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug

/turf/unsimulated/floor/asteroid/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C

/turf/unsimulated/floor/asteroid/New()
	var/proper_name = name
	..()

	name = proper_name

	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"
	if(ticker)
		initialize()

/turf/unsimulated/floor/asteroid/initialize()
	updateMineralOverlays()

/turf/unsimulated/floor/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				gets_dug()
		if(1.0)
			gets_dug()
	return

/turf/unsimulated/floor/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(!W || !user)
		return 0

	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/used_digging = W //cast for dig speed and flags
		if (get_turf(user) != user.loc) //if we aren't somehow on the turf we're in
			return

		if(!(used_digging.diggables & DIG_SOIL)) //if the pickaxe can't dig soil, we don't
			to_chat(user, "<span class='rose'>You can't dig soft soil with \the [W].</span>")
			return

		if (dug)
			to_chat(user, "<span class='rose'>This area has already been dug.</span>")
			return

		to_chat(user, "<span class='rose'>You start digging.<span>")
		playsound(get_turf(src), 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		if(do_after(user, src, used_digging.digspeed) && user) //the better the drill, the faster the digging
			playsound(src, 'sound/items/shovel.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You dug a hole.</span>")
			gets_dug()

	else
		..(W,user)
	return

/turf/unsimulated/floor/asteroid/proc/gets_dug()
	if(dug)
		return
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	dug = 1
	//icon_plating = "asteroid_dug"
	icon_state = "asteroid_dug"
	return

/turf/unsimulated/floor/asteroid/proc/updateMineralOverlays()
	src.overlays.len = 0
	spawn(1)
		for(var/dir in cardinal)
			if(istype(get_step(src,dir), /turf/unsimulated/mineral))
				switch(dir)
					if(NORTH)
						src.overlays += image('icons/turf/walls.dmi', "rock_side_n")
					if(SOUTH)
						src.overlays += image('icons/turf/walls.dmi', "rock_side_s", layer=6)
					if(EAST)
						src.overlays += image('icons/turf/walls.dmi', "rock_side_e", layer=6)
					if(WEST)
						src.overlays += image('icons/turf/walls.dmi', "rock_side_w", layer=6)

/turf/unsimulated/floor/asteroid/proc/fullUpdateMineralOverlays()
	var/turf/unsimulated/floor/asteroid/A
	if(istype(get_step(src, WEST), /turf/unsimulated/floor/asteroid))
		A = get_step(src, WEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, EAST), /turf/unsimulated/floor/asteroid))
		A = get_step(src, EAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTH), /turf/unsimulated/floor/asteroid))
		A = get_step(src, NORTH)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHWEST), /turf/unsimulated/floor/asteroid))
		A = get_step(src, NORTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHEAST), /turf/unsimulated/floor/asteroid))
		A = get_step(src, NORTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHWEST), /turf/unsimulated/floor/asteroid))
		A = get_step(src, SOUTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHEAST), /turf/unsimulated/floor/asteroid))
		A = get_step(src, SOUTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTH), /turf/unsimulated/floor/asteroid))
		A = get_step(src, SOUTH)
		A.updateMineralOverlays()
	src.updateMineralOverlays()

/turf/unsimulated/mineral/random
	name = "Mineral deposit"
	var/mineralSpawnChanceList = list(
		"Iron"      = 50,
		"Plasma"    = 25,
		"Uranium"   = 5,
		"Gold"      = 5,
		"Silver"    = 5,
		"Gibtonite" = 5,
		"Diamond"   = 1,
		"Cave"      = 1,
		/*
		"Pharosium"  = 5,
		"Char"  = 5,
		"Claretine"  = 5,
		"Bohrum"  = 5,
		"Syreline"  = 5,
		"Erebite"  = 5,
		"Uqill"  = 5,
		"Telecrystal"  = 5,
		"Mauxite"  = 5,
		"Cobryl"  = 5,
		"Cerenkite"  = 5,
		"Molitz"  = 5,
		"Cytine"  = 5
		*/
	)
	//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 10  //means 10% chance of this plot changing to a mineral deposit

/turf/unsimulated/mineral/random/New()
	icon_state = "rock"
	if (prob(mineralChance) && !mineral)
		var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name

		if(!name_to_mineral)
			SetupMinerals()

		if (mineral_name)
			if(mineral_name in name_to_mineral)
				mineral = name_to_mineral[mineral_name]
				mineral.UpdateTurf(src)
			else
				warning("Unknown mineral ID: [mineral_name]")

	. = ..()

/turf/unsimulated/mineral/random/high_chance
	icon_state = "rock(high)"
	mineralChance = 25
	mineralSpawnChanceList = list(
		"Uranium" = 10,
		"Iron"    = 30,
		"Diamond" = 2,
		"Gold"    = 10,
		"Silver"  = 10,
		"Plasma"  = 25,
		/*
		"Pharosium"  = 5,
		"Char"  = 5,
		"Claretine"  = 5,
		"Bohrum"  = 5,
		"Syreline"  = 5,
		"Erebite"  = 5,
		"Uqill"  = 5,
		"Telecrystal"  = 5,
		"Mauxite"  = 5,
		"Cobryl"  = 5,
		"Cerenkite"  = 5,
		"Molitz"  = 5,
		"Cytine"  = 5
		*/
	)

/turf/unsimulated/mineral/random/high_chance_clown
	icon_state = "rock(clown)"
	mineralChance = 40
	mineralSpawnChanceList = list(
		"Uranium" = 10,
		//"Iron"    = 10,
		"Diamond" = 2,
		"Gold"    = 5,
		"Silver"  = 5,
		/*
		"Pharosium"  = 1,
		"Char"  = 1,
		"Claretine"  = 1,
		"Bohrum"  = 1,
		"Syreline"  = 1,
		"Erebite"  = 1,
		"Uqill"  = 1,
		"Telecrystal"  = 1,
		"Mauxite"  = 1,
		"Cobryl"  = 1,
		"Cerenkite"  = 1,
		"Molitz"  = 1,
		"Cytine"  = 1,
		*/
		"Plasma"  = 25,
		"Clown"   = 15,
		"Phazon"  = 10
	)

/turf/unsimulated/mineral/random/Destroy()
	return

/turf/unsimulated/mineral/uranium
	name = "Uranium deposit"
	icon_state = "rock_Uranium"
	mineral = new /mineral/uranium
	scan_state = "rock_Uranium"


/turf/unsimulated/mineral/iron
	name = "Iron deposit"
	icon_state = "rock_Iron"
	mineral = new /mineral/iron


/turf/unsimulated/mineral/diamond
	name = "Diamond deposit"
	icon_state = "rock_Diamond"
	mineral = new /mineral/diamond
	scan_state = "rock_Diamond"


/turf/unsimulated/mineral/gold
	name = "Gold deposit"
	icon_state = "rock_Gold"
	mineral = new /mineral/gold
	scan_state = "rock_Gold"


/turf/unsimulated/mineral/silver
	name = "Silver deposit"
	icon_state = "rock_Silver"
	mineral = new /mineral/silver
	scan_state = "rock_Silver"


/turf/unsimulated/mineral/plasma
	name = "Plasma deposit"
	icon_state = "rock_Plasma"
	mineral = new /mineral/plasma
	scan_state = "rock_Plasma"


/turf/unsimulated/mineral/clown
	name = "Bananium deposit"
	icon_state = "rock_Clown"
	mineral = new /mineral/clown
	scan_state = "rock_Clown"


/turf/unsimulated/mineral/phazon
	name = "Phazite deposit"
	icon_state = "rock_Phazon"
	mineral = new /mineral/phazon
	scan_state = "rock_Phazon"

/turf/unsimulated/mineral/pharosium
	name = "Pharosium deposit"
	icon_state = "rock_Pharosium"
	mineral = new /mineral/pharosium

/turf/unsimulated/mineral/char
	name = "Char deposit"
	icon_state = "rock_Char"
	mineral = new /mineral/char

/turf/unsimulated/mineral/claretine
	name = "Claretine deposit"
	icon_state = "rock_Claretine"
	mineral = new /mineral/claretine

/turf/unsimulated/mineral/bohrum
	name = "Bohrum deposit"
	icon_state = "rock_Bohrum"
	mineral = new /mineral/bohrum

/turf/unsimulated/mineral/syreline
	name = "Syreline deposit"
	icon_state = "rock_Syreline"
	mineral = new /mineral/syreline

/turf/unsimulated/mineral/erebite
	name = "Erebite deposit"
	icon_state = "rock_Erebite"
	mineral = new /mineral/erebite

/turf/unsimulated/mineral/cytine
	name = "Cytine deposit"
	icon_state = "rock_Cytine"
	mineral = new /mineral/cytine

/turf/unsimulated/mineral/uqill
	name = "Uqill deposit"
	icon_state = "rock_Uqill"
	mineral = new /mineral/uqill

/turf/unsimulated/mineral/telecrystal
	name = "Telecrystal deposit"
	icon_state = "rock_Telecrystal"
	mineral = new /mineral/telecrystal

/turf/unsimulated/mineral/mauxite
	name = "Mauxite deposit"
	icon_state = "rock_Mauxite"
	mineral = new /mineral/mauxite

/turf/unsimulated/mineral/cobryl
	name = "Cobryl deposit"
	icon_state = "rock_Cobryl"
	mineral = new /mineral/cobryl

/turf/unsimulated/mineral/cerenkite
	name = "Cerenkite deposit"
	icon_state = "rock_Cerenkite"
	mineral = new /mineral/cerenkite

/turf/unsimulated/mineral/molitz
	name = "Molitz deposit"
	icon_state = "rock_Molitz"
	mineral = new /mineral/molitz

////////////////////////////////Gibtonite
/turf/unsimulated/mineral/gibtonite
	name = "Diamond deposit" //honk
	icon_state = "rock_Gibtonite"
	mineral = new /mineral/gibtonite
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	scan_state = "rock_Gibtonite"
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = 0 //How far into the lifecycle of gibtonite we are, 0 is untouched, 1 is active and attempting to detonate, 2 is benign and ready for extraction
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
<<<<<<< HEAD
	var/activated_image = null

/turf/closed/mineral/gibtonite/New()
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	..()

/turf/closed/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/mining_scanner) || istype(I, /obj/item/device/t_scanner/adv_mining_scanner) && stage == 1)
		user.visible_message("<span class='notice'>[user] holds [I] to [src]...</span>", "<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	..()

/turf/closed/mineral/gibtonite/proc/explosive_reaction(mob/user = null, triggered_by_explosion = 0)
	if(stage == 0)
		var/image/I = image('icons/turf/smoothrocks.dmi', loc = src, icon_state = "rock_Gibtonite_active", layer = ON_EDGED_TURF_LAYER)
		add_overlay(I)
		activated_image = I
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = 1
		visible_message("<span class='danger'>There was gibtonite inside! It's going to explode!</span>")
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

/turf/closed/mineral/gibtonite/proc/countdown(notify_admins = 0)
	set waitfor = 0
	while(istype(src, /turf/closed/mineral/gibtonite) && stage == 1 && det_time > 0 && mineralAmt >= 1)
		det_time--
		sleep(5)
	if(istype(src, /turf/closed/mineral/gibtonite))
		if(stage == 1 && det_time <= 0 && mineralAmt >= 1)
			var/turf/bombturf = get_turf(src)
			mineralAmt = 0
			stage = 3
			explosion(bombturf,1,3,5, adminlog = notify_admins)

/turf/closed/mineral/gibtonite/proc/defuse()
	if(stage == 1)
		overlays -= activated_image
		var/image/I = image('icons/turf/smoothrocks.dmi', loc = src, icon_state = "rock_Gibtonite_inactive", layer = ON_EDGED_TURF_LAYER)
		add_overlay(I)
=======

/turf/unsimulated/mineral/gibtonite/New()
	icon_state="rock_Diamond"
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	..()

/turf/unsimulated/mineral/gibtonite/Bumped(AM)
	var/bump_reject = 0
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.get_active_hand(),/obj/item/weapon/pickaxe) || istype(H.get_inactive_hand(),/obj/item/weapon/pickaxe)) && src.stage == 1)
			to_chat(H, "<span class='warning'>You don't think that's a good idea...</span>")
			bump_reject = 1

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active, /obj/item/weapon/pickaxe))
			to_chat(R, "<span class='warning'>You don't think that's a good idea...</span>")
			bump_reject = 1
		else if(istype(R.module_active, /obj/item/device/mining_scanner))
			attackby(R.module_active, R) //let's bump to disable. This is kinder, because borgs need some love

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected, /obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.occupant_message("<span class='warning'>Safety features prevent this action.</span>")
			bump_reject = 1

	if(!bump_reject) //if we haven't been pushed off, we do the drilling bit
		return ..()

/turf/unsimulated/mineral/gibtonite/attackby(obj/item/I, mob/user)
	if(((istype(I, /obj/item/device/mining_scanner)) || (istype(I, /obj/item/device/depth_scanner))) && stage == 1)
		user.visible_message("<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	if(istype(I, /obj/item/weapon/pickaxe))
		src.activated_ckey = "[user.ckey]"
		src.activated_name = "[user.name]"
	..()

/turf/unsimulated/mineral/gibtonite/proc/explosive_reaction()
	if(stage == 0)
		icon_state = "rock_Gibtonite_active"
		name = "Gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = 1
		visible_message("<span class='warning'>There was gibtonite inside! It's going to explode!</span>")
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		var/log_str = "[src.activated_ckey]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> [src.activated_name] has triggered a gibtonite deposit reaction <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>."
		log_game(log_str)
		countdown()

/turf/unsimulated/mineral/gibtonite/proc/countdown()
	spawn(0)
		while(stage == 1 && det_time > 0 && mineral.result_amount >= 1)
			det_time--
			sleep(5)
		if(stage == 1 && det_time <= 0 && mineral.result_amount >= 1)
			var/turf/bombturf = get_turf(src)
			mineral.result_amount = 0
			explosion(bombturf,1,3,5, adminlog = 0)
		if(stage == 0 || stage == 2)
			return

/turf/unsimulated/mineral/gibtonite/proc/defuse()
	if(stage == 1)
		icon_state = "rock_Gibtonite" //inactive does not exist. The other icon is active.
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = 2
		if(det_time < 0)
			det_time = 0
		visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [src.det_time] reactions left till the explosion!</span>")

<<<<<<< HEAD
/turf/closed/mineral/gibtonite/gets_drilled(mob/user, triggered_by_explosion = 0)
	if(stage == 0 && mineralAmt >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == 1 && mineralAmt >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineralAmt = 0
		stage = 3
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == 2) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/weapon/twohanded/required/gibtonite/G = new /obj/item/weapon/twohanded/required/gibtonite/(src)
=======
/turf/unsimulated/mineral/gibtonite/GetDrilled()
	if(stage == 0 && mineral.result_amount >= 1) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction()
		return
	if(stage == 1 && mineral.result_amount >= 1) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		mineral.result_amount = 0
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == 2) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/weapon/gibtonite/G = new /obj/item/weapon/gibtonite/(src)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		if(det_time <= 0)
			G.quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.quality = 2
			G.icon_state = "Gibtonite ore 2"
<<<<<<< HEAD

	ChangeTurf(turf_type, defer_change)
	spawn(10)
		AfterChange()

/turf/closed/mineral/gibtonite/volcanic
	initial_gas_mix = "o2=14;n2=23;TEMP=300"

////////////////////////////////End Gibtonite

/turf/open/floor/plating/asteroid/airless/cave
	var/length = 100
	var/mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goldgrub = 1, /mob/living/simple_animal/hostile/asteroid/goliath = 5, /mob/living/simple_animal/hostile/asteroid/basilisk = 4, /mob/living/simple_animal/hostile/asteroid/hivelord = 3)
	var/sanity = 1
	turf_type = /turf/open/floor/plating/asteroid/airless

/turf/open/floor/plating/asteroid/airless/cave/volcanic
	mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goldgrub = 10, /mob/living/simple_animal/hostile/asteroid/goliath/beast = 50, /mob/living/simple_animal/hostile/asteroid/basilisk/watcher = 40, /mob/living/simple_animal/hostile/asteroid/hivelord/legion = 30,
		/mob/living/simple_animal/hostile/spawner/lavaland = 2, /mob/living/simple_animal/hostile/spawner/lavaland/goliath = 3, /mob/living/simple_animal/hostile/spawner/lavaland/legion = 3, \
		/mob/living/simple_animal/hostile/megafauna/dragon = 2, /mob/living/simple_animal/hostile/megafauna/bubblegum = 2, /mob/living/simple_animal/hostile/megafauna/colossus = 2)

	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"

/turf/open/floor/plating/asteroid/airless/cave/New(loc, length, go_backwards = 1, exclude_dir = -1)
=======
	var/turf/unsimulated/floor/asteroid/gibtonite_remains/G = ChangeTurf(/turf/unsimulated/floor/asteroid/gibtonite_remains)
	G.fullUpdateMineralOverlays()

/turf/unsimulated/floor/asteroid/gibtonite_remains
	var/det_time = 0
	var/stage = 0

////////////////////////////////End Gibtonite

/turf/unsimulated/floor/asteroid/cave
	var/length = 100
	var/mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath  = 5,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 1,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 3,
		/mob/living/simple_animal/hostile/asteroid/hivelord = 5
	)
	var/sanity = 1

/turf/unsimulated/floor/asteroid/cave/New(loc, var/length, var/go_backwards = 1, var/exclude_dir = -1)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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

<<<<<<< HEAD
/turf/open/floor/plating/asteroid/airless/cave/proc/make_tunnel(dir)

	var/turf/closed/mineral/tunnel = src
=======
/turf/unsimulated/floor/asteroid/cave/proc/make_tunnel(var/dir)


	var/turf/unsimulated/mineral/tunnel = src
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/next_angle = pick(45, -45)

	for(var/i = 0; i < length; i++)
		if(!sanity)
			break

		var/list/L = list(45)
		if(IsOdd(dir2angle(dir))) // We're going at an angle and we want thick angled tunnels.
			L += -45

		// Expand the edges of our tunnel
		for(var/edge_angle in L)
<<<<<<< HEAD
			var/turf/closed/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
=======
			var/turf/unsimulated/mineral/edge = get_step(tunnel, angle2dir(dir2angle(dir) + edge_angle))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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
<<<<<<< HEAD
			setDir(angle2dir(dir2angle(dir) )+ next_angle)


/turf/open/floor/plating/asteroid/airless/cave/proc/SpawnFloor(turf/T)
	for(var/turf/S in range(2,T))
		if(istype(S, /turf/open/space) || istype(S.loc, /area/mine/explored))
=======
			dir = angle2dir(dir2angle(dir) + next_angle)

/turf/unsimulated/floor/asteroid/cave/proc/SpawnFloor(var/turf/T)
	for(var/turf/S in range(2,T))
		if(istype(S, /turf/space) || istype(S.loc, /area/mine/explored))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			sanity = 0
			break
	if(!sanity)
		return

	SpawnMonster(T)
<<<<<<< HEAD
	new turf_type(T)
/turf/open/floor/plating/asteroid/airless/cave/proc/SpawnMonster(turf/T)
	if(prob(30))
		if(istype(loc, /area/mine/explored) || istype(loc, /area/lavaland/surface/outdoors/explored))
			return
		for(var/atom/A in urange(12,T))//Lowers chance of mob clumps
=======

	new /turf/unsimulated/floor/asteroid(T)

/turf/unsimulated/floor/asteroid/cave/proc/SpawnMonster(var/turf/T)
	if(prob(2))
		if(istype(loc, /area/mine/explored))
			return
		for(var/atom/A in range(7,T))//Lowers chance of mob clumps
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
			if(istype(A, /mob/living/simple_animal/hostile/asteroid))
				return
		var/randumb = pickweight(mob_spawn_list)
		new randumb(T)
	return

<<<<<<< HEAD
/turf/closed/mineral/attackby(obj/item/weapon/pickaxe/P, mob/user, params)

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

		if(do_after(user,P.digspeed, target = src))
			if(istype(src, /turf/closed/mineral))
				user << "<span class='notice'>You finish cutting into the rock.</span>"
				gets_drilled(user)
				feedback_add_details("pick_used_mining","[P.type]")
	else
		return attack_hand(user)
	return

/turf/closed/mineral/proc/gets_drilled()
	if (mineralType && (src.mineralAmt > 0) && (src.mineralAmt < 11))
		var/i
		for (i=0;i<mineralAmt;i++)
			new mineralType(src)
		feedback_add_details("ore_mined","[mineralType]|[mineralAmt]")
	ChangeTurf(turf_type, defer_change)
	spawn(10)
		AfterChange()
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction
	return

/turf/closed/mineral/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash >= 2)
		gets_drilled()
	..()

/turf/closed/mineral/attack_alien(mob/living/carbon/alien/M)
	M << "<span class='notice'>You start digging into the rock...</span>"
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	if(do_after(M,40, target = src))
		M << "<span class='notice'>You tunnel into the rock.</span>"
		gets_drilled(M)

/turf/closed/mineral/Bumped(AM as mob|obj)
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
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/drill))
			src.attackby(M.selected,M)
			return*/
//Aparantly mechs are just TOO COOL to call Bump(), so fuck em (for now)
	else
		return

/**********************Asteroid**************************/

/turf/open/floor/plating/asteroid //floor piece
	name = "asteroid sand"
	baseturf = /turf/open/floor/plating/asteroid
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	icon_plating = "asteroid"
	var/environment_type = "asteroid"
	var/turf_type = /turf/open/floor/plating/asteroid //Because caves do whacky shit to revert to normal
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug
	var/sand_type = /obj/item/weapon/ore/glass

/turf/open/floor/plating/asteroid/airless
	initial_gas_mix = "TEMP=2.7"
	turf_type = /turf/open/floor/plating/asteroid/airless

/turf/open/floor/plating/asteroid/basalt
	name = "volcanic floor"
	baseturf = /turf/open/floor/plating/asteroid/basalt
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	icon_plating = "basalt"
	environment_type = "basalt"
	sand_type = /obj/item/weapon/ore/glass/basalt

/turf/open/floor/plating/asteroid/basalt/lava //lava underneath
	baseturf = /turf/open/floor/plating/lava/smooth

/turf/open/floor/plating/asteroid/basalt/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/plating/asteroid/snow
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	baseturf = /turf/open/floor/plating/asteroid/snow
	icon_state = "snow"
	icon_plating = "snow"
	initial_gas_mix = "TEMP=180"
	slowdown = 2
	environment_type = "snow"
	sand_type = /obj/item/stack/sheet/mineral/snow

/turf/open/floor/plating/asteroid/snow/airless
	initial_gas_mix = "TEMP=2.7"

/turf/open/floor/plating/asteroid/snow/temperatre
	initial_gas_mix = "TEMP=255.37"

/turf/open/floor/plating/asteroid/New()
	var/proper_name = name
	..()
	name = proper_name
	if(prob(20))
		icon_state = "[environment_type][rand(0,12)]"

/turf/open/floor/plating/asteroid/burn_tile()
	return

/turf/open/floor/plating/asteroid/ex_act(severity, target)
	contents_explosion(severity, target)
	switch(severity)
		if(3)
			return
		if(2)
			if(prob(20))
				src.gets_dug()
		if(1)
			src.gets_dug()

/turf/open/floor/plating/asteroid/attackby(obj/item/weapon/W, mob/user, params)
	//note that this proc does not call ..()
	if(!W || !user)
		return 0
	var/digging_speed = 0
	if (istype(W, /obj/item/weapon/shovel))
		var/obj/item/weapon/shovel/S = W
		digging_speed = S.digspeed
	else if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W
		digging_speed = P.digspeed
	if (digging_speed)
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "<span class='warning'>This area has already been dug!</span>"
			return

		user << "<span class='notice'>You start digging...</span>"
		playsound(src, 'sound/effects/shovel_dig.ogg', 50, 1)

		if(do_after(user, digging_speed, target = src))
			if(istype(src, /turf/open/floor/plating/asteroid))
				user << "<span class='notice'>You dig a hole.</span>"
				gets_dug()
				feedback_add_details("pick_used_mining","[W.type]")

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
		var/turf/open/floor/T = ChangeTurf(Z.turf_type)
		if(istype(Z,/obj/item/stack/tile/light)) //TODO: get rid of this ugly check somehow
			var/obj/item/stack/tile/light/L = Z
			var/turf/open/floor/light/F = T
			F.state = L.state
		playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)

/turf/open/floor/plating/asteroid/proc/gets_dug()
	if(dug)
		return
	for(var/i in 1 to 5)
		new sand_type(src)
	dug = 1
	icon_plating = "[environment_type]_dug"
	icon_state = "[environment_type]_dug"
	slowdown = 0
	return

/turf/open/floor/plating/asteroid/singularity_act()
	return

/turf/open/floor/plating/asteroid/singularity_pull(S, current_size)
	return

//////////////CHASM//////////////////

/turf/open/chasm
	name = "chasm"
	desc = "Watch your step."
	baseturf = /turf/open/chasm
	smooth = SMOOTH_TRUE | SMOOTH_BORDER
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "smooth"
	var/drop_x = 1
	var/drop_y = 1
	var/drop_z = 1

/turf/open/chasm/Entered(atom/movable/AM)
	START_PROCESSING(SSobj, src)
	drop_stuff()

/turf/open/chasm/process()
	if(!drop_stuff())
		STOP_PROCESSING(SSobj, src)

/turf/open/chasm/proc/drop_stuff()
	. = 0
	for(var/thing in contents)
		if(droppable(thing))
			. = 1
			drop(thing)

/turf/open/chasm/proc/droppable(atom/movable/AM)
	if(!isliving(AM) && !isobj(AM))
		return 0
	if(istype(AM, /obj/singularity) || istype(AM, /obj/item/projectile) || AM.throwing)
		return 0
	if(istype(AM, /obj/effect/portal))
		//Portals aren't affected by gravity. Probably.
		return 0
	//Flies right over the chasm
	if(isanimal(AM))
		var/mob/living/simple_animal/SA = AM
		if(SA.flying)
			return 0
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(istype(H.belt, /obj/item/device/wormhole_jaunter))
			var/obj/item/device/wormhole_jaunter/J = H.belt
			//To freak out any bystanders
			visible_message("<span class='boldwarning'>[H] falls into [src]!</span>")
			J.chasm_react(H)
			return 0
		if(H.dna && H.dna.species && (FLYING in H.dna.species.specflags))
			return 0
	return 1

/turf/open/chasm/proc/drop(atom/movable/AM)
	var/turf/T = locate(drop_x, drop_y, drop_z)
	if(T)
		AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>GAH! Ah... where are you?</span>")
		T.visible_message("<span class='boldwarning'>[AM] falls from above!</span>")
		AM.forceMove(T)
		if(isliving(AM))
			var/mob/living/L = AM
			L.Weaken(5)
			L.adjustBruteLoss(30)

/turf/open/chasm/straight_down/New()
	..()
	drop_x = x
	drop_y = y
	if(z+1 <= world.maxz)
		drop_z = z+1

/**********************Lavaland Turfs**************************/

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface

/turf/open/chasm/straight_down/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE
	baseturf = /turf/open/chasm/straight_down/lava_land_surface

/turf/open/chasm/straight_down/lava_land_surface/normal_air
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"

/turf/open/chasm/straight_down/lava_land_surface/drop(atom/movable/AM)
	AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>You stumble and stare into an abyss before you. It stares back, and you fall \
	into the enveloping dark.</span>")
	if(isliving(AM))
		var/mob/living/L = AM
		L.notransform = TRUE
		L.Stun(10)
		L.resting = TRUE
	animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
	for(var/i in 1 to 5)
		AM.pixel_y--
		sleep(2)
	if(isrobot(AM))
		var/mob/living/silicon/robot/S = AM
		qdel(S.mmi)
	qdel(AM)

/turf/closed/mineral/volcanic/lava_land_surface
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface
	defer_change = 1

/turf/closed/mineral/random/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

	mineralChance = 10
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic = 5, /turf/closed/mineral/diamond/volcanic = 1, /turf/closed/mineral/gold/volcanic = 10, /turf/closed/mineral/titanium/volcanic = 11,
		/turf/closed/mineral/silver/volcanic = 12, /turf/closed/mineral/plasma/volcanic = 20, /turf/closed/mineral/iron/volcanic = 40,
		/turf/closed/mineral/gibtonite/volcanic = 4, /turf/open/floor/plating/asteroid/airless/cave/volcanic = 1, /turf/closed/mineral/bscrystal/volcanic = 1)

/turf/closed/mineral/random/high_chance/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/lava/smooth/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic = 35, /turf/closed/mineral/diamond/volcanic = 30, /turf/closed/mineral/gold/volcanic = 45, /turf/closed/mineral/titanium/volcanic = 45,
		/turf/closed/mineral/silver/volcanic = 50, /turf/closed/mineral/plasma/volcanic = 50, /turf/closed/mineral/bscrystal/volcanic = 20)

/turf/open/floor/plating/lava/smooth/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE
	baseturf = /turf/open/chasm/straight_down/lava_land_surface

/turf/closed/mineral/gibtonite/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/uranium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/diamond/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/gold/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/silver/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/titanium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/plasma/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/iron/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1

/turf/closed/mineral/bscrystal/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturf = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	defer_change = 1


//BECAUSE ONE PLANET WASNT ENOUGH

/turf/closed/mineral/ash_rock //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/rock_wall.dmi'
	icon_state = "rock"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/closed/mineral, /turf/closed/wall)
	baseturf = /turf/open/floor/plating/ash
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	environment_type = "waste"
	turf_type = /turf/open/floor/plating/ash
	defer_change = 1

/turf/open/floor/plating/ash
	icon = 'icons/turf/mining.dmi'
	name = "ash"
	icon_state = "ash"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/open/floor/plating/ash, /turf/closed)
	var/smooth_icon = 'icons/turf/floors/ash.dmi'
	desc = "The ground is covered in volcanic ash."
	baseturf = /turf/open/floor/plating/ash //I assume this will be a chasm eventually, once this becomes an actual surface
	slowdown = 1
	initial_gas_mix = "o2=14;n2=23;TEMP=300"
	planetary_atmos = TRUE

/turf/open/floor/plating/ash/New()
	pixel_y = -4
	pixel_x = -4
	icon = smooth_icon
	..()

/turf/open/floor/plating/ash/break_tile()
	return

/turf/open/floor/plating/ash/burn_tile()
	return

/turf/open/floor/plating/ash/rocky
	name = "rocky ground"
	icon_state = "rockyash"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/floors/rocky_ash.dmi'
	slowdown = 0
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/open/floor/plating/ash/rocky, /turf/closed)

//Necropolis

/turf/closed/indestructible/necropolis
	name = "necropolis wall"
	desc = "A seemingly impenetrable wall."
	icon = 'icons/turf/walls.dmi'
	icon_state = "necro"
	explosion_block = 50
	baseturf = /turf/closed/indestructible/necropolis

/turf/open/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturf = /turf/open/indestructible/necropolis

/turf/open/indestructible/necropolis/New()
	..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"
=======
/turf/unsimulated/floor/asteroid/plating
	intact=0
	icon_state="asteroidplating"

/turf/unsimulated/floor/asteroid/canBuildCatwalk()
	return BUILD_FAILURE

/turf/unsimulated/floor/asteroid/canBuildLattice()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!(locate(/obj/structure/lattice) in contents))
		return BUILD_SUCCESS
	return BUILD_FAILURE

/turf/unsimulated/floor/asteroid/canBuildPlating()
	if(src.x >= (world.maxx - TRANSITIONEDGE) || src.x <= TRANSITIONEDGE)
		return BUILD_FAILURE
	else if (src.y >= (world.maxy - TRANSITIONEDGE || src.y <= TRANSITIONEDGE ))
		return BUILD_FAILURE
	else if(!dug)
		return BUILD_IGNORE
	if(locate(/obj/structure/lattice) in contents)
		return BUILD_SUCCESS
	return BUILD_FAILURE
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
