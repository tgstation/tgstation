
///basic bow, used for medieval sim
/obj/item/gun/ballistic/bow/longbow
	name = "longbow"
	desc = "While pretty finely crafted, surely you can find something better to use in the current year."

/// Shortbow, made via the crafting recipe
/obj/item/gun/ballistic/bow/shortbow
	name = "shortbow"
	desc = "A simple homemade shortbow. Great for LARPing. Or poking out someones eye."
	obj_flags = UNIQUE_RENAME
	projectile_damage_multiplier = 0.5
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 4, /datum/material/iron = SHEET_MATERIAL_AMOUNT)

///chaplain's divine archer bow
/obj/item/gun/ballistic/bow/divine
	name = "divine bow"
	desc = "Holy armament to pierce the souls of sinners."
	icon_state = "holybow"
	inhand_icon_state = "holybow"
	base_icon_state = "holybow"
	worn_icon_state = "holybow"
	slot_flags = ITEM_SLOT_BACK
	obj_flags = UNIQUE_RENAME
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/bow/holy
	projectile_damage_multiplier = 0.6
	projectile_speed_multiplier = 1.5

/obj/item/ammo_box/magazine/internal/bow/holy
	name = "divine bowstring"
	ammo_type = /obj/item/ammo_casing/arrow/holy

/obj/item/gun/ballistic/bow/divine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/nullrod_core)
	RegisterSignal(src, COMSIG_ITEM_SUBTYPE_PICKER_SELECTED, PROC_REF(on_selected))

/obj/item/gun/ballistic/bow/divine/proc/on_selected(datum/source, obj/item/nullrod/old_weapon, mob/picker)
	SIGNAL_HANDLER
	new /obj/item/storage/bag/quiver/holy(loc)

/// Ashen bow, crafted from watcher sinew and animal bones.
/obj/item/gun/ballistic/bow/ashenbow
	name = "ashen bow"
	desc = "A bow made from watcher sinew and bone. Seems to possess an almost eerie radiance about it."
	icon_state = "ashenbow"
	inhand_icon_state = "ashenbow"
	base_icon_state = "ashenbow"
	worn_icon_state = "ashenbow"
	slot_flags = ITEM_SLOT_BACK
	obj_flags = UNIQUE_RENAME
	projectile_damage_multiplier = 0.5
	custom_materials = list(/datum/material/bone = SHEET_MATERIAL_AMOUNT * 6)
