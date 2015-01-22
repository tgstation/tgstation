/obj/machinery/sleep_console
	name = "sleeper console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "console"
	anchored = 1	//About time someone fixed this.
	density = 0

/obj/machinery/sleeper
	name = "sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper-open"
	density = 0
	anchored = 1
	state_open = 1
	var/efficiency
	var/initial_bin_rating = 1
	var/min_health = 25
	var/timing = 0
	var/timeleft = 0
	var/releasetime = 0

/obj/machinery/sleeper/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/sleeper(null)

	// Customizable bin rating, used by the labor camp to stop people filling themselves with chemicals and escaping.
	var/obj/item/weapon/stock_parts/matter_bin/B = new(null)
	B.rating = initial_bin_rating
	component_parts += B

	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()
	SSobj.processing.Add(src)

/obj/machinery/sleeper/RefreshParts()
	var/E
	var/I
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		I += M.rating

	efficiency = E
	min_health = -E * 25

/obj/machinery/sleeper/allow_drop()
	return 0

/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(stat || user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user)|| !iscarbon(target))
		return
	close_machine(target)

/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A in src)
			A.loc = loc
			A.blob_act()
		qdel(src)

/obj/machinery/sleeper/attack_animal(var/mob/living/simple_animal/M)//Stop putting hostile mobs in things guise
	if(M.environment_smash)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>[M.name] smashes [src] apart!</span>")
		qdel(src)
	return

/obj/machinery/sleeper/attackby(obj/item/I, mob/user)
	if(!state_open && !occupant)
		if(default_deconstruction_screwdriver(user, "sleeper-o", "sleeper", I))
			return

	if(default_change_direction_wrench(user, I))
		return

	if(exchange_parts(user, I))
		return

	if(default_pry_open(I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/sleeper/ex_act(severity, target)
	go_out()
	..()

/obj/machinery/sleeper/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..(severity)

/obj/machinery/sleeper/proc/go_out()
	if(!occupant)
		return
	for(var/atom/movable/O in src)
		O.loc = loc
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant = null
	icon_state = "sleeper-open"

/obj/machinery/sleeper/container_resist()
	open_machine()

/obj/machinery/sleeper/relaymove(var/mob/user)
	..()
	open_machine()

/obj/machinery/sleeper/attack_hand(mob/user)
	if(..())
		return

	sleeperUI(user)

/obj/machinery/sleeper/proc/sleeperUI(mob/user)
	var/second = round(timeleft() % 60)
	var/minute = round((timeleft() - second) / 60)
	var/dat = "<HTML><BODY><TT>"

	dat += "<HR>Autosleeper Timer</hr> <br/>"
	if (timing)
		dat += "<a href='?src=\ref[src];timing=0'>Stop Timer and open door</a><br/>"
	else
		dat += "<a href='?src=\ref[src];timing=1'>Activate Timer and close door</a><br/>"

	dat += "Time Left: [(minute ? text("[minute]:") : null)][second] <br/>"
	dat += "<a href='?src=\ref[src];tp=-60'>-</a> <a href='?src=\ref[src];tp=-1'>-</a> <a href='?src=\ref[src];tp=1'>+</a> <A href='?src=\ref[src];tp=60'>+</a><br/>"
	dat += "</TT></BODY></HTML>"

	dat += "<h3>Sleeper Status</h3>"
	dat += "<A href='?src=\ref[src];refresh=1'>Scan</A>"
	dat += "<A href='?src=\ref[src];[state_open ? "close=1'>Close</A>" : "open=1'>Open</A>"]"
	dat += "<div class='statusDisplay'>"
	if(!occupant)
		dat += "Sleeper Unoccupied"
	else
		dat += "[occupant.name] => "
		switch(occupant.stat)	//obvious, see what their status is
			if(0)
				dat += "<span class='good'>Conscious</span>"
			if(1)
				dat += "<span class='average'>Unconscious</span>"
			else
				dat += "<span class='bad'>DEAD</span>"
		dat += "<br />"
		dat +=  "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health < 0 ? "0" : "[occupant.health]"]%;' class='progressFill good'></div></div><div class='statusValue'>[occupant.stat > 1 ? "" : "[occupant.health]%"]</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Brute Damage:</div><div class='progressBar'><div style='width: [occupant.getBruteLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getBruteLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Resp. Damage:</div><div class='progressBar'><div style='width: [occupant.getOxyLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getOxyLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Toxin Content:</div><div class='progressBar'><div style='width: [occupant.getToxLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getToxLoss()]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Burn Severity:</div><div class='progressBar'><div style='width: [occupant.getFireLoss()]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.getFireLoss()]%</div></div>"

		dat += "<HR><div class='line'><div class='statusLabel'>Paralysis Summary:</div><div class='statusValue'>[round(occupant.paralysis)]% [occupant.paralysis ? "([round(occupant.paralysis / 4)] seconds left)" : ""]</div></div>"
		if(occupant.getCloneLoss())
			dat += "<div class='line'><span class='average'>Subject appears to have cellular damage.</span></div>"
		if(occupant.getBrainLoss())
			dat += "<div class='line'><span class='average'>Significant brain damage detected.</span></div>"
		if(occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in occupant.reagents.reagent_list)
				dat += text("<div class='line'><div class='statusLabel'>[R.name]:</div><div class='statusValue'>[] units</div></div>", round(R.volume, 0.1))
	dat += "</div>"

	var/datum/browser/popup = new(user, "sleeper", "Sleeper Console", 520, 540)	//Set up the popup browser window
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(dat)
	popup.open()

/obj/machinery/sleeper/Topic(href, href_list)
	if(..() || usr == occupant)
		return
	usr.set_machine(src)

	if(href_list["timing"]) //switch between timing and not timing
		var/timeleft = timeleft()
		timeleft = min(max(round(timeleft), 0), 600)
		timing = text2num(href_list["timing"])
		timeset(timeleft)
	else if(href_list["tp"]) //adjust timer
		var/timeleft = timeleft()
		var/tp = text2num(href_list["tp"])
		timeleft += tp
		timeleft = min(max(round(timeleft), 0), 600)
		timeset(timeleft)

	if(href_list["refresh"])
		updateUsrDialog()
		return
	if(href_list["open"])
		open_machine()
		return
	if(href_list["close"])
		close_machine()
		return
	updateUsrDialog()
	add_fingerprint(usr)

/obj/machinery/sleeper/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/sleeper/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		..()

/obj/machinery/sleeper/close_machine(mob/target)
	if(state_open && !panel_open)
		..(target)

/obj/machinery/sleeper/update_icon()
	if(state_open)
		icon_state = "sleeper-open"
	else
		icon_state = "sleeper"

/obj/machinery/sleeper/process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(!timing)
		return
	if(timeleft() && occupant)
		occupant.paralysis = timeleft
		timeleft -= 10
		if(occupant.reagents.get_reagent_amount("salglu_solution") < 25)
			occupant.reagents.add_reagent("salglu_solution", 5)
	else if(!timeleft() && occupant)
		occupant.paralysis = 0
		go_out()

/obj/machinery/sleeper/proc/timeset(var/seconds)
	if(timing)
		releasetime=world.time+seconds*10
	else
		timeleft=seconds*10
	return

/obj/machinery/sleeper/proc/timeleft()
	. = (timing ? (releasetime-world.time) : timeleft)/10
	if(. < 0)
		. = 0