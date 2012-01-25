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
	CRAFT_ITEMS += new/datum/craftlathe_item("ADMAMANTINE","Adamantine",1,1,list("","","","","","","","",""),/obj/item/stack/sheet/adamantine)
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



	return