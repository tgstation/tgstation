/obj/item/shrapnel // frag grenades
	name = "shrapnel shard"
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5)
	weak_against_armour = TRUE
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	item_flags = DROPDEL
	sharpness = SHARP_EDGED

/obj/item/shrapnel/stingball // stingbang grenades
	name = "stingball"
	icon_state = "tiny"
	sharpness = NONE

/obj/item/shrapnel/bullet // bullets
	name = "bullet"
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = "s-casing"
	embedding = null // embedding vars are taken from the projectile itself


/obj/projectile/bullet/shrapnel
	name = "flying shrapnel shard"
	damage = 14
	range = 20
	weak_against_armour = TRUE
	dismemberment = 5
	ricochets_max = 2
	ricochet_chance = 70
	shrapnel_type = /obj/item/shrapnel
	ricochet_incidence_leeway = 60
	hit_prone_targets = TRUE
	sharpness = SHARP_EDGED
	wound_bonus = 30
	embedding = list(embed_chance=70, ignore_throwspeed_threshold=TRUE, fall_chance=1)

/obj/projectile/bullet/shrapnel/mega
	name = "flying shrapnel hunk"
	range = 45
	dismemberment = 15
	ricochets_max = 6
	ricochet_chance = 130
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0.9

/obj/projectile/bullet/pellet/stingball
	name = "stingball pellet"
	damage = 3
	stamina = 8
	ricochets_max = 4
	ricochet_chance = 66
	ricochet_decay_chance = 1
	ricochet_decay_damage = 0.9
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 2
	ricochet_incidence_leeway = 0
	embed_falloff_tile = -2
	shrapnel_type = /obj/item/shrapnel/stingball
	embedding = list(embed_chance=55, fall_chance=2, jostle_chance=7, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.7, pain_mult=3, jostle_pain_mult=3, rip_time=15)

/obj/projectile/bullet/pellet/stingball/on_ricochet(atom/A)
	hit_prone_targets = TRUE // ducking will save you from the first wave, but not the rebounds

/obj/projectile/bullet/pellet/stingball/mega
	name = "megastingball pellet"
	ricochets_max = 6
	ricochet_chance = 110

/obj/projectile/bullet/pellet/capmine
	name = "\improper AP shrapnel shard"
	range = 7
	damage = 8
	stamina = 8
	sharpness = SHARP_EDGED
	wound_bonus = 5
	bare_wound_bonus = 5
	ricochets_max = 2
	ricochet_chance = 140
	shrapnel_type = /obj/item/shrapnel/capmine
	embedding = list(embed_chance=90, fall_chance=3, jostle_chance=7, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.7, pain_mult=5, jostle_pain_mult=6, rip_time=15)
	wound_falloff_tile = 0
	embed_falloff_tile = 0

/obj/item/shrapnel/capmine
	name = "\improper AP shrapnel shard"
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5)
	weak_against_armour = TRUE

