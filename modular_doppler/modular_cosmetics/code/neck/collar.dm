/obj/item/clothing/neck/human_petcollar
	name = "pet collar"
	desc = "It's for pets. Though you probably could wear it yourself, you'd doubtless be the subject of ridicule."
	icon_state = "pet"
	greyscale_config = /datum/greyscale_config/collar/pet
	greyscale_config_worn = /datum/greyscale_config/collar/pet/worn
	greyscale_colors = "#44BBEE#FFCC00"
	obj_flags = parent_type::obj_flags | UNIQUE_RENAME
	flags_1 = IS_PLAYER_COLORABLE_1
	alternate_worn_layer = UNDER_SUIT_LAYER
	/// What treat item spawns inside the collar?
	var/treat_path = /obj/item/food/cookie

/obj/item/clothing/neck/human_petcollar/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/small)
	atom_storage.set_holdable(list(
		/obj/item/food/cookie,
		/obj/item/key/collar,
	))
	if(treat_path)
		new treat_path(src)

// incompatible storage by default stops attack chain, but this does not, allows pen renaming
/obj/item/clothing/neck/human_petcollar/storage_insert_on_interacted_with(datum/storage/storage, obj/item/inserted, mob/living/user)
	return is_type_in_typecache(inserted, storage.can_hold)

/obj/item/clothing/neck/human_petcollar/leather
	name = "leather pet collar"
	icon_state = "leather"
	greyscale_config = /datum/greyscale_config/collar/leather
	greyscale_config_worn = /datum/greyscale_config/collar/leather/worn
	greyscale_colors = "#222222#888888#888888"

/obj/item/clothing/neck/human_petcollar/choker
	name = "choker"
	desc = "Quite fashionable... if you're somebody who's just read their first BDSM-themed erotica novel."
	icon_state = "choker"
	greyscale_config = /datum/greyscale_config/collar/choker
	greyscale_config_worn = /datum/greyscale_config/collar/choker/worn
	greyscale_colors = "#222222"

/obj/item/clothing/neck/human_petcollar/thinchoker
	name = "thin choker"
	desc = "Like the normal one, but thinner!"
	icon_state = "thinchoker"
	greyscale_config = /datum/greyscale_config/collar/thinchoker
	greyscale_config_worn = /datum/greyscale_config/collar/thinchoker/worn
	greyscale_colors = "#222222"

/obj/item/key/collar
	name = "collar key"
	desc = "A key for a tiny lock on a collar or bag."
	obj_flags = parent_type::obj_flags | UNIQUE_RENAME

/obj/item/clothing/neck/human_petcollar/locked
	name = "locked collar"
	desc = "A collar that has a small lock on it to keep it from being removed."
	treat_path = /obj/item/key/collar
	/// Is the collar currently locked?
	var/locked = FALSE

/obj/item/clothing/neck/human_petcollar/locked/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(can_unequip))

/obj/item/clothing/neck/human_petcollar/locked/proc/can_unequip(obj/item/source, force, atom/newloc, no_move, invdrop, silent)
	var/mob/living/carbon/wearer = source.loc
	if(istype(wearer) && wearer.wear_neck == source && locked)
		to_chat(wearer, "The collar is locked! You'll need to unlock it before you can take it off!")
		return COMPONENT_ITEM_BLOCK_UNEQUIP
	return NONE

/obj/item/clothing/neck/human_petcollar/locked/canStrip(mob/stripper, mob/owner)
	if(!locked)
		return ..()
	owner.balloon_alert(stripper, "locked!")
	return FALSE

/obj/item/clothing/neck/human_petcollar/locked/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/key/collar))
		return ..()
	to_chat(user, span_warning("With a click, the collar [locked ? "unlocks" : "locks"]!"))
	locked = !locked
	return ITEM_INTERACT_SUCCESS

/obj/item/clothing/neck/human_petcollar/locked/examine(mob/user)
	. = ..()
	. += "It seems to be [locked ? "locked" : "unlocked"]."

/obj/item/clothing/neck/human_petcollar/locked/bell
	name = "bell collar"
	desc = "A loud and annoying collar for your little kitten!"
	icon_state = "bell"
	greyscale_config = /datum/greyscale_config/collar/bell
	greyscale_config_worn = /datum/greyscale_config/collar/bell/worn
	greyscale_colors = "#222222#C0C0C0"

/obj/item/clothing/neck/human_petcollar/locked/choker
	name = "choker"
	desc = "Quite fashionable... if you're somebody who's just read their first BDSM-themed erotica novel."
	icon_state = "choker"
	greyscale_config = /datum/greyscale_config/collar/choker
	greyscale_config_worn = /datum/greyscale_config/collar/choker/worn
	greyscale_colors = "#222222"

/obj/item/clothing/neck/human_petcollar/locked/cow
	name = "cowbell collar"
	desc = "Don't fear the reaper, now your pet doesn't have to."
	icon_state = "cow"
	greyscale_config = /datum/greyscale_config/collar/cow
	greyscale_config_worn = /datum/greyscale_config/collar/cow/worn
	greyscale_colors = "#663300#FFCC00"

/obj/item/clothing/neck/human_petcollar/locked/cross
	name = "cross collar"
	desc = "A religious punishment, probably."
	icon_state = "cross"
	greyscale_config = /datum/greyscale_config/collar/cross
	greyscale_config_worn = /datum/greyscale_config/collar/cross/worn
	greyscale_colors = "#663300#FFCC00"

/obj/item/clothing/neck/human_petcollar/locked/holo
	name = "holocollar"
	desc = "A collar with holographic information. Like a microchip, but around the neck."
	icon_state = "holo"
	greyscale_config = /datum/greyscale_config/collar/holo
	greyscale_config_worn = /datum/greyscale_config/collar/holo/worn
	greyscale_colors = "#292929#3399FF"

/obj/item/clothing/neck/human_petcollar/locked/leather
	name = "leather pet collar"
	icon_state = "leather"
	greyscale_config = /datum/greyscale_config/collar/leather
	greyscale_config_worn = /datum/greyscale_config/collar/leather/worn
	greyscale_colors = "#222222#888888#888888"

/obj/item/clothing/neck/human_petcollar/locked/spike
	name = "spiked collar"
	desc = "A collar for a moody pet. Or a pitbull."
	icon_state = "spike"
	greyscale_config = /datum/greyscale_config/collar/spike
	greyscale_config_worn = /datum/greyscale_config/collar/spike/worn
	greyscale_colors = "#292929#C0C0C0"
