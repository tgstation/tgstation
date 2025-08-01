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

/obj/item/pillow/attack(mob/living/carbon/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!iscarbon(target_mob))
		return
	if(bricked || HAS_TRAIT(src, TRAIT_WIELDED))
		hit_sound = 'sound/items/pillow/pillow_hit2.ogg'
	else
		hit_sound = 'sound/items/pillow/pillow_hit.ogg'
	user.apply_damage(5, STAMINA) //Had to be done so one person cannot keep multiple people stam critted
	last_fighter = user
	playsound(user, hit_sound, 80) //the basic 50 vol is barely audible

/obj/item/pillow/attack_secondary(mob/living/carbon/victim, mob/living/user, params)
	. = ..()
	if(!istype(victim))
		return
	if(victim.is_mouth_covered() || !victim.get_bodypart(BODY_ZONE_HEAD))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You can't bring yourself to harm [victim]"))
		return
	if((victim.body_position == LYING_DOWN) || ((user.grab_state >= GRAB_AGGRESSIVE) && (user.pulling == victim)))
		user.visible_message("[user] starts to smother [victim]", span_notice("You begin smothering [victim]"), vision_distance = COMBAT_MESSAGE_RANGE)
		INVOKE_ASYNC(src, PROC_REF(smothering), user, victim)

/obj/item/pillow/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!bricked && istype(attacking_item, /obj/item/stack/sheet/mineral/sandstone))
		var/obj/item/stack/sheet/mineral/sandstone/brick = attacking_item
		balloon_alert(user, "inserting brick...")
		if(!do_after(user, 2 SECONDS, src))
			return
		if(!brick.use(1))
			balloon_alert(user, "not enough bricks!")
			return
		balloon_alert(user, "bricked!")
		become_bricked()
		return
	if(istype(attacking_item, /obj/item/clothing/neck/pillow_tag))
		if(!pillow_trophy)
			user.transferItemToLoc(attacking_item, src)
			pillow_trophy = attacking_item
			balloon_alert(user, "honor reclaimed!")
			update_appearance()
			return
		else
			balloon_alert(user, "tag is intact.")
			return
	return ..()

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
		if((victim.body_position != LYING_DOWN) && ((user.grab_state < GRAB_AGGRESSIVE) || (user.pulling != victim)))
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
	var/obj/item/pillow/unstoppably_plushed

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
