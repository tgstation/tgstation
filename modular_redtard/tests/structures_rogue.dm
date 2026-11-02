#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// A hand opens a tent flap, which then lets one through and lets the eye through, and closes it again.
/datum/unit_test/rogue_structures_tent_flap

/datum/unit_test/rogue_structures_tent_flap/Run()
	var/mob/living/carbon/human/consistent/camper = allocate(__IMPLIED_TYPE__)
	var/obj/structure/roguetent/flap = allocate(/obj/structure/roguetent)
	flap.attack_hand(camper)
	TEST_ASSERT(!flap.density && !flap.opacity, "An opened tent flap still blocks the way or the view")
	TEST_ASSERT_EQUAL(flap.icon_state, "tent_door0", "An opened tent flap does not look open")
	flap.attack_hand(camper)
	TEST_ASSERT(flap.density && flap.opacity, "A closed tent flap lets one or the eye through")

/// A hand cart takes items up to its capacity, refuses one more past it and standing people at all, tips everything out, and
/// a reliable cog raises its capacity once.
/datum/unit_test/rogue_structures_handcart

/datum/unit_test/rogue_structures_handcart/Run()
	var/mob/living/carbon/human/consistent/carter = allocate(__IMPLIED_TYPE__)
	var/obj/structure/handcart/cart = allocate(/obj/structure/handcart)
	TEST_ASSERT_EQUAL(cart.maximum_capacity, rogue_value("handcart_capacity"), "A hand cart does not carry its capacity")
	var/obj/item/screwdriver/tool = allocate(/obj/item/screwdriver)
	TEST_ASSERT(cart.put_in(tool), "A hand cart refused a small item")
	TEST_ASSERT_EQUAL(tool.loc, cart, "The item is not in the cart")
	TEST_ASSERT_EQUAL(cart.current_capacity, tool.w_class, "The cart does not weigh the item by its size")
	TEST_ASSERT_EQUAL(cart.icon_state, "cart-full", "A loaded cart looks empty")
	TEST_ASSERT(!cart.insertion_allowed(carter), "A standing person can be put in a cart")
	cart.current_capacity = cart.maximum_capacity
	var/obj/item/screwdriver/extra = allocate(/obj/item/screwdriver)
	TEST_ASSERT(!cart.put_in(extra), "A full cart took one more item")
	cart.dump_contents()
	TEST_ASSERT_EQUAL(tool.loc, cart.loc, "Tipping the cart out did not put the item on its tile")
	TEST_ASSERT_EQUAL(cart.current_capacity, 0, "An empty cart still carries weight")
	TEST_ASSERT_EQUAL(cart.icon_state, "cart-empty", "An empty cart looks loaded")
	var/obj/item/roguegear/wood/reliable/cog = allocate(/obj/item/roguegear/wood/reliable)
	carter.put_in_hands(cog)
	cart.fit_cog(carter, cog)
	TEST_ASSERT_EQUAL(cart.upgrade_level, 1, "A reliable cog did not fit the level 1 wheelbrace")
	TEST_ASSERT_EQUAL(cart.maximum_capacity, rogue_value("handcart_reliable_cog_capacity"), "A reliable cog did not raise the capacity")
	var/obj/item/roguegear/wood/reliable/second_cog = allocate(/obj/item/roguegear/wood/reliable)
	TEST_ASSERT_EQUAL(cart.fit_cog(carter, second_cog), ITEM_INTERACT_BLOCKING, "A second reliable cog was fitted over the first")
	TEST_ASSERT(!QDELETED(second_cog), "A refused cog was used up")

/// A standing clock tells the time and blocks the way only from the side it faces; a wall clock tells the time as well.
/datum/unit_test/rogue_structures_clocks

/datum/unit_test/rogue_structures_clocks/Run()
	var/mob/living/carbon/human/consistent/walker = allocate(__IMPLIED_TYPE__)
	var/obj/structure/fluff/clock/clock = allocate(/obj/structure/fluff/clock)
	TEST_ASSERT(findtext(rockhill_clock_reading(), "Oh no, it's "), "A clock face does not tell the hour")
	TEST_ASSERT(!clock.CanAllowThrough(walker, clock.dir), "A clock lets one in from the side it faces")
	TEST_ASSERT(clock.CanAllowThrough(walker, REVERSE_DIR(clock.dir)), "A clock blocks the way from behind")
	TEST_ASSERT(clock.soundloop?.loop_started, "A clock does not tick")
	var/obj/structure/fluff/wallclock/wall_clock = allocate(/obj/structure/fluff/wallclock)
	var/told = FALSE
	for(var/line in wall_clock.examine(walker))
		if(findtext(line, "Oh no, it's "))
			told = TRUE
	TEST_ASSERT(told, "A wall clock does not tell the time on examine")

/// A common bell rings once and then waits out its cooldown.
/datum/unit_test/rogue_structures_bells

/datum/unit_test/rogue_structures_bells/Run()
	var/mob/living/carbon/human/consistent/ringer = allocate(__IMPLIED_TYPE__)
	var/obj/structure/bell_common/bell = allocate(/obj/structure/bell_common)
	bell.attack_hand(ringer)
	TEST_ASSERT_EQUAL(bell.last_ring, world.time, "A common bell did not ring")
	var/obj/structure/standingbell/service_bell = allocate(/obj/structure/standingbell)
	TEST_ASSERT(length(service_bell.called_roles("church")), "A service bell in the church calls no one")
	TEST_ASSERT(!length(service_bell.called_roles("nowhere")), "A service bell calls someone to a room with no service")

/// Carved words show to one who reads; a carved sign takes no more.
/datum/unit_test/rogue_structures_signs

/datum/unit_test/rogue_structures_signs/Run()
	var/mob/living/carbon/human/consistent/reader = allocate(__IMPLIED_TYPE__)
	var/obj/structure/fluff/customsign/sign = allocate(/obj/structure/fluff/customsign)
	sign.wrotesign = "WELCOME TO ROCKHILL"
	var/read = FALSE
	for(var/line in sign.examine(reader))
		if(findtext(line, "WELCOME TO ROCKHILL") || findtext(line, "I have no idea what it says"))
			read = TRUE
	TEST_ASSERT(read, "A carved sign says nothing on examine")
	var/obj/item/natural/feather/quill = allocate(/obj/item/natural/feather)
	TEST_ASSERT(sign.can_carve_with(reader, quill), "A feather does not carve a sign")

/// A raised flag flies on the town's flagpoles and is named in their description; lowered, it is gone.
/datum/unit_test/rogue_structures_flagpoles

/datum/unit_test/rogue_structures_flagpoles/Run()
	var/obj/structure/flagpole/flagpole = allocate(/obj/structure/flagpole)
	var/was_raised = !!GLOB.rockhill_town_flags.raised["university"]
	GLOB.rockhill_town_flags.set_raised("university", FALSE)
	TEST_ASSERT(GLOB.rockhill_town_flags.set_raised("university", TRUE), "The university flag did not go up")
	TEST_ASSERT("university" in GLOB.rockhill_town_flags.flying(), "A raised flag does not fly")
	TEST_ASSERT(findtext(flagpole.desc, "university"), "A flagpole does not name the flag it flies")
	TEST_ASSERT(!GLOB.rockhill_town_flags.set_raised("nonsense", TRUE), "An unknown flag went up")
	GLOB.rockhill_town_flags.set_raised("university", was_raised)

/// A garment aimed at its place goes on a mannequin and an empty hand takes it back; knocked over, the mannequin drops all.
/datum/unit_test/rogue_structures_mannequins

/datum/unit_test/rogue_structures_mannequins/Run()
	var/mob/living/carbon/human/consistent/dresser = allocate(__IMPLIED_TYPE__)
	var/obj/structure/mannequin/male/stand = allocate(/obj/structure/mannequin/male)
	var/obj/item/clothing/head/helmet/hat = allocate(/obj/item/clothing/head/helmet)
	dresser.put_in_hands(hat)
	stand.try_dress(dresser, hat, BODY_ZONE_HEAD)
	TEST_ASSERT_EQUAL(stand.outfit["head"], hat, "A hat aimed at the head did not go on the mannequin")
	TEST_ASSERT_EQUAL(hat.loc, stand, "The hat is not on the mannequin")
	stand.take_off(dresser, "head")
	TEST_ASSERT(dresser.is_holding(hat), "An empty hand did not take the hat back")
	TEST_ASSERT(isnull(stand.outfit["head"]), "The mannequin still wears the hat")
	stand.try_dress(dresser, hat, BODY_ZONE_HEAD)
	stand.tip_over()
	TEST_ASSERT(stand.tipped_over && !stand.density, "A knocked mannequin still stands")
	TEST_ASSERT_EQUAL(hat.loc, stand.loc, "A knocked mannequin kept its hat")

/// A hookah's mouthpiece comes to the hand and goes back on its hose.
/datum/unit_test/rogue_structures_hookah

/datum/unit_test/rogue_structures_hookah/Run()
	var/mob/living/carbon/human/consistent/smoker = allocate(__IMPLIED_TYPE__)
	var/obj/structure/shisha/hookah/pipe = allocate(/obj/structure/shisha/hookah)
	TEST_ASSERT(pipe.mouthpiece?.loc == pipe, "A hookah has no mouthpiece on its hose")
	TEST_ASSERT_EQUAL(pipe.reagents?.maximum_volume, rogue_value("hookah_volume"), "A hookah holds the wrong amount")
	pipe.attack_hand(smoker)
	TEST_ASSERT(smoker.is_holding(pipe.mouthpiece), "A hand did not take the mouthpiece")
	pipe.reattach_mouthpiece()
	TEST_ASSERT_EQUAL(pipe.mouthpiece.loc, pipe, "The mouthpiece did not go back on its hose")

/// Stepping on a pressure plate opens the hatch of its redstone id.
/datum/unit_test/rogue_structures_pressure_plate

/datum/unit_test/rogue_structures_pressure_plate/Run()
	var/obj/structure/pressure_plate/plate = allocate(/obj/structure/pressure_plate, run_loc_floor_top_right)
	var/obj/structure/floordoor/hatch = allocate(/obj/structure/floordoor)
	plate.redstone_id = "rogue_structures_test"
	plate.register_redstone()
	hatch.redstone_id = "rogue_structures_test"
	hatch.register_redstone()
	var/mob/living/carbon/human/consistent/stepper = allocate(__IMPLIED_TYPE__)
	stepper.forceMove(get_turf(plate))
	TEST_ASSERT(hatch.togg, "Stepping on the pressure plate did not open the hatch")

/// An arcyne wall stops one who cannot ward off magic.
/datum/unit_test/rogue_structures_arcyne_wall

/datum/unit_test/rogue_structures_arcyne_wall/Run()
	var/mob/living/carbon/human/consistent/walker = allocate(__IMPLIED_TYPE__)
	var/obj/structure/forcefield_weak/wall = allocate(/obj/structure/forcefield_weak)
	TEST_ASSERT(!wall.CanAllowThrough(walker, SOUTH), "An arcyne wall let a plain person through")

/// A bone pile raises a haunt bound to it, and raises another when that one is gone.
/datum/unit_test/rogue_structures_bonepile

/datum/unit_test/rogue_structures_bonepile/Run()
	var/obj/structure/bonepile/pile = allocate(/obj/structure/bonepile)
	TEST_ASSERT(pile.spawning, "A new bone pile does not stir")
	pile.create_haunt()
	TEST_ASSERT_EQUAL(LAZYLEN(pile.haunts), 1, "The bone pile raised no haunt")
	var/mob/living/simple_animal/hostile/rogue/haunt/ghost = pile.haunts[1]
	TEST_ASSERT_EQUAL(ghost.rockhill_pile, pile, "The haunt is not bound to its pile")
	qdel(ghost)
	TEST_ASSERT(!LAZYLEN(pile.haunts), "A haunt laid to rest is still counted")
	TEST_ASSERT(pile.spawning, "The bone pile does not raise its haunt again")

/// A wooden table taken apart with tools leaves a small log and no frame; a person lying on a Ratwood bed lies a little up.
/datum/unit_test/rogue_structures_furniture

/datum/unit_test/rogue_structures_furniture/Run()
	var/obj/structure/table/wood/rockhill/wood/table = allocate(/obj/structure/table/wood/rockhill/wood)
	var/turf/table_turf = get_turf(table)
	table.deconstruct(TRUE)
	TEST_ASSERT(locate(/obj/item/grown/log/tree/small) in table_turf, "A wooden table taken apart left no small log")
	TEST_ASSERT(!(locate(/obj/structure/table_frame) in table_turf), "A wooden table taken apart left a TG frame")
	var/mob/living/carbon/human/consistent/sleeper = allocate(__IMPLIED_TYPE__, run_loc_floor_top_right)
	var/obj/structure/bed/rockhill/rogue/bed = allocate(/obj/structure/bed/rockhill/rogue, run_loc_floor_top_right)
	bed.buckle_mob(sleeper, force = TRUE)
	TEST_ASSERT_EQUAL(sleeper.has_offset("rockhill_bed_buckle", PIXEL_Y_OFFSET), 5, "One lying on a Ratwood bed is not shifted up")
	bed.unbuckle_mob(sleeper, force = TRUE)
	TEST_ASSERT(!sleeper.has_offset("rockhill_bed_buckle", PIXEL_Y_OFFSET), "Getting up from a bed kept the shift")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
