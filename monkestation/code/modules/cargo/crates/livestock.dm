/datum/supply_pack/critter/carp
	name = "Something Fishy"
	desc = "Something smells fishy..."
	contraband = TRUE
	cost = CARGO_CRATE_VALUE * 9
	contains = list(/mob/living/basic/carp = 3)
	crate_name = "Live seafood crate"

/datum/supply_pack/critter/bears
	name = "Bear-bones collection"
	desc = "From Space Russia with love."
	cost = CARGO_CRATE_VALUE * 12
	hidden = TRUE
	contains = list()

/datum/supply_pack/critter/bears/fill(obj/structure/closet/crate/critter/C)
	for(var/i in 1 to 3)
		var/item = pick(
			prob (20);
				/mob/living/simple_animal/hostile/bear,
			prob (20);
				/mob/living/simple_animal/hostile/bear/snow,
			prob (20);
				/mob/living/simple_animal/hostile/bear/russian,
			prob (20);
				/mob/living/simple_animal/hostile/bear/butter,
			prob (20);
				/mob/living/simple_animal/hostile/bear/hudson
		)
		new item(C)
