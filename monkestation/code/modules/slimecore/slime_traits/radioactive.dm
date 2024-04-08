/datum/slime_trait/radioactive
	name = "Radioactive"
	desc = "Emits violent rays of radiation."
	menu_buttons = list(ENVIRONMENT_CHANGE, DANGEROUS_CHANGE)

/datum/slime_trait/radioactive/on_add(mob/living/basic/slime/parent)
	. = ..()
	parent.add_filter("radio_slime", 10, outline_filter(12, "#39ff1430"))
	parent.AddComponent(/datum/component/radioactive_emitter, cooldown_time = 5 SECONDS, range = 3, threshold = RAD_MEDIUM_INSULATION)

/datum/slime_trait/radioactive/on_remove(mob/living/basic/slime/parent)
	. = ..()
	qdel(parent.GetComponent(/datum/component/radioactive_emitter))
