#define CONTIGUOUS_WALLS  1
#define CONTIGUOUS_FLOORS 2


var/global/list/mining_surprises = typesof(/mining_surprise)-/mining_surprise

/surprise_room
	var/list/floors[0]
	var/list/walls[0]

	var/size_x=0
	var/size_y=0

/mining_surprise
	var/name = "Hidden Complex"

	//: Types of floor to use
	var/list/floortypes[0]
	var/list/walltypes[0]
	var/list/spawntypes[0]
	var/list/fluffitems[0]

	var/max_richness=2

	//: How many rooms?
	var/complex_max_size=1

	var/room_size_max=5

	var/flags=0

	var/list/rooms=list()
	var/list/goodies=list()
	var/list/candidates=list()

	var/area/asteroid/artifactroom/complex_area

	proc/spawn_complex(var/atom/start_loc)
		name = "[initial(name)] #[rand(100,999)]"
		complex_area = new
		complex_area.name = name
		var/atom/pos=start_loc
		var/nrooms=complex_max_size
		var/maxtries=50
		var/l_size_x=0
		var/l_size_y=0
		while(nrooms && maxtries)
			var/sx=rand(3,room_size_max)
			var/sy=rand(3,room_size_max)
			var/o_x=l_size_x?rand(0,l_size_x):0
			var/o_y=l_size_y?rand(0,l_size_y):0
			var/atom/npos
			switch(pick(cardinal))
				if(NORTH)
					npos=locate(pos.x+o_x,  pos.y+sy-1, pos.z)
				if(SOUTH)
					npos=locate(pos.x+o_x,  pos.y-sy+1, pos.z)
				if(WEST)
					npos=locate(pos.x-sx-1, pos.y+o_y,  pos.z)
				if(EAST)
					npos=locate(pos.x+sx+1, pos.y+o_y,  pos.z)
			if(spawn_room(npos,sx,sy,1))
				pos=npos
				l_size_x=sx
				l_size_y=sy
			else if(complex_max_size==nrooms)
				// Failed to make first room, abort.
				del(complex_area)
				return 0
			else
				maxtries--
				continue
			nrooms--
		postProcessComplex()
		message_admins("Complex spawned at [formatJumpTo(start_loc)]")
		return 1

	proc/postProcessRoom(var/surprise_room/room)
		for(var/turf/floor in room.floors)
			for(var/turf/T in floor.AdjacentTurfs())
				if(T in room.floors)
					candidates|=T
					break

	proc/postProcessComplex()
		for(var/i=0;i<=rand(1,max_richness);i++)
			if(!candidates.len)
				return
			var/turf/T = pick(candidates)
			var/thing = pickweight(spawntypes)
			if(thing==null)
				continue
			new thing(T)
			candidates -= T
			message_admins("Goodie [thing] spawned at [formatJumpTo(T)]")

		for(var/i=0;i<=rand(5,10);i++)
			if(!candidates.len)
				return
			var/turf/T = pick(candidates)
			var/thing = pickweight(fluffitems)
			if(thing==null)
				continue
			new thing(T)

	proc/spawn_room(var/atom/start_loc, var/x_size, var/y_size, var/clean=0)
		if(!check_complex_placement(start_loc,x_size,y_size))
			return 0

		// If walls/floors are contiguous, pick them out.
		var/wall_type
		if(flags & CONTIGUOUS_WALLS)
			wall_type = pickweight(walltypes)

		var/floor_type
		if(flags & CONTIGUOUS_FLOORS)
			floor_type = pickweight(floortypes)


		var/list/walls[0]
		var/list/floors[0]
		for(var/x = 0,x<x_size,x++)
			for(var/y = 0,y<y_size,y++)
				var/turf/cur_loc = locate(start_loc.x+x,start_loc.y+y,start_loc.z)

				if(clean)
					for(var/O in cur_loc)
						qdel(O)

				if(x == 0 || x==x_size-1 || y==0 || y==y_size-1)
					walls |= cur_loc
				else
					floors |= cur_loc

		var/surprise_room/room = new
		for(var/turf/turf in walls)

			if(!(flags & CONTIGUOUS_WALLS))
				wall_type=pickweight(walltypes)

			var/turf/T
			if(dd_hasprefix("[wall_type]","/obj"))
				if(!(flags & CONTIGUOUS_FLOORS))
					floor_type=pickweight(floortypes)
				T=new floor_type(turf)
				new wall_type(T)
			else
				//testing("Creating wall of type [wall_type].")
				T=new wall_type(turf)

			room.walls += T
			complex_area.contents += T

		for(var/turf/turf in floors)
			if(!(flags & CONTIGUOUS_FLOORS))
				floor_type=pickweight(floortypes)

			var/turf/T = new floor_type(turf)
			room.floors += T
			complex_area.contents += T

		postProcessRoom(room)

		rooms += room

		message_admins("Room spawned at [formatJumpTo(start_loc)]")

		return 1

/mining_surprise/human
	name="Hidden Complex"
	floortypes = list(
		/turf/simulated/floor/airless=95,
		/turf/simulated/floor/plating/airless=5
	)
	walltypes = list(
		/turf/simulated/wall=100
	)
	spawntypes = list(
		/obj/item/weapon/pickaxe/silver					=4,
		/obj/item/weapon/pickaxe/drill					=4,
		/obj/item/weapon/pickaxe/jackhammer				=4,
		/obj/item/weapon/pickaxe/diamond				=3,
		/obj/item/weapon/pickaxe/diamonddrill			=3,
		/obj/item/weapon/pickaxe/gold					=3,
		/obj/item/weapon/pickaxe/plasmacutter			=2,
		/obj/structure/closet/syndicate/resources		=2,
		/obj/item/weapon/melee/energy/sword/pirate		=1,
		/obj/mecha/working/ripley/mining				=1
	)
	complex_max_size=2

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

/mining_surprise/alien_nest
	name="Hidden Nest"
	floortypes = list(
		/turf/unsimulated/floor/asteroid=100
	)

	walltypes = list(
		/turf/unsimulated/mineral/random/high_chance=1
	)

	spawntypes = list(
		/obj/item/clothing/mask/facehugger				=4,
		/obj/mecha/working/ripley/mining				=1
	)
	fluffitems = list(
		/obj/effect/decal/remains/human                 = 5,
		/obj/effect/decal/cleanable/blood/xeno          = 5,
		/obj/effect/decal/mecha_wreckage/ripley			= 1
	)
	complex_max_size=6
	room_size_max=7

	var/const/eggs_left=10 // Per complex
	var/turf/weeds[0] // Turfs with weeds.
	postProcessComplex()
		..()
		var/list/all_floors=list()
		for(var/surprise_room/room in rooms)
			var/list/w_cand=room.floors
			var/egged=0
			while(w_cand.len)
				var/turf/weed_turf = pick(w_cand)
				if(locate(/obj/effect/alien) in weed_turf)
					continue
				w_cand -= weed_turf
				if(weed_turf && !egged)
					new /obj/effect/alien/weeds/node(weed_turf)
					weeds += weed_turf
					egged=1
				else
					all_floors |= room.floors

		for(var/e=0;e<eggs_left;e++)
			var/turf/egg_turf = pick(all_floors)
			if(egg_turf && !(locate(/obj/effect/alien) in egg_turf))
				new /obj/effect/alien/egg(egg_turf)

///////////////////
// /tg/ Surprises
/mining_surprise/organharvest
	walltypes = list(
		/turf/simulated/wall/r_wall=2,
		/turf/simulated/wall=2,
		/turf/unsimulated/mineral/random/high_chance=1
	)
	floortypes = list(
		/turf/simulated/floor=1,
		/turf/simulated/floor/engine=1
	)
	spawntypes = list(
		/obj/item/device/mass_spectrometer/adv=1,
		/obj/item/clothing/glasses/hud/health=1,
		/obj/machinery/bot/medbot/mysterious=1
	)
	fluffitems = list(
		/obj/effect/decal/cleanable/blood=5,
		/obj/item/weapon/reagent_containers/food/snacks/appendix=2, // OM NOM
		/obj/structure/closet/crate/freezer=2,
		/obj/machinery/optable=1,
		/obj/item/weapon/scalpel=1,
		/obj/item/weapon/storage/firstaid/regular=3,
		/obj/item/weapon/tank/anesthetic=1,
		///obj/item/weapon/surgical_drapes=2
	)

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

	complex_max_size=3
	room_size_max=7

/mining_surprise/cult
	name = "Hidden Temple"
	walltypes = list(
		/turf/simulated/wall/cult=3,
		/turf/unsimulated/mineral/random/high_chance=1
	)
	floortypes = list(
		/turf/simulated/floor/engine/cult=1
	)
	spawntypes = list(
		/mob/living/simple_animal/hostile/creature=1,
		// /obj/item/organ/heart=2,
		/obj/item/device/soulstone=1
	)
	fluffitems = list(
		/obj/effect/gateway=1,
		/obj/effect/gibspawner=1,
		/obj/structure/cult/talisman=1,
		/obj/item/toy/crayon/red=2,
		/obj/effect/decal/cleanable/blood=4,
		/obj/structure/table/woodentable=2,
		/obj/item/weapon/ectoplasm=3
	)

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

	complex_max_size=3
	room_size_max=5

/mining_surprise/wizden
	name = "Hidden Den"
	walltypes = list(
		/turf/simulated/wall/mineral/plasma=3,
		/turf/unsimulated/mineral/random/high_chance=1
	)
	floortypes = list(
		/turf/simulated/floor/wood=1
	)
	spawntypes = list(
		// /vg/: Let's not. /obj/item/weapon/veilrender/vealrender=1,
		// /vg/: /obj/item/key=1
		/obj/item/clothing/glasses/monocle=5,
		// /vg/:
		/obj/structure/stool/bed/chair/vehicle/wizmobile=1
	)
	fluffitems = list(
		/obj/structure/safe/floor=1,
		// /obj/structure/wardrobe=1,
		/obj/item/weapon/storage/belt/soulstone=1,
		/obj/item/trash/candle=3,
		/obj/item/weapon/dice=3,
		/obj/item/weapon/staff=2,
		/obj/effect/decal/cleanable/dirt=3,
		/obj/item/weapon/coin/mythril=3
	)

	flags = CONTIGUOUS_WALLS | CONTIGUOUS_FLOORS

	complex_max_size=1
	room_size_max=7

/mining_surprise/cavein
	name="Cave-In"

	walltypes = list(
		/turf/unsimulated/mineral/random/high_chance=1
	)
	floortypes = list(
		/turf/unsimulated/floor/asteroid=1
	)
	spawntypes = list(
		/obj/mecha/working/ripley/mining=1,
		/obj/item/weapon/pickaxe/jackhammer=2,
		/obj/item/weapon/pickaxe/diamonddrill=2
	)
	fluffitems = list(
		/obj/effect/decal/cleanable/blood=3,
		/obj/effect/decal/remains/human=1,
		/obj/item/clothing/under/overalls=1,
		/obj/item/weapon/reagent_containers/food/snacks/grown/chili=1,
		/obj/item/weapon/tank/oxygen/red=2
	)

	complex_max_size=3
	room_size_max=7

/mining_surprise/human/hitech
	complex_max_size=3
	room_size_max=7

	walltypes = list(
		/turf/simulated/wall/r_wall=1
	)
	floortypes = list(
		/turf/simulated/floor/greengrid=1,
		/turf/simulated/floor/bluegrid=1
	)
	spawntypes = list(
		/obj/item/weapon/pickaxe/plasmacutter=1,
		/obj/machinery/shieldgen=1,
		/obj/item/weapon/cell/hyper=1
	)
	fluffitems = list(
		/obj/structure/table/reinforced=2,
		/obj/item/weapon/stock_parts/scanning_module/phasic=3,
		/obj/item/weapon/stock_parts/matter_bin/super=3,
		/obj/item/weapon/stock_parts/manipulator/pico=3,
		/obj/item/weapon/stock_parts/capacitor/super=3,
		/obj/item/device/pda/clear=1
	)

/mining_surprise/human/speakeasy
	complex_max_size=3
	room_size_max=7

	floortypes = list(
		/turf/simulated/floor,
		/turf/simulated/floor/wood)
	spawntypes = list(
		/obj/item/weapon/melee/energy/sword/pirate=1,
		/obj/structure/closet/syndicate/resources=2
	)
	fluffitems = list(
		/obj/structure/table/woodentable=2,
		/obj/structure/reagent_dispensers/beerkeg=1,
		/obj/item/weapon/spacecash/c500=4,
		/obj/item/weapon/reagent_containers/food/drinks/shaker=1,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/wine=3,
		/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey=3,
		/obj/item/clothing/shoes/laceup=2
	)

/mining_surprise/human/plantlab
	complex_max_size=2
	room_size_max=7

	spawntypes = list(
		/obj/item/weapon/gun/energy/floragun=1,
		/obj/item/seeds/novaflowerseed=2,
		/obj/item/seeds/bluespacetomatoseed=2
	)
	fluffitems = list(
		// /obj/structure/flora/kirbyplants=1,
		/obj/structure/table/reinforced=2,
		/obj/machinery/hydroponics=1,
		/obj/effect/glowshroom/single=2,
		/obj/item/weapon/reagent_containers/syringe/antitoxin=2,
		/obj/item/weapon/reagent_containers/glass/bottle/diethylamine=3,
		/obj/item/weapon/reagent_containers/glass/bottle/ammonia=3
	)

		/*if("poly")
			theme = "poly"
			x_size = 5
			y_size = 5
			walltypes = list(/turf/simulated/wall/mineral/clown)
			floortypes= list(/turf/simulated/floor/engine)
			treasureitems = list(/obj/item/weapon/spellbook=1,/obj/mecha/combat/marauder=1,/obj/machinery/wish_granter=1)
			fluffitems = list(/obj/item/weapon/melee/energy/axe)*/