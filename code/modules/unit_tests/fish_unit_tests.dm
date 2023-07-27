#define TRAIT_FISH_TESTING "made_you_read_this"

///Checks that things associated with fish size and weight work correctly.
/datum/unit_test/fish_size_weight

/datum/unit_test/fish_size_weight/Run()
	var/obj/item/fish/fish = allocate(/obj/item/fish/testdummy)
	TEST_ASSERT_EQUAL(fish.grind_results[/datum/reagent], 20, "the test fish has [fish.grind_results[/datum/reagent]] units of reagent when it should have 20")
	TEST_ASSERT_EQUAL(fish.w_class, WEIGHT_CLASS_BULKY, "the test fish has w_class of [fish.w_class] when it should have been [WEIGHT_CLASS_BULKY]")
	var/expected_num_fillets = round(FISH_SIZE_BULKY_MAX / FISH_FILLET_NUMBER_SIZE_DIVISOR * 2, 1)
	TEST_ASSERT_EQUAL(fish.num_fillets, expected_num_fillets, "the test fish has [fish.num_fillets] number of fillets when it should have [expected_num_fillets]")

///Checks that fish breeding works correctly.
/datum/unit_test/fish_breeding

/datum/unit_test/fish_breeding/Run()
	var/obj/item/fish/fish = allocate(/obj/item/fish/testdummy)
	///Check if the fishes can generate offsprings at all.
	var/obj/item/fish/fish_two = allocate(/obj/item/fish/testdummy/two)
	var/obj/item/fish/new_fish = fish.create_offspring(fish_two.type, fish_two)
	TEST_ASSERT(new_fish, "the two test fishes couldn't generate an offspring")
	var/traits_len = length(new_fish.fish_traits)
	TEST_ASSERT_NOTEQUAL(traits_len, 2, "the offspring of the test fishes has both parents' traits, which are incompatible with each other")
	TEST_ASSERT_NOTEQUAL(traits_len, 0, "the offspring has neither of the parents' traits")
	TEST_ASSERT(HAS_TRAIT(new_fish, TRAIT_FISH_TESTING), "The offspring doesn't have the relative datum trait associated with its fish trait")

	///Check that crossbreeder, no-mating and self-reproductive fish traits work correctly.
	var/obj/structure/aquarium/traits/aquarium = allocate(/obj/structure/aquarium/traits)
	TEST_ASSERT(!aquarium.sterile.try_to_reproduce(), "The test aquarium's sterile fish managed to reproduce when it shouldn't have")
	var/obj/item/fish/crossbreeder_jr = aquarium.crossbreeder.try_to_reproduce()
	TEST_ASSERT(crossbreeder_jr, "The test aquarium's crossbreeder fish didn't manage to reproduce when it should have.")
	TEST_ASSERT_EQUAL(crossbreeder_jr.type, aquarium.cloner.type, "The test aquarium's crossbreeder fish mated with the wrong type of fish")
	var/obj/item/fish/cloner_jr = aquarium.cloner.try_to_reproduce()
	TEST_ASSERT(cloner_jr, "The test aquarium's cloner fish didn't manage to reproduce when it should have.")
	TEST_ASSERT_NOTEQUAL(cloner_jr.type, aquarium.sterile.type, "The test aquarium's cloner fish mated with the sterile fish")

///Checks that fish evolutions work correctly.
/datum/unit_test/fish_evolution

/datum/unit_test/fish_evolution/Run()
	var/obj/structure/aquarium/evolution/aquarium = allocate(/obj/structure/aquarium/evolution)
	var/obj/item/fish/evolve_jr = aquarium.evolve.try_to_reproduce()
	TEST_ASSERT(evolve_jr, "The test aquarium's evolution fish didn't manage to reproduce when it should have")
	TEST_ASSERT_NOTEQUAL(evolve_jr.type, /obj/item/fish/goldfish, "The test aquarium's evolution fish managed to pass the conditions of an impossible evolution.")
	TEST_ASSERT_EQUAL(evolve_jr.type, /obj/item/fish/clownfish, "The test aquarium's evolution fish's offspring isn't of the expected type")
	TEST_ASSERT(!(/datum/fish_trait/dummy in evolve_jr.fish_traits), "The test aquarium's evolution fish's offspring still has the old trait that ought to be removed by the evolution datum")
	TEST_ASSERT(/datum/fish_trait/dummy/two in evolve_jr.fish_traits, "The test aquarium's evolution fish's offspring doesn't have the evolution trait")

///dummy fish item used for the tests, as well with related subtypes and datums.
/obj/item/fish/testdummy
	grind_results = list()
	average_weight = FISH_GRIND_RESULTS_WEIGHT_DIVISOR * 2
	average_size = FISH_SIZE_BULKY_MAX
	num_fillets = 2
	fish_traits = list(/datum/fish_trait/dummy)
	stable_population = INFINITY
	breeding_timeout = 0

/obj/item/fish/testdummy/two
	fish_traits = list(/datum/fish_trait/dummy/two)

/datum/fish_trait/dummy
	incompatible_traits = list(/datum/fish_trait/dummy/two)
	inheritability = 100
	diff_traits_inheritability = 100

/datum/fish_trait/dummy/apply_to_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_TESTING, FISH_TRAIT_DATUM)
	fish.grind_results[/datum/reagent] = 10

/datum/fish_trait/dummy/two
	incompatible_traits = list(/datum/fish_trait/dummy)

/obj/structure/aquarium/traits
	allow_breeding = TRUE
	var/obj/item/fish/testdummy/crossbreeder/crossbreeder
	var/obj/item/fish/testdummy/cloner/cloner
	var/obj/item/fish/testdummy/sterile/sterile

/obj/structure/aquarium/traits/Initialize(mapload)
	. = ..()
	crossbreeder = new(src)
	cloner = new(src)
	sterile = new(src)

/obj/item/fish/testdummy/crossbreeder
	fish_traits = list(/datum/fish_trait/crossbreeder)

/obj/item/fish/testdummy/cloner
	fish_traits = list(/datum/fish_trait/parthenogenesis)

/obj/item/fish/testdummy/sterile
	fish_traits = list(/datum/fish_trait/no_mating)

/obj/structure/aquarium/evolution
	allow_breeding = TRUE
	var/obj/item/fish/testdummy/evolve/evolve
	var/obj/item/fish/testdummy/evolve_two/evolve_two

/obj/structure/aquarium/evolution/Initialize(mapload)
	. = ..()
	evolve = new(src)
	evolve_two = new(src)

/obj/item/fish/testdummy/evolve
	compatible_types = list(/obj/item/fish/testdummy/evolve_two)
	evolution_types = list(/datum/fish_evolution/dummy)

/obj/item/fish/testdummy/evolve_two
	compatible_types = list(/obj/item/fish/testdummy/evolve)
	evolution_types = list(/datum/fish_evolution/dummy/two)

/datum/fish_evolution/dummy
	probability = 200 //Guaranteed chance even if halved.
	new_fish_type = /obj/item/fish/clownfish
	new_traits = list(/datum/fish_trait/dummy/two)
	removed_traits = list(/datum/fish_trait/dummy)

/datum/fish_evolution/dummy/two
	new_fish_type = /obj/item/fish/goldfish

/datum/fish_evolution/dummy/two/New()
	. = ..()
	probability = 0 //works around the global list initialization skipping abstract/impossible evolutions.

#undef TRAIT_FISH_TESTING

