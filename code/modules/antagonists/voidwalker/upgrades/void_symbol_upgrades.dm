#define VOIDWLAKER_UPGRADE_VOID_SYMBOL "voidwalker_void_symbol_upgrade"

/datum/voidwalker_upgrades_tree/void_symbol
	name = "Void Symbol"
	desc = /datum/action/cooldown/spell/pointed/void_symbol::desc
	icon_state = /datum/action/cooldown/spell/pointed/void_symbol::button_icon_state
	unlocked = FALSE
	spell_to_give_on_unlock = /datum/action/cooldown/spell/pointed/void_symbol
	tree_type = VOIDWLAKER_UPGRADE_VOID_SYMBOL

/datum/voidwalker_upgrade_branch/void_symbol
	branch_type = VOIDWLAKER_UPGRADE_VOID_SYMBOL
	var/datum/action/cooldown/spell/pointed/void_symbol/void_symbol_spell

/datum/voidwalker_upgrade_branch/void_symbol/try_research()
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	void_symbol_spell = locate() in i_know_you_is_human.actions
	if(isnull(void_symbol_spell))
		to_chat(i_know_you_is_human, span_warning("You don't have void symbol to upgrade it!"))
		return
	return ..()

/datum/voidwalker_upgrade_branch/void_symbol/influence/tier1
	name = "Influence I"
	desc = "+1 Max void blessed person that you can make."

/datum/voidwalker_upgrade_branch/void_symbol/influence/tier1/upgrade_effect()
	. = ..()
	void_symbol_spell.max_blessed += 1

/datum/voidwalker_upgrade_branch/void_symbol/influence/tier2
	name = "Influence II"
	desc = "+1 Max void blessed person that you can make."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/void_symbol/influence/tier1::name

/datum/voidwalker_upgrade_branch/void_symbol/influence/tier2/upgrade_effect()
	. = ..()
	void_symbol_spell.max_blessed += 1

/datum/voidwalker_upgrade_branch/void_symbol/influence/tier3
	name = "Influence III"
	desc = "+2 Max void blessed person that you can make."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/void_symbol/influence/tier2::name

/datum/voidwalker_upgrade_branch/void_symbol/influence/tier3/upgrade_effect()
	. = ..()
	void_symbol_spell.max_blessed += 2

/datum/voidwalker_upgrade_branch/void_symbol/effects/tier2
	name = "Inheritance"
	desc = "All void blessed followers get unsettle spell."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/void_symbol/influence/tier1::name

/datum/voidwalker_upgrade_branch/void_symbol/effects/tier2/upgrade_effect()
	. = ..()
	var/datum/antagonist/voidwalker/void_boss = locate() in owner_mind.antag_datums
	if(isnull(void_boss))
		return
	void_boss.unsettle_to_blessed = TRUE
	for(var/mob/living/carbon/human/my_voided_friend in void_symbol_spell.blessed_peoples)
		var/datum/action/cooldown/spell/pointed/unsettle/unsettle_spell = new /datum/action/cooldown/spell/pointed/unsettle (my_voided_friend)
		unsettle_spell.Grant(my_voided_friend)

/datum/voidwalker_upgrade_branch/void_symbol/effects/tier3
	name = "Promotion"
	desc = "Targets kidnapped by void blessed followers will give 2 points instead of 1."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/void_symbol/effects/tier2::name

/datum/voidwalker_upgrade_branch/void_symbol/effects/tier3/upgrade_effect()
	. = ..()
	var/datum/antagonist/voidwalker/void_boss = locate() in owner_mind.antag_datums
	if(isnull(void_boss))
		return
	void_boss.points_recieved_from_void_blessed++

#undef VOIDWLAKER_UPGRADE_VOID_SYMBOL
