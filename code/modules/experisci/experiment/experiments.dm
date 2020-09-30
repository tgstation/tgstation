/datum/experiment/scanning/random/slime
	name = "Base Slime Experiment"
	total_requirement = 10
	max_requirement_per_type = 4

/datum/experiment/scanning/random/slime/calibration
	name = "Slime Sample Test"
	description = "Lets see if our scanners can pick up the genetic data from a simple slime extract."
	required_atoms = list(/obj/item/slime_extract/grey = 1)

/datum/experiment/scanning/random/slime/easy
	name = "Easy Slime Survey"
	description = "A wealthy client has requested that we provide samples of data from several basic slime cores."
	possible_types = list(/obj/item/slime_extract/orange,
							/obj/item/slime_extract/purple,
							/obj/item/slime_extract/blue,
							/obj/item/slime_extract/metal,
							/obj/item/slime_extract/yellow,
							/obj/item/slime_extract/darkpurple,
							/obj/item/slime_extract/darkblue,
							/obj/item/slime_extract/silver)

/datum/experiment/scanning/random/slime/moderate
	name = "Moderate Slime Survey"
	description = "Central Command has asked that you collect data from several common slime cores."
	possible_types = list(/obj/item/slime_extract/bluespace,
							/obj/item/slime_extract/sepia,
							/obj/item/slime_extract/cerulean,
							/obj/item/slime_extract/pyrite,
							/obj/item/slime_extract/red,
							/obj/item/slime_extract/green,
							/obj/item/slime_extract/pink,
							/obj/item/slime_extract/gold)

/datum/experiment/scanning/random/slime/hard
	name = "Challenging Slime Survey"
	description = "Another station has challenged your research team to collect several challenging slime cores, \
	 				including a very valuable rainbow core. Are you up to the task?"
	possible_types = list(/obj/item/slime_extract/oil,
							/obj/item/slime_extract/black,
							/obj/item/slime_extract/lightpink,
							/obj/item/slime_extract/adamantine)


/datum/experiment/scanning/random/cytology/easy
	name = "Basic Cytology Scanning Experiment"
	description = "A scientist needs vermin to test on, use the cytology equipment to grow some of these simple critters!"
	total_requirement = 3
	max_requirement_per_type = 2
	possible_types = list(/mob/living/simple_animal/hostile/cockroach, /datum/micro_organism/cell_line/mouse)

/datum/experiment/scanning/random/cytology/medium
	name = "Advanced Cytology Scanning Experiment"
	description = "We need to see how the body functions from the earliest moments. Some cytology experiments will help us gain this understanding."
	total_requirement = 3
	max_requirement_per_type = 2
	possible_types = list(/mob/living/simple_animal/hostile/carp, /mob/living/simple_animal/hostile/retaliate/poison/snake, /mob/living/simple_animal/pet/cat, /mob/living/simple_animal/pet/dog/corgi, /mob/living/simple_animal/cow, /mob/living/simple_animal/chicken)

/datum/experiment/scanning/random/cytology/medium/one
	name = "Advanced Cytology Scanning Experiment One"

/datum/experiment/scanning/random/cytology/medium/two
	name = "Advanced Cytology Scanning Experiment Two"

/datum/experiment/scanning/random/janitor_trash
	name = "Station Hygiene Inspection"
	description = "To learn how to clean, we must first learn what it is to have filth. We need you to scan some filth around the station."
	possible_types = list(/obj/effect/decal/cleanable/vomit,
	/obj/effect/decal/cleanable/blood/splatter)
	total_requirement = 3

/datum/experiment/explosion/calibration
	name = "Is This Thing On?"
	description = "The engineers from last shift left a notice for us that the doppler array seemed to be malfunctioning. \
					Could you check that it is still working? Any explosion will do!"
	required_light = 1

/datum/experiment/explosion/maxcap
	name = "Mother of God"
	description = "A recent outbreak of a blood-cult in a nearby sector necessitates the development of a large explosive. \
					Create a large enough explosion to prove your bomb, we'll be watching."


/datum/experiment/explosion/medium
	name = "Explosive Ordinance Experiment"
	description = "Alright, can we really call ourselves professionals if we can't make shit blow up?"
	required_heavy = 2
	required_light = 6

/datum/experiment/explosion/maxcap/New()
	required_devastation = GLOB.MAX_EX_DEVESTATION_RANGE
	required_heavy = GLOB.MAX_EX_HEAVY_RANGE
	required_light = GLOB.MAX_EX_LIGHT_RANGE


/datum/experiment/scanning/random/material/meat
	name = "Biological Material Scanning Experiment"
	description = "They told us we couldn't make chairs out of every material in the world. You're here to prove those nay-sayers wrong."

/datum/experiment/scanning/random/material/easy
	name = "Low Grade Material Scanning Experiment"
	description = "Material science is all about a basic understanding of the universe, and how it's built. To explain this, build something basic and we'll show you how to break it."
	total_requirement = 6
	possible_types = list(/obj/structure/chair, /obj/structure/toilet, /obj/structure/table)
	possible_material_types = list(/datum/material/iron, /datum/material/glass)

/datum/experiment/scanning/random/material/medium
	name = "Medium Grade Material Scanning Experiment"
	description = "Not all materials are strong enough to hold together a space station. Look at these materials for example, and see what makes them useful for our electronics and equipment."

	possible_material_types = list(/datum/material/silver, /datum/material/gold, /datum/material/plastic, /datum/material/titanium)
/datum/experiment/scanning/random/material/medium/one
	name = "Medium Grade Material Scanning Experiment One"

/datum/experiment/scanning/random/material/medium/two
	name = "Medium Grade Material Scanning Experiment Two"

/datum/experiment/scanning/random/material/medium/three
	name = "Medium Grade Material Scanning Experiment Three"

/datum/experiment/scanning/random/material/hard
	name = "High Grade Material Scanning Experiment"
	description = "NT spares no expense to test even the most valuable of materials for their qualities as construction materials. Go build us some of the fanciest"
	possible_material_types = list(/datum/material/diamond, /datum/material/plasma, /datum/material/uranium)

/datum/experiment/scanning/random/material/hard/one
	name = "High Grade Material Scanning Experiment One"

/datum/experiment/scanning/random/material/hard/two
	name = "High Grade Material Scanning Experiment Two"

/datum/experiment/scanning/random/material/hard/three
	name = "High Grade Material Scanning Experiment Three"
