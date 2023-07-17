//replaces the anchoring crystal scripture if all 3 crystals have been summoned and protected
/datum/scripture/transform_to_golem
	name = "Ascend Form"
	desc = "Ascend your form to that of a clockwork golem, giving them innate armor, environmental immunity, and faster invoking for most scriptures."
	tip = "Can only be used by humaniod servants."
	button_icon_state = "Spatial Warp"
	power_cost = 300
	invocation_time = 15 SECONDS
	invocation_text = list("My form is weak...", "It must ascend...", "To that of clockwork.")
	cogs_required = 3
	category = SPELLTYPE_SERVITUDE
	unique_locked = TRUE //unlocked after 3 anchoring crystals have been placed

/datum/scripture/transform_to_golem/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(invoker))
		to_chat(invoker, span_warning("This scripture can only be used by humanoid servants."))
		return FALSE

	if(is_species(invoker, /datum/species/golem/clockwork))
		to_chat(invoker, span_notice("You are already a clockwork golem!"))
		return FALSE
	return TRUE

/datum/scripture/transform_to_golem/invoke_success()
	var/mob/living/carbon/human/human_servant = invoker
	human_servant.set_species(/datum/species/golem/clockwork)
	human_servant.update_body(TRUE)
	human_servant.update_mutations_overlay()
