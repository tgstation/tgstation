
datum/geosample
	var/scrambled = 0	//if this sample has been mixed with other samples
	//
	var/age_thousand = 1					//age can correspond to different artifacts
	var/age_million = 0
	var/age_billion = 0
	var/artifact_id = ""					//id of a nearby artifact, if there is one
	var/artifact_strength = 0				//proportional to distance
	var/responsive_reagent = ""				///each reagent corresponds to a different type of find
	var/reagent_response = ""				//likelihood of there being finds there

datum/geosample/New(var/turf/simulated/mineral/container)
	UpdateTurf(container)

//this function should only be called once. it's here just in case
datum/geosample/proc/UpdateTurf(var/turf/simulated/mineral/container)
	src = null
	switch(container.mineralName)
		if("Uranium")
			age_million = rand(1, 704)
			age_thousand = rand(1,999)
		if("Iron")
			age_thousand = rand(1, 999)
			age_million = rand(1, 999)
		if("Diamond")
			age_thousand = rand(1,999)
			age_million = rand(1,999)
		if("Gold")
			age_thousand = rand(1,999)
			age_million = rand(1,999)
			age_billion = rand(3,4)
		if("Silver")
			age_thousand = rand(1,999)
			age_million = rand(1,999)
		if("Plasma")
			age_thousand = rand(1,999)
			age_million = rand(1,999)
			age_billion = rand(10, 13)
		if("Archaeo")
			//snowflake
			age_thousand = rand(1,999)
