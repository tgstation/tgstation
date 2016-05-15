/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	luminosity = 8

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/miner/New()
	..()
	contents = list()
	new /obj/item/weapon/storage/backpack/dufflebag/engineering(src)
	new /obj/item/weapon/storage/backpack/industrial(src)
	new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/gloves/fingerless(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/weapon/storage/box/emptysandbags(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/device/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/weapon/gun/energy/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/weapon/survivalcapsule(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/weapon/circuitboard/computer/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away"
	no_destination_swap = 1

/*********************Pickaxe & Drills**************************/

/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/mining.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 15
	throwforce = 10
	item_state = "pickaxe"
	w_class = 4
	materials = list(MAT_METAL=2000) //one sheet, but where can you make them?
	var/digspeed = 40
	var/list/digsound = list('sound/effects/picaxe1.ogg','sound/effects/picaxe2.ogg','sound/effects/picaxe3.ogg')
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("hit", "pierced", "sliced", "attacked")

/obj/item/weapon/pickaxe/proc/playDigSound()
	playsound(src, pick(digsound),50,1)

/obj/item/weapon/pickaxe/silver
	name = "silver-plated pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 20 //mines faster than a normal pickaxe, bought from mining vendor
	origin_tech = "materials=3;engineering=2"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	force = 17

/obj/item/weapon/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 14
	origin_tech = "materials=4;engineering=3"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."
	force = 19

/obj/item/weapon/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	item_state = "jackhammer"
	slot_flags = SLOT_BELT
	digspeed = 25 //available from roundstart, faster than a pickaxe.
	digsound = list('sound/weapons/drill.ogg')
	hitsound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	desc = "An electric mining drill for the especially scrawny."

/obj/item/weapon/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags = NODROP

/obj/item/weapon/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	digspeed = 7
	origin_tech = "materials=6;powerstorage=4;engineering=5"
	desc = "Yours is the drill that will pierce the heavens!"

/obj/item/weapon/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	digspeed = 7

/obj/item/weapon/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	digspeed = 5 //the epitome of powertools. extremely fast mining, laughs at puny walls
	origin_tech = "materials=3;powerstorage=2;engineering=2"
	digsound = list('sound/weapons/sonic_jackhammer.ogg')
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."

/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/mining.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8
	var/digspeed = 20
	throwforce = 4
	item_state = "shovel"
	w_class = 3
	materials = list(MAT_METAL=50)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	sharpness = IS_SHARP

/obj/item/weapon/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5
	throwforce = 7
	w_class = 2

/obj/item/weapon/emptysandbag
	name = "empty sandbag"
	desc = "A bag to be filled with sand."
	icon = 'icons/obj/items.dmi'
	icon_state = "sandbag"
	w_class = 1

/obj/item/weapon/emptysandbag/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/weapon/ore/glass))
		user << "<span class='notice'>You fill the sandbag.</span>"
		var/obj/item/stack/sheet/mineral/sandbags/I = new /obj/item/stack/sheet/mineral/sandbags
		user.unEquip(src)
		user.put_in_hands(I)
		qdel(W)
		qdel(src)
		return
	else
		return ..()

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon_state = "miningcar"

/*****************************Survival Pod********************************/


/area/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	requires_power = 0
	has_gravity = 1

/obj/item/weapon/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = 1
	var/used = FALSE

/obj/item/weapon/survivalcapsule/attack_self()
	if(used == FALSE)
		src.loc.visible_message("<span class='warning'>\The [src] begins to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		var/turf/T = get_turf(src)
		var/clear = TRUE
		for(var/turf/turf in range(2,T))
			if(istype(turf, /turf/closed) && !istype(turf, /turf/closed/mineral))
				clear = FALSE
				break
			for(var/obj/obj in turf)
				if(obj.density && obj.anchored)
					clear = FALSE
					break
		if(!clear)
			src.loc.visible_message("<span class='warning'>\The [src] doesn't have room to deploy! You need to clear a 5x5 area!</span>")
			used = FALSE
			return
		playsound(get_turf(src), 'sound/effects/phasein.ogg', 100, 1)
		PoolOrNew(/obj/effect/particle_effect/smoke, src.loc)
		if(T.z != ZLEVEL_MINING && T.z != ZLEVEL_LAVALAND)//only report capsules away from the mining/lavaland level
			message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) activated a bluespace capsule away from the mining level! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [T.x], [T.y], [T.z]")
		load()
		qdel(src)

/obj/item/weapon/survivalcapsule/proc/load()
	var/list/blacklist = list(/area/shuttle) //Shuttles move based on area, and we'd like not to break them
	var/turf/start_turf = get_turf(src.loc)
	var/turf/cur_turf
	var/x_size = 5
	var/y_size = 5
	var/list/walltypes = list(/turf/closed/wall/shuttle/survival/pod)
	var/floor_type = /turf/open/floor/pod
	var/room

	//Center the room/spawn it
	start_turf = locate(start_turf.x -2, start_turf.y - 2, start_turf.z)

	room = spawn_room(start_turf, x_size, y_size, walltypes, floor_type, "Emergency Shelter")

	start_turf = get_turf(src.loc)

	//Fill it

	//The door
	cur_turf = locate(start_turf.x, start_turf.y-2, start_turf.z)
	new /obj/machinery/door/airlock/survival_pod(cur_turf)


	//Bed middle right
	cur_turf = locate(start_turf.x+1, start_turf.y, start_turf.z)
	new /obj/structure/bed/pod(cur_turf)
	new /obj/item/weapon/bedsheet/black(cur_turf)

	//Chair bottom right
	cur_turf = locate(start_turf.x+1, start_turf.y-1, start_turf.z)
	new /obj/structure/tubes(cur_turf)
	var/obj/structure/chair/comfy/black/C = new (cur_turf)
	C.dir = 8

	//GPS computer top right
	cur_turf = locate(start_turf.x+1, start_turf.y+1, start_turf.z)
	new /obj/item/device/gps/computer(cur_turf)

	//Donk Pocket Storage Top/middle
	cur_turf = locate(start_turf.x, start_turf.y+1, start_turf.z)
	new /obj/machinery/smartfridge/survival_pod(cur_turf)

	//Table in Bottom Left
	cur_turf = locate(start_turf.x-1, start_turf.y-1, start_turf.z)
	new /obj/structure/table/survival_pod(cur_turf)

	//Sleeper Middle Left
	cur_turf = locate(start_turf.x-1, start_turf.y, start_turf.z)
	new /obj/machinery/sleeper/survival_pod(cur_turf)

	//Fans Top Left
	cur_turf = locate(start_turf.x-1, start_turf.y+1, start_turf.z)
	new /obj/structure/fans(cur_turf)

	//Signs
	cur_turf = locate(start_turf.x-2, start_turf.y, start_turf.z)
	var/obj/structure/sign/mining/survival/S1 = new(cur_turf)
	S1.dir = WEST

	cur_turf = locate(start_turf.x+2, start_turf.y, start_turf.z)
	var/obj/structure/sign/mining/survival/S2 = new(cur_turf)
	S2.dir = EAST

	cur_turf = locate(start_turf.x, start_turf.y+2, start_turf.z)
	var/obj/structure/sign/mining/survival/S3 = new(cur_turf)
	S3.dir = NORTH

	cur_turf = locate(start_turf.x-1, start_turf.y-2, start_turf.z)
	var/obj/structure/sign/mining/survival/S4 = new(cur_turf)
	S4.dir = SOUTH

	cur_turf = locate(start_turf.x+1, start_turf.y-2, start_turf.z)
	new /obj/structure/sign/mining(cur_turf)

	var/area/survivalpod/L = new /area/survivalpod

	var/turf/threshhold = locate(start_turf.x, start_turf.y-2, start_turf.z)
	threshhold.ChangeTurf(/turf/open/floor/pod)
	var/turf/open/floor/pod/doorturf = threshhold
	doorturf.air.parse_gas_string("o2=21;n2=82;TEMP=293.15")
	var/area/ZZ = get_area(threshhold)
	if(!is_type_in_list(ZZ, blacklist))
		L.contents += threshhold
	threshhold.overlays.Cut()

	new /obj/structure/fans/tiny(threshhold) //a tiny fan, to keep the air in.

	var/list/turfs = room["floors"]
	for(var/turf/open/floor/A in turfs)
		A.air.parse_gas_string("o2=21;n2=82;TEMP=293.15")
		A.overlays.Cut()
		var/area/Z = get_area(A)
		if(!is_type_in_list(Z, blacklist))
			L.contents += A

//Pod turfs and objects


//Floors
/turf/open/floor/pod
	name = "pod floor"
	icon_state = "podfloor"
	icon_regular_floor = "podfloor"
	floor_tile = /obj/item/stack/tile/pod

/turf/open/floor/pod/light
	icon_state = "podfloor_light"
	icon_regular_floor = "podfloor_light"
	floor_tile = /obj/item/stack/tile/pod/light

/turf/open/floor/pod/dark
	icon_state = "podfloor_dark"
	icon_regular_floor = "podfloor_dark"
	floor_tile = /obj/item/stack/tile/pod/dark

//Walls
/turf/closed/wall/shuttle/survival
	name = "pod wall"
	desc = "An easily-compressable wall used for temporary shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "smooth"
	walltype = "shuttle"
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/closed/wall/shuttle/survival, /obj/machinery/door/airlock/survival_pod, /obj/structure/window/shuttle/survival_pod, /obj/structure/shuttle/engine)

/turf/closed/wall/shuttle/survival/nodiagonal
	smooth = SMOOTH_MORE

/turf/closed/wall/shuttle/survival/pod
	canSmoothWith = list(/turf/closed/wall/shuttle/survival, /obj/machinery/door/airlock, /obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/shuttle, /obj/structure/shuttle/engine)

//Window
/obj/structure/window/shuttle/survival_pod
	name = "pod window"
	icon = 'icons/obj/smooth_structures/pod_window.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/closed/wall/shuttle/survival, /obj/machinery/door/airlock/survival_pod, /obj/structure/window/shuttle/survival_pod)

//Door
/obj/machinery/door/airlock/survival_pod
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/survival/horizontal/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/horizontal/survival_overlays.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_pod
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/survival_pod/vertical
	icon = 'icons/obj/doors/airlocks/survival/vertical/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/vertical/survival_overlays.dmi'
	doortype = /obj/structure/door_assembly/door_assembly_pod/vertical

/obj/structure/door_assembly/door_assembly_pod
	name = "pod airlock assembly"
	icon = 'icons/obj/doors/airlocks/survival/horizontal/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/horizontal/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod
	anchored = 1
	state = 1
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_pod/vertical
	icon = 'icons/obj/doors/airlocks/survival/vertical/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/vertical/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod/vertical

//Table
/obj/structure/table/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "table"
	smooth = SMOOTH_FALSE

//Sleeper
/obj/machinery/sleeper/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "sleeper"

/obj/machinery/sleeper/survival_pod/update_icon()
	if(state_open)
		overlays.Cut()
	else
		overlays += "sleeper_cover"

//Computer
/obj/item/device/gps/computer
	name = "pod computer"
	icon_state = "pod_computer"
	icon = 'icons/obj/lavaland/pod_computer.dmi'
	anchored = 1
	density = 1
	pixel_y = -32

/obj/item/device/gps/computer/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the gps.</span>", \
						"<span class='notice'>You start to disassemble the gps...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20/W.toolspeed, target = src))
			new /obj/item/device/gps(src.loc)
			qdel(src)
			return ..()

/obj/item/device/gps/computer/attack_hand(mob/user)
	attack_self(user)

//Bed
/obj/structure/bed/pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "bed"

//Survival Storage Unit
/obj/machinery/smartfridge/survival_pod
	name = "survival pod storage"
	desc = "A heated storage unit."
	icon_state = "bedcomputer"
	icon = 'icons/obj/lavaland/donkvendor.dmi'
	icon_on = "donkvendor"
	icon_off = "donkvendor"
	luminosity = 8
	max_n_of_items = 10
	pixel_y = -4

/obj/machinery/smartfridge/survival_pod/empty
	name = "dusty survival pod storage"
	desc = "A heated storage unit. This ones seen better days."

/obj/machinery/smartfridge/survival_pod/empty/New()
	return()

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	if(istype(O, /obj/item))
		return 1
	return 0

/obj/machinery/smartfridge/survival_pod/New()
	..()
	for(var/i in 1 to 5)
		var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/warm/W = new(src)
		load(W)
	if(prob(50))
		var/obj/item/weapon/storage/pill_bottle/dice/D = new(src)
		load(D)
	else
		var/obj/item/device/instrument/guitar/G = new(src)
		load(G)

//Fans
/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = 1
	density = 1
	var/arbitraryatmosblockingvar = TRUE
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 5

/obj/structure/fans/deconstruct()
	if(buildstacktype)
		new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/fans/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the fan.</span>", \
						"<span class='notice'>You start to disassemble the fan...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20/W.toolspeed, target = src))
			deconstruct()
			return ..()

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = TURF_LAYER + 0.8
	density = 0
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/New(loc)
	..()
	air_update_turf(1)

/obj/structure/fans/Destroy()
	arbitraryatmosblockingvar = FALSE
	air_update_turf(1)
	return ..()

/obj/structure/fans/CanAtmosPass(turf/T)
	return !arbitraryatmosblockingvar

//Signs
/obj/structure/sign/mining
	name = "nanotrasen mining corps sign"
	desc = "A sign of relief for weary miners, and a warning for would be competitors to Nanotrasen's mining claims."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "ntpod"

/obj/structure/sign/mining/survival
	name = "shelter sign"
	desc = "A high visibility sign designating a safe shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "survival"

//Fluff
/obj/structure/tubes
	icon_state = "tubes"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	name = "tubes"
	anchored = 1
	layer = MOB_LAYER - 0.2
	density = 0

