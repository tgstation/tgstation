/obj/structure/signpost
	name = "signpost"
	desc = "Won't somebody give me a sign?"
	icon = 'icons/obj/fluff/general.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE

	/// Whether or not this enables the Houlihan element.
	var/teleports = FALSE
	/// Optional replacement for the teleport question.
	var/question = null
	/// Optional list of z-levels that the Houlihan element can send us to. Modify this on Initialize().
	VAR_FINAL/list/zlevels = null

/obj/structure/signpost/Initialize(mapload)
	..()
	set_light(2)
	return INITIALIZE_HINT_LATELOAD

/obj/structure/signpost/LateInitialize()
	// This is here cause we wanna be super sure zlevels is properly initialized
	if(teleports)
		AddComponent(/datum/component/houlihan_teleport, question, zlevels)

/* ----------------- */

/obj/structure/signpost/salvation
	name = "\proper salvation"
	desc = "In the darkest times, we will find our way home."
	resistance_flags = INDESTRUCTIBLE
	teleports = TRUE

/obj/structure/signpost/void
	name = "signpost at the edge of the universe"
	desc = "A direction in the directionless void."
	density = FALSE
	/// Brightness of the signpost.
	var/range = 2
	/// Light power of the signpost.
	var/power = 0.8

/obj/structure/signpost/void/Initialize(mapload)
	. = ..()
	set_light(range, power)
