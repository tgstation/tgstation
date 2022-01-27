
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

/obj/item/tattoo_kit/attack(mob/living/tattoo_holder, mob/living/tattoo_artist, params)
	. = ..()
	if(.)
		return TRUE
	if(!tattoo_artist.mind || tattoo_artist.combat_mode)
		return
	if(!uses)
		balloon_alert(tattoo_artist, "not enough ink!")
		return
	if(!tattoo_artist.mind.memories)
		balloon_alert(tattoo_artist, "nothing memorable to engrave!")
		return
	var/selected_zone = tattoo_artist.zone_selected
	var/obj/item/bodypart/tattoo_target = tattoo_holder.get_bodypart(selected_zone)
	if(!tattoo_target)
		balloon_alert(tattoo_artist, "no limb to tattoo!")
		return
	if(HAS_TRAIT_FROM(tattoo_target, TRAIT_NOT_ENGRAVABLE, INNATE_TRAIT))
		balloon_alert(tattoo_artist, "bodypart cannot be engraved!")
		return
	if(HAS_TRAIT_FROM(tattoo_target, TRAIT_NOT_ENGRAVABLE, TRAIT_GENERIC))
		balloon_alert(tattoo_artist, "bodypart has already been engraved!")
		return
	var/datum/memory/memory_to_tattoo = tattoo_artist.mind.select_memory("tattoo")
	if(!memory_to_tattoo || !tattoo_artist.Adjacent(tattoo_holder) || !tattoo_holder.get_bodypart(selected_zone))
		return

	tattoo_artist.visible_message(span_notice("[tattoo_artist] begins to tattoo something onto [tattoo_target] of [tattoo_holder]..."))
	if(!do_after(tattoo_artist, 5 SECONDS, tattoo_holder))
		return
	if(!tattoo_holder.get_bodypart(selected_zone))
		return
	tattoo_target.AddComponent(/datum/component/tattoo, memory_to_tattoo.generate_story(STORY_TATTOO))
	//prevent this memory from being used again this round
	memory_to_tattoo.memory_flags |= MEMORY_FLAG_ALREADY_USED
