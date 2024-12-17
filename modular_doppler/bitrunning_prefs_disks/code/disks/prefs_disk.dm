/**
 * Bitrunning tech disks which let you load a custom character preference for your bit avatar.
 * This uses a preference selected from your character list.
 * Optionally, this may include the loadout as well.
 *
 * For the sake of domain restrictions:
 * - ability blocks block the application of character prefs.
 * - item blocks block the application of character loadout.
 */
/obj/item/bitrunning_disk/preferences
	name = "bitrunning program: personalized avatar"
	desc = "A disk containing source code. It can be used to override your bit avatar's standard appearance. Further avatar disks will be ignored."

	// Allows it to be held in the pocket
	w_class = WEIGHT_CLASS_SMALL

	/// Our chosen preference.
	var/datum/preferences/chosen_preference
	/// Whether we include the loadout as well.
	var/include_loadout = FALSE
	/// Mock client we use for forwarding to quirk assignment (beware, evil hacks).
	var/datum/prefs_disk_client_interface/mock_client

/obj/item/bitrunning_disk/preferences/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/bitrunning_disk/preferences/examine(mob/user)
	. = ..()
	if(isnull(chosen_preference))
		return

	. += span_info("Loadout application is currently [include_loadout ? "enabled" : "disabled"].")
	. += span_notice("Ctrl-click to toggle loadout application.")

/obj/item/bitrunning_disk/preferences/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	var/result = NONE
	if(isnull(chosen_preference) && (held_item == src))
		context[SCREENTIP_CONTEXT_LMB] = "Select avatar"
		result = CONTEXTUAL_SCREENTIP_SET
	if(!isturf(src.loc))
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Toggle loadout"
		result = CONTEXTUAL_SCREENTIP_SET

	return result

/obj/item/bitrunning_disk/preferences/Destroy()
	QDEL_NULL(chosen_preference)
	QDEL_NULL(mock_client)
	return ..()

/obj/item/bitrunning_disk/preferences/attack_self(mob/user, modifiers)
	. = ..()

	if(isnull(user.client) || chosen_preference)
		return

	var/list/character_profiles = user.client.prefs?.create_character_profiles()
	if(isnull(character_profiles) || !length(character_profiles))
		return

	var/choice = tgui_input_list(user, message = "Select a character",  title = "Bitrunning Avatar", items = character_profiles)
	if(isnull(choice) || !user.is_holding(src))
		return

	choice_made = choice
	chosen_preference = new(user.client)
	chosen_preference.load_character(character_profiles.Find(choice))

	// Perform our evil hacks
	if(isnull(mock_client))
		mock_client = new
	mock_client.prefs = chosen_preference
	// Done loading from the client, so replace reference to the real client
	chosen_preference.parent = mock_client

	balloon_alert(user, "avatar set!")
	playsound(user, 'sound/items/click.ogg', 50, TRUE)

/obj/item/bitrunning_disk/preferences/item_ctrl_click(mob/user)
	if(isturf(src.loc)) // If on a turf, we skip to dragging
		return NONE
	if(isnull(chosen_preference))
		balloon_alert(user, "set preference first!")
		return CLICK_ACTION_BLOCKING
	include_loadout = !include_loadout
	balloon_alert(user, include_loadout ? "loadout enabled!" : "loadout disabled!")

	// High frequency range when enabled, low when disabled. More tactile.
	var/toggle_frequency = include_loadout ? rand(45000, 55000) : rand(32000, 42000)
	playsound(user, 'sound/items/click.ogg', 50, TRUE, frequency = toggle_frequency)

	return CLICK_ACTION_SUCCESS

/**
 * Allows for ordering of the prefs disk.
 */
/datum/orderable_item/bitrunning_tech/prefs_disk
	cost_per_order = 1000
	purchase_path = /obj/item/bitrunning_disk/preferences
	desc = "This disk contains a program that lets you load in custom bit avatars."

/**
 * Evil hack that allows us to assign quirks without needing to forward a real client.
 * Using this instead of the normal mock client allows us to include only what we need without editing the base,
 * or interfering with things like `mock_client_uid`.
 *
 * Much the same, this should match the interface of /client wherever necessary.
 */
/datum/prefs_disk_client_interface
	/// Player preferences datum for the client
	var/datum/preferences/prefs

	/// The mob the client controls
	var/mob/mob

/// We don't actually care about award status, but we don't want it to runtime due to not existing.
/datum/prefs_disk_client_interface/proc/get_award_status(achievement_type, mob/user, value = 1)
	return 0
