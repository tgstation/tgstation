#define FORTIFY_FILTER "ANGRY_GLOW"

//Pillow and pillow related items
/obj/item/pillow
	name = "pillow"
	desc = "A soft and fluffy pillow. You can smack someone with this!"
	icon = 'icons/obj/bed.dmi'
	icon_state = "pillow_1_t"
	inhand_icon_state = "pillow_t"
	lefthand_file = 'icons/mob/inhands/items/pillow_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/pillow_righthand.dmi'
	force = 5
	w_class = WEIGHT_CLASS_NORMAL
	damtype = STAMINA
	///change the description based on the pillow tag
	var/static/tag_desc = "This one seems to have its tag removed."
	///pillow tag is attached to it
	var/obj/item/clothing/neck/pillow_tag/pillow_trophy
	///whoever last use this pillow
	var/last_fighter
	///for selecting the various sprite variation, defaults to the blank white pillow
	var/variation = 1
	///for alternating between hard hitting sound vs soft hitting sound
	var/hit_sound
	///if we have a brick inside us
	var/bricked = FALSE
	///Stamina recoil from hitting
	var/stam_recoil = 5
	drop_sound = SFX_CLOTH_DROP
	pickup_sound = SFX_CLOTH_PICKUP

/obj/item/pillow/Initialize(mapload)
	. = ..()
	if(!pillow_trophy)
		pillow_trophy = new(src)
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 5, \
		force_wielded = 10, \
	)
	AddElement(/datum/element/disarm_attack)
	RegisterSignal(src, COMSIG_ITEM_CAN_DISARM_ATTACK, PROC_REF(can_disarm_attack))

	var/static/list/slapcraft_recipe_list = list(\
		/datum/crafting_recipe/pillow_suit, /datum/crafting_recipe/pillow_hood,\
		)

	AddElement(
		/datum/element/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/pillow/Destroy(force)
	. = ..()
	QDEL_NULL(pillow_trophy)

/obj/item/pillow/proc/can_smother(mob/living/victim, mob/living/user)
	return (victim.body_position == LYING_DOWN || (user.grab_state >= GRAB_AGGRESSIVE && user.pulling == victim))

/obj/item/pillow/proc/can_disarm_attack(datum/source, mob/living/victim, mob/living/user, message)
	SIGNAL_HANDLER
	if(can_smother(victim, user))
		return COMPONENT_BLOCK_ITEM_DISARM_ATTACK

/obj/item/pillow/attack(mob/living/carbon/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!iscarbon(target_mob))
		return
	if(bricked || HAS_TRAIT(src, TRAIT_WIELDED))
		hit_sound = 'sound/items/pillow/pillow_hit2.ogg'
	else
		hit_sound = 'sound/items/pillow/pillow_hit.ogg'
	user.apply_damage(stam_recoil, STAMINA) //Had to be done so one person cannot keep multiple people stam critted
	last_fighter = user
	new /obj/effect/temp_visual/pillow_hit(get_turf(target_mob))
	playsound(user, hit_sound, 80) //the basic 50 vol is barely audible

/obj/item/pillow/attack_secondary(mob/living/carbon/victim, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!istype(victim))
		return
	if(victim.is_mouth_covered() || !victim.get_bodypart(BODY_ZONE_HEAD))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You can't bring yourself to harm [victim]"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(can_smother(victim, user))
		user.visible_message("[user] starts to smother [victim]!", span_notice("You begin smothering [victim]!"), vision_distance = COMBAT_MESSAGE_RANGE)
		INVOKE_ASYNC(src, PROC_REF(smothering), user, victim)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/pillow/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!bricked && istype(tool, /obj/item/stack/sheet/mineral/sandstone))
		var/obj/item/stack/sheet/mineral/sandstone/brick = tool
		balloon_alert(user, "inserting brick...")
		if(!do_after(user, 2 SECONDS, src))
			return ITEM_INTERACT_BLOCKING
		if(!brick.use(1))
			balloon_alert(user, "not enough bricks!")
			return ITEM_INTERACT_BLOCKING
		balloon_alert(user, "bricked!")
		become_bricked()
		return ITEM_INTERACT_SUCCESS

	if(istype(tool, /obj/item/clothing/neck/pillow_tag))
		if(pillow_trophy)
			balloon_alert(user, "tag is intact.")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING
		pillow_trophy = tool
		balloon_alert(user, "honor reclaimed!")
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/item/pillow/examine(mob/user)
	. = ..()
	if(bricked)
		. += span_info("[p_They()] feel[p_s()] unnaturally heavy.")
	if(pillow_trophy)
		. += span_notice("Alt-click to remove the tag!")

/obj/item/pillow/click_alt(mob/user)
	if(!user.can_hold_items(src))
		return CLICK_ACTION_BLOCKING
	if(!pillow_trophy)
		balloon_alert(user, "no tag!")
		return CLICK_ACTION_BLOCKING
	balloon_alert(user, "removing tag...")
	if(!do_after(user, 2 SECONDS, src))
		return CLICK_ACTION_BLOCKING
	if(last_fighter)
		pillow_trophy.desc = "A pillow tag taken from [last_fighter] after a gruesome pillow fight."
	user.put_in_hands(pillow_trophy)
	pillow_trophy = null
	balloon_alert(user, "tag removed")
	playsound(user,'sound/items/poster/poster_ripped.ogg', 50)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/pillow/update_appearance(updates)
	. = ..()
	if(!pillow_trophy)
		desc = "A soft and fluffy pillow. You can smack someone with this! [tag_desc]"
		icon_state = "pillow_[variation]"
		inhand_icon_state = "pillow_no_t"
	else
		desc = "A soft and fluffy pillow. You can smack someone with this!"
		icon_state = "pillow_[variation]_t"
		inhand_icon_state = "pillow_t"

/// Puts a brick inside the pillow, increasing its damage
/obj/item/pillow/proc/become_bricked()
	bricked = TRUE
	var/datum/component/two_handed/two_handed = GetComponent(/datum/component/two_handed)
	if(two_handed)
		AddComponent(/datum/component/two_handed, force_unwielded = two_handed.force_unwielded + 5, force_wielded = two_handed.force_wielded + 10)
	force += 5
	update_appearance()

/// Smothers the victim while the do_after succeeds and the victim is laying down or being strangled
/obj/item/pillow/proc/smothering(mob/living/carbon/user, mob/living/carbon/victim)
	while(victim)
		if(!can_smother(victim, user))
			break
		if(!do_after(user, 1 SECONDS, victim))
			break
		victim.losebreath += 1
	victim.visible_message("[victim] manages to escape being smothered!", span_notice("You break free!"), vision_distance = COMBAT_MESSAGE_RANGE)

/obj/item/pillow/random

/obj/item/pillow/random/Initialize(mapload)
	. = ..()
	variation = rand(1, 4)
	icon_state = "pillow_[variation]_t"
	//random pillows spawn bricked sometimes, fuck you
	if(prob(1))
		become_bricked()

/obj/item/pillow/suit_pillow
	stam_recoil = 0

/obj/item/clothing/suit/pillow_suit
	name = "pillow suit"
	desc = "Part man, part pillow. All CARNAGE!"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	cold_protection = CHEST|GROIN|ARMS|LEGS //a pillow suit must be hella warm
	allowed = list(/obj/item/pillow) //moar pillow carnage
	icon = 'icons/obj/bed.dmi'
	worn_icon = 'icons/mob/clothing/suits/pillow.dmi'
	icon_state = "pillow_suit"
	armor_type = /datum/armor/suit_pillow_suit
	custom_materials = list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT)
	var/obj/item/pillow/suit_pillow/unstoppably_plushed

/datum/armor/suit_pillow_suit
	melee = 5
	acid = 75


/obj/item/clothing/suit/pillow_suit/Initialize(mapload)
	. = ..()
	unstoppably_plushed = new(src)
	AddComponent(/datum/component/bumpattack, proxy_weapon = unstoppably_plushed, valid_inventory_slot = ITEM_SLOT_OCLOTHING)

/obj/item/clothing/suit/pillow_suit/Destroy()
	. = ..()
	QDEL_NULL(unstoppably_plushed)


/obj/item/clothing/head/pillow_hood
	name = "pillow hood"
	desc = "The final piece of the pillow juggernaut"
	body_parts_covered = HEAD
	icon = 'icons/obj/bed.dmi'
	worn_icon = 'icons/mob/clothing/suits/pillow.dmi'
	icon_state = "pillowcase_hat"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS
	armor_type = /datum/armor/head_pillow_hood
	custom_materials = list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT)

/datum/armor/head_pillow_hood
	melee = 5
	acid = 75

/obj/item/clothing/neck/pillow_tag
	name = "pillow tag"
	desc = "A price tag for the pillow. It appears to have space to fill names in."
	icon = 'icons/obj/bed.dmi'
	icon_state = "pillow_tag"
	worn_icon = 'icons/mob/clothing/neck.dmi'
	worn_icon_state = "pillow_tag"
	body_parts_covered = NECK

/obj/item/pillow/clown
	name = "clown pillow"
	desc = "Daww look at that little clown!"
	icon_state = "pillow_5_t"
	variation = 5

/obj/item/pillow/mime
	name = "mime pillow"
	desc = "Daww look at that little mime!"
	icon_state = "pillow_6_t"
	variation = 6

/obj/item/spear/pillow
	name = "pillow lance"
	desc = "Looks like someone duct-taped a body-pillow onto a long pole, as some kind of blunt spear."
	damtype = STAMINA
	force_unwielded = 12
	force_wielded = 18
	icon_state = "pillow_lance0"
	icon_prefix = "pillow_lance"
	hitsound = 'sound/items/pillow/pillow_hit.ogg'
	///The current direction of the jousting.
	VAR_FINAL/current_direction = NONE
	///How many tiles we've charged up thus far
	VAR_FINAL/current_tile_charge = 0
	///The min amount of tiles before you can joust someone.
	var/min_tile_charge = 2
	///How much of an increase in damage is achieved every tile moved during jousting.
	var/damage_boost_per_tile = 2
	///How much stamina we lose per tile charge
	var/stamina_per_tile = 5
	///Tracker for when we last moved to ensure its a continous charge
	VAR_FINAL/last_charge_move
	///Chargine state
	VAR_FINAL/charging = FALSE


/obj/item/spear/pillow/on_wield(obj/item/source, mob/living/carbon/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CLIENT_MOVED, PROC_REF(check_move))
	RegisterSignal(user, COMSIG_LIVING_MOB_BUMP, PROC_REF(impale))

/obj/item/spear/pillow/on_unwield(obj/item/source, mob/living/carbon/user)
	. = ..()
	reset_user(user)

/obj/item/spear/pillow/dropped(mob/user, silent)
	. = ..()
	reset_user(user)

/obj/item/spear/pillow/proc/reset_user(mob/user)
	UnregisterSignal(user, list(COMSIG_MOB_CLIENT_MOVED, COMSIG_LIVING_MOB_BUMP))
	reset_charge(user)

/obj/item/spear/pillow/proc/reset_charge(mob/living/user)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/lance_charge)
	current_tile_charge = initial(current_tile_charge)
	current_direction = user.dir
	charging = FALSE

/obj/item/spear/pillow/proc/check_move(mob/living/user)
	SIGNAL_HANDLER

	if(current_direction != user.dir || world.time > last_charge_move + 0.5 SECONDS)
		reset_charge(user)
	else
		if(current_tile_charge >= min_tile_charge)
			if(!charging)
				user.add_movespeed_modifier(/datum/movespeed_modifier/lance_charge)
				user.balloon_alert(user, "charging!")
				charging = TRUE
			user.adjust_stamina_loss(stamina_per_tile)
		current_tile_charge++
	last_charge_move = world.time

/obj/item/spear/pillow/proc/impale(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	if(current_tile_charge < min_tile_charge)
		user.balloon_alert(user, "too slow!")
		return
	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attackby), src, user)
	target.adjust_stamina_loss(damage_boost_per_tile * current_tile_charge)
	playsound(user, 'sound/effects/bang.ogg', 40, TRUE)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/lance_charge)

/obj/item/spear/pillow/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()

	new /obj/effect/temp_visual/pillow_hit(get_turf(target))

/obj/item/shield/mattress
	name = "mattress shield"
	desc = "A typical twin mattress repurposed into a makeshift shield"
	icon_state = "mattress_shield"
	damtype = STAMINA
	force = 10
	actions_types = list(/datum/action/item_action/fortify)
	action_slots = ALL
	hitsound = 'sound/items/pillow/pillow_hit.ogg'
	block_chance = 20
	max_integrity = 30
	custom_materials = list(/datum/material/paper = SHEET_MATERIAL_AMOUNT * 4)
	var/hunkered = FALSE
	///Aura color for juggernaut mode
	var/outline_colour = "#eb0c07"

/obj/item/shield/mattress/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()

	new /obj/effect/temp_visual/pillow_hit(get_turf(target))

/obj/item/shield/mattress/dropped(mob/user, silent)
	. = ..()
	if(hunkered)
		un_fortify(user)

/obj/item/shield/mattress/ui_action_click(mob/user, actiontype)
	. = ..()

	if(!hunkered)
		fortify(user)
	else
		un_fortify(user)

/obj/item/shield/mattress/proc/fortify(mob/user)
	hunkered = TRUE
	force += 5
	block_chance += 20
	ADD_TRAIT(user, TRAIT_BRAWLING_KNOCKDOWN_BLOCKED, HELD_ITEM_TRAIT)
	user.add_movespeed_modifier(/datum/movespeed_modifier/pillow_fortify)
	user.visible_message(span_alert("[user.name] hunkers down into a defensive stance!"))
	user.add_filter(FORTIFY_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 0, "size" = 1))
	var/filter = user.get_filter(FORTIFY_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

/obj/item/shield/mattress/proc/un_fortify(mob/user)
	hunkered = FALSE
	force -= 5
	block_chance -= 20
	REMOVE_TRAIT(user, TRAIT_BRAWLING_KNOCKDOWN_BLOCKED, HELD_ITEM_TRAIT)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/pillow_fortify)
	var/filter = user.get_filter(FORTIFY_FILTER)
	animate(filter)
	user.remove_filter(FORTIFY_FILTER)
	user.visible_message(span_alert("[user] loosens up and relaxes a bit."))

#undef FORTIFY_FILTER
