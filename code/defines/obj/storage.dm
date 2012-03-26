/obj/item/weapon/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	w_class = 4.0
	flags = 259.0
	max_w_class = 3
	max_combined_w_class = 21

/obj/item/weapon/storage/backpack/cultpack
	name = "Trophy Rack"
	desc = "A backpack and trophy rack, useful for both carrying extra gear and proudly declaring your insanity "
	icon_state = "cultpack"

/obj/item/weapon/storage/trashbag
	name = "trash bag"
	desc = "For picking up all that trash."
	icon_state = "trashbag"
	item_state = "trashbag"
	w_class = 4.0
	storage_slots = 20
	max_w_class = 1
	max_combined_w_class = 20
/*
/obj/item/weapon/storage/lbe
	name = "Load Bearing Equipment"
	desc = "You wear these on your thighs, they help carry heavy loads."
	icon_state = "backpack" //PLACEHOLDER
	w_class = 2.0
	max_combined_w_class = 17
*/
/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "A reasonable place to put your pills."
	icon_state = "pill_canister"
	icon = 'chemical.dmi'
	item_state = "contsolid"
	w_class = 2.0
	can_hold = list("/obj/item/weapon/reagent_containers/pill")

/obj/item/weapon/storage/dice
	name = "dice pack"
	desc = "Apparently this has dice in them."
	icon_state = "pill_canister"
	icon = 'chemical.dmi'
	item_state = "contsolid"
	w_class = 2.0
	can_hold = list("/obj/item/weapon/dice")

/obj/item/weapon/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"

/obj/item/weapon/storage/box/engineer

/obj/item/weapon/storage/box/medic
	name = "anesthetic box"
	desc = "Full of masks and emergency anesthetic tanks."

/obj/item/weapon/storage/box/syndicate

/obj/item/weapon/storage/box/ert
	name = "medical box"
	desc = "Full of goodness."
	icon_state = "implant"
	item_state = "syringe_kit"
/obj/item/weapon/storage/cupbox
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )
		new /obj/item/weapon/reagent_containers/food/drinks/sillycup( src )

/obj/item/weapon/storage/pillbottlebox
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/blankbox
	name = "box of blank shells"
	desc = "It has a picture of a gun and several warning symbols on the front."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/backpack/clown
	name = "Giggles Von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"

/obj/item/weapon/storage/backpack/medic
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"

/obj/item/weapon/storage/backpack/medic/full
//Spawns with 2 boxes of ERT gear, a box of ERT gear and a hypo, and a box of anesthetic.
	New()
		..()
		new /obj/item/weapon/reagent_containers/hypospray/ert(src)
		for(var/i = 1, i <=2, i++)
			new /obj/item/weapon/storage/box/ert(src)
		new /obj/item/weapon/storage/box/medic(src)
		new /obj/item/weapon/storage/belt/medical(src)
		return

/obj/item/weapon/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"

/obj/item/weapon/storage/backpack/satchel
	name = "satchel"
	desc = "It's a very robust satchel to wear on your back."
	icon_state = "satchel"

	New()
		..()

/obj/item/weapon/storage/backpack/bandolier
	name = "bandolier"
	desc = "It's a very old bandolier to wear on your back."
	icon_state = "bandolier"

/obj/item/weapon/storage/backpack/medicalsatchel
	name = "medic's satchel"
	desc = "Easy to access medical satchel for quick responses."
	icon_state = "medicalsatchel"

/obj/item/weapon/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"

/obj/item/weapon/storage/backpack/industrial/full
	name = "loaded industrial backpack"
	desc = "A tough backpack for the daily grind, full of gear"
	icon_state = "engiepack"

//Spawns with 2 glass, 2 metal, 1 steel, and 2 special boxes.
	New()
		..()
		for(var/i = 1, i <=2, i++)
			var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src)
			G.amount = 50
			G.loc = src
		for(var/i = 1, i <=2, i++)
			var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src)
			G.amount = 50
			G.loc = src
		var/obj/item/stack/sheet/r_metal/R = new /obj/item/stack/sheet/r_metal(src)
		R.amount = 50
		R.loc = src
		var/obj/item/weapon/storage/box/B1 = new /obj/item/weapon/storage/box(src)
		B1.name = "power and airlock circuit box"
		B1.desc = "Bursting with repair gear"
		B1.w_class = 2
		for(var/i = 1, i <= 7, i++)
			if(i < 4)
				var/obj/item/weapon/module/power_control/P = new /obj/item/weapon/module/power_control(B1)
				P.loc = B1
			if(i >= 4)
				var/obj/item/weapon/airlock_electronics/P = new /obj/item/weapon/airlock_electronics(B1)
				P.loc = B1
		var/obj/item/weapon/storage/box/B2 = new /obj/item/weapon/storage/box(src)
		B2.name = "power cells and wire box"
		B2.desc = "Bursting with repair gear"
		B2.w_class = 2
		var/color = pick("red","yellow","green","blue")
		for(var/i = 1, i <= 7, i++)
			if(i < 4)
				var/obj/item/weapon/cable_coil/P = new /obj/item/weapon/cable_coil(B2,30,color)
				P.loc = B2
			if(i >= 4)
				var/obj/item/weapon/cell/P = new /obj/item/weapon/cell(B2)
				P.maxcharge = 15000
				P.charge = 15000
				P.updateicon()
				P.loc = B2
		return

/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0
	max_w_class = 3
	max_combined_w_class = 16

/obj/item/weapon/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	storage_slots = 4
	icon_state = "wallet"
	can_hold = list(
		"/obj/item/weapon/spacecash",
		"/obj/item/weapon/card",
		"/obj/item/clothing/mask/cigarette",
		"/obj/item/device/flashlight/pen",
		"/obj/item/seeds",
		"/obj/item/stack/medical",
		"/obj/item/toy/crayon",
		"/obj/item/weapon/coin",
		"/obj/item/weapon/dice",
		"/obj/item/weapon/disk",
		"/obj/item/weapon/implanter",
		"/obj/item/weapon/lighter",
		"/obj/item/weapon/match",
		"/obj/item/weapon/paper",
		"/obj/item/weapon/pen",
		"/obj/item/weapon/photo",
		"/obj/item/weapon/reagent_containers/dropper",
		"/obj/item/weapon/screwdriver",
		"/obj/item/weapon/stamp")

	attackby(obj/item/A as obj, mob/user as mob)
		..()
		update_icon()
		return

	update_icon()
		for(var/obj/item/weapon/card/id/ID in contents)
			if(ID.icon_state == "gold")
				icon_state = "walletid_gold"
				return
			else if(ID.icon_state == "id")
				icon_state = "walletid"
				return
		icon_state = "wallet"



	proc/get_id()
		for(var/obj/item/weapon/card/id/ID in contents)
			if(istype(ID))
				return ID

/obj/item/weapon/storage/wallet/random/New()
	..()
	var/item1_type = pick( /obj/item/weapon/spacecash/c10,/obj/item/weapon/spacecash/c100,/obj/item/weapon/spacecash/c1000,/obj/item/weapon/spacecash/c20,/obj/item/weapon/spacecash/c200,/obj/item/weapon/spacecash/c50, /obj/item/weapon/spacecash/c500)
	var/item2_type
	if(prob(50))
		item2_type = pick( /obj/item/weapon/spacecash/c10,/obj/item/weapon/spacecash/c100,/obj/item/weapon/spacecash/c1000,/obj/item/weapon/spacecash/c20,/obj/item/weapon/spacecash/c200,/obj/item/weapon/spacecash/c50, /obj/item/weapon/spacecash/c500)
	var/item3_type = pick( /obj/item/weapon/coin/silver, /obj/item/weapon/coin/silver, /obj/item/weapon/coin/gold, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/iron )

	spawn(2)
		if(item1_type)
			new item1_type(src)
		if(item2_type)
			new item2_type(src)
		if(item3_type)
			new item3_type(src)


/obj/item/weapon/storage/disk_kit
	name = "box of data disks"
	desc = "It has a picture of a data disk on it."
	icon_state = "id"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/disk_kit/disks

/obj/item/weapon/storage/disk_kit/disks2

/obj/item/weapon/storage/fcard_kit
	name = "box of fingerprint cards"
	desc = "It has a picture of a fingerprint on each of its faces."
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "In case of injury."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	var/empty = 0

/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "Contains burn treatments."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

/obj/item/weapon/storage/syringes
	name = "Syringes"
	desc = "A box full of syringes."
	desc = "A biohazard alert warning is printed on the box"
	icon_state = "syringe"

/obj/item/weapon/storage/firstaid/toxin
	name = "Toxin First Aid"
	desc = "Contains anti-toxin medication."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

/obj/item/weapon/storage/firstaid/o2
	name = "Oxygen Deprivation First Aid"
	desc = "Contains oxygen deprivation medication."
	icon_state = "o2"
	item_state = "firstaid-o2"

/obj/item/weapon/storage/flashbang_kit
	name = "Flashbangs (WARNING)"
	desc = "<FONT color=red><B>WARNING: Do not use without reading these preautions!</B></FONT>\n<B>These devices are extremely dangerous and can cause blindness or deafness if used incorrectly.</B>\nThe chemicals contained in these devices have been tuned for maximal effectiveness and due to\nextreme safety precuaiotn shave been incased in a tamper-proof pack. DO NOT ATTEMPT TO OPEN\nFLASH WARNING: Do not use continually. Excercise extreme care when detonating in closed spaces.\n\tMake attemtps not to detonate withing range of 2 meters of the intended target. It is imperative\n\tthat the targets visit a medical professional after usage. Damage to eyes increases extremely per\n\tuse and according to range. Glasses with flash resistant filters DO NOT always work on high powered\n\tflash devices such as this. <B>EXERCISE CAUTION REGARDLESS OF CIRCUMSTANCES</B>\nSOUND WARNING: Do not use continually. Visit a medical professional if hearing is lost.\n\tThere is a slight chance per use of complete deafness. Exercise caution and restraint.\nSTUN WARNING: If the intended or unintended target is too close to detonation the resulting sound\n\tand flash have been known to cause extreme sensory overload resulting in temporary\n\tincapacitation.\n<B>DO NOT USE CONTINUALLY</B>\nOperating Directions:\n\t1. Pull detonnation pin. <B>ONCE THE PIN IS PULLED THE GRENADE CAN NOT BE DISARMED!</B>\n\t2. Throw grenade. <B>NEVER HOLD A LIVE FLASHBANG</B>\n\t3. The grenade will detonste 10 seconds hafter being primed. <B>EXCERCISE CAUTION</B>\n\t-<B>Never prime another grenade until after the first is detonated</B>\nNote: Usage of this pyrotechnic device without authorization is an extreme offense and can\nresult in severe punishment upwards of <B>10 years in prison per use</B>.\n\nDefault 3 second wait till from prime to detonation. This can be switched with a screwdriver\nto 10 seconds.\n\nCopyright of Nanotrasen Industries- Military Armnaments Division\nThis device was created by Nanotrasen Labs a member of the Expert Advisor Corporation"
	icon_state = "flashbang"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/emp_kit
	name = "emp grenades"
	desc = "A box with 5 emp grenades."
	icon_state = "flashbang"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/gl_kit
	name = "Prescription Glasses"
	desc = "This box contains nerd glasses."
	icon_state = "glasses"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/seccart_kit
	name = "Spare R.O.B.U.S.T. Cartridges"
	desc = "A box full of R.O.B.U.S.T. Cartridges, used by Security."
	icon = 'pda.dmi'
	icon_state = "pdabox"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/handcuff_kit
	name = "Spare Handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "handcuff"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/id_kit
	name = "Spare IDs"
	desc = "Has many empty IDs."
	icon_state = "id"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/lglo_kit
	name = "Latex Gloves"
	desc = "Contains white gloves."
	icon_state = "latex"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/injectbox
	name = "DNA-Injectors"
	desc = "This box contains injectors it seems."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/stma_kit
	name = "Sterile Masks"
	desc = "This box contains masks of +2 constitution." //I made it better.  --SkyMarshal
	icon_state = "mask"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/trackimp_kit
	name = "Tracking Implant Kit"
	desc = "Box full of tracking implants."
	icon_state = "implant"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/chemimp_kit
	name = "Chemical Implant Kit"
	desc = "Box of stuff used to implant chemicals."
	icon_state = "implant"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/deathalarm_kit
	name = "Death Alarm Kit"
	desc = "Box of stuff used to implant death alarms."
	icon_state = "implant"
	item_state = "syringe_kit"

	New()
		..()
		new /obj/item/weapon/implanter(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)
		new /obj/item/weapon/implantcase/death_alarm(src)

/obj/item/weapon/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very heavy."
	icon = 'storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0
	origin_tech = "combat=1"

	var/selfdamage = 0

/obj/item/weapon/storage/toolbox/afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
	if(contents.len && istype(user.loc, /turf) && prob(10))
		// have a chance to swing open
		user.visible_message("\red \The [src] swings wide open and its contents are scattered on the floor!")
		for(var/obj/O in contents)
			O.loc = user.loc
			O.layer = OBJ_LAYER
			if(prob(50)) step_rand(O)
	..()

/obj/item/weapon/storage/toolbox/emergency
	name = "emergency toolbox"
	desc = "A toolbox for emergencies"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/mechanical
	name = "mechanical toolbox"
	desc = "A toolbox for holding tools about machinery."
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/toolbox/electrical
	name = "electrical toolbox"
	desc = "A toolbox for holding tools about electronics."
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/weapon/storage/PCMBox
	name = "spare power control modules"
	desc = "A box of spare power control module circuit boards."
	icon = 'storage.dmi'
	icon_state = "circuit"
	item_state = "syringe_kit"

/obj/item/weapon/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	desc = "You have no idea what this is."
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = "combat=1;syndicate=1"
	force = 14.0

/obj/item/weapon/storage/book
	name = "book"
	icon = 'library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	max_w_class = 2
	max_combined_w_class = 3
	storage_slots = 3
	flags = FPRINT | TABLEPASS

/obj/item/weapon/storage/bible
	name = "bible"
	desc = "Holds the word of religion."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/weapon/storage/bible/booze
	name = "bible"
	desc = "Holds the word of religion."
	icon_state ="bible"

/obj/item/weapon/storage/bible/tajaran
	name = "The Holy Book of S'rendarr"
	desc = "Holds the word of religion."
	icon_state ="koran"

/obj/item/weapon/storage/mousetraps
	name = "box of Pest-B-Gon Mousetraps"
	desc = "<B><FONT=red>WARNING:</FONT></B> <I>Keep out of reach of children</I>."
	icon_state = "mousetraps"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap

/obj/item/weapon/storage/donkpocket_kit
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave. Product will cool if not eaten within seven minutes.</I>"
	icon_state = "donk_kit"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."
	icon_state = "box"
	item_state = "syringe_kit"
	foldable = /obj/item/stack/sheet/cardboard	//BubbleWrap

/obj/item/weapon/storage/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."
	icon_state = "box"
	item_state = "syringe_kit"
