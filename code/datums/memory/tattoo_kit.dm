
/obj/item/tattoo_kit
	name = "tattoo kit"
	desc = "A kit with all the tools necessary for losing a bet, or making otherwise incredibly indelible decisions."
	icon = 'icons/obj/maintenance_loot.dmi'
	icon_state = "tattoo_kit"
	///each use = 1 tattoo
	var/uses = 1
	///how many uses can be stored
	var/max_uses = 5

/obj/item/tattoo_kit/examine(mob/tattoo_artist)
	. = ..()
	if(!uses)
		. += span_warning("This kit has no uses left!")
	else
		. += span_notice("This kit has enough ink for [uses] use\s.")
	. += span_boldnotice("You can use a toner cartridge to refill this.")

/obj/item/tattoo_kit/attackby(obj/item/toner/ink_cart, mob/living/tattoo_artist, params)
	. = ..()
	if(!istype(ink_cart))
		return
	var/added_amount = round(ink_cart.charges / 5)
	if(added_amount == 0)
		return
	added_amount = min(uses + added_amount, max_uses)
	uses += min(max_uses, added_amount)
	qdel(ink_cart)
	balloon_alert(tattoo_artist, "added tattoo ink")

/obj/item/tattoo_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(!ishuman(user) || !ishuman(target))
		return
	var/mob/living/carbon/human/tattoo_artist = user
	var/mob/living/carbon/human/tattoo_holder = target
	if(!tattoo_artist.mind || tattoo_artist.combat_mode)
		return
	if(!uses)
		tattoo_artist.balloon_alert(tattoo_artist, "not enough ink!")
		return
	var/is_right_clicking = LAZYACCESS(params2list(click_parameters), RIGHT_CLICK)
	if(!tattoo_artist.mind.memories && is_right_clicking)
		tattoo_artist.balloon_alert(tattoo_artist, "nothing memorable to engrave, try leftclicking!")
		return
	var/selected_zone = tattoo_artist.zone_selected
	var/obj/item/bodypart/tattoo_target = tattoo_holder.get_bodypart(selected_zone)
	if(!tattoo_target)
		tattoo_artist.balloon_alert(tattoo_artist, "no limb to tattoo!")
		return
	if(HAS_TRAIT_FROM(tattoo_target, TRAIT_NOT_ENGRAVABLE, INNATE_TRAIT))
		tattoo_artist.balloon_alert(tattoo_artist, "bodypart cannot be engraved!")
		return
	if(HAS_TRAIT_FROM(tattoo_target, TRAIT_NOT_ENGRAVABLE, TRAIT_GENERIC))
		tattoo_artist.balloon_alert(tattoo_artist, "bodypart has already been engraved!")
		return
	var/tattoo_result
	if(is_right_clicking)
		tattoo_artist.visible_message(span_notice("[tattoo_artist] begins to tattoo something onto [tattoo_target] of [tattoo_holder]..."))
		var/datum/memory/memory_to_tattoo = tattoo_artist.mind.select_memory("tattoo")
		if(!memory_to_tattoo || !tattoo_artist.Adjacent(tattoo_holder) || !tattoo_holder.get_bodypart(selected_zone))
			return
		if(!do_after(tattoo_artist, 5 SECONDS, tattoo_holder))
			return
		if(!tattoo_holder.get_bodypart(selected_zone))
			return
		tattoo_result = memory_to_tattoo.generate_story(STORY_TATTOO)
		//prevent this memory from being used again this round
		memory_to_tattoo.memory_flags |= MEMORY_FLAG_ALREADY_USED
	else
		tattoo_artist.visible_message(span_notice("[tattoo_artist] begins to tattoo something onto [tattoo_target] of [tattoo_holder]..."))
		var/str = tgui_input_text(tattoo_artist, "What would you like to tattoo?", \
			"Tattoo Gun", \
			"a heart with an arrow through it with MOM in the center", \
			max_length = MAX_MESSAGE_LEN)
		if(!str)
			tattoo_artist.visible_message(span_notice("[tattoo_artist] decides to stop before tattooing."))
			return
		if(!do_after(tattoo_artist, 5 SECONDS, tattoo_holder))
			return
		tattoo_result = str
	tattoo_target.AddComponent(/datum/component/tattoo, tattoo_result)
