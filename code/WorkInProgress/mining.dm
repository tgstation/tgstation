/*********************NEW AUTOLATHE / CRAFT LATHE***********************/

var/list/datum/craftlathe_item/CRAFT_ITEMS = list()
var/CRAFT_ITEMS_SETUP = 1        //this should probably be a pre-game thing, but i'll do it so the first lathe2 that's created will set-up the recipes.

proc/check_craftlathe_recipe(var/list/param_recipe)
	if(param_recipe.len != 9)
		return
	var/i
	var/match = 0 //this one counts if there is at least one non-"" ingredient.
	for(var/datum/craftlathe_item/CI in CRAFT_ITEMS)
		match = 0
		for(i = 1; i <= 9; i++)
			if(CI.recipe[i] != param_recipe[i])
				match = 0 //use this so it passes by the match > 0 check below, otherwise i'd need a new variable to tell the return CI below that the check failed
				break
			if(CI.recipe[i] != "")
				match++
		if(match > 0)
			return CI
	return 0

/datum/craftlathe_item
	var/id = "" //must be unique for each item type. used to create recipes
	var/name = "unknown" //what the lathe will show as it's contents
	var/list/recipe = list("","","","","","","","","") //the 9 items here represent what items need to be placed in the lathe to produce this item.
	var/item_type = null //this is used on items like sheets which are added when inserted into the lathe.
	var/amount = 1
	var/amount_attackby = 1

/datum/craftlathe_item/New(var/param_id,var/param_name,var/param_amount,var/param_ammount_per_attackby,var/list/param_recipe,var/param_type = null)
	..()
	id = param_id
	name = param_name
	recipe = param_recipe
	item_type = param_type
	amount = param_amount;
	amount_attackby = param_ammount_per_attackby
	return

//this proc checks the recipe you give in it's parameter with the entire list of available items. If any match, it returns the item from CRAFT_ITEMS. the returned item should not be changed!!

/obj/machinery/autolathe2
	name = "Craft lathe"
	icon_state = "autolathe"
	density = 1
	anchored = 1
	var/datum/craftlathe_item/selected = null
	var/datum/craftlathe_item/make = null
	var/list/datum/craftlathe_item/craft_contents = list()
	var/list/current_recipe = list("","","","","","","","","")

/obj/machinery/autolathe2/New()
	..()
	if(CRAFT_ITEMS_SETUP)
		CRAFT_ITEMS_SETUP = 0
		build_recipes()
	return

/obj/machinery/autolathe2/attack_hand(mob/user as mob)
	var/dat
	dat = text("<h3>Craft Lathe</h3>")
	dat += text("<table><tr><td valign='top'>")

	dat += text("<b>Materials</b><p>")
	var/datum/craftlathe_item/CI
	var/i
	for(i = 1; i <= craft_contents.len; i++)
		CI = craft_contents[i]
		if (CI == selected)
			dat += text("[CI.name] ([CI.amount])<br>")
		else
			dat += text("<A href='?src=\ref[src];select=[i]'>[CI.name]</a> ([CI.amount])<br>")

	dat += text("</td><td valign='top'>")

	dat += text("<b>Crafting Table</b><p>")

	dat += text("	<table bgcolor='#cccccc' cellpadding='4' cellspacing='0'>")

	var/j = 0
	var/k = 0
	for (i = 0; i < 3; i++)
		dat += text("	<tr>")
		for (j = 1; j <= 3; j++)
			k = i * 3 + j
			if (current_recipe[k])
				dat += text("	<td><A href='?src=\ref[src];remove=[k]'>[current_recipe[k]]</a></td>")
			else
				dat += text("	<td><A href='?src=\ref[src];add=[k]'>----</a></td>")
		dat += text("	</tr>")
	dat += text("	</table>")

	dat += text("<br><br>")
	dat += text("<b>Will make: </b>")
	if (make)
		dat += text("<A href='?src=\ref[src];make=[1]'>[make.name]</a>")
	else
		dat += text("nothing useful")

	dat += text("</td></tr></table>")
	user << browse("[dat]", "window=craft")

/obj/machinery/autolathe2/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["remove"])
		var/n = text2num(href_list["remove"])
		if(!n || n < 1 || n > 9)
			return
		current_recipe[n] = ""
	if(href_list["select"])
		var/n = text2num(href_list["select"])
		if(!n || n < 1 || n > 9)
			return
		selected = craft_contents[n]
	if(href_list["add"])
		var/n = text2num(href_list["add"])
		if(!n || n < 1 || n > 9)
			return
		if(selected)
			current_recipe[n] = selected.id
	if(href_list["make"])
		var/datum/craftlathe_item/MAKE = check_craftlathe_recipe(src.current_recipe)
		if(MAKE)
			for (var/datum/craftlathe_item/CI2 in craft_contents)
				if(CI2.id == MAKE.id)
					CI2.amount += CI2.amount_attackby
					src.updateUsrDialog()
					return
			craft_contents += new/datum/craftlathe_item(MAKE.id,MAKE.name,MAKE.amount,MAKE.amount_attackby,MAKE.recipe,MAKE.item_type)
	var/datum/craftlathe_item/CI = check_craftlathe_recipe(src.current_recipe)
	if(CI)
		make = CI
	else
		make = null
	src.updateUsrDialog()



/obj/machinery/autolathe2/attackby(obj/item/weapon/W as obj, mob/user as mob)
	usr.machine = src
	src.add_fingerprint(usr)
	for (var/datum/craftlathe_item/CI in CRAFT_ITEMS)
		if(W.type == CI.item_type)
			for (var/datum/craftlathe_item/CI2 in craft_contents)
				if(CI2.item_type == W.type)
					CI2.amount += CI2.amount_attackby
					rmv_item(W)
					return
			craft_contents += new/datum/craftlathe_item(CI.id,CI.name,CI.amount,CI.amount_attackby,CI.recipe,CI.item_type)
			rmv_item(W)
			return
	src.updateUsrDialog()
	return

/obj/machinery/autolathe2/proc/rmv_item(obj/item/W as obj)
	if(istype(W,/obj/item/stack))
		var/obj/item/stack/S = W
		S.amount--
		if (S.amount <= 0)
			del(S)
	else
		del(W)

/obj/machinery/autolathe2/proc/build_recipes()
	//Parameters: ID, Name, Amount, Amount_added_per_attackby, Recipe, Object type
	CRAFT_ITEMS += new/datum/craftlathe_item("METAL","Metal",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/metal)
	CRAFT_ITEMS += new/datum/craftlathe_item("R METAL","Reinforced Metal",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/r_metal)
	CRAFT_ITEMS += new/datum/craftlathe_item("GLASS","Glass",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/glass)
	CRAFT_ITEMS += new/datum/craftlathe_item("R GLASS","Reinforced Glass",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/rglass)
	CRAFT_ITEMS += new/datum/craftlathe_item("GOLD","Gold",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/gold)
	CRAFT_ITEMS += new/datum/craftlathe_item("SILVER","Silver",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/silver)
	CRAFT_ITEMS += new/datum/craftlathe_item("DIAMOND","Diamond",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/diamond)
	CRAFT_ITEMS += new/datum/craftlathe_item("PLASMA","Plasma",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/plasma)
	CRAFT_ITEMS += new/datum/craftlathe_item("URANIUM","Uranium",1,1,list("","","","","","","","",""),/obj/item/weapon/ore/uranium)
	CRAFT_ITEMS += new/datum/craftlathe_item("CLOWN","Bananium",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/clown)
	CRAFT_ITEMS += new/datum/craftlathe_item("SCREWS","Screws",9,9,list("","","","","METAL","","","METAL",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("COGS","Cogs",9,9,list("","METAL","","METAL","METAL","METAL","","METAL",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("SWITCH","Switch",12,12,list("METAL","","METAL","METAL","METAL","","METAL","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("KEYBOARD","Keyboard",1,1,list("","","","SWITCH","SWITCH","SWITCH","SWITCH","SWITCH","SWITCH"))
	CRAFT_ITEMS += new/datum/craftlathe_item("M PANEL","Metal Panel",10,10,list("","","","","METAL","METAL","","METAL","METAL"))
	CRAFT_ITEMS += new/datum/craftlathe_item("CASE","Equipment Case",1,1,list("M PANEL","M PANEL","M PANEL","M PANEL","","M PANEL","M PANEL","M PANEL","M PANEL"))
	CRAFT_ITEMS += new/datum/craftlathe_item("G PANEL","Glass Panel",10,10,list("","","","","GLASS","GLASS","","GLASS","GLASS"))
	CRAFT_ITEMS += new/datum/craftlathe_item("SCREEN","Screen",1,1,list("","GLASS","","GLASS","PLASMA","GLASS","","GLASS",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("EL SILVER","Electronics Silver",30,30,list("","","","","SILVER","","","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("EL GOLD","Electronics Gold",6,6,list("","","","","GOLD","","","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("TINTED GL","Tinted Glass",2,2,list("","METAL","","","GLASS","","","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("TANK VALVE","Tank Transfer Valuve",1,1,list("","PIPE","","","PIPE","SWITCH","","PIPE",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("PIPE","Pipe",1,1,list("","M PANEL","","","M PANEL","","","M PANEL",""))

	CRAFT_ITEMS += new/datum/craftlathe_item("CB FRAME","Circuitboard Frame",1,1,list("","","","M PANEL","G PANEL","M PANEL","G PANEL","M PANEL","G PANEL"))
	CRAFT_ITEMS += new/datum/craftlathe_item("ROM","ROM Module",1,1,list("EL SILVER","EL SILVER","EL SILVER","EL SILVER","","EL SILVER","EL SILVER","EL SILVER","EL SILVER"))
	CRAFT_ITEMS += new/datum/craftlathe_item("RAM","RAM Module",1,1,list("EL SILVER","EL SILVER","EL SILVER","EL SILVER","EL GOLD","EL SILVER","EL SILVER","EL SILVER","EL SILVER"))
	CRAFT_ITEMS += new/datum/craftlathe_item("PROCESSOR","Processor",1,1,list("EL GOLD","EL SILVER","EL GOLD","EL SILVER","EL SILVER","EL SILVER","EL SILVER","EL GOLD","EL SILVER"))
	CRAFT_ITEMS += new/datum/craftlathe_item("ANTENNA","Antenna",1,1,list("","","EL SILVER","","","EL SILVER","EL SILVER","EL SILVER","EL SILVER"))
	CRAFT_ITEMS += new/datum/craftlathe_item("OP RECEPTOR","Optic Receptor",1,1,list("G PANEL","G PANEL","G PANEL","","EL GOLD","","G PANEL","G PANEL","G PANEL"))
	CRAFT_ITEMS += new/datum/craftlathe_item("THERMAL OP R","Thermal Optic Receptor",1,1,list("","OP RECEPTOR","","ROM","DIAMOND","DIAMOND","","OP RECEPTOR",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("MASON OP R","Mason Optic Receptor",1,1,list("","OP RECEPTOR","","ROM","EL SILVER","EL SILVER","","OP RECEPTOR",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("EAR FRAME","Earpiece Frame",1,1,list("M PANEL","M PANEL","M PANEL","M PANEL","","M PANEL","M PANEL","M PANEL",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("RADIO M","Radio Module",1,1,list("","ANTENNA","","","ROM","","CB FRAME","CB FRAME","CB FRAME"))
	CRAFT_ITEMS += new/datum/craftlathe_item("EARPIECE","Radio Earpiece",1,1,list("","","","","RADIO M","","","EAR FRAME",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("EARMUFFS","Earmuffs",1,1,list("","M PANEL","","EAR FRAME","","EAR FRAME","","",""))

	CRAFT_ITEMS += new/datum/craftlathe_item("GLASSES FRAME","Glasses Frame",1,1,list("M PANEL","","M PANEL","M PANEL","","M PANEL","M PANEL","M PANEL","M PANEL"))
	CRAFT_ITEMS += new/datum/craftlathe_item("MASONS","Mason Scanners",1,1,list("","","","MASON OP R","GLASSES FRAME","MASON OP R","","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("THERMALS","Thermal Scanners",1,1,list("","","","THERMAL OP R","GLASSES FRAME","THERMAL OP R","","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("SUNGLASSES","Sunglasses",1,1,list("","","","TINTED GL","GLASSES FRAME","TINTED GL","","",""))

	CRAFT_ITEMS += new/datum/craftlathe_item("HELMET FR","Helmet Frame",1,1,list("METAL","METAL","METAL","METAL","","METAL","","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("HELMET","Security Helmet",1,1,list("R METAL","R METAL","R METAL","R METAL","HELMET FR","R METAL","","GLASS",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("HOS HELMET","HoS Helmet",1,1,list("SILVER","GOLD","SILVER","SILVER","HELMET","SILVER","","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("HARDHAT","Hardhat",1,1,list("","FLASHLIGHT","","","HELMET FR","","","",""))
	CRAFT_ITEMS += new/datum/craftlathe_item("SWAT HELMET","SWAT Helmet",1,1,list("","","","","HELMET","","R GLASS","R GLASS","R GLASS"))
	CRAFT_ITEMS += new/datum/craftlathe_item("WELDING HELM","Welding Helmet",1,1,list("","","","","HELMET FR","","TINTED GL","TINTED GL","TINTED GL"))
	CRAFT_ITEMS += new/datum/craftlathe_item("SPACE HELMET","Space Helmet",1,1,list("R METAL","SILVER","R METAL","SILVER","HELMET FR","SILVER","R GLASS","R GLASS","R GLASS"))
	CRAFT_ITEMS += new/datum/craftlathe_item("RIG HELMET","RIG Helmet",1,1,list("R METAL","SILVER","R METAL","SILVER","SPACE HELMET","SILVER","R GLASS","R GLASS","R GLASS"))
	CRAFT_ITEMS += new/datum/craftlathe_item("GAS MASK","Gas Mask",1,1,list("","","","","HELMET FR","TANK VALVE","","G PANEL",""))

	CRAFT_ITEMS += new/datum/craftlathe_item("ARMOR FRAME","Armor Frame",1,1,list("R METAL","","R METAL","R METAL","R METAL","R METAL","R METAL","R METAL","R METAL"))
	CRAFT_ITEMS += new/datum/craftlathe_item("ARMOR","Armored Vest",1,1,list("R METAL","","R METAL","R METAL","ARMOR FRAME","R METAL","R METAL","R METAL","R METAL"))
	CRAFT_ITEMS += new/datum/craftlathe_item("HOS ARMOR","HoS Armor",1,1,list("DIAMOND","","DIAMOND","URANIUM","ARMOR","URANIUM","URANIUM","R METAL","URANIUM"))
	CRAFT_ITEMS += new/datum/craftlathe_item("CAP ARMOR","Captain Armor",1,1,list("DIAMOND","","DIAMOND","URANIUM","HOS ARMOR","URANIUM","URANIUM","R METAL","URANIUM"))
	CRAFT_ITEMS += new/datum/craftlathe_item("SPACE S FR","Space Suit Frame",1,1,list("SILVER","","SILVER","SILVER","SILVER","SILVER","SILVER","SILVER","SILVER"))
	CRAFT_ITEMS += new/datum/craftlathe_item("SPACE SUIT","Space Suit",1,1,list("SILVER","","SILVER","RAM","SPACE S FR","RADIO M","SILVER","SILVEr","SILVER"))
	CRAFT_ITEMS += new/datum/craftlathe_item("RIG SUIT","RIG Suit",1,1,list("SILVER","","SILVER","SILVER","SPACE SUIT","SILVER","SILVER","SILVER","SILVER"))
	//TODO: Flashlight, type paths
	return



/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	luminosity = 8

/**********************Random mine generator************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/mine_generator
	name = "Random mine generator"
	anchored = 1
	unacidable = 1
	var/turf/last_loc
	var/turf/target_loc
	var/turf/start_loc
	var/randXParam //the value of these two parameters are generated by the code itself and used to
	var/randYParam //determine the random XY parameters
	var/mineDirection = 3
	/*
		0 = none
		1 = N
		2 = NNW
		3 = NW
		4 = WNW
		5 = W
		6 = WSW
		7 = SW
		8 = SSW
		9 = S
		10 = SSE
		11 = SE
		12 = ESE
		13 = E
	 	14 = ENE
		15 = NE
		16 = NNE
	*/

/obj/mine_generator/New()
	last_loc = src.loc
	var/i
	for(i = 0; i < 50; i++)
		gererateTargetLoc()
		//target_loc = locate(last_loc.x + rand(5), last_loc.y + rand(5), src.z)
		fillWithAsteroids()
	del(src)
	return


/obj/mine_generator/proc/gererateTargetLoc()  //this proc determines where the next square-room will end.
	switch(mineDirection)
		if(1)
			randXParam = 0
			randYParam = 4
		if(2)
			randXParam = 1
			randYParam = 3
		if(3)
			randXParam = 2
			randYParam = 2
		if(4)
			randXParam = 3
			randYParam = 1
		if(5)
			randXParam = 4
			randYParam = 0
		if(6)
			randXParam = 3
			randYParam = -1
		if(7)
			randXParam = 2
			randYParam = -2
		if(8)
			randXParam = 1
			randYParam = -3
		if(9)
			randXParam = 0
			randYParam = -4
		if(10)
			randXParam = -1
			randYParam = -3
		if(11)
			randXParam = -2
			randYParam = -2
		if(12)
			randXParam = -3
			randYParam = -1
		if(13)
			randXParam = -4
			randYParam = 0
		if(14)
			randXParam = -3
			randYParam = 1
		if(15)
			randXParam = -2
			randYParam = 2
		if(16)
			randXParam = -1
			randYParam = 3
	target_loc = last_loc
	if (randXParam > 0)
		target_loc = locate(target_loc.x+rand(randXParam),target_loc.y,src.z)
	if (randYParam > 0)
		target_loc = locate(target_loc.x,target_loc.y+rand(randYParam),src.z)
	if (randXParam < 0)
		target_loc = locate(target_loc.x-rand(-randXParam),target_loc.y,src.z)
	if (randYParam < 0)
		target_loc = locate(target_loc.x,target_loc.y-rand(-randXParam),src.z)
	if (mineDirection == 1 || mineDirection == 5 || mineDirection == 9 || mineDirection == 13) //if N,S,E,W, turn quickly
		if(prob(50))
			mineDirection += 2
		else
			mineDirection -= 2
			if(mineDirection < 1)
				mineDirection += 16
	else
		if(prob(50))
			if(prob(50))
				mineDirection += 1
			else
				mineDirection -= 1
				if(mineDirection < 1)
					mineDirection += 16
	return


/obj/mine_generator/proc/fillWithAsteroids()

	if(last_loc)
		start_loc = last_loc

	if(start_loc && target_loc)
		var/x1
		var/y1

		var/turf/line_start = start_loc
		var/turf/column = line_start

		if(start_loc.x <= target_loc.x)
			if(start_loc.y <= target_loc.y)                                 //GOING NORTH-EAST
				for(y1 = start_loc.y; y1 <= target_loc.y; y1++)
					for(x1 = start_loc.x; x1 <= target_loc.x; x1++)
						new/turf/simulated/floor/airless/asteroid(column)
						column = get_step(column,EAST)
					line_start = get_step(line_start,NORTH)
					column = line_start
				last_loc = target_loc
				return
			else                                                            //GOING NORTH-WEST
				for(y1 = start_loc.y; y1 >= target_loc.y; y1--)
					for(x1 = start_loc.x; x1 <= target_loc.x; x1++)
						new/turf/simulated/floor/airless/asteroid(column)
						column = get_step(column,WEST)
					line_start = get_step(line_start,NORTH)
					column = line_start
				last_loc = target_loc
				return
		else
			if(start_loc.y <= target_loc.y)                                 //GOING SOUTH-EAST
				for(y1 = start_loc.y; y1 <= target_loc.y; y1++)
					for(x1 = start_loc.x; x1 >= target_loc.x; x1--)
						new/turf/simulated/floor/airless/asteroid(column)
						column = get_step(column,EAST)
					line_start = get_step(line_start,SOUTH)
					column = line_start
				last_loc = target_loc
				return
			else                                                            //GOING SOUTH-WEST
				for(y1 = start_loc.y; y1 >= target_loc.y; y1--)
					for(x1 = start_loc.x; x1 >= target_loc.x; x1--)
						new/turf/simulated/floor/airless/asteroid(column)
						column = get_step(column,WEST)
					line_start = get_step(line_start,SOUTH)
					column = line_start
				last_loc = target_loc
				return


	return

/**********************Miner Lockers**************************/

/obj/secure_closet/miner
	name = "Miner's Equipment"
	icon_state = "miningsec1"
	icon_closed = "miningsec"
	icon_locked = "miningsec1"
	icon_broken = "miningsecbroken"
	icon_off = "miningsecoff"
	req_access = list(access_mining)

/obj/secure_closet/miner/New()
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


/**********************Administration Shuttle**************************/

var/admin_shuttle_location = 0 // 0 = centcom 13, 1 = station

proc/move_admin_shuttle()
	var/area/fromArea
	var/area/toArea
	if (admin_shuttle_location == 1)
		fromArea = locate(/area/shuttle/administration/station)
		toArea = locate(/area/shuttle/administration/centcom)
	else
		fromArea = locate(/area/shuttle/administration/centcom)
		toArea = locate(/area/shuttle/administration/station)
	fromArea.move_contents_to(toArea)
	if (admin_shuttle_location)
		admin_shuttle_location = 0
	else
		admin_shuttle_location = 1
	return

/**********************Centcom Ferry**************************/

var/ferry_location = 0 // 0 = centcom , 1 = station

proc/move_ferry()
	var/area/fromArea
	var/area/toArea
	if (ferry_location == 1)
		fromArea = locate(/area/shuttle/transport1/station)
		toArea = locate(/area/shuttle/transport1/centcom)
	else
		fromArea = locate(/area/shuttle/transport1/centcom)
		toArea = locate(/area/shuttle/transport1/station)
	fromArea.move_contents_to(toArea)
	if (ferry_location)
		ferry_location = 0
	else
		ferry_location = 1
	return

/**********************Shuttle Computer**************************/

var/mining_shuttle_tickstomove = 10
var/mining_shuttle_moving = 0
var/mining_shuttle_location = 0 // 0 = station 13, 1 = mining station

proc/move_mining_shuttle()
	if (mining_shuttle_moving)
		return
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
	dat = text("<b>Mining shuttle: <A href='?src=\ref[src];move=[1]'>Call</A></b>")
	user << browse("[dat]", "window=miningshuttle;size=200x100")

/obj/machinery/computer/mining_shuttle/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["move"])
		if (!mining_shuttle_moving)
			usr << "\blue shuttle called and will arrive shortly"
			move_mining_shuttle()
		else
			usr << "\blue shuttle is already moving"

/obj/machinery/computer/mining_shuttle/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (istype(W, /obj/item/weapon/card/emag))
		src.req_access = list()
		hacked = 1
		usr << "The computer's controls are now all access"

/**********************Mine areas**************************/

/area/mine/explored
	name = "Mine"
	icon_state = "janitor"
	music = null

/area/mine/unexplored
	name = "Mine"
	icon_state = "captain"
	music = null

/area/mine/lobby
	name = "Mining station Hallways"
	icon_state = "mine"

/area/mine/storage
	name = "Mining station Storage"
	icon_state = "green"

/area/mine/production
	name = "Mining station Production Area"
	icon_state = "janitor"

/area/mine/living_quarters
	name = "Mining station Living Quarters"
	icon_state = "yellow"

/area/mine/eva
	name = "Mining station EVA"
	icon_state = "eva"

/area/mine/maintenance
	name = "Mining station Maintenance"
	icon_state = "maintcentral"


/**********************Mineral deposits**************************/

/turf/simulated/mineral //wall piece
	name = "Rock"
	icon = 'walls.dmi'
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
				T.overlays += image('walls.dmi', "rock_side_s")
		if((istype(get_step(src, SOUTH), /turf/simulated/floor)) || (istype(get_step(src, SOUTH), /turf/space)) || (istype(get_step(src, SOUTH), /turf/simulated/shuttle/floor)))
			T = get_step(src, SOUTH)
			if (T)
				T.overlays += image('walls.dmi', "rock_side_n", layer=6)
		if((istype(get_step(src, EAST), /turf/simulated/floor)) || (istype(get_step(src, EAST), /turf/space)) || (istype(get_step(src, EAST), /turf/simulated/shuttle/floor)))
			T = get_step(src, EAST)
			if (T)
				T.overlays += image('walls.dmi', "rock_side_w", layer=6)
		if((istype(get_step(src, WEST), /turf/simulated/floor)) || (istype(get_step(src, WEST), /turf/space)) || (istype(get_step(src, WEST), /turf/simulated/shuttle/floor)))
			T = get_step(src, WEST)
			if (T)
				T.overlays += image('walls.dmi', "rock_side_e", layer=6)

	if (mineralName && mineralAmt && spread && spreadChance)
		if(prob(spreadChance))
			if(istype(get_step(src, SOUTH), /turf/simulated/mineral/random))
				new src.type(get_step(src, SOUTH))
		if(prob(spreadChance))
			if(istype(get_step(src, NORTH), /turf/simulated/mineral/random))
				new src.type(get_step(src, NORTH))
		if(prob(spreadChance))
			if(istype(get_step(src, WEST), /turf/simulated/mineral/random))
				new src.type(get_step(src, WEST))
		if(prob(spreadChance))
			if(istype(get_step(src, EAST), /turf/simulated/mineral/random))
				new src.type(get_step(src, EAST))
	return

/turf/simulated/mineral/random
	name = "Mineral deposit"
	var/mineralAmtList = list("Uranium" = 5, "Iron" = 5, "Diamond" = 5, "Gold" = 5, "Silver" = 5, "Plasma" = 5)
	var/mineralSpawnChanceList = list("Uranium" = 5, "Iron" = 50, "Diamond" = 1, "Gold" = 5, "Silver" = 5, "Plasma" = 25)
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
			if(M)
				src = M
				M.levelupdate()
	return

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


/turf/simulated/mineral/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/airless/asteroid/W
	var/old_dir = dir

	for(var/direction in cardinal)
		for(var/obj/glowshroom/shroom in get_step(src,direction))
			if(!shroom.floor) //shrooms drop to the floor
				shroom.floor = 1
				shroom.icon_state = "glowshroomf"
				shroom.pixel_x = 0
				shroom.pixel_y = 0

	W = new /turf/simulated/floor/airless/asteroid( locate(src.x, src.y, src.z) )
	W.dir = old_dir
	W.fullUpdateMineralOverlays()

	/*
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	*/
	W.opacity = 1
	W.sd_SetOpacity(0)
	W.sd_LumReset()
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
/*
	if (istype(W, /obj/item/weapon/pickaxe/radius))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return
*/
//Watch your tabbing, microwave. --NEO

		user << "\red You start picking."
		playsound(user, 'Genhit.ogg', 20, 1)

		if(do_after(user,W:digspeed))
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
			if (src.mineralName == "Clown")
				new /obj/item/weapon/ore/clown(src)
	ReplaceWithFloor()
	return

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


/**********************Asteroid**************************/

/turf/simulated/floor/airless/asteroid //floor piece
	name = "Asteroid"
	icon = 'floors.dmi'
	icon_state = "asteroid"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
	var/seedName = "" //Name of the seed it contains
	var/seedAmt = 0   //Ammount of the seed it contains
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug

/turf/simulated/floor/airless/asteroid/New()
	..()
	//if (prob(50))
	//	seedName = pick(list("1","2","3","4"))
	//	seedAmt = rand(1,4)
	spawn(2)
		updateMineralOverlays()

/turf/simulated/floor/airless/asteroid/ex_act(severity)
	return

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
		playsound(src.loc, 'rustle1.ogg', 50, 1) //russle sounds sounded better

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
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	new/obj/item/weapon/ore/glass(src)
	return

/turf/simulated/floor/airless/asteroid/proc/updateMineralOverlays()

	src.overlays = null

	if(istype(get_step(src, NORTH), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_n")
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_s", layer=6)
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_e", layer=6)
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_w", layer=6)


/turf/simulated/floor/airless/asteroid/proc/fullUpdateMineralOverlays()
	var/turf/simulated/floor/airless/asteroid/A
	if(istype(get_step(src, WEST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, WEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, EAST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, EAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTH), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, NORTH)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHWEST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, NORTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHEAST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, NORTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHWEST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, SOUTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHEAST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, SOUTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTH), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, SOUTH)
		A.updateMineralOverlays()
	src.updateMineralOverlays()

/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "Rock"
	icon = 'Mining.dmi'
	icon_state = "ore"

/obj/item/weapon/ore/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/satchel))
		var/obj/item/weapon/satchel/S = W
		if (S.mode == 1)
			for (var/obj/item/weapon/ore/O in locate(src.x,src.y,src.z))
				if (S.contents.len < S.capacity)
					S.contents += O;
				else
					user << "\blue The satchel is full."
					break
			user << "\blue You pick up all the ores."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
			else
				user << "\blue The satchel is full."
	return

/obj/item/weapon/ore/uranium
	name = "Uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"

/obj/item/weapon/ore/iron
	name = "Iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"

/obj/item/weapon/ore/glass
	name = "Sand"
	icon_state = "Glass ore"
	origin_tech = "materials=1"

/obj/item/weapon/ore/plasma
	name = "Plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "materials=2"

/obj/item/weapon/ore/silver
	name = "Silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"

/obj/item/weapon/ore/gold
	name = "Gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"

/obj/item/weapon/ore/diamond
	name = "Diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"

/obj/item/weapon/ore/clown
	name = "Bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"

/obj/item/weapon/ore/slag
	name = "Slag"
	desc = "Completely useless"
	icon_state = "slag"

/obj/item/weapon/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/**********************Ore pile (not used)**************************/

/obj/item/weapon/ore_pile
	name = "Pile of ores"
	icon = 'Mining.dmi'
	icon_state = "orepile"

/**********************Satchel**************************/

/obj/item/weapon/satchel
	icon = 'mining.dmi'
	icon_state = "satchel"
	name = "Mining Satchel"
	var/mode = 0;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 50; //the number of ore pieces it can carry.

/obj/item/weapon/satchel/attack_self(mob/user as mob)
	for (var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = user.loc
	user << "\blue You empty the satchel."
	return

/obj/item/weapon/satchel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/ore))
		var/obj/item/weapon/ore/O = W
		src.contents += O;
	return

/obj/item/weapon/satchel/verb/toggle_mode()
	set name = "Switch Satchel Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The satchel now picks up all ore in a tile at once."
		if(0)
			usr << "The satchel now picks up one ore at a time."


/**********************Ore box**************************/

/obj/ore_box
	icon = 'mining.dmi'
	icon_state = "orebox"
	name = "Ore Box"
	desc = "It's heavy"
	density = 1

/obj/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		src.contents += W;
	if (istype(W, /obj/item/weapon/satchel))
		src.contents += W.contents
		user << "\blue You empty the satchel into the box."
	return

/obj/ore_box/attack_hand(obj, mob/user as mob)
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_glass = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0

	for (var/obj/item/weapon/ore/C in contents)
		if (istype(C,/obj/item/weapon/ore/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/weapon/ore/glass))
			amt_glass++;
		if (istype(C,/obj/item/weapon/ore/plasma))
			amt_plasma++;
		if (istype(C,/obj/item/weapon/ore/iron))
			amt_iron++;
		if (istype(C,/obj/item/weapon/ore/silver))
			amt_silver++;
		if (istype(C,/obj/item/weapon/ore/gold))
			amt_gold++;
		if (istype(C,/obj/item/weapon/ore/uranium))
			amt_uranium++;
		if (istype(C,/obj/item/weapon/ore/clown))
			amt_clown++;

	var/dat = text("<b>The contents of the ore box reveal...</b><br>")
	if (amt_gold)
		dat += text("Gold ore: [amt_gold]<br>")
	if (amt_silver)
		dat += text("Silver ore: [amt_silver]<br>")
	if (amt_iron)
		dat += text("Metal ore: [amt_iron]<br>")
	if (amt_glass)
		dat += text("Sand: [amt_glass]<br>")
	if (amt_diamond)
		dat += text("Diamond ore: [amt_diamond]<br>")
	if (amt_plasma)
		dat += text("Plasma ore: [amt_plasma]<br>")
	if (amt_uranium)
		dat += text("Uranium ore: [amt_uranium]<br>")
	if (amt_clown)
		dat += text("Bananium ore: [amt_clown]<br>")

	dat += text("<br><br><A href='?src=\ref[src];removeall=1'>Empty box</A>")
	user << browse("[dat]", "window=orebox")
	return

/obj/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		for (var/obj/item/weapon/ore/O in contents)
			contents -= O
			O.loc = src.loc
		usr << "\blue You empty the box"
	src.updateUsrDialog()
	return


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
	icon = 'screen1.dmi'
	icon_state = "x2"
	name = "Input area"
	density = 0
	anchored = 1.0
	New()
		icon_state = "blank"

/obj/machinery/mineral/output
	icon = 'screen1.dmi'
	icon_state = "x"
	name = "Output area"
	density = 0
	anchored = 1.0
	New()
		icon_state = "blank"


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
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		return
	return


/**********************Ore to material recipes datum**************************/

var/list/AVAILABLE_ORES = typesof(/obj/item/weapon/ore)

/datum/material_recipe
	var/name
	var/list/obj/item/weapon/ore/recipe
	var/obj/prod_type  //produced material/object type

	New(var/param_name, var/param_recipe, var/param_prod_type)
		name = param_name
		recipe = param_recipe
		prod_type = param_prod_type

var/list/datum/material_recipe/MATERIAL_RECIPES = list(
		new/datum/material_recipe("Metal",list(/obj/item/weapon/ore/iron),/obj/item/stack/sheet/metal),
		new/datum/material_recipe("Glass",list(/obj/item/weapon/ore/glass),/obj/item/stack/sheet/glass),
		new/datum/material_recipe("Gold",list(/obj/item/weapon/ore/gold),/obj/item/stack/sheet/gold),
		new/datum/material_recipe("Silver",list(/obj/item/weapon/ore/silver),/obj/item/stack/sheet/silver),
		new/datum/material_recipe("Diamond",list(/obj/item/weapon/ore/diamond),/obj/item/stack/sheet/diamond),
		new/datum/material_recipe("Plasma",list(/obj/item/weapon/ore/plasma),/obj/item/stack/sheet/plasma),
		new/datum/material_recipe("Bananium",list(/obj/item/weapon/ore/clown),/obj/item/stack/sheet/clown)
	)

/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "Produciton machine console"
	icon = 'terminals.dmi'
	icon_state = "production_console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/processing_unit/machine = null

/obj/machinery/mineral/processing_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, EAST))
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/processing_unit_console/attack_hand(user as mob)

	var/dat = "<b>Smelter control console</b><br><br>"
	//iron
	if(machine.ore_iron || machine.ore_glass || machine.ore_plasma || machine.ore_uranium || machine.ore_gold || machine.ore_silver || machine.ore_diamond || machine.ore_clown)
		if(machine.ore_iron)
			if (machine.selected_iron==1)
				dat += text("<A href='?src=\ref[src];sel_iron=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_iron=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Iron: [machine.ore_iron]<br>")
		else
			machine.selected_iron = 0

		//sand - glass
		if(machine.ore_glass)
			if (machine.selected_glass==1)
				dat += text("<A href='?src=\ref[src];sel_glass=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_glass=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Sand: [machine.ore_glass]<br>")
		else
			machine.selected_glass = 0

		//plasma
		if(machine.ore_plasma)
			if (machine.selected_plasma==1)
				dat += text("<A href='?src=\ref[src];sel_plasma=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_plasma=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Plasma: [machine.ore_plasma]<br>")
		else
			machine.selected_plasma = 0

		//uranium
		if(machine.ore_uranium)
			if (machine.selected_uranium==1)
				dat += text("<A href='?src=\ref[src];sel_uranium=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_uranium=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Uranium: [machine.ore_uranium]<br>")
		else
			machine.selected_uranium = 0

		//gold
		if(machine.ore_gold)
			if (machine.selected_gold==1)
				dat += text("<A href='?src=\ref[src];sel_gold=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_gold=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Gold: [machine.ore_gold]<br>")
		else
			machine.selected_gold = 0

		//silver
		if(machine.ore_silver)
			if (machine.selected_silver==1)
				dat += text("<A href='?src=\ref[src];sel_silver=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_silver=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Silver: [machine.ore_silver]<br>")
		else
			machine.selected_silver = 0

		//diamond
		if(machine.ore_diamond)
			if (machine.selected_diamond==1)
				dat += text("<A href='?src=\ref[src];sel_diamond=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_diamond=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Diamond: [machine.ore_diamond]<br>")
		else
			machine.selected_diamond = 0

		//bananium
		if(machine.ore_clown)
			if (machine.selected_clown==1)
				dat += text("<A href='?src=\ref[src];sel_clown=no'><font color='green'>Smelting</font></A> ")
			else
				dat += text("<A href='?src=\ref[src];sel_clown=yes'><font color='red'>Not smelting</font></A> ")
			dat += text("Bananium: [machine.ore_clown]<br>")
		else
			machine.selected_clown = 0

		//On or off
		dat += text("Machine is currently ")
		if (machine.on==1)
			dat += text("<A href='?src=\ref[src];set_on=off'>On</A> ")
		else
			dat += text("<A href='?src=\ref[src];set_on=on'>Off</A> ")
	else
		dat+="---No Materials Loaded---"


	user << browse("[dat]", "window=console_processing_unit")



/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["sel_iron"])
		if (href_list["sel_iron"] == "yes")
			machine.selected_iron = 1
		else
			machine.selected_iron = 0
	if(href_list["sel_glass"])
		if (href_list["sel_glass"] == "yes")
			machine.selected_glass = 1
		else
			machine.selected_glass = 0
	if(href_list["sel_plasma"])
		if (href_list["sel_plasma"] == "yes")
			machine.selected_plasma = 1
		else
			machine.selected_plasma = 0
	if(href_list["sel_uranium"])
		if (href_list["sel_uranium"] == "yes")
			machine.selected_uranium = 1
		else
			machine.selected_uranium = 0
	if(href_list["sel_gold"])
		if (href_list["sel_gold"] == "yes")
			machine.selected_gold = 1
		else
			machine.selected_gold = 0
	if(href_list["sel_silver"])
		if (href_list["sel_silver"] == "yes")
			machine.selected_silver = 1
		else
			machine.selected_silver = 0
	if(href_list["sel_diamond"])
		if (href_list["sel_diamond"] == "yes")
			machine.selected_diamond = 1
		else
			machine.selected_diamond = 0
	if(href_list["sel_clown"])
		if (href_list["sel_clown"] == "yes")
			machine.selected_clown = 1
		else
			machine.selected_clown = 0
	if(href_list["set_on"])
		if (href_list["set_on"] == "on")
			machine.on = 1
		else
			machine.on = 0
	src.updateUsrDialog()
	return

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "Furnace"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/mineral/CONSOLE = null
	var/ore_gold = 0;
	var/ore_silver = 0;
	var/ore_diamond = 0;
	var/ore_glass = 0;
	var/ore_plasma = 0;
	var/ore_uranium = 0;
	var/ore_iron = 0;
	var/ore_clown = 0;
	var/selected_gold = 0
	var/selected_silver = 0
	var/selected_diamond = 0
	var/selected_glass = 0
	var/selected_plasma = 0
	var/selected_uranium = 0
	var/selected_iron = 0
	var/selected_clown = 0
	var/on = 0 //0 = off, 1 =... oh you know!

/obj/machinery/mineral/processing_unit/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		processing_items.Add(src)
		return
	return

/obj/machinery/mineral/processing_unit/process()
	if (src.output && src.input)
		var/i
		for (i = 0; i < 10; i++)
			if (on)
				if (selected_glass == 1 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_glass > 0)
						ore_glass--;
						new /obj/item/stack/sheet/glass(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 1 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_gold > 0)
						ore_gold--;
						new /obj/item/stack/sheet/gold(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 1 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_silver > 0)
						ore_silver--;
						new /obj/item/stack/sheet/silver(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 1 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_diamond > 0)
						ore_diamond--;
						new /obj/item/stack/sheet/diamond(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 1 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_plasma > 0)
						ore_plasma--;
						new /obj/item/stack/sheet/plasma(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 1 && selected_iron == 0 && selected_clown == 0)
					if (ore_uranium > 0)
						ore_uranium--;
						new /obj/item/stack/sheet/uranium(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0)
					if (ore_iron > 0)
						ore_iron--;
						new /obj/item/stack/sheet/metal(output.loc)
					else
						on = 0
					continue
				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0)
					if (ore_iron > 0)
						ore_iron--;
						new /obj/item/stack/sheet/metal(output.loc)
					else
						on = 0
					continue

				if (selected_glass == 0 && selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 1)
					if (ore_clown > 0)
						ore_clown--;
						new /obj/item/stack/sheet/clown(output.loc)
					else
						on = 0
					continue


				//if a non valid combination is selected

				var/b = 1 //this part checks if all required ores are available

				if (!(selected_gold || selected_silver ||selected_diamond || selected_uranium | selected_plasma || selected_iron))
					b = 0

				if (selected_gold == 1)
					if (ore_gold <= 0)
						b = 0
				if (selected_silver == 1)
					if (ore_silver <= 0)
						b = 0
				if (selected_diamond == 1)
					if (ore_diamond <= 0)
						b = 0
				if (selected_uranium == 1)
					if (ore_uranium <= 0)
						b = 0
				if (selected_plasma == 1)
					if (ore_plasma <= 0)
						b = 0
				if (selected_iron == 1)
					if (ore_iron <= 0)
						b = 0
				if (selected_glass == 1)
					if (ore_glass <= 0)
						b = 0
				if (selected_clown == 1)
					if (ore_clown <= 0)
						b = 0

				if (b) //if they are, deduct one from each, produce slag and shut the machine off
					if (selected_gold == 1)
						ore_gold--
					if (selected_silver == 1)
						ore_silver--
					if (selected_diamond == 1)
						ore_diamond--
					if (selected_uranium == 1)
						ore_uranium--
					if (selected_plasma == 1)
						ore_plasma--
					if (selected_iron == 1)
						ore_iron--
					if (selected_clown == 1)
						ore_clown--
					new /obj/item/weapon/ore/slag(output.loc)
					on = 0
				else
					on = 0
					break
				break
			else
				break
		for (i = 0; i < 10; i++)
			var/obj/item/O
			O = locate(/obj/item, input.loc)
			if (O)
				if (istype(O,/obj/item/weapon/ore/iron))
					ore_iron++;
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/glass))
					ore_glass++;
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/diamond))
					ore_diamond++;
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/plasma))
					ore_plasma++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/gold))
					ore_gold++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/silver))
					ore_silver++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/uranium))
					ore_uranium++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/clown))
					ore_clown++
					del(O)
					continue
				O.loc = src.output.loc
			else
				break
	return



/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "Stacking machine console"
	icon = 'terminals.dmi'
	icon_state = "production_console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/stacking_machine/machine = null

/obj/machinery/mineral/stacking_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, SOUTHEAST))
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/stacking_unit_console/attack_hand(user as mob)

	var/dat

	dat += text("<b>Stacking unit console</b><br><br>")

	if(machine.ore_iron)
		dat += text("Iron: [machine.ore_iron] <A href='?src=\ref[src];release=iron'>Release</A><br>")
	if(machine.ore_steel)
		dat += text("Steel: [machine.ore_steel] <A href='?src=\ref[src];release=steel'>Release</A><br>")
	if(machine.ore_glass)
		dat += text("Glass: [machine.ore_glass] <A href='?src=\ref[src];release=glass'>Release</A><br>")
	if(machine.ore_rglass)
		dat += text("Reinforced Glass: [machine.ore_rglass] <A href='?src=\ref[src];release=rglass'>Release</A><br>")
	if(machine.ore_plasma)
		dat += text("Plasma: [machine.ore_plasma] <A href='?src=\ref[src];release=plasma'>Release</A><br>")
	if(machine.ore_gold)
		dat += text("Gold: [machine.ore_gold] <A href='?src=\ref[src];release=gold'>Release</A><br>")
	if(machine.ore_silver)
		dat += text("Silver: [machine.ore_silver] <A href='?src=\ref[src];release=silver'>Release</A><br>")
	if(machine.ore_uranium)
		dat += text("Uranium: [machine.ore_uranium] <A href='?src=\ref[src];release=uranium'>Release</A><br>")
	if(machine.ore_diamond)
		dat += text("Diamond: [machine.ore_diamond] <A href='?src=\ref[src];release=diamond'>Release</A><br>")
	if(machine.ore_clown)
		dat += text("Bananium: [machine.ore_clown] <A href='?src=\ref[src];release=clown'>Release</A><br><br>")

	dat += text("Stacking: [machine.stack_amt]<br><br>")

	user << browse("[dat]", "window=console_stacking_machine")

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["release"])
		switch(href_list["release"])
			if ("plasma")
				if (machine.ore_plasma > 0)
					var/obj/item/stack/sheet/plasma/G = new /obj/item/stack/sheet/plasma
					G.amount = machine.ore_plasma
					G.loc = machine.output.loc
					machine.ore_plasma = 0
			if ("uranium")
				if (machine.ore_uranium > 0)
					var/obj/item/stack/sheet/uranium/G = new /obj/item/stack/sheet/uranium
					G.amount = machine.ore_uranium
					G.loc = machine.output.loc
					machine.ore_uranium = 0
			if ("glass")
				if (machine.ore_glass > 0)
					var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass
					G.amount = machine.ore_glass
					G.loc = machine.output.loc
					machine.ore_glass = 0
			if ("rglass")
				if (machine.ore_rglass > 0)
					var/obj/item/stack/sheet/rglass/G = new /obj/item/stack/sheet/rglass
					G.amount = machine.ore_rglass
					G.loc = machine.output.loc
					machine.ore_rglass = 0
			if ("gold")
				if (machine.ore_gold > 0)
					var/obj/item/stack/sheet/gold/G = new /obj/item/stack/sheet/gold
					G.amount = machine.ore_gold
					G.loc = machine.output.loc
					machine.ore_gold = 0
			if ("silver")
				if (machine.ore_silver > 0)
					var/obj/item/stack/sheet/silver/G = new /obj/item/stack/sheet/silver
					G.amount = machine.ore_silver
					G.loc = machine.output.loc
					machine.ore_silver = 0
			if ("diamond")
				if (machine.ore_diamond > 0)
					var/obj/item/stack/sheet/diamond/G = new /obj/item/stack/sheet/diamond
					G.amount = machine.ore_diamond
					G.loc = machine.output.loc
					machine.ore_diamond = 0
			if ("iron")
				if (machine.ore_iron > 0)
					var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal
					G.amount = machine.ore_iron
					G.loc = machine.output.loc
					machine.ore_iron = 0
			if ("steel")
				if (machine.ore_steel > 0)
					var/obj/item/stack/sheet/r_metal/G = new /obj/item/stack/sheet/r_metal
					G.amount = machine.ore_steel
					G.loc = machine.output.loc
					machine.ore_steel = 0
			if ("clown")
				if (machine.ore_clown > 0)
					var/obj/item/stack/sheet/clown/G = new /obj/item/stack/sheet/clown
					G.amount = machine.ore_clown
					G.loc = machine.output.loc
					machine.ore_clown = 0
	src.updateUsrDialog()
	return


/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "Stacking machine"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/stacking_unit_console/CONSOLE
	var/stk_types = list()
	var/stk_amt   = list()
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/ore_gold = 0;
	var/ore_silver = 0;
	var/ore_diamond = 0;
	var/ore_plasma = 0;
	var/ore_iron = 0;
	var/ore_uranium = 0;
	var/ore_clown = 0;
	var/ore_glass = 0;
	var/ore_rglass = 0;
	var/ore_steel = 0;
	var/stack_amt = 50; //ammount to stack before releassing

/obj/machinery/mineral/stacking_machine/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		processing_items.Add(src)
		return
	return

/obj/machinery/mineral/stacking_machine/process()
	if (src.output && src.input)
		var/obj/item/O
		while (locate(/obj/item, input.loc))
			O = locate(/obj/item, input.loc)
			if (istype(O,/obj/item/stack/sheet/metal))
				ore_iron+= O:amount;
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/diamond))
				ore_diamond+= O:amount;
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/plasma))
				ore_plasma+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/gold))
				ore_gold+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/silver))
				ore_silver+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/clown))
				ore_clown+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/uranium))
				ore_uranium+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/glass))
				ore_glass+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/rglass))
				ore_rglass+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/r_metal))
				ore_steel+= O:amount
				del(O)
				continue
			if (istype(O,/obj/item/weapon/ore/slag))
				del(O)
				continue
			O.loc = src.output.loc
	if (ore_gold >= stack_amt)
		var/obj/item/stack/sheet/gold/G = new /obj/item/stack/sheet/gold
		G.amount = stack_amt
		G.loc = output.loc
		ore_gold -= stack_amt
		return
	if (ore_silver >= stack_amt)
		var/obj/item/stack/sheet/silver/G = new /obj/item/stack/sheet/silver
		G.amount = stack_amt
		G.loc = output.loc
		ore_silver -= stack_amt
		return
	if (ore_diamond >= stack_amt)
		var/obj/item/stack/sheet/diamond/G = new /obj/item/stack/sheet/diamond
		G.amount = stack_amt
		G.loc = output.loc
		ore_diamond -= stack_amt
		return
	if (ore_plasma >= stack_amt)
		var/obj/item/stack/sheet/plasma/G = new /obj/item/stack/sheet/plasma
		G.amount = stack_amt
		G.loc = output.loc
		ore_plasma -= stack_amt
		return
	if (ore_iron >= stack_amt)
		var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal
		G.amount = stack_amt
		G.loc = output.loc
		ore_iron -= stack_amt
		return
	if (ore_clown >= stack_amt)
		var/obj/item/stack/sheet/clown/G = new /obj/item/stack/sheet/clown
		G.amount = stack_amt
		G.loc = output.loc
		ore_clown -= stack_amt
		return
	if (ore_uranium >= stack_amt)
		var/obj/item/stack/sheet/uranium/G = new /obj/item/stack/sheet/uranium
		G.amount = stack_amt
		G.loc = output.loc
		ore_uranium -= stack_amt
		return
	if (ore_glass >= stack_amt)
		var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass
		G.amount = stack_amt
		G.loc = output.loc
		ore_glass -= stack_amt
		return
	if (ore_rglass >= stack_amt)
		var/obj/item/stack/sheet/rglass/G = new /obj/item/stack/sheet/rglass
		G.amount = stack_amt
		G.loc = output.loc
		ore_rglass -= stack_amt
		return
	if (ore_steel >= stack_amt)
		var/obj/item/stack/sheet/r_metal/G = new /obj/item/stack/sheet/r_metal
		G.amount = stack_amt
		G.loc = output.loc
		ore_steel -= stack_amt
		return
	return


/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "Unloading machine"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null


/obj/machinery/mineral/unloading_machine/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		processing_items.Add(src)
		return
	return

/obj/machinery/mineral/unloading_machine/process()
	if (src.output && src.input)
		if (locate(/obj/ore_box, input.loc))
			var/obj/ore_box/BOX = locate(/obj/ore_box, input.loc)
			var/i = 0
			for (var/obj/item/weapon/ore/O in BOX.contents)
				BOX.contents -= O
				O.loc = output.loc
				i++
				if (i>=10)
					return
		if (locate(/obj/item, input.loc))
			var/obj/item/O
			var/i
			for (i = 0; i<10; i++)
				O = locate(/obj/item, input.loc)
				if (O)
					O.loc = src.output.loc
				else
					return
	return


/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'stationobjs.dmi'
	icon_state = "coinpress0"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/amt_silver = 0 //amount of silver
	var/amt_gold = 0   //amount of gold
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0
	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = 0
	var/chosen = "metal" //which material will be used to make coins
	var/coinsToProduce = 10


/obj/machinery/mineral/mint/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		processing_items.Add(src)
		return
	return


/obj/machinery/mineral/mint/process()
	if ( src.input)
		var/obj/item/stack/sheet/O
		O = locate(/obj/item/stack/sheet, input.loc)
		if(O)
			if (istype(O,/obj/item/stack/sheet/gold))
				amt_gold += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/silver))
				amt_silver += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/diamond))
				amt_diamond += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/plasma))
				amt_plasma += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/uranium))
				amt_uranium += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/metal))
				amt_iron += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/clown))
				amt_clown += 100 * O.amount
				del(O)


/obj/machinery/mineral/mint/attack_hand(user as mob)

	var/dat = "<b>Coin Press</b><br>"

	if (!input)
		dat += text("input connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")
	if (!output)
		dat += text("<br>output connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")

	dat += text("<br><font color='#ffcc00'><b>Gold inserted: </b>[amt_gold]</font> ")
	if (chosen == "gold")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=gold'>Choose</A>")
	dat += text("<br><font color='#888888'><b>Silver inserted: </b>[amt_silver]</font> ")
	if (chosen == "silver")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=silver'>Choose</A>")
	dat += text("<br><font color='#555555'><b>Iron inserted: </b>[amt_iron]</font> ")
	if (chosen == "metal")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=metal'>Choose</A>")
	dat += text("<br><font color='#8888FF'><b>Diamond inserted: </b>[amt_diamond]</font> ")
	if (chosen == "diamond")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=diamond'>Choose</A>")
	dat += text("<br><font color='#FF8800'><b>Plasma inserted: </b>[amt_plasma]</font> ")
	if (chosen == "plasma")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=plasma'>Choose</A>")
	dat += text("<br><font color='#008800'><b>uranium inserted: </b>[amt_uranium]</font> ")
	if (chosen == "uranium")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=uranium'>Choose</A>")
	if(amt_clown > 0)
		dat += text("<br><font color='#AAAA00'><b>Bananium inserted: </b>[amt_clown]</font> ")
		if (chosen == "clown")
			dat += text("chosen")
		else
			dat += text("<A href='?src=\ref[src];choose=clown'>Choose</A>")

	dat += text("<br><br>Will produce [coinsToProduce] [chosen] coins if enough materials are available.<br>")
	//dat += text("The dial which controls the number of conins to produce seems to be stuck. A technician has already been dispatched to fix this.")
	dat += text("<A href='?src=\ref[src];chooseAmt=-10'>-10</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=-5'>-5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=-1'>-1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=1'>+1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=5'>+5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=10'>+10</A> ")

	dat += text("<br><br>In total this machine produced <font color='green'><b>[newCoins]</b></font> coins.")
	dat += text("<br><A href='?src=\ref[src];makeCoins=[1]'>Make coins</A>")
	user << browse("[dat]", "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(processing==1)
		usr << "\blue The machine is processing."
		return
	if(href_list["choose"])
		chosen = href_list["choose"]
	if(href_list["chooseAmt"])
		coinsToProduce = between(0, coinsToProduce + text2num(href_list["chooseAmt"]), 1000)
	if(href_list["makeCoins"])
		var/temp_coins = coinsToProduce
		if (src.output)
			processing = 1;
			icon_state = "coinpress1"
			var/obj/item/weapon/moneybag/M
			switch(chosen)
				if("metal")
					while(amt_iron > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new/obj/item/weapon/coin/iron(M)
						amt_iron -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("gold")
					while(amt_gold > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/gold(M)
						amt_gold -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("silver")
					while(amt_silver > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/silver(M)
						amt_silver -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("diamond")
					while(amt_diamond > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/diamond(M)
						amt_diamond -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("plasma")
					while(amt_plasma > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/plasma(M)
						amt_plasma -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("uranium")
					while(amt_uranium > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/uranium(M)
						amt_uranium -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)
				if("clown")
					while(amt_clown > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/clown(M)
						amt_clown -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
			icon_state = "coinpress0"
			processing = 0;
			coinsToProduce = temp_coins
	src.updateUsrDialog()
	return


/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 0.0
	throwforce = 0.0
	w_class = 1.0

/obj/item/weapon/coin/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/weapon/coin/gold
	name = "Gold coin"
	icon_state = "coin_gold"

/obj/item/weapon/coin/silver
	name = "Silver coin"
	icon_state = "coin_silver"

/obj/item/weapon/coin/diamond
	name = "Diamond coin"
	icon_state = "coin_diamond"

/obj/item/weapon/coin/iron
	name = "Iron coin"
	icon_state = "coin_iron"

/obj/item/weapon/coin/plasma
	name = "Solid plasma coin"
	icon_state = "coin_plasma"

/obj/item/weapon/coin/uranium
	name = "Uranium coin"
	icon_state = "coin_uranium"

/obj/item/weapon/coin/clown
	name = "Bananaium coin"
	icon_state = "coin_clown"

/*****************************Money bag********************************/

/obj/item/weapon/moneybag
	icon = 'storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 2.0
	w_class = 4.0

/obj/item/weapon/moneybag/attack_hand(user as mob)
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0

	for (var/obj/item/weapon/coin/C in contents)
		if (istype(C,/obj/item/weapon/coin/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/weapon/coin/plasma))
			amt_plasma++;
		if (istype(C,/obj/item/weapon/coin/iron))
			amt_iron++;
		if (istype(C,/obj/item/weapon/coin/silver))
			amt_silver++;
		if (istype(C,/obj/item/weapon/coin/gold))
			amt_gold++;
		if (istype(C,/obj/item/weapon/coin/uranium))
			amt_uranium++;
		if (istype(C,/obj/item/weapon/coin/clown))
			amt_clown++;

	var/dat = text("<b>The contents of the moneybag reveal...</b><br>")
	if (amt_gold)
		dat += text("Gold coins: [amt_gold] <A href='?src=\ref[src];remove=gold'>Remove one</A><br>")
	if (amt_silver)
		dat += text("Silver coins: [amt_silver] <A href='?src=\ref[src];remove=silver'>Remove one</A><br>")
	if (amt_iron)
		dat += text("Metal coins: [amt_iron] <A href='?src=\ref[src];remove=iron'>Remove one</A><br>")
	if (amt_diamond)
		dat += text("Diamond coins: [amt_diamond] <A href='?src=\ref[src];remove=diamond'>Remove one</A><br>")
	if (amt_plasma)
		dat += text("Plasma coins: [amt_plasma] <A href='?src=\ref[src];remove=plasma'>Remove one</A><br>")
	if (amt_uranium)
		dat += text("Uranium coins: [amt_uranium] <A href='?src=\ref[src];remove=uranium'>Remove one</A><br>")
	if (amt_clown)
		dat += text("Bananium coins: [amt_clown] <A href='?src=\ref[src];remove=clown'>Remove one</A><br>")
	user << browse("[dat]", "window=moneybag")

/obj/item/weapon/moneybag/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/coin))
		var/obj/item/weapon/coin/C = W
		user << "\blue You add the [C.name] into the bag."
		usr.drop_item()
		contents += C
	if (istype(W, /obj/item/weapon/moneybag))
		var/obj/item/weapon/moneybag/C = W
		for (var/obj/O in C.contents)
			contents += O;
		user << "\blue You empty the [C.name] into the bag."
	return

/obj/item/weapon/moneybag/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["remove"])
		var/obj/item/weapon/coin/COIN
		switch(href_list["remove"])
			if("gold")
				COIN = locate(/obj/item/weapon/coin/gold,src.contents)
			if("silver")
				COIN = locate(/obj/item/weapon/coin/silver,src.contents)
			if("iron")
				COIN = locate(/obj/item/weapon/coin/iron,src.contents)
			if("diamond")
				COIN = locate(/obj/item/weapon/coin/diamond,src.contents)
			if("plasma")
				COIN = locate(/obj/item/weapon/coin/plasma,src.contents)
			if("uranium")
				COIN = locate(/obj/item/weapon/coin/uranium,src.contents)
			if("clown")
				COIN = locate(/obj/item/weapon/coin/clown,src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return



/obj/item/weapon/moneybag/vault

/obj/item/weapon/moneybag/vault/New()
	..()
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/gold(src)
	new /obj/item/weapon/coin/gold(src)


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
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
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
				while(locate(/obj/item/weapon/ore/plasma, input.loc) && locate(/obj/machinery/portable_atmospherics/canister,output.loc))
					O = locate(/obj/item/weapon/ore/plasma, input.loc)
					if (istype(O,/obj/item/weapon/ore/plasma))
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
	force = 15.0
	throwforce = 4.0
	item_state = "pickaxe"
	w_class = 4.0
	m_amt = 3000 //making them on par with the require materials to make silver, gold, and diamond picks
	var/digspeed = 40 //moving the delay to an item var so R&D can make improved picks. --NEO

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

	jackhammer
		name = "Sonic Jackhammer"
		icon_state = "jackhammer"
		item_state = "jackhammer"
		digspeed = 30
		origin_tech = "materials=3; powerstorage=2"
		desc = "Cracks rocks with sonic blasts, perfect for killing cave lizards."

	drill
		name = "Mining Drill"
		icon_state = "handdrill"
		item_state = "jackhammer"
		digspeed = 30
		origin_tech = "materials=3; powerstorage=2"
		desc = "Yours is the drill that will pierce through the rock walls."

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
		force = 10.0 //Also, weaker
		digspeed = 20
		origin_tech = "materials=4; plasmatech=2"
		desc = "A rock cutter that uses bursts of hot plasma. You could use it to cut limbs off of xenos! Or, you know, mine stuff."

	diamond
		name = "Diamond Pickaxe"
		icon_state = "dpickaxe"
		item_state = "dpickaxe"
		digspeed = 10
		origin_tech = "materials=6"
		desc = "A pickaxe with a diamond pick head, this is just like minecraft."

	diamonddrill //When people ask about the badass leader of the mining tools, they are talking about ME!
		name = "Diamond Mining Drill"
		icon_state = "diamonddrill"
		item_state = "jackhammer"
		digspeed = 0
		origin_tech = "materials=6; powerstorage=4"
		desc = "Yours is the drill that will pierce the heavens!"

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


/******************************Materials****************************/

/obj/item/stack/sheet/gold
	name = "gold"
	icon_state = "sheet-gold"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000

/obj/item/stack/sheet/gold/New(loc,amount)
	..()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
/*	recipes = gold_recipes          //Commenting out until there's a proper sprite. The golden plaque is supposed to be a special item dedicated to a really good player. -Agouri

	var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("Plaque", /obj/item/weapon/plaque_assembly, 2), \
	)*/


/obj/item/stack/sheet/silver
	name = "silver"
	icon_state = "sheet-silver"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=3"
	perunit = 2000

/obj/item/stack/sheet/silver/New(loc,amount)
	..()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_range = 3
	origin_tech = "materials=6"
	perunit = 1000

/obj/item/stack/sheet/diamond/New(loc,amount)
	..()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/uranium
	name = "Uranium block"
	icon_state = "sheet-uranium"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 2000

/obj/item/stack/sheet/enruranium
	name = "Enriched Uranium block"
	icon_state = "sheet-enruranium"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 1000

/obj/item/stack/sheet/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "plasmatech=2;materials=2"
	perunit = 2000

/obj/item/stack/sheet/clown
	name = "bananium"
	icon_state = "sheet-clown"
	force = 5.0
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000

/obj/item/stack/sheet/clown/New(loc,amount)
	..()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4


/**********************Rail track**************************/

/obj/machinery/rail_track
	name = "Rail track"
	icon = 'Mining.dmi'
	icon_state = "rail"
	dir = 2
	var/id = null    //this is needed for switches to work Set to the same on the whole length of the track
	anchored = 1

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
	var/speed = 0
	var/slowing = 0
	var/atom/movable/load = null //what it's carrying

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

/obj/machinery/rail_car/MouseDrop_T(var/atom/movable/C, mob/user)

	if(user.stat)
		return

	if (!istype(C) || C.anchored || get_dist(user, src) > 1 || get_dist(src,C) > 1 )
		return

	if(ismob(C))
		load(C)


/obj/machinery/rail_car/proc/load(var/atom/movable/C)

	if(get_dist(C, src) > 1)
		return
	//mode = 1

	C.loc = src.loc
	sleep(2)
	C.loc = src
	load = C

	C.pixel_y += 9
	if(C.layer < layer)
		C.layer = layer + 0.1
	overlays += C

	if(ismob(C))
		var/mob/M = C
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

	//mode = 0
	//send_status()

/obj/machinery/rail_car/proc/unload(var/dirn = 0)
	if(!load)
		return

	overlays = null

	load.loc = src.loc
	load.pixel_y -= 9
	load.layer = initial(load.layer)
	if(ismob(load))
		var/mob/M = load
		if(M.client)
			M.client.perspective = MOB_PERSPECTIVE
			M.client.eye = src


	if(dirn)
		step(load, dirn)

	load = null

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/AM in src)
		AM.loc = src.loc
		AM.layer = initial(AM.layer)
		AM.pixel_y = initial(AM.pixel_y)
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)
				M.client.perspective = MOB_PERSPECTIVE
				M.client.eye = src

/obj/machinery/rail_car/relaymove(var/mob/user)
	if(user.stat)
		return
	if(load == user)
		unload(0)
	return

/obj/machinery/rail_car/process()
	if (moving == 1)
		if (slowing == 1)
			if (speed > 0)
				speed--;
				if (speed == 0)
					slowing = 0
		else
			if (speed < 10)
				speed++;
		var/i = 0
		for (i = 0; i < speed; i++)
			if (moving == 1)
				switch (direction)
					if ("S")
						for (var/obj/machinery/rail_track/R in locate(src.x,src.y-1,src.z))
							if (R.dir == 10)
								direction = "W"
							if (R.dir == 9)
								direction = "E"
							if (R.dir == 2 || R.dir == 1 || R.dir == 10 || R.dir == 9)
								for (var/mob/living/M in locate(src.x,src.y-1,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("N")
						for (var/obj/machinery/rail_track/R in locate(src.x,src.y+1,src.z))
							if (R.dir == 5)
								direction = "E"
							if (R.dir == 6)
								direction = "W"
							if (R.dir == 5 || R.dir == 1 || R.dir == 6 || R.dir == 2)
								for (var/mob/living/M in locate(src.x,src.y+1,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("E")
						for (var/obj/machinery/rail_track/R in locate(src.x+1,src.y,src.z))
							if (R.dir == 6)
								direction = "S"
							if (R.dir == 10)
								direction = "N"
							if (R.dir == 4 || R.dir == 8 || R.dir == 10 || R.dir == 6)
								for (var/mob/living/M in locate(src.x+1,src.y,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("W")
						for (var/obj/machinery/rail_track/R in locate(src.x-1,src.y,src.z))
							if (R.dir == 9)
								direction = "N"
							if (R.dir == 5)
								direction = "S"
							if (R.dir == 8 || R.dir == 9 || R.dir == 5 || R.dir == 4)
								for (var/mob/living/M in locate(src.x-1,src.y,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
				sleep(1)
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
		dat += text("<A href='?src=\ref[src];ship=hopper'>Planet hopper</A> - Tiny, Slow, 25000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=bus'>Blunder Bus</A> - Small, Decent speed, 60000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=dinghy'>Space dinghy</A> - Medium size, Decent speed, 100000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=van'>Boxvan MMDLVIr</A> - Medium size, Decent speed, 120000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=secvan'>Boxvan MMDLVI - Security eidition</A> - Large, Rather slow, 125000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=station4'>Space station 4</A> - Huge, Slow, 250000 metal<br>")

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