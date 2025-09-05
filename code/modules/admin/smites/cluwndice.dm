/// Makes the target's blood a beautiful rainbow
/datum/smite/clownify_blood
	name = "Clownify blood"

/datum/smite/clownify_blood/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.set_blood_type(BLOOD_TYPE_CLOWN)
	SEND_SOUND(carbon_target, 'sound/items/bikehorn.ogg')
