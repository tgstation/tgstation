//Loadout. There are 2 existing datums: Category datums and Loadout Items datums.
//Category datums have name and gear list, the former has to be set, the latter gets filled in STILLTOBEDECIDED
//Loadout Items have several vars that need to be set.

//DEFINES INSIDE /code/__DEFINES/hippie.dm
/datum/gear_category
	var/id = "none"
	var/list/gear_list

/datum/gear_category/New()
	..()
	for(var/i in subtypesof(/datum/gear))
		var/datum/gear/gear = i
		if(initial(gear.category) == id)
			LAZYADD(gear_list, new gear)

//Gear categories down here
/datum/gear_category/head
	id = HEADGEAR

/datum/gear_category/suit
	id = SUITGEAR

/datum/gear
	var/name = "gear name"
	var/category = "none"
	var/description = "why do i exist"
	var/path//item-to-spawn path
	var/cost = 1 //normally, each loadout costs a single point.
	var/list/locked_to_roles // use LAZYADD in Initialize() and add the roles your item is locked to

/datum/gear/New()
	..()
	if(!description)
		var/obj/O = path
		description = initial(O.desc)

/datum/gear/test
	name = "fuck you"
	description = "i'm cool"
	category = HEADGEAR

/datum/gear/test2
	name = "fuck you2"
	description = "i'm cool2"
	category = SUITGEAR