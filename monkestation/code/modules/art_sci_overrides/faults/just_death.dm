/datum/artifact_fault/death
	name = "Instant Death"
	trigger_chance = 1
	visible_message = "blows someone up with mind."


/datum/artifact_fault/death/on_trigger(datum/component/artifact/component)

	for(var/mob/living/carbon/human in range(rand(3, 4), component.holder))
		var/obj/item/organ/internal/brain/brain = human.get_organ_slot(ORGAN_SLOT_BRAIN)
		if(brain)
			brain.forceMove(get_turf(human))
		human.gib()
		break
