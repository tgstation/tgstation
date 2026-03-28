/**
 * Prank wand knocks you over as if pied and surrounds you with space lube
 */
/obj/item/gun/magic/wand/prank
	name = "wand of pratfalls"
	desc = "A comedy wand which is sure to get a laugh out of you, if not its victims."
	school = SCHOOL_CONJURATION
	ammo_type = /obj/item/ammo_casing/magic/prank
	icon_state = "bananawand"
	base_icon_state = "bananawand"
	fire_sound = 'sound/items/bikehorn.ogg'
	max_charges = 10

/obj/item/gun/magic/wand/prank/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	var/obj/item/food/pie/cream/magical/pie = new(src)
	pie.stun_and_blur(user)
	charges--

/obj/item/gun/magic/wand/prank/do_suicide(mob/living/user)
	charges--
	playsound(user, fire_sound, 50, TRUE)
	user.visible_message("[user] covers [user.p_themselves()] with magical lube!")
	var/datum/reagents/lube = new /datum/reagents(40)
	lube.add_reagent(/datum/reagent/lube, 40)
	lube.my_atom = get_turf(user)
	lube.create_foam(/datum/effect_system/fluid_spread/foam, 40)
	user.slip(5 SECONDS)
	user.apply_status_effect(/datum/status_effect/slippery_death)
	return MANUAL_SUICIDE

/obj/item/ammo_casing/magic/prank
	projectile_type = /obj/projectile/magic/prank
	harmful = FALSE

/obj/projectile/magic/prank
	name = "bolt of pratfalls"
	icon = 'icons/obj/food/piecake.dmi'
	icon_state = "pie"

/obj/projectile/magic/prank/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/obj/item/food/pie/cream/magical/pie = new()
	pie.stun_and_blur(target)

/// This creates an extremely messy cream pie which your audience will love
/obj/item/food/pie/cream/magical

/obj/item/food/pie/cream/magical/stun_and_blur(mob/living/victim, can_splat_on)
	. = ..()
	var/datum/reagents/lube = new /datum/reagents(40)
	lube.add_reagent(/datum/reagent/lube, 40)
	lube.my_atom = get_turf(victim)
	lube.create_foam(/datum/effect_system/fluid_spread/foam, 40)
	qdel(lube)
	var/static/laugh_sound = list('sound/items/sitcom_laugh/SitcomLaugh1.ogg', 'sound/items/sitcom_laugh/SitcomLaugh2.ogg', 'sound/items/sitcom_laugh/SitcomLaugh3.ogg')
	playsound(victim, pick(laugh_sound), 100, FALSE)

/// Used by the wand suicide, keep slipping until you hit a wall and explode
/datum/status_effect/slippery_death
	alert_type = null
	tick_interval = 0.2 SECONDS
	/// What direction are we slipping in?
	var/direction

/datum/status_effect/slippery_death/on_creation(mob/living/new_owner, set_duration)
	. = ..()
	direction = pick(GLOB.cardinals)
	new_owner.setDir(direction)
	new_owner.Stun(INFINITY, ignore_canstun = TRUE)
	ADD_TRAIT(new_owner, TRAIT_IMMOBILIZED, REF(src))
	RegisterSignals(new_owner, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_LIVING_DEATH, COMSIG_LIVING_MOB_BUMP, COMSIG_LIVING_MOB_BUMPED), PROC_REF(die))

/datum/status_effect/slippery_death/tick(seconds_between_ticks)
	var/turf/turf = get_step(owner, direction)
	if(!turf || turf.is_blocked_turf())
		die()
		return
	owner.Move(turf)

/// When we hit anything, die, or change z level we burst
/datum/status_effect/slippery_death/proc/die()
	SIGNAL_HANDLER
	owner.gib(DROP_ALL_REMAINS)
	qdel(src)
