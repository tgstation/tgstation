/datum/bounty/virus
	reward = CARGO_CRATE_VALUE * 10
	var/shipped = FALSE
	var/stat_value = 0
	var/stat_name = ""

/datum/bounty/virus/New()
	..()
	stat_value = rand(4, 11)
	if(rand(3) == 1)
		stat_value *= -1
	name = "Virus ([stat_name] of [stat_value])"
	description = "Nanotrasen is interested in a virus with a [stat_name] stat of exactly [stat_value]. Central Command will pay handsomely for such a virus."
	reward += rand(0, 4) * CARGO_CRATE_VALUE

/datum/bounty/virus/can_claim()
	return ..() && shipped

/datum/bounty/virus/applies_to(obj/export)
	if(shipped)
		return FALSE
	if(export.flags_1 & HOLOGRAM_1)
		return FALSE
	if(!istype(export, /obj/item/reagent_containers || !export.reagents || !export.reagents.reagent_list))
		return FALSE
	var/datum/reagent/blood/blud = locate() in export.reagents.reagent_list
	if(!blud)
		return FALSE
	for(var/datum/disease/advance/virus in blud.get_diseases())
		if(accepts_virus(virus))
			return TRUE
	return FALSE

/datum/bounty/virus/ship(obj/export)
	if(!applies_to(export))
		return FALSE
	shipped = TRUE
	return TRUE

/datum/bounty/virus/proc/accepts_virus(virus)
	return TRUE

/datum/bounty/virus/resistance
	stat_name = "resistance"

/datum/bounty/virus/resistance/accepts_virus(datum/disease/advance/virus)
	return virus.totalResistance() == stat_value

/datum/bounty/virus/stage_speed
	stat_name = "stage speed"

/datum/bounty/virus/stage_speed/accepts_virus(datum/disease/advance/virus)
	return virus.totalStageSpeed() == stat_value

/datum/bounty/virus/stealth
	stat_name = "stealth"

/datum/bounty/virus/stealth/accepts_virus(datum/disease/advance/virus)
	return virus.totalStealth() == stat_value

/datum/bounty/virus/transmit
	stat_name = "transmissible"

/datum/bounty/virus/transmit/accepts_virus(datum/disease/advance/virus)
	return virus.totalTransmittable() == stat_value

