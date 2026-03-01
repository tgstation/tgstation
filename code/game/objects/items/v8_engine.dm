#define ENGINE_COOLDOWN 5 SECONDS
#define SLASH_COOLDOWN 1.2 SECONDS
#define SLASH_WINDUP 1 SECONDS
#define CHARGE_DAMAGE_MOD 10
#define HOUSE_EDGE_ICONS_MAX 3
#define HOUSE_EDGE_ICONS_MIN 0

/**
 * File for the House Edge sword and the V8 Engine, obtained from the black market.
 */

/obj/item/v8_engine
	name = "ancient engine"
	desc = "An extremely well-preserved, massive V8 engine from the early 2000s. It seems to be missing the rest of the vehicle. There's a tiny label on the side."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "v8_engine"
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	throwforce = 15
	throw_range = 1
	throw_speed = 1
	COOLDOWN_DECLARE(engine_sound_cooldown)

/obj/item/v8_engine/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_unwielded=5, force_wielded=5)

/obj/item/v8_engine/attack_self(mob/user, modifiers)
	. = ..()
	if (!COOLDOWN_FINISHED(src, engine_sound_cooldown))
		return
	playsound(src, 'sound/items/car_engine_start.ogg', vol = 75, vary = FALSE, extrarange = 3)
	Shake(duration = ENGINE_COOLDOWN)
	to_chat(user, span_notice("Darn thing... it's too old to keep on without retrofitting it! Without modifications, it works like it's junk."))
	COOLDOWN_START(src, engine_sound_cooldown, ENGINE_COOLDOWN)

/obj/item/v8_engine/examine_more(mob/user)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(start_learning_recipe), user)

/obj/item/v8_engine/proc/start_learning_recipe(mob/user)
	if(!user.mind)
		return
	if(user.mind.has_crafting_recipe(user = user, potential_recipe = /datum/crafting_recipe/house_edge))
		return
	to_chat(user, span_notice("You peer at the label on the side, reading about some unique modifications that could be made to the engine..."))
	if(do_after(user, 15 SECONDS, src))
		user.mind.teach_crafting_recipe(/datum/crafting_recipe/house_edge)
		to_chat(user, span_notice("You learned how to make the House Edge."))

/obj/item/house_edge
	name = "House Edge"
	desc = "Dangerous. Loud. Sleek. It has a built in roulette wheel. This thing could easily rip your arm off if you're not careful."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "house_edge"
	base_icon_state = "house_edge"
	inhand_icon_state = "house_edge"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	force = 12
	throwforce = 10
	throw_range = 5
	throw_speed = 1
	armour_penetration = 15
	hitsound = 'sound/items/car_engine_start.ogg'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 14, /datum/material/cardboard = SHEET_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.8)
	/// The number of charges the house edge has accrued through 2-handed hits, to charge a more powerful charge attack.
	var/fire_charges = 0
	///Sound played when wielded.
	var/active_hitsound = 'sound/items/house_edge_hit.ogg'
	///Datum that tracks weapon dashing for the fire_charge system
	var/datum/action/innate/dash/charge
	COOLDOWN_DECLARE(fire_charge_cooldown)

/obj/item/house_edge/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 12, force_wielded = 22, attacksound = active_hitsound)
	RegisterSignals(src, list(COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_PRE_THROW, COMSIG_ITEM_ATTACK_SELF), PROC_REF(reset_charges))

/obj/item/house_edge/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!ismob(target))
		return
	var/mob/mob_target = target
	if(HAS_TRAIT(src, TRAIT_WIELDED) && mob_target.stat != DEAD)
		//Add a fire charge to a max of 3, updates icon_state.
		fire_charges = clamp((fire_charges + 1), HOUSE_EDGE_ICONS_MIN, HOUSE_EDGE_ICONS_MAX)
		COOLDOWN_RESET(src, fire_charge_cooldown)
	update_appearance(UPDATE_ICON_STATE)

/obj/item/house_edge/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, fire_charge_cooldown))
		return ITEM_INTERACT_BLOCKING
	if(fire_charges <= 0)
		balloon_alert(user, "no fire charges!")
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_boldnotice("You take aim at [interacting_with]..."))
	user.add_shared_particles(/particles/bonfire)

	if(!do_after(user, SLASH_WINDUP, target = src))
		// Special attack fizzles, no slash and charges lost.
		reset_charges()
		drop_particles(user)
		return ITEM_INTERACT_BLOCKING

	user.add_shared_particles(/particles/bonfire)
	new /obj/effect/temp_visual/focus_ring(get_turf(src))
	playsound(src, 'sound/items/car_engine_start.ogg', vol = 35, vary = FALSE, extrarange = 3)

	if(!do_after(user, SLASH_WINDUP * 2, target = src) || fire_charges < 3)
		flaming_slash(interacting_with, user, upgraded = FALSE)
		return ITEM_INTERACT_SUCCESS

	flaming_slash(interacting_with, user, upgraded = TRUE) //Upgraded slash.
	return ITEM_INTERACT_SUCCESS

/obj/item/house_edge/update_icon_state()
	inhand_icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "house_edge1" : "house_edge"
	icon_state = "[base_icon_state][fire_charges ? fire_charges : ""]"
	return ..()

/**
 * Proc that handles the house edge's fire_charge mechanic when resetting charges back to zero.
 * Updates icon, sets count, and updates icon.
 */
/obj/item/house_edge/proc/reset_charges(on_slash = FALSE)
	if(!COOLDOWN_FINISHED(src, fire_charge_cooldown) && !on_slash)
		return
	if(fire_charges)
		balloon_alert_to_viewers("charges lost!")
	fire_charges = 0
	update_icon(UPDATE_OVERLAYS|UPDATE_ICON_STATE)

/// Kills any of the relevant particles off the wielder, as added during special attacks.
/obj/item/house_edge/proc/drop_particles(mob/living/user)
	user.remove_shared_particles(/particles/bonfire)

/**
 * Proc that creates and fires the flaming_slash projectile from the house edge special attack.
 * Extends off the ranged_interact_with_atom_secondary() behavior.
 * * upgraded: when juiced up from the second do_after, applies a light explosion radius to the slash.
 */
/obj/item/house_edge/proc/flaming_slash(atom/interacting_with, mob/living/user, upgraded = FALSE)
	// Do the cool slash
	var/obj/projectile/flaming_slash/projectile = new /obj/projectile/flaming_slash(get_turf(src))

	projectile.aim_projectile(interacting_with, src)
	projectile.firer = user
	projectile.damage += (10 * fire_charges)
	if(upgraded)
		projectile.explosion_power = 1
		projectile.damage /= 2 // The damage is pretty solid normally, but with the explosion and all the RNG that comes with, it's nearly a 1-shot. This evens a playing field a bit.
	projectile.fire(null, interacting_with)

	user.visible_message(span_danger("[user] makes a[upgraded ? " devastating" : "" ] blazing slash at [interacting_with]!"),\
		span_notice("You take a blazing swipe at [interacting_with]!"))
	playsound(src, 'sound/items/modsuit/flamethrower.ogg', vol = 75, vary = FALSE, extrarange = 3)
	playsound(src, 'sound/items/weapons/slash.ogg', vol = 50, vary = FALSE, extrarange = 3)

	drop_particles(user)
	COOLDOWN_START(src, fire_charge_cooldown, SLASH_COOLDOWN)
	reset_charges(on_slash = TRUE)

/// Flaming slash for the special attack at max charges.
/obj/projectile/flaming_slash
	name = "flaming slash"
	desc = "Someone is about to cash out."
	icon_state = "flaming_slash"
	damage_type = BURN
	armor_flag = MELEE //We're operating off of anime remote slash logic here. As such, we can treat this as a hybrid burn/brute this way.
	damage = 10 // Damage amps based on the number of flame_charges it was created off of.
	speed = 2
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_FIRE
	sharpness = SHARP_EDGED

	///Applied in on_hit as the light_devastation_range. Defaults to zero unless giving the slash an extra juiced charge.
	var/explosion_power = 0

/obj/projectile/flaming_slash/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	explosion(loc,
		light_impact_range = explosion_power,
		flame_range = 3,
		explosion_cause = "[firer] using \the [fired_from]",
		explosion_arc = 120
	)

#undef ENGINE_COOLDOWN
#undef SLASH_COOLDOWN
#undef SLASH_WINDUP
#undef CHARGE_DAMAGE_MOD
#undef HOUSE_EDGE_ICONS_MAX
#undef HOUSE_EDGE_ICONS_MIN
