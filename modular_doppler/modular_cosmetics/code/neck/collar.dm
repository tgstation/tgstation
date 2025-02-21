/obj/item/clothing/neck/fashion_collar
	name = "thin collar"
	desc = "A thin strap with no particular design. The size happens to fit a person's a neck too."
	icon_state = "thin_collar"
	greyscale_config = /datum/greyscale_config/collar
	greyscale_config_worn = /datum/greyscale_config/collar/worn
	greyscale_colors = "#806948"
	obj_flags = parent_type::obj_flags | UNIQUE_RENAME
	flags_1 = IS_PLAYER_COLORABLE_1
	alternate_worn_layer = UNDER_SUIT_LAYER
	var/collar_contents = /obj/item/key/collar
	var/locked = FALSE

/obj/item/clothing/neck/fashion_collar/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(can_unequip))
	create_storage(storage_type = /datum/storage/pockets/small)
	atom_storage.set_holdable(list(
		/obj/item/key/collar,
	))
	if(collar_contents)
		new collar_contents(src)

/obj/item/clothing/neck/fashion_collar/proc/can_unequip(obj/item/source, force, atom/newloc, no_move, invdrop, silent)
	var/mob/living/carbon/wearer = source.loc
	if(istype(wearer) && wearer.wear_neck == source && locked)
		to_chat(wearer, "The collar is locked! You'll need to unlock it before you can take it off!")
		return COMPONENT_ITEM_BLOCK_UNEQUIP
	return NONE

/obj/item/clothing/neck/fashion_collar/canStrip(mob/stripper, mob/owner)
	if(!locked)
		return ..()
	owner.balloon_alert(stripper, "locked!")
	return FALSE

/obj/item/clothing/neck/fashion_collar/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/key/collar))
		return ..()
	to_chat(user, span_warning("With a click, the collar [locked ? "unlocks" : "locks"]!"))
	locked = !locked
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/neck/fashion_collar/examine(mob/user)
	. = ..()
	. += "It seems to be [locked ? "locked" : "unlocked"]."

/obj/item/key/collar
	name = "collar key"
	desc = "A key for a tiny lock on a collar or bag."
	obj_flags = parent_type::obj_flags | UNIQUE_RENAME

/obj/item/clothing/neck/fashion_collar/thick
	name = "thick collar"
	desc = "A thick strap, unadorned. The size happens to fit a person's a neck too."
	icon_state = "thick_collar"
	greyscale_config = /datum/greyscale_config/collar/thick
	greyscale_config_worn = /datum/greyscale_config/collar/thick/worn

/obj/item/clothing/neck/fashion_collar/bell
	name = "bell collar"
	desc = "A thin strap adorned with a small chrome bell and D-shaped ring."
	icon_state = "bell"
	greyscale_config = /datum/greyscale_config/collar/bell
	greyscale_config_worn = /datum/greyscale_config/collar/bell/worn
	greyscale_colors = "#222222#C0C0C0"

/obj/item/clothing/neck/fashion_collar/bell/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/item_equipped_movement_rustle, SFX_JINGLEBELL)

/obj/item/clothing/neck/fashion_collar/cow
	name = "cowbell collar"
	desc = "A thick band of leather with a large brass bell mounted to a sturdy ring."
	icon_state = "cow"
	greyscale_config = /datum/greyscale_config/collar/cow
	greyscale_config_worn = /datum/greyscale_config/collar/cow/worn
	greyscale_colors = "#663300#FFCC00"

/obj/item/clothing/neck/fashion_collar/cross
	name = "cross choker"
	desc = "A thin band of velvet with a cross shaped charm opposite the clasp."
	icon_state = "cross"
	greyscale_config = /datum/greyscale_config/collar/cross
	greyscale_config_worn = /datum/greyscale_config/collar/cross/worn
	greyscale_colors = "#663300#FFCC00"

/obj/item/clothing/neck/fashion_collar/holo
	name = "holocollar"
	desc = "Biometrics are scrawled in holoform across the pendant on this collar."
	icon_state = "holo"
	greyscale_config = /datum/greyscale_config/collar/holo
	greyscale_config_worn = /datum/greyscale_config/collar/holo/worn
	greyscale_colors = "#292929#3399FF"

/obj/item/clothing/neck/fashion_collar/spike
	name = "spiked collar"
	desc = "This design has its origins in bands of spiked iron worn about the necks of medieval hunting dogs, to \
	protect them against retaliating prey."
	icon_state = "spike"
	greyscale_config = /datum/greyscale_config/collar/spike
	greyscale_config_worn = /datum/greyscale_config/collar/spike/worn
	greyscale_colors = "#6b6f70"
