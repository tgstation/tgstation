/obj/item/melee/energy
	icon = 'icons/obj/weapons/transforming_energy.dmi'
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
	bare_wound_bonus = 20
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
	var/active_w_class = WEIGHT_CLASS_BULKY
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

/obj/item/melee/energy/sword/Initialize(mapload)
	. = ..()
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple, -10, TRAIT_TRANSFORM_ACTIVE)

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
