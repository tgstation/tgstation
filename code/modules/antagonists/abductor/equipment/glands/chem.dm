/obj/item/organ/heart/gland/chem
	abductor_hint = "intrinsic pharma-provider. The abductee constantly produces random chemicals inside their bloodstream. They also quickly regenerate toxin damage."
	cooldown_low = 50
	cooldown_high = 50
	uses = -1
	icon_state = "viral"
	mind_control_uses = 3
	mind_control_duration = 1200
	var/static/list/possible_reagents

/obj/item/organ/heart/gland/chem/Initialize(mapload)
	. = ..()
	if(!LAZYLEN(possible_reagents))
		LAZYINITLIST(possible_reagents)
		for(var/reagent_path in subtypesof(/datum/reagent/drug) + subtypesof(/datum/reagent/medicine) + typesof(/datum/reagent/toxin))
			possible_reagents += reagent_path

/obj/item/organ/heart/gland/chem/activate()
	var/chem_to_add = pick(possible_reagents)
	owner.reagents.add_reagent(chem_to_add, 2)
	owner.adjust_tox_loss(-5, forced = TRUE)
	..()
