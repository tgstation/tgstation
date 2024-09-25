/obj/item/gun/magic/wand/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew."
	fire_sound = 'sound/items/weapons/emitter.ogg'
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "arcane_barrage"
	inhand_icon_state = "arcane_barrage"
	base_icon_state = "arcane_barrage"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	slot_flags = null
	item_flags = NEEDS_PERMIT | DROPDEL | ABSTRACT | NOBLUDGEON
	flags_1 = NONE
	weapon_weight = WEAPON_HEAVY
	max_charges = 30
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage

/obj/item/gun/magic/wand/arcane_barrage/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, 0.2 SECONDS)

/obj/item/gun/magic/wand/arcane_barrage/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(!.)
		return
	if(!charges)
		user.dropItemToGround(src, TRUE)
