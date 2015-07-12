/datum/round_event_control/vent_clog
	name = "Clogged Vents"
	typepath = /datum/round_event/vent_clog
	weight = 35

/datum/round_event/vent_clog
	announceWhen	= 1
	startWhen		= 5
	endWhen			= 35
	var/interval 	= 2
	var/list/vents  = list()

/datum/round_event/vent_clog/announce()
	priority_announce("The scrubbers network is experiencing a backpressure surge. Some ejection of contents may occur.", "Atmospherics alert")


/datum/round_event/vent_clog/setup()
	endWhen = rand(25, 100)
<<<<<<< HEAD
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in machines)
		if(temp_vent.loc.z == ZLEVEL_STATION)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents["p1"]
			if(temp_vent_parent.other_atmosmch.len > 20)
=======
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/temp_vent in machines)
		if(temp_vent.loc.z == ZLEVEL_STATION && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 20)
>>>>>>> remotes/upstream/master
				vents += temp_vent
	if(!vents.len)
		return kill()

/datum/round_event/vent_clog/tick()
	if(activeFor % interval == 0)
		var/obj/vent = pick_n_take(vents)
		if(vent && vent.loc)
			var/list/gunk = list("water","carbon","flour","radium","toxin","cleaner","nutriment","condensedcapsaicin","mushroomhallucinogen","lube",
								 "plantbgone","banana","charcoal","space_drugs","morphine","holywater","ethanol","hot_coco","facid")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = vent
			R.add_reagent(pick(gunk), 50)

			var/datum/effect/effect/system/smoke_spread/chem/smoke = new
			smoke.set_up(R, rand(1, 2), 0, vent, 0, silent = 1)
			playsound(vent.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)