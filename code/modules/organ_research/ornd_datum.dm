//this datum stores the basic organ types with their vars that can be modified.
//the ornd console is used to create instances of these datums with modified vars.
//how much each var can be modified is based on research.

/datum/ornd
	var/name = "ORND datum"
	var/list/traits = list() //special traits that can be applied to any organ
	var/obj/item/organ/product //set this to the type of organ
	var/cost = 30 //cost in units of synthflesh to produce
	var/list/datumOrgans = list()

/datum/ornd/New()
	for(var/S in subtypesof(src))
		datumOrgans += new S

/datum/ornd/liver
	name = "synthetic liver"
	product = /obj/item/organ/liver
	cost = 50 //liver has some of the most useful organ abilities
	var/alcohol_tolerance = 0.005
	var/health = 100
	var/toxTolerance = 3//maximum amount of toxins the liver can just shrug off
	var/toxLethality = 0.5//affects how much damage toxins do to the liver
	var/filterToxins = TRUE //whether to filter toxins

/datum/ornd/heart
	name = "synthetic heart"
	product = /obj/item/organ/heart

/datum/ornd/ears
	name = "synthetic ears"
	product = /obj/item/organ/ears
	cost = 20
	var/bang_protect = 0 //Resistance against loud noises

/datum/ornd/stomach //todo: add vars to increase amount of food you can eat and make it take longer to starve
	name = "synthetic stomach"
	product = /obj/item/organ/stomach
	cost = 20
	var/disgust_metabolism = 1

/datum/ornd/lungs
	name = "synthetic lungs"
	product = /obj/item/organ/lungs
	cost = 60 //a lot because enough research can potentially make oxygen tanks last forever/be resistant to toxins
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = 0.05
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas.

/datum/ornd/vocal_cords
	name = "synthetic vocal cords"
	product = /obj/item/organ/vocal_cords
	cost = 35
	var/list/spans = list()

/datum/ornd/eyes
	name = "synthetic eyes"
	var/see_in_dark = 2
	var/flash_protect = 0

