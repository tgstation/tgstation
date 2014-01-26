//Contains the target item datums for Steal objectives.

datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/weapon/bikehorn		//typepath of the objective
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)

datum/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1


datum/objective_item/caplaser
	name = "the captain's antique laser gun"
	targetitem = /obj/item/weapon/gun/energy/laser/captain
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/handtele
	name = "a hand teleporter"
	targetitem = /obj/item/weapon/hand_tele
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/rcd
	name = "a rapid-construction-device"
	targetitem = /obj/item/weapon/rcd
	difficulty = 3

datum/objective_item/jetpack
	name = "a jetpack"
	targetitem = /obj/item/weapon/tank/jetpack
	difficulty = 3

datum/objective_item/magboots
	name = "a pair of magboots"
	targetitem =  /obj/item/clothing/shoes/magboots
	difficulty = 5
	excludefromjob = list("Chief Engineer")

datum/objective_item/corgimeat
	name = "a piece of corgi meat"
	targetitem = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	difficulty = 5
	excludefromjob = list("Head of Personnel") //>hurting your little buddy ever

datum/objective_item/capmedal
	name = "the medal of captaincy"
	targetitem = /obj/item/clothing/tie/medal/gold/captain
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/hypo
	name = "the hypospray"
	targetitem = /obj/item/weapon/reagent_containers/hypospray
	difficulty = 5
	excludefromjob = list("Chief Medical Officer")

datum/objective_item/nukedisc
	name = "the nuclear authentication disk"
	targetitem = /obj/item/weapon/disk/nuclear
	difficulty = 5
	excludefromjob = list("Captain")

datum/objective_item/ablative
	name = "an ablative armor vest"
	targetitem = /obj/item/clothing/suit/armor/laserproof
	difficulty = 3
	excludefromjob = list("Head of Security", "Warden")

datum/objective_item/reactive
	name = "the reactive teleport armor"
	targetitem = /obj/item/clothing/suit/armor/reactive
	difficulty = 5
	excludefromjob = list("Research Director")

//Items with special checks!
datum/objective_item/plasma
	name = "28 moles of plasma (full tank)"
	targetitem = /obj/item/weapon/tank
	difficulty = 3
	excludefromjob = list("Chief Engineer","Research Director","Station Engineer","Scientist","Atmospheric Technician")

datum/objective_item/plasma/check_special_completion(var/obj/item/weapon/tank/T)
	var/found_amount = 0
	found_amount += T:air_contents:toxins
	return found_amount>=target_amount


datum/objective_item/functionalai
	name = "a functional AI"
	targetitem = /obj/item/device/aicard
	difficulty = 20 //beyond the impossible

datum/objective_item/functionalai/check_special_completion(var/obj/item/device/aicard/C)
	for(var/mob/living/silicon/ai/A in C)
		if(istype(A, /mob/living/silicon/ai) && A.stat != 2) //See if any AI's are alive inside that card.
			return 1
	return 0


datum/objective_item/blueprints
	name = "the station blueprints"
	targetitem = /obj/item/blueprints
	difficulty = 10
	excludefromjob = list("Chief Engineer")
/*//i hate u pete
datum/objective_item/blueprints/check_special_completion(var/obj/item/I)
	for(var/obj/item/I in all_items)	//the actual blueprints are good too!
		if(istype(I, /obj/item/blueprints))
			return 1
		if(istype(I, /obj/item/weapon/photo))
			var/obj/item/weapon/photo/P = I
			if(P.blueprints)	//if the blueprints are in frame
				return 1
	return 1
*/

datum/objective_item/slime
	name = "an unused sample of slime extract"
	targetitem = /obj/item/slime_extract
	difficulty = 3
	excludefromjob = list("Research Director","Scientist")

datum/objective_item/slime/check_special_completion(var/obj/item/slime_extract/E)
	if(E.Uses > 0)
		return 1
	return 0



/*

		if("28 moles of plasma (full tank)","10 diamonds","50 gold bars","25 refined uranium bars")
			var/target_amount = text2num(target_name)//Non-numbers are ignored.
			var/found_amount = 0.0//Always starts as zero.

			for(var/obj/item/I in all_items) //Check for plasma tanks
				if(istype(I, steal_target))
					found_amount += (target_name=="28 moles of plasma (full tank)" ? (I:air_contents:toxins) : (I:amount))
			return found_amount>=target_amount

		if("a functional AI")
			for(var/obj/item/device/aicard/C in all_items) //Check for ai card
				for(var/mob/living/silicon/ai/M in C)
					if(istype(M, /mob/living/silicon/ai) && M.stat != 2) //See if any AI's are alive inside that card.
						return 1

		if("the station blueprints")
			for(var/obj/item/I in all_items)	//the actual blueprints are good too!
				if(istype(I, /obj/item/blueprints))
					return 1
				if(istype(I, /obj/item/weapon/photo))
					var/obj/item/weapon/photo/P = I
					if(P.blueprints)	//if the blueprints are in frame
						return 1

		if("an unused sample of slime extract")
			for(var/obj/item/slime_extract/E in all_items)
				if(E.Uses > 0)
					return 1


	var/global/possible_items_special[] = list(
		"the captain's pinpointer" = /obj/item/weapon/pinpointer,
		"an advanced energy gun" = /obj/item/weapon/gun/energy/gun/nuclear,
		"a diamond drill" = /obj/item/weapon/pickaxe/diamonddrill,
		"a bag of holding" = /obj/item/weapon/storage/backpack/holding,
		"a hyper-capacity cell" = /obj/item/weapon/cell/hyper,
		"10 diamonds" = /obj/item/stack/sheet/mineral/diamond,
		"50 gold bars" = /obj/item/stack/sheet/mineral/gold,
		"25 refined uranium bars" = /obj/item/stack/sheet/mineral/uranium,
		"a laser pointer" = /obj/item/device/laser_pointer,
	)
*/