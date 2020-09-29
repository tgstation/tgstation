/datum/experiment/scanning/random/slime
	name = "Base Slime Experiment"
	total_requirement = 10

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
	required_atoms = list(/obj/item/slime_extract/rainbow = 1)
	possible_types = list(/obj/item/slime_extract/oil,
							/obj/item/slime_extract/black,
							/obj/item/slime_extract/lightpink,
							/obj/item/slime_extract/adamantine)

/datum/experiment/scanning/destructive/ian
	name = "Ian's Connundrum"
	description = "Central Command seems to have lost its backup of Ian's DNA, could you get a copy for us?"
	required_atoms = list(/mob/living/simple_animal/pet/dog/corgi/ian = 1)

/datum/experiment/explosion/calibration
	name = "Is This Thing On?"
	description = "The engineers from last shift left a notice for us that the doppler array seemed to be malfunctioning. \
					Could you check that it is still working? Any explosion will do!"
	required_light = 1

/datum/experiment/explosion/maxcap
	name = "Mother of God"
	description = "A recent outbreak of a blood-cult in a nearby sector necessitates the development of a large explosive. \
					Create a large enough explosion to prove your bomb, we'll be watching."

/datum/experiment/explosion/maxcap/New()
	required_devastation = GLOB.MAX_EX_DEVESTATION_RANGE
	required_heavy = GLOB.MAX_EX_HEAVY_RANGE
	required_light = GLOB.MAX_EX_LIGHT_RANGE
