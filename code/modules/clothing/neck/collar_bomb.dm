///Special neckwear that kills its wearer if triggered, by either its specific remote or assemblies.
/obj/item/clothing/neck/collar_bomb
	name = "collar bomb"
	desc = "A cumbersome collar of some sort, filled with just enough explosive to rip one's head off... at least that's what it reads on the front tag."
	icon_state = "collar_bomb"
	icon = 'icons/obj/clothing/neck.dmi'
	inhand_icon_state = "reverse_bear_trap"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	clothing_flags = INEDIBLE_CLOTHING
	armor_type = /datum/armor/collar_bomb
	equip_delay_self = 6 SECONDS
	equip_delay_other = 8 SECONDS
	///The button it's associated with
	var/obj/item/collar_bomb_button/button
	///Whether the collar countdown has been triggered.
	var/active = FALSE

/datum/armor/collar_bomb
	fire = 97
	bomb = 97
	acid = 97

/obj/item/clothing/neck/collar_bomb/Initialize(mapload, obj/item/collar_bomb_button/button)
	. = ..()
	src.button = button
	button?.collar = src
	set_wires(new /datum/wires/collar_bomb(src))

/obj/item/clothing/neck/collar_bomb/Destroy()
	button?.collar = null
	button = null
	return ..()

/obj/item/clothing/neck/collar_bomb/examine(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_NECK) == src)
		return
	. += span_tinynotice("It has a [EXAMINE_HINT("wire")] panel that could be interacted with...")

/obj/item/clothing/neck/collar_bomb/attackby(obj/item/item, mob/user, list/modifiers)
	if(is_wire_tool(item))
		wires.interact(user)
	else
		return ..()

/obj/item/clothing/neck/collar_bomb/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_NECK)
		ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/neck/collar_bomb/dropped(mob/user, silent = FALSE)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/neck/collar_bomb/proc/explosive_countdown(ticks_left)
	active = TRUE
	if(ticks_left > 0)
		playsound(src, 'sound/items/timer.ogg', 30, FALSE)
		balloon_alert_to_viewers("[ticks_left]")
		ticks_left--
		addtimer(CALLBACK(src, PROC_REF(explosive_countdown), ticks_left), 1 SECONDS)
		return

	playsound(src, 'sound/effects/snap.ogg', 75, TRUE)
	if(!ishuman(loc))
		balloon_alert_to_viewers("dud...")
		active = FALSE
		return
	var/mob/living/carbon/human/brian = loc
	if(brian.get_item_by_slot(ITEM_SLOT_NECK) != src)
		balloon_alert_to_viewers("dud...")
		active = FALSE
		return
	visible_message(span_warning("[src] goes off, outright decapitating [brian]!"), span_hear("You hear a fleshy boom!"))
	playsound(src, SFX_EXPLOSION, 30, TRUE)
	brian.apply_damage(200, BRUTE, BODY_ZONE_HEAD)
	var/obj/item/bodypart/head/myhead = brian.get_bodypart(BODY_ZONE_HEAD)
	myhead?.dismember()
	brian.investigate_log("has been decapitated by [src].", INVESTIGATE_DEATHS)
	flash_color(brian, flash_color = COLOR_RED, flash_time = 1 SECONDS)
	qdel(src)

///The button that detonates the collar.
/obj/item/collar_bomb_button
	name = "big yellow button"
	desc = "It looks like a big red button, except it's yellow. It comes with a heavy trigger, to avoid accidents."
	icon = 'icons/obj/devices/assemblies.dmi'
	icon_state = "bigyellow"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	///The collar bomb it's associated with.
	var/obj/item/clothing/neck/collar_bomb/collar

/obj/item/collar_bomb_button/attack_self(mob/user)
	. = ..()
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return
	balloon_alert_to_viewers("pushing the button...")
	if(!do_after(user, 1.2 SECONDS, target = src))
		return
	playsound(user, 'sound/machines/click.ogg', 25, TRUE)
	if(!collar|| collar.active)
		return
	collar.explosive_countdown(ticks_left = 5)
	if(!ishuman(collar.loc))
		return
	var/mob/living/carbon/human/brian = collar.loc
	if(brian.get_item_by_slot(ITEM_SLOT_NECK) == collar)
		brian.investigate_log("has had their [collar] triggered by [user] via yellow button.", INVESTIGATE_DEATHS)


/obj/item/collar_bomb_button/Destroy()
	collar?.button = null
	collar = null
	return ..()
