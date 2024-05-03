/datum/action/cooldown/borer/upgrade_stat
	name = "Become Stronger"
	button_icon_state = "level"
	stat_evo_points = 1
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Lets you become stronger in exchange for an evolution point\n\
	Your maximum health, regeneration, chemical storage and chemical regeneration will all be faster\n\
	"

/datum/action/cooldown/borer/upgrade_stat/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/basic/cortical_borer/cortical_owner = owner

	cortical_owner.stat_evolution -= stat_evo_points
	cortical_owner.maxHealth += cortical_owner.health_per_level
	cortical_owner.health_regen += cortical_owner.health_regen_per_level
	cortical_owner.max_chemical_storage += cortical_owner.chem_storage_per_level
	cortical_owner.chemical_regen += cortical_owner.chem_regen_per_level
	cortical_owner.level += 1

	cortical_owner.human_host.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10 * cortical_owner.host_harm_multiplier, maximum = BRAIN_DAMAGE_SEVERE)

	cortical_owner.human_host.adjust_eye_blur(6 SECONDS * cortical_owner.host_harm_multiplier) //about 12 seconds' worth by default
	to_chat(cortical_owner, span_notice("You have grown!"))
	to_chat(cortical_owner.human_host, span_warning("You feel a sharp pressure in your head!"))
	StartCooldown()
