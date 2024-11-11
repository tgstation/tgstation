/// A space dragon's fire breath, toasts lunch AND buffs your friends
/datum/action/cooldown/mob_cooldown/fire_breath/carp
	desc = "A Space Dragon's burning breath not only chars its foes, but invigorates Space Carp as well."
	fire_damage = 30
	mech_damage = 50
	fire_range = 20
	fire_temperature = 700 // Even hotter than a megafauna for some reason
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/fire_breath/carp/on_burn_mob(mob/living/barbecued, mob/living/source)
	if (!source.faction_check_atom(barbecued))
		return ..()
	to_chat(barbecued, span_notice("[source]'s fiery breath fills you with energy!"))
	barbecued.apply_status_effect(/datum/status_effect/carp_invigoration)

/// Makes you run faster for the duration
/datum/status_effect/carp_invigoration
	id = "carp_invigorated"
	alert_type = null
	duration = 8 SECONDS

/datum/status_effect/carp_invigoration/on_apply()
	. = ..()
	if (!.)
		return
	owner.add_filter("anger_glow", 3, list("type" = "outline", "color" = COLOR_CARP_RIFT_RED, "size" = 2))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)

/datum/status_effect/carp_invigoration/on_remove()
	owner.remove_filter("anger_glow")
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)
