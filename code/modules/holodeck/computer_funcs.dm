/obj/machinery/computer/holodeck/attack_hand(var/mob/user as mob)
	user.set_machine(src)

	var/dat = "<h3>Current Loaded Programs</h3>"
	dat += "<a href='?src=\ref[src];loadarea=[offline_program.type]'>Power Off</a><br>"
	for(var/area/A in program_cache)
		dat += "<a href='?src=\ref[src];loadarea=[A.type]'>[A.name]</a><br>"
	if(emagged && emag_programs.len)
		dat += "<span class='warning'>SUPERVISOR ACCESS - SAFETY PROTOCOLS DISABLED - CAUTION: EMITTER ANOMALY</span><br>"
		for(var/area/A in emag_programs)
			dat += "<a href='?src=\ref[src];loadarea=[A.type]'>[A.name]</a><br>"

	var/datum/browser/popup = new(user, "computer", name, 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/holodeck/attack_ai(var/mob/user as mob)
	var/dat = "<h3>Current Loaded Programs</h3>"

	dat += "<a href='?src=\ref[src];loadarea=[offline_program.type]'>Power Off</a><br>"
	for(var/area/A in program_cache)
		dat += "<a href='?src=\ref[src];loadarea=[A.type]'>[A.name]</a><br>"

	if(emag_programs.len)
		dat += "<br>"
		if(emagged)
			dat += "Safety protocol: <span class='bad'>Offline</span> <a href='?\ref[src];safety=1'>Engage</a><br>"
			for(var/area/A in emag_programs)
				dat += "<a href='?src=\ref[src];loadarea=[A.type]'>[A.name]</a><br>"
		else
			dat += "Safety protocol: <span class='good'>Online</span> <a href='?\ref[src];safety=0'>Disengage</a><br>"

	var/datum/browser/popup = new(user, "computer", name, 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()


/obj/machinery/computer/holodeck/proc/load_program(var/area/A, var/force = 0, var/delay = 0)
	if(stat)
		A = offline_program
		force = 1
		delay = 0
	if(program == A)
		return
	if(world.time < (last_change + 25 + (damaged?500:0)) && !force)
		if(delay)
			sleep(25)
		else
			if(world.time < (last_change + 15))//To prevent super-spam clicking, reduced process size and annoyance -Sieve
				return
			if(get_dist(usr,src) <= 3)
				usr << "<span class='warning'>ERROR. Recalibrating projection apparatus.</span>"
				return

	last_change = world.time
	active = (A != offline_program)
	use_power = active+1

	for(var/obj/effect/holodeck_effect/HE in effects)
		HE.deactivate(src)

	for(var/item in spawned)
		derez(item, forced=force)

	program = A
	// note nerfing does not yet work on guns, should
	// should also remove/limit/filter reagents?
	// this is an exercise left to others I'm afraid.  -Sayu
	spawned = A.copy_contents_to(linked, 1, nerf_weapons = !emagged)
	for(var/obj/machinery/M in spawned)
		M.flags |= NODECONSTRUCT
	for(var/obj/structure/S in spawned)
		S.flags |= NODECONSTRUCT
	effects = list()

	spawn(30)
		var/list/added = list()
		for(var/obj/effect/holodeck_effect/HE in spawned)
			effects += HE
			spawned -= HE
			var/atom/x = HE.activate(src)
			if(istype(x) || islist(x))
				spawned += x // holocarp are not forever
				added += x
		for(var/obj/machinery/M in added)
			M.flags |= NODECONSTRUCT
		for(var/obj/structure/S in added)
			S.flags |= NODECONSTRUCT

/obj/machinery/computer/holodeck/proc/derez(var/obj/obj, var/silent = 1, var/forced = 0)
	// Emagging a machine creates an anomaly in the derez systems.
	if(obj && src.emagged && !src.stat && !forced)
		if((ismob(obj) || istype(obj.loc,/mob)) && prob(50))
			spawn(50) .(obj,silent) // may last a disturbingly long time
			return
	spawned.Remove(obj)

	if(!obj)
		return
	var/turf/T = get_turf(obj)
	for(var/atom/movable/AM in obj.contents) // these should be derezed if they were generated
		AM.loc = T
		if(ismob(AM))
			silent = FALSE					// otherwise make sure they are dropped

	if(!silent)
		visible_message("The [obj.name] fades away!")
	qdel(obj)