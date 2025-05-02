/// How much terror is applied upon first cast of Terrify
#define TERROR_INITIAL_AMOUNT 100
/// Amount of terror caused by subsequent casting of the Terrify spell.
#define STACK_TERROR_AMOUNT 135

/datum/status_effect/terrified
	id = "terrified"
	status_type = STATUS_EFFECT_REFRESH
	remove_on_fullheal = TRUE
	alert_type = /atom/movable/screen/alert/status_effect/terrified

/datum/status_effect/terrified/on_apply()
	to_chat(owner, span_alert("The darkness closes in around you, shadows dance around the corners of your vision... It feels like something is watching you!"))
	owner.emote("scream")
	owner.AddComponentFrom("terrified", /datum/component/fearful, list(/datum/terror_handler/simple_source/nyctophobia/terrified), TERROR_INITIAL_AMOUNT)
	return TRUE

/datum/status_effect/terrified/on_remove()
	owner.RemoveComponentSource("terrified", /datum/component/fearful)

/datum/status_effect/terrified/refresh(effect, ...)
	// Jank way of adding terror to the existing component
	owner.AddComponentFrom("terrified", /datum/component/fearful, null, STACK_TERROR_AMOUNT)

/// The status effect popup for the terror status effect
/atom/movable/screen/alert/status_effect/terrified
	name = "Terrified!"
	desc = "You feel a supernatural darkness settle in around you, overwhelming you with panic! Get into the light!"
	icon_state = "terrified"

#undef TERROR_INITIAL_AMOUNT
#undef STACK_TERROR_AMOUNT
