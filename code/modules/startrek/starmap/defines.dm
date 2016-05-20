var/global/datum/starmap/starMap
var/global/list/all_sector_objects = list() //All -actual- existing stellar objects. This is sad on resources. :(
var/global/list/all_so_types = list() //A global list of all potential stellar objects to choose from.

//This is the datum for the whole shebang. It contains stuff for generating the grid and maintaining it.
/datum/starmap
	var/max_x = 4
	var/max_y = 4
	var/max_z = 4
	var/negative_allowed = 0
	var/warp_speed_minutes = 10
	var/mission_ratio = 0.75 //this to 1.0 of grid size is where objective will spawn.
	var/list/all_nodes = list()
	var/list/visited_nodes = list()
	var/max_sites_sector = 3
	var/list/uniques = list()
	var/mission_selected = 0 //Don't touch.

//New spacegrid! Let's fire it up.

//This is the datum for each individual coordinate on the grid. Stuff like planets show up here.
//Also known as a "sector"
/datum/sm_node
	var/sector_name = "Sector 001" //These should be randomized. 001 is actually Earth.
	var/x //Where does this node lie on the grid?
	var/y
	var/z
	var/list/datum/sector_object/sector_stuff = list() //What exactly is here?
	var/ship_here //Is the ship currently here?
	var/faction = "Neutral" //Does someone claim this sector? "Federation", "Neutral", etc
	var/has_subspace
	var/mission_objective
	var/datum/starmap/master
	var/image/onscreen_image = null

//"Stuff" in "space"
//May or may not actually exist.
//Foot travel destinations MUST have is_away_mission and map_file.
/datum/sector_object
	var/obj_name = "Sector Thingy" //The template should never actually exist.
	var/alt_tag = "<error>"
	var/datum/sm_node/master = null
	var/descrip = "A generic sector object. This should not exist."
	var/chance = 0
	var/is_away_mission = 0
	var/map_file = ""
	var/minerals = 0
	var/radiation = 0
	var/shields = 0 //Generic "points". Ship has 100. Starbase has 1000.
	var/weapons = 0 //Generic "points". ^^^
	var/is_hostile = 0
	var/faction = "Neutral" //"friendly", "neutral", "trader", "romulan", "borg". Faction stuff spawns more often in like factions.
	var/hailing_status = 0
	var/dockable = 0
	var/number_in_name = 0
	var/is_unique = 0
	var/max_per_sector = 1
	var/life_signs = "None" //"none", "basic", "intelligent", etc
	var/image/onscreen_image
	var/datum/sector_object/orbiting = null //Are we orbiting another stellar object?

/datum/sector_object/star
	obj_name = "Star"
	descrip = "A burning nuclear furnace."
	radiation = 5000
	number_in_name = 1
	max_per_sector = 1
	chance = 0
	var/startype
	var/starsize

	initialize()
		..()

		//Let's do the super rare ones first
		//Each star, hole, or anything with stable mass can have their own exoplanets.
		//But there wont be any life on them if they are orbiting the black hole, for example
		if(rand(100) < 3)
			startype = pick(0,0,0,0,0,0,0,0,\
							1,1,1,1,1,1,1,\
							2,2,2,2,2,2,\
							3,3,3,3,3,\
							4,4,4,4,4,\
							5,5,5,5,\
							6,6,6,6,\
							7,7,\
							8,8,\
							9,9,\
							10,10,\
							11,11,\
							12)

//Black Hole				= 0
//Neutron Star				= 1
//Pulsar					= 2
//Wolf Rayet				= 3
//Carbon Star				= 4
//Extreme Hydrogen Star		= 5
//PMS Star					= 6
//ElectroWeak Star			= 7
//White Hole				= 8
//Technetium Star			= 9
//Iron Star					= 10
//Peculiar star				= 11
//Dark Star					= 12

			switch(startype)
				if(0) //Black Hole
					obj_name = "Black Hole"
					startype = "Black Hole"
					descrip = "A roiling mass of gravity and radiation."
					//radiation = rand(150000,250000)
					//onscreen_image = "" Later


				if(1) //Neutorn Star
					obj_name = "Neutorn Star"
					startype = "Neutron Star"
					descrip = "A highly unstable, small, radioactive star."
					//radiation = rand(150000,250000)
					//onscreen_image = "" Later

					if(!istype(master))
						return //Just to be safe..
					master.create_sector_object("nebula/supernova")


				if(2) //Pulsar
					obj_name = "Pulsar"
					startype = "Pulsar"
					descrip = "A highly unstable, small, radioactive star."
					//radiation = rand(150000,250000)
					//onscreen_image = "" Later

					if(!istype(master))
						return //Just to be safe..
					master.create_sector_object("nebula/supernova")


				if(3) //Class W: Wolf-Rayet
					obj_name = "Class W: Wolf-Rayet (Blue Super Giant)"
					starsize = "Super Giant"
					startype = "Blue"
					descrip = "A dying supergiant with their hydrogen layers blown away by stellar winds. Extremely hot and massive."
					//radiation += rand(-1000,1000)
					//onscreen_image = "" Later

					if(!istype(master))
						return //Just to be safe..
					master.create_sector_object("nebula/planetary")


				if(4) //Class C: Carbon Star
					starsize = pick("Giant", "Bright Giant", "Super Giant")
					obj_name = "Class C: Carbon Star (Red [starsize])"
					startype = "Red"
					descrip = "Red [starsize], near the end of its life, in which there is an excess of carbon in the atmosphere."
					//radiation += rand(-1000,1000)
					//onscreen_image = "" Later

					if(!istype(master))
						return //Just to be safe..
					master.create_sector_object("nebula/planetary")


				if(5) //Extreme helium star
					starsize = pick("Bright Giant", "Super Giant")
					obj_name = "[starsize] Extreme Helium Star"
					descrip = "Almost devoid of hydrogen, the most common chemical element of the Universe."
					//radiation += rand(-1000,1000)
					//onscreen_image = "" Later


				if(6) //PMS Star
					obj_name = "PMS Star"
					starsize = "Dwarf"
					descrip = "A pre-main-sequence star is a star in the stage when it has not yet reached started hydrogen burning."
					//onscreen_image = "" Later


				if(7) //Electroweak Star
					obj_name = "Electroweak Star"
					startype = "Electroweak Star"
					descrip = "A highly unstable, radioactive star. The star's core is at the size of an apple, containing about two Earth masses. This must be the first ever record of an existing Electroweak Star."
					//radiation = rand(150000,250000)
					//onscreen_image = "" Later

					//Spawn Supernova Remnant
					if(!istype(master))
						return //Just to be safe..
					master.create_sector_object("nebula/supernova")


				if(8) //White Hole
					obj_name = "White Hole"
					startype = "White Hole"
					descrip = "Opposite of black hole. This must be the first ever record of an existing White Hole."
					//radiation = rand(150000,250000)
					//onscreen_image = "" Later


				if(9) //Technetium Star
					obj_name = "Technetium Star"
					startype = "Technetium Star"
					descrip = "A Tc-rich star. It is a star whose stellar spectrum contains absorption lines of the light radioactive metal technetium. The most stable isotope of technetium is 98Tc with a half-life of 4.2 million years, which is too short a time to allow the metal to be material from before the star's formation."
					//onscreen_image = "" Later


				if(10) //Iron Star
					obj_name = "Iron Star"
					startype = "Iron Star"
					descrip = "A compact star that cold fusion occurring via quantum tunnelling caused  the light nuclei in ordinary matter to fuse into iron-56 nuclei. Fission and alpha-particle emission would then make heavy nuclei decay into iron, converting stellar-mass objects to cold spheres of iron."
					//onscreen_image = "" Later


				if(11) //Peculiar star
					obj_name = "Peculiar star"
					startype = "Peculiar star"
					descrip = "Star with distinctly unusual metal abundances, at least in their surface layers."
					//onscreen_image = "" Later


				if(12) //Dark Star
					obj_name = "Dark star"
					startype = "Blue"
					starsize = "Hyper Giant"
					descrip = "Has a surface escape velocity that equals or exceeds the speed of light. Any light emitted at the surface of a dark star would be trapped by the star's gravity, rendering it dark."
					//radiation = rand(150000,250000)
					//onscreen_image = "" Later

/*TODO:
Quasars
Blazars
Brown Dwarfs/Sub Dwarfs
*/

		else //If not special, pick normal ones
			radiation += rand(-1000,1000)

			//Blue HyperGiants are the most rarest of all below
			starsize = pick("Sub Dwarf", "Sub Dwarf", "Sub Dwarf", "Sub Dwarf", "Sub Dwarf",\
							"Dwarf", "Dwarf", "Dwarf", "Dwarf", "Dwarf", "Dwarf", "Dwarf",\
							"Sub Giant", "Sub Giant", "Sub Giant", "Sub Giant", "Sub Giant",\
							"Giant", "Giant", "Giant", "Giant",\
							"Bright Giant", "Bright Giant", "Bright Giant",\
							"Super Giant", "Super Giant",\
							"Hyper Giant")


			startype = pick("Red", "Red", "Red", "Red", "Red", "Red", "Red",\
							"Orange", "Orange", "Orange", "Orange", "Orange", "Orange",\
							"Yellow", "Yellow", "Yellow", "Yellow", "Yellow",\
							"Yellow-White", "Yellow-White", "Yellow-White", "Yellow-White",\
							"White", "White", "White",\
							"Blue-White", "Blue-White",\
							"Blue")


			obj_name = "[startype] [starsize]"
			//onscreen_image = "[starsize]" Later


		if(!istype(master))
			return //Just to be safe..

		if(rand(100) < 20)
			master.create_sector_object("planet/large")
		if(rand(100) < 25)
			master.create_sector_object("planet")
		if(rand(100) < 35)
			master.create_sector_object("planet")
		if(rand(100) < 20)
			master.create_sector_object("planet/small")
		if(rand(100) < 10)
			master.create_sector_object("planet/small")
		if(rand(100) < 25)
			var/randsteroids = rand(1,3)
			for(var/i = 0 to randsteroids)
				master.create_sector_object("asteroid_small")


/datum/sector_object/planet
	obj_name = "Medium Planet"
	var/planet_class = "M"
	var/planet_type = ""
	var/rotation = "Normal"
	var/atmosphere = "None"
	var/gravity = "Normal"
	var/volcanism = "Low"
	var/weather = "Low"

	is_away_mission = 1 //We can travel here!
	map_file = "" //Maps go here!

	initialize()
		..()
		generate_planet()

	proc/generate_planet()
		//Generate planets depending on the star they orbit.

		//Orbiting normal stars (Wolf-Rayet and Carbon Star included)
		planet_class = pick("D","D","D","D","H","H","J","J","J","K","L","L","L","M","M","M","M","M","N","T","Y")
		//TODO:
			//Orbiting dead stars
				//planet_class = pick("D","D","D","D","H","H","J","J","J","N","T","Y")

		gravity = pick("Low","Normal","Normal","Normal","High")
		radiation = rand(0,100)
		minerals = rand(0,15000)
		switch(planet_class)
			if("D") //Dead planet or moon. No atmosphere.
				gravity = pick("Low","Low","Normal","Normal","High")
				weather = "None"
				planet_type = pick("Barren","(Moon)","Dead")
				life_signs = "None"

			if("H") //Generally uninhabitable. Volcanic, etc.
				rotation = pick("Eccentric","Eccentric","Tilted","Tilted","Erratic","Erratic","Normal","Normal")
				atmosphere = pick("Unsafe","Unsafe","Sulphuric","Acidic","Safe","Poisonous")
				planet_type = pick("Volcanic","Acidic","Storm-wracked","Uninhabitable")
				gravity = pick("Low","Normal","High","High","Extreme")
				volcanism = pick("Low","Medium","High","High","Extreme")
				weather = pick("Low","Medium","High","High","Extreme")
				life_signs = pick("None","None","None","Proto")

			if("J") //Common gas giant.
				weather = pick("High","High","Extreme")
				volcanism = "None"
				gravity = "Extreme"
				atmosphere = "Chaotic"
				planet_type = "Gas Giant"
				life_signs = "None"
				minerals = 0

			if("K") //Habitable, with help.
				rotation = pick("Eccentric","Eccentric","Tilted","Tilted","Erratic","Erratic","Normal","Normal")
				atmosphere = pick("Unsafe","Unsafe","Unsafe","Safe","Poisonous")
				planet_type = pick("Jungle","Desert","Rocky","Ocean")
				gravity = pick("Low","Normal","Normal","Normal","High")
				weather = pick("Low","Medium","Medium","Medium","High")
				life_signs = pick("None","None","None","Proto","Proto","Simple Bacteria","Complex Bacteria")

			if("L") //Habitable, but uninhabited by animal life. Plants, bacteria, etc only
				rotation = pick("Eccentric","Normal","Normal")
				atmosphere = "Safe"
				planet_type = pick("Jungle","Forest","Ocean","Lush","Gaia")
				gravity = pick("Low","Normal","Normal","Normal","High")
				weather = pick("Low","Medium","Medium","Medium","High")
				life_signs = pick("Proto","Simple Plants","Simple Plants","Complex Plants","Complex Plants")

			if("M") //Habitable, and inhabited.
				rotation = pick("Eccentric","Normal","Normal","Tilted")
				atmosphere = "Safe"
				planet_type = pick("Jungle","Forest","Ocean","Lush","Lush","Gaia","Gaia")
				gravity = pick("Low","Normal","Normal","Normal")
				weather = pick("Low","Medium")
				life_signs = pick("Complex Plants","Complex Mixed","Primitive","Industrial","Modern")
				if(life_signs == "Modern" || life_signs == "Industrial")
					faction = pick("Federation","Federation","Federation","Romulan","Romulan","Klingon","Klingon","Ferengi","Cardassian","Bajoran","Pirate","Neutral","Neutral","Neutral")
				if(master.faction != "Neutral")
					faction = master.faction

			if("N") //Sulfuric gas planet.
				weather = pick("High","High","Extreme")
				volcanism = "None"
				gravity = "Extreme"
				atmosphere = "Sulphuric"
				planet_type = "Sulfuric Gas Giant"
				life_signs = "???"
				minerals = 0

			if("T") //Uncommon gas giant
				weather = pick("High","High","Extreme")
				volcanism = "None"
				gravity = "Extreme"
				atmosphere = "Chaotic"
				planet_type = "Gas Giant"
				life_signs = "None"
				radiation = rand(500,15000)
				minerals = 0

			if("Y") //Demon planet!
				rotation = pick("Eccentric","Eccentric","Tilted","Erratic")
				weather = "Extreme"
				volcanism = "Extreme"
				atmosphere = "???"
				planet_type = "Demon World"
				life_signs = "???"
				radiation = rand(0,150000)
				minerals = rand(0,150000)

		descrip = "A planet. Rot: [rotation] W: [weather] V: [volcanism] Atm: [atmosphere] LS: [life_signs]"

/datum/sector_object/planet/small
	obj_name = "Small Planet"

/datum/sector_object/planet/large
	obj_name = "Large Planet"

/datum/sector_object/fed_starbase
	obj_name = "Starbase"
	descrip = "A Federation starbase, equipped with all the amenities one could want."
	is_away_mission = 1
	map_file = ""
	shields = 1000
	weapons = 1000
	dockable = 1
	chance = 5 //Not big. 1 in 20 is still sizeable.
	faction = "Federation"
	number_in_name = 1

/datum/sector_object/asteroid_small
	obj_name = "Small Asteroid Belt"
	descrip = "A small field of rocks drifting through space."
	chance = 50 //Very high chance.
	faction = "Neutral"
	max_per_sector = 5
	number_in_name = 1
	map_file = ""

	initialize()
		..()
		minerals = rand(50,100)
		radiation = rand(0,10)

/datum/sector_object/asteroid_large
	obj_name = "Large Asteroid Belt"
	descrip = "A large belt of rocks drifting through space."
	chance = 15
	faction = "Neutral"
	max_per_sector = 1
	number_in_name = 1
	map_file = ""

	initialize()
		..()
		minerals = rand(100,1000)
		radiation = rand(0,100)

/datum/sector_object/radioactive_anomaly
	obj_name = "Radioactive Anomaly"
	descrip = "A large, strange anomalous sector of space."
	chance = 15
	var/anomaly_type
	var/anomaly_size

	initialize()
		..()

		anomaly_type = pick("Radioactive","Radioactive", "Gravitron", "Antigravitron")
		anomaly_size = pick("Small","Small","Small", "Large","Large", "Giant")
		switch(anomaly_type)
			if("Radioactive")
				obj_name = "Radioactive Anomaly"
				descrip = "A [anomaly_size] Radioactive Anomaly. Emmits a massive ammount of radiation."
				radiation = rand(25000,250000)

			if("Gravitron")
				obj_name = "Gravitron Anomaly"
				descrip = "A [anomaly_size] Gravitron Anomaly. Emmits a massive gravity pull."
				radiation = 5000 + rand(-500,25000)

			if("Antigravitron")
				obj_name = "Antigravitron Anomaly"
				descrip = "A [anomaly_size] Antigravitron Anomaly. Emmits a massive gravity push."
				radiation = 5000 + rand(-500,25000)


/datum/sector_object/nebula
	obj_name = "H II Nebula"
	descrip = "A massive cloud of glowing gas."
	chance = 20
	radiation = 5000
//	var/nebula_type

	initialize()
		..()
/*
		nebula_type = pick("H II", "Planetary Nebula", "Supernova Remnant", "Dark Nebula")
		switch(nebula_type)
			if("H II")
				obj_name = "H II Nebula"
				descrip = "A massive cloud of glowing gas."
			if("Planetary nebulae") //Can only be found near dying stars
				obj_name = "Planetary Nebula"
				descrip = "A massive cloud of glowing gas. Caused by the solar winds blowing away gasses from the dying star"
				radiation += rand(500,2500)
			if("Supernova Remnant")//Can only be found near neutron stars and black and white holes
				obj_name = "Supernova Remnant"
				descrip = "A massive cloud of glowing gas. Caused by supernova explosion."
				radiation += rand(2500,25000)
			if("Dark Nebula")//Blocks scanning of the node this is in, unless you are already inside the node?
				obj_name = "Dark Nebula"
				descrip = "A massive cloud of higly densed gas. It prevents light from the other side from going trough it."
*/
		radiation += rand(-radiation*0.25,radiation*2)

/datum/sector_object/nebula/planetary
	obj_name = "Planetary nebulae"
	descrip = "A massive cloud of glowing gas. Caused by the solar winds blowing away gasses from the dying star"
	chance = 0 //Automaticaly spawned with dying stars
	radiation = 25000

/datum/sector_object/nebula/supernova
	obj_name = "Supernova Remnant"
	descrip = "A massive cloud of glowing gas. Caused by supernova explosion."
	chance = 0 //Automaticaly spawned with neutron stars
	radiation = 50000

/datum/sector_object/nebula/dark_nebula
	obj_name = "Dark Nebula"
	descrip = "A massive cloud of higly densed gas. It prevents light from the other side from going trough it."
	chance = 5
	radiation = 5000