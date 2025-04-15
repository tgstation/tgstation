/// Strikes the target with a lightning bolt
/datum/smite/lightning
	name = "Lightning Bolt"

/datum/smite/lightning/effect(client/user, mob/living/target)
	. = ..()
	lightningbolt(target)
	to_chat(target, span_userdanger("The gods have punished you for your sins!"), confidential = TRUE)

///this is the actual bolt effect and damage, made into its own proc because it is used elsewhere
/proc/lightningbolt(mob/living/user)
	var/turf/lightning_source = get_step(get_step(user, NORTH), NORTH)
	lightning_source.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
	user.adjustFireLoss(LIGHTNING_BOLT_DAMAGE)
	playsound(get_turf(user), 'sound/effects/magic/lightningbolt.ogg', 50, TRUE)
	if(ishuman(user))
		var/mob/living/carbon/human/human_target = user
		human_target.electrocution_animation(LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH)

/datum/smite/lightning/divine
	name = "Lightning Bolt (Divine)"
	smite_flags = SMITE_DIVINE
