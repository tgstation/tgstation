/// Subtype with support for hoods
/// You no longer actually need to extend this and can just add the component yourself without a lot of this boilerplate code
/obj/item/clothing/suit/hooded
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this
	/// Alternative mode for hiding the hood, instead of storing the hood in the suit it qdels it, useful for when you deal with hooded suit with storage.
	var/alternative_mode = FALSE
	/// What should be added to the end of the icon state when the hood is up? Set to "" for the suit sprite to not change at all
	var/hood_up_affix = "_t"
	/// Icon state added as a worn overlay while the hood is down, leave as "" for no overlay
	var/hood_down_overlay_suffix = ""
	/// Reference to hood object, if it exists
	var/obj/item/clothing/head/hooded/hood

/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	if (!hoodtype)
		return
	AddComponent(\
		/datum/component/toggle_attached_clothing,\
		deployable_type = hoodtype,\
		equipped_slot = ITEM_SLOT_HEAD,\
		action_name = "Toggle Hood",\
		destroy_on_removal = alternative_mode,\
		parent_icon_state_suffix = hood_up_affix,\
		down_overlay_state_suffix = hood_down_overlay_suffix, \
		pre_creation_check = CALLBACK(src, PROC_REF(can_create_hood)),\
		on_created = CALLBACK(src, PROC_REF(on_hood_created)),\
		on_deployed = CALLBACK(src, PROC_REF(on_hood_up)),\
		on_removed = CALLBACK(src, PROC_REF(on_hood_down)),\
	)

/obj/item/clothing/suit/hooded/Destroy()
	hood = null
	return ..()

/// Override to only create the hood conditionally
/obj/item/clothing/suit/hooded/proc/can_create_hood()
	return TRUE

/// Called when the hood is instantiated
/obj/item/clothing/suit/hooded/proc/on_hood_created(obj/item/clothing/head/hooded/hood)
	SHOULD_CALL_PARENT(TRUE)
	src.hood = hood
	RegisterSignal(hood, COMSIG_QDELETING, PROC_REF(on_hood_deleted))

/// Called when hood is deleted
/obj/item/clothing/suit/hooded/proc/on_hood_deleted()
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	hood = null

/// Called when the hood is worn
/obj/item/clothing/suit/hooded/proc/on_hood_up(obj/item/clothing/head/hooded/hood)
	return

/// Called when the hood is hidden
/obj/item/clothing/suit/hooded/proc/on_hood_down(obj/item/clothing/head/hooded/hood)
	return

/obj/item/clothing/suit/toggle
	abstract_type = /obj/item/clothing/suit/toggle
	/// The noun that is displayed to the user on toggle. EX: "Toggles the suit's [buttons]".
	var/toggle_noun = "buttons"

/obj/item/clothing/suit/toggle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, toggle_noun)

/obj/item/clothing/head/hooded
	abstract_type = /obj/item/clothing/head/hooded
