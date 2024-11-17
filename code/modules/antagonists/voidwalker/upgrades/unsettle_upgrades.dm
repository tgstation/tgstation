#define VOIDWLAKER_UPGRADE_UNSETTLE "voidwalker_unsettle_upgrade"

/datum/voidwalker_upgrades_tree/unsettle_upgrades
	name = "Unsettle"
	desc = /datum/action/cooldown/spell/pointed/unsettle::desc
	icon_state = /datum/action/cooldown/spell/pointed/unsettle::button_icon_state
	tree_type = VOIDWLAKER_UPGRADE_UNSETTLE

/datum/voidwalker_upgrade_branch/unsettle
	branch_type = VOIDWLAKER_UPGRADE_UNSETTLE
	var/datum/action/cooldown/spell/pointed/unsettle/unsettle_spell

/datum/voidwalker_upgrade_branch/unsettle/try_research()
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	unsettle_spell = locate() in i_know_you_is_human.actions
	if(isnull(unsettle_spell))
		to_chat(i_know_you_is_human, span_warning("You don't have unsettle to upgrade it!"))
		return
	return ..()

/datum/voidwalker_upgrade_branch/unsettle/cooldown/tier1
	name = "Refraction I"
	desc = "Increases stun time and reduces cast time by 2 seconds."

/datum/voidwalker_upgrade_branch/unsettle/cooldown/tier1/upgrade_effect()
	. = ..()
	unsettle_spell.stare_time -= 2 SECONDS
	unsettle_spell.stun_time += 2 SECONDS

/datum/voidwalker_upgrade_branch/unsettle/cooldown/tier2
	name = "Jubilation"
	desc = "Speeds up by 6 seconds after using a spell"
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/unsettle/cooldown/tier1::name

/datum/voidwalker_upgrade_branch/unsettle/cooldown/tier2/upgrade_effect()
	. = ..()
	unsettle_spell.give_speed_modifier = TRUE

/datum/voidwalker_upgrade_branch/unsettle/cooldown/tier3
	name = "Refraction II"
	desc = "Increases stun time and reduces cast time by 2 seconds."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/unsettle/cooldown/tier2::name

/datum/voidwalker_upgrade_branch/unsettle/cooldown/tier3/upgrade_effect()
	. = ..()
	unsettle_spell.stare_time -= 2 SECONDS
	unsettle_spell.stun_time += 2 SECONDS

/datum/voidwalker_upgrade_branch/unsettle/effects/tier1
	name = "Unsettle Cooldown I"
	desc = "Reduces cooldown time by 4 seconds"

/datum/voidwalker_upgrade_branch/unsettle/effects/tier1/upgrade_effect()
	. = ..()
	unsettle_spell.cooldown_time -= 4 SECONDS

/datum/voidwalker_upgrade_branch/unsettle/effects/tier2
	name = "Unsettle Cooldown II"
	desc = "Reduces cooldown time by 4 seconds"
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/unsettle/effects/tier1::name

/datum/voidwalker_upgrade_branch/unsettle/effects/tier2/upgrade_effect()
	. = ..()
	unsettle_spell.cooldown_time -= 4 SECONDS

/datum/voidwalker_upgrade_branch/unsettle/effects/tier3
	name = "Devastation"
	desc = "When using a spell, all targets within a 2 radius of the victim receive a knockdown equal to half the paralysis time and half the stamina damage."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/unsettle/effects/tier2::name

/datum/voidwalker_upgrade_branch/unsettle/effects/tier3/upgrade_effect()
	. = ..()
	unsettle_spell.aoe_range += 2

#undef VOIDWLAKER_UPGRADE_UNSETTLE
