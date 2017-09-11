//this datum contains a list of all datum organs
//organs were originally a subtype of this ornd datum, but the new() proc created infinite loops so I split them

/datum/ornd
	var/name = "ORND datum"
	var/list/datumOrgans = list()

/datum/ornd/New()
	for(var/S in subtypesof(/datum/organ))
		datumOrgans += new S


//this datum stores the basic organ types with their vars that can be modified.
//the ornd console is used to create instances of these datums with modified vars.
//how much each var can be modified is based on research.

/datum/organ
	var/name = "organ datum"
	var/list/traits = list() //special traits that can be applied to any organ
	var/obj/item/organ/product //set this to the type of organ
	var/cost = 30 //cost in units of synthflesh to produce
	var/list/modVars = list()

/datum/organ/proc/datumToOrgan()
	var/obj/item/organ/dOrgan = new product
	for(var/V in dOrgan.vars)
		if("[V]" in modVars)
			dOrgan.V = modVars["[V]"]

	return dOrgan

/datum/organ/liver
	name = "synthetic liver"
	product = /obj/item/organ/liver
	cost = 50 //liver has some of the most useful organ abilities
	modVars = list("alcohol_tolerance" = 0.005, "health" = 100, "toxTolerance" = 3, "toxLethality" = 0.5, "filterToxins" = TRUE)

/datum/organ/heart
	name = "synthetic heart"
	product = /obj/item/organ/heart

/datum/organ/ears
	name = "synthetic ears"
	product = /obj/item/organ/ears
	cost = 20
	modVars = list("bang_protect" = 0)

/datum/organ/stomach //todo: add vars to increase amount of food you can eat and make it take longer to starve
	name = "synthetic stomach"
	product = /obj/item/organ/stomach
	cost = 20
	modVars = list("disgust_metabolism" = 1)

/datum/organ/lungs
	name = "synthetic lungs"
	product = /obj/item/organ/lungs
	cost = 60 //a lot because enough research can potentially make oxygen tanks last forever/be resistant to toxins
	modVars = list("safe_oxygen_min" = 16, "safe_oxygen_max" = 0, "safe_nitro_min" = 0, "safe_nitro_max" = 0, "safe_co2_min" = 0, "safe_co2_max" = 10, "safe_toxins_min" = 0, "safe_toxins_max" = 0.05)

/datum/organ/eyes
	name = "synthetic eyes"
	modVars = list("see_in_dark" = 2, "flash_protect" = 0)

