/obj/item/gun/magic/wand
	name = "wand"
	desc = "You shouldn't have this."
	ammo_type = /obj/item/ammo_casing/magic
	icon_state = "nothingwand"
	inhand_icon_state = "wand"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	base_icon_state = "nothingwand"
	w_class = WEIGHT_CLASS_SMALL
	self_charging = FALSE
	max_charges = 100 //100, 50, 50, 34 (max charge distribution by 25%ths)
	/// If true, we have a 25% chance of listed max charges, 50% chance of 1/2 max charges, 25% chance of 1/3 max charges
	var/variable_charges = TRUE

/obj/item/gun/magic/wand/Initialize(mapload)
	if (!variable_charges || prob(25))
		return ..()

	if(prob(33)) // 33% of the remaining 75% so another 25%
		max_charges = CEILING(max_charges / 3, 1)
	else
		max_charges = CEILING(max_charges / 2, 1)
	return ..()

/obj/item/gun/magic/wand/examine(mob/user)
	. = ..()
	. += "Has [charges] charge\s remaining."

/obj/item/gun/magic/wand/update_icon_state()
	icon_state = "[base_icon_state][charges ? null : "-drained"]"
	return ..()

/obj/item/gun/magic/wand/attack(atom/target, mob/living/user)
	if(target == user)
		return
	return ..()

/obj/item/gun/magic/wand/try_fire_gun(atom/target, mob/living/user, params)
	if(!charges)
		shoot_with_empty_chamber(user)
		return FALSE
	if(target == user)
		if(no_den_usage && istype(get_area(user), /area/centcom/wizard_station))
			to_chat(user, span_warning("You know better than to violate the security of The Den, best wait until you leave to use [src]."))
			return FALSE
		zap_self(user)
		. = TRUE

	else
		. = ..()

	if(.)
		update_appearance()
	return .

/// Called if we poke ourselves with the wand
/obj/item/gun/magic/wand/proc/zap_self(mob/living/user, suicide = FALSE)
	user.visible_message(span_danger("[user] zaps [user.p_them()]self with [src]."))
	playsound(user, fire_sound, 50, TRUE)
	user.log_message("zapped [user.p_them()]self with a <b>[src]</b>", LOG_ATTACK)

/obj/item/gun/magic/wand/do_suicide(mob/living/user)
	zap_self(user, suicide = TRUE)
	return FIRELOSS

/// Wand which kills people and heals skeletons
/obj/item/gun/magic/wand/death
	name = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, slaying them without fail."
	school = SCHOOL_NECROMANCY
	fire_sound = 'sound/effects/magic/wandodeath.ogg'
	ammo_type = /obj/item/ammo_casing/magic/death
	icon_state = "deathwand"
	base_icon_state = "deathwand"
	max_charges = 3 //3, 2, 2, 1

/obj/item/gun/magic/wand/death/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	charges--
	if(user.can_block_magic())
		user.visible_message(span_warning("[src] has no effect on [user]!"))
		return
	if(isliving(user))
		if(user.mob_biotypes & MOB_UNDEAD) //negative energy heals the undead
			user.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE) // This heals suicides
			if (!suicide)
				to_chat(user, span_notice("You feel great!"))
			return
	to_chat(user, span_warning("You irradiate yourself with pure negative energy! \
	[pick("Do not pass go. Do not collect 200 zorkmids.","You feel more confident in your spell casting skills.","You die...","Do you want your possessions identified?")]"))
	user.death(FALSE)

/obj/item/gun/magic/wand/death/do_suicide(mob/living/user)
	. = ..()
	if (user.stat == DEAD)
		return MANUAL_SUICIDE
	user.visible_message(span_suicide("...but if anything [user.p_they()] look healthier than before."))
	return SHAME

/obj/item/gun/magic/wand/death/debug
	desc = "In some obscure circles, this is known as the 'cloning tester's friend'."
	max_charges = 500
	variable_charges = FALSE
	self_charging = TRUE
	recharge_rate = 1


/// Wand which kills skeletons and heals people
/obj/item/gun/magic/wand/resurrection
	name = "wand of healing"
	desc = "This wand uses healing magics to heal and revive. They are rarely utilized within the Wizard Federation for some reason."
	school = SCHOOL_RESTORATION
	ammo_type = /obj/item/ammo_casing/magic/heal
	fire_sound = 'sound/effects/magic/staff_healing.ogg'
	icon_state = "revivewand"
	base_icon_state = "revivewand"
	max_charges = 10 //10, 5, 5, 4

/obj/item/gun/magic/wand/resurrection/zap_self(mob/living/user, suicide = FALSE)
	..()
	charges--
	if(user.can_block_magic())
		user.visible_message(span_warning("[src] has no effect on [user]!"))
		return
	if(isliving(user))
		var/mob/living/L = user
		if(L.mob_biotypes & MOB_UNDEAD) //positive energy harms the undead
			to_chat(user, span_warning("You irradiate yourself with pure positive energy! \
			[pick("Do not pass go. Do not collect 200 zorkmids.","You feel more confident in your spell casting skills.","You die...","Do you want your possessions identified?")]"))
			user.investigate_log("has been killed by a bolt of resurrection.", INVESTIGATE_DEATHS)
			user.death(FALSE)
			return
	user.revive(ADMIN_HEAL_ALL, force_grab_ghost = TRUE) // This heals suicides
	if (!suicide)
		to_chat(user, span_notice("You feel great!"))

/obj/item/gun/magic/wand/resurrection/do_suicide(mob/living/user)
	. = ..()
	if (user.stat == DEAD)
		return MANUAL_SUICIDE
	user.visible_message(span_suicide("...but if anything [user.p_they()] look healthier than before."))
	return SHAME

/obj/item/gun/magic/wand/resurrection/debug //for testing
	desc = "Is it possible for something to be even more powerful than regular magic? This wand is."
	max_charges = 500
	variable_charges = FALSE
	self_charging = TRUE
	recharge_rate = 1

/// Wand which turns mobs into other mobs
/obj/item/gun/magic/wand/polymorph
	name = "wand of polymorph"
	desc = "This wand is attuned to chaos and will radically alter the victim's form."
	school = SCHOOL_TRANSMUTATION
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "polywand"
	base_icon_state = "polywand"
	fire_sound = 'sound/effects/magic/staff_change.ogg'
	max_charges = 10 //10, 5, 5, 4

/obj/item/gun/magic/wand/polymorph/zap_self(mob/living/user, suicide = FALSE)
	. = ..() //because the user mob ceases to exists by the time wabbajack fully resolves
	user.wabbajack()
	charges--

/obj/item/gun/magic/wand/polymorph/do_suicide(mob/living/user)
	var/static/list/corpse_types = list(
		/obj/effect/decal/cleanable/insectguts,
		/obj/item/food/deadmouse,
		/obj/item/trash/bee,
	)
	playsound(loc, fire_sound, 50, TRUE, -1)
	var/corpse_path = pick(corpse_types)
	var/atom/corpse = new corpse_path(user.drop_location())
	corpse.name = user.real_name
	user.unequip_everything()
	user.ghostize()
	qdel(user)
	return MANUAL_SUICIDE

/// Wand of go somewhere else
/obj/item/gun/magic/wand/teleport
	name = "wand of teleportation"
	desc = "This wand will wrench targets through space and time to move them somewhere else."
	school = SCHOOL_TRANSLOCATION
	ammo_type = /obj/item/ammo_casing/magic/teleport
	fire_sound = 'sound/effects/magic/wand_teleport.ogg'
	icon_state = "telewand"
	base_icon_state = "telewand"
	max_charges = 10 //10, 5, 5, 4
	no_den_usage = TRUE

/obj/item/gun/magic/wand/teleport/zap_self(mob/living/user, suicide = FALSE)
	if(do_teleport(user, user, 10, channel = TELEPORT_CHANNEL_MAGIC))
		var/datum/effect_system/fluid_spread/smoke/smoke = new
		smoke.set_up(3, holder = src, location = user.loc)
		smoke.start()
		charges--
	return ..()

/obj/item/gun/magic/wand/teleport/do_suicide(mob/living/user)
	playsound(loc, fire_sound, 50, TRUE, -1)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(3, holder = src, location = user.loc)
	smoke.start()
	if (!iscarbon(user))
		return SHAME

	var/mob/living/carbon/suicider = user
	var/obj/item/teleport_part = suicider.get_organ_slot(ORGAN_SLOT_BRAIN)
	if (!teleport_part)
		teleport_part = suicider.get_bodypart(BODY_ZONE_HEAD)
	if (!teleport_part)
		return SHAME

	var/turf/destination = user.drop_location() // Grab this first in case moving the brain out dusts you or something

	if (isorgan(teleport_part))
		var/obj/item/organ/brain = teleport_part
		brain.Remove(user, special = FALSE)
	else
		var/obj/item/bodypart/head = teleport_part
		head.dismember(BRUTE)

	teleport_part.forceMove(destination)
	do_teleport(teleport_part, destination, 10, channel = TELEPORT_CHANNEL_MAGIC)
	if (user.stat != DEAD)
		return SHAME
	return MANUAL_SUICIDE

/// Wand of go somewhere else which is safe-ish
/obj/item/gun/magic/wand/safety
	name = "wand of safety"
	desc = "This wand will use the lightest of bluespace currents to gently place the target somewhere safe."
	school = SCHOOL_TRANSLOCATION
	ammo_type = /obj/item/ammo_casing/magic/safety
	fire_sound = 'sound/effects/magic/wand_teleport.ogg'
	icon_state = "telewand"
	base_icon_state = "telewand"
	max_charges = 10 //10, 5, 5, 4
	no_den_usage = FALSE

/obj/item/gun/magic/wand/safety/zap_self(mob/living/user, suicide = FALSE)
	var/turf/origin = get_turf(user)
	var/turf/destination = find_safe_turf(extended_safety_checks = TRUE)

	if(do_teleport(user, destination, channel=TELEPORT_CHANNEL_MAGIC))
		for(var/t in list(origin, destination))
			var/datum/effect_system/fluid_spread/smoke/smoke = new
			smoke.set_up(0, holder = src, location = t)
			smoke.start()
	return ..()

/obj/item/gun/magic/wand/safety/do_suicide(mob/living/user)
	. = ..()
	return SHAME // It's a safety wand sorry

/obj/item/gun/magic/wand/safety/debug
	desc = "This wand has 'find_safe_turf()' engraved into its blue wood. Perhaps it's a secret message?"
	max_charges = 500
	variable_charges = FALSE
	self_charging = TRUE
	recharge_rate = 1


/// Wand of making doors
/obj/item/gun/magic/wand/door
	name = "wand of door creation"
	desc = "This particular wand can create doors in any wall for the unscrupulous wizard who shuns teleportation magics."
	school = SCHOOL_TRANSMUTATION
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "doorwand"
	base_icon_state = "doorwand"
	fire_sound = 'sound/effects/magic/staff_door.ogg'
	max_charges = 20 //20, 10, 10, 7
	no_den_usage = TRUE

/obj/item/gun/magic/wand/door/zap_self(mob/living/user, suicide = FALSE)
	to_chat(user, span_notice("You feel vaguely more open with your feelings."))
	charges--
	return ..()

/obj/item/gun/magic/wand/door/do_suicide(mob/living/user)
	if (!iscarbon(user))
		. = ..()
		var/static/list/shared_feelings = list(
			"I can't take it any more!!",
			"I can't do this any more!!",
			"I don't want to live in this world!!",
			"I wish I was dead!!",
			"Nothing matters to me any more!!",
			"Someone please kill me!!",
			"The pain is unbearable!!",
		)
		user.say(pick(shared_feelings), forced = "failed wand suicide")
		return SHAME
	playsound(loc, fire_sound, 50, TRUE, -1)
	var/mob/living/carbon/suicider = user
	var/obj/item/bodypart/chest = suicider.get_bodypart(BODY_ZONE_CHEST) // I think it's impossible not to have a chest so we'll just assume they have one
	user.visible_message(span_suicide("[user]'s chest swings open like a door!"))
	chest.dismember(BRUTE, silent = FALSE, wounding_type = WOUND_SLASH)
	return BRUTELOSS

/// Wand of blowing shit up
/obj/item/gun/magic/wand/fireball
	name = "wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames."
	school = SCHOOL_EVOCATION
	fire_sound = 'sound/effects/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/fireball
	icon_state = "firewand"
	base_icon_state = "firewand"
	max_charges = 8 //8, 4, 4, 3

/obj/item/gun/magic/wand/fireball/zap_self(mob/living/user, suicide = FALSE)
	..()
	explosion(user, devastation_range = -1, light_impact_range = 2, flame_range = 2, flash_range = 3, adminlog = FALSE, explosion_cause = src)
	charges--

/// Wand of doing fuck all
/obj/item/gun/magic/wand/nothing
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick?"
	ammo_type = /obj/item/ammo_casing/magic/nothing

/obj/item/gun/magic/wand/nothing/do_suicide(mob/living/user)
	. = ..()
	return SHAME

/// Wand of making things small
/obj/item/gun/magic/wand/shrink
	name = "wand of shrinking"
	desc = "Feel the tiny eldritch terror of an itty... bitty... head!"
	ammo_type = /obj/item/ammo_casing/magic/shrink/wand
	icon_state = "shrinkwand"
	base_icon_state = "shrinkwand"
	fire_sound = 'sound/effects/magic/staff_shrink.ogg'
	max_charges = 10 //10, 5, 5, 4
	no_den_usage = TRUE
	w_class = WEIGHT_CLASS_TINY

/obj/item/gun/magic/wand/shrink/zap_self(mob/living/user, suicide = FALSE)
	to_chat(user, span_notice("The world grows large..."))
	charges--
	user.AddComponent(/datum/component/shrink, -1) // small forever
	return ..()

/obj/item/gun/magic/wand/shrink/do_suicide(mob/living/user)
	playsound(user, fire_sound, 50, TRUE)
	user.unequip_everything()
	user.visible_message(span_suicide("[user] shrinks into nothing!"), span_suicide("You shrink into nothing!"))
	user.Stun(20 SECONDS, ignore_canstun = TRUE)
	user.set_suicide(TRUE)
	user.ghostize()
	animate(user, transform = matrix() * 0, time = 1 SECONDS)
	QDEL_IN(user, 1 SECONDS)
	return MANUAL_SUICIDE

// Wands of debugging

#ifdef TESTING

/obj/item/gun/magic/wand/antag
	name = "wand of antag"
	desc = "This wand uses the powers of bullshit to turn anyone it hits into an antag"
	school = SCHOOL_FORBIDDEN
	ammo_type = /obj/item/ammo_casing/magic/antag
	icon_state = "revivewand"
	base_icon_state = "revivewand"
	color = COLOR_ADMIN_PINK
	max_charges = 99999

/obj/item/gun/magic/wand/antag/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	var/obj/item/ammo_casing/magic/antag/casing = new ammo_type()
	var/obj/projectile/magic/magic_proj = casing.projectile_type
	magic_proj = new magic_proj(src)
	magic_proj.on_hit(user)
	QDEL_NULL(casing)

/obj/item/ammo_casing/magic/antag
	projectile_type = /obj/projectile/magic/antag
	harmful = FALSE

/obj/projectile/magic/antag
	name = "bolt of antag"
	icon_state = "ion"
	var/antag = /datum/antagonist/traitor

/obj/projectile/magic/antag/on_hit(atom/target, blocked, pierce_hit)
	. = ..()

	if(isliving(target))
		var/mob/living/victim = target
		if(isnull(victim.mind))
			victim.mind_initialize()
		if(victim.mind.has_antag_datum(antag))
			victim.mind.remove_antag_datum(antag)
			to_chat(world, "removed")
		else
			victim.mind.add_antag_datum(antag)
			to_chat(world, "added")

/obj/item/gun/magic/wand/antag/heretic
	name = "wand of antag heretic"
	desc = "This wand uses the powers of bullshit to turn anyone it hits into an antag heretic"
	color = COLOR_GREEN
	ammo_type = /obj/item/ammo_casing/magic/antag/heretic

/obj/item/ammo_casing/magic/antag/heretic
	projectile_type = /obj/projectile/magic/antag/heretic

/obj/projectile/magic/antag/heretic
	name = "bolt of antag heretic"
	icon_state = "ion"
	antag = /datum/antagonist/heretic

/obj/item/gun/magic/wand/antag/cult
	name = "wand of antag cultist"
	desc = "This wand uses the powers of bullshit to turn anyone it hits into an antag cultist"
	color = COLOR_CULT_RED
	ammo_type = /obj/item/ammo_casing/magic/antag/cult

/obj/item/ammo_casing/magic/antag/cult
	projectile_type = /obj/projectile/magic/antag/cult

/obj/projectile/magic/antag/cult
	name = "bolt of antag cult"
	icon_state = "ion"
	antag = /datum/antagonist/cult

#endif
