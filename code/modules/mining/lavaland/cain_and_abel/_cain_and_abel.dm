#define THROW_MODE_CRYSTALS "throw_mode_crystals"
#define THROW_MODE_LAUNCH "throw_mode_launch"

/obj/item/cain_and_abel
	name = "Cain & Abel"
	desc = "I cry I pray mon Dieu."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi' //same sprite as lefthand
	icon_state = "cain_and_abel"
	inhand_icon_state = "cain_and_abel"
	attack_verb_continuous = list("attacks", "saws", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "saw", "slice", "tear", "lacerate", "rip", "dice", "cut")
	force = 15
	attack_speed = 6
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	actions_types = list(/datum/action/cooldown/dagger_swing)
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_SMALL
	sharpness = SHARP_EDGED
	light_range = 3
	light_power = 2
	light_color = "#3db9db"
	reach = 2
	attack_icon = 'icons/effects/effects.dmi'
	attack_icon_state = "cain_abel_attack"
	/// Our current combo count
	var/combo_count = 0
	/// The maximum combo we can reach
	var/max_combo = 6
	/// Percentage boost we get on every combo
	var/damage_boost = 1.15
	/// Animation positions used by wisps
	var/static/list/animation_steps
	/// What throw mode we're using
	var/throw_mode = THROW_MODE_CRYSTALS
	/// Flames we have up!
	var/list/current_wisps = list()
	/// Cooldown till we can throw blades again
	COOLDOWN_DECLARE(throw_cooldown)

/obj/item/cain_and_abel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = force, force_wielded = force)
	if (length(animation_steps))
		return

	animation_steps = list(
		new /datum/abel_wisp_frame(-18, -2, MOB_LAYER, EASE_OUT, EASE_IN),
		new /datum/abel_wisp_frame(-6, -6, ABOVE_MOB_LAYER, EASE_IN, EASE_OUT),
		new /datum/abel_wisp_frame(6, -6, ABOVE_MOB_LAYER, EASE_IN, EASE_OUT),
		new /datum/abel_wisp_frame(18, -2, MOB_LAYER, EASE_OUT, EASE_IN),
		new /datum/abel_wisp_frame(6, 2, BELOW_MOB_LAYER, EASE_IN, EASE_OUT),
		new /datum/abel_wisp_frame(-6, 2, BELOW_MOB_LAYER, EASE_IN, EASE_OUT),
	)

/obj/item/cain_and_abel/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(isliving(old_loc))
		unset_user(old_loc)

/obj/item/cain_and_abel/proc/unset_user(mob/living/source)
	if(HAS_TRAIT(source, TRAIT_RELAYING_ATTACKER))
		source.RemoveElement(/datum/element/relay_attackers)

	set_combo(new_value = 0, user = source)
	UnregisterSignal(source, list(COMSIG_ATOM_WAS_ATTACKED))

/obj/item/cain_and_abel/equipped(mob/user, slot)
	. = ..()

	if(!(slot & ITEM_SLOT_HANDS))
		unset_user(user)
		return

	if(!HAS_TRAIT(user, TRAIT_RELAYING_ATTACKER))
		user.AddElement(/datum/element/relay_attackers)

	RegisterSignal(user, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/obj/item/cain_and_abel/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	set_combo(new_value = 0, user = source)

/obj/item/cain_and_abel/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(get_dist(interacting_with, user) > 9 || interacting_with.z != user.z)
		return NONE

	if(!length(current_wisps))
		user.balloon_alert(user, "no wisps!")
		return ITEM_INTERACT_BLOCKING

	for(var/index in 0 to (length(current_wisps) - 1))
		addtimer(CALLBACK(src, PROC_REF(fire_wisp), user, interacting_with), index * 0.15 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/item/cain_and_abel/attack(mob/living/target, mob/living/carbon/human/user)
	if(!istype(target) || target.mob_size < MOB_SIZE_LARGE || target.stat == DEAD)
		attack_speed = CLICK_CD_MELEE
		return ..()

	attack_speed = initial(attack_speed)
	var/old_force = force
	var/bonus_value = combo_count || 1
	force = CEILING((bonus_value * damage_boost) * force, 1)
	. = ..()
	force = old_force
	set_combo(new_value = combo_count + 1, user = user)

/obj/item/cain_and_abel/attack_self(mob/user)
	. = ..()
	if(.)
		return TRUE
	throw_mode = (throw_mode == THROW_MODE_CRYSTALS) ? THROW_MODE_LAUNCH : THROW_MODE_CRYSTALS
	user.balloon_alert(user, "crystals [throw_mode == THROW_MODE_CRYSTALS ? "activated" : "deactivated"]")
	return TRUE

/obj/item/cain_and_abel/proc/set_combo(new_value, mob/living/user, instant = FALSE)
	new_value = clamp(new_value, 0, max_combo)
	if (new_value == combo_count)
		return

	if (new_value > combo_count)
		for (var/i in 1 to new_value - combo_count)
			add_wisp(user)
	else
		for (var/i in 1 to combo_count - new_value)
			remove_wisp(current_wisps[i], instant)

	combo_count = new_value

/obj/item/cain_and_abel/proc/add_wisp(mob/living/user)
	var/obj/effect/overlay/blood_wisp/new_wisp = new(src)
	current_wisps += new_wisp
	user.vis_contents += new_wisp
	RegisterSignal(new_wisp, COMSIG_QDELETING, PROC_REF(on_wisp_delete))
	for (var/wisp_index in 1 to length(current_wisps))
		var/obj/effect/overlay/blood_wisp/wisp = current_wisps[wisp_index]
		var/spawn_index = floor(length(animation_steps) / length(current_wisps) * wisp_index)
		var/datum/abel_wisp_frame/spawn_position = animation_steps[spawn_index]

		// Latest added wisp is teleported to its spawn position, others animate from their current position
		if (wisp_index == length(current_wisps))
			wisp.pixel_w = spawn_position.x
			wisp.pixel_z = spawn_position.y
			wisp.layer = spawn_position.layer
		else
			animate(wisp, tag = "wisp_anim_x")
			animate(wisp, tag = "wisp_anim_y")

		var/start_index = spawn_index % length(animation_steps) + 1
		var/datum/abel_wisp_frame/position = animation_steps[start_index]
		animate(wisp, pixel_w = position.x, layer = position.layer, time = 0.6 SECONDS, loop = -1, tag = "wisp_anim_x")
		// We need to animate x and y coordinates separately as they have different easing steps
		for (var/frame_index in 1 to length(animation_steps) - 1)
			// Get actual index starting from our *next* animation step, not initial position
			var/anim_index = (start_index + frame_index - 1) % length(animation_steps) + 1
			position = animation_steps[anim_index]
			animate(time = 0.6 SECONDS, pixel_w = position.x, layer = position.layer, easing = SINE_EASING | position.x_easing)

		animate(wisp, time = 0.6 SECONDS, pixel_z = position.y, loop = -1, tag = "wisp_anim_y")
		for (var/frame_index in 1 to length(animation_steps) - 1)
			// Get actual index starting from our *next* animation step, not initial position
			var/anim_index = (start_index + frame_index - 1) % length(animation_steps) + 1
			position = animation_steps[anim_index]
			animate(time = 0.6 SECONDS, pixel_z = position.y, easing = SINE_EASING | position.y_easing)

/obj/item/cain_and_abel/proc/on_wisp_delete(datum/source)
	SIGNAL_HANDLER
	current_wisps -= source
	UnregisterSignal(source, COMSIG_QDELETING)

/obj/item/cain_and_abel/proc/fire_wisp(atom/user, atom/target)
	user.fire_projectile(/obj/projectile/dagger_wisp, target)
	set_combo(combo_count - 1, user, TRUE)

/obj/item/cain_and_abel/proc/remove_wisp(obj/wisp_to_remove, instant = FALSE)
	if (instant)
		qdel(wisp_to_remove)
		return
	animate(wisp_to_remove, alpha = 0, time = 0.2 SECONDS)
	QDEL_IN(wisp_to_remove, 0.2 SECONDS)

/// Frame data for cain & abel wisps so we don't have to make list monstrocities
/datum/abel_wisp_frame
	var/x = 0
	var/y = 0
	var/layer = MOB_LAYER
	var/x_easing = NONE
	var/y_easing = NONE

/datum/abel_wisp_frame/New(x, y, layer, x_easing, y_easing)
	. = ..()
	src.x = x
	src.y = y
	src.layer = layer
	src.x_easing = x_easing
	src.y_easing = y_easing
