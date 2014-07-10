// Theft objectives.
//
// Separated into datums so we can prevent roles from getting certain objectives.

#define THEFT_SPECIAL         1

/datum/theft_objective
	var/name=""
	var/typepath=/atom
	var/list/protected_jobs=list()

	// Permissible areas for the items to be in.
	// No areas = all areas permitted.
	var/list/areas = list()
	var/flags=0

/datum/theft_objective/proc/get_contents(var/obj/O)
	var/list/L = list()

	if(istype(O,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S=O
		L += S.return_inv()

	else if(istype(O,/obj/item/weapon/gift))
		var/obj/item/weapon/gift/G = O
		L += G.gift
		if(istype(G.gift, /obj/item/weapon/storage))
			L += get_contents(G.gift)

	else if(istype(O,/obj/item/smallDelivery))
		var/obj/item/smallDelivery/D = O
		L += D.wrapped
		if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
			L += get_contents(D.wrapped)
	return L

/datum/theft_objective/proc/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return 0
	var/list/all_items = list()
	if(isliving(owner.current))
		all_items = owner.current.get_contents()
	if(areas.len)
		for(var/areatype in areas)
			var/area/area = locate(areatype)
			for(var/obj/O in area)
				all_items += O
				all_items += get_contents(O)
	if(all_items.len)
		for(var/obj/I in all_items) //Check for items
			if(istype(I, typepath))
				//Stealing the cheap autoinjector doesn't count
				if(istype(I, /obj/item/weapon/reagent_containers/hypospray/autoinjector))
					continue
				if(areas.len)
					if(!is_type_in_list(get_area_master(I),areas))
						continue
				return 1
	return 0


/datum/theft_objective/traitor/antique_laser_gun
	name = "the captain's antique laser gun"
	typepath = /obj/item/weapon/gun/energy/laser/captain
	protected_jobs = list("Captain")

/datum/theft_objective/traitor/hand_tele
	name = "a hand teleporter"
	typepath = /obj/item/weapon/hand_tele
	protected_jobs = list("Captain")

/datum/theft_objective/traitor/rcd
	name = "an RCD"
	typepath = /obj/item/weapon/rcd
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/traitor/rpd
	name = "an RPD"
	typepath = /obj/item/weapon/pipe_dispenser
	protected_jobs = list("Chief Engineer", "Atmospherics Technician")

/datum/theft_objective/traitor/jetpack
	name = "a jetpack"
	typepath = /obj/item/weapon/tank/jetpack

/datum/theft_objective/traitor/cap_jumpsuit
	name = "the captain's jumpsuit"
	typepath = /obj/item/clothing/under/rank/captain
	protected_jobs = list("Captain")

/datum/theft_objective/traitor/ai
	name = "a functional AI"
	typepath = /obj/item/device/aicard


/datum/theft_objective/traitor/magboots
	name = "a pair of advanced magboots"
	typepath = /obj/item/clothing/shoes/magboots/elite
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/traitor/blueprints
	name = "the station blueprints"
	typepath = /obj/item/blueprints
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/traitor/voidsuit
	name = "a nasa voidsuit"
	typepath = /obj/item/clothing/suit/space/nasavoid
	protected_jobs = list("Research Director")

/datum/theft_objective/traitor/slime_extract
	name = "a sample of slime extract"
	typepath = /obj/item/slime_extract
	protected_jobs = list("Research Director", "Scientist")

/datum/theft_objective/traitor/corgi
	name = "a piece of corgi meat"
	typepath = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi

/datum/theft_objective/traitor/rd_jumpsuit
	name = "the research director's jumpsuit"
	typepath = /obj/item/clothing/under/rank/research_director
	protected_jobs = list("Research Director")

/datum/theft_objective/traitor/ce_jumpsuit
	name = "the chief engineer's jumpsuit"
	typepath = /obj/item/clothing/under/rank/chief_engineer
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/traitor/cmo_jumpsuit
	name = "the chief medical officer's jumpsuit"
	typepath = /obj/item/clothing/under/rank/chief_medical_officer
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/traitor/hos_jumpsuit
	name = "the head of security's jumpsuit"
	typepath = /obj/item/clothing/under/rank/head_of_security
	protected_jobs = list("Head of Security")

/datum/theft_objective/traitor/hop_jumpsuit
	name = "the head of personnel's jumpsuit"
	typepath = /obj/item/clothing/under/rank/head_of_personnel
	protected_jobs = list("Head of Personnel")

/datum/theft_objective/traitor/hypospray
	name = "a hypospray"
	typepath = /obj/item/weapon/reagent_containers/hypospray
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/traitor/pinpointer
	name = "the captain's pinpointer"
	typepath = /obj/item/weapon/pinpointer
	protected_jobs = list("Captain")

/datum/theft_objective/traitor/ablative
	name = "an ablative armor vest"
	typepath = /obj/item/clothing/suit/armor/laserproof
	protected_jobs = list("Head of Security", "Warden")

/datum/theft_objective/number
	var/min=0
	var/max=0
	var/step=1

	var/required_amount=0

/datum/theft_objective/number/New()
	if(min==max)
		required_amount=min
	else
		var/lower=min/step
		var/upper=min/step
		required_amount=rand(lower,upper)*step
	name = "[required_amount] [name]"

/datum/theft_objective/number/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return 0
	var/list/all_items = list()
	if(isliving(owner.current))
		all_items = owner.current.get_contents()
	if(areas.len)
		for(var/areatype in areas)
			var/area/area = locate(areatype)
			for(var/obj/O in area)
				all_items += O
				all_items += get_contents(O)
	if(all_items.len)
		var/found_amount = 0
		for(var/obj/I in all_items) //Check for items
			if(istype(I, typepath))
				//Stealing the cheap autoinjector doesn't count
				if(istype(I, /obj/item/weapon/reagent_containers/hypospray/autoinjector))
					continue
				if(areas.len)
					if(!is_type_in_list(get_area_master(I),areas))
						continue
				found_amount += getAmountStolen(I)
		return found_amount >= required_amount
	return 0

/datum/theft_objective/number/proc/getAmountStolen(var/obj/item/I)
	return I:amount

/datum/theft_objective/number/traitor/plasma_gas
	name = "moles of plasma (full tank)"
	typepath = /obj/item/weapon/tank
	min=28
	max=28

/datum/theft_objective/number/traitor/plasma_gas/getAmountStolen(var/obj/item/I)
	return I:air_contents:toxins

/datum/theft_objective/number/traitor/coins
	name = "credits of coins (in bag)"
	min=1000
	max=5000
	step=500

/datum/theft_objective/number/traitor/coins/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	var/found_amount=0.0
	for(var/obj/item/weapon/moneybag/B in all_items)
		if(B)
			for(var/obj/item/weapon/coin/C in B)
				found_amount += C.credits
	return found_amount >= required_amount


////////////////////////////////
// SPECIAL OBJECTIVES
////////////////////////////////
/datum/objective/steal/special
	target_category = "special"

/datum/theft_objective/special/nuke_gun
	name = "nuclear gun"
	typepath = /obj/item/weapon/gun/energy/gun/nuclear

/datum/theft_objective/special/diamond_drill
	name = "diamond drill"
	typepath = /obj/item/weapon/pickaxe/diamonddrill

/datum/theft_objective/special/boh
	name = "bag of holding"
	typepath = /obj/item/weapon/storage/backpack/holding

/datum/theft_objective/special/hyper_cell
	name = "hyper-capacity cell"
	typepath = /obj/item/weapon/cell/hyper

/datum/theft_objective/number/special
	flags = THEFT_SPECIAL

/datum/theft_objective/number/special/diamonds
	name = "diamonds"
	typepath = /obj/item/stack/sheet/mineral/diamond
	min=5
	max=10
	step=5

/datum/theft_objective/number/special/gold
	name = "gold bars"
	typepath = /obj/item/stack/sheet/mineral/gold
	min=10
	max=50
	step=10

/datum/theft_objective/number/special/uranium
	name = "refined uranium sheets"
	typepath = /obj/item/stack/sheet/mineral/uranium
	min=10
	max=30
	step=5