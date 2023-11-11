/obj/item/dousing_rod
	name = "dowsing rod"

	icon = 'goon/icons/obj/sealab_power.dmi'
	icon_state = "dowsing_hands"
	base_icon_state = "dowsing"

	w_class = WEIGHT_CLASS_SMALL

	///are we currently deployed?
	var/deployed = FALSE
	///the closest hotspot to us
	var/datum/hotspot/closest_hotspot
	///the amount of processes required to trigger its effects
	var/processes_required = 5
	///current number of processes
	var/processes = 0
	///the current heat value of our turf
	var/current_heat = 0

/obj/item/dousing_rod/Destroy(force)
	. = ..()
	closest_hotspot = null

/obj/item/dousing_rod/attack_hand(mob/user, list/modifiers)
	. = ..()
	undeploy()

/obj/item/dousing_rod/proc/deploy(turf/deploying)
	src.forceMove(deploying)
	deployed = TRUE
	START_PROCESSING(SSmachines, src)
	update_appearance()
	return_dousing()

/obj/item/dousing_rod/proc/undeploy()
	deployed = FALSE
	processes = 5
	current_heat = 0
	STOP_PROCESSING(SSmachines, src)
	update_appearance()

/obj/item/dousing_rod/process(seconds_per_tick)
	if(processes < processes_required)
		processes++
		return
	processes = 0
	return_dousing()

/obj/item/dousing_rod/proc/return_dousing()
	set_heat()
	update_appearance()
	if(current_heat == 0)
		return

	var/last_distance = INFINITY
	var/centered = FALSE
	var/turf/source_turf = get_turf(src)
	var/turf/center_turf
	for(var/datum/hotspot/listed_hotspot in SShotspots.retrieve_hotspot_list(get_turf(src)))
		center_turf = listed_hotspot.center.return_turf()

		if(source_turf == center_turf)
			centered = TRUE

		var/distance = get_dist(source_turf, center_turf)
		if(distance < last_distance)
			closest_hotspot = listed_hotspot
			last_distance = distance

	if(centered)
		say("Directly centered with one or more hotspots.")
		return

	else if(closest_hotspot && last_distance != INFINITY)
		var/dir_string = dir2text(get_dir(source_turf, center_turf))
		say("Estimated Position is:[max((last_distance - rand(1,3)), 1)]M [dir_string]")
	else
		say("ERROR: No hotspots in readable range.")

/obj/item/dousing_rod/proc/set_heat()
	//this is hellish as we also need this to deal with the ramp we have for overlapping hotspots
	//so we can either duplicate the curve, or hardset the values. IDK which is easier in this case
	//so i'm just hard setting it, as the actual graph that would deal with hotspot stacking would be a menance.
	if(src.z != SSmapping.levels_by_trait(ZTRAIT_STATION)[1])
		current_heat = 0
		return
	var/turf/return_turf = get_turf(src)
	var/total_heat = SShotspots.return_heat(return_turf)
	switch(round(total_heat))
		if(0 to 300)
			current_heat = 1
		if(301 to 450)
			current_heat = 2
		if(451 to 700)
			current_heat = 3
		if(701 to 800)
			current_heat = 4
		if(801 to 900)
			current_heat = 5
		if(901 to 1000)
			current_heat = 6
		if(1001 to 1300)
			current_heat = 7
		if(1301 to 2000)
			current_heat = 8
		if(2001 to 2400)
			current_heat = 9
		if(2401 to 3000)
			current_heat = 10
		if(3001 to 4000)
			current_heat = 11
		if(4001 to 4500)
			current_heat = 12
		if(4501 to 5300)
			current_heat = 13
		else
			current_heat = 14

/obj/item/dousing_rod/update_icon_state()
	. = ..()
	if(!deployed)
		icon_state = "dowsing_hands"
	else
		icon_state = "dowsing_deployed_[current_heat]"
