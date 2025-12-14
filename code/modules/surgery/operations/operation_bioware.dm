/datum/surgery_operation/limb/bioware
	abstract_type = /datum/surgery_operation/limb/bioware
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_MORBID | OPERATION_LOCKED
	required_bodytype = ~BODYTYPE_ROBOTIC
	time = 12.5 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED|SURGERY_ORGANS_CUT
	/// What status effect is gained when the surgery is successful?
	/// Used to check against other bioware types to prevent stacking.
	var/datum/status_effect/status_effect_gained = /datum/status_effect/bioware
	/// Zone to operate on for this bioware
	var/required_zone = BODY_ZONE_CHEST

/datum/surgery_operation/limb/bioware/get_default_radial_image()
	return image('icons/hud/implants.dmi', "lighting_bolt")

/datum/surgery_operation/limb/bioware/all_required_strings()
	return list("operate on [parse_zone(required_zone)] (target [parse_zone(required_zone)])") + ..()

/datum/surgery_operation/limb/bioware/all_blocked_strings()
	var/list/incompatible_surgeries = list()
	for(var/datum/surgery_operation/limb/bioware/other_bioware as anything in subtypesof(/datum/surgery_operation/limb/bioware))
		if(other_bioware::status_effect_gained::id != status_effect_gained::id)
			continue
		if(other_bioware::required_bodytype != required_bodytype)
			continue
		incompatible_surgeries += (other_bioware.rnd_name || other_bioware.name)

	return ..() + list("the patient must not have undergone [english_list(incompatible_surgeries, and_text = " OR ")] prior")

/datum/surgery_operation/limb/bioware/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != required_zone)
		return FALSE
	if(limb.owner.has_status_effect(status_effect_gained))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/bioware/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	limb.owner.apply_status_effect(status_effect_gained)
	if(limb.owner.ckey)
		SSblackbox.record_feedback("tally", "bioware", 1, status_effect_gained)

/datum/surgery_operation/limb/bioware/vein_threading
	name = "thread veins"
	rnd_name = "Symvasculodesis (Vein Threading)" // "together vessel fusion"
	desc = "Weave a patient's veins into a reinforced mesh, reducing blood loss from injuries."
	status_effect_gained = /datum/status_effect/bioware/heart/threaded_veins

/datum/surgery_operation/limb/bioware/vein_threading/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start weaving [limb.owner]'s blood vessels."),
		span_notice("[surgeon] starts weaving [limb.owner]'s blood vessels."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s blood vessels."),
	)
	display_pain(limb.owner, "Your entire body burns in agony!")

/datum/surgery_operation/limb/bioware/vein_threading/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You weave [limb.owner]'s blood vessels into a resistant mesh!"),
		span_notice("[surgeon] weaves [limb.owner]'s blood vessels into a resistant mesh!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s blood vessels."),
	)
	display_pain(limb.owner, "You can feel your blood pumping through reinforced veins!")

/datum/surgery_operation/limb/bioware/vein_threading/mechanic
	rnd_name = "Hydraulics Routing Optimization (Threaded Veins)"
	desc = "Optimize the routing of a robotic patient's hydraulic system, reducing fluid loss from leaks."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/muscled_veins
	name = "muscled veins"
	rnd_name = "Myovasculoplasty (Muscled Veins)" // "muscle vessel reshaping"
	desc = "Add a muscled membrane to a patient's veins, allowing them to pump blood without a heart."
	status_effect_gained = /datum/status_effect/bioware/heart/muscled_veins

/datum/surgery_operation/limb/bioware/muscled_veins/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start wrapping muscles around [limb.owner]'s blood vessels."),
		span_notice("[surgeon] starts wrapping muscles around [limb.owner]'s blood vessels."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s blood vessels."),
	)
	display_pain(limb.owner, "Your entire body burns in agony!")

/datum/surgery_operation/limb/bioware/muscled_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You reshape [limb.owner]'s blood vessels, adding a muscled membrane!"),
		span_notice("[surgeon] reshapes [limb.owner]'s blood vessels, adding a muscled membrane!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s blood vessels."),
	)
	display_pain(limb.owner, "You can feel your heartbeat's powerful pulses ripple through your body!")

/datum/surgery_operation/limb/bioware/muscled_veins/mechanic
	rnd_name = "Hydraulics Redundancy Subroutine (Muscled Veins)"
	desc = "Add redundancies to a robotic patient's hydraulic system, allowing it to pump fluids without an engine or pump."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/nerve_splicing
	name = "splice nerves"
	rnd_name = "Symneurodesis (Spliced Nerves)" // "together nerve fusion"
	desc = "Splice a patient's nerves together to make them more resistant to stuns."
	time = 15.5 SECONDS
	status_effect_gained = /datum/status_effect/bioware/nerves/spliced

/datum/surgery_operation/limb/bioware/nerve_splicing/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start splicing together [limb.owner]'s nerves."),
		span_notice("[surgeon] starts splicing together [limb.owner]'s nerves."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s nervous system."),
	)
	display_pain(limb.owner, "Your entire body goes numb!")

/datum/surgery_operation/limb/bioware/nerve_splicing/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully splice [limb.owner]'s nervous system!"),
		span_notice("[surgeon] successfully splices [limb.owner]'s nervous system!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s nervous system."),
	)
	display_pain(limb.owner, "You regain feeling in your body; It feels like everything's happening around you in slow motion!")

/datum/surgery_operation/limb/bioware/nerve_splicing/mechanic
	rnd_name = "System Automatic Reset Subroutine (Spliced Nerves)"
	desc = "Upgrade a robotic patient's automatic systems, allowing it to better resist stuns."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/nerve_grounding
	name = "ground nerves"
	rnd_name = "Xanthoneuroplasty (Grounded Nerves)" // "yellow nerve reshaping". see: yellow gloves
	desc = "Reroute a patient's nerves to act as grounding rods, protecting them from electrical shocks."
	time = 15.5 SECONDS
	status_effect_gained = /datum/status_effect/bioware/nerves/grounded

/datum/surgery_operation/limb/bioware/nerve_grounding/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start rerouting [limb.owner]'s nerves."),
		span_notice("[surgeon] starts rerouting [limb.owner]'s nerves."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s nervous system."),
	)
	display_pain(limb.owner, "Your entire body goes numb!")

/datum/surgery_operation/limb/bioware/nerve_grounding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully reroute [limb.owner]'s nervous system!"),
		span_notice("[surgeon] successfully reroutes [limb.owner]'s nervous system!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s nervous system."),
	)
	display_pain(limb.owner, "You regain feeling in your body! You feel energized!")

/datum/surgery_operation/limb/bioware/nerve_grounding/mechanic
	rnd_name = "System Shock Dampening (Grounded Nerves)"
	desc = "Install grounding rods into a robotic patient's nervous system, protecting it from electrical shocks."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/ligament_hook
	name = "reshape ligaments"
	rnd_name = "Arthroplasty (Ligament Hooks)" // "joint reshaping"
	desc = "Reshape a patient's ligaments to allow limbs to be manually reattached if severed - at the cost of making them easier to detach."
	status_effect_gained = /datum/status_effect/bioware/ligaments/hooked

/datum/surgery_operation/limb/bioware/ligament_hook/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start reshaping [limb.owner]'s ligaments into a hook-like shape."),
		span_notice("[surgeon] starts reshaping [limb.owner]'s ligaments into a hook-like shape."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s ligaments."),
	)
	display_pain(limb.owner, "Your limbs burn with severe pain!")

/datum/surgery_operation/limb/bioware/ligament_hook/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You reshape [limb.owner]'s ligaments into a connective hook!"),
		span_notice("[surgeon] reshapes [limb.owner]'s ligaments into a connective hook!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s ligaments."),
	)
	display_pain(limb.owner, "Your limbs feel... strangely loose.")

/datum/surgery_operation/limb/bioware/ligament_hook/mechanic
	rnd_name = "Anchor Point Snaplocks (Ligament Hooks)"
	desc = "Refactor a robotic patient's limb joints to allow for rapid deatchment, allowing limbs to be manually reattached if severed - \
		at the cost of making them easier to detach as well."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/ligament_reinforcement
	name = "strengthen ligaments"
	rnd_name = "Arthrorrhaphy (Ligament Reinforcement)" // "joint strengthening" / "joint stitching"
	desc = "Strengthen a patient's ligaments to make dismemberment more difficult, at the cost of making nerve connections easier to interrupt."
	status_effect_gained = /datum/status_effect/bioware/ligaments/reinforced

/datum/surgery_operation/limb/bioware/ligament_reinforcement/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start reinforcing [limb.owner]'s ligaments."),
		span_notice("[surgeon] starts reinforcing [limb.owner]'s ligaments."),
		span_notice("[surgeon] starts manipulating [limb.owner]'s ligaments."),
	)
	display_pain(limb.owner, "Your limbs burn with severe pain!")

/datum/surgery_operation/limb/bioware/ligament_reinforcement/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You reinforce [limb.owner]'s ligaments!"),
		span_notice("[surgeon] reinforces [limb.owner]'s ligaments!"),
		span_notice("[surgeon] finishes manipulating [limb.owner]'s ligaments."),
	)
	display_pain(limb.owner, "Your limbs feel more secure, but also more frail.")

/datum/surgery_operation/limb/bioware/ligament_reinforcement/mechanic
	rnd_name = "Anchor Point Reinforcement (Ligament Reinforcement)"
	desc = "Reinforce a robotic patient's limb joints to prevent dismemberment, at the cost of making nerve connections easier to interrupt."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/cortex_folding
	name = "cortex folding"
	rnd_name = "Encephalofractoplasty (Cortex Folding)" // it's a stretch - "brain fractal reshaping"
	desc = "A biological upgrade which folds a patient's cerebral cortex into a fractal pattern, increasing neural density and flexibility."
	status_effect_gained = /datum/status_effect/bioware/cortex/folded
	required_zone = BODY_ZONE_HEAD

/datum/surgery_operation/limb/bioware/cortex_folding/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start folding [limb.owner]'s cerebral cortex."),
		span_notice("[surgeon] starts folding [limb.owner]'s cerebral cortex."),
		span_notice("[surgeon] starts performing surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head throbs with gruesome pain, it's nearly too much to handle!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You fold [limb.owner]'s cerebral cortex into a fractal pattern!"),
		span_notice("[surgeon] folds [limb.owner]'s cerebral cortex into a fractal pattern!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your brain feels stronger... and more flexible!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool)
	if(!limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
		return ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, damaging the brain!"),
		span_warning("[surgeon] screws up, damaging the brain!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head throbs with excruciating pain!")
	limb.owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
	limb.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/limb/bioware/cortex_folding/mechanic
	rnd_name = "Wetware OS Labyrinthian Programming (Cortex Folding)"
	desc = "Reprogram a robotic patient's neural network in a downright eldritch programming language, giving space to non-standard neural patterns."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC

/datum/surgery_operation/limb/bioware/cortex_imprint
	name = "cortex imprinting"
	rnd_name = "Encephalopremoplasty (Cortex Imprinting)" // it's a stretch - "brain print reshaping"
	desc = "A biological upgrade which carves a patient's cerebral cortex into a self-imprinting pattern, increasing neural density and resilience."
	status_effect_gained = /datum/status_effect/bioware/cortex/imprinted
	required_zone = BODY_ZONE_HEAD

/datum/surgery_operation/limb/bioware/cortex_imprint/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You start carving [limb.owner]'s outer cerebral cortex into a self-imprinting pattern."),
		span_notice("[surgeon] starts carving [limb.owner]'s outer cerebral cortex into a self-imprinting pattern."),
		span_notice("[surgeon] starts performing surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head throbs with gruesome pain, it's nearly too much to handle!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You reshape [limb.owner]'s outer cerebral cortex into a self-imprinting pattern!"),
		span_notice("[surgeon] reshapes [limb.owner]'s outer cerebral cortex into a self-imprinting pattern!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your brain feels stronger... and more resilient!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool)
	if(!limb.owner.get_organ_slot(ORGAN_SLOT_BRAIN))
		return ..()
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, damaging the brain!"),
		span_warning("[surgeon] screws up, damaging the brain!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your brain throbs with intense pain; Thinking hurts!")
	limb.owner.adjust_organ_loss(ORGAN_SLOT_BRAIN, 60)
	limb.owner.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/limb/bioware/cortex_imprint/mechanic
	rnd_name = "Wetware OS Ver 2.0 (Cortex Imprinting)"
	desc = "Update a robotic patient's operating system to a \"newer version\", improving overall performance and resilience. \
		Shame about all the adware."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
