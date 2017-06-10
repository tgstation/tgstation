/obj/item/weapon/implant/tracking
	name = "tracking implant"
	desc = "Track with this."
	activated = 0
	origin_tech = "materials=2;magnets=2;programming=2;biotech=2"

/obj/item/weapon/implant/tracking/New()
	..()
	GLOB.tracked_implants += src

/obj/item/weapon/implant/tracking/Destroy()
	. = ..()
	GLOB.tracked_implants -= src

/obj/item/weapon/implanter/tracking
	imp_type = /obj/item/weapon/implant/tracking

/obj/item/weapon/implanter/tracking/gps
	imp_type = /obj/item/device/gps/mining/internal

/obj/item/weapon/implant/tracking/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Tracking Beacon<BR>
				<b>Life:</b> 10 minutes after death of host<BR>
				<b>Important Notes:</b> None<BR>
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
