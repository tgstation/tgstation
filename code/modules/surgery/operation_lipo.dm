/datum/surgery_operation/limb/lipoplasty
	name = "lipoplasty"
	desc = "Remove excess fat from a patient's body."
	implements = list(
		TOOL_SAW = 1,
		TOOL_SCALPEL = 0.8,
		/obj/item/shovel/serrated = 0.75,
		/obj/item/melee/energy/sword = 0.75,
		/obj/item/hatchet = 0.3,
		/obj/item/knife = 0.3,
		/obj/item = 0.2,
	)
	required_bodytype = BODYTYPE_ORGANIC
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item = 'sound/items/handling/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_operation/limb/lipoplasty/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(list(/obj/item/food/meat/slab/human, /obj/item/scalpel))
	return base

/datum/surgery_operation/limb/lipoplasty/tool_check(obj/item/tool)
	// Require sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/lipoplasty/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
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
	implements = list(
		TOOL_WRENCH = 0.95,
		TOOL_CROWBAR = 0.95,
		/obj/item/shovel/serrated = 0.75,
		/obj/item/melee/energy/sword = 0.75,
		TOOL_SAW = 0.6,
		/obj/item/hatchet = 0.3,
		/obj/item/knife = 0.3,
		TOOL_SCALPEL = 0.25,
		/obj/item = 0.2,
	)
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	required_bodytype = BODYTYPE_ROBOTIC
