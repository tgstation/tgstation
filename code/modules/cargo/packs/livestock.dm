/datum/supply_pack/critter
	group = "Livestock"
	crate_type = /obj/structure/closet/crate/critter

/datum/supply_pack/critter/parrot
	name = "Bird Crate"
	desc = "Contains five expert telecommunication birds."
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/mob/living/simple_animal/parrot)
	crate_name = "parrot crate"

/datum/supply_pack/critter/parrot/generate()
	. = ..()
	for(var/i in 1 to 4)
		new /mob/living/simple_animal/parrot(.)

/datum/supply_pack/critter/butterfly
	name = "Butterflies Crate"
	desc = "Not a very dangerous insect, but they do give off a better image than, say, flies or cockroaches."//is that a motherfucking worm reference
	contraband = TRUE
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/mob/living/basic/butterfly)
	crate_name = "entomology samples crate"

/datum/supply_pack/critter/butterfly/generate()
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/basic/butterfly(.)

/datum/supply_pack/critter/cat
	name = "Cat Crate"
	desc = "The cat goes meow! Comes with a collar and a nice cat toy! Cheeseburger not included."//i can't believe im making this reference
	cost = CARGO_CRATE_VALUE * 10 //Cats are worth as much as corgis.
	contains = list(/mob/living/simple_animal/pet/cat,
					/obj/item/clothing/neck/petcollar,
					/obj/item/toy/cattoy,
				)
	crate_name = "cat crate"

/datum/supply_pack/critter/cat/generate()
	. = ..()
	if(prob(50))
		var/mob/living/simple_animal/pet/cat/C = locate() in .
		qdel(C)
		new /mob/living/simple_animal/pet/cat/_proc(.)

/datum/supply_pack/critter/chick
	name = "Chicken Crate"
	desc = "The chicken goes bwaak!"
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/chick)
	crate_name = "chicken crate"

/datum/supply_pack/critter/corgi
	name = "Corgi Crate"
	desc = "Considered the optimal dog breed by thousands of research scientists, this Corgi is but \
		one dog from the millions of Ian's noble bloodline. Comes with a cute collar!"
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/mob/living/basic/pet/dog/corgi,
					/obj/item/clothing/neck/petcollar,
				)
	crate_name = "corgi crate"

/datum/supply_pack/critter/corgi/generate()
	. = ..()
	if(prob(50))
		var/mob/living/basic/pet/dog/corgi/D = locate() in .
		if(D.gender == FEMALE)
			qdel(D)
			new /mob/living/basic/pet/dog/corgi/lisa(.)

/datum/supply_pack/critter/cow
	name = "Cow Crate"
	desc = "The cow goes moo! Contains one cow."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/basic/cow)
	crate_name = "cow crate"

/datum/supply_pack/critter/sheep
	name = "Sheep Crate"
	desc = "The sheep goes BAAAA! Contains one sheep."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/basic/sheep)
	crate_name = "sheep crate"

/datum/supply_pack/critter/pig
	name = "Pig Crate"
	desc = "The pig goes oink! Contains one pig."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/basic/pig)
	crate_name = "pig crate"

/datum/supply_pack/critter/pony
	name = "Pony Crate"
	desc = "Ponies, yay! (Just the one.)"
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/basic/pony)
	crate_name = "pony crate"

/datum/supply_pack/critter/crab
	name = "Crab Rocket"
	desc = "CRAAAAAAB ROCKET. CRAB ROCKET. CRAB ROCKET. CRAB CRAB CRAB CRAB CRAB CRAB CRAB \
		CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB \
		CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB \
		CRAB CRAB CRAB CRAB CRAB CRAB ROCKET. CRAFT. ROCKET. BUY. CRAFT ROCKET. CRAB ROOOCKET. \
		CRAB ROOOOCKET. CRAB CRAB CRAB CRAB CRAB CRAB CRAB CRAB ROOOOOOOOOOOOOOOOOOOOOOCK \
		EEEEEEEEEEEEEEEEEEEEEEEEE EEEETTTTTTTTTTTTAAAAAAAAA AAAHHHHHHHHHHHHH. CRAB ROCKET. CRAAAB \
		ROCKEEEEEEEEEGGGGHHHHTT CRAB CRAB CRAABROCKET CRAB ROCKEEEET."//fun fact: i actually spent like 10 minutes and transcribed the entire video.
	cost = CARGO_CRATE_VALUE * 8
	contains = list(/mob/living/basic/crab)
	crate_name = "look sir free crabs"
	drop_pod_only = TRUE

/datum/supply_pack/critter/crab/generate()
	. = ..()
	for(var/i in 1 to 49)
		new /mob/living/basic/crab(.)

/datum/supply_pack/critter/corgis/exotic
	name = "Exotic Corgi Crate"
	desc = "Corgi fit for a king, this corgi comes in a unique color to signify their superiority. \
		Comes with a cute collar!"
	cost = CARGO_CRATE_VALUE * 11
	contains = list(/mob/living/basic/pet/dog/corgi/exoticcorgi,
					/obj/item/clothing/neck/petcollar,
				)
	crate_name = "exotic corgi crate"

/datum/supply_pack/critter/fox
	name = "Fox Crate"
	desc = "The fox goes...? Contains one fox. Comes with a collar!"//what does the fox say
	cost = CARGO_CRATE_VALUE * 10
	contains = list(
		/mob/living/basic/pet/fox,
		/obj/item/clothing/neck/petcollar,
	)
	crate_name = "fox crate"

/datum/supply_pack/critter/goat
	name = "Goat Crate"
	desc = "The goat goes baa! Contains one goat. Warranty void if used as a replacement for Pete."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/mob/living/basic/goat)
	crate_name = "goat crate"

/datum/supply_pack/critter/rabbit
	name = "Rabbit Crate"
	desc = "What noise do rabbits even make? Contains one rabbit."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/rabbit)
	crate_name = "rabbit crate"

/datum/supply_pack/critter/mothroach
	name = "Mothroach Crate"
	desc = "Put the mothroach on your head and find out what true cuteness looks like. \
		Contains one mothroach."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/mothroach)
	crate_name = "mothroach crate"

/datum/supply_pack/critter/monkey
	name = "Monkey Cube Crate"
	desc = "Stop monkeying around! Contains seven monkey cubes. Just add water!"
	cost = CARGO_CRATE_VALUE * 4
	contains = list (/obj/item/storage/box/monkeycubes)
	crate_type = /obj/structure/closet/crate
	crate_name = "monkey cube crate"

/datum/supply_pack/critter/pug
	name = "Pug Crate"
	desc = "Like a normal dog, but... squished. Contains one pug. Comes with a nice collar!"
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/mob/living/basic/pet/dog/pug,
					/obj/item/clothing/neck/petcollar,
				)
	crate_name = "pug crate"

/datum/supply_pack/critter/bullterrier
	name = "Bull Terrier Crate"
	desc = "Like a normal dog, but with a head the shape of an egg. Contains one bull terrier. \
		Comes with a nice collar!"
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/mob/living/basic/pet/dog/bullterrier,
					/obj/item/clothing/neck/petcollar,
				)
	crate_name = "bull terrier crate"

/datum/supply_pack/critter/snake
	name = "Snake Crate"
	desc = "Tired of these MOTHER FUCKING snakes on this MOTHER FUCKING space station? \
		Then this isn't the crate for you. Contains three venomous snakes."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/basic/snake = 3)
	crate_name = "snake crate"

/datum/supply_pack/critter/amphibians
	name = "Amphibian Friends Crate"
	desc = "Two disgustingly cute slimey friends. Cytologists love them! \
		Contains one frog and one axolotl. Warning: Frog may have hallucinogenic properties."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/mob/living/basic/axolotl,
		/mob/living/basic/frog,
	)
	crate_name = "amphibian crate"

/datum/supply_pack/critter/lizard
	name = "Lizard Crate"
	desc = "Hisss! Containssss a friendly lizard. Not to be confusssed with a lizardperssson."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/basic/lizard)
	crate_name = "lizard crate"

/datum/supply_pack/critter/garden_gnome
	name = "Garden Gnome Crate"
	desc = "Collect them all for your garden. Comes with three!"
	hidden = TRUE
	cost = CARGO_CRATE_VALUE * 20
	contains = list(/mob/living/basic/garden_gnome)
	crate_name = "garden gnome crate"

/datum/supply_pack/critter/garden_gnome/generate()
	. = ..()
	for(var/i in 1 to 2)
		new /mob/living/basic/garden_gnome(.)

/datum/supply_pack/critter/fish
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/critter/fish/aquarium_fish
	name = "Aquarium Fish Case"
	desc = "An aquarium fish bundle handpicked by monkeys from our collection. Contains two random fish."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/fish_case/random = 2)
	crate_name = "aquarium fish crate"

/datum/supply_pack/critter/fish/freshwater_fish
	name = "Freshwater Fish Case"
	desc = "Aquarium fish that have had most of their mud cleaned off."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/fish_case/random/freshwater = 2)
	crate_name = "freshwater fish crate"

/datum/supply_pack/critter/fish/saltwater_fish
	name = "Saltwater Fish Case"
	desc = "Aquarium fish that fill the room with the smell of salt."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/fish_case/random/saltwater = 2)
	crate_name = "saltwater fish crate"

/datum/supply_pack/critter/fish/tiziran_fish
	name = "Tiziran Fish Case"
	desc = "Tiziran saltwater fish imported from the Zagos Sea."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/fish_case/tiziran = 2)
	crate_name = "tiziran fish crate"
