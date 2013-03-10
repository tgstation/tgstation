/**********************Mineral deposits**************************/

#define XENOARCH_SPAWN_CHANCE 0.5
#define XENOARCH_SPREAD_CHANCE 15
#define ARTIFACT_SPAWN_CHANCE 20

/turf/simulated/mineral //wall piece
	name = "Rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = TCMB
	var/mineralName = ""
	var/mineralAmt = 0
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles
	var/last_act = 0

	var/datum/geosample/geological_data
	var/excavation_level = 0
	var/list/finds = list()
	var/list/excavation_minerals = list()
	var/next_rock = 0
	var/archaeo_overlay = ""
	var/excav_overlay = ""
	var/obj/item/weapon/last_find
	var/datum/artifact_find/artifact_find

/turf/simulated/mineral/Del()
	return

/turf/simulated/mineral/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				src.mineralAmt -= 1 //some of the stuff gets blown up
				src.gets_drilled()
		if(1.0)
			src.mineralAmt -= 2 //some of the stuff gets blown up
			src.gets_drilled()
	return

/turf/simulated/mineral/New()

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

	if (mineralName && mineralAmt && spread && spreadChance)
		for(var/trydir in list(1,2,4,8))
			if(prob(spreadChance))
				if(istype(get_step(src, trydir), /turf/simulated/mineral/random))
					var/turf/simulated/mineral/T = get_step(src, trydir)
					var/turf/simulated/mineral/M = new src.type(T)
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
				var/turf/simulated/mineral/M = turfs_to_process[1]
				for(var/turf/simulated/mineral/T in orange(1, M))
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

/turf/simulated/mineral/random
	name = "Mineral deposit"
	var/mineralAmtList = list("Uranium" = 5, "Iron" = 5, "Diamond" = 5, "Gold" = 5, "Silver" = 5, "Plasma" = 5/*, "Adamantine" = 5*/)
	var/mineralSpawnChanceList = list("Uranium" = 5, "Iron" = 50, "Diamond" = 1, "Gold" = 5, "Silver" = 5, "Plasma" = 25/*, "Adamantine" =5*/)//Currently, Adamantine won't spawn as it has no uses. -Durandan
	var/mineralChance = 10  //means 10% chance of this plot changing to a mineral deposit

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
				/*if("Adamantine")
					M = new/turf/simulated/mineral/adamantine(src)*/
			if(M)
				src = M
				M.levelupdate()

				//preserve archaeo data
				M.geological_data = src.geological_data
				M.excavation_minerals = src.excavation_minerals
				M.overlays = src.overlays
				M.artifact_find = src.artifact_find
				M.archaeo_overlay = src.archaeo_overlay
				M.excav_overlay = src.excav_overlay

	/*else if (prob(artifactChance))
		new/obj/machinery/artifact(src)*/
	return

/turf/simulated/mineral/random/high_chance
	mineralChance = 25
	mineralSpawnChanceList = list("Uranium" = 10, "Iron" = 30, "Diamond" = 2, "Gold" = 10, "Silver" = 10, "Plasma" = 25, "Archaeo" = 2)

/turf/simulated/mineral/random/Del()
	return

/turf/simulated/mineral/uranium
	name = "Uranium deposit"
	icon_state = "rock_Uranium"
	mineralName = "Uranium"
	mineralAmt = 5
	spreadChance = 10
	spread = 1



/turf/simulated/mineral/iron
	name = "Iron deposit"
	icon_state = "rock_Iron"
	mineralName = "Iron"
	mineralAmt = 5
	spreadChance = 25
	spread = 1


/turf/simulated/mineral/diamond
	name = "Diamond deposit"
	icon_state = "rock_Diamond"
	mineralName = "Diamond"
	mineralAmt = 5
	spreadChance = 10
	spread = 1


/turf/simulated/mineral/gold
	name = "Gold deposit"
	icon_state = "rock_Gold"
	mineralName = "Gold"
	mineralAmt = 5
	spreadChance = 10
	spread = 1


/turf/simulated/mineral/silver
	name = "Silver deposit"
	icon_state = "rock_Silver"
	mineralName = "Silver"
	mineralAmt = 5
	spreadChance = 10
	spread = 1


/turf/simulated/mineral/plasma
	name = "Plasma deposit"
	icon_state = "rock_Plasma"
	mineralName = "Plasma"
	mineralAmt = 5
	spreadChance = 25
	spread = 1


/turf/simulated/mineral/clown
	name = "Bananium deposit"
	icon_state = "rock_Clown"
	mineralName = "Clown"
	mineralAmt = 3
	spreadChance = 0
	spread = 0

/*
commented out in r5061, I left it because of the shroom thingies

/turf/simulated/mineral/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/plating/airless/asteroid/W
	var/old_dir = dir

	for(var/direction in cardinal)
		for(var/obj/effect/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0

	var/old_lumcount = lighting_lumcount - initial(lighting_lumcount)
	W = new /turf/simulated/floor/plating/airless/asteroid(src)
	W.lighting_lumcount += old_lumcount
	if(old_lumcount != W.lighting_lumcount)
		W.lighting_changed = 1
		lighting_controller.changed_turfs += W

	W.dir = old_dir

	W.fullUpdateMineralOverlays()
	W.levelupdate()
	return W
*/

/turf/simulated/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/device/core_sampler))
		src.geological_data.UpdateNearbyArtifactInfo(src)
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = W
		user.visible_message("\blue[user] extends [P] towards [src].","\blue You extend [P] towards [src].")
		if(do_after(user,40))
			user << "\blue \icon[P] [src] has been excavated to a depth of [2*src.excavation_level]cm."
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
/*
	if (istype(W, /obj/item/weapon/pickaxe/radius))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
*/
//Watch your tabbing, microwave. --NEO

		var/obj/item/weapon/pickaxe/P = W
		if(last_act+P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time

		playsound(user, P.drill_sound, 20, 1)

		//handle any archaeological finds we might uncover
		var/fail_message
		if(src.finds.len)
			var/datum/find/F = src.finds[1]
			if(src.excavation_level + P.excavation_amount > F.excavation_required)
				//Chance to destroy / extract any finds here
				fail_message = ", <b>[pick("there is a crunching noise","[W] collides with some different rock","part of the rock face crumbles away","something breaks under [W]")]</b>"

		user << "\red You start [P.drill_verb][fail_message ? fail_message : ""]."

		if(fail_message)
			if(prob(50))
				if(prob(25))
					excavate_find(5, src.finds[1])
				else if(prob(50))
					src.finds.Remove(src.finds[1])

		if(do_after(user,P.digspeed))
			user << "\blue You finish [P.drill_verb] the rock."

			if(finds.len)
				var/datum/find/F = src.finds[1]
				if(round(src.excavation_level + P.excavation_amount) == F.excavation_required)
					//Chance to extract any items here perfectly, otherwise just pull them out along with the rock surrounding them
					if(src.excavation_level + P.excavation_amount > F.excavation_required)
						//if you can get slightly over, perfect extraction
						excavate_find(100, F)
					else
						excavate_find(80, F)

				else if(src.excavation_level + P.excavation_amount > F.excavation_required - F.clearance_range)
					//just pull the surrounding rock out
					excavate_find(0, F)

			if( src.excavation_level + P.excavation_amount >= 100 || (!finds.len && !excavation_minerals.len) )
				//if players have been excavating this turf, have a chance to leave some rocky debris behind
				var/boulder_prob = 0
				var/obj/structure/boulder/B

				if(src.excavation_level > 15)
					boulder_prob = 10
				if(artifact_find)
					boulder_prob += 25
					if(src.excavation_level >= 100)
						boulder_prob += 40
					else if(src.excavation_level > 95)
						boulder_prob += 25
					else if(src.excavation_level > 90)
						boulder_prob += 10
				if(prob(boulder_prob))
					B = new(src)
					if(artifact_find)
						B.artifact_find = artifact_find
				else if(src.excavation_level + P.excavation_amount >= 100)
					spawn(0)
						artifact_debris()

				gets_drilled(B ? 0 : 1)
				return
			else
				src.excavation_level += P.excavation_amount

				//archaeo overlays
				if(!archaeo_overlay && finds.len)
					var/datum/find/F = src.finds[1]
					if(F.excavation_required <= src.excavation_level + F.view_range)
						archaeo_overlay = "overlay_archaeo[rand(1,3)]"
						overlays += archaeo_overlay

			//there's got to be a better way to do this
			var/update_excav_overlay = 0
			if(src.excavation_level >= 75)
				if(src.excavation_level - P.excavation_amount < 75)
					update_excav_overlay = 1
			else if(src.excavation_level >= 50)
				if(src.excavation_level - P.excavation_amount < 50)
					update_excav_overlay = 1
			else if(src.excavation_level >= 25)
				if(src.excavation_level - P.excavation_amount < 25)
					update_excav_overlay = 1

			//update overlays displaying excavation level
			if( !(excav_overlay && excavation_level > 0) || update_excav_overlay )
				var/excav_quadrant = round(excavation_level / 25) + 1
				excav_overlay = "overlay_excv[excav_quadrant]_[rand(1,3)]"
				overlays += excav_overlay

			//extract pesky minerals while we're excavating
			while(excavation_minerals.len && src.excavation_level > excavation_minerals[excavation_minerals.len])
				drop_mineral()
				//have a 50% chance to extract bonus minerals this way
				//if(prob(50))
				pop(excavation_minerals)
				mineralAmt--

			//drop some rocks
			next_rock += P.excavation_amount * 10
			while(next_rock > 100)
				next_rock -= 100
				var/obj/item/weapon/ore/O = new(src)
				src.geological_data.UpdateNearbyArtifactInfo(src)
				O.geological_data = src.geological_data

	else
		return attack_hand(user)
	return

/turf/simulated/mineral/proc/drop_mineral()
	var/obj/item/weapon/ore/O
	if (src.mineralName == "Uranium")
		O = new /obj/item/weapon/ore/uranium(src)
	if (src.mineralName == "Iron")
		O = new /obj/item/weapon/ore/iron(src)
	if (src.mineralName == "Gold")
		O = new /obj/item/weapon/ore/gold(src)
	if (src.mineralName == "Silver")
		O = new /obj/item/weapon/ore/silver(src)
	if (src.mineralName == "Plasma")
		O = new /obj/item/weapon/ore/plasma(src)
	if (src.mineralName == "Diamond")
		O = new /obj/item/weapon/ore/diamond(src)
	/*if (src.mineralName == "Archaeo")
		//new /obj/item/weapon/archaeological_find(src)
		//if(prob(10) || delicate)
		if(prob(50)) //Don't have delicate tools (hand pick/excavation tool) yet, temporarily change to 50% instead of 10% -Mij
			O = new /obj/item/weapon/ore/strangerock(src)
		else
			destroyed = 1*/
	if (src.mineralName == "Clown")
		O = new /obj/item/weapon/ore/clown(src)
	if(O)
		src.geological_data.UpdateNearbyArtifactInfo(src)
		O.geological_data = src.geological_data
	return O

/turf/simulated/mineral/proc/gets_drilled(var/artifact_fail = 0)
	//var/destroyed = 0 //used for breaking strange rocks
	if ((src.mineralName != "") && (src.mineralAmt > 0) && (src.mineralAmt < 11))

		//if the turf has already been excavated, some of it's ore has been removed
		for (var/i=0;i<mineralAmt;i++)
			drop_mineral()

	/*if (prob(src.artifactChance))
		//spawn a rare artifact here
		new /obj/machinery/artifact(src)*/
	var/turf/simulated/floor/plating/airless/asteroid/N = ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
	N.fullUpdateMineralOverlays()

	//destroyed artifacts have weird, unpleasant effects
	if(artifact_find && artifact_fail)
		var/pain = 0
		if(prob(50))
			pain = 1
		for(var/mob/living/M in range(src, 200))
			M << "<font color='red'><b>[pick("A high pitched [pick("keening","wailing","whistle")]","A rumbling noise like [pick("thunder","heavy machinery")]")] somehow penetrates your mind before fadaing away!</b></font>"
			if(pain)
				flick("pain",M.pain)
				if(prob(50))
					M.adjustBruteLoss(5)
			else
				flick("flash",M.flash)
				if(prob(50))
					M.Stun(5)
			M.apply_effect(25, IRRADIATE)

	/*if(destroyed)  //Display message about being a terrible miner
		usr << "\red You destroy some of the rocks!"*/
	return

/turf/simulated/mineral/proc/excavate_find(var/prob_clean = 0, var/datum/find/F)
	//with skill and luck, players can cleanly extract finds
	//otherwise, they come out inside a chunk of rock
	var/obj/item/weapon/X
	if(prob_clean)
		X = new/obj/item/weapon/archaeological_find(src, new_item_type = F.find_type)
	else
		X = new/obj/item/weapon/ore/strangerock(src, inside_item_type = F.find_type)
		src.geological_data.UpdateNearbyArtifactInfo(src)
		X:geological_data = src.geological_data

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
				src.visible_message("\red<b>[pick("[display_name] crumbles away into dust","[display_name] breaks apart","[display_name] collapses onto itself")].</b>")
				del(X)

	src.finds.Remove(F)

/turf/simulated/mineral/proc/artifact_debris()
	//cael's patented random limited drop componentized loot system!
	var/materials = 0
	var/list/viable_materials = list(1,2,4,8,16,32,64,128,256)

	var/num_materials = rand(1,5)
	for(var/i=0, i<num_materials, i++)
		var/chosen = pick(viable_materials)
		materials |= chosen
		viable_materials.Remove(chosen)

	if(materials & 1)
		var/quantity = rand(0,3)
		for(var/i=0, i<quantity, i++)
			var/obj/item/stack/rods/R = new(src)
			R.amount = rand(5,25)

	if(materials & 2)
		var/quantity = pick(0, 0, 1)
		for(var/i=0, i<quantity, i++)
			var/obj/item/stack/tile/R = new(src)
			R.amount = rand(1,5)

	if(materials & 4)
		var/quantity = rand(0,3)
		for(var/i=0, i<quantity, i++)
			var/obj/item/stack/sheet/metal/R = new(src)
			R.amount = rand(5,25)

	if(materials & 8)
		var/quantity = rand(0,3)
		for(var/i=0, i<quantity, i++)
			var/obj/item/stack/sheet/plasteel/R = new(src)
			R.amount = rand(5,25)

	if(materials & 16)
		var/quantity = rand(0,3)
		for(var/i=0, i<quantity, i++)
			new /obj/item/weapon/shard(src)

	if(materials & 32)
		var/quantity = rand(0,3)
		for(var/i=0, i<quantity, i++)
			new /obj/item/weapon/shard/plasma(src)

	if(materials & 64)
		var/quantity = rand(0,3)
		for(var/i=0, i<quantity, i++)
			var/obj/item/stack/sheet/mineral/uranium/R = new(src)
			R.amount = rand(5,25)

	if(materials & 128)
		var/quantity = rand(0,3)
		for(var/i=0, i<quantity, i++)
			var/obj/item/stack/sheet/mineral/mythril/R = new(src)
			R.amount = rand(5,25)

	if(materials & 256)
		var/quantity = rand(0,3)
		for(var/i=0, i<quantity, i++)
			var/obj/item/stack/sheet/mineral/adamantine/R = new(src)
			R.amount = rand(5,25)

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

/turf/simulated/floor/plating/airless/asteroid //floor piece
	name = "Asteroid"
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB
	icon_plating = "asteroid"
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug

/turf/simulated/floor/plating/airless/asteroid/New()
	var/proper_name = name
	..()
	name = proper_name
	//if (prob(50))
	//	seedName = pick(list("1","2","3","4"))
	//	seedAmt = rand(1,4)
	if(prob(20))
		icon_state = "asteroid[rand(0,12)]"
	spawn(2)
		updateMineralOverlays()

/turf/simulated/floor/plating/airless/asteroid/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				src.gets_dug()
		if(1.0)
			src.gets_dug()
	return

/turf/simulated/floor/plating/airless/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(!W || !user)
		return 0

	if ((istype(W, /obj/item/weapon/shovel)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(40)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if ((istype(W,/obj/item/weapon/pickaxe/drill)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(30)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if ((istype(W,/obj/item/weapon/pickaxe/diamonddrill)) || (istype(W,/obj/item/weapon/pickaxe/borgdrill)))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'sound/effects/rustle1.ogg', 50, 1) //russle sounds sounded better

		sleep(0)
		if ((user.loc == T && user.get_active_hand() == W))
			user << "\blue You dug a hole."
			gets_dug()

	if(istype(W,/obj/item/weapon/storage/bag/ore))
		var/obj/item/weapon/storage/bag/ore/S = W
		if(S.collection_mode)
			for(var/obj/item/weapon/ore/O in src.contents)
				O.attackby(W,user)
				return

	else
		..(W,user)
	return

/turf/simulated/floor/plating/airless/asteroid/proc/gets_dug()
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

/turf/simulated/floor/plating/airless/asteroid/proc/updateMineralOverlays()

	src.overlays.Cut()

	if(istype(get_step(src, NORTH), /turf/simulated/mineral))
		src.overlays += image('icons/turf/walls.dmi', "rock_side_n")
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		src.overlays += image('icons/turf/walls.dmi', "rock_side_s", layer=6)
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		src.overlays += image('icons/turf/walls.dmi', "rock_side_e", layer=6)
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		src.overlays += image('icons/turf/walls.dmi', "rock_side_w", layer=6)

/turf/simulated/floor/plating/airless/asteroid/proc/fullUpdateMineralOverlays()
	var/turf/simulated/floor/plating/airless/asteroid/A
	if(istype(get_step(src, WEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, WEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, EAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, EAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTH)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, NORTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHWEST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHEAST), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTH), /turf/simulated/floor/plating/airless/asteroid))
		A = get_step(src, SOUTH)
		A.updateMineralOverlays()
	src.updateMineralOverlays()

/turf/simulated/floor/plating/airless/asteroid/Entered(atom/movable/M as mob|obj)
	..()
	if(istype(M,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = M
		if(istype(R.module, /obj/item/weapon/robot_module/miner))
			if(istype(R.module_state_1,/obj/item/weapon/storage/bag/ore))
				src.attackby(R.module_state_1,R)
			else if(istype(R.module_state_2,/obj/item/weapon/storage/bag/ore))
				src.attackby(R.module_state_2,R)
			else if(istype(R.module_state_3,/obj/item/weapon/storage/bag/ore))
				src.attackby(R.module_state_3,R)
			else
				return