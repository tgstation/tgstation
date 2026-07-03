/obj/item/organ/brain
	var/death_trauma_applied = FALSE

/obj/item/organ/brain/Initialize(mapload)
	. = ..()
	if(CONFIG_GET(flag/brain_permanent_traumas))
		decay_factor = STANDARD_ORGAN_DECAY * CONFIG_GET(number/brain_decay_rate)

/datum/config_entry/flag/brain_permanent_traumas
	default = FALSE

/datum/config_entry/number/brain_decay_rate
	integer = FALSE
	default = 0.5

/obj/item/reagent_containers/hypospray/medipen/survival
	list_reagents = list( /datum/reagent/medicine/epinephrine = 7, /datum/reagent/medicine/c2/aiuri = 7, /datum/reagent/medicine/c2/libital = 7, /datum/reagent/medicine/leporazine = 6, /datum/reagent/toxin/formaldehyde = 3)

/obj/item/reagent_containers/hypospray/medipen/survival/luxury
	list_reagents = list(/datum/reagent/medicine/salbutamol = 9, /datum/reagent/medicine/c2/penthrite = 9, /datum/reagent/medicine/oxandrolone = 9, /datum/reagent/medicine/sal_acid = 10, /datum/reagent/medicine/omnizine = 10, /datum/reagent/medicine/leporazine = 10, /datum/reagent/toxin/formaldehyde = 3)
