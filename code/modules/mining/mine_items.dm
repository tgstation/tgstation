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
	icon_state = "mining"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/industrial(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/device/mining_scanner(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/clothing/glasses/meson(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Used to call and send the mining shuttle."
	req_access = list(access_mining)
	circuit = /obj/item/weapon/circuitboard/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away"

/*********************Pickaxe & Drills**************************/

/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/mining.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 15
	throwforce = 10.0
	item_state = "pickaxe"
	w_class = 4.0
	m_amt = 3750 //one sheet, but where can you make them?
	var/digspeed = 40
	var/list/digsound = list('sound/effects/picaxe1.ogg','sound/effects/picaxe2.ogg','sound/effects/picaxe3.ogg')
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("hit", "pierced", "sliced", "attacked")

/obj/item/weapon/pickaxe/proc/playDigSound()
	playsound(src, pick(digsound),50,1)

/obj/item/weapon/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 20 //mines twice as fast as a normal pickaxe, bought from mining vendor
	origin_tech = "materials=4;engineering=3"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."

/obj/item/weapon/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	item_state = "jackhammer"
	digspeed = 25 //available from roundstart, faster than a pickaxe but needs recharging or cell replacements
	digsound = list('sound/weapons/drill.ogg')
	hitsound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	desc = "An electric mining drill for the especially scrawny."
	var/drillcost = 15 //666 mineral walls by default
	var/obj/item/weapon/stock_parts/cell/high/bcell = null

/obj/item/weapon/pickaxe/drill/New() //this one starts with a cell pre-installed.
	..()
	bcell = new(src)
	return

/obj/item/weapon/pickaxe/drill/update_icon()
	if(!bcell)
		icon_state = "[initial(icon_state)]-nocell"
	else if(bcell.charge < drillcost)
		icon_state = "[initial(icon_state)]-empty"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/weapon/pickaxe/drill/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(bcell)
			user << "<span class='notice'>[src] already has a cell.</span>"
		else
			user.drop_item()
			W.loc = src
			bcell = W
			user << "<span class='notice'>You install a cell in [src].</span>"
			update_icon()
	else
		..()

/obj/item/weapon/pickaxe/drill/attack_self(mob/user)
	if(bcell)
		bcell.updateicon()
		bcell.loc = get_turf(src.loc)
		bcell = null
		user << "<span class='notice'>You remove the cell from [src].</span>"
		update_icon()
	else
		user << "<span class='notice'>There is no cell in [src].</span>"

/obj/item/weapon/pickaxe/drill/examine(mob/user)
	..()
	if(bcell)
		user <<"<span class='notice'>The [src.name] is [round(bcell.percent())]% charged.</span>"
	if(!bcell)
		user <<"<span class='warning'>The [src.name] does not have a power source installed.</span>"

/obj/item/weapon/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	var/warned = 0

/obj/item/weapon/pickaxe/drill/cyborg/attack_self(mob/user)
	return //can't remove the drill's cell

/obj/item/weapon/pickaxe/drill/cyborg/proc/use_robot_power(var/mob/living/silicon/robot/R)
	if(!bcell.use(drillcost))
		if(!warned)
			usr << "<span class='danger'>Drill internal battery depleted, power will be drawn from user's power supply.</span>"
			playsound(src, 'sound/weapons/smg_empty_alarm.ogg',50,1)
			warned = 1
		if(!R.cell.use(drillcost))
			R << "<span class='notice'>You don't have enough charge to drill.</span>"
			return 0
	return 1

/obj/item/weapon/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	digspeed = 10 //it's a fast drill with a relatively low power cost. what more could you ask for?
	origin_tech = "materials=6;powerstorage=4;engineering=5"
	desc = "Yours is the drill that will pierce the heavens!"
	drillcost = 25 //400 mineral walls by default, but very quickly

/obj/item/weapon/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	digspeed = 5 //the epitome of powertools. high power consumption, extremely fast mining, laughs at puny walls
	origin_tech = "materials=3;powerstorage=2;engineering=2"
	digsound = list('sound/weapons/sonic_jackhammer.ogg')
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."
	drillcost = 30 //333 mineral walls by default, but very quickly

/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/mining.dmi'
	icon_state = "shovel"
	flags = CONDUCT
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
	icon_crate = "miningcar"
	icon_state = "miningcar"
