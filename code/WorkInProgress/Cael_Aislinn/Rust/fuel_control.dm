
/obj/machinery/computer/rust_fuel_control
	name = "RUST Fuel Injection Control"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "fuel"
	var/list/connected_injectors = list()
	var/list/active_stages = list()
	var/list/proceeding_stages = list()
	var/list/stage_times = list()
	//var/list/stage_status
	var/announce_fueldepletion = 0
	var/announce_stageprogression = 0
	var/scan_range = 25
	var/ticks_this_stage = 0

/*/obj/machinery/computer/rust_fuel_control/New()
	..()
	//these are the only three stages we can accept
	//we have another console for SCRAM
	fuel_injectors = new/list
	stage_status = new/list

	fuel_injectors.Add("One")
	fuel_injectors["One"] = new/list
	stage_status.Add("One")
	stage_status["One"] = 0
	fuel_injectors.Add("Two")
	fuel_injectors["Two"] = new/list
	stage_status.Add("Two")
	stage_status["Two"] = 0
	fuel_injectors.Add("Three")
	fuel_injectors["Three"] = new/list
	stage_status.Add("Three")
	stage_status["Three"] = 0
	fuel_injectors.Add("SCRAM")
	fuel_injectors["SCRAM"] = new/list
	stage_status.Add("SCRAM")
	stage_status["SCRAM"] = 0

	spawn(0)
		for(var/obj/machinery/power/rust_fuel_injector/Injector in world)
			if(Injector.stage in fuel_injectors)
				var/list/targetlist = fuel_injectors[Injector.stage]
				targetlist.Add(Injector)*/

/obj/machinery/computer/rust_fuel_control/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/rust_fuel_control/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/computer/rust_fuel_control/interact(mob/user)
	if(stat & (BROKEN|NOPOWER))
		user.unset_machine()
		user << browse(null, "window=fuel_control")
		return

	if (!istype(user, /mob/living/silicon) && get_dist(src, user) > 1)
		user.unset_machine()
		user << browse(null, "window=fuel_control")
		return

	var/dat = "<B>Reactor Core Fuel Control</B><BR>"
	/*dat += "<b>Fuel depletion announcement:</b> "
	dat += "[announce_fueldepletion == 0 ? 	"Disabled"		: "<a href='?src=\ref[src];announce_fueldepletion=0'>\[Disable\]</a>"] "
	dat += "[announce_fueldepletion == 1 ? 	"Announcing"	: "<a href='?src=\ref[src];announce_fueldepletion=1'>\[Announce\]</a>"] "
	dat += "[announce_fueldepletion == 2 ? 	"Broadcasting"	: "<a href='?src=\ref[src];announce_fueldepletion=2'>\[Broadcast\]</a>"]<br>"
	dat += "<b>Stage progression announcement:</b> "
	dat += "[announce_stageprogression == 0 ? 	"Disabled"		: "<a href='?src=\ref[src];announce_stageprogression=0'>\[Disable\]</a>"] "
	dat += "[announce_stageprogression == 1 ? 	"Announcing"	: "<a href='?src=\ref[src];announce_stageprogression=1'>\[Announce\]</a>"] "
	dat += "[announce_stageprogression == 2 ? 	"Broadcasting"	: "<a href='?src=\ref[src];announce_stageprogression=2'>\[Broadcast\]</a>"]<br>"*/
	dat += "<hr>"

	dat += "<b>Detected devices</b> <a href='?src=\ref[src];scan=1'>\[Refresh list\]</a>"
	dat += "<table border=1 width='100%'>"
	dat += "<tr>"
	dat += "<td><b>ID</b></td>"
	dat += "<td><b>Assembly</b></td>"
	dat += "<td><b>Consumption</b></td>"
	dat += "<td><b>Depletion</b></td>"
	dat += "<td><b>Duration</b></td>"
	dat += "<td><b>Next stage</b></td>"
	dat += "<td></td>"
	dat += "<td></td>"
	dat += "</tr>"

	for(var/obj/machinery/power/rust_fuel_injector/I in connected_injectors)
		dat += "<tr>"
		dat += "<td>[I.id_tag]</td>"
		if(I.cur_assembly)
			dat += "<td><a href='?src=\ref[I];toggle_injecting=1;update_extern=\ref[src]'>\[[I.injecting ? "Halt injecting" : "Begin injecting"]\]</a></td>"
		else
			dat += "<td>None</td>"
		dat += "<td>[I.fuel_usage * 100]%</td>"
		if(I.cur_assembly)
			dat += "<td>[I.cur_assembly.percent_depleted * 100]%</td>"
		else
			dat += "<td>NA</td>"
		if(stage_times.Find(I.id_tag))
			dat += "<td>[ticks_this_stage]/[stage_times[I.id_tag]]s <a href='?src=\ref[src];stage_time=[I.id_tag]'>Modify</td>"
		else
			dat += "<td>[ticks_this_stage]s <a href='?src=\ref[src];stage_time=[I.id_tag]'>Set</td>"
		if(proceeding_stages.Find(I.id_tag))
			dat += "<td><a href='?src=\ref[src];set_next_stage=[I.id_tag]'>[proceeding_stages[I.id_tag]]</a></td>"
		else
			dat += "<td>None <a href='?src=\ref[src];set_next_stage=[I.id_tag]'>\[modify\]</a></td>"
		dat += "<td><a href='?src=\ref[src];toggle_stage=[I.id_tag]'>\[[active_stages.Find(I.id_tag) ? "Deactivate stage" : "Activate stage "] \]</a></td>"
		dat += "</tr>"
	dat += "</table>"

	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</A> "
	dat += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	user << browse(dat, "window=fuel_control;size=800x400")
	user.set_machine(src)

/obj/machinery/computer/rust_fuel_control/Topic(href, href_list)
	..()

	if( href_list["scan"] )
		connected_injectors = list()
		for(var/obj/machinery/power/rust_fuel_injector/I in range(scan_range, src))
			if(check_injector_status(I))
				connected_injectors.Add(I)

	if( href_list["toggle_stage"] )
		var/cur_stage = href_list["toggle_stage"]
		if(active_stages.Find(cur_stage))
			active_stages.Remove(cur_stage)
			for(var/obj/machinery/power/rust_fuel_injector/I in connected_injectors)
				if(I.id_tag == cur_stage && check_injector_status(I))
					I.StopInjecting()
		else
			active_stages.Add(cur_stage)
			for(var/obj/machinery/power/rust_fuel_injector/I in connected_injectors)
				if(I.id_tag == cur_stage && check_injector_status(I))
					I.BeginInjecting()

	if( href_list["cooldown"] )
		for(var/obj/machinery/power/rust_fuel_injector/I in connected_injectors)
			if(check_injector_status(I))
				I.StopInjecting()
		active_stages = list()

	if( href_list["warmup"] )
		for(var/obj/machinery/power/rust_fuel_injector/I in connected_injectors)
			if(check_injector_status(I))
				I.BeginInjecting()
			if(!active_stages.Find(I.id_tag))
				active_stages.Add(I.id_tag)

	if( href_list["stage_time"] )
		var/cur_stage = href_list["stage_time"]
		var/new_duration = input("Enter new stage duration in seconds", "Stage duration") as num
		if(new_duration)
			stage_times[cur_stage] = new_duration
		else if(stage_times.Find(cur_stage))
			stage_times.Remove(cur_stage)

	if( href_list["announce_fueldepletion"] )
		announce_fueldepletion = text2num(href_list["announce_fueldepletion"])

	if( href_list["announce_stageprogression"] )
		announce_stageprogression = text2num(href_list["announce_stageprogression"])

	if( href_list["close"] )
		usr << browse(null, "window=fuel_control")
		usr.unset_machine()

	if( href_list["set_next_stage"] )
		var/cur_stage = href_list["set_next_stage"]
		if(!proceeding_stages.Find(cur_stage))
			proceeding_stages.Add(cur_stage)
		var/next_stage = input("Enter next stage ID", "Automated stage procession") as text|null
		if(next_stage)
			proceeding_stages[cur_stage] = next_stage
		else
			proceeding_stages.Remove(cur_stage)

	updateDialog()

/obj/machinery/computer/rust_fuel_control/proc/check_injector_status(var/obj/machinery/power/rust_fuel_injector/I)
	if(!I)
		return 0

	if(I.stat & (BROKEN|NOPOWER) || !I.remote_access_enabled || !I.id_tag)
		if(connected_injectors.Find(I))
			connected_injectors.Remove(I)
		return 0

	return 1
