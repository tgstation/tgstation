#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's surgery on TG's operations (combat/surgery/). The test map is not a medieval one, so the patient is given the
/// surgery element (and the blood element, for Ratwood's wounds) by hand, as a medieval map gives them to every human. A step
/// is done by TG's success(), past its roll and its time.
/datum/unit_test/rogue_surgery
	abstract_type = /datum/unit_test/rogue_surgery

/datum/unit_test/rogue_surgery/proc/make_patient()
	var/mob/living/carbon/human/consistent/patient = allocate(__IMPLIED_TYPE__)
	patient.AddElement(/datum/element/rogue_blood)
	patient.AddElement(/datum/element/rogue_surgery)
	return patient

/datum/unit_test/rogue_surgery/proc/make_surgeon(rank = ROGUE_RANK_JOURNEYMAN)
	var/mob/living/carbon/human/consistent/surgeon = allocate(__IMPLIED_TYPE__)
	surgeon.rogue_set_skill(/datum/attribute/skill/misc/medicine, rank * ROGUE_SKILL_PER_RANK)
	return surgeon

/datum/unit_test/rogue_surgery/proc/rogue_operation(operation_type)
	return GLOB.operations.operations_by_typepath[operation_type]

/// A medieval body offers Ratwood's operations and only those, to the skilled; a body of TG's offers none of them.
/datum/unit_test/rogue_surgery/offered

/datum/unit_test/rogue_surgery/offered/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/mob/living/carbon/human/surgeon = make_surgeon()
	var/obj/item/rogueweapon/surgery/scalpel/scalpel = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT(HAS_TRAIT(patient, TRAIT_READY_TO_OPERATE), "A medieval body cannot be operated on without drapes")
	var/list/offered = surgeon.get_available_operations(patient, scalpel, BODY_ZONE_L_ARM)
	var/incision = FALSE
	for(var/slice in offered)
		var/datum/surgery_operation/offer = offered[slice][1]
		TEST_ASSERT(offer.rogue_medieval, "A medieval body offers [offer.type], which is not Ratwood's")
		if(offer.type == /datum/surgery_operation/limb/rogue/incise)
			incision = TRUE
	TEST_ASSERT(incision, "A scalpel cannot incise a medieval arm")
	var/mob/living/carbon/human/novice = make_surgeon(ROGUE_RANK_NONE)
	ADD_TRAIT(novice, TRAIT_ROGUE_NO_SKILLS, "rogue_surgery_test")
	TEST_ASSERT(!length(novice.get_available_operations(patient, scalpel, BODY_ZONE_L_ARM)), "One without Medicine is offered an incision")
	var/mob/living/carbon/human/consistent/townie = allocate(__IMPLIED_TYPE__)
	var/list/tg_offered = surgeon.get_available_operations(townie, scalpel, BODY_ZONE_L_ARM)
	for(var/slice in tg_offered)
		var/list/entry = tg_offered[slice]
		var/datum/surgery_operation/offer = entry[1]
		TEST_ASSERT(!offer.rogue_medieval, "A body of TG's offers Ratwood's [offer.type]")

/// The ported tools answer to their steps; the cautery only while it is hot; a tool's chance is Ratwood's against a sharp thing's.
/datum/unit_test/rogue_surgery/tools

/datum/unit_test/rogue_surgery/tools/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/mob/living/carbon/human/surgeon = make_surgeon()
	var/obj/item/rogueweapon/surgery/scalpel/scalpel = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_EQUAL(scalpel.tool_behaviour, TOOL_SCALPEL, "The scalpel is no scalpel")
	TEST_ASSERT(scalpel.item_flags & SURGICAL_TOOL, "The scalpel is no surgical tool")
	var/obj/item/rogueweapon/surgery/hemostat/improv/clamp = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_EQUAL(clamp.tool_behaviour, ROGUE_TOOL_IMPROVISED_HEMOSTAT, "The improvised clamp is no clamp")
	var/obj/item/rogueweapon/surgery/cautery/cautery = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_NULL(cautery.tool_behaviour, "A cold cautery sears")
	cautery.rogue_heat(10 SECONDS)
	TEST_ASSERT_EQUAL(cautery.tool_behaviour, TOOL_CAUTERY, "A hot cautery does not sear")
	TEST_ASSERT(cautery.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST, "A hot cautery is not hot")
	cautery.rogue_set_heated(FALSE)
	TEST_ASSERT_NULL(cautery.tool_behaviour, "A cooled cautery still sears")
	var/obj/item/knife/kitchen/knife = allocate(__IMPLIED_TYPE__)
	var/datum/surgery_operation/incise = rogue_operation(/datum/surgery_operation/limb/rogue/incise)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/scalpel_chance = incise.rogue_success_chance(arm, surgeon, scalpel)
	var/knife_chance = incise.rogue_success_chance(arm, surgeon, knife)
	TEST_ASSERT(scalpel_chance > 0 && knife_chance > 0, "Neither a scalpel nor a knife can incise")
	TEST_ASSERT(abs(scalpel_chance * rogue_value("surgery_incise_sharp") - knife_chance * rogue_value("surgery_incise_scalpel")) < 0.01, "A knife's chance is not Ratwood's share of a scalpel's")
	TEST_ASSERT_NULL(incise.rogue_implement(IMPLEMENT_HAND), "A bare hand can incise")

/// The incision opens the limb and closes with the site: sewn shut, or seared with the rest.
/datum/unit_test/rogue_surgery/incision

/datum/unit_test/rogue_surgery/incision/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/mob/living/carbon/human/surgeon = make_surgeon()
	var/obj/item/rogueweapon/surgery/scalpel/scalpel = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/surgery/retractor/retractor = allocate(__IMPLIED_TYPE__)
	var/obj/item/rogueweapon/surgery/cautery/cautery = allocate(__IMPLIED_TYPE__)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/datum/surgery_operation/incise = rogue_operation(/datum/surgery_operation/limb/rogue/incise)
	UNLINT(incise.success(arm, surgeon, scalpel, list()))
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(arm, SURGERY_SKIN_CUT|SURGERY_VESSELS_UNCLAMPED), "An incision did not cut the skin and the vessels")
	var/datum/wound/rogue/incision/incision = arm.get_wound_type(/datum/wound/rogue/incision)
	TEST_ASSERT(incision, "An incision left no incision")
	TEST_ASSERT_EQUAL(incision.rogue_sew_threshold(), rogue_value("surgery_incision_sew"), "An incision is not sewn as Ratwood's")
	incision.rogue_sew_done()
	TEST_ASSERT(QDELETED(incision), "A sewn incision stayed open")
	TEST_ASSERT(!LIMB_HAS_ANY_SURGERY_STATE(arm, ALL_SURGERY_SKIN_STATES), "The site stayed open after the incision was sewn")
	UNLINT(incise.success(arm, surgeon, scalpel, list()))
	var/datum/surgery_operation/retract = rogue_operation(/datum/surgery_operation/limb/rogue/retract)
	UNLINT(retract.success(arm, surgeon, retractor, list()))
	TEST_ASSERT(LIMB_HAS_SURGERY_STATE(arm, SURGERY_SKIN_OPEN), "Retracting did not open the skin")
	incision = arm.get_wound_type(/datum/wound/rogue/incision)
	TEST_ASSERT(incision, "Retracting closed the incision")
	cautery.rogue_heat(10 SECONDS)
	var/burn = arm.burn_dam
	var/datum/surgery_operation/cauterize = rogue_operation(/datum/surgery_operation/limb/rogue/cauterize)
	UNLINT(cauterize.success(arm, surgeon, cautery, list()))
	TEST_ASSERT(QDELETED(incision), "Searing left the incision open")
	TEST_ASSERT(!LIMB_HAS_ANY_SURGERY_STATE(arm, ALL_SURGERY_STATES_UNSET_ON_CLOSE), "Searing did not close the site")
	TEST_ASSERT(arm.burn_dam > burn, "Searing did not burn")

/// Searing closes Ratwood's dynamic slash or mends it by the searing, and a stump with it.
/datum/unit_test/rogue_surgery/searing

/datum/unit_test/rogue_surgery/searing/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/mob/living/carbon/human/surgeon = make_surgeon()
	var/obj/item/rogueweapon/surgery/cautery/cautery = allocate(__IMPLIED_TYPE__)
	cautery.rogue_heat(10 SECONDS)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	patient.apply_damage(15, BRUTE, arm, wound_bonus = 100, sharpness = SHARP_EDGED)
	var/datum/wound/rogue/dynamic/slash/slash = arm.get_wound_type(/datum/wound/rogue/dynamic/slash)
	TEST_ASSERT(slash, "A cut did not open a slash")
	var/health = slash.rogue_health
	var/datum/surgery_operation/cauterize = rogue_operation(/datum/surgery_operation/limb/rogue/cauterize)
	UNLINT(cauterize.success(arm, surgeon, cautery, list()))
	TEST_ASSERT(QDELETED(slash) || slash.rogue_health <= health - rogue_value("surgery_cauterize_heal") + 0.01, "Searing did not mend the slash")
	patient.apply_damage(10, BRUTE, arm)
	var/datum/wound/rogue/dynamic/bruise/bruise = arm.get_wound_type(/datum/wound/rogue/dynamic/bruise)
	TEST_ASSERT(bruise && !bruise.rogue_cauterizable(), "A hematoma can be seared")
	patient.rogue_add_stump()
	var/datum/wound/rogue_stump/stump = locate() in patient.all_wounds
	TEST_ASSERT(stump, "Could not leave a stump")
	var/integrity = stump.integrity
	UNLINT(cauterize.success(patient.get_bodypart(BODY_ZONE_CHEST), surgeon, cautery, list()))
	TEST_ASSERT(QDELETED(stump) || stump.integrity < integrity, "Searing the chest did not sear the stump")

/// A dislocation is put back; a broken bone is set, mends a part at once and the rest by itself and in sleep.
/datum/unit_test/rogue_surgery/bones

/datum/unit_test/rogue_surgery/bones/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/mob/living/carbon/human/surgeon = make_surgeon()
	var/obj/item/rogueweapon/surgery/bonesetter/bonesetter = allocate(__IMPLIED_TYPE__)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	arm.force_wound_upwards(/datum/wound/blunt/bone/moderate)
	TEST_ASSERT(arm.get_wound_type(/datum/wound/blunt/bone/moderate), "Could not dislocate the arm")
	var/datum/surgery_operation/relocate = rogue_operation(/datum/surgery_operation/limb/rogue/relocate)
	UNLINT(relocate.success(arm, surgeon, bonesetter, list()))
	TEST_ASSERT_NULL(arm.get_wound_type(/datum/wound/blunt/bone/moderate), "Relocating left the arm dislocated")
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	leg.force_wound_upwards(/datum/wound/blunt/bone/critical)
	var/datum/wound/blunt/bone/critical/fracture = leg.get_wound_type(/datum/wound/blunt/bone/critical)
	TEST_ASSERT(fracture, "Could not break the leg")
	TEST_ASSERT(leg.rogue_settable_bone(), "A broken leg cannot be set")
	TEST_ASSERT_EQUAL(fracture.rogue_sleep_healing(), rogue_value("fracture_sleep_healing"), "A broken bone not set mends in sleep")
	var/datum/surgery_operation/set_bone = rogue_operation(/datum/surgery_operation/limb/rogue/set_bone)
	UNLINT(set_bone.success(leg, surgeon, bonesetter, list()))
	TEST_ASSERT(fracture.rogue_bone_set, "Setting did not set the bone")
	TEST_ASSERT(!leg.rogue_settable_bone(), "A set bone can be set again")
	TEST_ASSERT(fracture.rogue_health < fracture.rogue_health_max(), "Setting the bone mended none of it")
	TEST_ASSERT_EQUAL(fracture.rogue_sleep_healing(), rogue_value("surgery_set_bone_sleep"), "A set bone does not mend in sleep as Ratwood's")
	for(var/tick in 1 to 200)
		if(QDELETED(fracture))
			break
		fracture.handle_process(SSMOBS_DT)
	TEST_ASSERT(QDELETED(fracture), "A set bone never mended")

/// Sawn, an arm is cut off and leaves a stump; a wooden prosthetic goes on in its place, a real limb that comes off as the
/// prosthetic again. A severed arm put back must be sewn on.
/datum/unit_test/rogue_surgery/limbs

/datum/unit_test/rogue_surgery/limbs/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/mob/living/carbon/human/surgeon = make_surgeon()
	var/obj/item/rogueweapon/surgery/saw/saw = allocate(__IMPLIED_TYPE__)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_L_ARM)
	var/datum/surgery_operation/saw_bone = rogue_operation(/datum/surgery_operation/limb/rogue/saw)
	UNLINT(saw_bone.success(arm, surgeon, saw, list()))
	TEST_ASSERT(arm.rogue_broken_bone(), "Sawing did not break the bone")
	var/datum/surgery_operation/amputate = rogue_operation(/datum/surgery_operation/limb/rogue/amputate)
	UNLINT(amputate.success(arm, surgeon, saw, list()))
	TEST_ASSERT_NULL(patient.get_bodypart(BODY_ZONE_L_ARM), "The amputated arm is still attached")
	var/obj/item/bodypart/stump_part = patient.get_bodypart(BODY_ZONE_L_ARM, TRUE)
	TEST_ASSERT(stump_part && IS_STUMP(stump_part), "The amputated arm left no stump to put a limb on")
	var/obj/item/bodypart/l_arm/prosthetic/woodleft/kit = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_EQUAL(kit.rogue_prosthetic_zone(), BODY_ZONE_L_ARM, "The wooden left arm is no left arm")
	var/obj/item/bodypart/wooden = rogue_attach_part(kit, patient)
	TEST_ASSERT(wooden, "The wooden arm did not go on")
	TEST_ASSERT_EQUAL(patient.get_bodypart(BODY_ZONE_L_ARM), wooden, "The wooden arm is not the patient's arm")
	TEST_ASSERT(istype(wooden, /obj/item/bodypart/arm/left/ghetto/rogue_prosthetic), "The wooden arm is no peg arm")
	TEST_ASSERT_EQUAL(kit.loc, wooden, "The prosthetic is not kept in the limb it made")
	TEST_ASSERT_EQUAL(wooden.max_damage, rogue_value("surgery_prosthetic_wood_left_arm_damage"), "The wooden left arm is not as tough as Ratwood's")
	TEST_ASSERT(!(wooden.biological_state & BIO_FLESH), "The wooden arm is of flesh")
	TEST_ASSERT_NULL(wooden.get_wound_type(/datum/wound/rogue/replantation), "A wooden arm needs sewing on")
	wooden.drop_limb()
	wooden.rogue_revert_prosthetic()
	TEST_ASSERT(QDELETED(wooden), "The wooden arm stayed a limb after it came off")
	TEST_ASSERT(isturf(kit.loc), "The prosthetic did not come back when the arm came off")
	var/obj/item/bodypart/leg = patient.get_bodypart(BODY_ZONE_L_LEG)
	TEST_ASSERT(patient.rogue_dismember(leg, saw, surgeon, "l_leg"), "Could not sever the leg")
	var/datum/wound/rogue_stump/stump = locate() in patient.all_wounds
	TEST_ASSERT(stump, "The severed leg left no bleeding stump")
	var/obj/item/bodypart/put_back = rogue_attach_part(leg, patient)
	TEST_ASSERT_EQUAL(put_back, leg, "The severed leg did not go back on")
	TEST_ASSERT(QDELETED(stump), "The leg put back left its stump bleeding")
	var/datum/wound/rogue/replantation/replantation = leg.get_wound_type(/datum/wound/rogue/replantation)
	TEST_ASSERT(replantation, "A leg put back needs no sewing on")
	TEST_ASSERT(HAS_TRAIT(leg, TRAIT_PARALYSIS), "A leg put back serves before it is sewn on")
	TEST_ASSERT(replantation.rogue_sew_threshold() > 0, "A leg put back cannot be sewn on")
	replantation.rogue_sew_done()
	TEST_ASSERT(!HAS_TRAIT(leg, TRAIT_PARALYSIS), "A leg sewn on does not serve")
	TEST_ASSERT(abs(replantation.rogue_bleed() - rogue_value("surgery_replant_sewn_bleed")) < 0.001, "A leg sewn on does not bleed as Ratwood's")

/// Bloodletting: a vein of a clamped arm is cut, and the bad blood forced out takes toxins with it.
/datum/unit_test/rogue_surgery/bloodletting

/datum/unit_test/rogue_surgery/bloodletting/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/mob/living/carbon/human/surgeon = make_surgeon(ROGUE_RANK_EXPERT)
	var/obj/item/rogueweapon/surgery/scalpel/scalpel = allocate(__IMPLIED_TYPE__)
	var/obj/item/bodypart/arm = patient.get_bodypart(BODY_ZONE_R_ARM)
	var/datum/surgery_operation/cut_vein = rogue_operation(/datum/surgery_operation/limb/rogue/cut_vein)
	UNLINT(cut_vein.success(arm, surgeon, scalpel, list()))
	var/datum/wound/rogue/vein/vein = arm.get_wound_type(/datum/wound/rogue/vein)
	TEST_ASSERT(vein, "Cutting a vein left no cut vein")
	TEST_ASSERT(vein.blood_flow > 0, "A cut vein does not bleed")
	patient.adjust_tox_loss(40)
	var/toxins = patient.get_tox_loss()
	var/blood = patient.get_blood_volume()
	var/datum/surgery_operation/bloodlet = rogue_operation(/datum/surgery_operation/limb/rogue/bloodlet)
	UNLINT(bloodlet.success(arm, surgeon, IMPLEMENT_HAND, list()))
	TEST_ASSERT(patient.get_tox_loss() < toxins, "Bloodletting drew no toxins out")
	TEST_ASSERT(patient.get_blood_volume() < blood, "Bloodletting let no blood out")
	var/flow = vein.blood_flow
	vein.rogue_sew_done()
	TEST_ASSERT(vein.blood_flow < flow, "A sewn vein bleeds as much")
	TEST_ASSERT_EQUAL(vein.rogue_sew_threshold(), 0, "A sewn vein can be sewn again")

/// Mouth to mouth gives breath; a failed step of surgery leaves bad humours by its chance.
/datum/unit_test/rogue_surgery/breath_and_humours

/datum/unit_test/rogue_surgery/breath_and_humours/Run()
	var/mob/living/carbon/human/patient = make_patient()
	var/mob/living/carbon/human/surgeon = make_surgeon()
	patient.adjust_oxy_loss(50)
	var/oxygen = patient.get_oxy_loss()
	var/datum/surgery_operation/breathe = rogue_operation(/datum/surgery_operation/limb/rogue/mouth_to_mouth)
	UNLINT(breathe.success(patient.get_bodypart(BODY_ZONE_HEAD), surgeon, IMPLEMENT_HAND, list()))
	TEST_ASSERT_EQUAL(patient.get_oxy_loss(), oxygen - rogue_value("surgery_cpr_oxygen"), "A breath did not ease the choking as Ratwood's")
	rogue_surgery_infect(patient, 5)
	TEST_ASSERT(patient.reagents.has_reagent(/datum/reagent/rogue_infection/major), "A step failed at a poor chance left no Kingsfield's Bane")
	var/mob/living/carbon/human/other = make_patient()
	rogue_surgery_infect(other, 60)
	TEST_ASSERT(other.reagents.has_reagent(/datum/reagent/rogue_infection/minor), "A step failed at a fair chance left no disrupted humours")
	var/mob/living/carbon/human/lucky = make_patient()
	rogue_surgery_infect(lucky, 90)
	TEST_ASSERT(!lucky.reagents.has_reagent(/datum/reagent/rogue_infection, check_subtypes = TRUE), "A step failed at a good chance left bad humours")

/// The artificer's contraptions become Ratwood's limb of their metal where the porter brings it.
/datum/unit_test/rogue_surgery/contraptions

/datum/unit_test/rogue_surgery/contraptions/Run()
	TEST_ASSERT_EQUAL(rogue_ratwood_prosthetic_path(ROGUE_PROSTHETIC_BRONZE, BODY_ZONE_R_ARM), "/obj/item/bodypart/r_arm/prosthetic/bronzeright", "The bronze right arm is not Ratwood's")
	TEST_ASSERT(text2path(rogue_ratwood_prosthetic_path(ROGUE_PROSTHETIC_BRONZE, BODY_ZONE_R_ARM)), "The porter brings no bronze right arm")
	TEST_ASSERT_EQUAL(rogue_prosthetic_material_of(/obj/item/bodypart/r_arm/prosthetic/bronzeright), ROGUE_PROSTHETIC_BRONZE, "The bronze right arm is not of bronze")
	TEST_ASSERT_EQUAL(rogue_prosthetic_material_of(/obj/item/bodypart/r_leg/prosthetic), ROGUE_PROSTHETIC_WOOD, "The wooden leg is not of wood")
	var/obj/item/contraption/ironprosthetic/iron = allocate(__IMPLIED_TYPE__)
	TEST_ASSERT_NULL(iron.rogue_prosthetic_zone(), "An iron prosthetic not yet shaped replaces a limb")
	iron.rogue_limb_zone = BODY_ZONE_R_LEG
	TEST_ASSERT_EQUAL(iron.rogue_prosthetic_zone(), BODY_ZONE_R_LEG, "A shaped iron leg replaces no leg")
	TEST_ASSERT_EQUAL(rogue_prosthetic_limb_type(iron.rogue_prosthetic_zone(), iron.rogue_prosthetic_material()), /obj/item/bodypart/leg/right/robot/surplus/rogue_prosthetic, "An iron leg is no metal leg")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
