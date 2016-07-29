/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
<<<<<<< HEAD
	luminosity = 8

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/miner/New()
	..()
	contents = list()
	new /obj/item/weapon/storage/backpack/dufflebag(src)
	new /obj/item/weapon/storage/backpack/explorer(src)
	new /obj/item/weapon/storage/backpack/satchel/explorer(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
=======
	light_range = 8

/**********************Miner Lockers**************************/

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "miningsec1"
	icon_closed = "miningsec"
	icon_locked = "miningsec1"
	icon_opened = "miningsecopen"
	icon_broken = "miningsecbroken"
	icon_off = "miningsecoff"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
<<<<<<< HEAD
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/weapon/storage/box/emptysandbags(src)
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe/mini(src)
	new /obj/item/device/radio/headset/headset_cargo/mining(src)
	new /obj/item/device/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/weapon/storage/bag/ore(src)
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
	var/global/list/dumb_rev_heads = list()

/obj/machinery/computer/shuttle/mining/attack_hand(mob/user)
	if(user.z == ZLEVEL_STATION && user.mind && (user.mind in ticker.mode.head_revolutionaries) && !(user.mind in dumb_rev_heads))
		user << "<span class='warning'>You get a feeling that leaving the station might be a REALLY dumb idea...</span>"
		dumb_rev_heads += user.mind
		return
	..()

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
	origin_tech = "materials=2;engineering=3"
	attack_verb = list("hit", "pierced", "sliced", "attacked")

/obj/item/weapon/pickaxe/mini
	name = "compact pickaxe"
	desc = "A smaller, compact version of the standard pickaxe."
	icon_state = "minipick"
	force = 10
	throwforce = 7
	slot_flags = SLOT_BELT
	w_class = 3
	materials = list(MAT_METAL=1000)

/obj/item/weapon/pickaxe/proc/playDigSound()
	playsound(src, pick(digsound),50,1)

/obj/item/weapon/pickaxe/silver
	name = "silver-plated pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 20 //mines faster than a normal pickaxe, bought from mining vendor
	origin_tech = "materials=3;engineering=4"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	force = 17

/obj/item/weapon/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 14
	origin_tech = "materials=5;engineering=4"
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
	origin_tech = "materials=2;powerstorage=2;engineering=3"
	desc = "An electric mining drill for the especially scrawny."

/obj/item/weapon/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags = NODROP

/obj/item/weapon/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	digspeed = 7
	origin_tech = "materials=6;powerstorage=4;engineering=4"
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
	origin_tech = "materials=6;powerstorage=4;engineering=5;magnets=4"
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
	origin_tech = "materials=2;engineering=2"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	sharpness = IS_SHARP

/obj/item/weapon/shovel/spade
=======
	sleep(2)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/industrial(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/device/radio/headset/headset_mining(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/device/mining_scanner(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/device/flashlight/lantern(src)
	new /obj/item/weapon/pickaxe/shovel(src)
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/clothing/glasses/scanner/meson(src)
	new /obj/item/device/gps/mining(src)
	new /obj/item/weapon/storage/belt/mining(src)


/**********************Shuttle Computer**************************/
/*
var/mining_shuttle_tickstomove = 10
var/mining_shuttle_moving = 0
var/mining_shuttle_location = 0 // 0 = station 13, 1 = mining station

proc/move_mining_shuttle()
	if(mining_shuttle_moving)	return
	mining_shuttle_moving = 1
	spawn(mining_shuttle_tickstomove*10)
		var/area/fromArea
		var/area/toArea
		if (mining_shuttle_location == 1)
			fromArea = locate(/area/shuttle/mining/outpost)
			toArea = locate(/area/shuttle/mining/station)
		else
			fromArea = locate(/area/shuttle/mining/station)
			toArea = locate(/area/shuttle/mining/outpost)
			var/list/search = fromArea.search_contents_for(/obj/item/weapon/disk/nuclear)
			if(!isemptylist(search))
				mining_shuttle_moving = 0
				return

		var/list/dstturfs = list()
		var/throwy = world.maxy

		for(var/turf/T in toArea)
			dstturfs += T
			if(T.y < throwy)
				throwy = T.y

		// hey you, get out of the way!
		for(var/turf/T in dstturfs)
			// find the turf to move things to
			var/turf/D = locate(T.x, throwy - 1, 1)
			//var/turf/E = get_step(D, SOUTH)
			for(var/atom/movable/AM as mob|obj in T)
				AM.Move(D)

			if(istype(T, /turf/simulated))
				del(T)
		//Do I really need to explain this loop?
		for(var/atom/A in toArea)
			if(istype(A,/mob/living))
				var/mob/living/unlucky_person = A
				unlucky_person.gib()
			// Weird things happen when this shit gets in the way.
			if(istype(A,/obj/structure/lattice) \
				|| istype(A, /obj/structure/window) \
				|| istype(A, /obj/structure/grille))
				qdel(A)

		fromArea.move_contents_to(toArea)
		if (mining_shuttle_location)
			mining_shuttle_location = 0
		else
			mining_shuttle_location = 1

		for(var/mob/M in toArea)
			if(M.client)
				spawn(0)
					if(M.locked_to)
						shake_camera(M, 3, 1) // locked_to, not a lot of shaking
					else
						shake_camera(M, 10, 1) // unlocked_to, HOLY SHIT SHAKE THE ROOM
			if(istype(M, /mob/living/carbon))
				if(!M.locked_to)
					M.Weaken(3)

		mining_shuttle_moving = 0
	return

/obj/machinery/computer/mining_shuttle
	name = "mining shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list(access_mining)
	circuit = "/obj/item/weapon/circuitboard/mining_shuttle"
	var/location = 0 //0 = station, 1 = mining base
	machine_flags = EMAGGABLE | SCREWTOGGLE
	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/mining_shuttle/attack_hand(user as mob)
	if(..(user))
		return
	src.add_fingerprint(usr)
	var/dat = "<center>Mining shuttle:<br> <b><A href='?src=\ref[src];move=[1]'>Send</A></b></center>"
	user << browse("[dat]", "window=miningshuttle;size=200x100")

/obj/machinery/computer/mining_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(ticker.mode.name == "blob")
			if(ticker.mode:declared)
				to_chat(usr, "Under directive 7-10, [station_name()] is quarantined until further notice.")
				return
		var/area/A = locate(/area/shuttle/mining/station)
		if(!mining_shuttle_location)
			var/list/search = A.search_contents_for(/obj/item/weapon/disk/nuclear)
			if(!isemptylist(search))
				to_chat(usr, "<span class='notice'>The nuclear disk is too precious for Nanotrasen to send it to an Asteroid.</span>")
				return
		if (!mining_shuttle_moving)
			to_chat(usr, "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>")
			move_mining_shuttle()
		else
			to_chat(usr, "<span class='notice'>Shuttle is already moving.</span>")

/obj/machinery/computer/mining_shuttle/emag(mob/user as mob)
	..()
	src.req_access = list()
	to_chat(usr, "You disable the console's access requirement.")
*/
/******************************Lantern*******************************/

/obj/item/device/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	desc = "A mining lantern."
	brightness_on = 6			// luminosity when on
	light_power = 2
	light_color = LIGHT_COLOR_TUNGSTEN

//Explicit
/obj/item/device/flashlight/lantern/on/New()
	..()

	on = 1
	update_brightness()

/*****************************Pickaxe********************************/

//Dig constants defined in setup.dm

/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/items.dmi'
	icon_state = "pickaxe"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	force = 15.0
	throwforce = 4.0
	item_state = "pickaxe"
	w_class = W_CLASS_LARGE
	sharpness = 0.6
	starting_materials = list(MAT_IRON = 3750) //one sheet, but where can you make them?
	w_type = RECYK_METAL
	var/digspeed = 40 //moving the delay to an item var so R&D can make improved picks. --NEO
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("hits", "pierces", "slices", "attacks")
	var/drill_sound = 'sound/weapons/Genhit.ogg'
	var/drill_verb = "picking"
	var/diggables = DIG_ROCKS

	var/excavation_amount = 100

/obj/item/weapon/pickaxe/hammer
	name = "sledgehammer"
	//icon_state = "sledgehammer" Waiting on sprite
	desc = "A mining hammer made of reinforced metal. You feel like smashing your boss in the face with this."
	drill_verb = "hammering"

/obj/item/weapon/pickaxe/silver
	name = "silver pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 30
	origin_tech = "materials=3"
	desc = "This makes no metallurgic sense."

/obj/item/weapon/pickaxe/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	digspeed = 20 //faster than drill, but cannot dig
	origin_tech = "materials=3;powerstorage=2;engineering=2"
	desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."
	drill_verb = "hammering"

/obj/item/weapon/pickaxe/gold
	name = "golden pickaxe"
	icon_state = "gpickaxe"
	item_state = "gpickaxe"
	digspeed = 20
	origin_tech = "materials=4"
	desc = "This makes no metallurgic sense."

/obj/item/weapon/pickaxe/plasmacutter
	name = "plasma cutter"
	icon_state = "plasmacutter"
	item_state = "gun"
	w_class = W_CLASS_MEDIUM //it is smaller than the pickaxe
	damtype = "fire"
	heat_production = 3800
	digspeed = 20 //Can slice though normal walls, all girders, or be used in reinforced wall deconstruction/ light thermite on fire
	sharpness = 1.0
	origin_tech = "materials=4;plasmatech=3;engineering=3"
	desc = "A rock cutter that uses bursts of hot plasma. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	diggables = DIG_ROCKS | DIG_WALLS
	drill_verb = "cutting"
	drill_sound = 'sound/items/Welder.ogg'

/obj/item/weapon/pickaxe/plasmacutter/is_hot()
	return 1

/obj/item/weapon/pickaxe/diamond
	name = "diamond pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 10
	sharpness = 1.2
	origin_tech = "materials=6;engineering=4"
	desc = "A pickaxe with a diamond pick head, this is just like minecraft."

/obj/item/weapon/pickaxe/drill
	name = "mining drill" // Can dig sand as well!
	icon_state = "handdrill"
	item_state = "jackhammer"
	digspeed = 30
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	desc = "Yours is the drill that will pierce through the rock walls."
	drill_verb = "drilling"

	diggables = DIG_ROCKS | DIG_SOIL //drills are multipurpose

/obj/item/weapon/pickaxe/drill/diamond //When people ask about the badass leader of the mining tools, they are talking about ME!
	name = "diamond mining drill"
	icon_state = "diamonddrill"
	item_state = "jackhammer"
	digspeed = 5 //Digs through walls, girders, and can dig up sand
	origin_tech = "materials=6;powerstorage=4;engineering=5"
	desc = "Yours is the drill that will pierce the heavens!"

	diggables = DIG_ROCKS | DIG_SOIL | DIG_WALLS | DIG_RWALLS

/obj/item/weapon/pickaxe/drill/borg
	name = "cyborg mining drill"
	icon_state = "diamonddrill"
	item_state = "jackhammer"
	digspeed = 15
	desc = ""

/*****************************Shovel********************************/

/obj/item/weapon/pickaxe/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon_state = "shovel"
	force = 8.0
	throwforce = 4.0
	item_state = "shovel"
	w_class = W_CLASS_MEDIUM
	sharpness = 0.5
	w_type = RECYK_MISC
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashes", "bludgeons", "thrashes", "whacks")


	digspeed = 40
	diggables = DIG_SOIL //soil only

/obj/item/weapon/pickaxe/shovel/spade
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
<<<<<<< HEAD
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
=======
	force = 5.0
	sharpness = 0.8
	throwforce = 7.0
	w_class = W_CLASS_SMALL

	digspeed = 60 //slower than the large shovel

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
<<<<<<< HEAD
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
	origin_tech = "engineering=3;bluespace=3"
	var/template_id = "shelter_alpha"
	var/datum/map_template/shelter/template
	var/used = FALSE

/obj/item/weapon/survivalcapsule/proc/get_template()
	if(template)
		return
	template = shelter_templates[template_id]
	if(!template)
		throw EXCEPTION("Shelter template ([template_id]) not found!")
		qdel(src)

/obj/item/weapon/survivalcapsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	. = ..()

/obj/item/weapon/survivalcapsule/examine(mob/user)
	. = ..()
	get_template()
	user << "This capsule has the [template.name] stored."
	user << template.description

/obj/item/weapon/survivalcapsule/attack_self()
	// Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(used == FALSE)
		src.loc.visible_message("<span class='warning'>\The [src] begins \
			to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		var/turf/deploy_location = get_turf(src)
		var/status = template.check_deploy(deploy_location)
		switch(status)
			if(SHELTER_DEPLOY_BAD_AREA)
				src.loc.visible_message("<span class='warning'>\The [src] \
				will not function in this area.</span>")
			if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
				var/width = template.width
				var/height = template.height
				src.loc.visible_message("<span class='warning'>\The [src] \
				doesn't have room to deploy! You need to clear a \
				[width]x[height] area!</span>")

		if(status != SHELTER_DEPLOY_ALLOWED)
			used = FALSE
			return

		playsound(get_turf(src), 'sound/effects/phasein.ogg', 100, 1)

		var/turf/T = deploy_location
		if(T.z != ZLEVEL_MINING && T.z != ZLEVEL_LAVALAND)//only report capsules away from the mining/lavaland level
			message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) activated a bluespace capsule away from the mining level! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [T.x], [T.y], [T.z]")
		template.load(deploy_location, centered = TRUE)
		PoolOrNew(/obj/effect/particle_effect/smoke, get_turf(src))
		qdel(src)

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
	assemblytype = /obj/structure/door_assembly/door_assembly_pod
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/survival_pod/vertical
	icon = 'icons/obj/doors/airlocks/survival/vertical/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/vertical/survival_overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_pod/vertical

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
		cut_overlays()
	else
		add_overlay("sleeper_cover")

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
	icon_state = "donkvendor"
	icon = 'icons/obj/lavaland/donkvendor.dmi'
	icon_on = "donkvendor"
	icon_off = "donkvendor"
	luminosity = 8
	max_n_of_items = 10
	pixel_y = -4

/obj/machinery/smartfridge/survival_pod/empty
	name = "dusty survival pod storage"
	desc = "A heated storage unit. This one's seen better days."

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
	layer = ABOVE_NORMAL_TURF_LAYER
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
	desc = "A sign of relief for weary miners, and a warning for would-be competitors to Nanotrasen's mining claims."
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
	layer = BELOW_MOB_LAYER
	density = 0
=======
	icon = 'icons/obj/storage.dmi'
	icon_state = "miningcar"
	density = 1
	icon_opened = "miningcaropen"
	icon_closed = "miningcar"

/**********************Jaunter**********************/

/obj/item/device/wormhole_jaunter
	name = "wormhole jaunter"
	desc = "A single use device harnessing outdated wormhole technology, Nanotrasen has since turned its eyes to blue space for more accurate teleportation. The wormholes it creates are unpleasant to travel through, to say the least."
	icon = 'icons/obj/items.dmi'
	icon_state = "Jaunter"
	item_state = "electronic"
	throwforce = 0
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	origin_tech = "bluespace=2"

/obj/item/device/wormhole_jaunter/attack_self(mob/user as mob)
	var/turf/device_turf = get_turf(user)
	if(!device_turf||device_turf.z==CENTCOMM_Z||device_turf.z>=map.zLevels.len)
		to_chat(user, "<span class='notice'>You're having difficulties getting the [src.name] to work.</span>")
		return
	else
		user.visible_message("<span class='notice'>[user.name] activates the [src.name]!</span>")
		var/list/L = new()

		for (var/obj/item/beacon/B in beacons)
			var/turf/T = get_turf(B)

			if (!isnull(T))
				if (T.z == map.zMainStation)
					L.Add(B)

		if(!L.len)
			to_chat(user, "<span class='notice'>The [src.name] failed to create a wormhole.</span>")
			return
		var/chosen_beacon = pick(L)
		var/obj/effect/portal/jaunt_tunnel/J = new /obj/effect/portal/jaunt_tunnel(get_turf(src))
		J.target = chosen_beacon
		try_move_adjacent(J)
		playsound(src,'sound/effects/sparks4.ogg', 50, 1)
		qdel(src) //Single-use

/obj/effect/portal/jaunt_tunnel
	name = "jaunt tunnel"
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"
	desc = "A stable hole in the universe made by a wormhole jaunter. Turbulent doesn't even begin to describe how rough passage through one of these is, but at least it will always get you somewhere near a beacon."

/*/obj/effect/portal/wormhole/jaunt_tunnel/teleport(atom/movable/M)
	if(istype(M, /obj/effect))
		return
	if(istype(M, /atom/movable))
		do_teleport(M, target, 6) */

/obj/effect/portal/jaunt_tunnel/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect))
		return
	if(!(istype(M, /atom/movable)))
		return
	if(!(target))
		qdel(src)

	//For safety. May be unnecessary.
	var/T = target
	if(!(isturf(T)))
		T = get_turf(target)

	if(prob(1)) //Honk
		T = (locate(rand(5, world.maxx - 10), rand(5, world.maxy - 10),3))

	do_teleport(M, T, 6)

	if(isliving(M))
		var/mob/living/L = M
		L.Weaken(3)
		if(ishuman(L))
			shake_camera(L, 20, 1)
			spawn(20)
				if(L)
					L.visible_message("<span class='danger'>[L] vomits from travelling through \the [src]!</span>")
					L.nutrition = max(L.nutrition-20,0)
					L.adjustToxLoss(-3)
					var/turf/V = get_turf(L) //V for Vomit
					V.add_vomit_floor(L)
					playsound(V, 'sound/effects/splat.ogg', 50, 1)
					return
	return

/**********************Resonator**********************/

/obj/item/weapon/resonator
	name = "resonator"
	icon = 'icons/obj/items.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	desc = "A handheld device that creates small fields of energy that resonate until they detonate, crushing rock. It can also be activated without a target to create a field at the user's location, to act as a delayed time trap. It's more effective in a vaccuum."
	w_class = W_CLASS_MEDIUM
	force = 10
	throwforce = 10
	var/cooldown = 0

/obj/item/weapon/resonator/proc/CreateResonance(var/target, var/creator)
	if(cooldown <= 0)
		playsound(get_turf(src),'sound/effects/stealthoff.ogg',50,1)
		var/obj/effect/resonance/R = new /obj/effect/resonance(get_turf(target))
		R.creator = creator
		cooldown = 1
		spawn(20)
			cooldown = 0

/obj/item/weapon/resonator/attack_self(mob/user as mob)
	CreateResonance(src, user)
	..()

/obj/item/weapon/resonator/afterattack(atom/target, mob/user, proximity_flag)
	if(target in user.contents)
		return
	if(proximity_flag)
		CreateResonance(target, user)

/obj/effect/resonance
	name = "resonance field"
	desc = "A resonating field that significantly damages anything inside of it when the field eventually ruptures."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield1"
	layer = 4.1
	mouse_opacity = 0
	var/resonance_damage = 30
	var/creator = null

/obj/effect/resonance/New()
	..()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf))
		return
	if(istype(proj_turf, /turf/unsimulated/mineral))
		var/turf/unsimulated/mineral/M = proj_turf
		playsound(src, 'sound/effects/sparks4.ogg',50,1)
		M.GetDrilled()
		spawn(5)
			qdel(src)
	else
		var/datum/gas_mixture/environment = proj_turf.return_air()
		var/pressure = environment.return_pressure()
		if(pressure < 50)
			name = "strong resonance field"
			resonance_damage = 60
		spawn(50)
			playsound(src,'sound/effects/sparks4.ogg',50,1)
			if(creator)
				for(var/mob/living/L in src.loc)
					add_logs(creator, L, "used a resonator field on", object = "resonator")
					to_chat(L, "<span class='danger'>\The [src] ruptured with you in it!</span>")
					L.adjustBruteLoss(resonance_damage)
			else
				for(var/mob/living/L in src.loc)
					to_chat(L, "<span class='danger'>\The [src] ruptured with you in it!</span>")
					L.adjustBruteLoss(resonance_damage)
			qdel(src)

/**********************Facehugger toy**********************/

/obj/item/clothing/mask/facehugger/toy
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	throwforce = 0
	sterile = 1
	//tint = 3 //Makes it feel more authentic when it latches on

/obj/item/clothing/mask/facehugger/toy/Die()
	return

/**********************Mining drone cube**********************/

/obj/item/weapon/mining_drone_cube
	name = "mining drone cube"
	desc = "Compressed mining drone, ready for deployment. Just unwrap the cube!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "minedronecube"

/obj/item/weapon/mining_drone_cube/attack_self(mob/user)

	user.visible_message("<span class='warning'>\The [src] suddenly expands into a fully functional mining drone!</span>", \
	"<span class='warning'>You carefully unwrap \the [src] and it suddenly expands into a fully functional mining drone!</span>")
	new /mob/living/simple_animal/hostile/mining_drone(get_turf(src))
	qdel(src)

/**********************Mining drone**********************/

/mob/living/simple_animal/hostile/mining_drone
	name = "nanotrasen minebot"
	desc = "A small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANWEAKEN|CANPUSH
	mouse_opacity = 1
	faction = "neutral"
	a_intent = I_HURT
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	wander = 0
	idle_vision_range = 5
	move_to_delay = 10
	retreat_distance = 1
	minimum_distance = 2
	health = 100
	maxHealth = 100
	melee_damage_lower = 15
	melee_damage_upper = 15
	environment_smash = 0
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	ranged = 1
	ranged_message = "shoots"
	ranged_cooldown_cap = 3
	projectiletype = /obj/item/projectile/beam
	projectilesound = 'sound/weapons/Laser.ogg'
	wanted_objects = list(/obj/item/weapon/ore)
	meat_type = null

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.welding && !stat)
			if(stance != HOSTILE_STANCE_IDLE)
				to_chat(user, "<span class='warning'>\The [src] is moving around too much to repair!</span>")
				return
			if(maxHealth == health)
				to_chat(user, "<span class='notice'>\The [src] is at full integrity.</span>")
			else
				health += 10
				user.visible_message("<span class='notice'>[user] repairs some of the armor on \the [src].</span>", \
				"<span class='notice'>You repair some of the armor on \the [src].</span>")
			return
	if(istype(I, /obj/item/device/mining_scanner))
		to_chat(user, "<span class='notice'>You instruct \the [src] to drop any collected ore.</span>")
		DropOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/Die()
	..()
	visible_message("<span class='danger'>\The [src] blows apart!</span>")
	new /obj/effect/decal/remains/robot(src.loc)
	DropOre()
	qdel(src)
	return

/mob/living/simple_animal/hostile/mining_drone/New()
	..()
	SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == I_HELP)
		switch(search_objects)
			if(0)
				SetCollectBehavior()
				to_chat(M, "<span class='info'>\The [src] will now search and store loose ore.</span>")
			if(2)
				SetOffenseBehavior()
				to_chat(M, "<span class='info'>\The [src] will now attack hostile wildlife.</span>")
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	stop_automated_movement_when_pulled = 1
	idle_vision_range = 9
	search_objects = 2
	wander = 1
	ranged = 0
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	stop_automated_movement_when_pulled = 0
	idle_vision_range = 5
	search_objects = 0
	wander = 0
	ranged = 1
	retreat_distance = 1
	minimum_distance = 2
	icon_state = "mining_drone_offense"

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		CollectOre()
		return
	..()

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	var/obj/item/weapon/ore/O
	for(O in src.loc)
		O.loc = src
	for(var/dir in alldirs)
		var/turf/T = get_step(src,dir)
		for(O in T)
			O.loc = src
	return

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre()
	if(!contents.len)
		return
	for(var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = src.loc
	return

/mob/living/simple_animal/hostile/mining_drone/adjustBruteLoss()
	if(search_objects)
		SetOffenseBehavior()
	..()

/**********************Lazarus Injector**********************/

/obj/item/weapon/lazarus_injector
	name = "lazarus injector"
	desc = "An injector with a cocktail of nanomachines and chemicals, this device can seemingly raise animals from the dead and make them friendly to the user (but retains previous nature aside from that). Unfortunately, the process is useless on higher lifeforms and incredibly costly, so these were stored away until an executive thought they'd be great motivation for some of their employees."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "lazarus_hypo"
	item_state = "hypo"
	throwforce = 0
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	var/loaded = 1

/obj/item/weapon/lazarus_injector/update_icon()
	..()
	if(loaded)
		icon_state = "lazarus_hypo"
	else
		icon_state = "lazarus_empty"

/obj/item/weapon/lazarus_injector/afterattack(atom/target, mob/user, proximity_flag)
	if(!loaded)
		return
	if(istype(target, /mob/living) && proximity_flag)
		if(istype(target, /mob/living/simple_animal))
			var/mob/living/simple_animal/M = target

			if(M.stat == DEAD)
				M.faction = "lazarus \ref[user]"
				M.revive()
				if(istype(target, /mob/living/simple_animal/hostile))
					var/mob/living/simple_animal/hostile/H = M
					H.friends += user
					log_game("[user] has revived hostile mob [target] with a lazarus injector")
				loaded = 0
				user.visible_message("<span class='warning'>[user] injects [M] with \the [src], reviving it.</span>", \
				"<span class='notice'>You inject [M] with \the [src], reviving it.</span>")
				playsound(src,'sound/effects/refill.ogg',50,1)
				update_icon()
				return
			else
				to_chat(user, "<span class='warning'>\The [src] is only effective on the dead.</span>")
				return
		else
			to_chat(user, "<span class='warning'>\The [src] is only effective on lesser beings.</span>")
			return

/obj/item/weapon/lazarus_injector/examine(mob/user)
	..()
	if(!loaded)
		to_chat(user, "<span class='info'>\The [src] is empty.</span>")

/*********************Mob Capsule*************************/

/obj/item/device/mobcapsule
	name = "lazarus capsule"
	desc = "It allows you to store and deploy lazarus-injected creatures easier."
	icon = 'icons/obj/mobcap.dmi'
	icon_state = "mobcap0"
	throwforce = 00
	throw_speed = 4
	throw_range = 20
	force = 0
	var/storage_capacity = 1
	var/mob/living/capsuleowner = null
	var/tripped = 0
	var/colorindex = 0
	var/mob/contained_mob

/obj/item/device/mobcapsule/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/pen))
		if(user != capsuleowner)
			to_chat(user, "<span class='warning'>\The [src] briefly flashes an error.</span>")
			return 0
		spawn()
			var/mname = sanitize(input("Choose a name for your friend.", "Name your friend", contained_mob.name) as text|null)
			if(mname)
				contained_mob.name = mname
				to_chat(user, "<span class='notice'>Renaming successful, say hello to [contained_mob]</span>")
				name = "lazarus capsule - [mname]"
	..()

/obj/item/device/mobcapsule/throw_impact(atom/A, mob/user)
	..()
	if(!tripped)
		if(contained_mob)
			dump_contents(user)
			tripped = 1
		else
			take_contents(user)
			tripped = 1

/obj/item/device/mobcapsule/proc/insert(var/atom/movable/AM, mob/user)


	if(contained_mob)
		return -1

	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(L.locked_to)
			return 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
	else if(!istype(AM, /obj/item) && !istype(AM, /obj/effect/dummy/chameleon))
		return 0
	else if(AM.density || AM.anchored)
		return 0
	AM.loc = src
	contained_mob = AM
	name = "lazarus capsule - [AM.name]"
	return 1

/obj/item/device/mobcapsule/pickup(mob/user)
	tripped = 0
	capsuleowner = user

/obj/item/device/mobcapsule/proc/dump_contents(mob/user)
	/*
	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src)
		AD.loc = src.loc

	for(var/obj/O in src)
		O.loc = src.loc

	for(var/mob/M in src)
		M.loc = src.loc
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
*/
	if(contained_mob)
		contained_mob.loc = src.loc
		if(contained_mob.client)
			contained_mob.client.eye = contained_mob.client.mob
			contained_mob.client.perspective = MOB_PERSPECTIVE
		contained_mob = null
		name = "lazarus capsule"

/obj/item/device/mobcapsule/attack_self(mob/user)
	colorindex += 1
	if(colorindex >= 6)
		colorindex = 0
	icon_state = "mobcap[colorindex]"
	update_icon()

/obj/item/device/mobcapsule/proc/take_contents(mob/user)
	for(var/mob/living/simple_animal/AM in src.loc)
		if(istype(AM))
			var/mob/living/simple_animal/M = AM
			var/mob/living/simple_animal/hostile/H = M
			if(!istype(H)) continue
			for(var/things in H.friends)
				if(capsuleowner in H.friends)
					if(insert(AM, user) == -1) //Limit reached
						break

/**********************Mining Scanner**********************/

/obj/item/device/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals, it can also be used to stop gibtonite detonations. Requires you to wear mesons to use optimally."
	name = "mining scanner"
	icon_state = "mining"
	item_state = "analyzer"
	w_class = W_CLASS_SMALL
	flags = 0
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	var/cooldown = 0

/obj/item/device/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(!cooldown)
		cooldown = 1
		spawn(40)
			cooldown = 0
		var/client/C = user.client
		var/list/L = list()
		var/turf/unsimulated/mineral/M
		for(M in range(7, user))
			if(M.scan_state)
				L += M
		if(!L.len)
			to_chat(user, "<span class='notice'>\The [src] reports that nothing was detected nearby.</span>")
			return
		else
			for(M in L)
				var/turf/T = get_turf(M)
				var/image/I = image('icons/turf/walls.dmi', loc = T, icon_state = M.scan_state, layer = 18)
				C.images += I
				spawn(30)
					if(C)
						C.images -= I

/**********************Xeno Warning Sign**********************/

/obj/structure/sign/xeno_warning_mining
	name = "DANGEROUS ALIEN LIFE"
	desc = "A sign that warns would-be space travellers of hostile alien life in the vicinity."
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
