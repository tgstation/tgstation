

datum/geosample
	var/scrambled = 0						//if this sample has been mixed with other samples
	//
	var/age = 0								//age can correspond to different archaeological finds
	var/age_thousand = 0
	var/age_million = 0
	var/age_billion = 0
	var/artifact_id = ""					//id of a nearby artifact, if there is one
	var/artifact_distance = 0				//proportional to distance
	var/main_find = ""						//carrier reagent that the main body of the tile responds to
	var/secondary_find = ""					//carrier reagent that the floor of the turf responds to
	//
	var/source_mineral
	var/list/specifity_offsets = list()

datum/geosample/New(var/turf/simulated/mineral/container)
	UpdateTurf(container)
	artifact_distance = rand(500,999999)

//this should only need to be called once
datum/geosample/proc/UpdateTurf(var/turf/simulated/mineral/container)
	source_mineral = container.mineralName
	age = rand(1,999)
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
		if("Clown")
			age = rand(-1,-999)				//thats_the_joke.mp4
			age_thousand = rand(-1,-999)
		/*if("Archaeo")
			//snowflake
			age_thousand = rand(1,999)*/
		else
			source_mineral = "Rock"
