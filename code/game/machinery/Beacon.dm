/obj/machinery/bluespace_beacon

	icon = 'objects.dmi'
	icon_state = "floor_beaconf"
	name = "Bluespace Gigabeacon"
	desc = "A device that draws power from bluespace and creates a permanent tracking beacon."
	level = 1		// underfloor
	layer = 2.5
	anchored = 1
	use_power = 1
	idle_power_usage = 0
	var/obj/item/device/radio/beacon/Beacon

	New()
		..()
		var/turf/T = loc
		Beacon = new /obj/item/device/radio/beacon
		Beacon.invisibility = 100
		Beacon.loc = T

		hide(T.intact)

	Del()
		if(Beacon)
			del(Beacon)
		..()

	// update the invisibility and icon
	hide(var/intact)
		invisibility = intact ? 101 : 0
		updateicon()

	// update the icon_state
	proc/updateicon()
		var/state="floor_beacon"

		if(invisibility)
			icon_state = "[state]f"

		else
			icon_state = "[state]"

	process()
		if(!Beacon)
			var/turf/T = loc
			Beacon = new /obj/item/device/radio/beacon
			Beacon.invisibility = 100
			Beacon.loc = T
		if(Beacon)
			if(Beacon.loc != loc)
				Beacon.loc = loc

		updateicon()


