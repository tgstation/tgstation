/// Unit test to ensure pizza boxes can be picked up when both hands are full
/datum/unit_test/pizzabox_pickup

/datum/unit_test/pizzabox_pickup/Run()
	var/obj/item/pizzabox/margherita/test_box = allocate(/obj/item/pizzabox/margherita)
	var/mob/living/carbon/human/test_user = allocate(/mob/living/carbon/human)
	
	// Open the box and slice the pizza
	test_box.open = TRUE
	test_box.pizza.slice()
	
	// Put the box on the ground (simulate dropping it)
	test_box.forceMove(get_turf(test_user))
	
	// Test 1: Normal behavior - empty hands should give a slice
	var/initial_slices = test_box.pizza.slices_left
	test_box.attack_hand(test_user)
	TEST_ASSERT(test_box.pizza.slices_left == initial_slices - 1, "Pizza box should give a slice when hands are empty")
	
	// Test 2: One hand full should still give a slice (preserve existing behavior)
	var/obj/item/paper/dummy1 = allocate(/obj/item/paper)
	test_user.put_in_active_hand(dummy1)
	var/slices_before_one_hand = test_box.pizza.slices_left
	test_box.attack_hand(test_user)
	TEST_ASSERT(test_box.pizza.slices_left == slices_before_one_hand - 1, "Pizza box should give a slice when only one hand is full")
	
	// Clean up the slice that was dropped when user couldn't hold it
	var/obj/item/food/pizzaslice/dropped_slice = locate(/obj/item/food/pizzaslice) in get_turf(test_user)
	if(dropped_slice)
		qdel(dropped_slice)
	
	// Test 3: Fill both hands and try to pick up the box
	var/obj/item/paper/dummy2 = allocate(/obj/item/paper) 
	test_user.put_in_inactive_hand(dummy2)
	
	// Verify both hands are full
	TEST_ASSERT(test_user.get_active_held_item() != null, "Active hand should be full")
	TEST_ASSERT(test_user.get_inactive_held_item() != null, "Inactive hand should be full") 
	
	// The box should not give another slice when hands are full
	var/slices_before_full_hands = test_box.pizza.slices_left
	test_box.attack_hand(test_user)
	TEST_ASSERT(test_box.pizza.slices_left == slices_before_full_hands, "Pizza box should not give a slice when both hands are full")
	
	// Test 4: Verify that closed boxes can always be picked up (existing behavior)
	test_box.open = FALSE
	var/slices_before_closed = test_box.pizza.slices_left
	test_box.attack_hand(test_user)  
	TEST_ASSERT(test_box.pizza.slices_left == slices_before_closed, "Closed pizza box should not give slices")