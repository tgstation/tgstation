/obj/projectile/beam/mindflayer
	name = "flayer ray"

/obj/projectile/beam/mindflayer/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/human_hit = target
		human_hit.adjust_organ_loss(ORGAN_SLOT_BRAIN, 20)
		human_hit.adjust_hallucinations(60 SECONDS)
