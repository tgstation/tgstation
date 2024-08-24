/* Kitchen tools
 * Contains:
 * Fork
 * Kitchen knives
 * Rolling Pins
 * Plastic Utensils
 */

#define PLASTIC_BREAK_PROBABILITY 25

/obj/item/kitchen
	icon = 'icons/obj/service/kitchen.dmi'
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
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.8)
	obj_flags = CONDUCTS_ELECTRICITY
	attack_verb_continuous = list("attacks", "stabs", "pokes")
	attack_verb_simple = list("attack", "stab", "poke")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor_type = /datum/armor/kitchen_fork
	sharpness = SHARP_POINTY
	var/datum/reagent/forkload //used to eat omelette
	custom_price = PAYCHECK_LOWER

/datum/armor/kitchen_fork
	fire = 50
	acid = 30

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
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 0.8)
	custom_price = PAYCHECK_LOWER * 1

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
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT)
	attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
	attack_verb_simple = list("prod", "whiff", "scratch", "poke")
	sharpness = SHARP_EDGED
	custom_price = PAYCHECK_LOWER * 2

/obj/item/knife/plastic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/easily_fragmented, PLASTIC_BREAK_PROBABILITY)

/obj/item/knife/kitchen/silicon
	name = "Kitchen Toolset"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "sili_knife"
	desc = "A breakthrough in synthetic engineering, this tool is a knife programmed to dull when not used for cooking purposes, and can exchange the blade for a rolling pin"
	force = 0
	throwforce = 0
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
	attack_verb_simple = list("prod", "whiff", "scratch", "poke")
	tool_behaviour = TOOL_KNIFE

/obj/item/knife/kitchen/silicon/get_all_tool_behaviours()
	return list(TOOL_ROLLINGPIN, TOOL_KNIFE)

/obj/item/knife/kitchen/silicon/examine()
	. = ..()
	. += " It's fitted with a [tool_behaviour] head."

/obj/item/knife/kitchen/silicon/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_drill.ogg', 50, TRUE)
	if(tool_behaviour != TOOL_ROLLINGPIN)
		tool_behaviour = TOOL_ROLLINGPIN
		to_chat(user, span_notice("You attach the rolling pin bit to the [src]."))
		icon_state = "sili_rolling_pin"
		force = 8
		sharpness = NONE
		hitsound = SFX_SWING_HIT
		attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
		attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")

	else
		tool_behaviour = TOOL_KNIFE
		to_chat(user, span_notice("You attach the knife bit to the [src]."))
		icon_state = "sili_knife"
		force = 0
		sharpness = SHARP_EDGED
		hitsound = 'sound/weapons/bladeslice.ogg'
		attack_verb_continuous = list("prods", "whiffs", "scratches", "pokes")
		attack_verb_simple = list("prod", "whiff", "scratch", "poke")

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "rolling_pin"
	worn_icon_state = "rolling_pin"
	inhand_icon_state = "rolling_pin"
	force = 8
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 1.5)
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	custom_price = PAYCHECK_CREW * 1.5
	tool_behaviour = TOOL_ROLLINGPIN

/obj/item/kitchen/rollingpin/illegal
	name = "metal rolling pin"
	desc = "A heavy metallic rolling pin used to bash in those annoying ingredients."
	icon_state = "metal_rolling_pin"
	inhand_icon_state = "metal_rolling_pin"
	force = 12
	obj_flags = CONDUCTS_ELECTRICITY
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/plastic = SHEET_MATERIAL_AMOUNT * 1.5)
	custom_price = PAYCHECK_CREW * 2
	bare_wound_bonus = 14

/obj/item/kitchen/rollingpin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins flattening [user.p_their()] head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS
/* Trays  moved to /obj/item/storage/bag */

/obj/item/kitchen/spoon
	name = "spoon"
	desc = "Just be careful your food doesn't melt the spoon first."
	icon_state = "spoon"
	base_icon_state = "spoon"
	w_class = WEIGHT_CLASS_TINY
	obj_flags = CONDUCTS_ELECTRICITY
	force = 2
	throw_speed = 3
	throw_range = 5
	attack_verb_simple = list("whack", "spoon", "tap")
	attack_verb_continuous = list("whacks", "spoons", "taps")
	armor_type = /datum/armor/kitchen_spoon
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.2)
	custom_price = PAYCHECK_LOWER * 2
	tool_behaviour = TOOL_MINING
	toolspeed = 25 // Literally 25 times worse than the base pickaxe

	var/spoon_sip_size = 5

/obj/item/kitchen/spoon/Initialize(mapload)
	. = ..()
	create_reagents(5, INJECTABLE|OPENCONTAINER|DUNKABLE)
	register_item_context()

/obj/item/kitchen/spoon/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_change))

/obj/item/kitchen/spoon/proc/on_reagent_change(datum/reagents/reagents, ...)
	SIGNAL_HANDLER
	update_appearance(UPDATE_OVERLAYS)
	return NONE

/obj/item/kitchen/spoon/add_item_context(obj/item/source, list/context, atom/target, mob/living/user)
	if(target.is_open_container())
		context[SCREENTIP_CONTEXT_LMB] = "Empty spoonful"
		context[SCREENTIP_CONTEXT_RMB] = "Grab spoonful"
		return CONTEXTUAL_SCREENTIP_SET
	if(isliving(target))
		context[SCREENTIP_CONTEXT_LMB] = target == user ? "[spoon_sip_size >= reagents.maximum_volume ? "Swallow" : "Taste"] spoonful" : "Give spoonful"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/item/kitchen/spoon/update_overlays()
	. = ..()
	if(reagents.total_volume <= 0)
		return
	var/mutable_appearance/filled_overlay = mutable_appearance(icon, "[base_icon_state]_filled")
	filled_overlay.color = mix_color_from_reagents(reagents.reagent_list)
	. += filled_overlay

/obj/item/kitchen/spoon/attack(mob/living/target_mob, mob/living/user, params)
	if(!target_mob.reagents || reagents.total_volume <= 0)
		return  ..()

	if(target_mob.is_mouth_covered(ITEM_SLOT_HEAD) || target_mob.is_mouth_covered(ITEM_SLOT_MASK))
		if(target_mob == user)
			target_mob.balloon_alert(user, "can't eat with mouth covered!")
		else
			target_mob.balloon_alert(user, "[target_mob.p_their()] mouth is covered!")
		return TRUE

	if(target_mob == user)
		user.visible_message(
			span_notice("[user] scoops a spoonful into [user.p_their()] mouth."),
			span_notice("You scoop a spoonful into your mouth.")
		)

	else
		to_chat(target_mob, span_userdanger("[target_mob.is_blind() ? "Someone" : "[user]"] forces a spoon into your face!"))
		target_mob.balloon_alert(user, "feeding spoonful...")
		if(!do_after(user, 3 SECONDS, target_mob))
			target_mob.balloon_alert(user, "interrupted!")
			return TRUE

		to_chat(target_mob, span_userdanger("[target_mob.is_blind() ? "You are forced to" : "[user] forces you to"] swallow a spoonful of something!"))
		user.visible_message(
			span_danger("[user] scoops a spoonful into [target_mob]'s mouth."),
			span_notice("You scoop a spoonful into [target_mob]'s mouth.")
		)

	playsound(target_mob, 'sound/items/drink.ogg', rand(10,50), vary = TRUE)
	reagents.trans_to(target_mob, spoon_sip_size, methods = INGEST)
	return TRUE

/obj/item/kitchen/spoon/pre_attack(atom/attacked_atom, mob/living/user, params)
	. = ..()
	if(.)
		return
	if(isliving(attacked_atom))
		return
	if(!attacked_atom.is_open_container())
		return
	if(reagents.total_volume <= 0)
		return

	var/amount_given = reagents.trans_to(attacked_atom, reagents.maximum_volume)
	if(amount_given >= reagents.total_volume)
		attacked_atom.balloon_alert(user, "spoon emptied")
	else if(amount_given > 0)
		attacked_atom.balloon_alert(user, "spoon partially emptied")
	else
		attacked_atom.balloon_alert(user, "it's full!")
	return TRUE

/obj/item/kitchen/spoon/pre_attack_secondary(atom/attacked_atom, mob/living/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(isliving(attacked_atom))
		return SECONDARY_ATTACK_CALL_NORMAL
	if(!attacked_atom.is_open_container())
		return SECONDARY_ATTACK_CALL_NORMAL

	if(reagents.total_volume >= reagents.maximum_volume || attacked_atom.reagents.total_volume <= 0)
		return SECONDARY_ATTACK_CALL_NORMAL

	if(attacked_atom.reagents.trans_to(src, reagents.maximum_volume))
		attacked_atom.balloon_alert(user, "grabbed spoonful")
	else
		attacked_atom.balloon_alert(user, "spoon is full!")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/kitchen/spoon/plastic
	name = "plastic spoon"
	icon_state = "plastic_spoon"
	force = 0
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT * 1.2)
	toolspeed = 75 // The plastic spoon takes 5 minutes to dig through a single mineral turf... It's one, continuous, breakable, do_after...
	custom_price = PAYCHECK_LOWER * 1

/datum/armor/kitchen_spoon
	fire = 50
	acid = 30

/obj/item/kitchen/spoon/plastic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/easily_fragmented, PLASTIC_BREAK_PROBABILITY)

/obj/item/kitchen/spoon/soup_ladle
	name = "ladle"
	desc = "What is a ladle but a comically large spoon?"
	icon_state = "ladle"
	base_icon_state = "ladle"
	inhand_icon_state = "spoon"
	custom_price = PAYCHECK_LOWER * 4
	spoon_sip_size = 3 // just a taste

/obj/item/kitchen/spoon/soup_ladle/Initialize(mapload)
	. = ..()
	create_reagents(SOUP_SERVING_SIZE + 5, INJECTABLE|OPENCONTAINER)

#undef PLASTIC_BREAK_PROBABILITY
