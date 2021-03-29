#define LIGHTNING_BOLT_DAMAGE 75
#define LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH 40

/// Strikes the target with a lightning bolt
/datum/smite/lightning
	name = "Lightning bolt"

/datum/smite/lightning/effect(client/user, mob/living/target)
	. = ..()
	var/turf/lightning_source = get_step(get_step(target, NORTH), NORTH)
	lightning_source.Beam(target, icon_state="lightning[rand(1,12)]", time = 5)
	target.adjustFireLoss(LIGHTNING_BOLT_DAMAGE)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.electrocution_animation(LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH)
	to_chat(target, "<span class='userdanger'>The gods have punished you for your sins!</span>", confidential = TRUE)

#undef LIGHTNING_BOLT_DAMAGE
#undef LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH
