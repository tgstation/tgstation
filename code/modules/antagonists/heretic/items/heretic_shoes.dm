/**
 * XANTODO ADD LORE WHEN WE MAKE THE KNOWLEDGE FOR THIS:
 *
 * "Gristle churns into joint, a pop, and the fool twists a blackened foot from the
 * jaws of another. At their game for centuries, this mangled tree of limbs twists,
 * thrashing snares buried into snarling gums, seeking to shred the weight of grafted
 * neighbors. Weighed down by lacerated feet, this canopy of rancid idiots ever seeks
 * the undoing of its own bonds. I dread the thought of walking in their wake, but
 * I must press on all the same. Their rhythms keep the feud fresh with indifference
 * to barrier or border. Pulling more into their turmoil as they waltz."
 */

/obj/item/clothing/shoes/magboots/greaves_of_the_prophet
	name = "\improper Joint-snap sabatons"
	desc = "Some nice shoes that allow you to always stay up on your feet."
	icon_state = "hereticgreaves"
	resistance_flags = ACID_PROOF | FIRE_PROOF | LAVA_PROOF
	active_traits = list(TRAIT_NEGATES_GRAVITY)
	slowdown_active = 0
	fishing_modifier = 0
	magpulse_fishing_modifier = 0

/obj/item/clothing/shoes/magboots/greaves_of_the_prophet/Initialize(mapload)
	. = ..()
	attach_clothing_traits(list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NO_SLIP_ALL))

/obj/item/clothing/shoes/magboots/greaves_of_the_prophet/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) // Don't give us magboot sprites when we toggle the traction

// XANTODO Move this to its own file (Or find somewhere it belongs)
/obj/item/ether
	name = "ether of the newborn"
	desc = "drink to cleanse your body of all abnormalities. Puts you into an enhanced sleep for a full minute."
	icon = 'icons/obj/antags/eldritch.dmi'
	icon_state = "poison_flask"

/obj/item/ether/attack_self(mob/living/user, modifiers)
	. = ..()
	user.revive(ADMIN_HEAL_ALL)
	for(var/obj/item/implant/to_remove in user.implants)
		to_remove.removed(user)

	user.apply_status_effect(/datum/status_effect/eldritch_sleep)
	user.SetSleeping(60 SECONDS)
	qdel(src)

/datum/status_effect/eldritch_sleep
	id = "eldritch_sleep"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_sleep
	show_duration = TRUE
	remove_on_fullheal = TRUE
	/// List of traits our drinker gets while they are asleep
	var/list/sleeping_traits = list(TRAIT_NOBREATH, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD, TRAIT_RESISTHEAT)

/datum/status_effect/eldritch_sleep/on_apply()
	. = ..()
	owner.add_traits(sleeping_traits, STATUS_EFFECT_TRAIT)

/datum/status_effect/eldritch_sleep/on_remove()
	owner.SetSleeping(0) // Wake up bookworm, we have some heathens to burn
	owner.remove_traits(sleeping_traits, STATUS_EFFECT_TRAIT)
	owner.reagents?.remove_all(100) // If someone gives you over 100 units of poison while you sleep then you deserve this L

/atom/movable/screen/alert/status_effect/eldritch_sleep
	name = "Eldritch Slumber"
	desc = "You feel an indescribable warmth keeping you safe..."
	icon_state = "eldritch_slumber"
