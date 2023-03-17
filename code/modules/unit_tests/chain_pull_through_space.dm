/datum/unit_test/chain_pull_through_space
	var/turf/open/space/space_tile
	var/claimed_tile
	var/mob/living/carbon/human/alice
	var/mob/living/carbon/human/bob
	var/mob/living/carbon/human/charlie
	var/targetz = 5
	var/datum/turf_reservation/reserved

/datum/unit_test/chain_pull_through_space/New()
	..()

	//reserve a tile that is always empty for our z destination
	reserved = SSmapping.RequestBlockReservation(5,5)

	// Create a space tile that goes to another z-level
	claimed_tile = run_loc_floor_bottom_left.type

	space_tile = run_loc_floor_bottom_left.ChangeTurf(/turf/open/space)
	space_tile.destination_x = round(reserved.bottom_left_coords[1] + (reserved.width-1) / 2)
	space_tile.destination_y = round(reserved.bottom_left_coords[2] + (reserved.height-1) / 2)
	space_tile.destination_z = reserved.bottom_left_coords[3]

	// Create our list of humans, all adjacent to one another
	alice = new(locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	alice.name = "Alice"

	bob = new(locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	bob.name = "Bob"

	charlie = new(locate(run_loc_floor_bottom_left.x + 4, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	charlie.name = "Charlie"

/datum/unit_test/chain_pull_through_space/Destroy()
	space_tile.ChangeTurf(claimed_tile)
	qdel(alice)
	qdel(bob)
	qdel(charlie)
	qdel(reserved)
	return ..()

/datum/unit_test/chain_pull_through_space/Run()
	// Alice pulls Bob, who pulls Charlie
	// Normally, when Alice moves forward, the rest follow
	alice.start_pulling(bob)
	bob.start_pulling(charlie)

	// Walk normally to the left, make sure we're still a chain
	alice.Move(locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	TEST_ASSERT_EQUAL(bob.x, run_loc_floor_bottom_left.x + 2, "During normal move, Bob was not at the correct x ([bob.x])")
	TEST_ASSERT_EQUAL(charlie.x, run_loc_floor_bottom_left.x + 3, "During normal move, Charlie was not at the correct x ([charlie.x])")

	// We're going through the space turf now that should teleport us
	alice.Move(run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(alice.z, space_tile.destination_z, "Alice did not teleport to the destination z-level. Current location: ([alice.x], [alice.y], [alice.z])")

	TEST_ASSERT_EQUAL(bob.z, space_tile.destination_z, "Bob did not teleport to the destination z-level. Current location: ([bob.x], [bob.y], [bob.z])")
	TEST_ASSERT(bob.Adjacent(alice), "Bob is not adjacent to Alice. Bob is at [bob.x], Alice is at [alice.x]")

	TEST_ASSERT_EQUAL(charlie.z, space_tile.destination_z, "Charlie did not teleport to the destination z-level. Current location: ([charlie.x], [charlie.y], [charlie.z])")
	TEST_ASSERT(charlie.Adjacent(bob), "Charlie is not adjacent to Bob. Charlie is at [charlie.x], Bob is at [bob.x]")
