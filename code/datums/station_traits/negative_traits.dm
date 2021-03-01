/datum/station_trait/carp_infestation
	name = "Carp infestation"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Dangerous fauna is present in the area of this station"
	trait_to_give = STATION_TRAIT_CARP_INFESTATION

/datum/station_trait/distant_supply_lines
	name = "Distant supply lines"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Due to the distance to our normal supply lines, cargo orders are more expensive."
	blacklist = list(/datum/station_trait/strong_supply_lines)

/datum/station_trait/distant_supply_lines/on_round_start()
	SSeconomy.pack_price_modifier *= 1.2

/datum/station_trait/late_arrivals
	name = "Late Arrivals"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Sorry for that, we didn't expect to fly into that vomiting goose while bringing you to your new station."
	trait_to_give = STATION_TRAIT_LATE_ARRIVALS
	blacklist = list(/datum/station_trait/random_spawns)

/datum/station_trait/random_spawns
	name = "Drive-by landing"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "Sorry for that, we missed your station by a few miles, so we just launched you towards your station in pods. Hope you don't mind!"
	trait_to_give = STATION_TRAIT_RANDOM_ARRIVALS
	blacklist = list(/datum/station_trait/late_arrivals)

/datum/station_trait/blackout
	name = "Blackout"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	report_message = "Station lights seem to be damaged, be safe when starting your shift today."

/datum/station_trait/blackout/on_round_start()
	. = ..()
	for(var/a in GLOB.apcs_list)
		var/obj/machinery/power/apc/current_apc = a
		if(prob(60))
			current_apc.overload_lighting()

/datum/station_trait/empty_maint
	name = "Cleaned out maintenance"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Our workers cleaned out most of the junk in the maintenace areas."
	blacklist = list(/datum/station_trait/filled_maint)
	trait_to_give = STATION_TRAIT_EMPTY_MAINT


/datum/station_trait/overflow_job_bureacracy
	name = "Overflow bureacracy mistake"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 5
	show_in_report = TRUE
	var/list/jobs_to_use = list("Clown", "Bartender", "Cook", "Botanist", "Cargo Technician", "Mime", "Janitor", "Prisoner")
	var/chosen_job

/datum/station_trait/overflow_job_bureacracy/New()
	. = ..()
	chosen_job = pick(jobs_to_use)
	RegisterSignal(SSjob, COMSIG_SUBSYSTEM_POST_INITIALIZE, .proc/set_overflow_job_override)

/datum/station_trait/overflow_job_bureacracy/get_report()
	return "[name] - It seems for some reason we put out the wrong job-listing for the overflow role this shift...I hope you like [chosen_job]s."

/datum/station_trait/overflow_job_bureacracy/proc/set_overflow_job_override(datum/source, new_overflow_role)
	SIGNAL_HANDLER
	SSjob.set_overflow_role(chosen_job)

/datum/station_trait/slow_shuttle
	name = "Slow Shuttle"
	trait_type = STATION_TRAIT_NEUTRAL
	weight = 5
	show_in_report = TRUE
	report_message = "Due to distance to our supply station, the cargo shuttle will have a slower flight time to your cargo department."
	blacklist = list(/datum/station_trait/quick_shuttle)

/datum/station_trait/slow_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 1.5

/datum/station_trait/dufflebags
	name = "Dufflebags"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 3
	show_in_report = TRUE
	trait_to_give = STATION_TRAIT_DUFFLEBAGS

/datum/station_trait/dufflebags/New()
	. = ..()
	report_message = pick(list(
		"Nanotrasen are interested if the higher volume of dufflebags affect employee productivity; thus all crewmembers have been equipped with them.",
		"Today's shift is sponsored by DuffleCo.",
		"An ambassador from the Wizard Federation broke into the employee equipment factory, but only replaced all the bags with dufflebags.",
		"Cloning is illegal; Nanotrasen doesn't clone new employees; Nanotrasen didn't make a mistake with the cloning template making everyone irrationally prefer dufflebags.",
		"In a bid to drive up sales of satchels and backpacks, the Nanotrasen Economic Divison has made dufflebags the mandatory shiftstart equipment selection.",
		"u a big man and need a big bag",
		"dufflebags cost the company less and therefore are in your best interest to have because you love the company dont you? you wouldnt want to cause us pain? you arent a bad person and love helping the company yes?",
		"We want you to and that is enough reason.",
		"Someone on the Commander team keeps trying to have \"duffleskirt\" catch on. To shut them up, we're making you all have dufflebags this shift.",
	))
