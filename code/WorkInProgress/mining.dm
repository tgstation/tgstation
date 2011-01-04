/**********************Mine areas**************************/

/area/mine/explored
	name = "Mine"
	icon_state = "janitor"
	music = null

/area/mine/unexplored
	name = "Mine"
	icon_state = "captain"
	music = null

/area/mine/lobby //DO NOT TURN THE SD_LIGHTING STUFF ON FOR SHUTTLES. IT BREAKS THINGS.
	name = "Mining station"
	requires_power = 0
	luminosity = 1
	icon_state = "mine"
	sd_lighting = 0


/**********************Mineral deposits**************************/

/turf/simulated/mineral //wall piece
	name = "Mineral deposit"
	icon = 'walls.dmi'
	icon_state = "rock"
	opacity = 1
	density = 1
	blocks_air = 1
	var/mineralName = ""
	var/mineralAmt = 0

/turf/simulated/asteroid/New()
	oxygen = 0.01
	nitrogen = 0.01

/turf/simulated/mineral/urenium
	name = "Uranium deposit"
	icon_state = "rock_Uranium"
	mineralName = "Uranium"
	mineralAmt = 5

/turf/simulated/mineral/iron
	name = "Iron deposit"
	icon_state = "rock_Iron"
	mineralName = "Iron"
	mineralAmt = 5

/turf/simulated/mineral/diamond
	name = "Diamond deposit"
	icon_state = "rock_Diamond"
	mineralName = "Diamond"
	mineralAmt = 5

/turf/simulated/mineral/gold
	name = "Gold deposit"
	icon_state = "rock_Gold"
	mineralName = "Gold"
	mineralAmt = 5

/turf/simulated/mineral/silver
	name = "Silver deposit"
	icon_state = "rock_Silver"
	mineralName = "Silver"
	mineralAmt = 5

/turf/simulated/mineral/plasma
	name = "Plasma deposit"
	icon_state = "rock_Plasma"
	mineralName = "Plasma"
	mineralAmt = 5

/turf/simulated/mineral/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/airless/W
	var/old_dir = dir

	W = new /turf/simulated/floor/airless( locate(src.x, src.y, src.z) )
	W.dir = old_dir
	W.icon_state = "asteroid"

	/*
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	*/
	W.opacity = 1
	W.sd_SetOpacity(0)
	W.levelupdate()
	return W

/turf/simulated/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		user << "\red You start picking."
		//playsound(src.loc, 'Welder.ogg', 100, 1)

		sleep(100)
		if ((user.loc == T && user.equipped() == W))
			user << "\blue You finish cutting into the rock."
			gets_drilled()

	else
		return attack_hand(user)
	return

/turf/simulated/mineral/proc/gets_drilled()
	if ((src.mineralName != "") && (src.mineralAmt > 0) && (src.mineralAmt < 11))
		var/i
		for (i=0;i<mineralAmt;i++)
			if (src.mineralName == "Uranium")
				new /obj/item/weapon/ore/uranium(src)
			if (src.mineralName == "Iron")
				new /obj/item/weapon/ore/iron(src)
			if (src.mineralName == "Gold")
				new /obj/item/weapon/ore/gold(src)
			if (src.mineralName == "Silver")
				new /obj/item/weapon/ore/silver(src)
			if (src.mineralName == "Plasma")
				new /obj/item/weapon/ore/plasma(src)
			if (src.mineralName == "Diamond")
				new /obj/item/weapon/ore/diamond(src)
	ReplaceWithFloor()
	return



/**********************Asteroid**************************/

/turf/simulated/floor/airless/asteroid //floor piece
	name = "Asteroid"
	icon = 'floors.dmi'
	icon_state = "asteroid"
	var/seedName = "" //Name of the seed it contains
	var/seedAmt = 0   //Ammount of the seed it contains
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug

/turf/simulated/floor/airless/asteroid/New()
	if (prob(50))
		seedName = pick(list("1","2","3","4"))
		seedAmt = rand(1,4)

/turf/simulated/floor/airless/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/shovel))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug == 1)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'Welder.ogg', 100, 1)

		sleep(50)
		if ((user.loc == T && user.equipped() == W))
			user << "\blue You dug a hole."
			gets_dug()
			dug = 1
			icon_state = "asteroid_dug"

	else
		return attack_hand(user)
	return

/turf/simulated/floor/airless/asteroid/proc/gets_dug()
	if ((src.seedName != "") && (src.seedAmt > 0) && (src.seedAmt < 11))
		var/i
		for (i=0;i<seedAmt;i++)
			if (src.seedName == "1")
				new /obj/item/seeds/alien/alien1(src)
			if (src.seedName == "2")
				new /obj/item/seeds/alien/alien2(src)
			if (src.seedName == "3")
				new /obj/item/seeds/alien/alien3(src)
			if (src.seedName == "4")
				new /obj/item/seeds/alien/alien4(src)
		seedName = ""
		seedAmt = 0
	return

/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "Rock"
	icon = 'Mining.dmi'
	icon_state = "ore"

/obj/item/weapon/ore/uranium
	name = "Uranium ore"
	icon = 'Mining.dmi'
	icon_state = "Uranium ore"

/obj/item/weapon/ore/iron
	name = "Iron ore"
	icon = 'Mining.dmi'
	icon_state = "Iron ore"

/obj/item/weapon/ore/plasma
	name = "Plasma ore"
	icon = 'Mining.dmi'
	icon_state = "Plasma ore"

/obj/item/weapon/ore/silver
	name = "Silver ore"
	icon = 'Mining.dmi'
	icon_state = "Silver ore"

/obj/item/weapon/ore/gold
	name = "Gold ore"
	icon = 'Mining.dmi'
	icon_state = "Gold ore"

/obj/item/weapon/ore/diamond
	name = "Diamond ore"
	icon = 'Mining.dmi'
	icon_state = "Diamond ore"

/obj/item/weapon/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/**********************Alien Seeds**************************/

/obj/item/seeds/alien/alien1
	name = "Space Fungus seed"
	desc = "The seed to the most abundant and annoying weed in the galaxy"
	icon = 'Hydroponics.dmi'
	icon_state = "seed-alien1"

/obj/item/seeds/alien/alien2
	name = "Asynchronous Catitius seed"
	desc = "This seed was only recently discovered and has not been studied properly yet."
	icon = 'Hydroponics.dmi'
	icon_state = "seed-alien2"

/obj/item/seeds/alien/alien3
	name = "Previously undiscovered seed"
	desc = "This appears to be a new type of seed"
	icon = 'Hydroponics.dmi'
	icon_state = "seed-alien3"

/obj/item/seeds/alien/alien4
	name = "Donot plant seed"
	desc = "Is the X a warning?"
	icon = 'Hydroponics.dmi'
	icon_state = "seed-alien4"

/**********************Artifacts**************************/

/obj/machinery/artifact/artifact1
	name = "Alien artifact 1"
	desc = "This odd artifact is something from an alien civilization. I wonder what it does"
	icon = 'Items.dmi'
	icon_state = "strangepresent"

/obj/machinery/artifact/artifact2
	name = "Alien artifact 2"
	desc = "This odd artifact is something from an alien civilization. I wonder what it does"
	icon = 'Items.dmi'
	icon_state = "strangepresent"

/obj/machinery/artifact/artifact3
	name = "Alien artifact 3"
	desc = "This odd artifact is something from an alien civilization. I wonder what it does"
	icon = 'Items.dmi'
	icon_state = "strangepresent"

/obj/machinery/artifact/artifact4
	name = "Alien artifact 4"
	desc = "This odd artifact is something from an alien civilization. I wonder what it does"
	icon = 'Items.dmi'
	icon_state = "strangepresent"

/**********************Input and output plates**************************/

/obj/machinery/mineral/input
	icon = 'craft.dmi'
	icon_state = "core"
	name = "Purifier input area"
	density = 0
	anchored = 1.0

/obj/machinery/mineral/output
	icon = 'craft.dmi'
	icon_state = "core"
	name = "Purifier output area"
	density = 0
	anchored = 1.0


/**********************Mineral purifier (not used, replaced with mineral processing unit)**************************/

/obj/machinery/mineral/purifier
	name = "Ore Purifier"
	desc = "A machine which makes building material out of ores"
	icon = 'computer.dmi'
	icon_state = "aiupload"
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/processed = 0
	var/processing = 0
	density = 1
	anchored = 1.0

/obj/machinery/mineral/purifier/attack_hand(user as mob)

	if(processing == 1)
		user << "The machine is processing"
		return

	var/dat
	dat = text("input connection status: ")
	if (input)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")
	dat += text("<br>output connection status: ")
	if (output)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")

	dat += text("<br><br><A href='?src=\ref[src];purify=[input]'>Purify</A>")

	dat += text("<br><br>found: <font color='green'><b>[processed]</b></font>")
	user << browse("[dat]", "window=purifier")

/obj/machinery/mineral/purifier/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["purify"])
		if (src.output)
			processing = 1;
			var/obj/item/weapon/ore/O
			processed = 0;
			while(locate(/obj/item/weapon/ore, input.loc))
				O = locate(/obj/item/weapon/ore, input.loc)
				if (istype(O,/obj/item/weapon/ore/iron))
					new /obj/item/stack/sheet/metal(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/diamond))
					new /obj/item/stack/sheet/diamond(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/plasma))
					new /obj/item/stack/sheet/plasma(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/gold))
					new /obj/item/stack/sheet/gold(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/silver))
					new /obj/item/stack/sheet/silver(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/uranium))
					new /obj/item/weapon/ore/uranium(output.loc)
					del(O)
				processed++
				sleep(5);
			processing = 0;
	src.updateUsrDialog()
	return


/obj/machinery/mineral/purifier/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, WEST))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, EAST))
		return
	return


/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "Production machine"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null


/obj/machinery/mineral/processing_unit/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, NORTH))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, SOUTH))
		processing_items.Add(src)
		return
	return

/obj/machinery/mineral/processing_unit/process()
	if (src.output && src.input)
		var/obj/item/weapon/ore/O
		O = locate(/obj/item/weapon/ore, input.loc)
		if (istype(O,/obj/item/weapon/ore/iron))
			new /obj/item/stack/sheet/metal(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/diamond))
			new /obj/item/stack/sheet/diamond(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/plasma))
			new /obj/item/stack/sheet/plasma(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/gold))
			new /obj/item/stack/sheet/gold(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/silver))
			new /obj/item/stack/sheet/silver(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/uranium))
			new /obj/item/weapon/ore/uranium(output.loc)
			del(O)

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "Stacking machine"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/stk_types = list()
	var/stk_amt   = list()
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null


/obj/machinery/mineral/stacking_machine/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, EAST))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, WEST))
		processing_items.Add(src)
		return
	return

/*

/obj/machinery/mineral/stacking_machine/process()
	if (src.output && src.input)
		var/obj/item/O
		O = locate(/obj/item, input.loc)

		if (O.type in stk_types)
			var/i
			for (i = 0; i < stk_types.len; i++)
				if (stk_types[i] == O.type)
					stk_amt[i]++
				else
					stk_types += O.type
					stk_amt[stk_types.len-1] = 1

		if (istype(O,/obj/item/weapon/ore/iron))
			new /obj/item/stack/sheet/metal(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/diamond))
			new /obj/item/stack/sheet/diamond(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/plasma))
			new /obj/item/stack/sheet/plasma(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/gold))
			new /obj/item/stack/sheet/gold(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/silver))
			new /obj/item/stack/sheet/silver(output.loc)
			del(O)
		if (istype(O,/obj/item/weapon/ore/uranium))
			new /obj/item/weapon/ore/uranium(output.loc)
			del(O)

*/

/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/amt_silver = 0 //amount of silver
	var/amt_gold = 0   //amount of gold
	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = 0


/obj/machinery/mineral/mint/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, NORTH))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, SOUTH))
		processing_items.Add(src)
		return
	return

/obj/machinery/mineral/mint/process()
	if (src.output && src.input)
		var/obj/item/stack/sheet/O
		O = locate(/obj/item/stack/sheet, input.loc)
		if (istype(O,/obj/item/stack/sheet/gold))
			amt_gold += 100
			del(O)
		if (istype(O,/obj/item/stack/sheet/silver))
			amt_silver += 100
			del(O)


/obj/machinery/mineral/mint/attack_hand(user as mob)

	var/dat
	dat = text("input connection status: ")
	if (input)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")
	dat += text("<br>output connection status: ")
	if (output)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")

	dat += text("<br><br><font color='#ffcc00'><b>Gold inserterd: </b>[amt_gold]</font>")
	dat += text("<br><br><font color='#888888'><b>Silver inserterd: </b>[amt_silver]</font>")

	dat += text("<br><br><A href='?src=\ref[src];makeCoins=[1]'>Make coins</A>")

	dat += text("<br><br>found: <font color='green'><b>[newCoins]</b></font>")
	user << browse("[dat]", "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
	if(processing==1)
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["makeCoins"])
		if (src.output)
			processing = 1;
			while(amt_gold > 0)
				new /obj/item/weapon/coin/gold(output.loc)
				amt_gold -= 20
				newCoins++
				src.updateUsrDialog()
				sleep(5);
			while(amt_silver > 0)
				new /obj/item/weapon/coin/silver(output.loc)
				amt_silver -= 20
				newCoins++
				src.updateUsrDialog()
				sleep(5);
			processing = 0;
	src.updateUsrDialog()
	return


/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 50

/obj/item/weapon/coin/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/weapon/coin/gold
	name = "Gold coin"
	icon_state = "coin_gold"

/obj/item/weapon/coin/silver
	name = "Silver coin"
	icon_state = "coin_silver"



/**********************Gas extractor**************************/

/obj/machinery/mineral/gasextractor
	name = "Gas extractor"
	desc = "A machine which extracts gasses from ores"
	icon = 'computer.dmi'
	icon_state = "aiupload"
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/message = "";
	var/processing = 0
	var/newtoxins = 0
	density = 1
	anchored = 1.0

/obj/machinery/mineral/gasextractor/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, NORTH))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, SOUTH))
		return
	return

/obj/machinery/mineral/gasextractor/attack_hand(user as mob)

	if(processing == 1)
		user << "The machine is processing"
		return

	var/dat
	dat = text("input connection status: ")
	if (input)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")
	dat += text("<br>output connection status: ")
	if (output)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")

	dat += text("<br><br><A href='?src=\ref[src];extract=[input]'>Extract gas</A>")

	dat += text("<br><br>Message: [message]")

	user << browse("[dat]", "window=purifier")

/obj/machinery/mineral/gasextractor/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["extract"])
		if (src.output)
			if (locate(/obj/machinery/portable_atmospherics/canister,output.loc))
				newtoxins = 0
				processing = 1
				var/obj/item/weapon/ore/O
				while(locate(/obj/item/weapon/ore, input.loc) && locate(/obj/machinery/portable_atmospherics/canister,output.loc))
					O = locate(/obj/item/weapon/ore, input.loc)
					if (istype(O,/obj/item/weapon/ore/uranium))
						var/obj/machinery/portable_atmospherics/canister/C
						C = locate(/obj/machinery/portable_atmospherics/canister,output.loc)
						C.air_contents.toxins += 100
						newtoxins += 100
						del(O)
					sleep(5);
				processing = 0;
				message = "Canister filled with [newtoxins] units of toxins"
			else
				message = "No canister found"
	src.updateUsrDialog()
	return

/******************************Lantern*******************************/

/obj/item/device/flashlight/lantern
	name = "Mining Lantern"
	icon = 'lighting.dmi'
	icon_state = "lantern-off"
	desc = "A miner's lantern"
	anchored = 0
	var/brightness = 12			// luminosity when on

/obj/item/device/flashlight/lantern/New()
	luminosity = 0
	on = 0
	return

/obj/item/device/flashlight/lantern/attack_self(mob/user)
	..()
	if (on == 1)
		icon_state = "lantern-on"
	else
		icon_state = "lantern-off"


/*****************************Pickaxe********************************/

/obj/item/weapon/pickaxe
	name = "Miner's pickaxe"
	icon = 'items.dmi'
	icon_state = "pickaxe"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 5.0
	throwforce = 7.0
	item_state = "wrench"
	w_class = 2.0
	m_amt = 50

/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "Shovel"
	icon = 'items.dmi'
	icon_state = "shovel"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 5.0
	throwforce = 7.0
	item_state = "wrench"
	w_class = 2.0
	m_amt = 50


/******************************Materials****************************/

/obj/item/stack/sheet/gold
	name = "gold"
	icon_state = "sheet-gold"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/gold/New()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/silver
	name = "silver"
	icon_state = "sheet-silver"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/silver/New()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/diamond/New()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3


/**********************Rail track**************************/

/obj/machinery/rail_track
	name = "Rail track"
	icon = 'Mining.dmi'
	icon_state = "rail"
	dir = 2
	var/id = null    //this is needed for switches to work Set to the same on the whole length of the track

/**********************Rail intersection**************************/

/obj/machinery/rail_track/intersections
	name = "Rail track intersection"
	icon_state = "rail_intersection"

/obj/machinery/rail_track/intersections/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 5
		if (5) dir = 4
		if (4) dir = 9
		if (9) dir = 2
		if (2) dir = 10
		if (10) dir = 8
		if (8) dir = 6
		if (6) dir = 1
	return

/obj/machinery/rail_track/intersections/NSE
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NSE"
	dir = 2

/obj/machinery/rail_track/intersections/NSE/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 5
		if (2) dir = 5
		if (5) dir = 9
		if (9) dir = 2
	return

/obj/machinery/rail_track/intersections/SEW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_SEW"
	dir = 8

/obj/machinery/rail_track/intersections/SEW/attack_hand(user as mob)
	switch (dir)
		if (8) dir = 6
		if (4) dir = 6
		if (6) dir = 5
		if (5) dir = 8
	return

/obj/machinery/rail_track/intersections/NSW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NSW"
	dir = 2

/obj/machinery/rail_track/intersections/NSW/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 10
		if (2) dir = 10
		if (10) dir = 6
		if (6) dir = 2
	return

/obj/machinery/rail_track/intersections/NEW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NEW"
	dir = 8

/obj/machinery/rail_track/intersections/NEW/attack_hand(user as mob)
	switch (dir)
		if (4) dir = 9
		if (8) dir = 9
		if (9) dir = 10
		if (10) dir = 8
	return

/**********************Rail switch**************************/

/obj/machinery/rail_switch
	name = "Rail switch"
	icon = 'Mining.dmi'
	icon_state = "rail"
	dir = 2
	icon = 'recycling.dmi'
	icon_state = "switch-off"
	var/obj/machinery/rail_track/track = null
	var/id            //used for to change the track pieces

/obj/machinery/rail_switch/New()
	spawn(10)
		src.track = locate(/obj/machinery/rail_track, get_step(src, NORTH))
		if(track)
			id = track.id
	return

/obj/machinery/rail_switch/attack_hand(user as mob)
	user << "You switch the rail track's direction"
	for (var/obj/machinery/rail_track/T in world)
		if (T.id == src.id)
			var/obj/machinery/rail_car/C = locate(/obj/machinery/rail_car, T.loc)
			if (C)
				switch (T.dir)
					if(1)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "N"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(2)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "N"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(4)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "W"
							if("W") C.direction = "E"
					if(8)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "W"
							if("W") C.direction = "E"
					if(5)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "E"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(6)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "W"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(9)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "N"
							if("W") C.direction = "E"
					if(10)
						switch(C.direction)
							if("N") C.direction = "W"
							if("S") C.direction = "W"
							if("E") C.direction = "W"
							if("W") C.direction = "N"
	return


/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon = 'storage.dmi'
	icon_state = "miningcar"
	density = 1
	openicon = "miningcaropen"
	closedicon = "miningcar"

/**********************Rail car**************************/

/obj/machinery/rail_car
	name = "Rail car"
	icon = 'Storage.dmi'
	icon_state = "miningcar"
	var/direction = "S"  //S = south, N = north, E = east, W = west. Determines whichw ay it'll look first
	var/moving = 0;
	anchored = 1
	density = 1

/obj/machinery/rail_car/attack_hand(user as mob)
	if (moving == 0)
		processing_items.Add(src)
		moving = 1
	else
		processing_items.Remove(src)
		moving = 0
	return

/*
for (var/client/C)
	C << "Dela."
*/

/obj/machinery/rail_car/process()
	if (moving == 1)
		switch (direction)
			if ("S")
				for (var/obj/machinery/rail_track/R in locate(src.x,src.y-1,src.z))
					if (R.dir == 10)
						direction = "W"
					if (R.dir == 9)
						direction = "E"
					if (R.dir == 2 || R.dir == 1 || R.dir == 10 || R.dir == 9)
						step(src,get_dir(src,R))
						break
					else
						moving = 0
			if ("N")
				for (var/obj/machinery/rail_track/R in locate(src.x,src.y+1,src.z))
					if (R.dir == 5)
						direction = "E"
					if (R.dir == 6)
						direction = "W"
					if (R.dir == 5 || R.dir == 1 || R.dir == 6 || R.dir == 2)
						step(src,get_dir(src,R))
						break
					else
						moving = 0
			if ("E")
				for (var/obj/machinery/rail_track/R in locate(src.x+1,src.y,src.z))
					if (R.dir == 6)
						direction = "S"
					if (R.dir == 10)
						direction = "N"
					if (R.dir == 4 || R.dir == 8 || R.dir == 10 || R.dir == 6)
						step(src,get_dir(src,R))
						break
					else
						moving = 0
			if ("W")
				for (var/obj/machinery/rail_track/R in locate(src.x-1,src.y,src.z))
					if (R.dir == 9)
						direction = "N"
					if (R.dir == 5)
						direction = "S"
					if (R.dir == 8 || R.dir == 9 || R.dir == 5 || R.dir == 4)
						step(src,get_dir(src,R))
						break
					else
						moving = 0
	else
		processing_items.Remove(src)
		moving = 0
	return


/**********************Spaceship builder area definitions**************************/

/area/shipbuilder
	requires_power = 0
	luminosity = 1
	sd_lighting = 0

/area/shipbuilder/station
	name = "shipbuilder station"
	icon_state = "teleporter"

/area/shipbuilder/ship1
	name = "shipbuilder ship1"
	icon_state = "teleporter"

/area/shipbuilder/ship2
	name = "shipbuilder ship2"
	icon_state = "teleporter"

/area/shipbuilder/ship3
	name = "shipbuilder ship3"
	icon_state = "teleporter"

/area/shipbuilder/ship4
	name = "shipbuilder ship4"
	icon_state = "teleporter"

/area/shipbuilder/ship5
	name = "shipbuilder ship5"
	icon_state = "teleporter"

/area/shipbuilder/ship6
	name = "shipbuilder ship6"
	icon_state = "teleporter"


/**********************Spaceship builder**************************/

/obj/machinery/spaceship_builder
	name = "Robotic Fabricator"
	icon = 'surgery.dmi'
	icon_state = "fab-idle"
	density = 1
	anchored = 1
	var/metal_amount = 0
	var/operating = 0
	var/area/currentShuttleArea = null
	var/currentShuttleName = null

/obj/machinery/spaceship_builder/proc/buildShuttle(var/shuttle)

	var/shuttleat = null
	var/shuttleto = "/area/shipbuilder/station"

	var/req_metal = 0
	switch(shuttle)
		if("hopper")
			shuttleat = "/area/shipbuilder/ship1"
			currentShuttleName = "Planet hopper"
			req_metal = 25000
		if("bus")
			shuttleat = "/area/shipbuilder/ship2"
			currentShuttleName = "Blnder Bus"
			req_metal = 60000
		if("dinghy")
			shuttleat = "/area/shipbuilder/ship3"
			currentShuttleName = "Space dinghy"
			req_metal = 100000
		if("van")
			shuttleat = "/area/shipbuilder/ship4"
			currentShuttleName = "Boxvan MMDLVI"
			req_metal = 120000
		if("secvan")
			shuttleat = "/area/shipbuilder/ship5"
			currentShuttleName = "Boxvan MMDLVI - Security edition"
			req_metal = 125000
		if("station4")
			shuttleat = "/area/shipbuilder/ship6"
			currentShuttleName = "Space station 4"
			req_metal = 250000

	if (metal_amount - req_metal < 0)
		return

	if (!shuttleat)
		return

	var/area/from = locate(shuttleat)
	var/area/dest = locate(shuttleto)

	if(!from || !dest)
		return

	currentShuttleArea = shuttleat
	from.move_contents_to(dest)
	return

/obj/machinery/spaceship_builder/proc/scrapShuttle()

	var/shuttleat = "/area/shipbuilder/station"
	var/shuttleto = currentShuttleArea

	if (!shuttleto)
		return

	var/area/from = locate(shuttleat)
	var/area/dest = locate(shuttleto)

	if(!from || !dest)
		return

	currentShuttleArea = null
	currentShuttleName = null
	from.move_contents_to(dest)
	return

/obj/machinery/spaceship_builder/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(operating == 1)
		user << "The machine is processing"
		return

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/stack/sheet/metal))

		var/obj/item/stack/sheet/metal/M = W
		user << "\blue You insert all the metal into the machine."
		metal_amount += M.amount * 100
		del(M)

	else
		return attack_hand(user)
	return

/obj/machinery/spaceship_builder/attack_hand(user as mob)
	if(operating == 1)
		user << "The machine is processing"
		return

	var/dat
	dat = text("<b>Ship fabricator</b><br><br>")
	dat += text("Current ammount of <font color='gray'>Metal: <b>[metal_amount]</b></font><br><hr>")

	if (currentShuttleArea)
		dat += text("<b>Currently building</b><br><br>[currentShuttleName]<br><br>")
		dat += text("<b>Build the shuttle to your liking.</b><br>This shuttle will be sent to the station in the event of an emergency along with a centcom emergency shuttle.")
		dat += text("<br><br><br><A href='?src=\ref[src];scrap=1'>Scrap current shuttle</A>")
	else
		dat += text("<b>Available ships to build:</b><br><br>")
		dat += text("<A href='?src=\ref[src];ship=hopper'>Planet hopper</A> - Tiny, Slow<br>")
		dat += text("<A href='?src=\ref[src];ship=bus'>Blunder Bus</A> - Small, Decent speed<br>")
		dat += text("<A href='?src=\ref[src];ship=dinghy'>Space dinghy</A> - Medium size, Decent speed<br>")
		dat += text("<A href='?src=\ref[src];ship=van'>Boxvan MMDLVIr</A> - Medium size, Decent speed<br>")
		dat += text("<A href='?src=\ref[src];ship=secvan'>Boxvan MMDLVI - Security eidition</A> - Large, Rather slow<br>")
		dat += text("<A href='?src=\ref[src];ship=station4'>Space station 4</A> - Huge, Slow<br>")

	user << browse("[dat]", "window=shipbuilder")


/obj/machinery/spaceship_builder/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["ship"])
		buildShuttle(href_list["ship"])
	if(href_list["scrap"])
		scrapShuttle(href_list["ship"])
	src.updateUsrDialog()
	return