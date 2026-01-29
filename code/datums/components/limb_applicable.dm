/datum/component/limb_applicable
	/// List of body zones we can apply parent to
	var/list/valid_zones
	/// Category that the parent is applied to
	/// Defaults to REF(parent), ie, you can apply any number of this item to a limb
	/// Setting it to a category will prevent multiple items of that category being applied unless override_existing is TRUE
	var/apply_category
	/// If TRUE, replaces existing items with new ones
	/// If FALSE, application will fail if an item of the same category is already applied
	var/override_existing
	/// Callback to determine if parent can be applied. (Return FALSE to block application)
	var/datum/callback/can_apply
	/// Callback invoked after application
	var/datum/callback/on_apply

/datum/component/limb_applicable/Initialize(
	list/valid_zones = GLOB.all_body_zones.Copy(),
	apply_category,
	override_existing = TRUE,
	datum/callback/can_apply,
	datum/callback/on_apply,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.valid_zones = valid_zones
	src.apply_category = apply_category || REF(parent)
	src.override_existing = override_existing
	src.can_apply = can_apply
	src.on_apply = on_apply


/datum/component/limb_applicable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_apply))
	RegisterSignal(parent, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_context))

	var/obj/item/applying_item = parent
	applying_item.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

/datum/component/limb_applicable/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM)
	UnregisterSignal(parent, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET)

/datum/component/limb_applicable/proc/add_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(isliving(target))
		context[SCREENTIP_CONTEXT_LMB] = "Apply [source.name]"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/datum/component/limb_applicable/proc/on_apply(datum/source, mob/user, atom/interacting_with)
	SIGNAL_HANDLER

	if(!isliving(interacting_with))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(on_apply_async), user, interacting_with)
	return ITEM_INTERACT_BLOCKING

/datum/component/limb_applicable/proc/on_apply_async(mob/user, atom/interacting_with)
	var/mob/living/target = interacting_with
	var/obj/item/bodypart/applying_to = target.get_bodypart(deprecise_zone(user.zone_selected))
	if(isnull(applying_to))
		target.balloon_alert(user, "no bodypart!")
		return

	if(!(applying_to.body_zone in src.valid_zones))
		target.balloon_alert(user, "can't be applied there!")
		return

	if(!override_existing)
		var/obj/item/existing = LAZYACCESS(applying_to.applied_items, apply_category)
		if(!isnull(existing))
			target.balloon_alert(user, "something is already there!")
			return

	if(can_apply && !can_apply.Invoke(user, target, applying_to))
		return

	var/obj/item/applying = parent
	if(isstack(parent))
		var/obj/item/stack/stack_parent = parent
		applying = stack_parent.split_stack(1)

	else if(!user.temporarilyRemoveItemFromInventory(applying))
		target.balloon_alert(user, "can't part with [applying.name]!")
		return

	applying_to.apply_item(applying, apply_category, override_existing)
	on_apply?.Invoke(user, target, applying_to)
