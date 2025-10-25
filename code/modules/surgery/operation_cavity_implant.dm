/datum/surgery_operation/limb/cavity_implant
	name = "cavity implant"
	desc = "Implant an item into a patient's body cavity."
	implements = list(
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/organ1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	/// Items that bypass normal size restrictions for cavity implantation
	var/list/heavy_cavity_implants

/datum/surgery_operation/limb/cavity_implant/New()
	. = ..()
	heavy_cavity_implants = typecacheof(list(
		/obj/item/transfer_valve,
	))

/datum/surgery_operation/limb/cavity_implant/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(image('icons/hud/screen_gen.dmi', "arrow_large_still"))
	return base

/datum/surgery_operation/limb/cavity_implant/state_check(obj/item/bodypart/chest/limb)
	if(!HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT))
		return FALSE
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/tool_check(obj/item/tool)
	if(tool.w_class > WEIGHT_CLASS_NORMAL && !is_type_in_typecache(tool, heavy_cavity_implants))
		return FALSE
	if(HAS_TRAIT(tool, TRAIT_NODROP) || (tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM)))
		return FALSE
	if(isorgan(tool)) // you rarely want to implant an organ
		return FALSE
	// if(tool.tool_behaviour in GLOB.all_surgical_tool_behaviours) // you rarely want to implant a medical tool
	// 	return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to insert [tool] into [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to insert [tool] into [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to insert [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "something"] into [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You can feel something being inserted into your [limb.plaintext_zone], it hurts like hell!")

/datum/surgery_operation/limb/cavity_implant/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if (!surgeon.transferItemToLoc(tool, limb.owner, force = TRUE)) // shouldn't fail but just in case
		display_results(
			surgeon,
			limb.owner,
			span_warning("You can't seem to fit [tool] in [limb.owner]'s [limb.plaintext_zone]!"),
			span_warning("[surgeon] can't seem to fit [tool] in [limb.owner]'s [limb.plaintext_zone]!"),
			span_warning("[surgeon] can't seem to fit [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "something"] in [limb.owner]'s [limb.plaintext_zone]!"),
		)
		return

	limb.cavity_item = tool
	display_results(
		surgeon,
		limb.owner,
		span_notice("You stuff [tool] into [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] stuffs [tool] into [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] stuffs [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "something"] into [limb.owner]'s [limb.plaintext_zone]."),
	)

/datum/surgery_operation/limb/undo_cavity_implant
	name = "remove cavity implant"
	desc = "Remove an item from a body cavity."
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_HEMOSTAT = 2,
		TOOL_CROWBAR = 2.5,
		/obj/item/kitchen/fork = 5,
	)

	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/organ1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_operation/limb/undo_cavity_implant/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(list(/obj/item/hemostat, limb.cavity_item))
	return base

/datum/surgery_operation/limb/undo_cavity_implant/state_check(obj/item/bodypart/chest/limb)
	if(!HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT))
		return FALSE
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	// unlike implant removal, don't show the surgery as an option unless something is actually implanted
	// it would stand to reason standard implants would be hidden from view (requires a search)
	// while cavity implants would be blatantly visible (no search necessary)
	if(isnull(limb.cavity_item))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/undo_cavity_implant/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to extract [limb.cavity_item] from [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to extract [limb.cavity_item] from [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to extract something from [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a serious pain in your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/undo_cavity_implant/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(isnull(limb.cavity_item)) // something else could have removed it mid surgery?
		display_results(
			surgeon,
			limb.owner,
			span_warning("You find nothing to remove from [limb.owner]'s [limb.plaintext_zone]."),
			span_warning("[surgeon] finds nothing to remove from [limb.owner]'s [limb.plaintext_zone]."),
			span_warning("[surgeon] finds nothing to remove from [limb.owner]'s [limb.plaintext_zone]."),
		)
		return

	var/obj/item/implant = limb.cavity_item
	limb.cavity_item = null
	display_results(
		surgeon,
		limb.owner,
		span_notice("You pull [implant] out of [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] pulls [implant] out of [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] pulls something out of [limb.owner]'s [limb.plaintext_zone]!"),
	)
	display_pain(limb.owner, "You can feel [implant.name] being pulled out of you!")
	surgeon.put_in_hands(implant)
