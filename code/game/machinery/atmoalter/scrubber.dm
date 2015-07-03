/obj/machinery/portable_atmospherics/scrubber
	name = "portable air scrubber"

	icon = 'icons/obj/atmos.dmi'
	icon_state = "pscrubber:0"
	density = 1

	var/on = 0
	var/volume_rate = 800

	volume = 750

/obj/machinery/portable_atmospherics/scrubber/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50/severity))
		on = !on
		update_icon()

	..(severity)

/obj/machinery/portable_atmospherics/scrubber/huge
	name = "huge air scrubber"
	icon_state = "scrubber:0"
	anchored = 1
	volume = 50000
	volume_rate = 5000

	var/global/gid = 1
	var/id = 0
	New()
		..()
		id = gid
		gid++

		name = "[name] (ID [id])"

	attack_hand(var/mob/user as mob)
		usr << "<span class='notice'>You can't directly interact with this machine. Use the area atmos computer.</span>"

	update_icon()
		src.overlays = 0

		if(on)
			icon_state = "scrubber:1"
		else
			icon_state = "scrubber:0"

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench))
			if(on)
				user << "<span class='notice'>Turn it off first!</span>"
				return

			anchored = !anchored
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user << "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>"

			return

		..()

/obj/machinery/portable_atmospherics/scrubber/huge/stationary
	name = "stationary air scrubber"

	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench))
			user << "<span class='notice'>The bolts are too tight for you to unscrew!</span>"
			return

		..()


/obj/machinery/portable_atmospherics/scrubber/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

	if(holding)
		overlays += "scrubber-open"

	if(connected_port)
		overlays += "scrubber-connector"

	return

/obj/machinery/portable_atmospherics/scrubber/process_atmos()
	..()

	if(on)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()
		var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles()

		//Take a gas sample
		var/datum/gas_mixture/removed
		if(holding)
			removed = environment.remove(transfer_moles)
		else
			removed = loc.remove_air(transfer_moles)

		//Filter it
		if (removed)
			var/datum/gas_mixture/filtered_out = new

			filtered_out.temperature = removed.temperature


			filtered_out.toxins = removed.toxins
			removed.toxins = 0

			filtered_out.carbon_dioxide = removed.carbon_dioxide
			removed.carbon_dioxide = 0

			if(removed.trace_gases.len>0)
				for(var/datum/gas/trace_gas in removed.trace_gases)
					if(istype(trace_gas, /datum/gas/sleeping_agent))
						removed.trace_gases -= trace_gas
						filtered_out.trace_gases += trace_gas

			if(removed.trace_gases.len>0)
				for(var/datum/gas/trace_gas in removed.trace_gases)
					if(istype(trace_gas, /datum/gas/oxygen_agent_b))
						removed.trace_gases -= trace_gas
						filtered_out.trace_gases += trace_gas

		//Remix the resulting gases
			air_contents.merge(filtered_out)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)
		//src.update_icon()
/obj/machinery/portable_atmospherics/scrubber/process()
	..()
	src.updateDialog()
	return

/obj/machinery/portable_atmospherics/scrubber/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_hand(var/mob/user as mob)
	ui_interact(user)



/obj/machinery/portable_atmospherics/scrubber/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "scrubber.tmpl", "Scrubber", 480, 400, 10)

/obj/machinery/portable_atmospherics/scrubber/get_ui_data()
	var/data = list()
	data["name"] = src.name
	data["portConnected"] = src.connected_port ? 1 : 0
	data["scrubberPressure"] = round(src.air_contents.return_pressure() ? src.air_contents.return_pressure() : 0)
	data["volumeRate"] = round(src.volume_rate ? src.volume_rate : 0)
	data["minVolumeRate"] = round(ONE_ATMOSPHERE/10)
	data["maxVolumeRate"] = round(10*ONE_ATMOSPHERE)
	data["scrubOn"] = src.on ? 1 : 0

	data["hasHoldingTank"] = src.holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = src.holding.name, "tankPressure" = round(src.holding.air_contents.return_pressure()))

	return data

/obj/machinery/portable_atmospherics/scrubber/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.set_machine(src)

		if(href_list["power"])
			on = !on

		if (href_list["remove_tank"])
			if(holding)
				holding.loc = loc
				holding = null

		if (href_list["volume_adj"])
			var/diff = text2num(href_list["volume_adj"])
			volume_rate = min(10*ONE_ATMOSPHERE, max(0, volume_rate+diff))

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=scrubber")
		return
	return