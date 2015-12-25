#define LOC_KITCHEN 0
#define LOC_ATMOS 1
#define LOC_INCIN 2
#define LOC_CHAPEL 3
#define LOC_LIBRARY 4
#define LOC_HYDRO 5
#define LOC_VAULT 6
#define LOC_TECH 7

#define VERM_MICE    0
#define VERM_LIZARDS 1
#define VERM_SPIDERS 2
#define VERM_SLIMES  3
#define VERM_BATS    4
#define VERM_BORERS  5
#define VERM_MIMICS  6
#define VERM_ROACHES 7

/datum/event/infestation
	announceWhen = 15
	endWhen = 20
	var/locstring
	var/vermstring

/datum/event/infestation/start()

	var/location = pick(LOC_KITCHEN, LOC_ATMOS, LOC_INCIN, LOC_CHAPEL, LOC_LIBRARY, LOC_HYDRO, LOC_VAULT, LOC_TECH)
	var/spawn_area_type

	//TODO:  These locations should be specified by the map datum or by the area. //Area datums, any day now
	//Something like area.is_quiet=1 or map.quiet_areas=list()
	switch(location)
		if(LOC_KITCHEN)
			spawn_area_type = /area/crew_quarters/kitchen
			locstring = "the Kitchen"
		if(LOC_ATMOS)
			spawn_area_type = /area/engineering/atmos
			locstring = "Atmospherics"
		if(LOC_INCIN)
			spawn_area_type = /area/maintenance/incinerator
			locstring = "the Incinerator"
		if(LOC_CHAPEL)
			spawn_area_type = /area/chapel/main
			locstring = "the Chapel"
		if(LOC_LIBRARY)
			spawn_area_type = /area/library
			locstring = "the Library"
		if(LOC_HYDRO)
			spawn_area_type = /area/hydroponics
			locstring = "Hydroponics"
		if(LOC_VAULT)
			spawn_area_type = /area/storage/nuke_storage
			locstring = "the Vault"
		if(LOC_TECH)
			spawn_area_type = /area/storage/tech
			locstring = "Technical Storage"

	var/list/spawn_types = list()
	var/max_number = 4
	var/vermin = pick(VERM_MICE, VERM_LIZARDS, VERM_SPIDERS, VERM_SLIMES, VERM_BATS, VERM_BORERS, VERM_MIMICS)
	switch(vermin)
		if(VERM_MICE)
			spawn_types = list(/mob/living/simple_animal/mouse/gray, /mob/living/simple_animal/mouse/brown, /mob/living/simple_animal/mouse/white)
			max_number = 12
			vermstring = "mice"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/simple_animal/lizard)
			max_number = 6
			vermstring = "lizards"
		if(VERM_SPIDERS)
			spawn_types = list(/mob/living/simple_animal/hostile/giant_spider/spiderling)
			vermstring = "spiderlings"
		if(VERM_SLIMES)
			spawn_types = typesof(/mob/living/carbon/slime) - /mob/living/carbon/slime - typesof(/mob/living/carbon/slime/adult)
			vermstring = "slimes"
		if(VERM_BATS)
			spawn_types = /mob/living/simple_animal/hostile/scarybat
			vermstring = "space bats"
		if(VERM_BORERS)
			spawn_types = /mob/living/simple_animal/borer
			vermstring = "cortical borers"
			max_number = 5
		if(VERM_MIMICS)
			spawn_types = /mob/living/simple_animal/hostile/mimic/crate/item
			vermstring = "mimics"
			max_number = 1 //1 to 2
		if(VERM_ROACHES)
			spawn_types = /mob/living/simple_animal/cockroach
			vermstring = "roaches"
			max_number = 30 //Thanks obama

	var/number = rand(2, max_number)

	for(var/i = 0, i <= number, i++)
		var/area/A = locate(spawn_area_type)
		var/list/turf/simulated/floor/valid = list()
		//Loop through each floor in the supply drop area
		for(var/turf/simulated/floor/F in A)
			if(!F.has_dense_content())
				valid.Add(F)

		var/picked = pick(valid)
		if(vermin == VERM_SPIDERS)
			var/mob/living/simple_animal/hostile/giant_spider/spiderling/S = new(picked)
			S.amount_grown = 0
		else
			var/spawn_type = pick(spawn_types)
			new spawn_type(picked)

/datum/event/infestation/announce()
	command_alert("Bioscans indicate that [vermstring] have been breeding in [locstring]. Clear them out, before this starts to affect productivity.", "Vermin infestation")

#undef LOC_KITCHEN
#undef LOC_ATMOS
#undef LOC_INCIN
#undef LOC_CHAPEL
#undef LOC_LIBRARY
#undef LOC_HYDRO
#undef LOC_VAULT
#undef LOC_TECH

#undef VERM_MICE
#undef VERM_LIZARDS
#undef VERM_SPIDERS
#undef VERM_SLIMES
#undef VERM_BATS
#undef VERB_MIMICS
