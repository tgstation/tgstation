#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's wounds and healing (combat/wounds.dm, medicine.dm, leeches.dm, pain.dm, survival/sleep.dm). The test map is not a
/// medieval one, so the patient is given the blood element by hand, as a medieval map gives it to every human.
/datum/unit_test/rogue_wounds
	abstract_type = /datum/unit_test/rogue_wounds

/datum/unit_test/rogue_wounds/proc/make_patient()
	var/mob/living/carbon/human/consistent/patient = allocate(__IMPLIED_TYPE__)
	patient.AddElement(/datum/element/rogue_blood)
	return patient

/// Blows open the dynamic wound of their kind and grow it, instead of TG's rolled wounds.
/datum/unit_test/rogue_wounds/dynamic

/datum/unit_test/rogue_wounds/dynamic/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	patient.apply_damage(15, BRUTE, arm, wound_bonus = 100, sharpness = SHARP_EDGED)
	var/datum/wound/rogue/dynamic/slash/slash = arm.get_wound_type(/datum/wound/rogue/dynamic/slash)
	TEST_ASSERT(slash, "A cut did not open a slash")
	TEST_ASSERT_NULL(arm.get_wound_type(/datum/wound/slash/flesh), "A cut still rolled TG's cut")
	TEST_ASSERT(slash.blood_flow > 0, "A slash does not bleed")
	TEST_ASSERT(slash.rogue_pain() > rogue_value("dynamic_slash_pain"), "The cut did not grow the slash's pain")
	TEST_ASSERT(patient.rogue_complex_pain() > 0, "The slash does not hurt")
	var/health = slash.rogue_health
	var/bleed = slash.rogue_bleed()
	patient.apply_damage(15, BRUTE, arm, sharpness = SHARP_EDGED)
	TEST_ASSERT(slash.rogue_health > health && slash.rogue_bleed() > bleed, "A second cut did not grow the slash")
	TEST_ASSERT_EQUAL(length(arm.wounds), 1, "A second cut opened another wound")
	patient.apply_damage(10, BRUTE, arm)
	TEST_ASSERT(arm.get_wound_type(/datum/wound/rogue/dynamic/bruise), "A blunt blow did not leave a hematoma")
	var/obj/item/knife/kitchen/knife = allocate(__IMPLIED_TYPE__)
	knife.rogue_current_bclass = BCLASS_STAB
	patient.apply_damage(10, BRUTE, arm, sharpness = SHARP_POINTY, attacking_item = knife)
	TEST_ASSERT(arm.get_wound_type(/datum/wound/rogue/dynamic/puncture), "A knife's stab did not leave a puncture")
	patient.apply_damage(10, BRUTE, arm, wound_bonus = CANT_WOUND, sharpness = SHARP_EDGED)
	TEST_ASSERT_EQUAL(length(arm.wounds), 3, "A hit that may not wound opened a wound")

/// The kind of a blow, as the damage tells it, and the wound of each kind.
/datum/unit_test/rogue_wounds/blow_class

/datum/unit_test/rogue_wounds/blow_class/Run()
	TEST_ASSERT_EQUAL(rogue_wound_blow_class(WOUND_PIERCE, null, null), BCLASS_BITE, "A pointed hit of no weapon and no direction is not a bite")
	TEST_ASSERT_EQUAL(rogue_wound_blow_class(WOUND_PIERCE, NORTH, null), BCLASS_CUT, "A creature's bite is not of the slash kind")
	TEST_ASSERT_EQUAL(rogue_wound_blow_class(WOUND_BLUNT, NORTH, null), BCLASS_BLUNT, "A blow of no weapon is not blunt")
	TEST_ASSERT_NULL(rogue_wound_blow_class(WOUND_BURN, null, null), "A burn is taken for a blow")
	var/obj/item/knife/kitchen/knife = allocate(__IMPLIED_TYPE__)
	knife.rogue_current_bclass = BCLASS_CHOP
	TEST_ASSERT_EQUAL(rogue_wound_blow_class(WOUND_SLASH, NORTH, knife), BCLASS_CHOP, "A chop is not told by the intent it was struck with")
	TEST_ASSERT_EQUAL(rogue_wound_blow_class(WOUND_PIERCE, NORTH, knife), BCLASS_STAB, "A thrust TG saw as a stab kept the cut of the hand's intent")
	TEST_ASSERT_EQUAL(rogue_wound_blow_class(WOUND_BLUNT, NORTH, knife), BCLASS_CHOP, "A chop on a mangled limb lost its kind")
	TEST_ASSERT_EQUAL(rogue_dynamic_wound_type(BCLASS_LASHING), /datum/wound/rogue/dynamic/lashing, "A lash leaves no lashing")
	TEST_ASSERT_EQUAL(rogue_dynamic_wound_type(BCLASS_PIERCE), /datum/wound/rogue/dynamic/gouge, "An arrow leaves no gouge")
	TEST_ASSERT_NULL(rogue_dynamic_wound_type(BCLASS_BURN), "Charring leaves a dynamic wound")

/// A dynamic wound clots and mends by itself, its pain easing by half of what it mends; mended whole, it closes.
/datum/unit_test/rogue_wounds/healing

/datum/unit_test/rogue_wounds/healing/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	patient.apply_damage(10, BRUTE, arm)
	var/datum/wound/rogue/dynamic/bruise/bruise = arm.get_wound_type(/datum/wound/rogue/dynamic/bruise)
	TEST_ASSERT(bruise, "A blunt blow did not leave a hematoma")
	var/health = bruise.rogue_health
	var/pain = bruise.rogue_pain()
	patient.rogue_pain_hud_dirty = FALSE
	bruise.handle_process(SSMOBS_DT)
	var/healed = health - bruise.rogue_health
	TEST_ASSERT(healed > 0, "A hematoma did not mend by itself")
	TEST_ASSERT(abs(pain - bruise.rogue_pain() - healed / 2) < 0.1, "The hematoma's pain did not ease by half of what it mended")
	TEST_ASSERT(patient.rogue_pain_hud_dirty, "The heart was not told the pain eased")
	bruise.rogue_heal_wound(bruise.rogue_health)
	TEST_ASSERT(QDELETED(bruise), "A hematoma mended whole did not close")
	patient.apply_damage(15, BRUTE, arm, sharpness = SHARP_EDGED)
	var/datum/wound/rogue/dynamic/slash/slash = arm.get_wound_type(/datum/wound/rogue/dynamic/slash)
	TEST_ASSERT(slash, "A cut did not open a slash")
	var/bleed = slash.rogue_bleed()
	slash.handle_process(SSMOBS_DT)
	TEST_ASSERT(slash.rogue_bleed() < bleed, "A slash did not clot")

/// The pain of TG's wounds and of a stump eases by half of what is mended (Ratwood heal_wound()).
/datum/unit_test/rogue_wounds/pain_eased

/datum/unit_test/rogue_wounds/pain_eased/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/datum/wound/fracture = patient.cause_wound_of_type_and_severity(WOUND_BLUNT, arm, WOUND_SEVERITY_SEVERE)
	TEST_ASSERT(fracture, "Could not break the arm")
	TEST_ASSERT_EQUAL(fracture.rogue_pain(), ROGUE_PAIN_FRACTURE, "A broken bone does not hurt as Ratwood's fracture")
	fracture.rogue_heal_wound(10)
	TEST_ASSERT_EQUAL(fracture.rogue_pain(), ROGUE_PAIN_FRACTURE - 5, "Mending 10 of a broken bone did not ease 5 of its pain")
	patient.rogue_add_stump()
	var/datum/wound/rogue_stump/stump = locate() in patient.all_wounds
	TEST_ASSERT(stump, "Could not leave a stump")
	var/stump_pain = stump.rogue_pain()
	stump.rogue_heal_wound(10)
	TEST_ASSERT_EQUAL(stump.rogue_pain(), stump_pain - 5, "Mending 10 of a stump did not ease 5 of its pain")

/// A sewn cut of TG stays as its sewn tail, bleeding and hurting a little; a sewn dynamic wound is gone.
/datum/unit_test/rogue_wounds/sewing

/datum/unit_test/rogue_wounds/sewing/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/datum/wound/cut = patient.cause_wound_of_type_and_severity(WOUND_SLASH, arm, WOUND_SEVERITY_CRITICAL)
	TEST_ASSERT(cut, "Could not open an artery")
	TEST_ASSERT(cut.rogue_sew_threshold() > 0, "An opened artery cannot be sewn")
	cut.rogue_sew_done()
	TEST_ASSERT(QDELETED(cut), "The sewn artery stayed as it was")
	var/datum/wound/rogue/sewn/sewn = arm.get_wound_type(/datum/wound/rogue/sewn)
	TEST_ASSERT(sewn, "A sewn artery left no sewn wound")
	TEST_ASSERT_EQUAL(sewn.rogue_pain(), rogue_value("sewn_artery_pain"), "A sewn artery does not hurt as Ratwood's")
	TEST_ASSERT(abs(sewn.rogue_bleed() - rogue_value("sewn_artery_bleed")) < 0.001, "A sewn artery does not bleed as Ratwood's")
	TEST_ASSERT(sewn.rogue_health > 0 && sewn.rogue_health <= rogue_value("sewn_artery_health"), "A sewn artery has more to mend than Ratwood's")
	TEST_ASSERT_EQUAL(sewn.rogue_sew_threshold(), 0, "A sewn wound can be sewn again")
	sewn.rogue_heal_wound(sewn.rogue_health)
	TEST_ASSERT(QDELETED(sewn), "A sewn artery mended whole did not close")
	patient.apply_damage(15, BRUTE, arm, sharpness = SHARP_EDGED)
	var/datum/wound/rogue/dynamic/slash/slash = arm.get_wound_type(/datum/wound/rogue/dynamic/slash)
	TEST_ASSERT(slash?.rogue_sew_threshold() > 0, "A slash cannot be sewn")
	var/flow = slash.blood_flow
	slash.rogue_stitch(0.1)
	TEST_ASSERT(slash.blood_flow < flow, "A stitch did not stem the slash")
	slash.rogue_sew_done()
	TEST_ASSERT(QDELETED(slash), "A sewn slash did not close")

/// The bandage shows on the body, and a new bleeding wound under it soaks through it.
/datum/unit_test/rogue_wounds/bandage

/datum/unit_test/rogue_wounds/bandage/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/natural/cloth/cloth = allocate(__IMPLIED_TYPE__)
	cloth.forceMove(arm)
	arm.rogue_bandage = cloth
	var/drawn = FALSE
	for(var/mutable_appearance/overlay as anything in arm.get_bodypart_damage_state())
		if(overlay.icon_state == "l_arm_b")
			drawn = TRUE
	TEST_ASSERT(drawn, "The bandage is not drawn on the arm")
	patient.apply_damage(15, BRUTE, arm, sharpness = SHARP_EDGED)
	TEST_ASSERT(cloth.rogue_soaked, "A new cut under the bandage did not soak through it")
	cloth.forceMove(get_turf(patient))
	TEST_ASSERT_NULL(arm.rogue_bandage, "The bandage taken off is still on the arm")

/// Sleep mends the wounds of a limb that does not bleed.
/datum/unit_test/rogue_wounds/sleep

/datum/unit_test/rogue_wounds/sleep/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	patient.apply_damage(10, BRUTE, arm)
	var/datum/wound/rogue/dynamic/bruise/bruise = arm.get_wound_type(/datum/wound/rogue/dynamic/bruise)
	TEST_ASSERT(bruise, "A blunt blow did not leave a hematoma")
	var/health = bruise.rogue_health
	var/datum/component/rogue_sleeper/sleeper = patient.AddComponent(/datum/component/rogue_sleeper)
	sleeper.sleep_heal(patient, SSMOBS_DT)
	TEST_ASSERT(QDELETED(bruise) || bruise.rogue_health < health, "Sleep did not mend the hematoma")

/// A leech draws toxins out and drinks blood until it is full, then drops off.
/datum/unit_test/rogue_wounds/leech

/datum/unit_test/rogue_wounds/leech/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/natural/worms/leech/leech = allocate(__IMPLIED_TYPE__)
	leech.forceMove(arm)
	leech.rogue_latch(arm)
	TEST_ASSERT(leech in arm.rogue_leeches, "The leech did not take hold of the arm")
	patient.adjust_tox_loss(10)
	var/blood = patient.get_blood_volume()
	var/toxins = patient.get_tox_loss()
	leech.rogue_leech_tick(patient, 1)
	TEST_ASSERT(patient.get_blood_volume() < blood, "The leech drank no blood")
	TEST_ASSERT(patient.get_tox_loss() < toxins, "The leech drew no toxins out")
	TEST_ASSERT(leech.rogue_blood > 0, "The leech kept none of the blood")
	leech.rogue_blood = leech.rogue_blood_max
	leech.rogue_leech_tick(patient, 1)
	TEST_ASSERT(leech.loc != arm && !(leech in arm.rogue_leeches), "A full leech did not drop off")
	TEST_ASSERT_NULL(leech.rogue_limb, "A leech that dropped off still holds the arm")

/// Cloth soaks in Ratwood's medicines; aqua vitae as soon as the drink exists.
/datum/unit_test/rogue_wounds/soakings

/datum/unit_test/rogue_wounds/soakings/Run()
	var/list/soakings = rogue_soak_medicines()
	TEST_ASSERT(soakings[/datum/reagent/medicine/healthpot], "Cloth cannot be soaked in a health potion")
	TEST_ASSERT(soakings[/datum/reagent/water/blessed], "Cloth cannot be soaked in blessed water")
	var/aqua_vitae = text2path("/datum/reagent/consumable/ethanol/aqua_vitae")
	TEST_ASSERT(!aqua_vitae || soakings[aqua_vitae], "Aqua vitae exists, but cloth cannot be soaked in it")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
