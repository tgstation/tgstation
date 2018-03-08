/datum/round_event_control/vent_clog
	name = "Clogged Vents"
	typepath = /datum/round_event/vent_clog
	weight = 25
	max_occurrences = 0
	min_players = 50

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
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			vents += temp_vent
	if(!vents.len)
		return kill()

/datum/round_event/vent_clog/start()
	for(var/obj/machinery/atmospherics/components/unary/vent in vents)
		if(vent && vent.loc)
			var/datum/reagents/R = new/datum/reagents(1000)
			R.my_atom = vent
			R.add_reagent(get_random_reagent_id(), 250)

			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(200, get_turf(vent), R)
			foam.start()

			var/cockroaches = prob(33) ? 3 : 0
			while(cockroaches)
				new /mob/living/simple_animal/cockroach(get_turf(vent))
				cockroaches--
		CHECK_TICK
