/mob/living/simple_animal/fish
	name = "concept of a fish"
	desc = "Fishy."
	icon = 'monkestation/code/modules/ghost_players/arena/arena_assets/icons/fish.dmi'
	icon_state = "guppy"
	icon_living = "guppy"
	turns_per_move = 5
	speak_emote = list("blubs")
	maxHealth = 20
	health = 20
	harm_intent_damage = 1
	del_on_death = 1
	movement_type = FLYING
	friendly_verb_continuous = "nudges"
	friendly_verb_simple = "nudge"
	verb_say = "blubs"
	verb_ask = "blubs inquisitively"
	verb_exclaim = "blubs intensely"
	verb_yell = "blubs intensely"

/mob/living/simple_animal/fish/guppy
	name = "guppy"
	desc = "Guppy is also known as rainbow fish because of the brightly colored body and fins."
	icon_state = "guppy"
	loot = list(/obj/item/fish/guppy)

/mob/living/simple_animal/fish/firefish
	name = "firefish goby"
	desc = "To communicate in the wild, the firefish uses its dorsal fin to alert others of potential danger."
	icon_state = "firefish"
	loot = list(/obj/item/fish/firefish)

/mob/living/simple_animal/fish/greenchromis
	name = "green chromis"
	desc = "The Chromis can vary in color from blue to green depending on the lighting and distance from the lights."
	icon_state = "greenchromis"
	loot = list(/obj/item/fish/greenchromis)

/mob/living/simple_animal/fish/catfish
	name = "cory catfish"
	desc = "A catfish has about 100,000 taste buds, and their bodies are covered with them to help detect chemicals present in the water and also to respond to touch."
	icon_state = "catfish"
	loot = list(/obj/item/fish/catfish)

/mob/living/simple_animal/fish/plasmatetra
	name = "plasma tetra"
	desc = "Due to their small size, tetras are prey to many predators in their watery world, including eels, crustaceans, and invertebrates."
	icon_state = "plastetra"
	loot = list(/obj/item/fish/plasmatetra)

/mob/living/simple_animal/fish/angelfish
	name = "angelfish"
	desc = "Young Angelfish often live in groups, while adults prefer solitary life. They become territorial and aggressive toward other fish when they reach adulthood."
	icon_state = "angelfish"
	loot = list(/obj/item/fish/angelfish)

/mob/living/simple_animal/fish/clownfish
	name = "clownfish"
	desc = "Clownfish catch prey by swimming onto the reef, attracting larger fish, and luring them back to the anemone. The anemone will sting and eat the larger fish, leaving the remains for the clownfish."
	icon_state = "clownfish"
	loot = list(/obj/item/fish/clownfish)

/mob/living/simple_animal/fish/goldfish
	name = "goldfish"
	desc = "Despite common belief, goldfish do not have three-second memories. They can actually remember things that happened up to three months ago."
	icon_state = "goldfish"
	loot = list(/obj/item/fish/goldfish)

/mob/living/simple_animal/fish/dwarf_moonfish
	name = "dwarf moonfish"
	desc = "Ordinarily in the wild, the Zagoskian moonfish is around the size of a tuna, however through selective breeding a smaller breed suitable for being kept as an aquarium pet has been created."
	icon_state = "dwarf_moonfish"
	loot = list(/obj/item/fish/dwarf_moonfish)

/mob/living/simple_animal/fish/gunner_jellyfish
	name = "gunner jellyfish"
	desc = "So called due to their resemblance to an artillery shell, the gunner jellyfish is native to Tizira, where it is enjoyed as a delicacy. Produces a mild hallucinogen that is destroyed by cooking."
	icon_state = "gunner_jellyfish"
	loot = list(/obj/item/fish/gunner_jellyfish)
