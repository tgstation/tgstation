/obj/projectile/bullet/bolt
	parent_type = /obj/projectile/rogue_ammo

/obj/projectile/bullet/firearm
	parent_type = /obj/projectile/rogue_ammo

/obj/projectile/bullet/reusable
	parent_type = /obj/projectile/rogue_ammo/reusable

/obj/projectile/bullet/arrow/pyro
	parent_type = /obj/projectile/rogue_ammo
	name = "pyroclatic arrow"
	desc = "An arrow with its tip drenched in a flammable tincture."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrowpyro_proj"
	damage = 15
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	hitsound = 'modular_redtard/rockhill/sound/blank.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow

/obj/projectile/bullet/arrow/water
	parent_type = /obj/projectile/rogue_ammo
	name = "water arrow"
	desc = "An arrow with its tip containing a glass ampule filled with water. It will shatter on impact, useful for taking out pesky lights."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrowwater_proj"
	damage = 0
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	hitsound = 'modular_redtard/rockhill/sound/blank.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow

/obj/projectile/bullet/bolt/pyro
	name = "pyroclastic bolt"
	desc = "A bolt smeared with a flammable tincture."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "boltpyro_proj"
	damage = 20
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.3
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	hitsound = 'modular_redtard/rockhill/sound/blank.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt

/obj/projectile/bullet/bolt/water
	name = "water bolt"
	desc = "A bolt with its tip containing a glass ampule filled with water. It will shatter on impact, useful for taking out pesky lights."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "boltwater_proj"
	damage = 0
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.3
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	hitsound = 'modular_redtard/rockhill/sound/blank.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt/water

/obj/projectile/bullet/firearm/grapeshot
	name = "grapeshot"
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	damage = 30
	armour_penetration = 90
	range = 15
	rogue_tile_time = 0.1
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 4
	rogue_accuracy = 90
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/bullet/grapeshot

/obj/projectile/bullet/firearm/lead
	name = "lead sphere"
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	damage = 80
	armour_penetration = 90
	range = 30
	rogue_tile_time = 0.1
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 4
	rogue_accuracy = 90
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/bullet/lead

/obj/projectile/bullet/reusable/arrow
	name = "arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 20
	armour_penetration = 1
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 25
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow

/obj/projectile/bullet/reusable/arrow/blacksteel
	name = "blacksteel arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "blacksteelarrow_proj"
	damage = 50
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 80
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 7
	rogue_accuracy = 100
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/blacksteel

/obj/projectile/bullet/reusable/arrow/blunt
	name = "blunt arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 15
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/blunt

/obj/projectile/bullet/reusable/arrow/bronze
	name = "bronze flight arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bronzearrow_proj"
	damage = 50
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.15
	rogue_embed_chance = 70
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 3
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/bronze

/obj/projectile/bullet/reusable/arrow/iron
	name = "broadhead arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 40
	armour_penetration = 1
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 30
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/iron

/obj/projectile/bullet/reusable/arrow/iron/decrepit
	name = "decrepit broadhead arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 20
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 30
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/iron/decrepit

/obj/projectile/bullet/reusable/arrow/poison
	name = "poison iron arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 20
	armour_penetration = 1
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 25
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/iron
	rogue_poison_type = /datum/reagent/stampoison
	rogue_poison_amount = 2
	rogue_slur = 10
	rogue_eyeblur = 10
	rogue_drowsy = 5

/obj/projectile/bullet/reusable/arrow/poison/stone
	name = "stone arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 20
	armour_penetration = 1
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 25
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/stone
	rogue_poison_type = /datum/reagent/stampoison
	rogue_poison_amount = 2
	rogue_slur = 10
	rogue_eyeblur = 10
	rogue_drowsy = 5

/obj/projectile/bullet/reusable/arrow/steel
	name = "bodkin arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 25
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.6
	rogue_embed_chance = 80
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 3
	rogue_accuracy = 75
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/steel

/obj/projectile/bullet/reusable/arrow/steel/ancient
	name = "ancient bodkin arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 25
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.6
	rogue_embed_chance = 80
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 3
	rogue_accuracy = 75
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/steel/ancient

/obj/projectile/bullet/reusable/arrow/stone
	name = "stone arrow"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "arrow_proj"
	damage = 20
	armour_penetration = 1
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 25
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	rogue_accuracy = 60
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/arrow/stone

/obj/projectile/bullet/reusable/bolt
	name = "bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	damage = 70
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.5
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt

/obj/projectile/bullet/reusable/bolt/ancient
	name = "bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	damage = 70
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.5
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt/ancient

/obj/projectile/bullet/reusable/bolt/blacksteel
	name = "blacksteel bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "blacksteelbolt_proj"
	damage = 70
	armour_penetration = 4
	range = 15
	rogue_tile_time = 0.5
	rogue_embed_chance = 80
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 6
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt/blacksteel

/obj/projectile/bullet/reusable/bolt/blunt
	name = "bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	damage = 25
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.3
	rogue_embed_chance = 1
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/woodblunt (2).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt/blunt

/obj/projectile/bullet/reusable/bolt/bronze
	name = "bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bronzebolt_proj"
	damage = 70
	armour_penetration = 2
	range = 15
	rogue_tile_time = 0.15
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 3
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt/bronze

/obj/projectile/bullet/reusable/bolt/decrepit
	name = "bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	damage = 40
	armour_penetration = 1
	range = 15
	rogue_tile_time = 0.5
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt/decrepit

/obj/projectile/bullet/reusable/bolt/heavyblunt
	name = "bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_blunt_proj"
	damage = 70
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.25
	rogue_embed_chance = 2
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/woodblunt (2).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt/heavyblunt

/obj/projectile/bullet/reusable/bolt/holy
	name = "sunderbolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolthwater_proj"
	damage = 35
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.5
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 5
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_arrow2.ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/bolt/holy
	rogue_poison_type = /datum/reagent/water/blessed
	rogue_poison_amount = 5

/obj/projectile/bullet/reusable/heavy_bolt
	name = "heavy bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	damage = 80
	armour_penetration = 4
	range = 30
	rogue_tile_time = 0.3
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_bolt (2).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/heavy_bolt

/obj/projectile/bullet/reusable/heavy_bolt/holy
	name = "stake bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	damage = 50
	armour_penetration = 4
	range = 30
	rogue_tile_time = 0.5
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 5
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_bolt (3).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/heavy_bolt/holy
	rogue_poison_type = /datum/reagent/water/blessed
	rogue_poison_amount = 5

/obj/projectile/bullet/reusable/heavy_bolt/tempest
	name = "tempest bolt"
	desc = ""
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bolt_proj"
	damage = 25
	armour_penetration = 4
	range = 30
	rogue_tile_time = 0.5
	rogue_embed_chance = 100
	rogue_bclass = "pierce"
	rogue_npc_damage_mult = 7
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/hi_bolt (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/heavy_bolt/tempest

/obj/projectile/bullet/reusable/sling_bullet/ancient
	name = "ancient sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	damage = 30
	armour_penetration = 2
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/ancient

/obj/projectile/bullet/reusable/sling_bullet/blacksteel
	name = "blacksteel sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "blacksteelslingbullet_proj"
	damage = 50
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/blacksteel

/obj/projectile/bullet/reusable/sling_bullet/bronze
	name = "bronze sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "bronzeslingbullet_proj"
	damage = 35
	armour_penetration = 1
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/bronze

/obj/projectile/bullet/reusable/sling_bullet/decrepit
	name = "decrepit sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	damage = 15
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/decrepit

/obj/projectile/bullet/reusable/sling_bullet/iron
	name = "iron sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	damage = 30
	armour_penetration = 2
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/iron

/obj/projectile/bullet/reusable/sling_bullet/silver
	name = "silver sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "blacksteelslingbullet_proj"
	color = "#c0c0c0"
	damage = 25
	armour_penetration = 1
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 5
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/silver

/obj/projectile/bullet/reusable/sling_bullet/silverblessed
	name = "blessed silver sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "blacksteelslingbullet_proj"
	color = "#eaff76"
	damage = 35
	armour_penetration = 2
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 6
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/silverblessed

/obj/projectile/bullet/reusable/sling_bullet/steel
	name = "steel sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	color = "#1f1d19"
	damage = 30
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/steel

/obj/projectile/bullet/reusable/sling_bullet/steelblessed
	name = "holy steel sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	color = "#29241a"
	damage = 30
	armour_penetration = 3
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 4
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/steelblessed

/obj/projectile/bullet/reusable/sling_bullet/stone
	name = "stone sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/weapons/ammo.dmi'
	icon_state = "musketball_proj"
	damage = 30
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
	rogue_drop_type = /obj/item/ammo_casing/caseless/rogue/sling_bullet/stone

/obj/projectile/bullet/sling_bullet
	parent_type = /obj/projectile/rogue_ammo
	name = "sling bullet"
	desc = "If you're reading this: duck."
	icon = 'modular_redtard/rockhill/icons/roguetown/items/natural.dmi'
	icon_state = "stone1"
	damage = 25
	armour_penetration = 0
	range = 15
	rogue_tile_time = 0.4
	rogue_embed_chance = 0
	rogue_bclass = "blunt"
	rogue_npc_damage_mult = 2
	hitsound = 'modular_redtard/rockhill/sound/combat/hits/blunt/bluntsmall (1).ogg'
