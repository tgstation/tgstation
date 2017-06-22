/obj/machinery/rnd/server
	name = "R&D Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	var/datum/techweb/stored_research
	var/heat_health = 100
	//Code for point mining here.
	var/server_id = 0
	var/base_mining_income = 2
	var/heat_gen = 100
	var/heating_power = 40000
	var/delay = 5
	var/temp_tolerance_low = 0
	var/temp_tolerance_high = T20C
	var/temp_penalty_coefficient = 0.5	//1 = -1 points per degree above high tolerance. 0.5 = -0.5 points per degree above high tolerance.
	req_access = list(GLOB.access_rd) //Only the R&D can change server settings.

/obj/item/weapon/circuitboard/machine/rdserver
	name = "R&D Server (Machine Board)"
	build_path = /obj/machinery/rnd/server
	req_components = list(
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/scanning_module = 1)

/obj/machinery/rnd/server/Destroy()
	SSresearch.servers -= src
	return ..()

/obj/machinery/rnd/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/weapon/stock_parts/SP in src)
		tot_rating += SP.rating
	heat_gen /= max(1, tot_rating)

/obj/machinery/rnd/server/Initialize(mapload)
	. = ..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/rdserver(null)
	B.apply_default_parts(src)
	SSresearch.servers += src
	stored_research = SSresearch.science_tech

/obj/machinery/rnd/server/proc/mine()
	. = base_mining_income
	var/penalty = max((get_env_temp() - temp_tolerance_low), 0) / temp_penalty_coefficient
	. = max(. - penalty, 0)

/obj/machinery/rnd/server/proc/get_env_temp()
	var/datum/gas_mixture/environment = loc.return_air()
	return environment.temperature

/obj/machinery/rnd/server/proc/produce_heat(heat_amt)
	if(!(stat & (NOPOWER|BROKEN))) //Blatently stolen from space heater.
		var/turf/L = loc
		if(istype(L))
			var/datum/gas_mixture/env = L.return_air()
			if(env.temperature < (heat_amt+T0C))

				var/transfer_moles = 0.25 * env.total_moles()

				var/datum/gas_mixture/removed = env.remove(transfer_moles)

				if(removed)

					var/heat_capacity = removed.heat_capacity()
					if(heat_capacity == 0 || heat_capacity == null)
						heat_capacity = 1
					removed.temperature = min((removed.temperature*heat_capacity + heating_power)/heat_capacity, 1000)

				env.merge(removed)
				air_update_turf()

/obj/machinery/rnd/server/attack_hand(mob/user as mob) // I guess only exists to stop ninjas or hell does it even work I dunno.  See also ninja gloves.
	if (disabled)
		return
	if (shocked)
		shock(user,50)
	return

/obj/machinery/rnd/server/centcom
	name = "Centcom Central R&D Database"
	server_id = -1

/obj/machinery/rnd/server/centcom/Initialize()
	. = ..()
	fix_noid_research_servers()

/proc/fix_noid_research_servers()
	var/list/no_id_servers = list()
	var/list/server_ids = list()
	for(var/obj/machinery/rnd/server/S in GLOB.machines)
		switch(S.server_id)
			if(-1)
				continue
			if(0)
				no_id_servers += S
			else
				server_ids += S.server_id

	for(var/obj/machinery/rnd/server/S in no_id_servers)
		var/num = 1
		while(!S.server_id)
			if(num in server_ids)
				num++
			else
				S.server_id = num
				server_ids += num
		no_id_servers -= S

/obj/machinery/rnd/server/centcom/process()
	return PROCESS_KILL	//don't need process()


/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Used to manage access to research and manufacturing databases."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/screen = 0
	var/obj/machinery/rnd/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	var/badmin = 0
	circuit = /obj/item/weapon/circuitboard/computer/rdservercontrol

/obj/machinery/computer/rdservercontrol/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
	usr.set_machine(src)
	if(!src.allowed(usr) && !emagged)
		to_chat(usr, "<span class='danger'>You do not have the required access level.</span>")
		return

	if(href_list["main"])
		screen = 0

	updateUsrDialog()
	return

/obj/machinery/computer/rdservercontrol/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = ""

	switch(screen)
		if(0) //Main Menu
			dat += "Connected Servers:<BR><BR>"

			for(var/obj/machinery/rnd/server/S in GLOB.machines)
				if(istype(S, /obj/machinery/rnd/server/centcom) && !badmin)
					continue
				dat += "[S.name] || "
				dat += "<BR>"

		//Mining status here
	user << browse("<TITLE>R&D Server Control</TITLE><HR>[dat]", "window=server_control;size=575x400")
	onclose(user, "server_control")
	return

/obj/machinery/computer/rdservercontrol/attackby(obj/item/weapon/D, mob/user, params)
	. = ..()
	src.updateUsrDialog()

/obj/machinery/computer/rdservercontrol/emag_act(mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, "<span class='notice'>You you disable the security protocols.</span>")
