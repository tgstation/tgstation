/datum/bounty/item/virus
	reward = CARGO_CRATE_VALUE * 10
	var/datum/symptom/requested_symptom

/datum/bounty/item/virus/New()
	..()
	requested_symptom = randomize_symptom()
	name = "Virus ([requested_symptom.name])"
	description = "Nanotrasen is interested in a virus with [requested_symptom.name] as a symptom. Central Command will pay handsomely for such a virus dish."
	reward += rand(0, 4) * CARGO_CRATE_VALUE

/datum/bounty/item/virus/proc/randomize_symptom()
	var/datum/symptom/symptom = pick(subtypesof(/datum/symptom))
	if(symptom.restricted)
		symptom = randomize_symptom()
	return symptom

/datum/bounty/item/virus/applies_to(obj/O)
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	if(istype(O, /obj/item/weapon/virusdish))
		var/obj/item/weapon/virusdish/dish = O
		if(accepts_virus(dish.contained_virus))
			return TRUE
	return FALSE

/datum/bounty/item/virus/ship(obj/O)
	if(!applies_to(O))
		return
	shipped_count += 1

/datum/bounty/item/virus/proc/accepts_virus(V)
	var/datum/disease/advance/A = V
	for(var/datum/symptom/symptom in A.symptoms)
		if(symptom.name == requested_symptom.name)
			return TRUE
	return FALSE
