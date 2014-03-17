// Theft objectives.
//
// Separated into datums so we can prevent roles from getting certain objectives.

#define THEFT_FLAG_SPECIAL 1

/datum/theft_objective
	var/name=""
	var/typepath=/atom
	var/list/protected_jobs=list()
	var/flags=0

/datum/theft_objective/proc/check_completion(var/datum/mind/owner)
	if(!owner.current)
		return 0
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	for(var/obj/I in all_items) //Check for items
		if(istype(I, typepath))
			//Stealing the cheap autoinjector doesn't count
			if(istype(I, /obj/item/weapon/reagent_containers/hypospray/autoinjector))
				continue
			return 1
	return 0


/datum/theft_objective/antique_laser_gun
	name = "the captain's antique laser gun"
	typepath = /obj/item/weapon/gun/energy/laser/captain
	protected_jobs = list("Captain")

/datum/theft_objective/hand_tele
	name = "a hand teleporter"
	typepath = /obj/item/weapon/hand_tele
	protected_jobs = list("Captain")

/datum/theft_objective/rcd
	name = "an RCD"
	typepath = /obj/item/weapon/rcd
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/rpd
	name = "an RPD"
	typepath = /obj/item/weapon/pipe_dispenser
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/jetpack
	name = "a jetpack"
	typepath = /obj/item/weapon/tank/jetpack

/datum/theft_objective/cap_jumpsuit
	name = "the captain's jumpsuit"
	typepath = /obj/item/clothing/under/rank/captain
	protected_jobs = list("Captain")

/datum/theft_objective/ai
	name = "a functional AI"
	typepath = /obj/item/device/aicard

/datum/theft_objective/magboots
	name = "a pair of magboots"
	typepath = /obj/item/clothing/shoes/magboots
	protected_jobs = list("Station Engineer", "Atmospheric Technician", "Chief Engineer")

/datum/theft_objective/blueprints
	name = "the station blueprints"
	typepath = /obj/item/blueprints
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/voidsuit
	name = "a nasa voidsuit"
	typepath = /obj/item/clothing/suit/space/nasavoid
	protected_jobs = list("Research Director")

/datum/theft_objective/slime_extract
	name = "a sample of slime extract"
	typepath = /obj/item/slime_extract

/datum/theft_objective/corgi
	name = "a piece of corgi meat"
	typepath = /obj/item/weapon/reagent_containers/food/snacks/meat/corgi

/datum/theft_objective/rd_jumpsuit
	name = "the research director's jumpsuit"
	typepath = /obj/item/clothing/under/rank/research_director
	protected_jobs = list("Research Director")

/datum/theft_objective/ce_jumpsuit
	name = "the chief engineer's jumpsuit"
	typepath = /obj/item/clothing/under/rank/chief_engineer
	protected_jobs = list("Chief Engineer")

/datum/theft_objective/cmo_jumpsuit
	name = "the chief medical officer's jumpsuit"
	typepath = /obj/item/clothing/under/rank/chief_medical_officer
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective/hos_jumpsuit
	name = "the head of security's jumpsuit"
	typepath = /obj/item/clothing/under/rank/head_of_security
	protected_jobs = list("Head of Security")

/datum/theft_objective/hop_jumpsuit
	name = "the head of personnel's jumpsuit"
	typepath = /obj/item/clothing/under/rank/head_of_personnel
	protected_jobs = list("Head of Personnel")

/datum/theft_objective/hypospray
	name = "a hypospray"
	typepath = /obj/item/weapon/reagent_containers/hypospray
	protected_jobs = list("Chief Medical Officer")

/datum/theft_objective
	name = "the captain's pinpointer"
	typepath = /obj/item/weapon/pinpointer
	protected_jobs = list("Captain")

/datum/theft_objective
	name = "an ablative armor vest"
	typepath = /obj/item/clothing/suit/armor/laserproof

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
	if(!isliving(owner.current))
		return 0
	var/list/all_items = owner.current.get_contents()
	var/found_amount=0.0
	for(var/obj/item/I in all_items)
		if(istype(I, typepath))
			found_amount += getAmountStolen(I)
	return found_amount >= required_amount

/datum/theft_objective/number/proc/getAmountStolen(var/obj/item/I)
	return I:amount

/datum/theft_objective/number/plasma_gas
	name = "moles of plasma (full tank)"
	typepath = /obj/item/weapon/tank
	min=28
	max=28

/datum/theft_objective/number/plasma_gas/getAmountStolen(var/obj/item/I)
	return I:air_contents:toxins

/datum/theft_objective/number/coins
	name = "credits of coins (in bag)"
	min=1000
	max=5000
	step=500

/datum/theft_objective/number/coins/check_completion(var/datum/mind/owner)
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
/datum/theft_objective/special
	flags = THEFT_FLAG_SPECIAL

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
	flags = THEFT_FLAG_SPECIAL

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