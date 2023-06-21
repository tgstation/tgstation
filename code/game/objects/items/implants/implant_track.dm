/obj/item/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	actions_types = null

	///for how many deciseconds after user death will the implant work?
	var/lifespan_postmortem = 6000
	///will people implanted with this act as teleporter beacons?
	var/allow_teleport = TRUE

/obj/item/implant/tracking/c38
	name = "TRAC implant"
	desc = "A smaller tracking implant that supplies power for only a few minutes."
	var/lifespan = 3000 //how many deciseconds does the implant last?
	///The id of the timer that's qdeleting us
	var/timerid
	allow_teleport = FALSE

/obj/item/implant/tracking/c38/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	timerid = QDEL_IN(src, lifespan)

/obj/item/implant/tracking/c38/removed(mob/living/source, silent, special)
	. = ..()
	deltimer(timerid)
	timerid = null

/obj/item/implant/tracking/c38/Destroy()
	return ..()

/obj/item/implant/tracking/Initialize(mapload)
	. = ..()
	GLOB.tracked_implants += src

/obj/item/implant/tracking/Destroy()
	GLOB.tracked_implants -= src
	return ..()

/obj/item/implanter/tracking
	imp_type = /obj/item/implant/tracking

/obj/item/implanter/tracking/gps
	imp_type = /obj/item/gps/mining/internal

/obj/item/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host.<BR>
				<b>Important Notes:</b> Implant [allow_teleport ? "also works" : "does not work"] as a teleporter beacon.<BR>
				<HR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Continuously transmits low power signal. Useful for tracking.<BR>
				<b>Special Features:</b><BR>
				<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
				a malfunction occurs thereby securing safety of subject. The implant will melt and
				disintegrate into bio-safe elements.<BR>
				<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
				circuitry. As a result neurotoxins can cause massive damage."}
	return dat
