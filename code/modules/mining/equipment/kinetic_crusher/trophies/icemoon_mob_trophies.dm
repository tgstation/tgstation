//Place icemoon small game trophies here.


/**
 * Polar bear
 * Detonating a mark while the user's health is at half or less causes the crusher to attack one more time.
 */
/obj/item/crusher_trophy/bear_paw
	name = "polar bear paw"
	desc = "It's a polar bear paw. Suitable as a trophy for a kinetic crusher."
	icon_state = "bear_paw"
	denied_types = list(/obj/item/crusher_trophy/bear_paw)

/obj/item/crusher_trophy/bear_paw/effect_desc()
	return "mark detonation to <b>attack twice</b> if you are below half your life"

/obj/item/crusher_trophy/bear_paw/on_mark_detonation(mob/living/target, mob/living/user)
	if(user.health / user.maxHealth > 0.5)
		return
	var/obj/item/held_item = user.get_active_held_item()
	if(!held_item)
		return
	held_item.melee_attack_chain(user, target, null)

/**
 * Wolf
 * Detonating a mark causes the user to move twice as fast for 1 second.
 */
/obj/item/crusher_trophy/wolf_ear
	name = "wolf ear"
	desc = "It's a wolf ear. Suitable as a trophy for a kinetic crusher."
	icon_state = "wolf_ear"
	denied_types = list(/obj/item/crusher_trophy/wolf_ear)
	///How long does the buff last on the crusher's wielder
	var/effect_duration = 1 SECONDS

/obj/item/crusher_trophy/wolf_ear/effect_desc()
	return "mark detonation to gain a <b>2X</b> speed boost for <b>[DisplayTimeText(effect_duration)]</b>"

/obj/item/crusher_trophy/wolf_ear/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(/datum/status_effect/speed_boost, effect_duration)
