/// Inflicts crippling brain damage on the target
/datum/smite/brain_damage
	name = "Brain damage"

/datum/smite/brain_damage/effect(client/user, mob/living/target)
	. = ..()
	target.adjust_organ_loss(ORGAN_SLOT_BRAIN, BRAIN_DAMAGE_DEATH - 1, BRAIN_DAMAGE_DEATH - 1)
