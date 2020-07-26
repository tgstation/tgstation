/datum/unit_test/chain_pull_through_space
	var/turf/open/space/space_tile
	var/turf/claimed_tile
	var/mob/living/carbon/human/alice
	var/mob/living/carbon/human/bob
	var/mob/living/carbon/human/charlie

/datum/unit_test/chain_pull_through_space/New()
	..()

	// Create a space tile that goes to another z-level
	claimed_tile = run_loc_bottom_left

	space_tile = new(locate(run_loc_bottom_left.x, run_loc_bottom_left.y, run_loc_bottom_left.z))
	space_tile.destination_x = 100
	space_tile.destination_y = 100
	space_tile.destination_z = 5

	// Create our list of humans, all adjacent to one another
	alice = new(locate(run_loc_bottom_left.x + 2, run_loc_bottom_left.y, run_loc_bottom_left.z))
	alice.name = "Alice"

	bob = new(locate(run_loc_bottom_left.x + 3, run_loc_bottom_left.y, run_loc_bottom_left.z))
	bob.name = "Bob"

	charlie = new(locate(run_loc_bottom_left.x + 4, run_loc_bottom_left.y, run_loc_bottom_left.z))
	charlie.name = "Charlie"

/datum/unit_test/chain_pull_through_space/Destroy()
	space_tile.copyTurf(claimed_tile)
	qdel(alice)
	qdel(bob)
	qdel(charlie)
	return ..()

/datum/unit_test/chain_pull_through_space/Run()
	// Alice pulls Bob, who pulls Charlie
	// Normally, when Alice moves forward, the rest follow
	// Alice is at the front but bob grabs charlie first
	bob.start_pulling(charlie)
	alice.start_pulling(bob)

	// Walk normally to the left, make sure we're still a chain
	walk_to(alice, locate(run_loc_bottom_left.x + 1, run_loc_bottom_left.y, run_loc_bottom_left.z), 0, 0, alice.step_size)
	if(!alice.check_pulling())
		return Fail("During normal move, Bob was no longer being pulled by Alice, Alice's x: [alice.x] Bob's x: [bob.x]")
	if(!bob.check_pulling())
		var/dist = bounds_dist(bob, charlie)
		return Fail("During normal move, Charlie was no longer being pulled by Bob, Bob's x: [bob.x] Charlie's x: [charlie.x] distance: [dist]")

	// We're going through the space turf now that should teleport us
	alice.Move(run_loc_bottom_left)
	if (alice.z != space_tile.destination_z)
		return Fail("Alice did not teleport to the destination z-level. Current z: ([alice.z]) Expected z: [(space_tile.destination_z)]")

	if (bob.z != space_tile.destination_z)
		return Fail("Bob did not teleport to the destination z-level. Current z: ([bob.z]) Expected z: [(space_tile.destination_z)]")
	if (!bob.Adjacent(alice))
		return Fail("Bob is not adjacent to Alice. Bob is at [bob.x], Alice is at [alice.x]")

	if (charlie.z != space_tile.destination_z)
		return Fail("Charlie did not teleport to the destination z-level. Current z: ([charlie.z]) Expected z: [(space_tile.destination_z)]")
	if (!charlie.Adjacent(bob))
		return Fail("Charlie is not adjacent to Bob. Charlie is at [charlie.x], Bob is at [bob.x]")
