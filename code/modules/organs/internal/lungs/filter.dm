// Lung upgrade
/datum/organ/internal/lungs/filter
	name = "advanced lungs"
	removed_type = /obj/item/organ/lungs/filter

	gasses = list()
	var/list/intake_settings=list(
		"oxygen" = list(
			new /datum/lung_gas/metabolizable("oxygen",            min_pp=16, max_pp=280),
			new /datum/lung_gas/waste("carbon_dioxide",            max_pp=10),
			new /datum/lung_gas/toxic("toxins",                    max_pp=5, max_pp_mask=0, reagent_id="plasma", reagent_mult=0.1),
			new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=1, min_para_pp=5, min_sleep_pp=10),
		),
		"nitrogen" = list(
			new /datum/lung_gas/metabolizable("nitrogen",          min_pp=16, max_pp=280),
			new /datum/lung_gas/waste("carbon_dioxide",            max_pp=10), // I guess? Ideally it'd be some sort of nitrogen compound.  Maybe N2O?
			new /datum/lung_gas/toxic("oxygen",                    max_pp=0.5, max_pp_mask=0, reagent_id="oxygen", reagent_mult=0.1),
			new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=1, min_para_pp=5, min_sleep_pp=10),
		),
		"plasma" = list(
			new /datum/lung_gas/metabolizable("toxins", min_pp=16, max_pp=280),
			new /datum/lung_gas/waste("oxygen",         max_pp=10),
			new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=1, min_para_pp=5, min_sleep_pp=10),
		)
	)

/datum/organ/internal/lungs/filter/CanInsert(var/mob/living/carbon/human/H, var/mob/surgeon=null, var/quiet=0)
	if(!(H.species.breath_type in intake_settings))
		if(surgeon)
			surgeon << "<span class='warning'>You read the compatibility list on the back of the lung and find that it won't work on this species.</span>"
		return 0
	return 1

/datum/organ/internal/lungs/filter/Insert(var/mob/living/carbon/human/H, var/mob/surgeon=null, var/quiet=0)
	if(!quiet)
		H.visible_message("<span class='info'>\The [name] clicks as it adjusts to their body's metabolism.</span>", "<span class='info'>You feel something click in your chest.</span>", "<span class='warning'>You hear a click.</span>")
	gasses=intake_settings[H.species.breath_type]
	return 1
