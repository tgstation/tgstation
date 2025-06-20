#define MAX_BLOOD_LEVEL 100

/obj/item/soulscythe
	name = "soulscythe"
	desc = "An old relic of hell created by devils to establish themselves as the leadership of hell over the demons. It grows stronger while it possesses a powerful soul."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "soulscythe"
	inhand_icon_state = "soulscythe"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	attack_verb_continuous = list("chops", "slices", "cuts", "reaps")
	attack_verb_simple = list("chop", "slice", "cut", "reap")
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 20
	throwforce = 17
	armour_penetration = 50
	sharpness = SHARP_EDGED
	exposed_wound_bonus = 10
	layer = MOB_LAYER
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Soulscythe mob in the scythe
	var/mob/living/basic/soulscythe/soul
	/// Are we grabbing a spirit?
	var/using = FALSE
	/// Currently charging?
	var/charging = FALSE
	/// Cooldown between moves
	COOLDOWN_DECLARE(move_cooldown)
	/// Cooldown between attacks
	COOLDOWN_DECLARE(attack_cooldown)

/obj/item/soulscythe/Initialize(mapload)
	. = ..()
	soul = new(src)
	RegisterSignal(soul, COMSIG_LIVING_RESIST, PROC_REF(on_resist))
	RegisterSignal(soul, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_attack))
	RegisterSignal(soul, COMSIG_MOB_ATTACK_RANGED_SECONDARY, PROC_REF(on_secondary_attack))
	RegisterSignal(src, COMSIG_ATOM_INTEGRITY_CHANGED, PROC_REF(on_integrity_change))
	AddElement(/datum/element/bane, mob_biotypes = MOB_PLANT, damage_multiplier = 0.5, requires_combat_mode = FALSE)

/obj/item/soulscythe/examine(mob/user)
	. = ..()
	. += soul.ckey ? span_nicegreen("There is a soul inhabiting it.") : span_danger("It's dormant.")

/obj/item/soulscythe/attack(mob/living/attacked, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(attacked.stat != DEAD)
		give_blood(10)

/obj/item/soulscythe/attack_hand(mob/user, list/modifiers)
	if(soul.ckey && !soul.faction_check_atom(user))
		to_chat(user, span_warning("You can't pick up [src]!"))
		return
	return ..()

/obj/item/soulscythe/pickup(mob/user)
	. = ..()
	if(soul.ckey)
		animate(src) //stop spinnage

/obj/item/soulscythe/dropped(mob/user, silent)
	. = ..()
	if(soul.ckey)
		reset_spin() //resume spinnage

/obj/item/soulscythe/attack_self(mob/user, modifiers)
	if(using || soul.ckey || soul.stat)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		balloon_alert(user, "you can't awaken the scythe!")
		return
	using = TRUE
	balloon_alert(user, "you hold the scythe up...")
	ADD_TRAIT(src, TRAIT_NODROP, type)
	var/mob/chosen_one = SSpolling.poll_ghosts_for_target(
		check_jobban = ROLE_PAI,
		poll_time = 20 SECONDS,
		checked_target = src,
		ignore_category = POLL_IGNORE_POSSESSED_BLADE,
		alert_pic = src,
		role_name_text = "soulscythe soul",
		chat_text_border_icon = src,
	)
	on_poll_concluded(user, chosen_one)

/// Ghost poll has concluded and a candidate has been chosen.
/obj/item/soulscythe/proc/on_poll_concluded(mob/living/master, mob/dead/observer/ghost)
	if(isnull(ghost))
		balloon_alert(master, "the scythe is dormant!")
		REMOVE_TRAIT(src, TRAIT_NODROP, type)
		using = FALSE
		return

	soul.PossessByPlayer(ghost.ckey)
	soul.copy_languages(master, LANGUAGE_MASTER) //Make sure the sword can understand and communicate with the master.
	soul.faction = list("[REF(master)]")
	balloon_alert(master, "the scythe glows")
	add_overlay("soulscythe_gem")
	density = TRUE
	if(!ismob(loc))
		reset_spin()

	REMOVE_TRAIT(src, TRAIT_NODROP, type)
	using = FALSE

/obj/item/soulscythe/relaymove(mob/living/user, direction)
	if(!COOLDOWN_FINISHED(src, move_cooldown) || charging)
		return
	if(!isturf(loc))
		balloon_alert(user, "resist out!")
		COOLDOWN_START(src, move_cooldown, 1 SECONDS)
		return
	if(!use_blood(1, FALSE))
		return
	if(pixel_x != base_pixel_x || pixel_y != base_pixel_y)
		animate(src, 0.2 SECONDS, pixel_x = base_pixel_y, pixel_y = base_pixel_y, flags = ANIMATION_PARALLEL)
	try_step_multiz(direction)
	COOLDOWN_START(src, move_cooldown, (direction in GLOB.cardinals) ? 0.1 SECONDS : 0.2 SECONDS)

/obj/item/soulscythe/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!charging)
		return
	charging = FALSE
	throwforce *= 0.5
	reset_spin()
	if(ismineralturf(hit_atom))
		var/turf/closed/mineral/hit_rock = hit_atom
		hit_rock.gets_drilled()
	if(isliving(hit_atom))
		var/mob/living/hit_mob = hit_atom
		if(hit_mob.stat != DEAD)
			give_blood(15)

/obj/item/soulscythe/AllowClick()
	return TRUE

/obj/item/soulscythe/proc/use_blood(amount = 0, message = TRUE)
	if(amount > soul.blood_volume)
		if(message)
			to_chat(soul, span_warning("Not enough blood!"))
		return FALSE
	soul.blood_volume -= amount
	return TRUE

/obj/item/soulscythe/proc/give_blood(amount)
	soul.blood_volume = min(MAX_BLOOD_LEVEL, soul.blood_volume + amount)

/obj/item/soulscythe/proc/on_resist(mob/living/user)
	SIGNAL_HANDLER

	if(isturf(loc))
		return
	INVOKE_ASYNC(src, PROC_REF(break_out))

/obj/item/soulscythe/proc/break_out()
	if(!use_blood(10))
		return
	balloon_alert(soul, "you resist...")
	if(!do_after(soul, 5 SECONDS, target = src, timed_action_flags = IGNORE_TARGET_LOC_CHANGE))
		balloon_alert(soul, "interrupted!")
		return
	balloon_alert(soul, "you break out")
	if(ismob(loc))
		var/mob/holder = loc
		holder.temporarilyRemoveItemFromInventory(src)
	forceMove(drop_location())

/obj/item/soulscythe/proc/on_integrity_change(datum/source, old_value, new_value)
	SIGNAL_HANDLER

	soul.set_health(new_value)

/obj/item/soulscythe/proc/on_attack(mob/living/source, atom/attacked_atom, modifiers)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, attack_cooldown) || !isturf(loc))
		return
	if(get_dist(source, attacked_atom) > 1)
		INVOKE_ASYNC(src, PROC_REF(shoot_target), attacked_atom)
	else
		INVOKE_ASYNC(src, PROC_REF(slash_target), attacked_atom)

/obj/item/soulscythe/proc/on_secondary_attack(mob/living/source, atom/attacked_atom, modifiers)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, attack_cooldown) || !isturf(loc))
		return
	INVOKE_ASYNC(src, PROC_REF(charge_target), attacked_atom)

/obj/item/soulscythe/proc/shoot_target(atom/attacked_atom)
	if(!use_blood(15))
		return
	COOLDOWN_START(src, attack_cooldown, 3 SECONDS)
	var/obj/projectile/projectile = new /obj/projectile/soulscythe(get_turf(src))
	projectile.aim_projectile(attacked_atom, src)
	projectile.firer = src
	projectile.fire(null, attacked_atom)
	visible_message(span_danger("[src] fires at [attacked_atom]!"), span_notice("You fire at [attacked_atom]!"))
	playsound(src, 'sound/effects/magic/fireball.ogg', 50, TRUE)

/obj/item/soulscythe/proc/slash_target(atom/attacked_atom)
	if(isliving(attacked_atom) && use_blood(10))
		var/mob/living/attacked_mob = attacked_atom
		if(attacked_mob.stat != DEAD)
			give_blood(15)
		attacked_mob.apply_damage(damage = force * (ismining(attacked_mob) ? 2 : 1), sharpness = SHARP_EDGED, exposed_wound_bonus = 5)
		to_chat(attacked_mob, span_userdanger("You're slashed by [src]!"))
	else if((ismachinery(attacked_atom) || isstructure(attacked_atom)) && use_blood(5))
		var/obj/attacked_obj = attacked_atom
		attacked_obj.take_damage(force, BRUTE, MELEE, FALSE)
	else
		return
	COOLDOWN_START(src, attack_cooldown, 1 SECONDS)
	animate(src)
	SpinAnimation(5)
	addtimer(CALLBACK(src, PROC_REF(reset_spin)), 1 SECONDS)
	visible_message(span_danger("[src] slashes [attacked_atom]!"), span_notice("You slash [attacked_atom]!"))
	playsound(src, 'sound/items/weapons/bladeslice.ogg', 50, TRUE)
	do_attack_animation(attacked_atom, ATTACK_EFFECT_SLASH)

/obj/item/soulscythe/proc/charge_target(atom/attacked_atom)
	if(charging || !use_blood(30))
		return
	COOLDOWN_START(src, attack_cooldown, 5 SECONDS)
	animate(src)
	charging = TRUE
	visible_message(span_danger("[src] starts charging..."))
	balloon_alert(soul, "you start charging...")
	if(!do_after(soul, 2 SECONDS, target = src, timed_action_flags = IGNORE_TARGET_LOC_CHANGE))
		balloon_alert(soul, "interrupted!")
		return
	visible_message(span_danger("[src] charges at [attacked_atom]!"), span_notice("You charge at [attacked_atom]!"))
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/items/weapons/thudswoosh.ogg', 50, TRUE)
	SpinAnimation(1)
	throwforce *= 2
	throw_at(attacked_atom, 10, 3, soul, FALSE)

/obj/item/soulscythe/proc/reset_spin()
	animate(src)
	SpinAnimation(15)

/obj/item/soulscythe/Destroy(force)
	soul.ghostize()
	QDEL_NULL(soul)
	return ..()

/// Soulscythe mob, just a way for players to control the scythe.
/mob/living/basic/soulscythe
	name = "mysterious spirit"
	maxHealth = 200
	health = 200
	gender = NEUTER
	mob_biotypes = MOB_SPIRIT
	faction = list()
	blood_volume = MAX_BLOOD_LEVEL
	hud_type = /datum/hud/soulscythe

/mob/living/basic/soulscythe/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), ROUNDSTART_TRAIT)
	RegisterSignal(src, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/mob/living/basic/soulscythe/proc/on_life(datum/source, seconds_per_tick, times_fired) // done like this because there's no need to go through all of life since the item does the work anyways
	if(stat == CONSCIOUS)
		blood_volume = min(MAX_BLOOD_LEVEL, blood_volume + round(1 * seconds_per_tick))
	return COMPONENT_LIVING_CANCEL_LIFE_PROCESSING

/// Special projectile for the soulscythe.
/obj/projectile/soulscythe
	name = "soulslash"
	icon_state = "soulslash"
	armor_flag = MELEE //jokair
	damage = 15
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_BLOOD_MAGIC

/obj/projectile/soulscythe/on_hit(atom/target, blocked = 0, pierce_hit)
	if (isliving(target))
		var/mob/living/as_living = target
		if (ismining(as_living))
			damage *= 2
	return ..()

#undef MAX_BLOOD_LEVEL
