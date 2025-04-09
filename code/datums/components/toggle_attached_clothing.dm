/**
 * Component which allows clothing to deploy a different kind of clothing onto you.
 * The simplest example is hooded suits deploying hoods onto your head.
 */
/datum/component/toggle_attached_clothing
	/// Instance of the item we're creating
	var/obj/item/deployable
	/// Action used to toggle deployment
	var/datum/action/item_action/toggle_action
	/// Typepath of what we're creating
	var/deployable_type
	/// Which slot this item equips into
	var/equipped_slot
	/// Name of toggle action
	var/action_name = ""
	/// If true, we delete our deployable on toggle rather than putting it in nullspace
	var/destroy_on_removal
	/// Current state of our deployable equipment
	var/currently_deployed = FALSE
	/// What should be added to the end of the parent icon state when equipment is deployed? Set to "" for no change
	var/parent_icon_state_suffix = ""
	/// Icon state for overlay to display over the parent item while deployable item is not deployed
	var/down_overlay_state_suffix = ""
	/// Overlay to display over the parent item while deployable item is not deployed
	var/mutable_appearance/undeployed_overlay
	/// Optional callback triggered before deploying, return TRUE to continue or FALSE to cancel
	var/datum/callback/pre_creation_check
	/// Optional callback triggered when we create our deployable equipment
	var/datum/callback/on_created
	/// Optional callback triggered when we have deployed our equipment
	var/datum/callback/on_deployed
	/// Optional callback triggered before we hide our equipment, before as we may delete it afterwards
	var/datum/callback/on_removed

/datum/component/toggle_attached_clothing/Initialize(
	deployable_type,
	equipped_slot,
	action_name = "Toggle",
	destroy_on_removal = FALSE,
	parent_icon_state_suffix = "",
	down_overlay_state_suffix = "",
	datum/callback/pre_creation_check,
	datum/callback/on_created,
	datum/callback/on_deployed,
	datum/callback/on_removed,
)
	. = ..()
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if (!deployable_type || !equipped_slot)
		return COMPONENT_REDUNDANT
	src.deployable_type = deployable_type
	src.equipped_slot = equipped_slot
	src.destroy_on_removal = destroy_on_removal
	src.parent_icon_state_suffix = parent_icon_state_suffix
	src.down_overlay_state_suffix = down_overlay_state_suffix
	src.pre_creation_check = pre_creation_check
	src.on_created = on_created
	src.on_deployed = on_deployed
	src.on_removed = on_removed

	var/obj/item/clothing_parent = parent
	toggle_action = new(parent)
	toggle_action.name = action_name
	clothing_parent.add_item_action(toggle_action)

	RegisterSignal(parent, COMSIG_ITEM_UI_ACTION_CLICK, PROC_REF(on_toggle_pressed))
	RegisterSignal(parent, COMSIG_ITEM_UI_ACTION_SLOT_CHECKED, PROC_REF(on_action_slot_checked))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_parent_equipped))
	RegisterSignal(parent, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(remove_deployable))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_AS_OUTFIT, PROC_REF(on_parent_equipped_outfit))
	if (down_overlay_state_suffix)
		var/overlay_state = "[initial(clothing_parent.icon_state)][down_overlay_state_suffix]"
		undeployed_overlay = mutable_appearance(initial(clothing_parent.worn_icon), overlay_state, -SUIT_LAYER)
		RegisterSignal(parent, COMSIG_ITEM_GET_WORN_OVERLAYS, PROC_REF(on_checked_overlays))
		clothing_parent.update_slot_icon()

	if (!destroy_on_removal)
		create_deployable()

/datum/component/toggle_attached_clothing/Destroy(force)
	unequip_deployable()
	QDEL_NULL(deployable)
	QDEL_NULL(toggle_action)
	undeployed_overlay = null
	pre_creation_check = null
	on_created = null
	on_deployed = null
	on_removed = null
	return ..()

/// Toggle deployable when the UI button is clicked
/datum/component/toggle_attached_clothing/proc/on_toggle_pressed(obj/item/source, mob/user, datum/action)
	SIGNAL_HANDLER
	if (action != toggle_action)
		return
	toggle_deployable()
	return COMPONENT_ACTION_HANDLED

/// Called when action attempts to check what slot the item is worn in
/datum/component/toggle_attached_clothing/proc/on_action_slot_checked(obj/item/clothing/source, mob/user, datum/action, slot)
	SIGNAL_HANDLER
	if (action != toggle_action)
		return
	if (!(source.slot_flags & slot))
		return COMPONENT_ITEM_ACTION_SLOT_INVALID

/// Apply an overlay while the item is not deployed
/datum/component/toggle_attached_clothing/proc/on_checked_overlays(obj/item/source, list/overlays, mutable_appearance/standing, isinhands, icon_file)
	SIGNAL_HANDLER
	if (isinhands || currently_deployed)
		return
	overlays += undeployed_overlay

/// Deploys gear if it is hidden, hides it if it is deployed
/datum/component/toggle_attached_clothing/proc/toggle_deployable()
	if (currently_deployed)
		remove_deployable()
		return

	var/obj/item/parent_gear = parent
	if (!ishuman(parent_gear.loc))
		return
	var/mob/living/carbon/human/wearer = parent_gear.loc
	if (wearer.is_holding(parent_gear))
		parent_gear.balloon_alert(wearer, "wear it first!")
		return
	if (wearer.get_item_by_slot(equipped_slot))
		parent_gear.balloon_alert(wearer, "slot occupied!")
		return
	if (!deployable && !create_deployable())
		return
	if (!wearer.equip_to_slot_if_possible(deployable, slot = equipped_slot))
		if(destroy_on_removal)
			remove_deployable()
		return
	currently_deployed = TRUE
	on_deployed?.Invoke(deployable)
	if (parent_icon_state_suffix)
		parent_gear.icon_state = "[initial(parent_gear.icon_state)][parent_icon_state_suffix]"
		parent_gear.worn_icon_state = parent_gear.icon_state
	parent_gear.update_slot_icon()
	wearer.update_mob_action_buttons()

/// Undeploy gear if it moves slots somehow
/datum/component/toggle_attached_clothing/proc/on_parent_equipped(obj/item/clothing/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if (slot & equipped_slot)
		return
	remove_deployable()

/// Display deployed if worn in an outfit
/datum/component/toggle_attached_clothing/proc/on_parent_equipped_outfit(obj/item/clothing/source, mob/equipper, visuals_only, slot)
	SIGNAL_HANDLER
	create_deployable()
	toggle_deployable()

/// Create our gear, returns true if we actually made anything
/datum/component/toggle_attached_clothing/proc/create_deployable()
	if (deployable)
		return FALSE
	if (pre_creation_check && !pre_creation_check.Invoke())
		return FALSE
	deployable = new deployable_type(parent)
	if (!istype(deployable))
		stack_trace("Tried to create non-clothing item from toggled clothing.")
	RegisterSignal(deployable, COMSIG_ITEM_DROPPED, PROC_REF(on_deployed_dropped))
	RegisterSignal(deployable, COMSIG_ITEM_EQUIPPED, PROC_REF(on_deployed_equipped))
	RegisterSignal(deployable, COMSIG_QDELETING, PROC_REF(on_deployed_destroyed))
	on_created?.Invoke(deployable)
	return TRUE

/// Undeploy gear if you drop it
/datum/component/toggle_attached_clothing/proc/on_deployed_dropped()
	SIGNAL_HANDLER
	remove_deployable()

/// Undeploy gear if it moves slots somehow
/datum/component/toggle_attached_clothing/proc/on_deployed_equipped(obj/item/clothing/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if (source.slot_flags & slot)
		return
	remove_deployable()

/// Undeploy gear if it is deleted
/datum/component/toggle_attached_clothing/proc/on_deployed_destroyed()
	SIGNAL_HANDLER
	remove_deployable()
	deployable = null

/// Removes our deployed equipment from the wearer
/datum/component/toggle_attached_clothing/proc/remove_deployable()
	SIGNAL_HANDLER
	unequip_deployable()
	if (!currently_deployed)
		return
	currently_deployed = FALSE
	on_removed?.Invoke(deployable)

	var/obj/item/parent_gear = parent
	if(destroy_on_removal)
		QDEL_NULL(deployable)
	if(parent_icon_state_suffix)
		parent_gear.icon_state = "[initial(parent_gear.icon_state)]"
		parent_gear.worn_icon_state = parent_gear.icon_state
	parent_gear.update_slot_icon()
	parent_gear.update_item_action_buttons()

/// Removes an equipped deployable atom upon its retraction or destruction
/datum/component/toggle_attached_clothing/proc/unequip_deployable()
	if (!deployable)
		return
	if (!ishuman(deployable.loc))
		deployable.forceMove(parent)
		return
	var/mob/living/carbon/human/wearer = deployable.loc
	wearer.transferItemToLoc(deployable, parent, force = TRUE, silent = TRUE)
