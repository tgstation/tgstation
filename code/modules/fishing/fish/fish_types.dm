// Freshwater fish

/obj/item/fish/goldfish
	name = "goldfish"
	desc = "Despite common belief, goldfish do not have three-second memories. They can actually remember things that happened up to three months ago."
	icon_state = "goldfish"
	sprite_width = 8
	sprite_height = 8
	stable_population = 3
	average_size = 30
	average_weight = 500
	favorite_bait = list(/obj/item/food/bait/worm)

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

/obj/item/fish/plasmatetra
	name = "plasma tetra"
	desc = "Due to their small size, tetras are prey to many predators in their watery world, including eels, crustaceans, and invertebrates."
	icon_state = "plastetra"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	aquarium_vc_color = "#D30EB0"
	average_size = 30
	average_weight = 500
	stable_population = 3

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

	fishing_traits = list(/datum/fishing_trait/picky_eater)

/obj/item/fish/cardinal
	name = "cardinalfish"
	desc = "Cardinalfish are often found near sea urchins, where the fish hide when threatened."
	icon_state = "cardinalfish"
	dedicated_in_aquarium_icon_state = "fish_greyscale"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	average_size = 30
	average_weight = 500
	stable_population = 4
	fishing_traits = list(/datum/fishing_trait/vegan)

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

/obj/item/fish/pufferfish
	name = "pufferfish"
	desc = "One Pufferfish contains enough toxins in its liver to kill 30 people."
	icon_state = "pufferfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	sprite_width = 8
	sprite_height = 8
	average_size = 60
	average_weight = 1000
	stable_population = 3

	fishing_traits = list(/datum/fishing_trait/heavy)

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

	fishing_traits = list(/datum/fishing_trait/nocturnal)

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

/obj/item/fish/gunner_jellyfish
	name = "gunner jellyfish"
	desc = "So called due to their resemblance to an artillery shell, the gunner jellyfish is native to Tizira, where it is enjoyed as a delicacy. Produces a mild hallucinogen that is destroyed by cooking."
	icon_state = "gunner_jellyfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 4
	fillet_type = /obj/item/food/fishmeat/gunner_jellyfish

/obj/item/fish/needlefish
	name = "needlefish"
	desc = "A tiny, transparent fish which resides in large schools in the oceans of Tizira. A common food for other, larger fish."
	icon_state = "needlefish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 12
	fillet_type = null
	average_size = 30
	average_weight = 300
	fishing_traits = list(/datum/fishing_trait/carnivore)

/obj/item/fish/armorfish
	name = "armorfish"
	desc = "A small shellfish native to Tizira's oceans, known for its exceptionally hard shell. Consumed similarly to prawns."
	icon_state = "armorfish"
	required_fluid_type = AQUARIUM_FLUID_SALTWATER
	stable_population = 10
	fillet_type = /obj/item/food/fishmeat/armorfish
	fish_ai_type = FISH_AI_SLOW

//Chasm fish
/obj/item/fish/chasm_crab
	name = "chasm chrab"
	desc = "The young of the lobstrosity mature in pools below the earth, eating what falls in until large enough to clamber out. Those found near the station are well-fed."
	icon_state = "chrab"
	dedicated_in_aquarium_icon_state = "chrab_small"
	sprite_height = 9
	sprite_width = 8
	source_height = 9
	source_width = 8
	stable_population = 4
	feeding_frequency = 15 MINUTES
	random_case_rarity = FISH_RARITY_RARE
	fillet_type = /obj/item/food/meat/slab/rawcrab

/obj/item/storage/box/fish_debug
	name = "box full of fish"

/obj/item/storage/box/fish_debug/PopulateContents()
	for(var/fish_type in subtypesof(/obj/item/fish))
		new fish_type(src)

/obj/item/fish/ratfish
	name = "ratfish"
	desc = "A rat exposed to the murky waters of maintenance too long. Any higher power, if it revealed itself, would state that the ratfish's continued existence is extremely unwelcome."
	icon_state = "ratfish"
	random_case_rarity = FISH_RARITY_RARE
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	stable_population = 10 //set by New, but this is the default config value
	fillet_type = /obj/item/food/meat/slab/human/mutant/zombie //eww...

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

/obj/item/fish/red_herring
	name = "red herring"
	desc = "A rare, anomalous fish that cloaks nearby creatures when in distress."
	icon_state = "red_herring"
	random_case_rarity = FISH_RARITY_VERY_RARE
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	average_size = 100
	average_weight = 1500

	fish_ai_type = FISH_AI_SLOW
	/// lazylist of weakrefs referring to everyone who is cloaked.
	var/list/weak_cloaked
	/// range of turfs that will cloak mobs, when flopping.
	var/cloak_range = 3

/obj/item/fish/red_herring/stop_flopping()
	. = ..()
	clear_cloaked()

/obj/item/fish/red_herring/process(delta_time)
	. = ..()
	if(!flopping)
		return
	LAZYINITLIST(weak_cloaked)
	//grab who we have right now
	var/list/cloaked = recursive_list_resolve(weak_cloaked)
	//remove those who aren't cloaked anymore
	for(var/mob/living/old_cloaked as anything in cloaked)
		if(get_dist(src, old_cloaked) > cloak_range)
			var/datum/status_effect/red_herring/cloaking_effect = old_cloaked.has_status_effect(/datum/status_effect/red_herring)
			if(cloaking_effect)
				qdel(cloaking_effect)
			cloaked.Remove(old_cloaked)
	//add those who should be cloaked
	for(var/mob/living/new_cloaked in range(src, cloak_range))
		cloaked |= new_cloaked
		new_cloaked.apply_status_effect(/datum/status_effect/red_herring)
	//save weakref of the changes
	weak_cloaked = weakrefify_list(cloaked)

/obj/item/fish/red_herring/proc/clear_cloaked()
	if(!weak_cloaked)
		return
	//grab who we have right now
	var/list/cloaked = recursive_list_resolve(weak_cloaked)
	//remove those who aren't cloaked anymore
	for(var/mob/living/old_cloaked as anything in cloaked)
		var/datum/status_effect/red_herring/cloaking_effect = old_cloaked.has_status_effect(/datum/status_effect/red_herring)
		if(cloaking_effect)
			qdel(cloaking_effect)
	cloaked = null

/datum/status_effect/red_herring
	id = "Red Herring"
	alert_type = /atom/movable/screen/alert/status_effect/red_herring

/datum/status_effect/red_herring/on_apply()
	. = ..()
	animate(owner, alpha = 5, time = 1.5 SECONDS)
	to_chat(owner, span_notice("The red herring cloaks you!"))

/datum/status_effect/red_herring/on_remove()
	. = ..()
	animate(owner, alpha = initial(owner.alpha), time = 1.5 SECONDS)
	to_chat(owner, span_warning("You are no longer cloaked by the red herring!"))

/atom/movable/screen/alert/status_effect/red_herring
	name = "Red Herring Cloaking"
	desc = "Being near the red herring while it is panicking is cloaking you!"
	icon_state = "red_herring"
