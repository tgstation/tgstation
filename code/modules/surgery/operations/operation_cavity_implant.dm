/datum/surgery_operation/limb/prepare_cavity
	name = "widen chest cavity"
	desc = "Widen a patient's chest cavity to allow for implanting of larger items."
	implements = list(
		TOOL_RETRACTOR = 1,
		TOOL_CROWBAR = 1.5,
	)
	time = 4.8 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	any_surgery_states_blocked = SURGERY_CAVITY_WIDENED

/datum/surgery_operation/limb/prepare_cavity/get_default_radial_image()
	return image(/obj/item/retractor)

/datum/surgery_operation/limb/prepare_cavity/all_required_strings()
	return list("operate on chest (target chest)") + ..()

/datum/surgery_operation/limb/prepare_cavity/state_check(obj/item/bodypart/chest/limb)
	return limb.body_zone == BODY_ZONE_CHEST

/datum/surgery_operation/limb/prepare_cavity/on_preop(obj/item/bodypart/chest/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to open [limb.owner]'s [limb.plaintext_zone] cavity wide..."),
		span_notice("[surgeon] begins to open [limb.owner]'s [limb.plaintext_zone] cavity wide."),
		span_notice("[surgeon] begins to open [limb.owner]'s [limb.plaintext_zone] cavity wide."),
	)
	display_pain(limb.owner, "You can feel pressure as your [limb.plaintext_zone] is being opened wide!")

/datum/surgery_operation/limb/prepare_cavity/on_success(obj/item/bodypart/chest/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_CAVITY_WIDENED)

/datum/surgery_operation/limb/cavity_implant
	name = "cavity implant"
	desc = "Implant an item into a patient's body cavity."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/organ1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_CAVITY_WIDENED
	/// Items that bypass normal size restrictions for cavity implantation
	var/list/heavy_cavity_implants

/datum/surgery_operation/limb/cavity_implant/New()
	. = ..()
	heavy_cavity_implants = typecacheof(list(
		/obj/item/transfer_valve,
	))

/datum/surgery_operation/limb/cavity_implant/all_required_strings()
	return list("operate on chest (target chest)") + ..()

/datum/surgery_operation/limb/cavity_implant/get_default_radial_image()
	return image('icons/hud/screen_gen.dmi', "arrow_large_still")

/datum/surgery_operation/limb/cavity_implant/state_check(obj/item/bodypart/chest/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	if(!isnull(limb.cavity_item))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/snowflake_check_availability(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	// Stops accidentally putting a tool you meant to operate with
	// Besides who really wants to put a scalpel or a wrench inside someone that's lame
	if(IS_ROBOTIC_LIMB(limb) && (tool.tool_behaviour in GLOB.all_mechanical_tools))
		return FALSE
	if(IS_ORGANIC_LIMB(limb) && (tool.tool_behaviour in GLOB.all_surgical_tools))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/cavity_implant/tool_check(obj/item/tool)
	if(tool.w_class > WEIGHT_CLASS_NORMAL && !is_type_in_typecache(tool, heavy_cavity_implants))
		return FALSE
	if(tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM))
		return FALSE
	if(isorgan(tool))
		return FALSE // use organ manipulation
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
	limb.remove_surgical_state(SURGERY_CAVITY_WIDENED)
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
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_CAVITY_WIDENED

/datum/surgery_operation/limb/undo_cavity_implant/all_required_strings()
	return list("operate on chest (target chest)") + ..()

/datum/surgery_operation/limb/undo_cavity_implant/get_default_radial_image()
	return image('icons/hud/screen_gen.dmi', "arrow_large_still")

/datum/surgery_operation/limb/undo_cavity_implant/get_radial_options(obj/item/bodypart/chest/limb, obj/item/tool, operating_zone)
	// Not bothering to cache this as the chance of hitting the same cavity item in the same round is rather low
	var/datum/radial_menu_choice/option = new()
	option.name = "remove [limb.cavity_item]"
	option.info = "Replace the [limb.cavity_item] embededd in the patient's chest cavity."
	option.image = get_generic_limb_radial_image(BODY_ZONE_CHEST)
	option.image.overlays += add_radial_overlays(limb.cavity_item)
	return option

/datum/surgery_operation/limb/undo_cavity_implant/state_check(obj/item/bodypart/chest/limb)
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
	limb.remove_surgical_state(SURGERY_CAVITY_WIDENED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You pull [implant] out of [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] pulls [implant] out of [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] pulls something out of [limb.owner]'s [limb.plaintext_zone]!"),
	)
	display_pain(limb.owner, "You can feel [implant.name] being pulled out of you!")
	surgeon.put_in_hands(implant)
