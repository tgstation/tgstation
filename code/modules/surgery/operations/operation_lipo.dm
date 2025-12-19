/datum/surgery_operation/limb/lipoplasty
	name = "excise excess fat"
	rnd_name = "Lipoplasty (Excise Fat)"
	desc = "Remove excess fat from a patient's body."
	operation_flags = OPERATION_NOTABLE | OPERATION_AFFECTS_MOOD
	implements = list(
		TOOL_SAW = 1,
		TOOL_SCALPEL = 1.25,
		/obj/item/shovel/serrated = 1.33,
		/obj/item/melee/energy/sword = 1.33,
		/obj/item/hatchet = 3.33,
		/obj/item/knife = 3.33,
		/obj/item = 5,
	)
	time = 6.4 SECONDS
	required_bodytype = ~BODYTYPE_ROBOTIC
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item = 'sound/items/handling/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/limb/lipoplasty/get_any_tool()
	return "Any sharp edged item"

/datum/surgery_operation/limb/lipoplasty/get_default_radial_image()
	return image(/obj/item/food/meat/slab/human)

/datum/surgery_operation/limb/lipoplasty/all_required_strings()
	. = list()
	. += "operate on chest (target chest)"
	. += ..()
	. += "the patient must have excess fat to remove"

/datum/surgery_operation/limb/lipoplasty/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match
	return ((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/lipoplasty/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	if(!HAS_TRAIT_FROM(limb.owner, TRAIT_FAT, OBESITY) && limb.owner.nutrition < NUTRITION_LEVEL_WELL_FED)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/lipoplasty/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to cut away [limb.owner]'s excess fat..."),
		span_notice("[surgeon] begins to cut away [limb.owner]'s excess fat."),
		span_notice("[surgeon] begins to cut [limb.owner]'s [limb.plaintext_zone] with [tool]."),
	)
	display_pain(limb.owner, "You feel a stabbing in your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/lipoplasty/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully remove excess fat from [limb.owner]'s body!"),
		span_notice("[surgeon] successfully removes excess fat from [limb.owner]'s body!"),
		span_notice("[surgeon] finishes cutting away excess fat from [limb.owner]'s [limb.plaintext_zone]."),
	)
	limb.owner.overeatduration = 0 //patient is unfatted
	var/removednutriment = limb.owner.nutrition
	limb.owner.set_nutrition(NUTRITION_LEVEL_WELL_FED)
	removednutriment -= NUTRITION_LEVEL_WELL_FED //whatever was removed goes into the meat

	var/typeofmeat = /obj/item/food/meat/slab/human
	if(limb.owner.flags_1 & HOLOGRAM_1)
		typeofmeat = null
	else if(limb.owner.dna?.species)
		typeofmeat = limb.owner.dna.species.meat

	if(!typeofmeat)
		return

	var/obj/item/food/meat/slab/newmeat = new typeofmeat()
	newmeat.name = "fatty meat"
	newmeat.desc = "Extremely fatty tissue taken from a patient."
	newmeat.subjectname = limb.owner.real_name
	newmeat.subjectjob = limb.owner.job
	newmeat.reagents.add_reagent(/datum/reagent/consumable/nutriment, (removednutriment / 15)) //To balance with nutriment_factor of nutriment
	newmeat.forceMove(limb.owner.drop_location())

/datum/surgery_operation/limb/lipoplasty/mechanic
	name = "engage expulsion valve" //gross
	rnd_name = "Nutrient Reserve Expulsion (Excise Fat)"
	implements = list(
		TOOL_WRENCH = 1.05,
		TOOL_CROWBAR = 1.05,
		/obj/item/shovel/serrated = 1.33,
		/obj/item/melee/energy/sword = 1.33,
		TOOL_SAW = 1.67,
		/obj/item/hatchet = 3.33,
		/obj/item/knife = 3.33,
		TOOL_SCALPEL = 4,
		/obj/item = 5,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
