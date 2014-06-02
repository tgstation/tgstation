// Management of available genes.

/datum/genetree
	var/list/sectors=list()
	var/list/dependencies=list()
	var/list/dependants=list()
	var/obj/machinery/networked/biomass_controller/biomass = null

/datum/genetree/New(var/obj/machinery/networked/biomass_controller/holder)
	biomass = holder
	// Build list of all sectors
	for(var/typepath in typesof(/datum/genetic_sector) - /datum/genetic_sector)
		var/datum/genetic_sector/sector = new typepath
		sectors[sector.id]=sector

		if(sector.prerequisites.len > 0)
			sector.locked=1

			// Make list of things that depend on this sector.
			dependencies[sector.id]=sector.prerequisites

			// Generate reverse dependencies
			for(var/dependee in sector.prerequisites)
				if(!(dependee in dependants))
					dependants[dependee]=list(sector.id)
				else
					var/list/D = dependants[dependee]
					D.Add(sector.name)

/datum/genetree/proc/IsActive(var/sname)
	var/datum/genetic_sector/sector = sectors[sname]
	return sector.active

/datum/genetree/proc/CanActivateSector(var/sname)
	var/datum/genetic_sector/sector = sectors[sname]
	for(var/dep in sector.prerequisites)
		if(!IsActive(sector.id))
			return 0
	return biomass.available >= sector.required_biomass

// Does NOT check for biomass
/datum/genetree/proc/ActivateSector(var/sname)
	var/datum/genetic_sector/sector = sectors[sname]
	sector.active = 1
	sector.OnActivate()
	for(var/subsect in dependants[sname])
		var/datum/genetic_sector/subsector = sectors[subsect]
		subsector.locked=0

/datum/genetree/proc/CheckSectors()
	var/sectors_changed=0
	for(var/sname in sectors)
		var/datum/genetic_sector/sector = sectors[sname]
		var/pstate=sector.active
		sector.active=1
		for(var/prereq in sector.prerequisites)
			if(!IsActive(prereq))
				sector.active=0
				break
		if(pstate != sector.active)
			sectors_changed = 1
	if(sectors_changed)
		CheckSectors()