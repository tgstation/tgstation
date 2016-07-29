var/list/obj/machinery/power/photocollector/photocollector_list = list()
/obj/machinery/power/photocollector
	name = "Photocollector"
	desc = "A device that uses high-energy photons to produce power."
	icon = 'icons/obj/machines/optical/lasergenerator.dmi'
	icon_state = "lasergen"
	anchored = 0
	density = 1

	var/last_power = 0
	var/production_ratio = 290 // Emitters draw 300 power each.
	ghost_read=0
	ghost_write=0

	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/power/photocollector/New()
	photocollector_list += src
	..()

/obj/machinery/power/photocollector/Destroy()
	photocollector_list -= src
	..()

/obj/machinery/power/photocollector/beam_connect(var/obj/effect/beam/B)
	..()
	update_icons()

/obj/machinery/power/photocollector/beam_disconnect(var/obj/effect/beam/B)
	..()
	update_icons()

/obj/machinery/power/photocollector/process()
	last_power = 0
	if(!anchored || beams.len == 0)
		return
	var/avail_energy = 0
	for(var/obj/effect/beam/emitter/EB in beams)
		if(EB)
			avail_energy += EB.power
	if(avail_energy>=1)
		var/power_produced=avail_energy * production_ratio
		add_avail(power_produced)
		last_power = power_produced

/obj/machinery/power/photocollector/wrenchAnchor(mob/user)
	if(..() == 1)
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
		return 1
	return -1

/obj/machinery/power/photocollector/attackby(obj/item/W, mob/user)
	if(..())
		return 1
	else if(istype(W, /obj/item/device/analyzer) || istype(W, /obj/item/device/multitool))
		if(last_power)
			to_chat(user, "<span class='notice'>\The [W] registers that [format_watts(last_power)] is being produced every cycle.</span>")
		else
			to_chat(user, "<span class='notice'>\The [W] registers that the unit is currently not producing power.</span>")
		return 1

/obj/machinery/power/photocollector/proc/update_icons()
	overlays.len = 0
	if(stat & (NOPOWER|BROKEN))
		return
	if(anchored && beams.len>0)
		overlays += image(icon = icon, icon_state = "lasergen-on")

