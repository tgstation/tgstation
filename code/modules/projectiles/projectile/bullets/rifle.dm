// .223 (M-90gl Carbine)

/obj/projectile/bullet/a223
	name = ".223 bullet"
	damage = 35
	armour_penetration = 30
	wound_bonus = -40

/obj/projectile/bullet/a223/weak //centcom
	damage = 20

/obj/projectile/bullet/a223/phasic
	name = ".223 phasic bullet"
	icon_state = "gaussphase"
	damage = 30
	armour_penetration = 100
	projectile_phasing =  PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS

// .310 Strilka (Sakhno Rifle)

/obj/projectile/bullet/strilka310
	name = ".310 Strilka bullet"
	damage = 60
	armour_penetration = 10
	wound_bonus = -45
	wound_falloff_tile = 0

/obj/projectile/bullet/strilka310/surplus
	name = ".310 Strilka surplus bullet"
	weak_against_armour = TRUE //this is specifically more important for fighting carbons than fighting noncarbons. Against a simple mob, this is still a full force bullet
	armour_penetration = 0

/obj/projectile/bullet/strilka310/enchanted
	name = "enchanted .310 bullet"
	damage = 20
	stamina = 80

// Harpoons (Harpoon Gun)

/obj/projectile/bullet/harpoon
	name = "harpoon"
	icon_state = "gauss"
	damage = 60
	armour_penetration = 50
	wound_bonus = -20
	bare_wound_bonus = 80
	embedding = list(embed_chance=100, fall_chance=3, jostle_chance=4, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)
	wound_falloff_tile = -5
	shrapnel_type = null

// Rebar (Rebar Crossbow)
/obj/projectile/bullet/rebar
	name = "rebar"
	icon_state = "rebar"
	damage = 30
	speed = 0.4
	dismemberment = 1 //because a 1 in 100 chance to just blow someones arm off is enough to be cool but also not enough to be reliable
	armour_penetration = 10
	wound_bonus = -20
	bare_wound_bonus = 20
	embedding = list(embed_chance=60, fall_chance=2, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=3, jostle_pain_mult=2, rip_time=10)
	embed_falloff_tile = -5
	wound_falloff_tile = -2
	shrapnel_type = /obj/item/ammo_casing/rebar

/obj/projectile/bullet/rebarsyndie
	name = "rebar"
	icon_state = "rebar"
	damage = 55
	speed = 0.4
	dismemberment = 2 //It's a budget sniper rifle.
	armour_penetration = 20 //A bit better versus armor. Gets past anti laser armor or a vest, but doesnt wound proc on sec armor.
	wound_bonus = 10
	bare_wound_bonus = 30
	embedding = list(embed_chance=80, fall_chance=1, jostle_chance=3, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=3, jostle_pain_mult=2, rip_time=14)
	embed_falloff_tile = -3
	shrapnel_type = /obj/item/ammo_casing/rebar/syndie
	var/modified = FALSE
	var/obj/item/pen/pen = null

/obj/projectile/bullet/rebar/zaukerite
	name = "zaukerite shard"
	icon_state = "rebar_zaukerite"
	damage = 60
	speed = 0.6
	dismemberment = 2
	damage_type = TOX
	eyeblur = 5
	armour_penetration = 30
	wound_bonus = 0
	bare_wound_bonus = 20
	embedding = list(embed_chance=90, fall_chance=0, jostle_chance=5, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.8, pain_mult=6, jostle_pain_mult=2, rip_time=30)
	embed_falloff_tile = -5
	shrapnel_type = /obj/item/ammo_casing/rebar/zaukerite

/obj/projectile/bullet/rebar/hydrogen
	name = "metallic hydrogen bolt"
	icon_state = "rebar_hydrogen"
	damage = 40
	speed = 0.4
	dismemberment = 2
	damage_type = BRUTE
	armour_penetration = 16
	wound_bonus = -15
	bare_wound_bonus = 30
	embedding = list(embed_chance = 70, fall_chance=1, jostle_chance=3, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.6, pain_mult=4, jostle_pain_mult=2, rip_time=18)
	embed_falloff_tile = -3
	shrapnel_type = /obj/item/ammo_casing/rebar/hydrogen

/obj/projectile/bullet/rebar/healium
	name = "healium bolt"
	icon_state = "rebar_hydrogen"
	damage = 0
	speed = 0.4
	dismemberment = 0
	damage_type = BRUTE
	armour_penetration = 100
	wound_bonus = -100
	bare_wound_bonus = -100
	embedding = list(embed_chance = 0)
	embed_falloff_tile = -3
	shrapnel_type = /obj/item/ammo_casing/rebar/healium

/obj/projectile/bullet/rebar/healium/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/breather = target
		breather.SetSleeping(3 SECONDS)
		var/need_mob_update
		need_mob_update = breather.adjustFireLoss(-30, updating_health = TRUE, required_bodytype = BODYTYPE_ORGANIC)
		need_mob_update += breather.adjustToxLoss(-30, updating_health = TRUE, required_biotype = BODYTYPE_ORGANIC)
		need_mob_update += breather.adjustBruteLoss(-30, updating_health = TRUE, required_bodytype = BODYTYPE_ORGANIC)
		need_mob_update += breather.adjustOxyLoss(-30, updating_health = TRUE, required_biotype = BODYTYPE_ORGANIC, required_respiration_type = ALL)
		if(need_mob_update)
			return UPDATE_MOB_HEALTH


	return BULLET_ACT_HIT


/obj/projectile/bullet/rebar/supermatter
	name = "supermatter bolt"
	icon_state = "rebar_supermatter"
	damage = 0
	speed = 0.4
	dismemberment = 0
	damage_type = TOX
	armour_penetration = 100
	shrapnel_type = /obj/item/ammo_casing/rebar/supermatter

/obj/projectile/bullet/rebar/supermatter/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/victim = target
		victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		dust_feedback(target)
		victim.dust()

	if(!isturf(target))
		dust_feedback(target)
		qdel(target)
	return BULLET_ACT_HIT


/obj/projectile/bullet/rebar/supermatter/proc/dust_feedback(atom/target)
	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 10, TRUE)
	visible_message(span_danger("[src] is hit by [target], turning [target.p_them()] to dust in a brilliant flash of light!"))

/obj/projectile/bullet/rebar/Initialize(mapload)
	. = ..()
	RegisterSignals(src, list(COMSIG_PROJECTILE_ON_SPAWN_DROP, COMSIG_PROJECTILE_ON_SPAWN_EMBEDDED), PROC_REF(handle_drop))

/obj/projectile/bullet/rebar/proc/handle_drop(datum/source, obj/item/ammo_casing/rebar/newcasing)
	SIGNAL_HANDLER

/obj/projectile/bullet/paperball
	desc = "Doink!"
	damage = 0 // It's a damn toy.
	range = 10
	shrapnel_type = null
	embedding = null
	name = "paper ball"
	desc = "doink!"
	damage_type = BRUTE
	icon = 'icons/obj/weapons/guns/toy.dmi'
	icon_state = "paperball"

//obj/projectile/bullet/paperball/proc/handle_drop(datum/source, obj/item/ammo_casing/paperball/newcasing)
	//SIGNAL_HANDLER
