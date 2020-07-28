//Contains the target item datums for Steal objectives.

/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/bikehorn		//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/altitems = list()				//Items which can serve as an alternative to the objective (darn you blueprints)
	var/list/special_equipment = list()

/datum/objective_item/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/objective_item/proc/TargetExists()
	return TRUE

/datum/objective_item/steal/New()
	..()
	if(TargetExists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

/datum/objective_item/steal/caplaser
	name = "the captain's antique laser gun."
	targetitem = /obj/item/gun/energy/laser/captain
	difficulty = 5
	excludefromjob = list("Captain")

/datum/objective_item/steal/hoslaser
	name = "the head of security's personal laser gun."
	targetitem = /obj/item/gun/energy/e_gun/hos
	difficulty = 10
	excludefromjob = list("Head Of Security")

/datum/objective_item/steal/handtele
	name = "a hand teleporter."
	targetitem = /obj/item/hand_tele
	difficulty = 5
	excludefromjob = list("Captain", "Research Director")

/datum/objective_item/steal/jetpack
	name = "the Captain's jetpack."
	targetitem = /obj/item/tank/jetpack/oxygen/captain
	difficulty = 5
	excludefromjob = list("Captain")

/datum/objective_item/steal/magboots
	name = "the chief engineer's advanced magnetic boots."
	targetitem =  /obj/item/clothing/shoes/magboots/advance
	difficulty = 5
	excludefromjob = list("Chief Engineer")

/datum/objective_item/steal/capmedal
	name = "the medal of captaincy."
	targetitem = /obj/item/clothing/accessory/medal/gold/captain
	difficulty = 5
	excludefromjob = list("Captain")

/datum/objective_item/steal/hypo
	name = "the hypospray."
	targetitem = /obj/item/reagent_containers/hypospray/cmo
	difficulty = 5
	excludefromjob = list("Chief Medical Officer")

/datum/objective_item/steal/nukedisc
	name = "the nuclear authentication disk."
	targetitem = /obj/item/disk/nuclear
	difficulty = 5
	excludefromjob = list("Captain")

/datum/objective_item/steal/nukedisc/check_special_completion(obj/item/disk/nuclear/N)
	return !N.fake

/datum/objective_item/steal/reflector
	name = "a reflector trenchcoat."
	targetitem = /obj/item/clothing/suit/hooded/ablative
	difficulty = 3
	excludefromjob = list("Head of Security", "Warden")

/datum/objective_item/steal/reactive
	name = "the reactive teleport armor."
	targetitem = /obj/item/clothing/suit/armor/reactive/teleport
	difficulty = 5
	excludefromjob = list("Research Director")

/datum/objective_item/steal/documents
	name = "any set of secret documents of any organization."
	targetitem = /obj/item/documents //Any set of secret documents. Doesn't have to be NT's
	difficulty = 5

/datum/objective_item/steal/nuke_core
	name = "the heavily radioactive plutonium core from the onboard self-destruct. Take care to wear the proper safety equipment when extracting the core!"
	targetitem = /obj/item/nuke_core
	difficulty = 15

/datum/objective_item/steal/nuke_core/New()
	special_equipment += /obj/item/storage/box/syndie_kit/nuke
	..()

/datum/objective_item/steal/supermatter
	name = "a sliver of a supermatter crystal. Be sure to use the proper safety equipment when extracting the sliver!"
	targetitem = /obj/item/nuke_core/supermatter_sliver
	difficulty = 15

/datum/objective_item/steal/supermatter/New()
	special_equipment += /obj/item/storage/box/syndie_kit/supermatter
	..()

/datum/objective_item/steal/supermatter/TargetExists()
	return GLOB.main_supermatter_engine != null

//Items with special checks!
/datum/objective_item/steal/plasma
	name = "28 moles of plasma (full tank)."
	targetitem = /obj/item/tank
	difficulty = 3
	excludefromjob = list("Chief Engineer","Research Director","Station Engineer","Scientist","Atmospheric Technician")

/datum/objective_item/steal/plasma/check_special_completion(obj/item/tank/T)
	var/target_amount = text2num(name)
	var/found_amount = 0
	found_amount += T.air_contents.gases[/datum/gas/plasma] ? T.air_contents.gases[/datum/gas/plasma][MOLES] : 0
	return found_amount>=target_amount


/datum/objective_item/steal/functionalai
	name = "a functional AI."
	targetitem = /obj/item/aicard
	difficulty = 20 //beyond the impossible

/datum/objective_item/steal/functionalai/check_special_completion(obj/item/aicard/C)
	for(var/mob/living/silicon/ai/A in C)
		if(isAI(A) && A.stat != DEAD) //See if any AI's are alive inside that card.
			return 1
	return 0

// Beginning of fulp edit for pets
/datum/objective_item/steal/iandog
	name = "Ian, the Head of Personnel's pet corgi, alive."
	targetitem = /obj/item/pet_carrier
	difficulty = 20
	excludefromjob = list("Head of Personnel")
	altitems = list(/obj/item/clothing/head/mob_holder)

/datum/objective_item/steal/iandog/New()
	special_equipment += /obj/item/lazarus_injector
	..()

/datum/objective_item/steal/iandog/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/pet_carrier))
		var/obj/item/pet_carrier/C = I
		for(var/mob/living/simple_animal/pet/dog/corgi/ian/D in C)
			if(D.stat != DEAD)//checks if pet is alive.
				return TRUE
		for(var/mob/living/simple_animal/pet/dog/corgi/puppy/D in C)
			if(D.stat != DEAD)//checks if pet is alive.
				if(D.desc == "It's the HoP's beloved corgi puppy.")
					return TRUE
	if(istype(I, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/C = I
		for(var/mob/living/simple_animal/pet/dog/corgi/ian/D in C)
			if(D.stat != DEAD)//checks if pet is alive.
				return TRUE
		for(var/mob/living/simple_animal/pet/dog/corgi/puppy/D in C)
			if(D.stat != DEAD)//checks if pet is alive.
				if(D.desc == "It's the HoP's beloved corgi puppy.")
					return TRUE
	return FALSE 

/datum/objective_item/steal/poly
	name = "Poly, the Chief Engineer's pet parrot, alive"
	targetitem = /obj/item/pet_carrier
	difficulty = 30
	excludefromjob = list("Chief Engineer")
	altitems = list(/obj/item/clothing/head/mob_holder)

/datum/objective_item/steal/poly/New()
	special_equipment += /obj/item/lazarus_injector
	..()

/datum/objective_item/steal/poly/check_special_completion(obj/item/B)
	if(istype(B, /obj/item/pet_carrier))
		var/obj/item/pet_carrier/A = B
		for(var/mob/living/simple_animal/parrot/poly/D in A)
			if(D.stat != DEAD)//checks if pet is alive.
				return TRUE
	if(istype(B, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/A = B
		for(var/mob/living/simple_animal/parrot/poly/D in A)
			if(D.stat != DEAD)//checks if pet is alive.
				return TRUE
	return FALSE

/datum/objective_item/steal/runtimecat
	name = "Runtime, the Cheif Medical Officer's pet, alive."
	targetitem = /obj/item/pet_carrier
	difficulty = 20
	excludefromjob = list("Chief Medical Officer")
	altitems = list(/obj/item/clothing/head/mob_holder)

/datum/objective_item/steal/runtimecat/New()
	special_equipment += /obj/item/lazarus_injector
	..()

/datum/objective_item/steal/runtimecat/check_special_completion(obj/item/H)
	if(istype(H, /obj/item/pet_carrier))
		var/obj/item/pet_carrier/T = H
		for(var/mob/living/simple_animal/pet/cat/runtime/D in T)
			if(D.stat != DEAD)//checks if pet is alive.
				return TRUE
	if(istype(H, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/T = H
		for(var/mob/living/simple_animal/pet/cat/runtime/D in T)
			if(D.stat != DEAD)//checks if pet is alive.
				return TRUE
	return FALSE

/datum/objective_item/steal/renaultfox
	name = "Renault, the Captain's prized fox, alive!"
	targetitem = /obj/item/pet_carrier
	difficulty = 20
	excludefromjob = list("Captain")
	altitems = list(/obj/item/clothing/head/mob_holder)

/datum/objective_item/steal/renaultfox/New()
	special_equipment += /obj/item/lazarus_injector
	..()

/datum/objective_item/steal/renaultfox/check_special_completion(obj/item/K)
	if(istype(K, /obj/item/pet_carrier))
		var/obj/item/pet_carrier/G = K
		for(var/mob/living/simple_animal/pet/fox/renault/D in G)
			if(D.stat != DEAD)//checks if pet is alive.
				return TRUE
	if(istype(K, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/G = K
		for(var/mob/living/simple_animal/pet/fox/renault/D in G)
			if(D.stat != DEAD)//checks if pet is alive.
				return TRUE
	return FALSE

/datum/objective_item/steal/lamarr
	name = "Lamarr The subject of study by the research director."
	targetitem = /obj/item/clothing/mask/facehugger/lamarr
	difficulty = 40
	excludefromjob = list("Research Director")

//End of fulp edit for pets

/datum/objective_item/steal/blueprints
	name = "the station blueprints."
	targetitem = /obj/item/areaeditor/blueprints
	difficulty = 10
	excludefromjob = list("Chief Engineer")
	altitems = list(/obj/item/photo)

/datum/objective_item/steal/blueprints/check_special_completion(obj/item/I)
	if(istype(I, /obj/item/areaeditor/blueprints))
		return TRUE
	if(istype(I, /obj/item/photo))
		var/obj/item/photo/P = I
		if(P.picture.has_blueprints)	//if the blueprints are in frame
			return TRUE
	return FALSE

/datum/objective_item/steal/slime
	name = "an unused sample of slime extract."
	targetitem = /obj/item/slime_extract
	difficulty = 3
	excludefromjob = list("Research Director","Scientist")

/datum/objective_item/steal/slime/check_special_completion(obj/item/slime_extract/E)
	if(E.Uses > 0)
		return 1
	return 0

/datum/objective_item/steal/blackbox
	name = "The Blackbox."
	targetitem = /obj/item/blackbox
	difficulty = 10
	excludefromjob = list("Chief Engineer","Station Engineer","Atmospheric Technician")

//Unique Objectives
/datum/objective_item/unique/docs_red
	name = "the \"Red\" secret documents."
	targetitem = /obj/item/documents/syndicate/red
	difficulty = 10

/datum/objective_item/unique/docs_blue
	name = "the \"Blue\" secret documents."
	targetitem = /obj/item/documents/syndicate/blue
	difficulty = 10

/datum/objective_item/special/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/special/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Old ninja objectives.
/datum/objective_item/special/pinpointer/nuke
	name = "the captain's pinpointer."
	targetitem = /obj/item/pinpointer
	difficulty = 10

/datum/objective_item/special/aegun
	name = "an advanced energy gun."
	targetitem = /obj/item/gun/energy/e_gun/nuclear
	difficulty = 10

/datum/objective_item/special/ddrill
	name = "a diamond drill."
	targetitem = /obj/item/pickaxe/drill/diamonddrill
	difficulty = 10

/datum/objective_item/special/boh
	name = "a bag of holding."
	targetitem = /obj/item/storage/backpack/holding
	difficulty = 10

/datum/objective_item/special/hypercell
	name = "a hyper-capacity power cell."
	targetitem = /obj/item/stock_parts/cell/hyper
	difficulty = 5

/datum/objective_item/special/laserpointer
	name = "a laser pointer."
	targetitem = /obj/item/laser_pointer
	difficulty = 5

/datum/objective_item/special/corgimeat
	name = "a piece of corgi meat."
	targetitem = /obj/item/reagent_containers/food/snacks/meat/slab/corgi
	difficulty = 5

/datum/objective_item/stack/New()
	..()
	if(TargetExists())
		GLOB.possible_items_special += src
	else
		qdel(src)

/datum/objective_item/stack/Destroy()
	GLOB.possible_items_special -= src
	return ..()

//Stack objectives get their own subtype
/datum/objective_item/stack
	name = "5 cardboard."
	targetitem = /obj/item/stack/sheet/cardboard
	difficulty = 9001

/datum/objective_item/stack/check_special_completion(obj/item/stack/S)
	var/target_amount = text2num(name)
	var/found_amount = 0

	if(istype(S, targetitem))
		found_amount = S.amount
	return found_amount>=target_amount

/datum/objective_item/stack/diamond
	name = "10 diamonds."
	targetitem = /obj/item/stack/sheet/mineral/diamond
	difficulty = 10

/datum/objective_item/stack/gold
	name = "50 gold bars."
	targetitem = /obj/item/stack/sheet/mineral/gold
	difficulty = 15

/datum/objective_item/stack/uranium
	name = "25 refined uranium bars."
	targetitem = /obj/item/stack/sheet/mineral/uranium
	difficulty = 10
