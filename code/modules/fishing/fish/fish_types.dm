// Freshwater fish

/obj/item/fish/goldfish
	name = "goldfish"
	desc = "Despite common belief, goldfish do not have three-second memories. \
		They can actually remember things that happened up to three months ago."
	icon_state = "goldfish"
	sprite_width = 8
	sprite_height = 8
	stable_population = 3
	average_size = 30
	average_weight = 500
	favorite_bait = list(/obj/item/food/bait/worm)
	required_temperature_min = MIN_AQUARIUM_TEMP+18
	required_temperature_max = MIN_AQUARIUM_TEMP+26

/obj/item/fish/goldfish/gill
	name = "McGill"
	desc = "A great rubber duck tool for Lawyers who can't get a grasp over their case."
	stable_population = 1
	random_case_rarity = FISH_RARITY_NOPE

/obj/item/fish/angelfish
	name = "angelfish"
	desc = "Young Angelfish often live in groups, while adults prefer solitary life. They become territorial and aggressive toward other fish when they reach adulthood."
	icon_state = "angelfish"
	dedicated_in_aquarium_icon_state = "bigfish"
	sprite_height = 7
	source_height = 7
	average_size = 30
	average_weight = 500
	stable_population = 3
	fish_traits = list(/datum/fish_trait/aggressive)
	required_temperature_min = MIN_AQUARIUM_TEMP+22
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/guppy
	name = "guppy"
	desc = "Guppy is also known as rainbow fish because of the brightly colored body and fins."
	icon_state = "guppy"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#91AE64"
	sprite_width = 8
	sprite_height = 5
	average_size = 30
	average_weight = 500
	stable_population = 6
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	required_temperature_max = MIN_AQUARIUM_TEMP+28

/obj/item/fish/plasmatetra
	name = "plasma tetra"
	desc = "Due to their small size, tetras are prey to many predators in their watery world, including eels, crustaceans, and invertebrates."
	icon_state = "plastetra"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#D30EB0"
	average_size = 30
	average_weight = 500
	stable_population = 3
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	required_temperature_max = MIN_AQUARIUM_TEMP+28

/obj/item/fish/catfish
	name = "cory catfish"
	desc = "A catfish has about 100,000 taste buds, and their bodies are covered with them to help detect chemicals present in the water and also to respond to touch."
	icon_state = "catfish"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#907420"
	average_size = 100
	average_weight = 2000
	stable_population = 3
	favorite_bait = list(
		list(
			"Type" = "Foodtype",
			"Value" = JUNKFOOD
		)
	)
	required_temperature_min = MIN_AQUARIUM_TEMP+12
	required_temperature_max = MIN_AQUARIUM_TEMP+30

// Saltwater fish below

/obj/item/fish/clownfish
	name = "clownfish"
	desc = "Clownfish catch prey by swimming onto the reef, attracting larger fish, and luring them back to the anemone. The anemone will sting and eat the larger fish, leaving the remains for the clownfish."
	icon_state = "clownfish"
	dedicated_in_aquarium_icon_state = "clownfish_small"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 5
	average_size = 30
	average_weight = 500
	stable_population = 4
	fish_traits = list(/datum/fish_trait/picky_eater)
	evolution_types = list(/datum/fish_evolution/lubefish)
	compatible_types = list(/obj/item/fish/clownfish/lube)
	required_temperature_min = MIN_AQUARIUM_TEMP+22
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/clownfish/lube
	name = "lubefish"
	desc = "A clownfish exposed to cherry-flavored lube for far too long. First discovered the days following a cargo incident around the seas of Europa, when thousands of thousands of thousands..."
	icon_state = "lubefish"
	random_case_rarity = FISH_RARITY_VERY_RARE
	dedicated_in_aquarium_icon_state = "lubefish_small"
	fish_traits = list(/datum/fish_trait/picky_eater, /datum/fish_trait/lubed)
	evolution_types = null
	compatible_types = list(/obj/item/fish/clownfish)
	food = /datum/reagent/lube

/obj/item/fish/cardinal
	name = "cardinalfish"
	desc = "Cardinalfish are often found near sea urchins, where the fish hide when threatened."
	icon_state = "cardinalfish"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 4
	fish_traits = list(/datum/fish_trait/vegan)
	required_temperature_min = MIN_AQUARIUM_TEMP+22
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/greenchromis
	name = "green chromis"
	desc = "The Chromis can vary in color from blue to green depending on the lighting and distance from the lights."
	icon_state = "greenchromis"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#00ff00"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 5
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28

	fishing_difficulty_modifier = 5 // Bit harder

/obj/item/fish/firefish
	name = "firefish goby"
	desc = "To communicate in the wild, the firefish uses its dorsal fin to alert others of potential danger."
	icon_state = "firefish"
	sprite_width = 6
	sprite_height = 5
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 3
	disliked_bait = list(/obj/item/food/bait/worm, /obj/item/food/bait/doughball)
	fish_ai_type = FISH_AI_ZIPPY
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28

/obj/item/fish/pufferfish
	name = "pufferfish"
	desc = "They say that one pufferfish contains enough toxins to kill 30 people, although in the last few decades they've been genetically engineered en masse to be less poisonous."
	icon_state = "pufferfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 8
	average_size = 60
	average_weight = 1000
	stable_population = 3
	required_temperature_min = MIN_AQUARIUM_TEMP+23
	required_temperature_max = MIN_AQUARIUM_TEMP+28

	fish_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/toxic)

/obj/item/fish/lanternfish
	name = "lanternfish"
	desc = "Typically found in areas below 6600 feet below the surface of the ocean, they live in complete darkness."
	icon_state = "lanternfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	random_case_rarity = FISH_RARITY_VERY_RARE
	source_width = 28
	source_height = 21
	sprite_width = 8
	sprite_height = 8
	average_size = 100
	average_weight = 1500
	stable_population = 3
	fish_traits = list(/datum/fish_trait/nocturnal)
	required_temperature_min = MIN_AQUARIUM_TEMP+2 //My source is that the water at a depth 6600 feet is pretty darn cold.
	required_temperature_max = MIN_AQUARIUM_TEMP+18

//Tiziran Fish
/obj/item/fish/dwarf_moonfish
	name = "dwarf moonfish"
	desc = "Ordinarily in the wild, the Zagoskian moonfish is around the size of a tuna, however through selective breeding a smaller breed suitable for being kept as an aquarium pet has been created."
	icon_state = "dwarf_moonfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 2
	fillet_type = /obj/item/food/fishmeat/moonfish
	average_size = 100
	average_weight = 2000
	required_temperature_min = MIN_AQUARIUM_TEMP+20
	required_temperature_max = MIN_AQUARIUM_TEMP+30

/obj/item/fish/gunner_jellyfish
	name = "gunner jellyfish"
	desc = "So called due to their resemblance to an artillery shell, the gunner jellyfish is native to Tizira, where it is enjoyed as a delicacy. Produces a mild hallucinogen that is destroyed by cooking."
	icon_state = "gunner_jellyfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 4
	fillet_type = /obj/item/food/fishmeat/gunner_jellyfish
	required_temperature_min = MIN_AQUARIUM_TEMP+24
	required_temperature_max = MIN_AQUARIUM_TEMP+32

/obj/item/fish/needlefish
	name = "needlefish"
	desc = "A tiny, transparent fish which resides in large schools in the oceans of Tizira. A common food for other, larger fish."
	icon_state = "needlefish"
	dedicated_in_aquarium_icon_state = "needlefish_small"
	sprite_width = 7
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 12
	fillet_type = null
	average_size = 20
	average_weight = 300
	fish_traits = list(/datum/fish_trait/carnivore)
	required_temperature_min = MIN_AQUARIUM_TEMP+10
	required_temperature_max = MIN_AQUARIUM_TEMP+32

/obj/item/fish/armorfish
	name = "armorfish"
	desc = "A small shellfish native to Tizira's oceans, known for its exceptionally hard shell. Consumed similarly to prawns."
	icon_state = "armorfish"
	dedicated_in_aquarium_icon_state = "armorfish_small"
	sprite_height = 5
	sprite_width = 6
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 10
	fillet_type = /obj/item/food/fishmeat/armorfish
	fish_ai_type = FISH_AI_SLOW
	required_temperature_min = MIN_AQUARIUM_TEMP+10
	required_temperature_max = MIN_AQUARIUM_TEMP+32

//Chasm fish
/obj/item/fish/chasm_crab
	name = "chasm chrab"
	desc = "The young of the lobstrosity mature in pools below the earth, eating what falls in until large enough to clamber out. Those found near the station are well-fed."
	icon_state = "chrab"
	dedicated_in_aquarium_icon_state = "chrab_small"
	sprite_height = 9
	sprite_width = 8
	stable_population = 4
	feeding_frequency = 15 MINUTES
	random_case_rarity = FISH_RARITY_RARE
	fillet_type = /obj/item/food/meat/slab/rawcrab
	required_temperature_min = MIN_AQUARIUM_TEMP+9
	required_temperature_max = LAVALAND_MAX_TEMPERATURE+50
	min_pressure = HAZARD_LOW_PRESSURE
	safe_air_limits = list(
		/datum/gas/oxygen = list(2, 100),
		/datum/gas/nitrogen,
		/datum/gas/carbon_dioxide = list(0, 20),
		/datum/gas/water_vapor,
		/datum/gas/plasma = list(0, 5),
		/datum/gas/bz = list(0, 5),
		/datum/gas/miasma = list(0, 5),
	)
	evolution_types = list(/datum/fish_evolution/ice_chrab)
	compatible_types = list(/obj/item/fish/chasm_crab/ice)

/obj/item/fish/chasm_crab/ice
	name = "arctic chrab"
	desc = "A subspecies of chasm chrabs that has adapted to the cold climate and lack of abysmal holes of the icemoon."
	icon_state = "arctic_chrab"
	dedicated_in_aquarium_icon_state = "ice_chrab_small"
	required_temperature_min = ICEBOX_MIN_TEMPERATURE-20
	required_temperature_max = MIN_AQUARIUM_TEMP+15
	evolution_types = list(/datum/fish_evolution/chasm_chrab)
	compatible_types = list(/obj/item/fish/chasm_crab)

/obj/item/storage/box/fish_debug
	name = "box full of fish"

/obj/item/storage/box/fish_debug/PopulateContents()
	for(var/fish_type in subtypesof(/obj/item/fish))
		new fish_type(src)

/obj/item/fish/donkfish
	name = "donk co. company patent donkfish"
	desc = "A lab-grown donkfish. Its invention was an accident for the most part, as it was intended to be consumed in donk pockets. Unfortunately, it tastes horrible, so it has now become a pseudo-mascot."
	icon_state = "donkfish"
	random_case_rarity = FISH_RARITY_VERY_RARE
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	stable_population = 4
	fillet_type = /obj/item/food/fishmeat/donkfish
	fish_traits = list(/datum/fish_trait/yucky)
	required_temperature_min = MIN_AQUARIUM_TEMP+15
	required_temperature_max = MIN_AQUARIUM_TEMP+28

/obj/item/fish/emulsijack
	name = "toxic emulsijack"
	desc = "Ah, the terrifying emulsijack. Created in a laboratory, the only real use of this slimey, scaleless fish is for completely ruining a tank."
	icon_state = "emulsijack"
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	stable_population = 3
	fish_traits = list(/datum/fish_trait/emulsijack)
	required_temperature_min = MIN_AQUARIUM_TEMP+5
	required_temperature_max = MIN_AQUARIUM_TEMP+40

/obj/item/fish/jumpercable
	name = "monocloning jumpercable"
	desc = "A surprisingly useful if nasty looking creation from the syndicate fish labs. Drop one in a tank, and \
		watch it self-feed and multiply. Generates more and more power as a growing swarm!"
	icon_state = "jumpercable"
	dedicated_in_aquarium_icon_state = "jumpercable_small"
	sprite_width = 17
	sprite_height = 5
	stable_population = 12
	average_size = 110
	average_weight = 10000
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_temperature_min = MIN_AQUARIUM_TEMP+10
	required_temperature_max = MIN_AQUARIUM_TEMP+30
	favorite_bait = list(/obj/item/stock_parts/cell/lead)
	fish_traits = list(
		/datum/fish_trait/parthenogenesis,
		/datum/fish_trait/mixotroph,
		/datum/fish_trait/electrogenesis,
	)

/obj/item/fish/ratfish
	name = "ratfish"
	desc = "A rat exposed to the murky waters of maintenance too long. Any higher power, if it revealed itself, would state that the ratfish's continued existence is extremely unwelcome."
	icon_state = "ratfish"
	random_case_rarity = FISH_RARITY_RARE
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	stable_population = 10 //set by New, but this is the default config value
	fillet_type = /obj/item/food/meat/slab/human/mutant/zombie //eww...
	fish_traits = list(/datum/fish_trait/necrophage)
	required_temperature_min = MIN_AQUARIUM_TEMP+15
	required_temperature_max = MIN_AQUARIUM_TEMP+35
	fish_ai_type = FISH_AI_ZIPPY
	favorite_bait = list(
		list(
			"Type" = "Foodtype",
			"Value" = DAIRY
		)
	)

/obj/item/fish/ratfish/Initialize(mapload)
	. = ..()
	//stable pop reflects the config for how many mice migrate. powerful...
	stable_population = CONFIG_GET(number/mice_roundstart)

/obj/item/fish/sludgefish
	name = "sludgefish"
	desc = "A misshapen, fragile, loosely fish-like living goop, the only thing that'd ever thrive in the acidic and claustrophobic cavities of the station's organic waste disposal system."
	icon_state = "sludgefish"
	dedicated_in_aquarium_icon_state = "sludgefish_small"
	sprite_width = 7
	sprite_height = 6
	required_fluid_type = AQUARIUM_FLUID_SULPHWATEVER
	stable_population = 8
	average_size = 20
	average_weight = 400
	health = 50
	breeding_timeout = 5 MINUTES
	fish_traits = list(/datum/fish_trait/parthenogenesis, /datum/fish_trait/no_mating)
	required_temperature_min = MIN_AQUARIUM_TEMP+10
	required_temperature_max = MIN_AQUARIUM_TEMP+40
	evolution_types = list(/datum/fish_evolution/purple_sludgefish)

/obj/item/fish/sludgefish/purple
	name = "purple sludgefish"
	desc = "A misshapen, fragile, loosely fish-like living goop. This one has developed sexual reproduction mechanisms, and a purple tint to boot."
	icon_state = "sludgefish_purple"
	dedicated_in_aquarium_icon_state = "sludgefish_purple_small"
	random_case_rarity = FISH_RARITY_NOPE
	fish_traits = list(/datum/fish_trait/parthenogenesis)

/obj/item/fish/slimefish
	name = "acquatic slime"
	desc = "Kids, this is what happens when a slime overcomes its hydrophobic nature. It goes glug glug."
	icon_state = "slimefish"
	icon_state_dead = "slimefish_dead"
	dedicated_in_aquarium_icon_state = "slimefish_small"
	sprite_width = 7
	sprite_height = 7
	do_flop_animation = FALSE //it already has a cute bouncy wiggle. :3
	random_case_rarity = FISH_RARITY_VERY_RARE
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	stable_population = 4
	health = 150
	fillet_type = /obj/item/slime_extract/grey
	grind_results = list(/datum/reagent/toxin/slimejelly = 10)
	fish_traits = list(/datum/fish_trait/toxin_immunity, /datum/fish_trait/crossbreeder)
	favorite_bait = list(
		list(
			"Type" = "Foodtype",
			"Value" = TOXIC,
		),
		list(
			"Type" = "Reagent",
			"Value" = /datum/reagent/toxin,
			"Amount" = 5,
		),
	)
	required_temperature_min = MIN_AQUARIUM_TEMP+20

/obj/item/fish/boned
	name = "unmarine bonemass"
	desc = "What one could mistake for fish remains, is in reality a species that chose to discard its weak flesh a long time ago. A living fossil, in its most literal sense."
	icon_state = "bonemass"
	dedicated_in_aquarium_icon_state = "bonemass_small"
	sprite_width = 10
	sprite_height = 7
	fish_ai_type = FISH_AI_ZIPPY
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_fluid_type = AQUARIUM_FLUID_ANY_WATER
	min_pressure = HAZARD_LOW_PRESSURE
	health = 150
	stable_population = 3
	grind_results = list(/datum/reagent/bone_dust = 20)
	fillet_type = /obj/item/stack/sheet/bone
	num_fillets = 2
	fish_traits = list(/datum/fish_trait/revival, /datum/fish_trait/carnivore)
	average_size = 70
	average_weight = 2000
	death_text = "%SRC stops moving." //It's dead... or is it?
	evolution_types = list(/datum/fish_evolution/mastodon)

/obj/item/fish/mastodon
	name = "unmarine mastodon"
	desc = "A monster of exposed muscles and innards, wrapped in a fish-like skeleton. You don't remember ever seeing it on the catalog."
	icon = 'icons/obj/aquarium/wide.dmi'
	icon_state = "mastodon"
	dedicated_in_aquarium_icon = 'icons/obj/aquarium/fish.dmi'
	dedicated_in_aquarium_icon_state = "mastodon_small"
	base_pixel_x = -16
	pixel_x = -16
	sprite_width = 12
	sprite_height = 7
	show_in_catalog = FALSE
	random_case_rarity = FISH_RARITY_NOPE
	fishing_difficulty_modifier = 5
	required_fluid_type = AQUARIUM_FLUID_ANY_WATER
	min_pressure = HAZARD_LOW_PRESSURE
	health = 300
	stable_population = 2 //This means they can only crossbreed.
	grind_results = list(/datum/reagent/bone_dust = 15, /datum/reagent/consumable/liquidgibs = 5)
	fillet_type = /obj/item/stack/sheet/bone
	num_fillets = 2
	feeding_frequency = 2 MINUTES
	breeding_timeout = 10 MINUTES
	average_size = 180
	average_weight = 5000
	death_text = "%SRC stops moving."
	fish_traits = list(/datum/fish_trait/heavy, /datum/fish_trait/amphibious, /datum/fish_trait/revival, /datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/aggressive)

/obj/item/fish/holo
	name = "holographic goldfish"
	desc = "A holographic representation of a common goldfish, slowly flickering out, removed from its holo-habitat."
	icon_state = "goldfish"
	show_in_catalog = FALSE
	random_case_rarity = FISH_RARITY_NOPE
	sprite_width = 8
	sprite_height = 8
	stable_population = 1
	average_size = 30
	average_weight = 500
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	grind_results = null
	fillet_type = null
	death_text = "%SRC gently disappears."
	fish_traits = list(/datum/fish_trait/no_mating) //just to be sure, these shouldn't reproduce
	experisci_scannable = FALSE

/obj/item/fish/holo/Initialize(mapload)
	. = ..()
	var/area/station/holodeck/holo_area = get_area(src)
	if(!istype(holo_area))
		addtimer(CALLBACK(src, PROC_REF(set_status), FISH_DEAD), 1 MINUTES)
		return
	holo_area.linked.add_to_spawned(src)

/obj/item/fish/holo/set_status(new_status)
	. = ..()
	if(status == FISH_DEAD)
		animate(src, alpha = 0, 3 SECONDS, easing = SINE_EASING)
		QDEL_IN(src, 3 SECONDS)

/obj/item/fish/holo/crab
	name = "holographic crab"
	desc = "A holographic represantion of a soul-crushingly soulless crab, unlike the cuter ones occasionally roaming around. It stares at you, with empty, beady eyes."
	icon_state = "crab"
	dedicated_in_aquarium_icon_state = "crab_small"
	average_weight = 1000
	sprite_height = 6
	sprite_width = 10

/obj/item/fish/holo/puffer
	name = "holographic pufferfish"
	desc ="A holographic representation of 100% safe-to-eat pufferfish... that is, if holographic fishes were even edible."
	icon_state = "pufferfish"
	sprite_width = 8
	sprite_height = 8
	average_size = 60
	average_weight = 1000

/obj/item/fish/holo/angel
	name = "holographic angelfish"
	desc = "A holographic representation of a angelfish. I got nothing snarky to say about this one."
	icon_state = "angelfish"
	dedicated_in_aquarium_icon_state = "bigfish"
	sprite_height = 7

/obj/item/fish/holo/clown
	name = "holographic clownfish"
	icon_state = "holo_clownfish"
	desc = "A holographic representation of a clownfish, or at least how they used to look like five centuries ago."
	dedicated_in_aquarium_icon_state = "holo_clownfish_small"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 5

/obj/item/fish/holo/checkered
	name = "unrendered holographic fish"
	desc = "A checkered silhoutte of searing purple and pitch black presents itself before your eyes, like a tear in fabric of reality. It hurts to watch."
	icon_state = "checkered" //it's a meta joke, buddy.
	dedicated_in_aquarium_icon_state = "checkered_small"
	sprite_width = 4

/obj/item/fish/holo/halffish
	name = "holographic half-fish"
	desc = "A holographic representation of... a fish reduced to all bones, except for its head. Isn't it supposed to be dead? Ehr, holo-dead?"
	icon_state = "half_fish"
	dedicated_in_aquarium_icon_state = "half_fish_small"
	sprite_height = 4
	sprite_width = 10
	average_size = 50

/obj/item/fish/starfish
	name = "cosmostarfish"
	desc = "A peculiar, gravity-defying, echinoderm-looking critter from hyperspace."
	icon_state = "starfish"
	dedicated_in_aquarium_icon_state = "starfish_small"
	icon_state_dead = "starfish_dead"
	sprite_width = 4
	average_size = 30
	average_weight = 300
	stable_population = 3
	required_fluid_type = AQUARIUM_FLUID_AIR
	random_case_rarity = FISH_RARITY_NOPE
	required_temperature_min = 0
	required_temperature_max = INFINITY
	safe_air_limits = null
	min_pressure = 0
	max_pressure = INFINITY
	grind_results = list(/datum/reagent/bluespace = 10, /datum/reagent/consumable/liquidgibs = 5)
	fillet_type = null
	fish_traits = list(/datum/fish_trait/antigrav, /datum/fish_trait/mixotroph)

/obj/item/fish/starfish/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/fish/starfish/update_overlays()
	. = ..()
	if(status == FISH_ALIVE)
		. += emissive_appearance(icon, "starfish_emissive", src)

///It spins, and dimly glows in the dark.
/obj/item/fish/starfish/flop_animation()
	DO_FLOATING_ANIM(src)

/obj/item/fish/lavaloop
	name = "lavaloop fish"
	desc = "Due to its curvature, it can be used as make-shift boomerang."
	icon_state = "lava_loop"
	sprite_width = 3
	sprite_height = 5
	average_size = 30
	average_weight = 500
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	required_fluid_type = AQUARIUM_FLUID_ANY_WATER //if we can survive hot lava and freezing plasrivers, we can survive anything
	fish_ai_type = FISH_AI_ZIPPY
	min_pressure = HAZARD_LOW_PRESSURE
	required_temperature_min = MIN_AQUARIUM_TEMP+30
	required_temperature_max = MIN_AQUARIUM_TEMP+35
	aquarium_vc_color = "#ce7e1d"
	fish_traits = list(
		/datum/fish_trait/carnivore,
		/datum/fish_trait/heavy,
	)
	hitsound = null
	throwforce = 5
	///maximum bonus damage when winded up
	var/maximum_bonus = 25

/obj/item/fish/lavaloop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_BYPASS_RANGED_ARMOR, INNATE_TRAIT)
	AddComponent(/datum/component/boomerang, throw_range, TRUE)
	AddComponent(\
		/datum/component/throwbonus_on_windup,\
		maximum_bonus = maximum_bonus,\
		windup_increment_speed = 2,\
		throw_text = "starts cooking in your hands, it may explode soon!",\
		pass_maximum_callback = CALLBACK(src, PROC_REF(explode_on_user)),\
		apply_bonus_callback = CALLBACK(src, PROC_REF(on_fish_land)),\
		sound_on_success = 'sound/weapons/parry.ogg',\
		effect_on_success = /obj/effect/temp_visual/guardian/phase,\
	)

/obj/item/fish/lavaloop/proc/explode_on_user(mob/living/user)
	var/obj/item/bodypart/arm/active_arm = user.get_active_hand()
	active_arm?.dismember()
	to_chat(user, span_warning("[src] explodes!"))
	playsound(src, 'sound/effects/explosion1.ogg', 40, TRUE)
	user.flash_act(1, 1)
	qdel(src)

/obj/item/fish/lavaloop/proc/on_fish_land(mob/living/target, bonus_value)
	if(!istype(target))
		return FALSE
	return (target.mob_size >= MOB_SIZE_LARGE)

/obj/item/fish/lavaloop/plasma_river
	maximum_bonus = 30

/obj/item/fish/lavaloop/plasma_river/explode_on_user(mob/living/user)
	playsound(src, 'sound/effects/explosion1.ogg', 40, TRUE)
	user.flash_act(1, 1)
	user.apply_status_effect(/datum/status_effect/ice_block_talisman, 5 SECONDS)
	qdel(src)

/obj/item/fish/lavaloop/plasma_river/on_fish_land(mob/living/target, bonus_value)
	if(!istype(target))
		return FALSE
	if(target.mob_size < MOB_SIZE_LARGE)
		return FALSE
	var/freeze_timer = (bonus_value * 0.1)
	if(freeze_timer <= 0)
		return FALSE
	target.apply_status_effect(/datum/status_effect/ice_block_talisman, freeze_timer SECONDS)
	return FALSE

/obj/item/fish/zipzap
	name = "anxious zipzap"
	desc = "A fish overflowing with crippling anxiety and electric potential. Worried about the walls of its tank closing in constantly. Both literally and as a general metaphorical unease about life's direction."
	icon_state = "zipzap"
	icon_state_dead = "zipzap_dead"
	sprite_width = 8
	sprite_height = 8
	stable_population = 3
	average_size = 30
	average_weight = 500
	random_case_rarity = FISH_RARITY_VERY_RARE
	favorite_bait = list(/obj/item/stock_parts/cell/lead)
	required_temperature_min = MIN_AQUARIUM_TEMP+18
	required_temperature_max = MIN_AQUARIUM_TEMP+26
	fish_traits = list(
		/datum/fish_trait/no_mating,
		/datum/fish_trait/wary,
		/datum/fish_trait/anxiety,
		/datum/fish_trait/electrogenesis,
	)
	//anxiety naturally limits the amount of zipzaps per tank, so they are stronger alone
	electrogenesis_power = 20 MEGA JOULES
