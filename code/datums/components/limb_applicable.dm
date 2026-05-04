/**
 * ## Limb Applicable
 *
 * Allows item to be attached to limbs by clicking on humans with them while limb targeting
 *
 * The item then goes in the limb's contents, where it will be added to the limb's applied_items list
 * The applied_items is indexed by category so you can easily check for the presence of a given item or category of item
 */
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
	/// Callback to determine if application can be attempted. Cannot sleep. (Return FALSE to block application)
	var/datum/callback/can_apply
	/// Callback to attempt application, I.E. do_after()s. Can sleep.
	var/datum/callback/do_apply
	/// Callback invoked after application
	var/datum/callback/on_apply

/datum/component/limb_applicable/Initialize(
	list/valid_zones = GLOB.all_body_zones.Copy(),
	apply_category,
	override_existing = TRUE,
	datum/callback/can_apply,
	datum/callback/do_apply,
	datum/callback/on_apply,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.valid_zones = valid_zones
	src.apply_category = apply_category || REF(parent)
	src.override_existing = override_existing
	src.can_apply = can_apply
	src.do_apply = do_apply
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

	var/mob/living/target = interacting_with
	var/obj/item/bodypart/applying_to = target.get_bodypart(deprecise_zone(user.zone_selected))

	if(isnull(applying_to))
		target.balloon_alert(user, "no bodypart!")
		return ITEM_INTERACT_BLOCKING

	if(!(applying_to.body_zone in valid_zones))
		target.balloon_alert(user, "can't be applied there!")
		return ITEM_INTERACT_BLOCKING

	if(!override_existing)
		var/obj/item/existing = LAZYACCESS(applying_to.applied_items, apply_category)
		if(!isnull(existing))
			target.balloon_alert(user, "something is already there!")
			return ITEM_INTERACT_BLOCKING

	if(can_apply)
		var/try_apply = can_apply.Invoke(user, target, applying_to)
		if(try_apply & LIMB_APPLICABLE_BLOCK_APPLICATION)
			return (try_apply & LIMB_APPLICABLE_BLOCK_ITEM_INTERACTION) ? ITEM_INTERACT_BLOCKING : NONE

	INVOKE_ASYNC(src, PROC_REF(on_apply_async), user, interacting_with, applying_to)
	return ITEM_INTERACT_BLOCKING

/datum/component/limb_applicable/proc/on_apply_async(mob/user, mob/living/target, obj/item/bodypart/applying_to)
	if(!do_apply?.Invoke(user, target, applying_to))
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
