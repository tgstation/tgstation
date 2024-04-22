/obj/projectile/beam/mindflayer
	name = "flayer ray"
	icon_state = "purplelaser"
	damage = 10
	damage_type = OXY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser

/obj/projectile/beam/mindflayer/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/human_hit = target
		human_hit.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
		human_hit.adjust_hallucinations(20 SECONDS)
