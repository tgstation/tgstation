/obj/item/shrapnel // frag grenades
	name = "shrapnel shard"
	embedding = list(embed_chance=70, ignore_throwspeed_threshold=TRUE, fall_chance=4, embed_chance_turf_mod=-100)
	custom_materials = list(/datum/material/iron=50)
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	item_flags = DROPDEL

/obj/item/shrapnel/stingball // stingbang grenades
	name = "stingball"
	embedding = list(embed_chance=90, fall_chance=3, jostle_chance=7, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.7, pain_mult=5, jostle_pain_mult=6, rip_time=15, embed_chance_turf_mod=-100)
	icon_state = "tiny"

/obj/item/shrapnel/bullet // bullets
	name = "bullet"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	item_flags = NONE

/obj/item/shrapnel/bullet/c38 // .38 round
	name = ".38 bullet"

/obj/item/shrapnel/bullet/c38/dumdum // .38 DumDum round
	name = ".38 DumDum bullet"
	embedding = list(embed_chance=70, fall_chance=10, jostle_chance=7, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=15, embed_chance_turf_mod=-100)

/obj/projectile/bullet/shrapnel
	name = "flying shrapnel shard"
	damage = 9
	ricochets_max = 2
	ricochet_chance = 40
	shrapnel_type = /obj/item/shrapnel
	hit_stunned_targets = TRUE

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
	shrapnel_type = /obj/item/shrapnel/stingball

/obj/projectile/bullet/pellet/stingball/on_ricochet(atom/A)
	hit_stunned_targets = TRUE // ducking will save you from the first wave, but not the rebounds
