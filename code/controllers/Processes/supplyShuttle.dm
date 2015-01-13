/datum/controller/process/supplyShuttle/setup()
	name = "supply shuttle"
	schedule_interval = 300 // every 30 seconds

	for(var/typepath in (typesof(/datum/supply_packs) - /datum/supply_packs))
		var/datum/supply_packs/P = new typepath()
		supply_shuttle.supply_packs[P.name] = P

/datum/controller/process/supplyShuttle/doWork()
	if(supply_shuttle.moving == 1)
		var/ticksleft = supply_shuttle.eta_timeofday - world.timeofday

		if(ticksleft > 0)
			supply_shuttle.eta = round(ticksleft / 600, 1)
		else
			supply_shuttle.eta = 0
			supply_shuttle.send()
