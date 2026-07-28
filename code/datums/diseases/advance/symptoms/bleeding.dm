/*Anticoagulant
 * Increases stealth
 * No change to resistance
 * Reduces to stage speed
 * Reduces transmissibility
 * Fatal Level
 * Bonus: Adds easybleed trait
*/

/datum/symptom/bleeding
	name = "Anticoagulant"
	desc = "The virus prevents the body from clotting blood. Unnoticable unless the host is bleeding."
	stealth = 1
	resistance = -1
	stage_speed = -3
	transmittable = 0
	severity = 3
	level = 8
	symptom_cure = /datum/reagent/acetaldehyde
	cure_color = "orange"
	threshold_descs = list(
		"Stage Speed 9" = "The host becomes more vulnerable to bleeding wounds.",
		"Stealth 3" = "The symptom remains hidden even while active."
	)
	var/easybleed = FALSE
	var/hidden = FALSE

/datum/symptom/bleeding/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 9)
		easybleed = TRUE
	if(A.totalStealth() >= 3)
		hidden = TRUE

/datum/symptom/bleeding/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_host = A.affected_mob
	for(var/datum/wound/possible_bleeding_wound as anything in carbon_host.all_wounds)
		if(possible_bleeding_wound.blood_flow && !hidden)
			if(4 > A.stage >= 2)
				to_chat(carbon_host, span_warning("Your bleeding wounds start to itch."))
			if(A.stage >= 4)
				to_chat(carbon_host, span_warning("Your bleeding wounds itch like crazy as more blood leaves your body."))
			return

/datum/symptom/bleeding/on_stage_change(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_host = A.affected_mob
	if(A.stage >= 4)
		ADD_TRAIT(carbon_host, TRAIT_BLOOD_FOUNTAIN, DISEASE_TRAIT)
		if(easybleed)
			ADD_TRAIT(carbon_host, TRAIT_EASYBLEED, DISEASE_TRAIT)
		return
	REMOVE_TRAIT(carbon_host, TRAIT_BLOOD_FOUNTAIN, DISEASE_TRAIT)
	REMOVE_TRAIT(carbon_host, TRAIT_EASYBLEED, DISEASE_TRAIT)


/datum/symptom/bleeding/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_host = A.affected_mob
	REMOVE_TRAIT(carbon_host, TRAIT_BLOOD_FOUNTAIN, DISEASE_TRAIT)
	REMOVE_TRAIT(carbon_host, TRAIT_EASYBLEED, DISEASE_TRAIT)

/datum/symptom/hypertension
	name = "Hypertension"
	desc = "Dramatically increases blood pressure, leading to blood vessels bursting open across the host's body."
	stealth = -2
	resistance = -1
	stage_speed = -1
	transmittable = -1
	level = 9
	severity = 6
	symptom_delay = 52.5
	symptom_cure = /datum/reagent/inverse/penthrite
	cure_color = "red"
	threshold_descs = list() // Set in New() so the compiler doesn't complain about non-constant expressions
	var/chems = list(/datum/reagent/toxin/histamine, /datum/reagent/toxin/staminatoxin)
	var/crit_slash = FALSE
	var/adding_chems = FALSE

/datum/symptom/hypertension/New()
	var/list_of_names = list()
	for(var/datum/reagent/poison as anything in chems)
		list_of_names += poison::name
	threshold_descs = list(
		"Resistance 7" = "Additionally synthesizes [english_list(list_of_names)] inside the host.",
		"Stage Speed 9" = "Increases the frequency of inflicted wounds.",
		"Transmission 8" = "Randomly increases the severity of inflicted wounds and quantity of chems synthesized."
	)

/datum/symptom/hypertension/Start(datum/disease/advance/our_disease)
	. = ..()
	if(!.)
		return
	if(our_disease.totalResistance() >= 7)
		adding_chems = TRUE
	if(our_disease.totalStageSpeed() >= 9)
		symptom_delay = 25
	if(our_disease.totalTransmittable() >= 8)
		crit_slash = TRUE

/datum/symptom/hypertension/Activate(datum/disease/advance/our_disease)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/carbon_host = our_disease.affected_mob
	if(our_disease.stage <= 2)
		carbon_host.ominous_nosebleed()
		return
	var/list/bleeding_bodyparts = list()
	for(var/obj/item/bodypart/random_bodypart as anything in carbon_host.get_bodyparts())
		if(random_bodypart.can_bleed())
			bleeding_bodyparts += random_bodypart
	if(bleeding_bodyparts.len == 0)
		return // full borg or borg with organic stumps
	var/obj/item/bodypart/victim_limb = pick(bleeding_bodyparts)
	var/wound_severity = WOUND_SEVERITY_MODERATE
	var/warning = "Your [victim_limb.name] tears itself open!"
	if(our_disease.stage >= 4)
		wound_severity = WOUND_SEVERITY_SEVERE
		if(adding_chems)
			add_reagents(carbon_host)
		if(crit_slash)
			var/chance = 33
			if(our_disease.stage == 5)
				chance = 66
			if(prob(chance))
				wound_severity = WOUND_SEVERITY_CRITICAL
				warning = "The blood vessels in your [victim_limb.name] suddenly rip open!"
				if(adding_chems)
					add_reagents(carbon_host) // Crit slashes add twice as many chems
	if (carbon_host.cause_wound_of_type_and_severity(WOUND_SLASH, victim_limb, wound_severity))
		to_chat(carbon_host, span_userdanger(warning))
		if(wound_severity == WOUND_SEVERITY_CRITICAL)
			carbon_host.emote("scream")

/datum/symptom/hypertension/proc/add_reagents(mob/living/carbon/carbon_host)
	for(var/datum/reagent/reagent_to_add as anything in chems)
		carbon_host.reagents.add_reagent(reagent_to_add, 3)
