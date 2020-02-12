/obj/item/dwarven_guide
	name = "Brokering 101: Dwarven guide"
	desc = "An ancient tome written dwarven"
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2

/obj/item/dwarven_guide/attack_self(mob/living/carbon/human/user)
	if(!user.can_read(src) || !user.dna.check_mutation(DWARVEN))
		return FALSE
	to_chat(user, "<span class='notice'>You flip through the pages of the book, quickly and conveniently learning every language in existence. Somewhat less conveniently, the aging book crumbles to dust in the process. Whoops.</span>")
	user.grant_all_languages()
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)

/obj/item/twohanded/war_hammer
	name = "dwarven warhammer"
	desc = "A very heavy warhammer, used to dent skulls unless they are already dented."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "greyscale_dwarven_warhammer0"
	//item_state = "greyscale_dwarven_warhammer0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	force = 14
	force_unwielded = 14
	force_wielded = 20
	armour_penetration = 20
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = 20000)
	attack_verb = list("smashed", "dented", "bludeoned")
	hitsound = 'sound/weapons/slam.ogg'
	sharpness = IS_BLUNT

/obj/item/twohanded/war_hammer/update_icon_state()
	icon_state = "greyscale_dwarven_warhammer[wielded]"


/obj/item/hatchet/dwarven/axe
	name = "dwarven hand axe"
	desc = "A very sharp axe blade made of greatest dwarven metal."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "greyscale_dwarven_axe"
	item_state = "greyscale_dwarven_axe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	flags_1 = CONDUCT_1
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	force = 15
	throwforce = 16

/obj/item/hatchet/dwarven/axe/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 60, 80)

/obj/item/hatchet/dwarven/javelin
	name = "dwarven javelin"
	desc = "A very sharp javelin made of greatest dwarven metal."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "greyscale_dwarven_javelin"
	item_state = "greyscale_dwarven_javelin"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	flags_1 = CONDUCT_1
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	force = 7
	throwforce = 18
	throw_speed = 4
	throw_range = 5
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 80, "embedded_fall_chance" = 20)

/obj/item/dwarven/rune_stone
	name = "rune stone"
	desc = "Dwarven magical artifact, looks fragile."
	icon = 'icons/obj/dwarven.dmi'
	icon_state = "runestone"

/obj/item/gun/magic/wand/rune
	desc = "Dwarven magical artifact, looks fragile."
	icon = 'icons/obj/dwarven.dmi'
	icon_state = "runestone"
	max_charges = 1
	no_den_usage = TRUE
	var/overlay_state = "blitz_rune"
	var/mutable_appearance/overlay

/obj/item/gun/magic/wand/rune/Initialize()
	. = ..()
	overlay = mutable_appearance(icon, overlay_state)
	overlay.appearance_flags = RESET_COLOR
	add_overlay(overlay)
	max_charges = 1

/obj/item/gun/magic/wand/rune/process_fire(atom/target, mob/living/user)
	. = ..()
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)

/obj/item/gun/magic/wand/rune/blitz
	name = "blitz rune"
	ammo_type = /obj/item/ammo_casing/magic/lightning
	fire_sound = 'sound/magic/fireball.ogg'
	overlay_state = "blitz_rune"

/obj/item/gun/magic/wand/rune/earth
	name = "earth rune"
	ammo_type = /obj/item/ammo_casing/magic/arcane_barrage
	fire_sound = 'sound/magic/fireball.ogg'
	overlay_state = "earth_rune"

/obj/item/gun/magic/wand/rune/air
	name = "air rune"
	ammo_type = /obj/item/ammo_casing/magic/teleport
	fire_sound = 'sound/magic/wand_teleport.ogg'
	overlay_state = "air_rune"





