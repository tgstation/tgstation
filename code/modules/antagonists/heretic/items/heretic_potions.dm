
// An unholy water flask, but for heretics.
/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Toxic to the closed minded, yet refreshing to those with knowledge of the beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldrich_flask"
	list_reagents = list(/datum/reagent/eldritch = 50)

// Potion created by the mawed crucible.
/obj/item/eldritch_potion
	name = "Brew of Day and Night"
	desc = "You should never see this"
	icon = 'icons/obj/eldritch.dmi'
	/// Typepath to the status effect this applies
	var/status_effect

/obj/item/eldritch_potion/attack_self(mob/user)
	. = ..()
	if(!.)
		return

	to_chat(user, span_notice("You drink [src] and with the viscous liquid, the glass dematerializes."))
	effect(user)
	qdel(src)

/*
 * The effect of the potion if it has any special one.
 * In general try not to override this
 * and utilize the status_effect var to make custom effects.
 */
/obj/item/eldritch_potion/proc/effect(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbie = user
	carbie.apply_status_effect(status_effect)

/obj/item/eldritch_potion/crucible_soul
	name = "Brew of Crucible Soul"
	desc = "Allows you to phase through walls for 15 seconds, after the time runs out, you get teleported to your original location."
	icon_state = "crucible_soul"
	status_effect = /datum/status_effect/crucible_soul

/obj/item/eldritch_potion/duskndawn
	name = "Brew of Dusk and Dawn"
	desc = "Allows you to see clearly through walls and objects for 60 seconds."
	icon_state = "clarity"
	status_effect = /datum/status_effect/duskndawn

/obj/item/eldritch_potion/wounded
	name = "Brew of Wounded Soldier"
	desc = "For the next 60 seconds each wound will heal you, minor wounds heal 1 of it's damage type per second, moderate heal 3 and critical heal 6. You also become immune to damage slowdon."
	icon_state = "marshal"
	status_effect = /datum/status_effect/marshal
