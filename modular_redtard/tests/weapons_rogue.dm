#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's weapons and gear (combat/integrity.dm, special_weapons.dm, keep_standard.dm, training_dummy.dm, azure_weapons.dm,
/// clash.dm). The test map is not a medieval one: Ratwood's weapons keep their integrity rules anywhere, the rest is called
/// directly where it waits for a medieval map.

/// A weapon breaks at its integrity_failure share, weak, blunt and unable to parry, and is mended by a full repair or a field
/// repair; worn to nothing it stays.
/datum/unit_test/rogue_weapon_break

/datum/unit_test/rogue_weapon_break/Run()
	var/mob/living/carbon/human/consistent/smith = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/sword/sword = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(sword.integrity_failure > 0, "The arming sword has no breaking point to test")
	var/force = sword.force
	var/defense = sword.wdefense
	var/penetration = sword.armour_penetration
	TEST_ASSERT(sword.can_parry, "The arming sword cannot parry to begin with")
	sword.take_damage(sword.get_integrity() - sword.max_integrity * sword.integrity_failure + 1, BRUTE, "", FALSE)
	TEST_ASSERT(sword.rogue_broken, "A sword worn to its breaking point did not break")
	TEST_ASSERT_EQUAL(sword.force, force / rogue_value("broken_force_divisor"), "A broken sword kept its force")
	TEST_ASSERT_EQUAL(sword.wdefense, defense / rogue_value("broken_defense_divisor"), "A broken sword kept its defense")
	TEST_ASSERT_EQUAL(sword.armour_penetration, penetration / rogue_value("broken_penetration_divisor"), "A broken sword kept its penetration")
	TEST_ASSERT(!sword.can_parry, "A broken sword can still parry")
	TEST_ASSERT_EQUAL(sword.get_sharpness(), NONE, "A broken sword is not blunt")
	TEST_ASSERT(sword.rogue_is_broken(), "The repairs do not see the sword as broken")
	sword.repair_damage(sword.max_integrity * 0.5 - sword.get_integrity())
	TEST_ASSERT(sword.rogue_broken, "Half a repair mended a broken sword")
	sword.repair_damage(sword.max_integrity)
	TEST_ASSERT(!sword.rogue_broken, "A full repair did not mend the sword")
	TEST_ASSERT_EQUAL(sword.force, force, "The mended sword did not get its force back")
	TEST_ASSERT_EQUAL(sword.wdefense, defense, "The mended sword did not get its defense back")
	TEST_ASSERT(sword.can_parry, "The mended sword cannot parry")
	// A field repair by an unskilled hand mends it at 60%, shoddy.
	sword.take_damage(sword.get_integrity() - sword.max_integrity * sword.integrity_failure + 1, BRUTE, "", FALSE)
	TEST_ASSERT(sword.rogue_broken, "The sword did not break a second time")
	sword.rogue_repair(smith, sword.max_integrity, TRUE)
	TEST_ASSERT(sword.shoddy_repair, "An unskilled repair of a broken sword was not a field repair")
	TEST_ASSERT(!sword.rogue_broken, "A field repair did not mend the sword")
	TEST_ASSERT(sword.get_integrity() <= sword.max_integrity * rogue_value("field_repair_share"), "A field repair went past its share")
	// Worn to nothing, it stays and takes no more harm.
	sword.take_damage(sword.max_integrity * 2, BRUTE, "", FALSE)
	TEST_ASSERT(!QDELETED(sword), "A sword worn to nothing was destroyed")
	TEST_ASSERT_EQUAL(sword.get_integrity(), 0, "The worn-out sword has integrity left")
	TEST_ASSERT_EQUAL(sword.take_damage(10, BRUTE, "", FALSE), 0, "A worn-out sword took more harm")

/// Putting a thing on oneself takes its delay less the wearer's speed, at least a decisecond, nothing at all when they meet.
/datum/unit_test/rogue_self_equip_delay

/datum/unit_test/rogue_self_equip_delay/Run()
	var/mob/living/carbon/human/consistent/wearer = allocate(__IMPLIED_TYPE__)
	var/obj/item/clothing/cloak/apron/apron = allocate(__IMPLIED_TYPE__)
	var/speed = wearer.rogue_stat(ROGUE_STAT_SPEED)
	apron.equip_delay_self = speed + 30
	TEST_ASSERT_EQUAL(apron.rogue_self_equip_delay(wearer), 30, "The wearer's speed did not shorten the delay")
	apron.equip_delay_self = speed
	TEST_ASSERT_EQUAL(apron.rogue_self_equip_delay(wearer), 0, "A delay equal to the speed did not vanish")
	apron.equip_delay_self = max(speed - 5, 1)
	if(apron.equip_delay_self < speed)
		TEST_ASSERT_EQUAL(apron.rogue_self_equip_delay(wearer), 1, "A delay below the speed did not take a decisecond")
	TEST_ASSERT(apron.edelay_type, "A cloak cannot be put on walking")
	var/obj/item/clothing/suit/roguetown/armor/gambeson/gambeson = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(!gambeson.edelay_type, "Armor can be put on walking")

/// The practice dummy wears the blade, tires, teaches or ripostes below its cap and teaches nothing at the cap.
/datum/unit_test/rogue_training_dummy

/datum/unit_test/rogue_training_dummy/Run()
	var/mob/living/carbon/human/consistent/trainee = allocate(__IMPLIED_TYPE__)
	var/obj/structure/fluff/statue/tdummy/dummy = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/sword/sword = allocate(__IMPLIED_TYPE__)
	trainee.put_in_active_hand(sword)
	var/skill = sword.associated_skill
	var/edge = sword.blade_int
	var/xp = trainee.attributes.get_skill_xp(skill)
	var/result = dummy.rogue_training_stroke(trainee, sword)
	TEST_ASSERT(result == "trained" || result == "riposted", "A stroke below the cap neither taught nor was riposted ([result])")
	TEST_ASSERT(sword.blade_int < edge, "A stroke on the dummy did not wear the blade")
	TEST_ASSERT(trainee.get_stamina_loss() > 0, "A stroke on the dummy did not tire")
	if(result == "trained")
		TEST_ASSERT(trainee.attributes.get_skill_xp(skill) > xp, "A teaching stroke taught nothing")
	trainee.SetKnockdown(0)
	trainee.get_up(TRUE)
	trainee.rogue_set_skill(skill, rogue_value("dummy_train_cap") * ROGUE_SKILL_PER_RANK)
	TEST_ASSERT_EQUAL(dummy.rogue_training_stroke(trainee, sword), "learned_all", "The dummy taught past its cap")

/// Two duelists with rings clash on even odds, and a bait between them takes the balance for the duelist time.
/datum/unit_test/rogue_duelist_ring

/datum/unit_test/rogue_duelist_ring/Run()
	var/mob/living/carbon/human/consistent/baiter = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/victim = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(!baiter.rogue_dueling(victim), "Two fighters without rings are dueling")
	baiter.wear_rings = list(allocate(/obj/item/clothing/ring/duelist))
	TEST_ASSERT(!baiter.rogue_dueling(victim), "One ring made a duel")
	victim.wear_rings = list(allocate(/obj/item/clothing/ring/duelist))
	TEST_ASSERT(baiter.rogue_dueling(victim), "Two duelist's rings did not make a duel")
	baiter.zone_selected = BODY_ZONE_R_ARM
	baiter.rogue_zone_precise = "r_arm"
	victim.zone_selected = BODY_ZONE_R_ARM
	victim.rogue_zone_precise = "r_arm"
	TEST_ASSERT(baiter.rogue_bait(victim), "Matching zones did not bait")
	TEST_ASSERT(victim.rogue_offbalance_until >= world.time + rogue_value("duelist_bait_offbalance"), "The first bait between duelists did not take the balance for the duelist time")

/// The bucklers parry with the skill of the weapon in the active hand, else with the shield skill.
/datum/unit_test/rogue_buckler_skill

/datum/unit_test/rogue_buckler_skill/Run()
	var/mob/living/carbon/human/consistent/fighter = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/sword/sword = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/shield/buckler/buckler = allocate(__IMPLIED_TYPE__)
	var/shield_skill = buckler.associated_skill
	fighter.put_in_active_hand(sword)
	fighter.put_in_inactive_hand(buckler)
	TEST_ASSERT_EQUAL(buckler.associated_skill, sword.associated_skill, "The buckler does not parry with the sword's skill")
	fighter.swap_hand(fighter.get_inactive_hand_index())
	TEST_ASSERT_EQUAL(buckler.associated_skill, shield_skill, "The buckler in the active hand does not parry with the shield skill")
	fighter.dropItemToGround(buckler)
	TEST_ASSERT_EQUAL(buckler.associated_skill, shield_skill, "A dropped buckler kept the sword's skill")

/// The stunmace switches on in hand, saps a struck foe on its charge and switches off with its own force back.
/datum/unit_test/rogue_stunmace

/datum/unit_test/rogue_stunmace/Run()
	var/mob/living/carbon/human/consistent/wielder = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/victim = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/mace/stunmace/mace = allocate(__IMPLIED_TYPE__)
	wielder.put_in_active_hand(mace)
	var/force = mace.force
	mace.attack_self(wielder)
	TEST_ASSERT(mace.on, "The stunmace did not switch on")
	TEST_ASSERT_EQUAL(mace.force, rogue_value("stunmace_on_force"), "The switched-on stunmace kept its force")
	var/charge = mace.charge
	mace.rogue_after_strike(victim, wielder)
	TEST_ASSERT(victim.get_stamina_loss() > 0, "The stunmace did not sap a struck foe")
	TEST_ASSERT(mace.charge < charge, "Sapping a foe cost the stunmace no charge")
	mace.attack_self(wielder)
	TEST_ASSERT(!mace.on, "The stunmace did not switch off")
	TEST_ASSERT_EQUAL(mace.force, force, "The switched-off stunmace did not get its force back")

/// A clump of hay on the militia spear, lit, sets a struck foe ablaze once.
/datum/unit_test/rogue_militia_spear

/datum/unit_test/rogue_militia_spear/Run()
	var/mob/living/carbon/human/consistent/wielder = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/victim = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/spear/militia/spear = allocate(__IMPLIED_TYPE__)
	var/obj/item/reagent_containers/food/snacks/grown/wheat/hay = allocate(__IMPLIED_TYPE__)
	wielder.put_in_active_hand(spear)
	TEST_ASSERT_EQUAL(spear.interact_with_atom(hay, wielder), ITEM_INTERACT_SUCCESS, "The spear did not take the hay")
	TEST_ASSERT(spear.is_loaded, "The spear is not loaded with hay")
	spear.fire_act(1000, 100)
	TEST_ASSERT(spear.rogue_hay_lit, "Fire did not light the hay")
	spear.rogue_after_strike(victim, wielder)
	TEST_ASSERT(victim.on_fire, "The burning spear did not set its target ablaze")
	TEST_ASSERT(!spear.is_loaded && !spear.rogue_hay_lit, "The hay did not burn out")

/// A blacksteel weapon's special can be swapped for one of its selection; a banner of cloth draws in its colour.
/datum/unit_test/rogue_blacksteel_choice

/datum/unit_test/rogue_blacksteel_choice/Run()
	var/obj/item/rogueweapon/sword/long/blacksteel/sword = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(length(sword.selection), "The blacksteel longsword has nothing to choose from")
	sword.rogue_special()
	sword.rogue_set_special(/datum/special_intent/axe_swing)
	TEST_ASSERT(istype(sword.rogue_special(), /datum/special_intent/axe_swing), "The chosen special did not replace the old one")
	var/obj/item/rogueweapon/spear/lance/lance = allocate(__IMPLIED_TYPE__)
	var/plain = length(lance.update_overlays())
	lance.rogue_banner_color = "#933030"
	TEST_ASSERT(length(lance.update_overlays()) > plain, "A banner did not draw on the lance")

/// The ducal standard's runes mend it a share at a time.
/datum/unit_test/rogue_keep_standard_mend

/datum/unit_test/rogue_keep_standard_mend/Run()
	var/obj/item/rogueweapon/spear/keep_standard/standard = allocate(__IMPLIED_TYPE__)
	standard.take_damage(standard.max_integrity / 2, BRUTE, "", FALSE)
	var/before = standard.get_integrity()
	standard.rogue_last_mend = world.time - rogue_value("standard_mend_time") - 1
	standard.process(SSobj.wait / 10)
	TEST_ASSERT(standard.get_integrity() > before, "The standard's runes did not mend it")

/// Azure Peak's charged weapons: the fire dagger burns, Bane's Edge poisons for less force, the deathfrost axe frostbites.
/datum/unit_test/rogue_azure_charges

/datum/unit_test/rogue_azure_charges/Run()
	var/mob/living/carbon/human/consistent/wielder = allocate(__IMPLIED_TYPE__)
	var/mob/living/carbon/human/consistent/victim = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/huntingknife/idagger/steel/fire/dagger = allocate(__IMPLIED_TYPE__)
	wielder.put_in_active_hand(dagger)
	wielder.rogue_set_skill(/datum/attribute/skill/combat/knives, ROGUE_SPECIAL_RANK * ROGUE_SKILL_PER_RANK)
	TEST_ASSERT(wielder.rogue_use_special(get_step(wielder, wielder.dir)), "Ignite Dagger could not be used")
	TEST_ASSERT_EQUAL(dagger.damtype, BURN, "The ignited dagger does not burn")
	TEST_ASSERT(dagger.possible_item_intents == dagger.active_intents, "The ignited dagger kept its usual intents")
	dagger.rogue_cool_down()
	TEST_ASSERT_EQUAL(dagger.damtype, BRUTE, "The cooled dagger still burns")
	var/obj/item/rogueweapon/sword/sabre/bane/sabre = allocate(__IMPLIED_TYPE__)
	var/force = sabre.force
	TEST_ASSERT(sabre.rogue_coat(wielder, 10 SECONDS, 15), "Bane's Edge could not be coated")
	TEST_ASSERT_EQUAL(sabre.damtype, TOX, "The coated sabre does not poison")
	TEST_ASSERT_EQUAL(sabre.force, force - 15, "The coated sabre kept its force")
	sabre.rogue_uncoat()
	TEST_ASSERT_EQUAL(sabre.force, force, "The sabre did not get its force back")
	var/obj/item/rogueweapon/stoneaxe/battle/ice/axe = allocate(__IMPLIED_TYPE__)
	wielder.dropItemToGround(dagger)
	wielder.put_in_active_hand(axe)
	TEST_ASSERT(axe.rogue_freeze(wielder, 10 SECONDS), "The deathfrost axe could not be frozen")
	wielder.rogue_select_intent(1)
	axe.rogue_after_strike(victim, wielder)
	TEST_ASSERT(victim.has_status_effect(/datum/status_effect/rogue/frostbite), "A frost cut did not frostbite")
	axe.rogue_thaw()
	TEST_ASSERT(!(/datum/intent/axe/cut/frost in axe.possible_item_intents), "The thawed axe kept its frost intents")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
