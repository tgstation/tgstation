/// Ratwood's steps of surgery (code/modules/surgery/surgeries/), each one of TG's operations on a medieval body
/// (combat/surgery/operation.dm), in TG's surgical states of the limb:
/// - incise (cut skin, vessels bleeding, the incision wound), clamp the bleeders, retract the incision (skin open);
/// - cauterize: sears the limb's wounds that can be seared and closes the site;
/// - saw the bone (a compound fracture of TG), amputate, set the broken bones, relocate a dislocation;
/// - cut a vein and force the bad blood out (bloodletting), remove what is lodged in the limb (and its leeches);
/// - manipulate organs (TG's organ manipulation, Ratwood's tools and ranks), mouth to mouth;
/// - implant a limb on a stump (a severed limb, put back with a replantation to sew, or a prosthetic), replace a broken limb
///   with a prosthetic, saw a prosthetic off;
/// - burn the rot out of a corpse's chest (Ratwood's hearth surgery, burial/corpse_rot.dm rogue_remove_rot()).
/// Not ported: the drill (no medieval drill), healing (Ratwood locks it behind a tech), plastic surgery, frostbite, external
/// and molded organs, the construct's and the other hearth surgeries, the revival chair.

/// The zones of Ratwood's limb steps: arms and legs.
#define ROGUE_SURGERY_LIMB_ZONES list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
/// The zones a limb can be cut off or put on: the head, the arms and the legs.
#define ROGUE_SURGERY_SEVERABLE_ZONES list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
/// The radial sprites of TG's surgery.
#define ROGUE_SURGERY_RADIAL 'icons/hud/surgery_radial.dmi'

/// Ratwood's SURGERY_BROKEN: a fracture of TG from severe up, or a cracked skull.
/obj/item/bodypart/proc/rogue_broken_bone()
	for(var/datum/wound/wound as anything in wounds)
		if(istype(wound, /datum/wound/cranial_fissure) || (istype(wound, /datum/wound/blunt/bone) && wound.severity >= WOUND_SEVERITY_SEVERE))
			return TRUE
	return FALSE

/// A broken bone of this limb not set yet (Ratwood can_set).
/obj/item/bodypart/proc/rogue_settable_bone()
	for(var/datum/wound/wound as anything in wounds)
		if(wound.rogue_settable())
			return TRUE
	return FALSE

/// The patient's cry of pain, a groan when they feel none (Ratwood: a groan under ozium).
/proc/rogue_surgery_cry(mob/living/patient, cry = "painscream")
	if(!patient || patient.stat == DEAD)
		return
	INVOKE_ASYNC(patient, TYPE_PROC_REF(/mob, emote), HAS_TRAIT(patient, TRAIT_NOPAIN) ? "groan" : cry)

/// Ratwood /datum/surgery_step/incise: the first cut, which opens the limb and its vessels.
/datum/surgery_operation/limb/rogue/incise
	name = "incise"
	desc = "Make an incision in a patient's limb to reach what lies beneath."
	implements = list(TOOL_SCALPEL = 1, ROGUE_IMPLEMENT_SHARP = 1)
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/rogue/incise/rogue_chances()
	return list(TOOL_SCALPEL = rogue_value("surgery_incise_scalpel"), ROGUE_IMPLEMENT_SHARP = rogue_value("surgery_incise_sharp"))

/datum/surgery_operation/limb/rogue/incise/rogue_time()
	return rogue_value("surgery_incise_time")

/datum/surgery_operation/limb/rogue/incise/rogue_skill_min()
	return rogue_value("surgery_incise_skill_min")

/datum/surgery_operation/limb/rogue/incise/rogue_skill_median()
	return rogue_value("surgery_incise_skill_median")

/datum/surgery_operation/limb/rogue/incise/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "make_incision")

/datum/surgery_operation/limb/rogue/incise/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to make an incision in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to make an incision in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins to make an incision in [FORMAT_LIMB_OWNER(limb)]."))

/datum/surgery_operation/limb/rogue/incise/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	limb.add_surgical_state(SURGERY_SKIN_CUT|SURGERY_VESSELS_UNCLAMPED)
	limb.rogue_surgery_wound(/datum/wound/rogue/incision, "surgery")
	display_results(surgeon, limb.owner, span_notice("Blood pools around the incision in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("Blood pools around the incision in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("Blood pools around the incision in [FORMAT_LIMB_OWNER(limb)]."))

/// Ratwood /datum/surgery_step/clamp: the cut vessels are clamped and bleed little.
/datum/surgery_operation/limb/rogue/clamp
	name = "clamp bleeders"
	desc = "Clamp the bleeding vessels of an incision."
	implements = list(TOOL_HEMOSTAT = 1, TOOL_WIRECUTTER = 1, ROGUE_TOOL_IMPROVISED_HEMOSTAT = 1)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_VESSELS_UNCLAMPED
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/rogue/clamp/rogue_chances()
	return list(TOOL_HEMOSTAT = rogue_value("surgery_clamp_hemostat"), TOOL_WIRECUTTER = rogue_value("surgery_clamp_wirecutter"), ROGUE_TOOL_IMPROVISED_HEMOSTAT = rogue_value("surgery_clamp_improvised"))

/datum/surgery_operation/limb/rogue/clamp/rogue_time()
	return rogue_value("surgery_clamp_time")

/datum/surgery_operation/limb/rogue/clamp/rogue_skill_min()
	return rogue_value("surgery_clamp_skill_min")

/datum/surgery_operation/limb/rogue/clamp/rogue_skill_median()
	return rogue_value("surgery_clamp_skill_median")

/datum/surgery_operation/limb/rogue/clamp/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "clamp_bleeders")

/datum/surgery_operation/limb/rogue/clamp/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to clamp bleeders in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to clamp bleeders in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins to clamp bleeders in [FORMAT_LIMB_OWNER(limb)]."))

/datum/surgery_operation/limb/rogue/clamp/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	limb.add_surgical_state(SURGERY_VESSELS_CLAMPED)
	limb.remove_surgical_state(SURGERY_VESSELS_UNCLAMPED)
	display_results(surgeon, limb.owner, span_notice("I clamp the bleeders in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] clamps the bleeders in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] clamps the bleeders in [FORMAT_LIMB_OWNER(limb)]."))

/// Ratwood /datum/surgery_step/retract: the incision is spread open.
/datum/surgery_operation/limb/rogue/retract
	name = "retract incision"
	desc = "Spread an incision open to reach the bone and the organs."
	implements = list(TOOL_RETRACTOR = 1, TOOL_SCREWDRIVER = 1, TOOL_WIRECUTTER = 1, ROGUE_TOOL_IMPROVISED_RETRACTOR = 1)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_CUT

/datum/surgery_operation/limb/rogue/retract/rogue_chances()
	return list(TOOL_RETRACTOR = rogue_value("surgery_retract_retractor"), TOOL_SCREWDRIVER = rogue_value("surgery_retract_screwdriver"), TOOL_WIRECUTTER = rogue_value("surgery_retract_wirecutter"), ROGUE_TOOL_IMPROVISED_RETRACTOR = rogue_value("surgery_retract_improvised"))

/datum/surgery_operation/limb/rogue/retract/rogue_time()
	return rogue_value("surgery_retract_time")

/datum/surgery_operation/limb/rogue/retract/rogue_skill_min()
	return rogue_value("surgery_retract_skill_min")

/datum/surgery_operation/limb/rogue/retract/rogue_skill_median()
	return rogue_value("surgery_retract_skill_median")

/datum/surgery_operation/limb/rogue/retract/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "retract_skin")

/datum/surgery_operation/limb/rogue/retract/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to retract [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to retract [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins to retract [FORMAT_LIMB_OWNER(limb)]."))

/datum/surgery_operation/limb/rogue/retract/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	limb.add_surgical_state(SURGERY_SKIN_OPEN | (LIMB_HAS_SURGERY_STATE(limb, SURGERY_VESSELS_CLAMPED) ? NONE : SURGERY_VESSELS_UNCLAMPED))
	limb.remove_surgical_state(SURGERY_SKIN_CUT)
	display_results(surgeon, limb.owner, span_notice("I retract [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] retracts [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] retracts [FORMAT_LIMB_OWNER(limb)]."))

/// Ratwood /datum/surgery_step/cauterize: every wound of the limb that can be seared is (cauterize_wound()), the site of the
/// operation is closed, and the searing burns and hurts. Ratwood's dynamic slashes, punctures and bites, the opened arteries
/// and the stumps sear; bruises, gouges and lashings do not.
/datum/surgery_operation/limb/rogue/cauterize
	name = "cauterize wounds"
	desc = "Sear the wounds of a limb shut, and close the site of an operation."
	implements = list(TOOL_CAUTERY = 1, TOOL_WELDER = 1, ROGUE_IMPLEMENT_HOT = 1)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'

/datum/surgery_operation/limb/rogue/cauterize/rogue_chances()
	return list(TOOL_CAUTERY = rogue_value("surgery_cauterize_cautery"), TOOL_WELDER = rogue_value("surgery_cauterize_welder"), ROGUE_IMPLEMENT_HOT = rogue_value("surgery_cauterize_hot"))

/datum/surgery_operation/limb/rogue/cauterize/rogue_time()
	return rogue_value("surgery_cauterize_time")

/datum/surgery_operation/limb/rogue/cauterize/rogue_skill_min()
	return rogue_value("surgery_cauterize_skill_min")

/datum/surgery_operation/limb/rogue/cauterize/rogue_skill_median()
	return rogue_value("surgery_cauterize_skill_median")

/datum/surgery_operation/limb/rogue/cauterize/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "mend_incision")

/// Ratwood validate_bodypart(): a limb with wounds; or the site of an operation to close.
/datum/surgery_operation/limb/rogue/cauterize/state_check(obj/item/bodypart/limb)
	if(!..())
		return FALSE
	return LAZYLEN(limb.wounds) || LIMB_HAS_ANY_SURGERY_STATE(limb, ALL_SURGERY_STATES_UNSET_ON_CLOSE)

/datum/surgery_operation/limb/rogue/cauterize/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to cauterize the wounds on [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to cauterize the wounds on [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins to cauterize the wounds on [FORMAT_LIMB_OWNER(limb)]."))

/datum/surgery_operation/limb/rogue/cauterize/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	display_results(surgeon, patient, span_notice("I cauterize the wounds on [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] cauterizes the wounds on [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] cauterizes the wounds on [FORMAT_LIMB_OWNER(limb)]."))
	var/searing = rogue_value("surgery_cauterize_heal")
	for(var/datum/wound/wound as anything in LAZYCOPY(limb.wounds))
		if(!QDELETED(wound))
			wound.rogue_cauterize(searing)
	if(LIMB_HAS_ANY_SURGERY_STATE(limb, ALL_SURGERY_STATES_UNSET_ON_CLOSE))
		limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)
	limb.receive_damage(burn = rogue_value("surgery_cauterize_burn"), wound_bonus = CANT_WOUND, damage_source = isitem(tool) ? tool : null)
	rogue_surgery_cry(patient)

/// Ratwood /datum/surgery_step/saw: the bone is sawn through - a compound fracture, as surgery means it.
/datum/surgery_operation/limb/rogue/saw
	name = "saw bone"
	desc = "Saw through the bone of an opened limb."
	implements = list(TOOL_SAW = 1, TOOL_SHOVEL = 1, ROGUE_IMPLEMENT_SHARP = 1)
	time = 5 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = ALL_SURGERY_BONE_STATES

/datum/surgery_operation/limb/rogue/saw/rogue_chances()
	return list(TOOL_SAW = rogue_value("surgery_saw_saw"), TOOL_SHOVEL = rogue_value("surgery_saw_shovel"), ROGUE_IMPLEMENT_SHARP = rogue_value("surgery_saw_sharp"))

/datum/surgery_operation/limb/rogue/saw/rogue_time()
	return rogue_value("surgery_saw_time")

/datum/surgery_operation/limb/rogue/saw/rogue_skill_min()
	return rogue_value("surgery_saw_skill_min")

/datum/surgery_operation/limb/rogue/saw/rogue_skill_median()
	return rogue_value("surgery_saw_skill_median")

/datum/surgery_operation/limb/rogue/saw/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "saw_bones")

/// Ratwood surgery_flags_blocked SURGERY_BROKEN: a bone already broken is not sawn.
/datum/surgery_operation/limb/rogue/saw/state_check(obj/item/bodypart/limb)
	return ..() && LIMB_HAS_BONES(limb) && !limb.rogue_broken_bone()

/datum/surgery_operation/limb/rogue/saw/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to saw through the bone in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to saw through the bone in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins to saw through the bone in [FORMAT_LIMB_OWNER(limb)]."))

/// Ratwood ignores critical resistance here: a proper surgical procedure, not a crit.
/datum/surgery_operation/limb/rogue/saw/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I saw [FORMAT_LIMB_OWNER(limb)] open."),
		span_notice("[surgeon] saws [FORMAT_LIMB_OWNER(limb)] open!"),
		span_notice("[surgeon] saws [FORMAT_LIMB_OWNER(limb)] open!"))
	if(HAS_TRAIT(limb.owner, TRAIT_NOPAIN))
		rogue_surgery_cry(limb.owner, "groan")
	limb.force_wound_upwards(/datum/wound/blunt/bone/critical, wound_source = "surgery")
	if(!QDELETED(limb) && !LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
		limb.add_surgical_state(SURGERY_BONE_SAWED)

/// Ratwood /datum/surgery_step/amputate: an opened limb with its bone broken is cut off. It leaves no bleeding stump: the
/// limb comes off as surgery takes it (Ratwood drop_limb()).
/datum/surgery_operation/limb/rogue/amputate
	name = "amputate"
	desc = "Sever an opened limb whose bone is broken."
	implements = list(TOOL_SCALPEL = 1, TOOL_SAW = 1, ROGUE_IMPLEMENT_SHARP = 1)
	time = 6.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	rogue_zones = ROGUE_SURGERY_SEVERABLE_ZONES

/datum/surgery_operation/limb/rogue/amputate/rogue_chances()
	return list(TOOL_SCALPEL = rogue_value("surgery_amputate_scalpel"), TOOL_SAW = rogue_value("surgery_amputate_saw"), ROGUE_IMPLEMENT_SHARP = rogue_value("surgery_amputate_sharp"))

/datum/surgery_operation/limb/rogue/amputate/rogue_time()
	return rogue_value("surgery_amputate_time")

/datum/surgery_operation/limb/rogue/amputate/rogue_skill_min()
	return rogue_value("surgery_amputate_skill_min")

/datum/surgery_operation/limb/rogue/amputate/rogue_skill_median()
	return rogue_value("surgery_amputate_skill_median")

/datum/surgery_operation/limb/rogue/amputate/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "amputate")

/// Ratwood surgery_flags SURGERY_INCISED | SURGERY_BROKEN: the bone is broken or sawn.
/datum/surgery_operation/limb/rogue/amputate/state_check(obj/item/bodypart/limb)
	if(!..() || (limb.bodypart_flags & BODYPART_UNREMOVABLE) || HAS_TRAIT(limb.owner, TRAIT_NODISMEMBER))
		return FALSE
	return LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED) || limb.rogue_broken_bone()

/datum/surgery_operation/limb/rogue/amputate/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to sever [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to sever [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] begins to sever [FORMAT_LIMB_OWNER(limb)]!"))

/datum/surgery_operation/limb/rogue/amputate/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	display_results(surgeon, patient, span_notice("I sever [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] severs [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] severs [FORMAT_LIMB_OWNER(limb)]!"))
	log_combat(surgeon, patient, "amputated", isitem(tool) ? tool : null, "([limb.plaintext_zone])")
	limb.drop_limb()

/// Ratwood /datum/surgery_step/relocate_bone: a dislocated joint is put back in place, through clothes, without a cut.
/datum/surgery_operation/limb/rogue/relocate
	name = "relocate bones"
	desc = "Put a dislocated joint back in place."
	implements = list(TOOL_BONESET = 1, IMPLEMENT_HAND = 1)
	time = 6.4 SECONDS
	operation_flags = OPERATION_LOCKED | OPERATION_NO_WIKI | OPERATION_SELF_OPERABLE | OPERATION_STANDING_ALLOWED | OPERATION_IGNORE_CLOTHES

/datum/surgery_operation/limb/rogue/relocate/rogue_chances()
	return list(TOOL_BONESET = rogue_value("surgery_relocate_bonesetter"), IMPLEMENT_HAND = rogue_value("surgery_relocate_hand"))

/datum/surgery_operation/limb/rogue/relocate/rogue_time()
	return rogue_value("surgery_relocate_time")

/datum/surgery_operation/limb/rogue/relocate/rogue_skill_min()
	return rogue_value("surgery_relocate_skill_min")

/datum/surgery_operation/limb/rogue/relocate/rogue_skill_median()
	return rogue_value("surgery_relocate_skill_median")

/datum/surgery_operation/limb/rogue/relocate/get_default_radial_image()
	return image(/obj/item/rogueweapon/surgery/bonesetter)

/datum/surgery_operation/limb/rogue/relocate/state_check(obj/item/bodypart/limb)
	return ..() && (locate(/datum/wound/blunt/bone/moderate) in limb.wounds)

/datum/surgery_operation/limb/rogue/relocate/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to set the bone in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to relocate the bone in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins to relocate the bone in [FORMAT_LIMB_OWNER(limb)]."))

/datum/surgery_operation/limb/rogue/relocate/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I successfully relocate the bone in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] successfully relocates the bone in [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] successfully relocates the bone in [FORMAT_LIMB_OWNER(limb)]!"))
	for(var/datum/wound/blunt/bone/moderate/dislocation in LAZYCOPY(limb.wounds))
		qdel(dislocation)

/// Ratwood /datum/surgery_step/set_bone: the broken bones of an opened limb are set; they mend a part at once, the rest by
/// themselves and in sleep (combat/surgery/wounds.dm).
/datum/surgery_operation/limb/rogue/set_bone
	name = "set bones"
	desc = "Set the broken bones of an opened limb, so that they mend."
	implements = list(TOOL_BONESET = 1, IMPLEMENT_HAND = 1)
	time = 6.4 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/rogue/set_bone/rogue_chances()
	return list(TOOL_BONESET = rogue_value("surgery_set_bone_bonesetter"), IMPLEMENT_HAND = rogue_value("surgery_set_bone_hand"))

/datum/surgery_operation/limb/rogue/set_bone/rogue_time()
	return rogue_value("surgery_set_bone_time")

/datum/surgery_operation/limb/rogue/set_bone/rogue_skill_min()
	return rogue_value("surgery_set_bone_skill_min")

/datum/surgery_operation/limb/rogue/set_bone/rogue_skill_median()
	return rogue_value("surgery_set_bone_skill_median")

/datum/surgery_operation/limb/rogue/set_bone/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "fix_bones")

/datum/surgery_operation/limb/rogue/set_bone/state_check(obj/item/bodypart/limb)
	return ..() && limb.rogue_settable_bone()

/datum/surgery_operation/limb/rogue/set_bone/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to set the bone in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to set the bone in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins to set the bone in [FORMAT_LIMB_OWNER(limb)]."))

/datum/surgery_operation/limb/rogue/set_bone/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I successfully set the bone in [FORMAT_LIMB_OWNER(limb)], they'll need to rest to fully heal now."),
		span_notice("[surgeon] successfully sets the bone in [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] successfully sets the bone in [FORMAT_LIMB_OWNER(limb)]!"))
	for(var/datum/wound/wound as anything in LAZYCOPY(limb.wounds))
		if(!QDELETED(wound))
			wound.rogue_set_bone()

/// Ratwood /datum/surgery_step/cutvein: with the bleeders clamped, a vein of an arm or a leg is opened for the bloodletting.
/datum/surgery_operation/limb/rogue/cut_vein
	name = "cut vein"
	desc = "Open a vein of a clamped limb, to let the bad blood out."
	implements = list(TOOL_SCALPEL = 1, ROGUE_IMPLEMENT_SHARP = 1)
	time = 5 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	all_surgery_states_required = SURGERY_VESSELS_CLAMPED
	rogue_zones = ROGUE_SURGERY_LIMB_ZONES

/datum/surgery_operation/limb/rogue/cut_vein/rogue_chances()
	return list(TOOL_SCALPEL = rogue_value("surgery_cut_vein_scalpel"), ROGUE_IMPLEMENT_SHARP = rogue_value("surgery_cut_vein_sharp"))

/datum/surgery_operation/limb/rogue/cut_vein/rogue_time()
	return rogue_value("surgery_cut_vein_time")

/datum/surgery_operation/limb/rogue/cut_vein/rogue_skill_min()
	return rogue_value("surgery_cut_vein_skill_min")

/datum/surgery_operation/limb/rogue/cut_vein/rogue_skill_median()
	return rogue_value("surgery_cut_vein_skill_median")

/datum/surgery_operation/limb/rogue/cut_vein/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "incise_organs")

/datum/surgery_operation/limb/rogue/cut_vein/state_check(obj/item/bodypart/limb)
	return ..() && !(locate(/datum/wound/rogue/vein) in limb.wounds)

/datum/surgery_operation/limb/rogue/cut_vein/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to cut [limb.owner]'s vein on [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to cut [limb.owner]'s vein on [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to cut [limb.owner]'s vein on [limb.plaintext_zone]."))

/datum/surgery_operation/limb/rogue/cut_vein/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	limb.rogue_surgery_wound(/datum/wound/rogue/vein, "bloodletting")
	display_results(surgeon, limb.owner, span_notice("Blood drips out of the cut vein in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("Blood drips out of the cut vein in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("Blood drips out of the cut vein in [FORMAT_LIMB_OWNER(limb)]."))

/// Ratwood /datum/surgery_step/bloodlet: the bad blood is forced out of the cut vein by hand, and toxins with it.
/datum/surgery_operation/limb/rogue/bloodlet
	name = "force out bad blood"
	desc = "Force the bad blood out of a cut vein, and the toxins with it."
	implements = list(IMPLEMENT_HAND = 1)
	time = 6.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/organ1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	rogue_zones = ROGUE_SURGERY_LIMB_ZONES

/datum/surgery_operation/limb/rogue/bloodlet/rogue_chances()
	return list(IMPLEMENT_HAND = rogue_value("surgery_bloodlet_hand"))

/datum/surgery_operation/limb/rogue/bloodlet/rogue_time()
	return rogue_value("surgery_bloodlet_time")

/datum/surgery_operation/limb/rogue/bloodlet/rogue_skill_min()
	return rogue_value("surgery_bloodlet_skill_min")

/datum/surgery_operation/limb/rogue/bloodlet/rogue_skill_median()
	return rogue_value("surgery_bloodlet_skill_median")

/datum/surgery_operation/limb/rogue/bloodlet/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "unclamp_bleeders")

/// Ratwood surgery_flags SURGERY_CUTVEIN: a cut vein on the limb.
/datum/surgery_operation/limb/rogue/bloodlet/state_check(obj/item/bodypart/limb)
	return ..() && (locate(/datum/wound/rogue/vein) in limb.wounds)

/datum/surgery_operation/limb/rogue/bloodlet/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to force the blood out of [limb.owner]'s vein in [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to force the blood out of [limb.owner]'s vein in [limb.plaintext_zone]!"),
		span_notice("[surgeon] begins to force the blood out of [limb.owner]'s vein in [limb.plaintext_zone]!"))

/datum/surgery_operation/limb/rogue/bloodlet/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	display_results(surgeon, patient, span_notice("I force blood out of [patient]'s vein in [limb.plaintext_zone]."),
		span_notice("[surgeon] forces blood out of [patient]'s vein in [limb.plaintext_zone]!"),
		span_notice("[surgeon] forces blood out of [patient]'s vein in [limb.plaintext_zone]!"))
	patient.adjust_tox_loss(-rogue_value("surgery_bloodlet_toxin"))
	patient.adjust_blood_volume(-rogue_value("surgery_bloodlet_blood"))

/// Ratwood /datum/surgery_step/remove_object: through an incision, everything lodged in the limb is taken out, the leeches on
/// it too.
/datum/surgery_operation/limb/rogue/remove_object
	name = "remove embedded objects"
	desc = "Take out what is lodged in a limb, through an incision."
	implements = list(TOOL_HEMOSTAT = 1, ROGUE_TOOL_IMPROVISED_HEMOSTAT = 1, IMPLEMENT_HAND = 1)
	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/organ2.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/rogue/remove_object/rogue_chances()
	return list(TOOL_HEMOSTAT = rogue_value("surgery_remove_object_hemostat"), ROGUE_TOOL_IMPROVISED_HEMOSTAT = rogue_value("surgery_remove_object_improvised"), IMPLEMENT_HAND = rogue_value("surgery_remove_object_hand"))

/datum/surgery_operation/limb/rogue/remove_object/rogue_time()
	return rogue_value("surgery_remove_object_time")

/datum/surgery_operation/limb/rogue/remove_object/rogue_skill_min()
	return rogue_value("surgery_remove_object_skill_min")

/datum/surgery_operation/limb/rogue/remove_object/rogue_skill_median()
	return rogue_value("surgery_remove_object_skill_median")

/datum/surgery_operation/limb/rogue/remove_object/get_default_radial_image()
	return image(/obj/item/rogueweapon/surgery/hemostat)

/datum/surgery_operation/limb/rogue/remove_object/state_check(obj/item/bodypart/limb)
	return ..() && (length(limb.embedded_objects) || length(limb.rogue_leeches))

/datum/surgery_operation/limb/rogue/remove_object/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I look for objects embedded in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] looks for objects embedded in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] looks for something in [FORMAT_LIMB_OWNER(limb)]."))

/datum/surgery_operation/limb/rogue/remove_object/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	var/objects = 0
	for(var/obj/item/embedded as anything in LAZYCOPY(limb.embedded_objects))
		objects++
		patient.remove_embedded_object(embedded)
	for(var/obj/item/natural/worms/leech/leech as anything in LAZYCOPY(limb.rogue_leeches))
		objects++
		leech.rogue_drop_off()
	if(!objects)
		to_chat(surgeon, span_warning("I find no objects embedded in [FORMAT_LIMB_OWNER(limb)]!"))
		return
	var/plural = objects > 1 ? "s" : ""
	display_results(surgeon, patient, span_notice("I successfully remove [objects] object[plural] from [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] successfully removes [objects] object[plural] from [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] successfully removes [objects] object[plural] from [FORMAT_LIMB_OWNER(limb)]!"))

/// Ratwood /datum/surgery_step/mouth_to_mouth: lying, choking from want of air, the patient is breathed for, breath after
/// breath, by hand on the help intent and the mouth aimed at; not by one who does not breathe, nor on oneself.
/datum/surgery_operation/limb/rogue/mouth_to_mouth
	name = "mouth to mouth"
	desc = "Breathe air into the lungs of a patient who chokes."
	implements = list(IMPLEMENT_HAND = 1)
	time = 3 SECONDS
	operation_flags = OPERATION_LOCKED | OPERATION_NO_WIKI | OPERATION_LOOPING
	rogue_zones = list(BODY_ZONE_HEAD)

/datum/surgery_operation/limb/rogue/mouth_to_mouth/rogue_chances()
	return list(IMPLEMENT_HAND = rogue_value("surgery_cpr_hand"))

/datum/surgery_operation/limb/rogue/mouth_to_mouth/rogue_time()
	return rogue_value("surgery_cpr_time")

/datum/surgery_operation/limb/rogue/mouth_to_mouth/rogue_skill_min()
	return rogue_value("surgery_cpr_skill_min")

/datum/surgery_operation/limb/rogue/mouth_to_mouth/rogue_skill_median()
	return rogue_value("surgery_cpr_skill_median")

/datum/surgery_operation/limb/rogue/mouth_to_mouth/get_default_radial_image()
	return get_generic_limb_radial_image(BODY_ZONE_PRECISE_MOUTH)

/datum/surgery_operation/limb/rogue/mouth_to_mouth/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	if(operated_zone != BODY_ZONE_PRECISE_MOUTH || limb.owner.get_oxy_loss() <= 0 || HAS_TRAIT(surgeon, TRAIT_NOBREATH))
		return FALSE
	if(!istype(surgeon.rogue_active_intent(), /datum/intent/unarmed/help))
		return FALSE
	return ..()

/datum/surgery_operation/limb/rogue/mouth_to_mouth/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I attempt to breathe air into [limb.owner]'s mouth."),
		span_notice("[surgeon] attempts to breathe air into [limb.owner]'s mouth."),
		span_notice("[surgeon] attempts to breathe air into [limb.owner]'s mouth."))

/datum/surgery_operation/limb/rogue/mouth_to_mouth/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I fill [limb.owner]'s lungs with a breath of air."),
		span_notice("[surgeon] gives [limb.owner] a breath of air."),
		span_notice("[surgeon] gives [limb.owner] a breath of air."))
	limb.owner.adjust_oxy_loss(-rogue_value("surgery_cpr_oxygen"))

/// Ratwood mouth_to_mouth failure(): no air gets in, and that is all.
/datum/surgery_operation/limb/rogue/mouth_to_mouth/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	operation_args[ROGUE_OPERATION_FAILED] = TRUE
	display_results(surgeon, limb.owner, span_warning("I failed!"), span_warning("[surgeon] failed!"),
		span_notice("[surgeon] failed to get air into [limb.owner]'s lungs."), TRUE)

/// Ratwood repeating: breath after breath, while the patient still chokes, until a breath fails; each breath is rolled anew.
/datum/surgery_operation/limb/rogue/mouth_to_mouth/can_loop(mob/living/patient, obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	if(operation_args[ROGUE_OPERATION_FAILED] || !..())
		return FALSE
	rogue_roll(limb, surgeon, tool, operation_args)
	return TRUE

/// Ratwood /datum/surgery_step/add_prosthetic: a limb is put on a stump - a severed one of the patient's own kind, sewn on
/// after (the replantation bleeds hard until it is), or a prosthetic. A prosthetic can also be put on without surgery
/// (combat/surgery/prosthetics.dm).
/datum/surgery_operation/limb/rogue/attach_limb
	name = "implant limb"
	desc = "Put a limb, or a prosthetic, on the stump of a missing one."
	implements = list(/obj/item/bodypart = 1, /obj/item = 1)
	time = 3 SECONDS
	operation_flags = OPERATION_LOCKED | OPERATION_NO_WIKI | OPERATION_SELF_OPERABLE | OPERATION_STANDING_ALLOWED | OPERATION_IGNORE_CLOTHES
	allow_stumps = TRUE
	rogue_flesh_only = FALSE
	rogue_zones = ROGUE_SURGERY_SEVERABLE_ZONES
	/// Radial options, one for each type of limb.
	var/list/rogue_options

/datum/surgery_operation/limb/rogue/attach_limb/rogue_chances()
	return list(ROGUE_IMPLEMENT_LIMB = rogue_value("surgery_attach_limb"))

/datum/surgery_operation/limb/rogue/attach_limb/rogue_time()
	return rogue_value("surgery_attach_time")

/datum/surgery_operation/limb/rogue/attach_limb/rogue_skill_min()
	return rogue_value("surgery_attach_skill_min")

/datum/surgery_operation/limb/rogue/attach_limb/rogue_skill_median()
	return rogue_value("surgery_attach_skill_median")

/datum/surgery_operation/limb/rogue/attach_limb/rogue_implement(tool)
	return rogue_part_zone(tool) ? ROGUE_IMPLEMENT_LIMB : null

/// The zone the limb in hand is for: a severed limb, or a prosthetic.
/datum/surgery_operation/limb/rogue/attach_limb/proc/rogue_part_zone(tool)
	if(isbodypart(tool))
		var/obj/item/bodypart/part = tool
		return (part.bodypart_flags & BODYPART_STUMP) ? null : part.body_zone
	if(isitem(tool))
		var/obj/item/kit = tool
		return kit.rogue_prosthetic_zone()
	return null

/datum/surgery_operation/limb/rogue/attach_limb/state_check(obj/item/bodypart/limb)
	return IS_STUMP(limb) && ..()

/datum/surgery_operation/limb/rogue/attach_limb/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	if(rogue_part_zone(tool) != limb.body_zone || !surgeon.canUnEquip(tool))
		return FALSE
	if(isbodypart(tool))
		var/obj/item/bodypart/part = tool
		if(!part.can_attach_limb(limb.owner))
			return FALSE
	return ..()

/datum/surgery_operation/limb/rogue/attach_limb/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	var/key = "[tool.type]-[tool.name]"
	var/datum/radial_menu_choice/option = LAZYACCESS(rogue_options, key)
	if(!option)
		option = new()
		option.name = "implant [tool.name]"
		option.info = "Put [tool.name] on the stump of the patient's missing limb."
		option.image = image(icon = tool.icon, icon_state = tool.icon_state)
		LAZYSET(rogue_options, key, option)
	return option

/datum/surgery_operation/limb/rogue/attach_limb/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to replace [limb.owner]'s [limb.plaintext_zone] with [tool]..."),
		span_notice("[surgeon] begins to replace [limb.owner]'s [limb.plaintext_zone] with [tool]."),
		span_notice("[surgeon] begins to replace [limb.owner]'s [limb.plaintext_zone]."))

/datum/surgery_operation/limb/rogue/attach_limb/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	var/obj/item/part = tool
	if(!surgeon.temporarilyRemoveItemFromInventory(part))
		return
	var/obj/item/bodypart/new_limb = rogue_attach_part(part, patient)
	if(!new_limb)
		to_chat(surgeon, span_warning("[patient]'s body rejects [part]!"))
		return
	display_results(surgeon, patient, span_notice("I succeed transplanting [patient]'s [new_limb.plaintext_zone]."),
		span_notice("[surgeon] successfully transplants [patient]'s [new_limb.plaintext_zone] with [new_limb]!"),
		span_notice("[surgeon] successfully transplants [patient]'s [new_limb.plaintext_zone]!"))

/// Ratwood /datum/surgery_step/replace_limb (augmentation): an opened limb with its bone broken is taken off and a prosthetic
/// put in its place.
/datum/surgery_operation/limb/rogue/replace_limb
	name = "replace limb"
	desc = "Replace an opened limb whose bone is broken with a prosthetic."
	implements = list(/obj/item/bodypart = 1, /obj/item = 1)
	time = 3.2 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	rogue_zones = ROGUE_SURGERY_LIMB_ZONES
	/// Radial options, one for each type of prosthetic.
	var/list/rogue_options

/datum/surgery_operation/limb/rogue/replace_limb/rogue_chances()
	return list(ROGUE_IMPLEMENT_LIMB = rogue_value("surgery_replace_limb"))

/datum/surgery_operation/limb/rogue/replace_limb/rogue_time()
	return rogue_value("surgery_replace_time")

/datum/surgery_operation/limb/rogue/replace_limb/rogue_skill_min()
	return rogue_value("surgery_replace_skill_min")

/datum/surgery_operation/limb/rogue/replace_limb/rogue_skill_median()
	return rogue_value("surgery_replace_skill_median")

/datum/surgery_operation/limb/rogue/replace_limb/rogue_implement(tool)
	return rogue_prosthetic_zone_of(tool) ? ROGUE_IMPLEMENT_LIMB : null

/// Ratwood "That's not an augment, silly!": only a prosthetic replaces a limb - one made of wood or metal, not flesh.
/datum/surgery_operation/limb/rogue/replace_limb/proc/rogue_prosthetic_zone_of(tool)
	if(isbodypart(tool))
		var/obj/item/bodypart/part = tool
		return ((part.biological_state & BIO_FLESH) || (part.bodypart_flags & BODYPART_STUMP)) ? null : part.body_zone
	if(isitem(tool))
		var/obj/item/kit = tool
		return kit.rogue_prosthetic_zone()
	return null

/datum/surgery_operation/limb/rogue/replace_limb/state_check(obj/item/bodypart/limb)
	if(!..() || (limb.bodypart_flags & BODYPART_UNREMOVABLE))
		return FALSE
	return LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED) || limb.rogue_broken_bone()

/datum/surgery_operation/limb/rogue/replace_limb/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	if(rogue_prosthetic_zone_of(tool) != limb.body_zone || !surgeon.canUnEquip(tool))
		return FALSE
	return ..()

/datum/surgery_operation/limb/rogue/replace_limb/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	var/key = "[tool.type]-[tool.name]"
	var/datum/radial_menu_choice/option = LAZYACCESS(rogue_options, key)
	if(!option)
		option = new()
		option.name = "replace with [tool.name]"
		option.info = "Take off the patient's broken limb and put [tool.name] in its place."
		option.image = image(icon = tool.icon, icon_state = tool.icon_state)
		LAZYSET(rogue_options, key, option)
	return option

/datum/surgery_operation/limb/rogue/replace_limb/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to augment [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to augment [FORMAT_LIMB_OWNER(limb)] with [tool]."),
		span_notice("[surgeon] begins to augment [FORMAT_LIMB_OWNER(limb)]."))

/datum/surgery_operation/limb/rogue/replace_limb/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	var/obj/item/part = tool
	if(!surgeon.temporarilyRemoveItemFromInventory(part))
		return
	var/obj/item/bodypart/new_limb = isbodypart(part) ? part : part.rogue_make_prosthetic_limb()
	if(!new_limb || !new_limb.replace_limb(patient))
		if(new_limb && new_limb != part)
			part.forceMove(patient.drop_location())
			qdel(new_limb)
		else
			part.forceMove(patient.drop_location())
		to_chat(surgeon, span_warning("[patient]'s body rejects [part]!"))
		return
	display_results(surgeon, patient, span_notice("I successfully augment [patient]'s [new_limb.plaintext_zone]."),
		span_notice("[surgeon] successfully augments [patient]'s [new_limb.plaintext_zone] with [new_limb]!"),
		span_notice("[surgeon] successfully augments [patient]'s [new_limb.plaintext_zone]!"))
	log_combat(surgeon, patient, "augmented", new_limb, "([new_limb.plaintext_zone])")

/// Ratwood /datum/surgery_step/remove_prosthetic: a prosthetic is sawn off at its base, back into the thing it was made from.
/datum/surgery_operation/limb/rogue/remove_prosthetic
	name = "remove prosthetic"
	desc = "Saw a prosthetic off at its base."
	implements = list(TOOL_SAW = 1)
	time = 10 SECONDS
	preop_sound = 'modular_redtard/rockhill/sound/foley/sewflesh.ogg'
	success_sound = 'sound/items/handling/surgery/saw.ogg'
	rogue_flesh_only = FALSE
	rogue_zones = ROGUE_SURGERY_LIMB_ZONES

/datum/surgery_operation/limb/rogue/remove_prosthetic/rogue_chances()
	return list(TOOL_SAW = rogue_value("surgery_remove_prosthetic_saw"))

/datum/surgery_operation/limb/rogue/remove_prosthetic/rogue_time()
	return rogue_value("surgery_remove_prosthetic_time")

/datum/surgery_operation/limb/rogue/remove_prosthetic/rogue_skill_min()
	return rogue_value("surgery_remove_prosthetic_skill_min")

/datum/surgery_operation/limb/rogue/remove_prosthetic/rogue_skill_median()
	return rogue_value("surgery_remove_prosthetic_skill_median")

/datum/surgery_operation/limb/rogue/remove_prosthetic/get_default_radial_image()
	return image(ROGUE_SURGERY_RADIAL, "saw_bones")

/// Ratwood requires_bodypart_type BODYPART_ROBOTIC: a limb of wood or metal.
/datum/surgery_operation/limb/rogue/remove_prosthetic/state_check(obj/item/bodypart/limb)
	if(!..() || (limb.biological_state & BIO_FLESH) || (limb.bodypart_flags & BODYPART_UNREMOVABLE))
		return FALSE
	return limb.bodytype & (BODYTYPE_PEG|BODYTYPE_ROBOTIC)

/datum/surgery_operation/limb/rogue/remove_prosthetic/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to saw through the base of [limb.owner]'s [limb.plaintext_zone] prosthetic..."),
		span_notice("[surgeon] begins to saw through the base of [limb.owner]'s prosthetic [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to saw through the base of [limb.owner]'s prosthetic [limb.plaintext_zone]."))

/datum/surgery_operation/limb/rogue/remove_prosthetic/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I saw through the base of [limb.owner]'s prosthetic [limb.plaintext_zone]."),
		span_notice("[surgeon] saws through the base of [limb.owner]'s prosthetic [limb.plaintext_zone]!"),
		span_notice("[surgeon] saws through the base of [limb.owner]'s prosthetic [limb.plaintext_zone]!"))
	limb.drop_limb()

/// Ratwood's hearth /datum/surgery_step/burn_rot: through an incision in the chest, the rot is burnt out of a body - a corpse
/// rotted or gone to bones is sound flesh again and may be brought back (burial/corpse_rot.dm).
/datum/surgery_operation/limb/rogue/burn_rot
	name = "burn rot"
	desc = "Burn the rot out of a body through an incision in its chest."
	implements = list(TOOL_CAUTERY = 1, /obj/item/clothing/neck/roguetown/psicross = 1, TOOL_WELDER = 1, ROGUE_IMPLEMENT_HOT = 1)
	time = 8 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	rogue_zones = list(BODY_ZONE_CHEST)

/datum/surgery_operation/limb/rogue/burn_rot/rogue_chances()
	return list(TOOL_CAUTERY = rogue_value("surgery_burn_rot_cautery"), /obj/item/clothing/neck/roguetown/psicross = rogue_value("surgery_burn_rot_psicross"), TOOL_WELDER = rogue_value("surgery_burn_rot_welder"), ROGUE_IMPLEMENT_HOT = rogue_value("surgery_burn_rot_hot"))

/datum/surgery_operation/limb/rogue/burn_rot/rogue_time()
	return rogue_value("surgery_burn_rot_time")

/datum/surgery_operation/limb/rogue/burn_rot/rogue_skill_min()
	return rogue_value("surgery_burn_rot_skill_min")

/datum/surgery_operation/limb/rogue/burn_rot/rogue_skill_median()
	return rogue_value("surgery_burn_rot_skill_median")

/datum/surgery_operation/limb/rogue/burn_rot/get_default_radial_image()
	return image(/obj/item/rogueweapon/surgery/cautery)

/datum/surgery_operation/limb/rogue/burn_rot/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(surgeon, limb.owner, span_notice("I begin to burn the rot within [limb.owner]..."),
		span_notice("[surgeon] begins to burn the rot from [limb.owner]'s heart."),
		span_notice("[surgeon] begins to burn the rot from [limb.owner]'s heart."))

/datum/surgery_operation/limb/rogue/burn_rot/rogue_effect(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	if(!patient.rogue_remove_rot())
		to_chat(surgeon, span_warning("The surgery fails to remove the rot."))
		return
	display_results(surgeon, patient, span_notice("I burn away the rot inside of [patient]."),
		span_notice("[surgeon] burns the rot within [patient]."),
		span_notice("[surgeon] takes [tool] to [patient]'s innards."))

/// Ratwood /datum/surgery_step/manipulate_organs, on TG's organ manipulation: through an opened limb (the skull and the chest
/// sawn too, for the brain and the chest's organs) an organ is taken out with forceps, a crowbar or the hand, or one in hand
/// put in. TG's organ choice stays; Ratwood's tools, ranks, chance and fever come with the module's operations.
/datum/surgery_operation/limb/organ_manipulation/internal/rogue
	name = "manipulate organs"
	desc = "Take an organ out of an opened limb, or put one in."
	operation_flags = OPERATION_LOCKED | OPERATION_NO_WIKI | OPERATION_NOTABLE | OPERATION_SELF_OPERABLE | OPERATION_STANDING_ALLOWED
	replaced_by = null
	all_surgery_states_required = SURGERY_SKIN_OPEN
	time = 6.4 SECONDS
	remove_implements = list(TOOL_HEMOSTAT = 1, ROGUE_TOOL_IMPROVISED_HEMOSTAT = 1, TOOL_CROWBAR = 1, IMPLEMENT_HAND = 1)
	insert_implements = list(/obj/item/organ = 1)
	random_item_organ_pool = null
	rogue_medieval = TRUE

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/rogue_chances()
	return list(TOOL_HEMOSTAT = rogue_value("surgery_organs_hemostat"), ROGUE_TOOL_IMPROVISED_HEMOSTAT = rogue_value("surgery_organs_improvised"), TOOL_CROWBAR = rogue_value("surgery_organs_crowbar"), IMPLEMENT_HAND = rogue_value("surgery_organs_hand"), /obj/item/organ = rogue_value("surgery_organs_organ"))

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/rogue_time()
	return rogue_value("surgery_organs_time")

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/rogue_skill_min()
	return rogue_value("surgery_organs_skill_min")

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/rogue_skill_median()
	return rogue_value("surgery_organs_skill_median")

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/get_tool_quality(tool = IMPLEMENT_HAND)
	return rogue_tool_quality(tool)

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, tool, operated_zone)
	return ..() && rogue_skilled(surgeon)

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	return rogue_speed(limb, surgeon, tool)

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	if(!..())
		return FALSE
	rogue_roll(limb, surgeon, tool, operation_args)
	return TRUE

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	rogue_learn(surgeon)

/datum/surgery_operation/limb/organ_manipulation/internal/rogue/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	rogue_fail(limb, surgeon, tool, operation_args)

#undef ROGUE_SURGERY_LIMB_ZONES
#undef ROGUE_SURGERY_SEVERABLE_ZONES
#undef ROGUE_SURGERY_RADIAL
