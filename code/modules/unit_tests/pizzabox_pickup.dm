/// Unit test to ensure pizza boxes can be picked up when on the ground
/datum/unit_test/pizzabox_pickup

/datum/unit_test/pizzabox_pickup/Run()
	var/obj/item/pizzabox/margherita/test_box = allocate(/obj/item/pizzabox/margherita)
	var/mob/living/carbon/human/test_user = allocate(/mob/living/carbon/human)
	
	// Open the box and slice the pizza
	test_box.open = TRUE
	test_box.pizza.slice()
	
	// Put the box on the ground (simulate dropping it)
	test_box.forceMove(get_turf(test_user))
	
	// Test 1: Should be able to pick up box from ground even with sliced pizza
	test_box.attack_hand(test_user)
	TEST_ASSERT(test_box.loc == test_user, "Pizza box should be picked up from ground even with sliced pizza")
	
	// Test 2: When holding the box, should be able to take slices
	test_user.put_in_inactive_hand(test_box)
	var/initial_slices = test_box.pizza.slices_left
	test_box.attack_hand(test_user)
	TEST_ASSERT(test_box.pizza.slices_left == initial_slices - 1, "Should get slice when holding pizza box")
	
	// Clean up any dropped slice
	var/obj/item/food/pizzaslice/dropped_slice = locate(/obj/item/food/pizzaslice) in get_turf(test_user)
	if(dropped_slice)
		qdel(dropped_slice)
	
	// Test 3: When holding box with unsliced pizza, should take out whole pizza
	// First put a new unsliced pizza in the box
	test_box.pizza = allocate(/obj/item/food/pizza/margherita)
	test_box.pizza.sliced = FALSE
	test_box.attack_hand(test_user)
	TEST_ASSERT(test_box.pizza == null, "Whole pizza should be removed when unsliced")
	TEST_ASSERT(test_user.get_active_held_item().type == /obj/item/food/pizza/margherita, "Should get whole pizza in active hand")
	
	// Clean up
	test_user.dropItemToGround(test_user.get_active_held_item())
	
	// Test 4: Verify that closed boxes can always be picked up (existing behavior)
	test_box.open = FALSE
	test_user.dropItemToGround(test_box)
	test_box.attack_hand(test_user)  
	TEST_ASSERT(test_box.loc == test_user, "Closed pizza box should be picked up normally")