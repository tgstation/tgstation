///List of all tracking implants currently in a mob.
GLOBAL_LIST_EMPTY(tracked_tracking_implants)

/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	actions_types = null
	implant_flags = IMPLANT_TYPE_SECURITY
	hud_icon_state = "hud_imp_tracking"

	///How long will the implant continue to function after death?
	var/lifespan_postmortem = 10 MINUTES

/obj/item/implant/tracking/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/tracked_implant, \
		global_list = GLOB.tracked_tracking_implants, \
	)

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp EYE-5 Convict Parole Implant<BR>
				<b>Life:</b> 10 minutes after death of host.<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Can be tracked from a prisoner management console.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
	return dat

/obj/item/implant/tracking/c38
	name = "TRAC implant"
	desc = "A smaller tracking implant that supplies power for only a few minutes."
	implant_flags = NONE
	///How long before this implant self-deletes?
	var/lifespan = 5 MINUTES
	///The id of the timer that's qdeleting us
	var/timerid

/obj/item/implant/tracking/c38/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	timerid = QDEL_IN_STOPPABLE(src, lifespan)

/obj/item/implant/tracking/c38/removed(mob/living/source, silent, special)
	. = ..()
	deltimer(timerid)
	timerid = null

/obj/item/implant/tracking/c38/Destroy()
	return ..()

/obj/item/implanter/tracking
	imp_type = /obj/item/implant/tracking

/obj/item/implanter/tracking/gps
	imp_type = /obj/item/gps/mining/internal
