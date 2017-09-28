/obj/item/melee/transforming/energy
	hitsound_on = 'sound/weapons/blade1.ogg'
	heat = 3500
	max_integrity = 200
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 30)
	resistance_flags = FIRE_PROOF
	var/brightness_on = 3

/obj/item/melee/transforming/energy/Initialize()
	. = ..()
	if(active)
		set_light(brightness_on)
		START_PROCESSING(SSobj, src)

/obj/item/melee/transforming/energy/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/melee/transforming/energy/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku!</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/transforming/energy/add_blood(list/blood_dna)
	return 0

/obj/item/melee/transforming/energy/is_sharp()
	return active * sharpness

/obj/item/melee/transforming/energy/process()
	open_flame()

/obj/item/melee/transforming/energy/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(.)
		if(active)
			if(item_color)
				icon_state = "sword[item_color]"
			START_PROCESSING(SSobj, src)
			set_light(brightness_on)
		else
			STOP_PROCESSING(SSobj, src)
			set_light(0)

/obj/item/melee/transforming/energy/is_hot()
	return active * heat

/obj/item/melee/transforming/energy/ignition_effect(atom/A, mob/user)
	if(!active)
		return ""

	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask == src)
			in_mouth = ", barely missing their nose"
	. = "<span class='warning'>[user] swings their [src][in_mouth]. They light [A] in the process.</span>"
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)

/obj/item/melee/transforming/energy/axe
	name = "energy axe"
	desc = "An energized battle axe."
	icon_state = "axe0"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	force = 40
	force_on = 150
	throwforce = 25
	throwforce_on = 30
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	w_class_on = WEIGHT_CLASS_HUGE
	flags_1 = CONDUCT_1
	armour_penetration = 100
	origin_tech = "combat=4;magnets=3"
	attack_verb_off = list("attacked", "chopped", "cleaved", "torn", "cut")
	attack_verb_on = list()
	light_color = "#40ceff"

/obj/item/melee/transforming/energy/axe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swings [src] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/transforming/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 3
	throwforce = 5
	hitsound = "swing_hit" //it starts deactivated
	attack_verb_off = list("tapped", "poked")
	throw_speed = 3
	throw_range = 5
	sharpness = IS_SHARP
	embed_chance = 75
	embedded_impact_pain_multiplier = 10
	armour_penetration = 35
	origin_tech = "combat=3;magnets=4;syndicate=4"
	block_chance = 50

/obj/item/melee/transforming/energy/sword/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(. && active && item_color)
		icon_state = "sword[item_color]"

/obj/item/melee/transforming/energy/sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/melee/transforming/energy/sword/cyborg
	item_color = "red"
	var/hitcost = 50

/obj/item/melee/transforming/energy/sword/cyborg/attack(mob/M, var/mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self(R)
			to_chat(R, "<span class='notice'>It's out of charge!</span>")
			return
		return ..()

/obj/item/melee/transforming/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	force_on = 30
	force = 18 //About as much as a spear
	hitsound = 'sound/weapons/circsawhit.ogg'
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw_0"
	icon_state_on = "esaw_1"
	item_color = null //stops icon from breaking when turned on.
	hitcost = 75 //Costs more than a standard cyborg esword
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = IS_SHARP
	light_color = "#40ceff"

/obj/item/melee/transforming/energy/sword/cyborg/saw/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/melee/transforming/energy/sword/saber
	var/list/possible_colors = list("red" = LIGHT_COLOR_RED, "blue" = LIGHT_COLOR_LIGHT_CYAN, "green" = LIGHT_COLOR_GREEN, "purple" = LIGHT_COLOR_LAVENDER)
	var/hacked = FALSE

/obj/item/melee/transforming/energy/sword/saber/Initialize(mapload)
	. = ..()
	if(LAZYLEN(possible_colors))
		var/set_color = pick(possible_colors)
		item_color = set_color
		light_color = possible_colors[set_color]

/obj/item/melee/transforming/energy/sword/saber/process()
	. = ..()
	if(hacked)
		var/set_color = pick(possible_colors)
		light_color = possible_colors[set_color]
		update_light()

/obj/item/melee/transforming/energy/sword/saber/red
	possible_colors = list("red" = LIGHT_COLOR_RED)

/obj/item/melee/transforming/energy/sword/saber/blue
	possible_colors = list("blue" = LIGHT_COLOR_LIGHT_CYAN)

/obj/item/melee/transforming/energy/sword/saber/green
	possible_colors = list("green" = LIGHT_COLOR_GREEN)

/obj/item/melee/transforming/energy/sword/saber/purple
	possible_colors = list("purple" = LIGHT_COLOR_LAVENDER)

/obj/item/melee/transforming/energy/sword/saber/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/device/multitool))
		if(!hacked)
			hacked = TRUE
			item_color = "rainbow"
			to_chat(user, "<span class='warning'>RNBW_ENGAGE</span>")

			if(active)
				icon_state = "swordrainbow"
				user.update_inv_hands()
		else
			to_chat(user, "<span class='warning'>It's already fabulous!</span>")
	else
		return ..()

/obj/item/melee/transforming/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon_state_on = "cutlass1"
	light_color = "#ff0000"

/obj/item/melee/transforming/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 30 //Normal attacks deal esword damage
	hitsound = 'sound/weapons/blade1.ogg'
	active = 1
	throwforce = 1 //Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	w_class = WEIGHT_CLASS_BULKY//So you can't hide it in your pocket or some such.
	var/datum/effect_system/spark_spread/spark_system
	sharpness = IS_SHARP

//Most of the other special functions are handled in their own files. aka special snowflake code so kewl
/obj/item/melee/transforming/energy/blade/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/melee/transforming/energy/blade/transform_weapon(mob/living/user, supress_message_text)
	return

/obj/item/melee/transforming/energy/blade/hardlight
	name = "hardlight blade"
	desc = "An extremely sharp blade made out of hard light. Packs quite a punch."
	icon_state = "lightblade"
	item_state = "lightblade"
