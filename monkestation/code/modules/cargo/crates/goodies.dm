/datum/supply_pack/goody/walkman
	name = "Walkman Single-pack"
	desc = "5 Walkmen is too much for the average man on the average occasion. Solution: 1 Singular Walkman. Contains 1 Walkman."
	cost = PAYCHECK_CREW * 3
	contains = list(/obj/item/device/walkman)

/datum/supply_pack/goody/cassette
	name = "Cassette Mini-Pack"
	desc = "Alright, we'll admit it, 10 cassettes are too much for the majority of our users. Contains 3 Approved Cassettes."
	cost = PAYCHECK_CREW * 5
	contains = list(/obj/item/device/cassette_tape/random = 3)

/datum/supply_pack/goody/blankcassette
	name = "Blank Cassette Mini-Pack"
	desc = "NO! We wont admit defeat! You will march yourself down to the Service section and purchase the 10 Blank Cassette pack instead of this Weak 3 Blank Cassette Pack!"
	cost = PAYCHECK_CREW * 3
	contains = list(/obj/item/device/cassette_tape/blank = 3)
