/obj/item/clothing/shoes/greaves_of_the_prophet
	name = "greaves of the prophet"
	desc = "some nice shoes that negate potential hazards and reduces how long it takes to remove bolas and traps"

/obj/item/clothing/shoes/greaves_of_the_prophet/Initialize(mapload)
	. = ..()
	attach_clothing_traits(list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE, TRAIT_NO_SLIP_ALL, TRAIT_NEGATES_GRAVITY))
	// XANTODO Sprite + Figure out bola code
	// resist_restraints()
	// breakouttime
	// Maybe signal?
	// https://discord.com/channels/326822144233439242/326831214667235328/1323027566222643220

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
