/datum/slime_color/grey
	name = "grey"
	icon_prefix = "grey"
	secretion_path = /datum/reagent/slime_ooze/grey
	slime_color = "#FFFFFF" // I know this is white its because the base colors are greyed
	possible_mutations = list(
		/datum/slime_mutation_data/metal,
		/datum/slime_mutation_data/orange,
		/datum/slime_mutation_data/purple,
		/datum/slime_mutation_data/blue,
		)

/datum/slime_color/grey/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/cockroach/iceroach = 1)

/datum/slime_color/blue
	name = "blue"
	icon_prefix = "blue"
	secretion_path = /datum/reagent/slime_ooze/blue
	slime_color = "#25F8E6"
	possible_mutations = list(
		/datum/slime_mutation_data/silver,
		/datum/slime_mutation_data/dark_blue,
		/datum/slime_mutation_data/pink,
		)

/datum/slime_color/blue/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/meatbeast = 2)
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/diyaab = 1)
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/thinbug = 1)

/datum/slime_color/dark_blue
	name = "dark blue"
	icon_prefix = "dark blue"
	secretion_path = /datum/reagent/slime_ooze/darkblue
	slime_color = "#3375F9"
	possible_mutations = list(
		/datum/slime_mutation_data/blue,
		/datum/slime_mutation_data/purple,
		/datum/slime_mutation_data/cerulean,
		)


/datum/slime_color/dark_blue/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/cockroach/iceroach = 1)
	GLOB.biomass_unlocks |= list(/mob/living/basic/cockroach/recursive = 1)

/datum/slime_color/green
	name = "green"
	icon_prefix = "green"
	secretion_path = /datum/reagent/slime_ooze/green
	slime_color = "#D6F264"
	possible_mutations = list(
		/datum/slime_mutation_data/black,
		)

/datum/slime_color/green/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/thoom = 2)

/datum/slime_color/metal
	name = "metal"
	icon_prefix = "metal"
	secretion_path = /datum/reagent/slime_ooze/metal
	slime_color = "#6D758D"
	possible_mutations = list(
		/datum/slime_mutation_data/silver,
		/datum/slime_mutation_data/yellow,
		/datum/slime_mutation_data/gold,
		)

/datum/slime_color/metal/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/meatbeast = 2)

/datum/slime_color/purple
	name = "purple"
	icon_prefix = "purple"
	secretion_path = /datum/reagent/slime_ooze/purple
	slime_color = "#BC4A9B"
	possible_mutations = list(
		/datum/slime_mutation_data/green,
		/datum/slime_mutation_data/dark_blue,
		/datum/slime_mutation_data/darkpurple,
		)

/datum/slime_color/purple/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/greeblefly = 2)
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/diyaab = 1)

/datum/slime_color/orange
	name = "orange"
	icon_prefix = "orange"
	secretion_path = /datum/reagent/slime_ooze/orange
	slime_color = "#FA6A0A"
	possible_mutations = list(
		/datum/slime_mutation_data/darkpurple,
		/datum/slime_mutation_data/yellow,
		/datum/slime_mutation_data/red,
		)

/datum/slime_color/orange/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/lavadog = 1)

/datum/slime_color/pink
	name = "pink"
	icon_prefix = "pink"
	secretion_path = /datum/reagent/slime_ooze/pink
	slime_color = "#F5A097"
	possible_mutations = list(
		/datum/slime_mutation_data/lightpink,
		)

/datum/slime_color/pink/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/voxslug = 1)

/datum/slime_color/darkpurple
	name = "dark purple"
	icon_prefix = "dark purple"
	secretion_path = /datum/reagent/slime_ooze/darkpurple
	slime_color = "#793A80"
	possible_mutations = list(
		/datum/slime_mutation_data/sepia,
		/datum/slime_mutation_data/purple,
		/datum/slime_mutation_data/orange,
		)

/datum/slime_color/darkpurple/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/possum = 1)

/datum/slime_color/red
	name = "red"
	icon_prefix = "red"
	secretion_path = /datum/reagent/slime_ooze/red
	slime_color = "#B4202A"
	possible_mutations = list(
		/datum/slime_mutation_data/oil,
		)

/datum/slime_color/darkpurple/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/xenofauna/dron = 1)

/datum/slime_color/yellow
	name = "yellow"
	icon_prefix = "yellow"
	secretion_path = /datum/reagent/slime_ooze/yellow
	slime_color = "#F9A31B"
	possible_mutations = list(
		/datum/slime_mutation_data/bluespace,
		/datum/slime_mutation_data/metal,
		/datum/slime_mutation_data/orange,
		)

/datum/slime_color/gold
	name = "gold"
	icon_prefix = "gold"
	secretion_path = /datum/reagent/slime_ooze/gold
	slime_color = "#BB7547"
	possible_mutations = list(
		/datum/slime_mutation_data/adamantine,
		)

/datum/slime_color/silver
	name = "silver"
	icon_prefix = "silver"
	secretion_path = /datum/reagent/slime_ooze/silver
	slime_color = "#8B93AF"
	possible_mutations = list(
		/datum/slime_mutation_data/pyrite,
		/datum/slime_mutation_data/metal,
		/datum/slime_mutation_data/blue,
		)

/datum/slime_color/silver/on_first_unlock()
	GLOB.biomass_unlocks |= list(/mob/living/basic/cockroach/iceroach = 1)

/datum/slime_color/lightpink
	name = "light pink"
	icon_prefix = "light pink"
	secretion_path = /datum/reagent/slime_ooze/lightpink
	slime_color = "#E9B5A3"
	possible_mutations = list(/datum/slime_mutation_data/rainbow)

/datum/slime_color/black
	name = "black"
	icon_prefix = "black"
	secretion_path = /datum/reagent/slime_ooze/black
	slime_color = "#333941"
	possible_mutations = list(/datum/slime_mutation_data/rainbow)

/datum/slime_color/rainbow
	name = "rainbow"
	icon_prefix = "rainbow"
	secretion_path = /datum/reagent/slime_ooze/rainbow
	slime_color = "#FFFFFF"

/datum/slime_color/rainbow/on_add_to_slime(mob/living/basic/slime/slime)
	slime.rainbow_effect()

/datum/slime_color/oil
	name = "oil"
	icon_prefix = "oil"
	secretion_path = /datum/reagent/slime_ooze/oil
	slime_color = "#242234"
	possible_mutations = list(/datum/slime_mutation_data/rainbow)

/datum/slime_color/sepia
	name = "sepia"
	icon_prefix = "sepia"
	secretion_path = /datum/reagent/slime_ooze/sepia
	slime_color = "#A08662"
	possible_mutations = list(/datum/slime_mutation_data/rainbow)

/datum/slime_color/adamantine
	name = "adamantine"
	icon_prefix = "adamantine"
	secretion_path = /datum/reagent/slime_ooze/adamantine
	slime_color = "#5DAF8D"
	possible_mutations = list(/datum/slime_mutation_data/rainbow)

/datum/slime_color/bluespace
	name = "bluespace"
	icon_prefix = "bluespace"
	secretion_path = /datum/reagent/slime_ooze/bluespace
	slime_color = "#C0E4FD"
	possible_mutations = list(/datum/slime_mutation_data/rainbow)

/datum/slime_color/pyrite
	name = "pyrite"
	icon_prefix = "pyrite"
	secretion_path = /datum/reagent/slime_ooze/pyrite
	slime_color = "#FFD541"
	possible_mutations = list(/datum/slime_mutation_data/rainbow)

/datum/slime_color/cerulean
	name = "cerulean"
	icon_prefix = "cerulean"
	secretion_path = /datum/reagent/slime_ooze/cerulean
	slime_color = "#285CC4"
	possible_mutations = list(/datum/slime_mutation_data/rainbow)
