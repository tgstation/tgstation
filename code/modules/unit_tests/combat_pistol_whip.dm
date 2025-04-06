/// Tests that guns (bayonetted or otherwise) are able to be used as melee weapons in close range
/datum/unit_test/pistol_whip

/datum/unit_test/pistol_whip/Run()
	var/mob/living/carbon/human/consistent/attacker = EASY_ALLOCATE()
	var/mob/living/carbon/human/consistent/victim = EASY_ALLOCATE()
	var/obj/item/gun/ballistic/automatic/pistol/gun = EASY_ALLOCATE()

	attacker.put_in_active_hand(gun, forced = TRUE)
	victim.forceMove(locate(attacker.x + 1, attacker.y, attacker.z))

	var/expected_ammo = gun.magazine.max_ammo + 1
	// These assertions are just here because I don't understand gun code
	TEST_ASSERT(gun.chambered, "Gun spawned without a chambered round.")
	TEST_ASSERT_EQUAL(gun.get_ammo(countchambered = TRUE), expected_ammo, "Gun spawned without a full magazine, \
		when it should spawn with mag size + 1 (chambered) rounds.")

	// Combat mode in melee range -> pistol whip
	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, victim)
	TEST_ASSERT_NOTEQUAL(victim.getBruteLoss(), 0, "Victim did not take brute damage from being pistol-whipped.")
	TEST_ASSERT_EQUAL(gun.get_ammo(countchambered = TRUE), expected_ammo, "The gun fired a shot when it was used for a pistol whip.")
	victim.fully_heal()

	// No combat mode -> point blank shot
	attacker.set_combat_mode(FALSE)
	click_wrapper(attacker, victim)
	TEST_ASSERT_NOTEQUAL(victim.getBruteLoss(), 0, "Victim did not take brute damage from being fired upon point-blank.")
	TEST_ASSERT(locate(/obj/item/ammo_casing/c9mm) in attacker.loc, "The gun did not eject a casing when it was used for a point-blank shot.")
	TEST_ASSERT_EQUAL(gun.get_ammo(countchambered = TRUE), expected_ammo - 1, "The gun did not fire a shot when it was used for a point-blank shot.")
	victim.fully_heal()

	// Combat mode in melee range with bayonet -> bayonet stab
	var/obj/item/knife/combat/knife = EASY_ALLOCATE()
	gun.AddComponent(/datum/component/bayonet_attachable, starting_bayonet = knife)

	attacker.set_combat_mode(TRUE)
	click_wrapper(attacker, victim)
	TEST_ASSERT_NOTEQUAL(victim.getBruteLoss(), 0, "Victim did not take brute damage from being bayonet stabbed.")
	victim.fully_heal()

/// Test that bayonetted weapons can be used to butcher
/datum/unit_test/bayonet_butchering

/datum/unit_test/bayonet_butchering/Run()
	var/mob/living/carbon/human/species/monkey/meat = EASY_ALLOCATE()
	meat.death()

	var/mob/living/carbon/human/consistent/butcher = EASY_ALLOCATE()
	butcher.set_combat_mode(TRUE)
	var/obj/item/gun/energy/recharge/kinetic_accelerator/gun = EASY_ALLOCATE()
	var/obj/item/knife/combat/knife = EASY_ALLOCATE()
	var/datum/component/bayonet_attachable/bayonet = gun.GetComponent(/datum/component/bayonet_attachable)
	bayonet.add_bayonet(knife)
	var/datum/component/butchering/butcher_comp = knife.GetComponent(/datum/component/butchering)
	butcher_comp.speed = 1 SECONDS

	butcher.put_in_active_hand(gun, forced = TRUE)
	click_wrapper(butcher, meat)
	TEST_ASSERT(DOING_INTERACTION(butcher, meat), "The butcher did not start butchering the monkey when using a bayonetted weapon.")
