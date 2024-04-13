/// Mining crusher trophy from a goliath. Increases damage as your health decreases.
/obj/item/crusher_trophy/goliath_tentacle
	name = "goliath tentacle"
	desc = "A sliced-off goliath tentacle. Suitable as a trophy for a kinetic crusher."
	icon_state = "goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/goliath_tentacle
	bonus_value = 2
	/// Your missing health is multiplied by this value to find the bonus damage
	var/missing_health_ratio = 0.1
	/// Amount of health you must lose to gain damage, according to the examine text. Cached so we don't recalculate it every examine.
	var/missing_health_desc

/obj/item/crusher_trophy/goliath_tentacle/Initialize(mapload)
	. = ..()
	missing_health_desc = 1 / missing_health_ratio / bonus_value

/obj/item/crusher_trophy/goliath_tentacle/effect_desc()
	return "mark detonation to do <b>[bonus_value]</b> more damage for every <b>[missing_health_desc]</b> health you are missing"

/obj/item/crusher_trophy/goliath_tentacle/on_mark_detonation(mob/living/target, mob/living/user)
	var/missing_health = user.maxHealth - user.health
	missing_health *= missing_health_ratio //bonus is active at all times, even if you're above 90 health
	missing_health *= bonus_value //multiply the remaining amount by bonus_value
	if(missing_health > 0)
		target.adjustBruteLoss(missing_health) //and do that much damage
