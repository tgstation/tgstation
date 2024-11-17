#define VOIDWLAKER_UPGRADE_BODY "voidwalker_body_upgrade"

/datum/voidwalker_upgrades_tree/body_upgrades
	name = "Body Strengthening"
	desc = "Provides more opportunities for tangible interaction with material objects, which increases combat effectiveness and survivability."
	icon_state = "up_body"
	tree_type = VOIDWLAKER_UPGRADE_BODY

/datum/voidwalker_upgrade_branch/body
	branch_type = VOIDWLAKER_UPGRADE_BODY

/datum/voidwalker_upgrade_branch/body/survival
	var/datum/status_effect/space_regeneration/var_to_regen_status

/datum/voidwalker_upgrade_branch/body/survival/upgrade_effect()
	. = ..()
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	var/obj/item/organ/internal/brain/voidwalker/braaaains = i_know_you_is_human.get_organ_by_type(/obj/item/organ/internal/brain/voidwalker)
	if(!braaaains)
		return
	var/datum/status_effect/space_regeneration/voidwalker_regen = braaaains.regen
	if(!voidwalker_regen)
		return
	var_to_regen_status = voidwalker_regen

/datum/voidwalker_upgrade_branch/body/survival/tier1
	name = "Survival I"
	desc = "Heals +0.5 hp per tick in space (1.5 deafault). x2 heals on crit."

/datum/voidwalker_upgrade_branch/body/survival/tier1/upgrade_effect()
	. = ..()
	var_to_regen_status.healing += 0.5
	var_to_regen_status.crit_mod += 1

/datum/voidwalker_upgrade_branch/body/survival/tier2
	name = "Survival II"
	desc = "Heals +1 hp per tick in space (1.5 deafault). Also Heals +1hp per tick out of space."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/body/survival/tier1::name

/datum/voidwalker_upgrade_branch/body/survival/tier2/upgrade_effect()
	. = ..()
	var_to_regen_status.healing += 1
	var_to_regen_status.out_space_healing += 1

/datum/voidwalker_upgrade_branch/body/survival/tier3
	name = "Survival III"
	desc = "Heals +0.5 hp per tick (1.5 deafault). x3 heals on crit. Also Heals +1hp per tick out of space."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/body/survival/tier2::name

/datum/voidwalker_upgrade_branch/body/survival/tier3/upgrade_effect()
	. = ..()
	var_to_regen_status.healing += 0.5
	var_to_regen_status.crit_mod += 1
	var_to_regen_status.out_space_healing += 1

/datum/voidwalker_upgrade_branch/body/strange
	var/protaction_number

/datum/voidwalker_upgrade_branch/body/strange/upgrade_effect()
	if(isnull(protaction_number))
		return
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	i_know_you_is_human.dna?.species?.damage_modifier += protaction_number

/datum/voidwalker_upgrade_branch/body/strange/tier1
	name = "Body Robust I"
	desc = "Increases body's resistance to all types of damage by 25%"
	protaction_number = 25

/datum/voidwalker_upgrade_branch/body/strange/tier2
	name = "Strong Arms"
	desc = "Your arms become overgrown with muscles, which allows you to drag and throw any objects."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/body/strange/tier1::name

/datum/voidwalker_upgrade_branch/body/strange/tier2/upgrade_effect()
	. = ..()
	owner_mind.current.RemoveElement(/datum/element/only_pull_living)
	REMOVE_TRAIT(owner_mind.current, TRAIT_NO_THROWING, SPECIES_TRAIT)

/datum/voidwalker_upgrade_branch/body/strange/tier3
	name = "Body Robust II"
	desc = "Increases body's resistance to all types of damage by 25%"
	tier = 3
	protaction_number = 25
	upgrade_before = /datum/voidwalker_upgrade_branch/body/strange/tier2::name

/datum/voidwalker_upgrade_branch/body/adaptation/tier2
	name = "Back Adaptation"
	desc = "Allows you to put an item which other people can put on their back on your back."
	tier = 2
	upgrade_before = /datum/voidwalker_upgrade_branch/body/strange/tier1::name

/datum/voidwalker_upgrade_branch/body/adaptation/tier2/upgrade_effect()
	. = ..()
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	i_know_you_is_human.dna?.species?.no_equip_flags &= ~ITEM_SLOT_BACK
	i_know_you_is_human.hud_used?.update_locked_slots()

/datum/voidwalker_upgrade_branch/body/adaptation/tier3
	name = "Hands Adaptation"
	desc = "Allows your hands to use things you couldn't use when your fingers were big."
	tier = 3
	upgrade_before = /datum/voidwalker_upgrade_branch/body/adaptation/tier2::name

/datum/voidwalker_upgrade_branch/body/adaptation/tier3/upgrade_effect()
	. = ..()
	if(!ishuman(owner_mind?.current))
		return
	var/mob/living/carbon/human/i_know_you_is_human = owner_mind?.current
	for(var/obj/item/bodypart/arm/void_arm in i_know_you_is_human.bodyparts)
		var/source = istype(void_arm, /obj/item/bodypart/arm/left) ? LEFT_ARM_TRAIT : RIGHT_ARM_TRAIT
		void_arm.bodypart_traits -= TRAIT_CHUNKYFINGERS
		REMOVE_TRAIT(i_know_you_is_human, TRAIT_CHUNKYFINGERS, source)

#undef VOIDWLAKER_UPGRADE_BODY
