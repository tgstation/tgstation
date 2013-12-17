/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	luminosity = 8

/**********************Miner Lockers**************************/

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "miningsec1"
	icon_closed = "miningsec"
	icon_locked = "miningsec1"
	icon_opened = "miningsecopen"
	icon_broken = "miningsecbroken"
	icon_off = "miningsecoff"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	sleep(2)
	if(prob(50))
		new /obj/item/weapon/storage/backpack/industrial(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/gloves/black(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/device/analyzer(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/device/flashlight/lantern(src)
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/clothing/glasses/meson(src)


/**********************Shuttle Computer**************************/


/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	req_access = list(access_mining)
	circuit = /obj/item/weapon/circuitboard/mining_shuttle
	id = "mining"

/******************************Lantern*******************************/

/obj/item/device/flashlight/lantern
	name = "lantern"
	icon_state = "lantern"
	desc = "A mining lantern."
	brightness_on = 6			// luminosity when on

/*****************************Pickaxe********************************/

/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/items.dmi'
	icon_state = "pickaxe"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 15.0
	throwforce = 4.0
	item_state = "pickaxe"
	w_class = 4.0
	m_amt = 3750 //one sheet, but where can you make them?
	var/digspeed = 40 //moving the delay to an item var so R&D can make improved picks. --NEO
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("hit", "pierced", "sliced", "attacked")

	hammer
		name = "sledgehammer"
		//icon_state = "sledgehammer" Waiting on sprite
		desc = "A mining hammer made of reinforced metal. You feel like smashing your boss in the face with this."

	silver
		name = "silver pickaxe"
		icon_state = "spickaxe"
		item_state = "spickaxe"
		digspeed = 30
		origin_tech = "materials=3"
		desc = "This makes no metallurgic sense."

	drill
		name = "mining drill" // Can dig sand as well!
		icon_state = "handdrill"
		item_state = "jackhammer"
		digspeed = 30
		origin_tech = "materials=2;powerstorage=3;engineering=2"
		desc = "Yours is the drill that will pierce through the rock walls."

	jackhammer
		name = "sonic jackhammer"
		icon_state = "jackhammer"
		item_state = "jackhammer"
		digspeed = 20 //faster than drill, but cannot dig
		origin_tech = "materials=3;powerstorage=2;engineering=2"
		desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."

	gold
		name = "golden pickaxe"
		icon_state = "gpickaxe"
		item_state = "gpickaxe"
		digspeed = 20
		origin_tech = "materials=4"
		desc = "This makes no metallurgic sense."

	plasmacutter
		name = "plasma cutter"
		icon_state = "plasmacutter"
		item_state = "gun"
		w_class = 3.0 //it is smaller than the pickaxe
		damtype = "fire"
		digspeed = 20 //Can slice though normal walls, all girders, or be used in reinforced wall deconstruction/ light thermite on fire
		origin_tech = "materials=4;plasmatech=3;engineering=3"
		desc = "A rock cutter that uses bursts of hot plasma. You could use it to cut limbs off of xenos! Or, you know, mine stuff."

	diamond
		name = "diamond pickaxe"
		icon_state = "dpickaxe"
		item_state = "dpickaxe"
		digspeed = 10
		origin_tech = "materials=6;engineering=4"
		desc = "A pickaxe with a diamond pick head, this is just like minecraft."

	diamonddrill //When people ask about the badass leader of the mining tools, they are talking about ME!
		name = "diamond mining drill"
		icon_state = "diamonddrill"
		item_state = "jackhammer"
		digspeed = 5 //Digs through walls, girders, and can dig up sand
		origin_tech = "materials=6;powerstorage=4;engineering=5"
		desc = "Yours is the drill that will pierce the heavens!"

	borgdrill
		name = "cyborg mining drill"
		icon_state = "diamonddrill"
		item_state = "jackhammer"
		digspeed = 15
		desc = ""

/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/items.dmi'
	icon_state = "shovel"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	force = 8.0
	throwforce = 4.0
	item_state = "shovel"
	w_class = 3.0
	m_amt = 50
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5.0
	throwforce = 7.0
	w_class = 2.0


/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon = 'icons/obj/storage.dmi'
	icon_state = "miningcar"
	density = 1
	icon_opened = "miningcaropen"
	icon_closed = "miningcar"




