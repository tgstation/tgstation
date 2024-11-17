#define VOIDWLAKER_UPGRADE_THROUGH_THE_VOID "voidwalker_through_the_void_upgrade"

/datum/voidwalker_upgrades_tree/through_the_void
	name = "Through The Void"
	desc = /datum/action/cooldown/spell/pointed/through_the_void::desc
	icon_state = /datum/action/cooldown/spell/pointed/through_the_void::button_icon_state
	unlocked = FALSE
	spell_to_give_on_unlock = /datum/action/cooldown/spell/pointed/through_the_void
	tree_type = VOIDWLAKER_UPGRADE_THROUGH_THE_VOID

/datum/voidwalker_upgrade_branch/through_the_void
	branch_type = VOIDWLAKER_UPGRADE_THROUGH_THE_VOID
	var/datum/action/cooldown/spell/pointed/through_the_void/through_the_void_spell

/datum/voidwalker_upgrade_branch/through_the_void/try_research()
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	through_the_void_spell = locate() in i_know_you_is_human.actions
	if(isnull(through_the_void_spell))
		to_chat(i_know_you_is_human, span_warning("You don't have void symbol to upgrade it!"))
		return
	return ..()

/datum/voidwalker_upgrade_branch/through_the_void/horror/tier1
	name = "Through The Void Cooldown I"
	desc = "Reduces cast time by 5 seconds."

/datum/voidwalker_upgrade_branch/through_the_void/horror/tier1/upgrade_effect()
	. = ..()
	through_the_void_spell.cooldown_time -= 5 SECONDS

/datum/voidwalker_upgrade_branch/through_the_void/horror/tier2
	name = "Horror I"
	desc = "Slows down the target when you teleport to."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/through_the_void/horror/tier1::name

/datum/voidwalker_upgrade_branch/through_the_void/horror/tier2/upgrade_effect()
	. = ..()
	through_the_void_spell.give_slowdown_modifier = TRUE

/datum/voidwalker_upgrade_branch/through_the_void/horror/tier3
	name = "Horror II"
	desc = "Creates 1-3 illusions near you on teleport. Number depends on the people nearby."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/through_the_void/horror/tier2::name

/datum/voidwalker_upgrade_branch/through_the_void/horror/tier3/upgrade_effect()
	. = ..()
	through_the_void_spell.make_illusions = TRUE

/datum/voidwalker_upgrade_branch/through_the_void/cooldown/tier2
	name = "Impatience"
	desc = "Removes cast delay."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/through_the_void/horror/tier1::name

/datum/voidwalker_upgrade_branch/through_the_void/cooldown/tier2/upgrade_effect()
	. = ..()
	through_the_void_spell.cast_delay = 0

/datum/voidwalker_upgrade_branch/through_the_void/cooldown/tier3
	name = "Through The Void Cooldown II"
	desc = "Reduces cast time by 10 seconds."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/through_the_void/cooldown/tier2::name

/datum/voidwalker_upgrade_branch/through_the_void/cooldown/tier3/upgrade_effect()
	. = ..()
	through_the_void_spell.cooldown_time -= 10 SECONDS

#undef VOIDWLAKER_UPGRADE_THROUGH_THE_VOID
