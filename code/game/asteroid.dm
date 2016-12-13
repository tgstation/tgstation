var/global/list/possiblethemes = list("organharvest","cult","wizden","cavein","xenoden","hitech","speakeasy","plantlab")

var/global/max_secret_rooms = 6

/proc/spawn_room(atom/start_loc, x_size, y_size, list/walltypes, floor, name, oldarea)
	var/list/room_turfs = list("walls"=list(),"floors"=list())

	var/area/asteroid/artifactroom/A = new
	if(name)
		A.name = name
	else
		A.name = "Artifact Room #[start_loc.x]-[start_loc.y]-[start_loc.z]"

	for(var/x = 0, x < x_size, x++)		//sets the size of the room on the x axis
		for(var/y = 0, y < y_size, y++) //sets it on y axis.
			var/turf/T
			var/cur_loc = locate(start_loc.x + x, start_loc.y + y, start_loc.z)


			if(x == 0 || x == x_size-1 || y == 0 || y == y_size-1)
				var/wall = pickweight(walltypes)//totally-solid walls are pretty boring.
				T = cur_loc
				T.ChangeTurf(wall)
				room_turfs["walls"] += T


			else
				T = cur_loc
				T.ChangeTurf(floor)
				room_turfs["floors"] += T

			if(!oldarea)
				A.contents += T

	return room_turfs

//////////////

/proc/make_mining_asteroid_secrets()
	for(var/i in 1 to max_secret_rooms)
		make_mining_asteroid_secret()

/proc/make_mining_asteroid_secret()
	var/valid = 0
	var/turf/T = null
	var/sanity = 0
	var/list/room = null
	var/list/turfs = null
	var/x_size = 5
	var/y_size = 5

	var/areapoints = 0
	var/theme = "organharvest"
	var/list/walltypes = list(/turf/closed/wall=3, /turf/closed/mineral/random=1)
	var/list/floortypes = list(/turf/open/floor/plasteel)
	var/list/treasureitems = list()//good stuff. only 1 is created per room.
	var/list/fluffitems = list()//lesser items, to help fill out the room and enhance the theme.

	x_size = rand(3,7)
	y_size = rand(3,7)
	areapoints = x_size * y_size

	switch(pick(possiblethemes))//what kind of room is this gonna be?
		if("organharvest")
			walltypes = list(/turf/closed/wall/r_wall=2,/turf/closed/wall=2,/turf/closed/mineral/random/high_chance=1)
			floortypes = list(/turf/open/floor/plasteel,/turf/open/floor/engine)
			treasureitems = list(/mob/living/simple_animal/bot/medbot/mysterious=1, /obj/item/weapon/circular_saw=1, /obj/structure/closet/crate/critter=2, /mob/living/simple_animal/pet/cat/space=1)
			fluffitems = list(/obj/effect/decal/cleanable/blood=5,/obj/item/organ/appendix=2,/obj/structure/closet/crate/freezer=2,
							  /obj/structure/table/optable=1,/obj/item/weapon/scalpel=1,/obj/item/weapon/storage/firstaid/regular=3,
							  /obj/item/weapon/tank/internals/anesthetic=1, /obj/item/weapon/surgical_drapes=2, /obj/item/device/mass_spectrometer/adv=1,/obj/item/clothing/glasses/hud/health=1)

		if("cult")
			theme = "cult"
			walltypes = list(/turf/closed/wall/mineral/cult=3,/turf/closed/mineral/random/high_chance=1)
			floortypes = list(/turf/open/floor/plasteel/cult)
			treasureitems = list(/obj/item/device/soulstone/anybody=1, /obj/item/clothing/suit/space/hardsuit/cult=1, /obj/item/weapon/bedsheet/cult=2,
								 /obj/item/clothing/suit/cultrobes=2, /mob/living/simple_animal/hostile/creature=3)
			fluffitems = list(/obj/effect/gateway=1,/obj/effect/gibspawner=1,/obj/structure/destructible/cult/talisman=1,/obj/item/toy/crayon/red=2,
							  /obj/item/organ/heart=2, /obj/effect/decal/cleanable/blood=4,/obj/structure/table/wood=2,/obj/item/weapon/ectoplasm=3,
							/obj/item/clothing/shoes/cult=1)

		if("wizden")
			theme = "wizden"
			walltypes = list(/turf/closed/wall/mineral/plasma=3,/turf/closed/mineral/random/high_chance=1)
			floortypes = list(/turf/open/floor/wood)
			treasureitems = list(/obj/item/weapon/veilrender/vealrender=2, /obj/item/weapon/spellbook/oneuse/blind=1,/obj/item/clothing/head/wizard/red=2,
							/obj/item/weapon/spellbook/oneuse/forcewall=1, /obj/item/weapon/spellbook/oneuse/smoke=1, /obj/structure/constructshell = 1, /obj/item/toy/katana=3,/obj/item/voodoo=3)
			fluffitems = list(/obj/structure/safe/floor=1,/obj/structure/dresser=1,/obj/item/weapon/storage/belt/soulstone=1,/obj/item/trash/candle=3,
							  /obj/item/weapon/dice=3,/obj/item/weapon/staff=2,/obj/effect/decal/cleanable/dirt=3,/obj/item/weapon/coin/mythril=3)

		if("cavein")
			theme = "cavein"
			walltypes = list(/turf/closed/mineral/random/high_chance=1)
			floortypes = list(/turf/open/floor/plating/asteroid/basalt, /turf/open/floor/plating/beach/sand)
			treasureitems = list(/obj/mecha/working/ripley/mining=1, /obj/item/weapon/pickaxe/drill/diamonddrill=2,
							/obj/item/weapon/resonator/upgraded=1, /obj/item/weapon/pickaxe/drill/jackhammer=5)
			fluffitems = list(/obj/effect/decal/cleanable/blood=3,/obj/effect/decal/remains/human=1,/obj/item/clothing/under/overalls=1,
							  /obj/item/weapon/reagent_containers/food/snacks/grown/chili=1,/obj/item/weapon/tank/internals/oxygen/red=2)

		if("xenoden")
			theme = "xenoden"
			walltypes = list(/turf/closed/mineral/random/high_chance=1)
			floortypes = list(/turf/open/floor/plating/asteroid/basalt, /turf/open/floor/plating/beach/sand)
			treasureitems = list(/obj/item/clothing/mask/facehugger=1)
			fluffitems = list(/obj/effect/decal/remains/human=1,/obj/effect/decal/cleanable/xenoblood/xsplatter=5)

		if("hitech")
			theme = "hitech"
			walltypes = list(/turf/closed/wall/r_wall=5,/turf/closed/mineral/random=1)
			floortypes = list(/turf/open/floor/greengrid,/turf/open/floor/bluegrid)
			treasureitems = list(/obj/item/weapon/stock_parts/cell/hyper=1, /obj/machinery/chem_dispenser/constructable=1,/obj/machinery/computer/telescience=1, /obj/machinery/r_n_d/protolathe=1,
								/obj/machinery/biogenerator=1)
			fluffitems = list(/obj/structure/table/reinforced=2,/obj/item/weapon/stock_parts/scanning_module/phasic=3,
							  /obj/item/weapon/stock_parts/matter_bin/super=3,/obj/item/weapon/stock_parts/manipulator/pico=3,
							  /obj/item/weapon/stock_parts/capacitor/super=3,/obj/item/device/pda/clear=1, /obj/structure/mecha_wreckage/phazon=1)

		if("speakeasy")
			theme = "speakeasy"
			floortypes = list(/turf/open/floor/plasteel,/turf/open/floor/wood)
			treasureitems = list(/obj/item/weapon/melee/energy/sword/pirate=1,/obj/item/weapon/gun/ballistic/revolver/doublebarrel=1,/obj/item/weapon/storage/backpack/satchel/flat=1,
			/obj/machinery/reagentgrinder=2, /obj/machinery/computer/security/wooden_tv=4, /obj/machinery/vending/coffee=3)
			fluffitems = list(/obj/structure/table/wood=2,/obj/structure/reagent_dispensers/beerkeg=1,/obj/item/stack/spacecash/c500=4,
							  /obj/item/weapon/reagent_containers/food/drinks/shaker=1,/obj/item/weapon/reagent_containers/food/drinks/bottle/wine=3,
							  /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey=3,/obj/item/clothing/shoes/laceup=2)

		if("plantlab")
			theme = "plantlab"
			treasureitems = list(/obj/item/weapon/gun/energy/floragun=1,/obj/item/seeds/sunflower/novaflower=2,/obj/item/seeds/tomato/blue/bluespace=2,/obj/item/seeds/tomato/blue=2,
			/obj/item/seeds/coffee/robusta=2, /obj/item/seeds/firelemon=2)
			fluffitems = list(/obj/item/weapon/twohanded/required/kirbyplants=1,/obj/structure/table/reinforced=2,/obj/machinery/hydroponics/constructable=1,
							  /obj/structure/glowshroom/single=2,/obj/item/weapon/reagent_containers/syringe/charcoal=2,
							  /obj/item/weapon/reagent_containers/glass/bottle/diethylamine=3,/obj/item/weapon/reagent_containers/glass/bottle/ammonia=3)

		/*if("poly")
			theme = "poly"
			x_size = 5
			y_size = 5
			walltypes = list(/turf/closed/wall/mineral/clown)
			floortypes= list(/turf/open/floor/engine)
			treasureitems = list(/obj/item/weapon/spellbook=1,/obj/mecha/combat/marauder=1,/obj/machinery/wish_granter=1)
			fluffitems = list(/obj/item/weapon/melee/energy/axe)*/

	possiblethemes -= theme //once a theme is selected, it's out of the running!
	var/floor = pick(floortypes)

	turfs = get_area_turfs(/area/lavaland/surface/outdoors)

	if(!turfs.len)
		return 0

	while(!valid)//Finds some spots to place these rooms at, where they won't be spotted immediately.
		valid = 1
		sanity++
		if(sanity > 100)
			return 0

		T=pick(turfs)
		if(!T)
			return 0

		var/list/surroundings = list()

		surroundings += range(7, locate(T.x,T.y,T.z))
		surroundings += range(7, locate(T.x+x_size,T.y,T.z))
		surroundings += range(7, locate(T.x,T.y+y_size,T.z))
		surroundings += range(7, locate(T.x+x_size,T.y+y_size,T.z))

		for(var/turf/check in surroundings)
			var/area/new_area = get_area(check)
			if(!(istype(new_area, /area/lavaland/surface/outdoors)))
				valid = FALSE
				break

	if(!T)
		return 0

	room = spawn_room(T,x_size,y_size,walltypes,floor) //WE'RE FINALLY CREATING THE ROOM

	if(room)//time to fill it with stuff
		var/list/emptyturfs = room["floors"]
		T = pick(emptyturfs)
		if(T)
			new /obj/structure/glowshroom/single(T) //Just to make it a little more visible
			var/surprise = null
			surprise = pickweight(treasureitems)
			new surprise(T)//here's the prize
			emptyturfs -= T

			while(areapoints >= 10)//lets throw in the fluff items
				T = pick(emptyturfs)
				var/garbage = null
				garbage = pickweight(fluffitems)
				new garbage(T)
				areapoints -= 5
				emptyturfs -= T
			//world.log << "The [theme] themed [T.loc] has been created!"

	return 1
