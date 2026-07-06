/**
 * Wand which makes you drunk, self-explanatory
 * As it applies a copious amount of alcohol it's actually surprisingly deadly, but not very fast at being deadly
 */

/obj/item/gun/magic/wand/booze
	name = "party wand"
	desc = "A wand which fills its target with copious amounts of alcohol. Use in moderation, unless you are \
		trying to give someone liver damage."
	school = SCHOOL_CONJURATION
	ammo_type = /obj/item/ammo_casing/magic/booze
	icon_state = "beerwand"
	base_icon_state = "beerwand"
	fire_sound = 'sound/effects/slosh.ogg'
	max_charges = 8

/obj/item/gun/magic/wand/booze/zap_self(mob/living/user, suicide = FALSE)
	playsound(user, fire_sound, 50, TRUE)
	if (!suicide)
		user.log_message("zapped [user.p_them()]self with a <b>[src]</b>", LOG_ATTACK)
		user.visible_message(span_notice("[user] puts the [src] up to [user.p_their()] mouth and starts chugging!"))
	var/obj/projectile/magic/booze/splash = new(user.drop_location())
	splash.firer = user
	user.projectile_hit(splash, BODY_ZONE_HEAD)
	qdel(splash)
	charges--

/obj/item/gun/magic/wand/booze/do_suicide(mob/living/user)
	. = ..()
	user.visible_message(span_suicide("[user] pours a constant stream of booze into [user.p_their()] mouth, [user.p_theyre()] about to pop!"))
	if (!do_after(user, 3 SECONDS, target = src))
		return SHAME
	user.Stun(5 SECONDS, ignore_canstun = TRUE)
	user.inflate_gib(DROP_ALL_REMAINS, gib_time = 2.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(flood_beer), get_turf(user)), 2.5 SECONDS, TIMER_DELETE_ME)
	return MANUAL_SUICIDE

/// Creates a beer blast when someone bursts themselves
/obj/item/gun/magic/wand/booze/proc/flood_beer(turf/flood_point)
	if (!flood_point)
		return
	var/datum/reagents/beer = new /datum/reagents(100)
	beer.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)
	beer.my_atom = flood_point
	beer.create_foam(/datum/effect_system/fluid_spread/foam, 100)

/obj/item/ammo_casing/magic/booze
	projectile_type = /obj/projectile/magic/booze

/obj/projectile/magic/booze
	name = "bolt of inebriation"
	icon_state = "energy"

/obj/projectile/magic/booze/Initialize(mapload)
	. = ..()
	create_reagents(max_vol = 10)
	reagents.add_reagent(/datum/reagent/consumable/ethanol/bacchus_blessing, 10)

/obj/projectile/magic/booze/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	reagents.trans_to(target, 10, methods = INGEST)
