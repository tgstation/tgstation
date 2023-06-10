//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	var/hoodtype = /obj/item/clothing/head/hooded/winterhood //so the chaplain hoodie or other hoodies can override this
	///Alternative mode for hiding the hood, instead of storing the hood in the suit it qdels it, useful for when you deal with hooded suit with storage.
	var/alternative_mode = FALSE
	///Whether the hood is flipped up
	var/hood_up = FALSE
	/// What should be added to the end of the icon state when the hood is up? Set to "" for the suit sprite to not change at all
	var/hood_up_affix = "_t"

/obj/item/clothing/suit/hooded/Initialize(mapload)
	. = ..()
	if (!hoodtype)
		return
	AddComponent(\
		/datum/component/toggled_clothing,\
		deployable_type = hoodtype,\
		equipped_slot = ITEM_SLOT_HEAD,\
		action_name = "Toggle Hood",\
		destroy_on_removal = alternative_mode,\
		parent_icon_state_modifier = hood_up_affix,\
		on_created = CALLBACK(src, PROC_REF(on_hood_created)),\
		on_deployed = CALLBACK(src, PROC_REF(on_hood_up)),\
		on_removed = CALLBACK(src, PROC_REF(on_hood_down)),\
	)

/// Called when the hood is instantiated
/obj/item/clothing/suit/hooded/proc/on_hood_created(obj/item/clothing/head/hooded/hood)
	return

/// Called when the hood is worn
/obj/item/clothing/suit/hooded/proc/on_hood_up(obj/item/clothing/head/hooded/hood)
	SHOULD_CALL_PARENT(TRUE)
	hood_up = TRUE

/// Called when the hood is hidden
/obj/item/clothing/suit/hooded/proc/on_hood_down(obj/item/clothing/head/hooded/hood)
	SHOULD_CALL_PARENT(TRUE)
	hood_up = FALSE

/obj/item/clothing/suit/toggle
	/// The noun that is displayed to the user on toggle. EX: "Toggles the suit's [buttons]".
	var/toggle_noun = "buttons"

/obj/item/clothing/suit/toggle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon, toggle_noun)
