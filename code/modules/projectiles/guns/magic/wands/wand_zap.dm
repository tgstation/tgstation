/**
 * It's just a classic taser
 */
/obj/item/gun/magic/wand/zap
	name = "wand of zapping"
	desc = "This wand overloads the nerves of your enemies with potent lightning."
	school = SCHOOL_EVOCATION
	ammo_type = /obj/item/ammo_casing/magic/zap
	icon_state = "teslawand"
	base_icon_state = "teslawand"
	fire_sound = 'sound/items/weapons/taser.ogg'
	max_charges = 8

/obj/item/gun/magic/wand/zap/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	do_sparks(1, TRUE, src)
	var/obj/projectile/magic/zap/spark = new(user.drop_location())
	spark.firer = user
	user.projectile_hit(spark, BODY_ZONE_CHEST)
	qdel(spark)
	charges--

/obj/item/gun/magic/wand/zap/do_suicide(mob/living/user)
	charges--
	playsound(user, fire_sound, 50, TRUE)
	do_sparks(2, TRUE, user)
	user.electrocute_act(0, src, siemens_coeff = 1, flags = SHOCK_IGNORE_IMMUNITY|SHOCK_DELAY_STUN|SHOCK_NOGLOVES)
	tesla_zap(source = user, zap_range = 5, power = 2.5e4, cutoff = 1e3)
	return FIRELOSS

/obj/item/ammo_casing/magic/zap
	projectile_type = /obj/projectile/magic/zap

/// A magic taser electrode
/obj/projectile/magic/zap
	name = "spark"
	icon_state = "spark"
	color = COLOR_YELLOW
	paralyze = 10 SECONDS
	stutter = 10 SECONDS
	jitter = 40 SECONDS
	hitsound = 'sound/items/weapons/taserhit.ogg'
	range = 7
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = /obj/effect/projectile/muzzle/stun
	impact_type = /obj/effect/projectile/impact/stun

/obj/projectile/magic/zap/on_hit(mob/living/target, blocked = 0, pierce_hit)
	. = ..()
	if (!istype(target) || blocked >= 100)
		do_sparks(1, TRUE, src)
		return

	target.add_mood_event("tased", /datum/mood_event/tased)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK) // We really sending this signal from like 8 places huh?
	if(!target.check_stun_immunity(CANKNOCKDOWN))
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, do_jitter_animation), 20), 0.5 SECONDS)

/obj/projectile/magic/zap/on_range()
	do_sparks(1, TRUE, src)
	return ..()
