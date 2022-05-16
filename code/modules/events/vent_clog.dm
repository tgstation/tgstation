/datum/round_event_control/vent_clog
	name = "Clogged Vents: Normal"
	typepath = /datum/round_event/vent_clog
	weight = 10
	max_occurrences = 3
	min_players = 10

/datum/round_event/vent_clog
	announceWhen = 1
	startWhen = 5
	endWhen = 35
	var/interval = 2
	var/list/vents = list()
	var/random_probability = 1
	var/reagents_amount = 50
	var/list/safer_chems = list(/datum/reagent/water,
								/datum/reagent/carbon,
								/datum/reagent/consumable/flour,
								/datum/reagent/space_cleaner,
								/datum/reagent/consumable/nutriment,
								/datum/reagent/consumable/condensedcapsaicin,
								/datum/reagent/drug/mushroomhallucinogen,
								/datum/reagent/lube,
								/datum/reagent/glitter/pink,
								/datum/reagent/cryptobiolin,
								/datum/reagent/toxin/plantbgone,
								/datum/reagent/blood,
								/datum/reagent/medicine/c2/multiver,
								/datum/reagent/drug/space_drugs,
								/datum/reagent/medicine/morphine,
								/datum/reagent/water/holywater,
								/datum/reagent/consumable/ethanol,
								/datum/reagent/consumable/hot_coco,
								/datum/reagent/toxin/acid,
								/datum/reagent/toxin/mindbreaker,
								/datum/reagent/toxin/rotatium,
								/datum/reagent/bluespace,
								/datum/reagent/pax,
								/datum/reagent/consumable/laughter,
								/datum/reagent/concentrated_barbers_aid,
								/datum/reagent/baldium,
								/datum/reagent/colorful_reagent,
								/datum/reagent/peaceborg/confuse,
								/datum/reagent/peaceborg/tire,
								/datum/reagent/consumable/salt,
								/datum/reagent/consumable/ethanol/beer,
								/datum/reagent/hair_dye,
								/datum/reagent/consumable/sugar,
								/datum/reagent/glitter/white,
								/datum/reagent/growthserum)
	//needs to be chemid unit checked at some point

/datum/round_event/vent_clog/announce()
	priority_announce("The scrubbers network is experiencing a backpressure surge. Some ejection of contents may occur.", "Atmospherics alert")

/datum/round_event/vent_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in GLOB.machines)
		var/turf/T = get_turf(temp_vent)
		if(T && is_station_level(T.z) && !temp_vent.welded)
			vents += temp_vent
	if(!vents.len)
		return kill()

/datum/round_event/vent_clog/start()
	for(var/obj/machinery/atmospherics/components/unary/vent in vents)
		if(vent && vent.loc)
			var/datum/reagents/dispensed_reagent = new/datum/reagents(1000)
			dispensed_reagent.my_atom = vent
			if (prob(random_probability))
				dispensed_reagent.add_reagent(get_random_reagent_id(), reagents_amount)
			else
				dispensed_reagent.add_reagent(pick(safer_chems), reagents_amount)

			dispensed_reagent.create_foam(/datum/effect_system/fluid_spread/foam, 50)

			var/cockroaches = prob(25) ? 2 : 0
			while(cockroaches)
				new /mob/living/basic/cockroach(get_turf(vent))
				cockroaches--
		CHECK_TICK

/datum/round_event_control/vent_clog/threatening
	name = "Clogged Vents: Threatening"
	typepath = /datum/round_event/vent_clog/threatening
	weight = 4
	min_players = 25
	max_occurrences = 1
	earliest_start = 35 MINUTES

/datum/round_event/vent_clog/threatening
	random_probability = 10
	reagents_amount = 100

/datum/round_event_control/vent_clog/catastrophic
	name = "Clogged Vents: Catastrophic"
	typepath = /datum/round_event/vent_clog/catastrophic
	weight = 2
	min_players = 35
	max_occurrences = 1
	earliest_start = 45 MINUTES

/datum/round_event/vent_clog/catastrophic
	random_probability = 30
	reagents_amount = 150
