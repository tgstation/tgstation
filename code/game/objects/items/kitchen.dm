/* Kitchen tools
 * Contains:
 * Fork
 * Kitchen knives
 * Rolling Pins
 * Plastic Utensils
 */

#define PLASTIC_BREAK_PROBABILITY 25

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'

/obj/item/kitchen/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_APC_SHOCKING, INNATE_TRAIT)

/obj/item/kitchen/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	force = 4
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=80)
	flags_1 = CONDUCT_1
	attack_verb_continuous = list("attacks", "stabs", "pokes")
	attack_verb_simple = list("attack", "stab", "poke")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	sharpness = SHARP_POINTY
	var/datum/reagent/forkload //used to eat omelette
	custom_price = PAYCHECK_PRISONER

/obj/item/kitchen/fork/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)

/obj/item/kitchen/fork/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] stabs \the [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to take a bite out of [user.p_them()]self!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/kitchen/fork/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(forkload)
		if(M == user)
			M.visible_message(span_notice("[user] eats a delicious forkful of omelette!"))
			M.reagents.add_reagent(forkload.type, 1)
		else
			M.visible_message(span_notice("[user] feeds [M] a delicious forkful of omelette!"))
			M.reagents.add_reagent(forkload.type, 1)
		icon_state = "fork"
		forkload = null
	else
		return ..()

/obj/item/kitchen/fork/plastic
	name = "plastic fork"
	desc = "Really takes you back to highschool lunch."
	icon_state = "plastic_fork"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	custom_materials = list(/datum/material/plastic=80)
	custom_price = PAYCHECK_PRISONER * 2

/obj/item/kitchen/fork/plastic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/easily_fragmented, PLASTIC_BREAK_PROBABILITY)

/obj/item/knife/kitchen
	name = "kitchen knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."

/obj/item/knife/plastic
	name = "plastic knife"
	icon_state = "plastic_knife"
	inhand_icon_state = "knife"
	desc = "A very safe, barely sharp knife made of plastic. Good for cutting food and not much else."
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_range = 5
	custom_materials = list(/datum/material/plastic = 100)
	attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
	attack_verb_simple = list("prod", "whiff", "scratch", "poke")
	sharpness = SHARP_EDGED
	custom_price = PAYCHECK_PRISONER * 2

/obj/item/knife/plastic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/easily_fragmented, PLASTIC_BREAK_PROBABILITY)

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	worn_icon_state = "rolling_pin"
	force = 8
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 1.5)
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	custom_price = PAYCHECK_EASY * 1.5
	tool_behaviour = TOOL_ROLLINGPIN

/obj/item/kitchen/rollingpin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins flattening [user.p_their()] head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS
/* Trays  moved to /obj/item/storage/bag */

/obj/item/kitchen/spoon
	name = "spoon"
	desc = "Just be careful your food doesn't melt the spoon first."
	icon_state = "spoon"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	force = 2
	throw_speed = 3
	throw_range = 5
	attack_verb_simple = list("whack", "spoon", "tap")
	attack_verb_continuous = list("whacks", "spoons", "taps")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 30)
	custom_materials = list(/datum/material/iron=120)
	custom_price = PAYCHECK_PRISONER * 5
	tool_behaviour = TOOL_MINING
	toolspeed = 25 // Literally 25 times worse than the base pickaxe

/obj/item/kitchen/spoon/plastic
	name = "plastic spoon"
	icon_state = "plastic_spoon"
	force = 0
	custom_materials = list(/datum/material/plastic=120)
	custom_price = PAYCHECK_PRISONER * 2
	toolspeed = 75 // The plastic spoon takes 5 minutes to dig through a single mineral turf... It's one, continuous, breakable, do_after...

/obj/item/kitchen/spoon/plastic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/easily_fragmented, PLASTIC_BREAK_PROBABILITY)

#undef PLASTIC_BREAK_PROBABILITY
