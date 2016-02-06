/obj/item/weapon/paper/manifest
	name = "supply manifest"
	var/erroneous = 0
	var/points = 0
	var/ordernumber = 0

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 1200

	dir = 8
	travelDir = 90
	width = 12
	dwidth = 5
	height = 7
	roundstart_move = "supply_away"

	var/list/blacklist = list(
		/mob/living,
		/obj/effect/blob,
		/obj/effect/rune,
		/obj/effect/spider/spiderling,
		/obj/item/weapon/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/device/radio/beacon,
		/obj/machinery/the_singularitygen,
		/obj/singularity,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/telepad,
		/obj/machinery/clonepod
	)

/obj/docking_port/mobile/supply/New()
	..()
	SSshuttle.supply = src

/obj/docking_port/mobile/supply/canMove()
	if(z == ZLEVEL_STATION)
		return check_blacklist(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(atom/A)
	if(is_type_in_list(A, blacklist))
		return 1
	for(var/thing in A)
		if(.(thing))
			return 1

/obj/docking_port/mobile/supply/request()
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock()
	if(getDockedId() == "supply_away") // Buy when we leave home.
		buy()
	if(..()) // Fly/enter transit.
		return
	if(getDockedId() == "supply_away") // Sell when we get home
		sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(!SSshuttle.shoppinglist.len)
		return

	var/list/emptyTurfs = list()
	for(var/turf/simulated/floor/T in areaInstance)
		if(T.density || T.contents.len)
			continue
		emptyTurfs += T

	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!SO.object)
			continue
		if(SO.object.cost > SSshuttle.points)
			continue

		var/errors = 0
		if(prob(5))
			errors |= MANIFEST_ERROR_COUNT
		if(prob(5))
			errors |= MANIFEST_ERROR_NAME
		if(prob(5))
			errors |= MANIFEST_ERROR_ITEM

		var/turf/T = pick_n_take(emptyTurfs)
		SO.createObject(T, errors)

		SSshuttle.points -= SO.object.cost
		SSshuttle.shoppinglist -= SO

/obj/docking_port/mobile/supply/proc/sell()
	var/crates = 0
	var/plasma = 0
	var/intel = 0

	var/msg = ""
	var/pointsEarned = 0

	for(var/atom/movable/AM in areaInstance)
		if(AM.anchored)
			continue
		SSshuttle.sold_atoms += " [AM.name]"

		if(istype(AM, /obj/structure/closet/crate) || istype(AM, /obj/structure/closet/critter))
			crates++
			SSshuttle.sold_atoms += ":"
			if(!AM.contents.len)
				SSshuttle.sold_atoms += " (empty)"
			else
				var/slip_found = FALSE
				for(var/atom/movable/thing in AM)
					SSshuttle.sold_atoms += " [thing.name]"
					if(!slip_found && istype(thing, /obj/item/weapon/paper/manifest))
						var/obj/item/weapon/paper/manifest/slip = thing
						if(slip.stamped && slip.stamped.len)
							slip_found = TRUE
							var/denied = FALSE
							for(var/stamp in slip.stamped)
								if(stamp == /obj/item/weapon/stamp/denied)
									denied = TRUE
									break
							if(slip.erroneous && denied) // Caught a mistake by Centcom.
								pointsEarned = slip.points - SSshuttle.points_per_crate
								SSshuttle.points += pointsEarned // Give a full refund (minus the crate).
								msg += "[pointsEarned]: Station correctly denied package [slip.ordernumber]: "
								if(slip.erroneous & MANIFEST_ERROR_NAME)
									msg += "Destination station incorrect. "
								else if(slip.erroneous & MANIFEST_ERROR_COUNT)
									msg += "Packages incorrectly counted. "
								else if(slip.erroneous & MANIFEST_ERROR_ITEM)
									msg += "Package incomplete. "
								msg += "Points refunded."
							else if(!slip.erroneous && !denied) // Approved a slip correctly.
								pointsEarned = SSshuttle.points_per_slip
								SSshuttle.points += pointsEarned
								msg += "+[pointsEarned]: Package [slip.ordernumber] accorded."
							else if(slip.erroneous) // You done goofed.
								pointsEarned = -SSshuttle.points_per_slip
								SSshuttle.points += pointsEarned
								msg += "[pointsEarned]: Station erroneously approved package [slip.ordernumber]: "
								if(slip.erroneous & MANIFEST_ERROR_NAME)
									msg += "Destination station incorrect."
								else if(slip.erroneous & MANIFEST_ERROR_COUNT)
									msg += "Packages incorrectly counted."
								else if(slip.erroneous & MANIFEST_ERROR_ITEM)
									msg += "We found unshipped items on our dock."
								msg += " Be more vigilant."
							else
								pointsEarned = round(SSshuttle.points_per_crate - slip.points)
								SSshuttle.points += pointsEarned
								msg += "[pointsEarned]: Station erroneously denied package [slip.ordernumber]."

					// Sell plasma
					if(istype(thing, /obj/item/stack/sheet/mineral/plasma))
						var/obj/item/stack/sheet/mineral/plasma/P = thing
						plasma += P.amount

					// Sell syndicate intel
					if(istype(thing, /obj/item/documents/syndicate))
						intel++

					// Sell tech levels
					if(istype(thing, /obj/item/weapon/disk/tech_disk))
						var/obj/item/weapon/disk/tech_disk/disk = thing
						if(!disk.stored)
							continue
						var/datum/tech/tech = disk.stored

						var/cost = tech.getCost(SSshuttle.techLevels[tech.id])
						if(cost)
							SSshuttle.techLevels[tech.id] = tech.level
							SSshuttle.points += cost
							msg += "+[cost]: Data: [tech.name]."

					// Sell max reliablity designs
					if(istype(thing, /obj/item/weapon/disk/design_disk))
						var/obj/item/weapon/disk/design_disk/disk = thing
						if(!disk.blueprint)
							continue
						var/datum/design/design = disk.blueprint
						if(design.id in SSshuttle.researchDesigns)
							continue

						if(initial(design.reliability) < 100 && design.reliability >= 100)
							// Maxed out reliability designs only.
							SSshuttle.points += SSshuttle.points_per_design
							SSshuttle.researchDesigns += design.id
							msg += "+[SSshuttle.points_per_design]: Design: [design.name]."

					// Sell exotic plants
					if(istype(thing, /obj/item/seeds))
						var/obj/item/seeds/S = thing
						if(S.rarity == 0) // Mundane species
							msg += "+0: We don't need samples of mundane species \"[capitalize(S.species)]\"."
						else if(SSshuttle.discoveredPlants[S.type]) // This species has already been sent to CentComm
							var/potDiff = S.potency - SSshuttle.discoveredPlants[S.type] // Compare it to the previous best
							if(potDiff > 0) // This sample is better
								SSshuttle.discoveredPlants[S.type] = S.potency
								msg += "+[potDiff]: New sample of \"[capitalize(S.species)]\" is superior.  Good work."
								SSshuttle.points += potDiff
							else // This sample is worthless
								msg += "+0: New sample of \"[capitalize(S.species)]\" is not more potent than existing sample ([SSshuttle.discoveredPlants[S.type]] potency)."
						else // This is a new discovery!
							SSshuttle.discoveredPlants[S.type] = S.potency
							msg += "[S.rarity]: New species discovered: \"[capitalize(S.species)]\".  Excellent work."
							SSshuttle.points += S.rarity // That's right, no bonus for potency.  Send a crappy sample first to "show improvement" later
					qdel(thing)
		qdel(AM)
		SSshuttle.sold_atoms += "."

	if(plasma > 0)
		pointsEarned = round(plasma * SSshuttle.points_per_plasma)
		msg += "[pointsEarned]: Received [plasma] unit(s) of exotic material."
		SSshuttle.points += pointsEarned

	if(intel > 0)
		pointsEarned = round(intel * SSshuttle.points_per_intel)
		msg += "[pointsEarned]: Received [intel] article(s) of enemy intelligence."
		SSshuttle.points += pointsEarned

	if(crates > 0)
		pointsEarned = round(crates * SSshuttle.points_per_crate)
		msg += "+[pointsEarned]: Received [crates] crate(s)."
		SSshuttle.points += pointsEarned

	SSshuttle.centcom_message = msg
