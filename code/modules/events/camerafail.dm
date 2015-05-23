/datum/round_event_control/camerafail
	name = "Major Camera Failure"
	typepath = /datum/round_event/camfail
	weight = 50
	max_occurrences = 100
	earliest_start = 20
	alertadmins = 1

/datum/round_event/camfail
	startWhen		= 0
	endWhen			= 2
	announceWhen	= 1
	var/maxfailures = 50

/datum/round_event/camfail/announce()
	priority_announce("Unwarranted recording software detected in [station_name()]'s camera network, remotely disabling affected cameras","Camera Shutdown Alert")


/datum/round_event/camfail/start()
	var/disabledcount = 0
	for( var/obj/machinery/camera/C in world)
		if((C.z == 1) && !(C.inborg == 1))
			if( !(disabledcount > maxfailures))
				if(prob(10) && (C.status))
					C.status = !(C.status)
					C.icon_state = "[initial(C.icon_state)]1"
					C.visible_message("<span class='danger'> \The [C] deactivates! </span>")
					disabledcount++
				else if(prob(10))
					C.emp_act(1)
					disabledcount++


/datum/round_event/camfail/tick()
	return

//camera event small version

/datum/round_event_control/camerafail/mini
	name = "Minor Camera Failure"
	typepath = /datum/round_event/camfail/mini
	weight = 100
	max_occurrences = 1000
	earliest_start = 0
	alertadmins = 0

/datum/round_event/camfail/mini/announce()
	return

/datum/round_event/camfail/mini
	maxfailures = 5