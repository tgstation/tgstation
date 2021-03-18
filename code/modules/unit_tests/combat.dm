/datum/unit_test/harm_punch/Run()
	var/mob/living/carbon/human/puncher = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)

	// Avoid all randomness in tests
	ADD_TRAIT(puncher, TRAIT_PERFECT_ATTACKER, INNATE_TRAIT)

	puncher.set_combat_mode(TRUE)
	victim.attack_hand(puncher, list(RIGHT_CLICK = FALSE))

	TEST_ASSERT(victim.getBruteLoss() > 0, "Victim took no brute damage after being punched")

/datum/unit_test/harm_melee/Run()
	var/mob/living/carbon/human/tider = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)

	tider.put_in_active_hand(toolbox, forced = TRUE)
	tider.set_combat_mode(TRUE)
	victim.attackby(toolbox, tider)

	TEST_ASSERT(victim.getBruteLoss() > 0, "Victim took no brute damage after being hit by a toolbox")

/datum/unit_test/harm_different_damage/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/weldingtool/welding_tool = allocate(/obj/item/weldingtool)

	attacker.put_in_active_hand(welding_tool, forced = TRUE)
	attacker.set_combat_mode(TRUE)

	welding_tool.attack_self(attacker) // Turn it on
	victim.attackby(welding_tool, attacker)

	TEST_ASSERT_EQUAL(victim.getBruteLoss(), 0, "Victim took brute damage from a lit welding tool")
	TEST_ASSERT(victim.getFireLoss() > 0, "Victim took no burn damage after being hit by a lit welding tool")

/datum/unit_test/attack_chain
	var/attack_hit
	var/post_attack_hit
	var/pre_attack_hit

/datum/unit_test/attack_chain/proc/attack_hit()
	attack_hit = TRUE

/datum/unit_test/attack_chain/proc/post_attack_hit()
	post_attack_hit = TRUE

/datum/unit_test/attack_chain/proc/pre_attack_hit()
	pre_attack_hit = TRUE

/datum/unit_test/attack_chain/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)

	RegisterSignal(toolbox, COMSIG_ITEM_PRE_ATTACK, .proc/pre_attack_hit)
	RegisterSignal(toolbox, COMSIG_ITEM_ATTACK, .proc/attack_hit)
	RegisterSignal(toolbox, COMSIG_ITEM_AFTERATTACK, .proc/post_attack_hit)

	attacker.put_in_active_hand(toolbox, forced = TRUE)
	attacker.set_combat_mode(TRUE)
	toolbox.melee_attack_chain(attacker, victim)

	TEST_ASSERT(pre_attack_hit, "Pre-attack signal was not fired")
	TEST_ASSERT(attack_hit, "Attack signal was not fired")
	TEST_ASSERT(post_attack_hit, "Post-attack signal was not fired")

/datum/unit_test/disarm/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	var/obj/item/storage/toolbox/toolbox = allocate(/obj/item/storage/toolbox)

	victim.put_in_active_hand(toolbox, forced = TRUE)

	var/obj/structure/barricade/dense_object = allocate(/obj/structure/barricade)

	// Attacker --> Victim --> Empty space --> Wall
	attacker.forceMove(run_loc_floor_bottom_left)
	victim.forceMove(locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	dense_object.forceMove(locate(run_loc_floor_bottom_left.x + 3, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	// First disarm, world should now look like:
	// Attacker --> Empty space --> Victim --> Wall
	victim.attack_hand(attacker, list(RIGHT_CLICK = TRUE))

	TEST_ASSERT_EQUAL(victim.loc.x, run_loc_floor_bottom_left.x + 2, "Victim wasn't moved back after being pushed")
	TEST_ASSERT(!victim.has_status_effect(STATUS_EFFECT_KNOCKDOWN), "Victim was knocked down despite not being against a wall")
	TEST_ASSERT_EQUAL(victim.get_active_held_item(), toolbox, "Victim dropped toolbox despite not being against a wall")

	attacker.forceMove(get_step(attacker, EAST))

	// Second disarm, victim was against wall and should be down
	victim.attack_hand(attacker, list(RIGHT_CLICK = TRUE))

	TEST_ASSERT_EQUAL(victim.loc.x, run_loc_floor_bottom_left.x + 2, "Victim was moved after being pushed against a wall")
	TEST_ASSERT(victim.has_status_effect(STATUS_EFFECT_KNOCKDOWN), "Victim was not knocked down after being pushed against a wall")
	TEST_ASSERT_EQUAL(victim.get_active_held_item(), null, "Victim didn't drop toolbox after being pushed against a wall")
