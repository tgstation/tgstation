var/const/stuff = {"
Hats
Collectable Pete hat:/obj/item/clothing/head/collectable/petehat:150
Collectable Xeno hat:/obj/item/clothing/head/collectable/xenom:110
Collectable Top hat:/obj/item/clothing/head/collectable/tophat:120
Kitty Ears:/obj/item/clothing/head/kitty:100
Ushanka:/obj/item/clothing/head/ushanka:200
Beret:/obj/item/clothing/head/beret:150
Witch Wig:/obj/item/clothing/head/witchwig:135
Marisa hat:/obj/item/clothing/head/witchwig:130
Cake-hat:/obj/item/clothing/head/hardhat/cakehat:100
Wizard hat:/obj/item/clothing/head/wizard/fake:100
Flat-cap:/obj/item/clothing/head/flatcap:120
Collectable rabbit ears:/obj/item/clothing/head/collectable/rabbitears:120
Cardborg helment:/obj/item/clothing/head/cardborg:20
Bear pelt:/obj/item/clothing/head/bearpelt:200

Masks
Fake Moustache:/obj/item/clothing/mask/fakemoustache:100
Pig Mask:/obj/item/clothing/mask/spig:150
Cow Mask:/obj/item/clothing/mask/cowmask:150
Horse Head Mask:/obj/item/clothing/mask/horsehead:150
Carp Mask:/obj/item/clothing/mask/gas/carp:150
Plague Doctor Mask:/obj/item/clothing/mask/gas/plaguedoctor:180
Monkey Mask:/obj/item/clothing/mask/gas/monkeymask:180
Owl Mask:/obj/item/clothing/mask/gas/owl_mask:180

Personal Stuff
Eye patch:/obj/item/clothing/glasses/eyepatch:130
Orange glasses:/obj/item/clothing/glasses/orange:130
Heat goggles:/obj/item/clothing/glasses/heat:130
Cold goggles:/obj/item/clothing/glasses/cold:130
Cane:/obj/item/weapon/cane:130
Zippo:/obj/item/weapon/lighter:130
Cigarette packet:/obj/item/weapon/storage/fancy/cigarettes:20
DromedaryCo packet:/obj/item/weapon/storage/fancy/cigarettes/dromedaryco:50
Premium Havanian Cigar:/obj/item/clothing/mask/cigarette/cigar/havana:130
E-Cigarette:/obj/item/clothing/mask/vape:150
Beer bottle:/obj/item/weapon/reagent_containers/food/drinks/beer:80
Captain flask:/obj/item/weapon/reagent_containers/food/drinks/flask:200
Three Mile Island Ice Tea:/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/threemileisland:100
Red glasses:/obj/item/clothing/glasses/red:180
Waistcoat:/obj/item/clothing/tie/waistcoat:85
Cloak:/obj/item/clothing/neck/cloak:190
Donut Box:/obj/item/weapon/storage/fancy/donut_box:450

Shoes
Clown Shoes:/obj/item/clothing/shoes/clown_shoes:130
Cyborg Shoes:/obj/item/clothing/shoes/cyborg:130
Laceups Shoes:/obj/item/clothing/shoes/laceup:130
Wooden Sandals:/obj/item/clothing/shoes/sandal:80
Brown Shoes:/obj/item/clothing/shoes/sneakers/brown:130
Jackboots:/obj/item/clothing/shoes/jackboots:170

Coats
Leather Coat:/obj/item/clothing/suit/jacket/leather/overcoat:160
Pirate Coat:/obj/item/clothing/suit/pirate:120
Red poncho:/obj/item/clothing/suit/poncho/red:140
Green poncho:/obj/item/clothing/suit/poncho/green:150
Puffer jacket:/obj/item/clothing/suit/jacket/puffer:120
Winter coat:/obj/item/clothing/suit/hooded/wintercoat:130
Cardborg:/obj/item/clothing/suit/cardborg:50

Jumpsuits
Vice Policeman:/obj/item/clothing/under/rank/vice:180
Pirate outfit:/obj/item/clothing/under/pirate:130
Waiter outfit:/obj/item/clothing/under/waiter:120
Black suit:/obj/item/clothing/under/lawyer/blacksuit:150
Central Command officer:/obj/item/clothing/under/rank/centcom_officer:390
Jeans:/obj/item/clothing/under/pants/jeans:160
Rainbow Suit:/obj/item/clothing/under/color/rainbow:130
Grim Jacket:/obj/item/clothing/under/suit_jacket:130
Executive Suit:/obj/item/clothing/under/suit_jacket/really_black:130
Schoolgirl Uniform:/obj/item/clothing/under/schoolgirl:130
Tacticool Turtleneck:/obj/item/clothing/under/syndicate/tacticool:130
Soviet Uniform:/obj/item/clothing/under/soviet:130
Kilt:/obj/item/clothing/under/kilt:100
Gladiator uniform:/obj/item/clothing/under/gladiator:100
Assistant's formal uniform:/obj/item/clothing/under/assistantformal:100
Psychedelic jumpsuit:/obj/item/clothing/under/rank/psyche:220



Gloves
White Gloves:/obj/item/clothing/gloves/color/white:130
Rainbow Gloves:/obj/item/clothing/gloves/color/rainbow:200
Black Gloves:/obj/item/clothing/gloves/color/black:160
Boxing Gloves:/obj/item/clothing/gloves/boxing:120
Green Gloves:/obj/item/clothing/gloves/color/green:100
Latex Gloves:/obj/item/clothing/gloves/color/latex:150
Fingerless Gloves:/obj/item/clothing/gloves/fingerless:90

Bedsheets
Clown Bedsheet:/obj/item/weapon/bedsheet/clown:100
Mime Bedsheet:/obj/item/weapon/bedsheet/mime:100
Rainbow Bedsheet:/obj/item/weapon/bedsheet/rainbow:100
Captain Bedsheet:/obj/item/weapon/bedsheet/captain:120

Toys
Rubber Duck:/obj/item/weapon/bikehorn/rubberducky:200
Champion Belt:/obj/item/weapon/storage/belt/champion:200
Toy pistol:/obj/item/toy/gun:150
Toy dualsaber:/obj/item/weapon/twohanded/dualsaber/toy:300
Rainbow crayon:/obj/item/toy/crayon/rainbow:250

Special Stuff
Santa Bag:/obj/item/weapon/storage/backpack/santabag:600
Bible:/obj/item/weapon/storage/book/bible:100
"}


var/list/datum/donator_prize/prizes = list()
var/list/datum/donator/donators = list()

#define DONATIONS_SPAWN_WINDOW 6000
// You can spawn donation items for 10 minutes without area limits.


/datum/donator
	var/ownerkey
	var/money = 0
	var/maxmoney = 0
	var/allowed_num_items = 10 //rel lox //sam lox

/datum/donator/New(ckey, money)
	..()
	ownerkey = ckey
	src.money = money
	maxmoney = money
	donators[ckey] = src

/datum/donator/proc/show()
	var/dat = "<title>Donations panel</title>"
	dat += "You have [money] / [maxmoney]<br>"
	dat += "You can spawn [allowed_num_items ? allowed_num_items : "no"] more items.<br><br>"

	if (allowed_num_items)
		if (!prizes.len)
			build_prizes_list()

		var/cur_cat = "None"

		for(var/p in prizes)
			var/datum/donator_prize/prize = p

			if (cur_cat != prize.category)
				dat += "<hr><b>[prize.category]</b><br>"
				cur_cat = prize.category

			dat += "<a href='?src=\ref[src];item=\ref[prize]'>[prize.item_name] : [prize.cost]</a><br>"
	usr << browse(dat, "window=donatorpanel;size=250x400")

/datum/donator/Topic(href, href_list)
	var/datum/donator_prize/prize = locate(href_list["item"])
	var/mob/living/carbon/human/user = usr

	if(!SSticker || SSticker.current_state < 3)
		usr << "<span class='warning'>Please wait until game setting up!</span>"
		return 0

	if((world.time-SSticker.round_start_time)>DONATIONS_SPAWN_WINDOW && !istype(get_area(user), /area/shuttle/arrival))
		usr << "<span class='warning'>You must be on arrival shuttle to spawn items.</span>"
		return 0

	if(prize.cost > money)
		usr << "<span class='warning'>You don't have enough funds.</span>"
		return 0

	if(!allowed_num_items)
		usr << "<span class='warning'>You have reached maximum amount of spawned items.</span>"
		return 0

	if(!user)
		user << "<span class='warning'>You must be a human to use this.</span>"
		return 0

	if(!ispath(prize.path_to))
		return 0

	if(user.stat)
		return 0


	var/list/slots = list(
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"hand" = slot_generic_dextrous_storage
	)

	var/obj/spawned = new prize.path_to(user.loc)
	var/where = user.equip_in_one_of_slots(spawned, slots, qdel_on_fail=0)

	if (!where)
		usr << "<span class='info'>Your [prize.item_name] has been spawned!</span>"
	else
		usr << "<span class='info'>Your [prize.item_name] has been spawned in your [where]!</span>"

	money -= prize.cost
	allowed_num_items--

	show()

/datum/donator_prize
	var/item_name = "Nothing"
	var/path_to = null
	var/cost = 0
	var/category = "Debug"

proc/load_donator(ckey)
//	var/DBConnection/dbcon2 = new()
//	dbcon2.doConnect("dbi:mysql:forum2:[global.sqladdress]:[global.sqlport]","[global.sqlfdbklogin]","[global.sqlfdbkpass]") //pidorasy

	if(!dbcon2.IsConnected())
//		world.log << "Failed to connect to database [dbcon2.ErrorMsg()] in load_donator([ckey])."
//		world.log << "Failed to connect to database in load_donator([ckey])."
		return 0

	var/DBQuery/query = dbcon2.NewQuery("SELECT round(sum) FROM Z_donators WHERE byond='[ckey]'")
	query.Execute()
	while(query.NextRow())
		var/money = round(text2num(query.item[1]))
		new /datum/donator(ckey, money)
//	dbcon2.Disconnect()
	return 1

proc/build_prizes_list()
	var/list/strings = splittext ( stuff, "\n" )
	var/cur_cat = "Miscellaneous"
	for (var/string in strings)
		if (string) //It's not a delimiter between
			var/list/item_info = splittext ( string, ":" )
			if (item_info.len==3)
				var/datum/donator_prize/prize = new
				prize.item_name = item_info[1]
				prize.path_to = text2path(item_info[2])
				prize.cost = text2num(item_info[3])
				prize.category = cur_cat
				prizes += prize
			else
				cur_cat = item_info[1]


/client/verb/cmd_donations_panel()
	set name = "Donations panel"
	set category = "OOC"


	if(!SSticker || SSticker.current_state < GAME_STATE_PLAYING)
		usr << "<span class='warning'>Please wait until game is set up!</span>"
		return

	if (!donators[ckey]) //It doesn't exist yet
		load_donator(ckey)

	var/datum/donator/D = donators[ckey]
	if(D)
		D.show()
	else
		usr << "<span class='warning'>You have not donated or donations database is inaccessible.</span>"


//SPECIAL ITEMS
/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/threemileisland/New()
	..()
	reagents.add_reagent("threemileisland", 50)
