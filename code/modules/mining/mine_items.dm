/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	luminosity = 8

/**********************Miner Lockers**************************/

/obj/structure/closet/secure_closet/miner
	name = "Miner's Equipment"
	icon_state = "miningsec1"
	icon_closed = "miningsec"
	icon_locked = "miningsec1"
	icon_broken = "miningsecbroken"
	icon_off = "miningsecoff"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	sleep(2)
	new /obj/item/device/analyzer(src)
	new /obj/item/device/radio/headset/headset_mine(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/weapon/satchel(src)
	new /obj/item/device/flashlight/lantern(src)
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/clothing/glasses/meson(src)


/**********************Shuttle Computer**************************/

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
				// NOTE: Commenting this out to avoid recreating mass driver glitch
				/*
				spawn(0)
					AM.throw_at(E, 1, 1)
					return
				*/

			if(istype(T, /turf/simulated))
				del(T)

		for(var/mob/living/carbon/bug in toArea) // If someone somehow is still in the shuttle's docking area...
			bug.gib()

		fromArea.move_contents_to(toArea)
		if (mining_shuttle_location)
			mining_shuttle_location = 0
		else
			mining_shuttle_location = 1
		mining_shuttle_moving = 0
	return

/obj/machinery/computer/mining_shuttle
	name = "Mining Shuttle Console"
	icon = 'computer.dmi'
	icon_state = "shuttle"
	req_access = list(access_mining)
	var/hacked = 0
	var/location = 0 //0 = station, 1 = mining base

/obj/machinery/computer/mining_shuttle/attack_hand(user as mob)
	src.add_fingerprint(usr)
	var/dat
	dat = text("<center>Mining shuttle:<br> <b><A href='?src=\ref[src];move=[1]'>Send</A></b></center>")
	user << browse("[dat]", "window=miningshuttle;size=200x100")

/obj/machinery/computer/mining_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		if(ticker.mode.name == "blob")
			if(ticker.mode:declared)
				usr << "Under directive 7-10, [station_name()] is quarantined until further notice."
				return

		if (!mining_shuttle_moving)
			usr << "\blue Shuttle recieved message and will be sent shortly."
			move_mining_shuttle()
		else
			usr << "\blue Shuttle is already moving."

/obj/machinery/computer/mining_shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/card/emag))
		src.req_access = list()
		hacked = 1
		usr << "You fried the consoles ID checking system. It's now available to everyone!"

/******************************Lantern*******************************/

/obj/item/device/flashlight/lantern
	name = "Mining Lantern"
	icon_state = "lantern-off"
	desc = "A miner's lantern"
	anchored = 0
	icon_on = "lantern-on"
	icon_off = "lantern-off"
	var/brightness = 12			// luminosity when on

/obj/item/device/flashlight/lantern/New()
	luminosity = 0
	on = 0
	return

/obj/item/device/flashlight/lantern/attack_self(mob/user)
	src.add_fingerprint(user)
	on = !on
	update_brightness(user)
	return

/*****************************Pickaxe********************************/

/obj/item/weapon/pickaxe
	name = "Miner's pickaxe"
	icon = 'items.dmi'
	icon_state = "pickaxe"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 15.0
	throwforce = 4.0
	item_state = "pickaxe"
	w_class = 4.0
	m_amt = 3750 //one sheet, but where can you make them?
	var/digspeed = 40 //moving the delay to an item var so R&D can make improved picks. --NEO
	origin_tech = "materials=1;engineering=1"

	hammer
		name = "Mining Sledge Hammer"
		desc = "A mining hammer made of reinforced metal. You feel like smashing your boss in the face with this."

	silver
		name = "Silver Pickaxe"
		icon_state = "spickaxe"
		item_state = "spickaxe"
		digspeed = 30
		origin_tech = "materials=3"
		desc = "This makes no metallurgic sense."

	drill
		name = "Mining Drill" // Can dig sand as well!
		icon_state = "handdrill"
		item_state = "jackhammer"
		digspeed = 30
		origin_tech = "materials=2;powerstorage=3;engineering=2"
		desc = "Yours is the drill that will pierce through the rock walls."

	jackhammer
		name = "Sonic Jackhammer"
		icon_state = "jackhammer"
		item_state = "jackhammer"
		digspeed = 20 //faster than drill, but cannot dig
		origin_tech = "materials=3;powerstorage=2;engineering=2"
		desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."

	gold
		name = "Golden Pickaxe"
		icon_state = "gpickaxe"
		item_state = "gpickaxe"
		digspeed = 20
		origin_tech = "materials=4"
		desc = "This makes no metallurgic sense."

	plasmacutter
		name = "Plasma Cutter"
		icon_state = "plasmacutter"
		item_state = "gun"
		w_class = 3.0 //it is smaller than the pickaxe
		damtype = "fire"
		digspeed = 20 //Can slice though normal walls, all girders, or be used in reinforced wall deconstruction/ light thermite on fire
		origin_tech = "materials=4;plasmatech=3;engineering=3"
		desc = "A rock cutter that uses bursts of hot plasma. You could use it to cut limbs off of xenos! Or, you know, mine stuff."

	diamond
		name = "Diamond Pickaxe"
		icon_state = "dpickaxe"
		item_state = "dpickaxe"
		digspeed = 10
		origin_tech = "materials=6;engineering=4"
		desc = "A pickaxe with a diamond pick head, this is just like minecraft."

	diamonddrill //When people ask about the badass leader of the mining tools, they are talking about ME!
		name = "Diamond Mining Drill"
		icon_state = "diamonddrill"
		item_state = "jackhammer"
		digspeed = 0 //Digs through walls, girders, and can dig up sand
		origin_tech = "materials=6;powerstorage=4;engineering=5"
		desc = "Yours is the drill that will pierce the heavens!"

	borgdrill
		name = "Cyborg Mining Drill"
		icon_state = "diamonddrill"
		item_state = "jackhammer"
		digspeed = 15
		desc = ""

/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "Shovel"
	icon = 'items.dmi'
	icon_state = "shovel"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 8.0
	throwforce = 4.0
	item_state = "shovel"
	w_class = 3.0
	m_amt = 50
	origin_tech = "materials=1;engineering=1"








/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon = 'storage.dmi'
	icon_state = "miningcar"
	density = 1
	icon_opened = "miningcaropen"
	icon_closed = "miningcar"




