#define VOIDWLAKER_UPGRADE_APPENDAGE "voidwalker_appendage_upgrade"

/datum/voidwalker_upgrades_tree/appendage_upgrades
	name = "Void Eater Evolution"
	desc = "Strengthens your Void Eater, making it more combat-ready and useful."
	icon_state = "up_appendage"
	tree_type = VOIDWLAKER_UPGRADE_APPENDAGE

/datum/voidwalker_upgrade_branch/appendage
	branch_type = VOIDWLAKER_UPGRADE_APPENDAGE
	var/obj/item/void_eater/owner_blade

/datum/voidwalker_upgrade_branch/appendage/try_research()
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	owner_blade = istype(i_know_you_is_human.get_active_held_item(), /obj/item/void_eater) ? i_know_you_is_human.get_active_held_item() : i_know_you_is_human.get_inactive_held_item()
	if(isnull(owner_blade) || !istype(owner_blade, /obj/item/void_eater))
		to_chat(i_know_you_is_human, span_warning("You don't have void eater to upgrade it!"))
		return
	return ..()

/datum/voidwalker_upgrade_branch/appendage/damage/tier1
	name = "Bloodiness I"
	desc = "Increases Void Eater damage +5 and bare wound bonus +20."

/datum/voidwalker_upgrade_branch/appendage/damage/tier1/upgrade_effect()
	. = ..()
	owner_blade.force += 5
	owner_blade.base_force += 5
	owner_blade.bare_wound_bonus += 20

/datum/voidwalker_upgrade_branch/appendage/damage/tier2
	name = "Bloodiness II"
	desc = "Increases Void Eater damage +5 and bare wound bonus +10. Your attacks now heals you +20% of caused damage."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/appendage/damage/tier1::name

/datum/voidwalker_upgrade_branch/appendage/damage/tier2/upgrade_effect()
	. = ..()
	owner_blade.force += 5
	owner_blade.base_force += 5
	owner_blade.bare_wound_bonus += 10
	owner_blade.vampirism += 20

/datum/voidwalker_upgrade_branch/appendage/damage/tier3
	name = "Glass Appendage"
	desc = "Increases Void Eater damage +15 but also increases damage lose per hit at x10. Increases minimum damage +5."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/appendage/damage/tier2::name

/datum/voidwalker_upgrade_branch/appendage/damage/tier3/upgrade_effect()
	. = ..()
	owner_blade.force += 15
	owner_blade.base_force += 15
	owner_blade.damage_loss_per_hit *= 10
	owner_blade.damage_minimum += 5

/datum/voidwalker_upgrade_branch/appendage/defence
	branch_type = VOIDWLAKER_UPGRADE_APPENDAGE

/datum/voidwalker_upgrade_branch/appendage/defence/tier1
	name = "Protection"
	desc = "Gives you +25% basic block chance"

/datum/voidwalker_upgrade_branch/appendage/defence/tier1/upgrade_effect()
	owner_blade.base_block += 25
	owner_blade.block_chance += 25

/datum/voidwalker_upgrade_branch/appendage/defence/tier2
	name = "Transfusion I"
	desc = "In addition to reducing damage, each hit also increases block chance +5%(Max 80%)"
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/appendage/defence/tier1::name

/datum/voidwalker_upgrade_branch/appendage/defence/tier2/upgrade_effect()
	owner_blade.block_chance_increase_per_hit += 5

/datum/voidwalker_upgrade_branch/appendage/defence/tier3
	name = "Transfusion II"
	desc = "In addition to reducing damage, each hit also increases block chance +5%(Max 80%). Gives you +15% basic block chance"
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/appendage/defence/tier2::name

/datum/voidwalker_upgrade_branch/appendage/defence/tier3/upgrade_effect()
	owner_blade.block_chance_increase_per_hit += 5
	owner_blade.base_block += 15
	owner_blade.block_chance += 15

/datum/voidwalker_upgrade_branch/appendage/piercing
	branch_type = VOIDWLAKER_UPGRADE_APPENDAGE

/datum/voidwalker_upgrade_branch/appendage/piercing/tier1
	name = "Accuracy I"
	desc = "Increases armour penetration +25% and wound bonus +30%."

/datum/voidwalker_upgrade_branch/appendage/piercing/tier1/upgrade_effect()
	owner_blade.armour_penetration += 25
	owner_blade.wound_bonus += 30

/datum/voidwalker_upgrade_branch/appendage/piercing/tier2
	name = "Silence"
	desc = "Attacks temporarily mute the target."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/appendage/piercing/tier1::name

/datum/voidwalker_upgrade_branch/appendage/piercing/tier2/upgrade_effect()
	owner_blade.silence_time += 4 SECONDS

/datum/voidwalker_upgrade_branch/appendage/piercing/tier3
	name = "Accuracy II"
	desc = "Increases armour penetration +25% and wound bonus +30%. Your attacks now heals you +10% of caused damage."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/appendage/piercing/tier2::name

/datum/voidwalker_upgrade_branch/appendage/piercing/tier3/upgrade_effect()
	owner_blade.armour_penetration += 25
	owner_blade.vampirism += 10
	owner_blade.wound_bonus += 30

#undef VOIDWLAKER_UPGRADE_APPENDAGE
