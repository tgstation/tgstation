#define HDD_PANEL_CLOSED 0
#define HDD_PANEL_OPEN 1
#define HDD_PRIED 2
#define HDD_CUT_LOOSE 3

/obj/machinery/rnd/server
	name = "\improper R&D Server"
	desc = "A computer system running a deep neural network that processes arbitrary information to produce data useable in the development of new technologies. In layman's terms, it makes research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	base_icon_state = "RD-server"
	var/heat_health = 100
	//Code for point mining here.
	var/working = TRUE //temperature should break it.
	var/research_disabled = FALSE
	var/server_id = 0
	var/base_mining_income = 2
	var/current_temp = 0
	var/heat_gen = 100
	var/heating_power = 40000
	var/delay = 5
	var/temp_tolerance_low = 0
	var/temp_tolerance_high = T20C
	var/temp_penalty_coefficient = 0.5 //1 = -1 points per degree above high tolerance. 0.5 = -0.5 points per degree above high tolerance.
	req_access = list(ACCESS_RD) //ONLY THE R&D CAN CHANGE SERVER SETTINGS.

/obj/machinery/rnd/server/Initialize()
	. = ..()
	name += " [num2hex(rand(1,65535), -1)]" //gives us a random four-digit hex number as part of the name. Y'know, for fluff.
	SSresearch.servers |= src

/obj/machinery/rnd/server/Destroy()
	SSresearch.servers -= src
	return ..()

/obj/machinery/rnd/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/SP in src)
		tot_rating += SP.rating
	heat_gen /= max(1, tot_rating)

/obj/machinery/rnd/server/update_icon_state()
	if(machine_stat & EMPED || machine_stat & NOPOWER)
		icon_state = "[base_icon_state]-off"
		return ..()
	icon_state = "[base_icon_state]-[research_disabled ? "halt" : "on"]"
	return ..()

/obj/machinery/rnd/server/power_change()
	. = ..()
	refresh_working()
	return

/obj/machinery/rnd/server/attackby(obj/item/O, mob/user, params)
	. = ..()


/obj/machinery/rnd/server/proc/refresh_working()
	if(machine_stat & EMPED || research_disabled || machine_stat & NOPOWER)
		working = FALSE
	else
		working = TRUE
	update_appearance()

/obj/machinery/rnd/server/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	set_machine_stat(machine_stat | EMPED)
	addtimer(CALLBACK(src, .proc/unemp), 600)
	refresh_working()

/obj/machinery/rnd/server/proc/unemp()
	set_machine_stat(machine_stat & ~EMPED)
	refresh_working()

/obj/machinery/rnd/server/proc/toggle_disable()
	research_disabled = !research_disabled
	refresh_working()

/obj/machinery/rnd/server/proc/get_env_temp()
	var/turf/open/L = loc
	if(isturf(L))
		return L.temperature
	return 0 //what

/obj/machinery/rnd/server/proc/produce_heat(heat_amt)
	if(!(machine_stat & (NOPOWER|BROKEN))) //Blatently stolen from space heater.
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
				air_update_turf(FALSE, FALSE)

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


/obj/machinery/computer/rdservercontrol
	name = "R&D Server Controller"
	desc = "Used to manage access to research and manufacturing databases."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/screen = 0
	var/obj/machinery/rnd/server/temp_server
	var/list/servers = list()
	var/list/consoles = list()
	req_access = list(ACCESS_RD)
	var/badmin = 0
	circuit = /obj/item/circuitboard/computer/rdservercontrol

/obj/machinery/computer/rdservercontrol/Topic(href, href_list)
	if(..())
		return

	add_fingerprint(usr)
	if (href_list["toggle"])
		if(allowed(usr) || obj_flags & EMAGGED)
			var/obj/machinery/rnd/server/S = locate(href_list["toggle"]) in SSresearch.servers
			S.toggle_disable()
		else
			to_chat(usr, span_danger("Access Denied."))

	updateUsrDialog()
	return

/obj/machinery/computer/rdservercontrol/ui_interact(mob/user)
	. = ..()
	var/list/dat = list()

	dat += "<b>Connected Servers:</b>"
	dat += "<table><tr><td style='width:25%'><b>Server</b></td><td style='width:25%'><b>Operating Temp</b></td><td style='width:25%'><b>Status</b></td>"
	for(var/obj/machinery/rnd/server/S in GLOB.machines)
		dat += "<tr><td style='width:25%'>[S.name]</td><td style='width:25%'>[S.current_temp]</td><td style='width:25%'>[S.machine_stat & EMPED || machine_stat & NOPOWER?"Offline":"<A href='?src=[REF(src)];toggle=[REF(S)]'>([S.research_disabled? "<font color=red>Disabled" : "<font color=lightgreen>Online"]</font>)</A>"]</td><BR>"
	dat += "</table></br>"

	dat += "<b>Research Log</b></br>"
	var/datum/techweb/stored_research
	stored_research = SSresearch.science_tech
	if(stored_research.research_logs.len)
		dat += "<table BORDER=\"1\">"
		dat += "<tr><td><b>Entry</b></td><td><b>Research Name</b></td><td><b>Cost</b></td><td><b>Researcher Name</b></td><td><b>Console Location</b></td></tr>"
		for(var/i=stored_research.research_logs.len, i>0, i--)
			dat += "<tr><td>[i]</td>"
			for(var/j in stored_research.research_logs[i])
				dat += "<td>[j]</td>"
			dat +="</tr>"
		dat += "</table>"

	else
		dat += "</br>No history found."

	var/datum/browser/popup = new(user, "server_com", src.name, 900, 620)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/computer/rdservercontrol/attackby(obj/item/D, mob/user, params)
	. = ..()
	src.updateUsrDialog()

/obj/machinery/computer/rdservercontrol/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	obj_flags |= EMAGGED
	to_chat(user, span_notice("You disable the security protocols."))

/// Master R&D server. As long as this still exists and still holds the HDD for the theft objective, research points generate at normal speed. Destroy it or an antag steals the HDD? Half research speed.
/obj/machinery/rnd/server/master
	var/obj/item/computer_hardware/hard_drive/cluster/hdd_theft/source_code_hdd
	var/deconstruction_state = HDD_PANEL_CLOSED
	var/front_panel_screws = 4
	var/hdd_wires = 6

/obj/machinery/rnd/server/master/Initialize()
	. = ..()
	name = "\improper Master " + name
	source_code_hdd = new(src)
	SSresearch.master_servers += src

	add_overlay("RD-server-objective-stripes")

/obj/machinery/rnd/server/master/Destroy()
	if(source_code_hdd)
		QDEL_NULL(source_code_hdd)

	SSresearch.master_servers -= src

	return ..()

/obj/machinery/rnd/server/master/attackby(obj/item/attacking_item, mob/user, params)
	if(!source_code_hdd)
		return ..()

	switch(deconstruction_state)
		if(HDD_PANEL_CLOSED)
			if(istype(attacking_item, /obj/item/screwdriver/hdd_extraction))
				to_chat(user, span_notice("Your [attacking_item.name] fits perfectly into the slots of [src]'s front panel screws. You can see [front_panel_screws] screws. You start unscrewing them..."))
				while(attacking_item.use_tool(src, user, 100, volume=100))
					front_panel_screws--

					if(front_panel_screws <= 0)
						deconstruction_state = HDD_PANEL_OPEN
						to_chat(user, span_notice("You remove the last screw from [src]'s front panel. It drops, held only by wires."))
						add_overlay("RD-server-hdd-panel-open")
						return

					to_chat(user, span_notice("You remove a screw from [src]'s front panel. Only [front_panel_screws] left..."))
				return
			if(istype(attacking_item, /obj/item/computer_hardware/hard_drive/cluster/hdd_theft))
				to_chat(user, span_notice("You can't see a place to insert [src]."))
		if(HDD_PANEL_OPEN)
			if(istype(attacking_item, /obj/item/crowbar/hdd_extraction))
				to_chat(user, span_notice("You can see [source_code_hdd] in a secure housing through behind the front panel. Your tiny [attacking_item.name] barely fits inside. You begin to pry it loose..."))
				if(attacking_item.use_tool(src, user, 200, volume=100))
					to_chat(user, span_notice("You pry [source_code_hdd] free of its secure housing."))
					deconstruction_state = HDD_PRIED
				return
			if(istype(attacking_item, /obj/item/computer_hardware/hard_drive/cluster/hdd_theft))
				to_chat(user, span_notice("There's already a [source_code_hdd.name] in the server. No need to add a second."))
		if(HDD_PRIED)
			if(istype(attacking_item, /obj/item/wirecutters/hdd_extraction))
				to_chat(user, span_notice("With [source_code_hdd] free, you begin to delicately cut wires with [attacking_item]. Following the instructions on its display, there are [hdd_wires] wires left..."))
				while(attacking_item.use_tool(src, user, 100, volume=100))
					hdd_wires--

					if(hdd_wires <= 0)
						deconstruction_state = HDD_CUT_LOOSE
						to_chat(user, span_notice("You cut the final wire and remove [source_code_hdd]."))
						try_put_in_hand(source_code_hdd, user)
						return

					to_chat(user, span_notice("You cut the wire indicated by [attacking_item]. [hdd_wires] wires left..."))
				return
			if(istype(attacking_item, /obj/item/computer_hardware/hard_drive/cluster/hdd_theft))
				to_chat(user, span_notice("There's already a [source_code_hdd.name] in the server. No need to add a second."))
		if(HDD_CUT_LOOSE)
			if(istype(attacking_item, /obj/item/computer_hardware/hard_drive/cluster/hdd_theft))
				to_chat(user, span_notice("[src] is too badly damaged to add [attacking_item]."))

	return ..()

#undef HDD_PANEL_CLOSED
#undef HDD_PANEL_OPEN
#undef HDD_PRIED
#undef HDD_CUT_LOOSE
