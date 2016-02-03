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

/obj/docking_port/mobile/supply/New()
	..()
	SSshuttle.supply = src

/obj/docking_port/mobile/supply/canMove()
	if(z == ZLEVEL_STATION)
		return forbidden_atoms_check(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock()
	. = ..()
	if(.)
		return .

	buy()
	sell()

/obj/docking_port/mobile/supply/proc/buy()
	if(z != ZLEVEL_STATION)		//we only buy when we are -at- the station
		return 1

	if(!SSshuttle.shoppinglist.len)
		return 2

	var/list/emptyTurfs = list()
	for(var/turf/simulated/floor/T in areaInstance)
		if(T.density || T.contents.len)
			continue
		emptyTurfs += T

	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!SO.object)
			continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			SSshuttle.shoppinglist.Cut(1, SSshuttle.shoppinglist.Find(SO))
			return

		var/errors = 0
		if(prob(5))
			errors |= MANIFEST_ERROR_COUNT
		if(prob(5))
			errors |= MANIFEST_ERROR_NAME
		if(prob(5))
			errors |= MANIFEST_ERROR_ITEM
		SO.createObject(T, errors)

	SSshuttle.shoppinglist.Cut()


/obj/docking_port/mobile/supply/proc/sell()
	if(z != ZLEVEL_CENTCOM)		//we only sell when we are -at- centcomm
		return 1

	var/plasma_count = 0
	var/intel_count = 0
	var/crate_count = 0

	var/msg = ""
	var/pointsEarned

	for(var/atom/movable/MA in areaInstance)
		if(MA.anchored)
			continue
		SSshuttle.sold_atoms += " [MA.name]"

		// Must be in a crate (or a critter crate)!
		if(istype(MA,/obj/structure/closet/crate) || istype(MA,/obj/structure/closet/critter))
			SSshuttle.sold_atoms += ":"
			if(!MA.contents.len)
				SSshuttle.sold_atoms += " (empty)"
			++crate_count

			var/find_slip = 1
			for(var/thing in MA)
				// Sell manifests
				SSshuttle.sold_atoms += " [thing:name]"
				if(find_slip && istype(thing,/obj/item/weapon/paper/manifest))
					var/obj/item/weapon/paper/manifest/slip = thing
					// TODO: Check for a signature, too.
					if(slip.stamped && slip.stamped.len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						// Did they mark it as erroneous?
						var/denied = 0
						for(var/i=1,i<=slip.stamped.len,i++)
							if(slip.stamped[i] == /obj/item/weapon/stamp/denied)
								denied = 1
						if(slip.erroneous && denied) // Caught a mistake by Centcom (IDEA: maybe Centcom rarely gets offended by this)
							pointsEarned = slip.points - SSshuttle.points_per_crate
							SSshuttle.points += pointsEarned // For now, give a full refund for paying attention (minus the crate cost)
							msg += "<font color=green>+[pointsEarned]</font>: Station correctly denied package [slip.ordernumber]: "
							if(slip.erroneous & MANIFEST_ERROR_NAME)
								msg += "Destination station incorrect. "
							else if(slip.erroneous & MANIFEST_ERROR_COUNT)
								msg += "Packages incorrectly counted. "
							else if(slip.erroneous & MANIFEST_ERROR_ITEM)
								msg += "Package incomplete. "
							msg += "Points refunded.<BR>"
						else if(!slip.erroneous && !denied) // Approving a proper order awards the relatively tiny points_per_slip
							SSshuttle.points += SSshuttle.points_per_slip
							msg += "<font color=green>+[SSshuttle.points_per_slip]</font>: Package [slip.ordernumber] accorded.<BR>"
						else // You done goofed.
							if(slip.erroneous)
								msg += "<font color=red>+0</font>: Station approved package [slip.ordernumber] despite error: "
								if(slip.erroneous & MANIFEST_ERROR_NAME)
									msg += "Destination station incorrect."
								else if(slip.erroneous & MANIFEST_ERROR_COUNT)
									msg += "Packages incorrectly counted."
								else if(slip.erroneous & MANIFEST_ERROR_ITEM)
									msg += "We found unshipped items on our dock."
								msg += "  Be more vigilant.<BR>"
							else
								pointsEarned = round(SSshuttle.points_per_crate - slip.points)
								SSshuttle.points += pointsEarned
								msg += "<font color=red>[pointsEarned]</font>: Station denied package [slip.ordernumber].  Our records show no fault on our part.<BR>"
						find_slip = 0
					continue

				// Sell plasma
				if(istype(thing, /obj/item/stack/sheet/mineral/plasma))
					var/obj/item/stack/sheet/mineral/plasma/P = thing
					plasma_count += P.amount

				// Sell syndicate intel
				if(istype(thing, /obj/item/documents/syndicate))
					++intel_count

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
						msg += "<font color=green>+[cost]</font>: [tech.name] - new data.<BR>"

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
						msg += "<font color=green>+[SSshuttle.points_per_design]</font>: Reliable [design.name] design.<BR>"

				// Sell exotic plants
				if(istype(thing, /obj/item/seeds))
					var/obj/item/seeds/S = thing
					if(S.rarity == 0) // Mundane species
						msg += "<font color=red>+0</font>: We don't need samples of mundane species \"[capitalize(S.species)]\".<BR>"
					else if(SSshuttle.discoveredPlants[S.type]) // This species has already been sent to CentComm
						var/potDiff = S.potency - SSshuttle.discoveredPlants[S.type] // Compare it to the previous best
						if(potDiff > 0) // This sample is better
							SSshuttle.discoveredPlants[S.type] = S.potency
							msg += "<font color=green>+[potDiff]</font>: New sample of \"[capitalize(S.species)]\" is superior.  Good work.<BR>"
							SSshuttle.points += potDiff
						else // This sample is worthless
							msg += "<font color=red>+0</font>: New sample of \"[capitalize(S.species)]\" is not more potent than existing sample ([SSshuttle.discoveredPlants[S.type]] potency).<BR>"
					else // This is a new discovery!
						SSshuttle.discoveredPlants[S.type] = S.potency
						msg += "<font color=green>+[S.rarity]</font>: New species discovered: \"[capitalize(S.species)]\".  Excellent work.<BR>"
						SSshuttle.points += S.rarity // That's right, no bonus for potency.  Send a crappy sample first to "show improvement" later
		qdel(MA)
		SSshuttle.sold_atoms += "."

	if(plasma_count > 0)
		pointsEarned = round(plasma_count * SSshuttle.points_per_plasma)
		msg += "<font color=green>+[pointsEarned]</font>: Received [plasma_count] unit(s) of exotic material.<BR>"
		SSshuttle.points += pointsEarned

	if(intel_count > 0)
		pointsEarned = round(intel_count * SSshuttle.points_per_intel)
		msg += "<font color=green>+[pointsEarned]</font>: Received [intel_count] article(s) of enemy intelligence.<BR>"
		SSshuttle.points += pointsEarned

	if(crate_count > 0)
		pointsEarned = round(crate_count * SSshuttle.points_per_crate)
		msg += "<font color=green>+[pointsEarned]</font>: Received [crate_count] crate(s).<BR>"
		SSshuttle.points += pointsEarned

	SSshuttle.centcom_message = msg


/proc/forbidden_atoms_check(atom/A)
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
	if(A)
		if(is_type_in_list(A, blacklist))
			return 1
		for(var/thing in A)
			if(.(thing))
				return 1

	return 0


