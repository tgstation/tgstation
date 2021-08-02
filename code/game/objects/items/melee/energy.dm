/obj/item/melee/energy
	icon = 'icons/obj/transforming_energy.dmi'
	heat = 3500
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 1
	light_on = FALSE

	/// Whether the sword can sheathe/transform.
	var/can_transform = TRUE
	/// Force while active.
	var/active_force = 30
	/// Throwforce while active.
	var/active_throwforce = 20
	/// Hitsound while active.
	var/active_hitsound = 'sound/weapons/blade1.ogg'
	/// Weight class while active.
	var/active_w_class = WEIGHT_CLASS_BULKY
	/// Attack verbs used while inactive.
	var/list/inactive_attack_verbs
	/// Attack verbs used while active.
	var/list/active_attack_verbs
	/// The color of this energy based sword, for use in editing the icon_state.
	var/sword_color_icon

/obj/item/melee/energy/Initialize()
	. = ..()
	if(can_transform)
		AddComponent(/datum/component/transforming_weapon, \
			force_on = active_force, \
			throwforce_on = active_throwforce, \
			hitsound_on = active_hitsound, \
			w_class_on = active_w_class, \
			attack_verb_off = inactive_attack_verbs, \
			attack_verb_on = active_attack_verbs, \
			on_transform_callback = CALLBACK(src, .proc/after_transform))
	if(force)
		START_PROCESSING(SSobj, src)

/obj/item/melee/energy/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/melee/energy/suicide_act(mob/user)
	if(!force)
		attack_self(user)
	user.visible_message(span_suicide("[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/energy/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/melee/energy/get_sharpness()
	return (force >= active_force ? 1 : 0) * sharpness

/obj/item/melee/energy/process()
	open_flame()

/obj/item/melee/energy/proc/after_transform()
	if(force)
		if(sword_color_icon)
			icon_state = "sword[sword_color_icon]"
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	set_light_on(force >= active_force ? 1 : 0)

/obj/item/melee/energy/get_temperature()
	return (force >= active_force  ? 1 : 0) * heat

/obj/item/melee/energy/ignition_effect(atom/A, mob/user)
	if(force < active_force)
		return ""

	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [C.p_their()] nose"
	. = span_warning("[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.")
	playsound(loc, hitsound, get_clamped_volume(), TRUE, -1)
	add_fingerprint(user)

/obj/item/melee/energy/axe
	name = "energy axe"
	desc = "An energized battle axe."
	icon_state = "axe0"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 40
	throwforce = 25
	throw_speed = 3
	throw_range = 5
	armour_penetration = 100
	w_class = WEIGHT_CLASS_NORMAL
	flags_1 = CONDUCT_1
	light_color = LIGHT_COLOR_LIGHT_CYAN

	active_force = 150
	active_throwforce = 30
	w_class_on = WEIGHT_CLASS_HUGE
	attack_verb_off = list("attacks", "chops", "cleaves", "tears", "lacerates", "cuts")
	attack_verb_on = list()

/obj/item/melee/energy/axe/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] swings [src] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = "swing_hit" //it starts deactivated
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	armour_penetration = 35
	block_chance = 50
	sharpness = SHARP_EDGED
	embedding = list("embed_chance" = 75, "impact_pain_mult" = 10)
	inactive_attack_verbs = list("taps", "pokes")

/obj/item/melee/energy/sword/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(. && force && sword_color)
		icon_state = "sword[sword_color]"

/obj/item/melee/energy/sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(force)
		return ..()
	return FALSE

/obj/item/melee/energy/sword/cyborg
	sword_color = "red"
	var/hitcost = 50

/obj/item/melee/energy/sword/cyborg/attack(mob/M, mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self(R)
			to_chat(R, span_notice("It's out of charge!"))
			return
		return ..()

/obj/item/melee/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	force_on = 30
	force = 18 //About as much as a spear
	hitsound = 'sound/weapons/circsawhit.ogg'
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw_0"
	icon_state_on = "esaw_1"
	sword_color = null //stops icon from breaking when turned on.
	hitcost = 75 //Costs more than a standard cyborg esword
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	light_color = LIGHT_COLOR_LIGHT_CYAN
	tool_behaviour = TOOL_SAW
	toolspeed = 0.7 //faster as a saw

/obj/item/melee/energy/sword/cyborg/saw/cyborg_unequip(mob/user)
	if(!active)
		return
	transform_weapon(user, TRUE)

/obj/item/melee/energy/sword/cyborg/saw/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return FALSE

/obj/item/melee/energy/sword/saber
	/// Assoc list of all possible saber colors to color define.
	var/list/possible_colors = list(
		"red" = COLOR_SOFT_RED,
		"blue" = LIGHT_COLOR_LIGHT_CYAN,
		"green" = LIGHT_COLOR_GREEN,
		"purple" = LIGHT_COLOR_LAVENDER,
		)
	/// Whether this saber has beel multitooled.
	var/hacked = FALSE

/obj/item/melee/energy/sword/saber/Initialize(mapload)
	. = ..()
	if(LAZYLEN(possible_colors))
		var/set_color = pick(possible_colors)
		sword_color = set_color
		set_light_color(possible_colors[set_color])

/obj/item/melee/energy/sword/saber/process()
	. = ..()
	if(hacked)
		set_light_color(possible_colors[pick(possible_colors)])

/obj/item/melee/energy/sword/saber/red
	possible_colors = list("red" = COLOR_SOFT_RED)

/obj/item/melee/energy/sword/saber/blue
	possible_colors = list("blue" = LIGHT_COLOR_LIGHT_CYAN)

/obj/item/melee/energy/sword/saber/green
	possible_colors = list("green" = LIGHT_COLOR_GREEN)

/obj/item/melee/energy/sword/saber/purple
	possible_colors = list("purple" = LIGHT_COLOR_LAVENDER)

/obj/item/melee/energy/sword/saber/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			sword_color = "rainbow"
			to_chat(user, span_warning("RNBW_ENGAGE"))
			if(active)
				icon_state = "swordrainbow"
				user.update_inv_hands()
		else
			to_chat(user, span_warning("It's already fabulous!"))
	else
		return ..()

/obj/item/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon_state_on = "cutlass1"
	light_color = COLOR_RED

/obj/item/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/blade1.ogg'
	force = 30
	throwforce = 1 // Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	/// Our linked spark system that emits from our sword.
	var/datum/effect_system/spark_spread/spark_system

//Most of the other special functions are handled in their own files. aka special snowflake code so kewl
/obj/item/melee/energy/blade/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/melee/energy/blade/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/melee/energy/blade/hardlight
	name = "hardlight blade"
	desc = "An extremely sharp blade made out of hard light. Packs quite a punch."
	icon_state = "lightblade"
	inhand_icon_state = "lightblade"
