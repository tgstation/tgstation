/**
 * Unit test to ensure that mechs take the correct amount of damage
 * based on armor, and that their equipment is properly damaged as well.
 */
/datum/unit_test/mecha_damage

/datum/unit_test/mecha_damage/Run()
	// "Loaded Mauler" was chosen deliberately here.
	// We need a mech that starts with arm equipment and has fair enough armor.
	var/obj/vehicle/sealed/mecha/demo_mech = allocate(/obj/vehicle/sealed/mecha/marauder/mauler/loaded)
	// We need to face our guy explicitly, because mechs have directional armor
	demo_mech.setDir(EAST)

	var/expected_melee_armor = demo_mech.get_armor_rating(MELEE)
	var/expected_laser_armor = demo_mech.get_armor_rating(LASER)
	var/expected_bullet_armor = demo_mech.get_armor_rating(BULLET)

	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	dummy.forceMove(locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	// The dummy needs to be targeting an arm. Left is chosen here arbitrarily.
	dummy.zone_selected = BODY_ZONE_L_ARM
	// Not strictly necessary, but you never know
	dummy.face_atom(demo_mech)

	// Get a sample "melee" weapon.
	// The energy axe is chosen here due to having a high base force, to make sure we get over the equipment DT.
	var/obj/item/dummy_melee = allocate(/obj/item/melee/energy/axe)
	var/expected_melee_damage = round(dummy_melee.force * (1 - expected_melee_armor / 100), DAMAGE_PRECISION)

	// Get a sample laser weapon.
	// The captain's laser gun here is chosen primarily because it deals more damage than normal lasers.
	var/obj/item/gun/energy/laser/dummy_laser = allocate(/obj/item/gun/energy/laser/captain)
	var/obj/item/ammo_casing/laser_ammo = dummy_laser.ammo_type[1]
	var/obj/projectile/beam/laser_fired = initial(laser_ammo.projectile_type)
	var/expected_laser_damage = round(dummy_laser.projectile_damage_multiplier * initial(laser_fired.damage) * (1 - expected_laser_armor / 100), DAMAGE_PRECISION)

	// Get a sample ballistic weapon.
	// The syndicate .357 here is chosen because it does a lot of damage.
	var/obj/item/gun/ballistic/dummy_gun = allocate(/obj/item/gun/ballistic/revolver)
	var/obj/item/ammo_casing/ballistic_ammo = dummy_gun.magazine.ammo_type
	var/obj/projectile/bullet_fired = initial(ballistic_ammo.projectile_type)
	var/expected_bullet_damage = round(dummy_gun.projectile_damage_multiplier * initial(bullet_fired.damage) * (1 - expected_bullet_armor / 100), DAMAGE_PRECISION)

	var/obj/item/mecha_parts/mecha_equipment/left_arm_equipment = demo_mech.equip_by_category[MECHA_L_ARM]
	TEST_ASSERT_NOTNULL(left_arm_equipment, "[demo_mech] spawned without any equipment in their left arm slot.")

	// Now it's time to actually beat the heck out of the mech to see if it takes damage correctly.
	TEST_ASSERT_EQUAL(demo_mech.get_integrity(), demo_mech.max_integrity, "[demo_mech] was spawned at not its maximum integrity.")
	TEST_ASSERT_EQUAL(left_arm_equipment.get_integrity(), left_arm_equipment.max_integrity, "[left_arm_equipment] ([demo_mech]'s left arm) spawned at not its maximum integrity.")

	// SMACK IT
	var/pre_melee_integrity = demo_mech.get_integrity()
	var/pre_melee_arm_integrity = left_arm_equipment.get_integrity()
	demo_mech.attacked_by(dummy_melee, dummy)

	check_integrity(demo_mech, pre_melee_integrity, expected_melee_damage, "hit with a melee item")
	check_integrity(left_arm_equipment, pre_melee_arm_integrity, expected_melee_damage, "hit with a melee item")

	// BLAST IT
	var/pre_laser_integrity = demo_mech.get_integrity()
	var/pre_laser_arm_integrity = left_arm_equipment.get_integrity()
	dummy_laser.fire_gun(demo_mech, dummy, FALSE)

	check_integrity(demo_mech, pre_laser_integrity, expected_laser_damage, "shot with a laser")
	check_integrity(left_arm_equipment, pre_laser_arm_integrity, expected_laser_damage, "shot with a laser")

	// SHOOT IT
	var/pre_bullet_integrity = demo_mech.get_integrity()
	var/pre_bullet_arm_integrity = left_arm_equipment.get_integrity()
	dummy_gun.fire_gun(demo_mech, dummy, FALSE)

	check_integrity(demo_mech, pre_bullet_integrity, expected_bullet_damage, "shot with a bullet")
	check_integrity(left_arm_equipment, pre_bullet_arm_integrity, expected_bullet_damage, "shot with a bullet")

	// Additional check: The right arm of the mech should have taken no damage by this point.
	var/obj/item/mecha_parts/mecha_equipment/right_arm_equipment = demo_mech.equip_by_category[MECHA_R_ARM]
	TEST_ASSERT_NOTNULL(right_arm_equipment, "[demo_mech] spawned without any equipment in their right arm slot.")
	TEST_ASSERT_EQUAL(right_arm_equipment.get_integrity(), right_arm_equipment.max_integrity, "[demo_mech] somehow took damage to its right arm, despite not being targeted.")

/// Simple helper to check if the integrity of an atom involved has taken damage, and if they took the amount of damage it should have.
/datum/unit_test/mecha_damage/proc/check_integrity(atom/checking, pre_integrity, expected_damage, hit_by_phrase)
	var/post_hit_health = checking.get_integrity()
	TEST_ASSERT(post_hit_health < pre_integrity, "[checking] was [hit_by_phrase], but didn't take any damage.")

	var/damage_taken = round(pre_integrity - post_hit_health, DAMAGE_PRECISION)
	TEST_ASSERT_EQUAL(damage_taken, expected_damage, "[checking] didn't take the expected amount of damage when [hit_by_phrase]. (Expected damage: [expected_damage], recieved damage: [damage_taken])")
