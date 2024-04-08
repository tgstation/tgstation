/datum/slime_mutation_data/metal
	output = /datum/slime_color/metal
	needed_items = list(/obj/item/stack/sheet/iron)

/datum/slime_mutation_data/orange
	output = /datum/slime_color/orange
	needed_items = list(/obj/item/stack/sheet/mineral/plasma)

/datum/slime_mutation_data/purple
	output = /datum/slime_color/purple
	needed_items = list(/obj/item/stack/medical/gauze)

/datum/slime_mutation_data/blue
	output = /datum/slime_color/blue
	latch_needed = list(/mob/living/basic/cockroach/iceroach = 50)

/datum/slime_mutation_data/cerulean
	output = /datum/slime_color/cerulean
	latch_needed = list(/mob/living/basic/cockroach/recursive = 40)

/datum/slime_mutation_data/dark_blue
	output = /datum/slime_color/dark_blue
	latch_needed = list(/mob/living/basic/xenofauna/diyaab = 75)

/datum/slime_mutation_data/red
	output = /datum/slime_color/red
	latch_needed = list(/mob/living/basic/xenofauna/lavadog = 50)

/datum/slime_mutation_data/oil
	output = /datum/slime_color/oil
	latch_needed = list(/mob/living/basic/xenofauna/dron = 65)

/datum/slime_mutation_data/yellow
	output = /datum/slime_color/yellow
	needed_items = list(/obj/item/stock_parts/cell)

/datum/slime_mutation_data/green
	output = /datum/slime_color/green
	latch_needed = list(/mob/living/basic/xenofauna/greeblefly = 65)

/datum/slime_mutation_data/sepia
	output = /datum/slime_color/sepia
	latch_needed = list(/mob/living/basic/xenofauna/possum = 65)

/datum/slime_mutation_data/black
	output = /datum/slime_color/black
	latch_needed = list(/mob/living/basic/xenofauna/thoom = 50)

/datum/slime_mutation_data/silver
	output = /datum/slime_color/silver
	latch_needed = list(/mob/living/basic/xenofauna/meatbeast = 80)

/datum/slime_mutation_data/gold
	output = /datum/slime_color/gold
	needed_items = list(/obj/item/stack/sheet/mineral/gold)

/datum/slime_mutation_data/adamantine
	output = /datum/slime_color/adamantine
	needed_items = list(/obj/item/rockroach_shell)

/datum/slime_mutation_data/darkpurple
	output = /datum/slime_color/darkpurple
	needed_items = list(/obj/item/slime_extract/purple)

/datum/slime_mutation_data/pink
	output = /datum/slime_color/pink
	latch_needed = list(/mob/living/basic/xenofauna/thinbug = 80)

/datum/slime_mutation_data/pyrite
	output = /datum/slime_color/pyrite
	needed_items = list(/obj/item/toy/crayon/rainbow)

/datum/slime_mutation_data/bluespace
	output = /datum/slime_color/bluespace
	needed_items = list(/obj/item/stack/ore/bluespace_crystal)

/datum/slime_mutation_data/lightpink
	output = /datum/slime_color/lightpink
	latch_needed = list(/mob/living/basic/xenofauna/voxslug = 80)

/datum/slime_mutation_data/rainbow
	output = /datum/slime_color/rainbow
	needed_items = list(
		/obj/item/slime_extract/orange = 1,
		/obj/item/slime_extract/purple = 1,
		/obj/item/slime_extract/blue = 1,
		/obj/item/slime_extract/metal = 1,
		/obj/item/slime_extract/yellow = 1,
		/obj/item/slime_extract/darkblue = 1,
		/obj/item/slime_extract/darkpurple = 1,
		/obj/item/slime_extract/silver = 1,
	)
	syringe_blocked = TRUE
