/obj/item/projectile/beam/mindflayer
	name = "flayer ray"

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		var/obj/item/organ/brain = M.getorganslot(ORGAN_SLOT_BRAIN)
		brain.applyOrganDamage(20)
		M.hallucination += 30
