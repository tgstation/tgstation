#define VOIDWLAKER_UPGRADE_SPACE_RELOCATION "voidwalker_space_relocation_upgrade"

/datum/voidwalker_upgrades_tree/space_relocation
	name = "Space Relocation"
	desc = /datum/action/cooldown/spell/space_relocation::desc
	icon_state = /datum/action/cooldown/spell/space_relocation::button_icon_state
	unlocked = FALSE
	spell_to_give_on_unlock = /datum/action/cooldown/spell/space_relocation
	tree_type = VOIDWLAKER_UPGRADE_SPACE_RELOCATION

/datum/voidwalker_upgrade_branch/space_relocation
	branch_type = VOIDWLAKER_UPGRADE_SPACE_RELOCATION
	var/datum/action/cooldown/spell/space_relocation/space_relocation_spell

/datum/voidwalker_upgrade_branch/space_relocation/try_research()
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	space_relocation_spell = locate() in i_know_you_is_human.actions
	if(isnull(space_relocation_spell))
		to_chat(i_know_you_is_human, span_warning("You don't have void symbol to upgrade it!"))
		return
	return ..()

/datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier1
	name = "Space Relocation Cooldown I"
	desc = "Increases spell effect duration by 5 seconds and cooldown by 10."

/datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier1/upgrade_effect()
	. = ..()
	space_relocation_spell.cooldown_time += 10 SECONDS

/datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier2
	name = "Economy"
	desc = "You can use spell again to deactivate it early and half cooldown timer."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier1::name

/datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier2/upgrade_effect()
	. = ..()
	space_relocation_spell.can_refund = TRUE

/datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier3
	name = "Space Relocation Cooldown II"
	desc = "Increases spell effect duration by 10 seconds and cooldown by 20."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier2::name

/datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier3/upgrade_effect()
	. = ..()
	space_relocation_spell.cooldown_time += 20 SECONDS

/datum/voidwalker_upgrade_branch/space_relocation/expansion/tier2
	name = "Dissolution"
	desc = "Makes all windows, walls and doors in range translucent allowing everyone to pass through them."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/space_relocation/cooldown/tier1::name

/datum/voidwalker_upgrade_branch/space_relocation/expansion/tier2/upgrade_effect()
	space_relocation_spell.dissolution = TRUE

/datum/voidwalker_upgrade_branch/space_relocation/expansion/tier3
	name = "Expansion"
	desc = "Icreases space creating around to 5x5."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/space_relocation/expansion/tier2::name

/datum/voidwalker_upgrade_branch/space_relocation/expansion/tier3/upgrade_effect()
	. = ..()
	space_relocation_spell.aoe_range += 1

#undef VOIDWLAKER_UPGRADE_SPACE_RELOCATION
