/obj/item/melee/energy
	icon = 'icons/obj/weapons/transforming_energy.dmi'
	abstract_type = /obj/item/melee/energy
	icon_angle = -45
	max_integrity = 200
	armor_type = /datum/armor/melee_energy
	attack_verb_continuous = list("hits", "taps", "pokes")
	attack_verb_simple = list("hit", "tap", "poke")
	resistance_flags = FIRE_PROOF
	light_system = OVERLAY_LIGHT
	light_range = 3
	light_power = 1
	light_on = FALSE
	exposed_wound_bonus = 20
	demolition_mod = 1.5 //1.5x damage to objects, robots, etc.
	stealthy_audio = TRUE
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NO_BLOOD_ON_ITEM

	/// The color of this energy based sword, for use in editing the icon_state.
	var/sword_color_icon
	/// Force while active.
	var/active_force = 30
	/// Throwforce while active.
	var/active_throwforce = 20
	/// Sharpness while active.
	var/active_sharpness = SHARP_EDGED
	/// Hitsound played attacking while active.
	var/active_hitsound = 'sound/items/weapons/blade1.ogg'
	/// Weight class while active.
	var/active_w_class = WEIGHT_CLASS_HUGE
	/// The heat given off when active.
	var/active_heat = 3500

/datum/armor/melee_energy
	fire = 100
	acid = 30

/obj/item/melee/energy/get_all_tool_behaviours()
	return list(TOOL_SAW)

/obj/item/melee/energy/Initialize(mapload)
	. = ..()
	make_transformable()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddComponent(
		/datum/component/butchering, \
		speed = 5 SECONDS, \
		butcher_sound = active_hitsound, \
	)

/obj/item/melee/energy/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/*
 * Gives our item the transforming component, passing in our various vars.
 */
/obj/item/melee/energy/proc/make_transformable()
	AddComponent( \
		/datum/component/transforming, \
		force_on = active_force, \
		throwforce_on = active_throwforce, \
		throw_speed_on = 4, \
		sharpness_on = active_sharpness, \
		hitsound_on = active_hitsound, \
		w_class_on = active_w_class, \
		attack_verb_continuous_on = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "cuts"), \
		attack_verb_simple_on = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/energy/suicide_act(mob/living/user)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		attack_self(user)
	user.visible_message(span_suicide("[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/energy/process(seconds_per_tick)
	if(heat)
		open_flame()

/obj/item/melee/energy/ignition_effect(atom/atom, mob/user)
	if(!heat && !HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return ""

	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(carbon_user.wear_mask)
			in_mouth = ", barely missing [carbon_user.p_their()] nose"
	. = span_rose("[user] swings [user.p_their()] [name][in_mouth]. [user.p_They()] light[user.p_s()] [user.p_their()] [atom.name] in the process.")
	playsound(loc, hitsound, get_clamped_volume(), TRUE, -1)
	add_fingerprint(user)

/obj/item/melee/energy/get_demolition_modifier(obj/target)
	return HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? demolition_mod : 1

/obj/item/melee/energy/update_icon_state()
	. = ..()
	if(!sword_color_icon)
		return
	if(HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		icon_state = "[base_icon_state]_on_[sword_color_icon]" // "esword_on_red"
		inhand_icon_state = icon_state
	else
		icon_state = base_icon_state
		inhand_icon_state = base_icon_state

/**
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Updates some of the stuff the transforming comp doesn't, such as heat and embedding.
 *
 * Also gives feedback to the user and activates or deactives the glow.
 */
/obj/item/melee/energy/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(active)
		heat = active_heat
		START_PROCESSING(SSobj, src)
	else
		heat = initial(heat)
		STOP_PROCESSING(SSobj, src)

	tool_behaviour = (active ? TOOL_SAW : NONE) //Lets energy weapons cut trees. Also lets them do bonecutting surgery, which is kinda metal!
	if(user)
		balloon_alert(user, "[name] [active ? "enabled":"disabled"]")
	playsound(src, active ? 'sound/items/weapons/saberon.ogg' : 'sound/items/weapons/saberoff.ogg', 35, TRUE)
	set_light_on(active)
	update_appearance(UPDATE_ICON_STATE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/// Energy axe - extremely strong.
/obj/item/melee/energy/axe
	name = "energy axe"
	desc = "An energized battle axe."
	icon_state = "axe"
	inhand_icon_state = "axe"
	base_icon_state = "axe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "chops", "cleaves", "tears", "lacerates", "cuts")
	attack_verb_simple = list("attack", "chop", "cleave", "tear", "lacerate", "cut")
	force = 40
	throwforce = 25
	throw_speed = 3
	throw_range = 5
	armour_penetration = 100
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_NORMAL
	obj_flags = CONDUCTS_ELECTRICITY
	light_color = LIGHT_COLOR_LIGHT_CYAN

	active_force = 150
	active_throwforce = 30
	active_w_class = WEIGHT_CLASS_HUGE

/obj/item/melee/energy/axe/make_transformable()
	AddComponent( \
		/datum/component/transforming, \
		force_on = active_force, \
		throwforce_on = active_throwforce, \
		throw_speed_on = throw_speed, \
		sharpness_on = sharpness, \
		w_class_on = active_w_class, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/energy/axe/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] swings [src] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS|FIRELOSS)

/// Energy swords.
/datum/embedding/esword
	embed_chance = 75
	impact_pain_mult = 10

/obj/item/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "e_sword"
	base_icon_state = "e_sword"
	inhand_icon_state = "e_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = SFX_SWING_HIT
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	armour_penetration = 35
	block_chance = 50
	block_sound = 'sound/items/weapons/block_blade.ogg'
	embed_type = /datum/embedding/esword
	var/list/alt_continuous = list("stabs", "pierces", "impales")
	var/list/alt_simple = list("stab", "pierce", "impale")
	var/alt_sharpness = SHARP_POINTY
	var/alt_force_mod = -10
	var/alt_hitsound = null

/obj/item/melee/energy/sword/Initialize(mapload)
	. = ..()
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, alt_sharpness, alt_continuous, alt_simple, alt_force_mod, TRAIT_TRANSFORM_ACTIVE, alt_hitsound)

/obj/item/melee/energy/sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return FALSE

	if(attack_type == LEAP_ATTACK)
		final_block_chance -= 25 //OH GOD GET IT OFF ME

	return ..()

/obj/item/melee/energy/sword/cyborg
	name = "cyborg energy sword"
	sword_color_icon = "red"
	/// The cell cost of hitting something.
	var/hitcost = 0.05 * STANDARD_CELL_CHARGE

/obj/item/melee/energy/sword/cyborg/attack(mob/target, mob/living/silicon/robot/user)
	if(!user.cell)
		return

	var/obj/item/stock_parts/power_store/our_cell = user.cell
	if(HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) && !(our_cell.use(hitcost)))
		attack_self(user)
		to_chat(user, span_notice("It's out of charge!"))
		return
	return ..()

/obj/item/melee/energy/sword/cyborg/cyborg_unequip(mob/user)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return
	attack_self(user)

/obj/item/melee/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "esaw"
	hitsound = 'sound/items/weapons/circsawhit.ogg'
	force = 18
	hitcost = 0.075 * STANDARD_CELL_CHARGE // Costs more than a standard cyborg esword.
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	light_color = LIGHT_COLOR_LIGHT_CYAN
	tool_behaviour = TOOL_SAW
	toolspeed = 0.7 // Faster than a normal saw.

	active_force = 30
	sword_color_icon = null // Stops icon from breaking when turned on.

/obj/item/melee/energy/sword/cyborg/saw/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	return FALSE

// The colored energy swords we all know and love.
/obj/item/melee/energy/sword/saber
	/// Assoc list of all possible saber colors to color define. If you add a new color, make sure to update /obj/item/toy/sword too!
	var/list/possible_sword_colors = list(
		"red" = COLOR_SOFT_RED,
		"blue" = LIGHT_COLOR_LIGHT_CYAN,
		"green" = LIGHT_COLOR_GREEN,
		"purple" = LIGHT_COLOR_LAVENDER,
	)
	/// Whether this saber has been multitooled.
	var/hacked = FALSE
	var/hacked_color

/obj/item/melee/energy/sword/saber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/jousting, damage_boost_per_tile = 1, knockdown_chance_per_tile = 10)
	if(!sword_color_icon && LAZYLEN(possible_sword_colors))
		sword_color_icon = pick(possible_sword_colors)

	if(sword_color_icon)
		set_light_color(possible_sword_colors[sword_color_icon])

/obj/item/melee/energy/sword/saber/process()
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) || !hacked)
		return

	if(!LAZYLEN(possible_sword_colors))
		possible_sword_colors = list(
			"red" = COLOR_SOFT_RED,
			"blue" = LIGHT_COLOR_LIGHT_CYAN,
			"green" = LIGHT_COLOR_GREEN,
			"purple" = LIGHT_COLOR_LAVENDER,
		)
		possible_sword_colors -= hacked_color

	hacked_color = pick(possible_sword_colors)
	set_light_color(possible_sword_colors[hacked_color])
	possible_sword_colors -= hacked_color

/obj/item/melee/energy/sword/saber/red
	sword_color_icon = "red"

/obj/item/melee/energy/sword/saber/blue
	sword_color_icon = "blue"

/obj/item/melee/energy/sword/saber/green
	sword_color_icon = "green"

/obj/item/melee/energy/sword/saber/purple
	sword_color_icon = "purple"

/obj/item/melee/energy/sword/saber/multitool_act(mob/living/user, obj/item/tool)
	if(hacked)
		to_chat(user, span_warning("It's already fabulous!"))
		return
	hacked = TRUE
	sword_color_icon = "rainbow"
	to_chat(user, span_warning("RNBW_ENGAGE"))
	update_appearance(UPDATE_ICON_STATE)

/obj/item/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "e_cutlass"
	inhand_icon_state = "e_cutlass"
	base_icon_state = "e_cutlass"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	light_color = COLOR_RED

/// Energy blades, which are effectively perma-extended energy swords
/obj/item/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	base_icon_state = "blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/items/weapons/blade1.ogg'
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut")
	force = 30
	throwforce = 1 // Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	sharpness = SHARP_EDGED
	heat = 3500
	w_class = WEIGHT_CLASS_BULKY
	/// Our linked spark system that emits from our sword.
	var/datum/effect_system/spark_spread/spark_system
	var/list/alt_continuous = list("stabs", "pierces", "impales")
	var/list/alt_simple = list("stab", "pierce", "impale")

//Most of the other special functions are handled in their own files. aka special snowflake code so kewl
/obj/item/melee/energy/blade/Initialize(mapload)
	. = ..()
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple, -10)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	START_PROCESSING(SSobj, src)
	ADD_TRAIT(src, TRAIT_TRANSFORM_ACTIVE, INNATE_TRAIT) // Functions as an extended esword

/obj/item/melee/energy/blade/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/melee/energy/blade/make_transformable()
	return FALSE

/obj/item/melee/energy/blade/hardlight
	name = "hardlight blade"
	desc = "An extremely sharp blade made out of hard light. Packs quite a punch."
	icon_state = "lightblade"
	inhand_icon_state = "lightblade"
	base_icon_state = "lightblade"
	icon_angle = 0

/obj/item/melee/energy/sword/surplus
	name = "\improper Type I 'Iaito' energy sword"
	desc = "Oversized, overengineered, and mass-produced. The two blades help make up for the poor cutting plane the emitter generates. Hopefully. \
		Supposedly, this version of the energy sword was a Waffle Corp prototype that was first trialed in a variety of armed conflicts around the interstellar \
		frontier. The success rate, and survival of its users, were abysmally low. To make matters worse, they had made so many of these swords (accidentally) that \
		it would cost the company more disposing of them than trying to offload them to raise a quick buck. Thus, the 'Iaito' was 'born'. Often found in the hands of \
		grunts, mooks, goons, criminals, wannabe assassins or lunatics. You may or may not fit into one of these categories if you are genuinely attempting to kill someone\
		with this sword."
	icon_state = "surplus_e_sword"
	inhand_icon_state = "surplus_e_sword"
	base_icon_state = "surplus_e_sword"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	active_force = 15 // This force is augmented by the state of our target.
	active_throwforce = 15
	alt_continuous = list("whacks", "smacks", "bashes")
	alt_simple = list("whack", "smack", "bash")
	alt_sharpness = NONE
	alt_force_mod = -12
	alt_hitsound = SFX_SWING_HIT
	/// Battery used to determine how many hits we can make before our sword switches off and can't be turned back on without a do_after.
	var/charge = 20
	/// Our battery maximum.
	var/max_charge = 20
	/// The amount of time it takes to recharge the sword.
	var/charge_time = 5 SECONDS
	/// The cooldown between instances of vigorous jiggling to get your shitty sword back on.
	COOLDOWN_DECLARE(jiggle_cooldown)

/obj/item/melee/energy/sword/surplus/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TRANSFORMING_PRE_TRANSFORM, PROC_REF(check_power))

/obj/item/melee/energy/sword/surplus/examine(mob/user)
	. = ..()
	if(charge)
		. += span_notice("[src] has [charge] hits left before it must be recharged.")
	else
		. += span_warning("[src] needs to be recharged.")

	. += span_info("You get the sense that this weapon isn't very effective unless you hit someone while they are exposed in some way, like attacking from behind or while they're staggered.")

/obj/item/melee/energy/sword/surplus/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(charge < max_charge)
		context[SCREENTIP_CONTEXT_RMB] = "Recharge"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

// A weapon best employed by someone in a desperate struggle
/obj/item/melee/energy/sword/surplus/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!isliving(target))
		return ..()

	if(sharpness == NONE)
		return ..()

	var/mob/living/living_target = target
	var/vulnerable_target = FALSE

	if(living_target.stat == DEAD) // I know it doesn't make a lot of sense but it makes it a bit too good for dismemberment otherwise
		return ..()

	if(living_target.get_timed_status_effect_duration(/datum/status_effect/staggered))
		vulnerable_target = TRUE

	if(HAS_TRAIT(living_target, TRAIT_INCAPACITATED))
		vulnerable_target = TRUE

	if(check_behind(user, living_target))
		vulnerable_target = TRUE

	if(vulnerable_target)
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 2)

	return ..()

/obj/item/melee/energy/sword/surplus/attack_self_secondary(mob/user, list/modifiers)
	. = ..()
	if (.)
		return

	if(charge == max_charge)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(DOING_INTERACTION(user, DOAFTER_SOURCE_CHARGING_ESWORD))
		user.balloon_alert(user, "busy!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(charge <= max_charge)
		user.balloon_alert(user, "attempting recharge...")
		if(!do_after(user, charge_time, target = src, extra_checks = CALLBACK(src, PROC_REF(do_jiggle), user), interaction_key = DOAFTER_SOURCE_CHARGING_ESWORD, iconstate = "beat_the_heat"))
			user.balloon_alert(user, "interrupted!")
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	charge = max_charge
	user.balloon_alert(user, "recharge successful")
	playsound(src, 'sound/machines/ping.ogg', 40, TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/melee/energy/sword/surplus/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) || charge <= 0)
		return

	charge--
	if(charge <= 0)
		user.balloon_alert(user, "out of charge!")
		attack_self(user)

/obj/item/melee/energy/sword/surplus/proc/check_power(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(charge <= 0 && !HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		balloon_alert(user, "no charge!")
		return COMPONENT_BLOCK_TRANSFORM

/obj/item/melee/energy/sword/surplus/proc/do_jiggle(mob/user)
	if(!COOLDOWN_FINISHED(src, jiggle_cooldown))
		return TRUE

	user.Shake(2, 1, 0.3 SECONDS, shake_interval = 0.1 SECONDS)
	playsound(src, 'sound/items/baton/telescopic_baton_folded_pickup.ogg', 40, TRUE)
	COOLDOWN_START(src, jiggle_cooldown, 1 SECONDS)
	return TRUE
