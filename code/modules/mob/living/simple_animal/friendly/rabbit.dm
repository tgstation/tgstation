//Just standard rabbits. If you want to toy around with the rabbits that spawn for Easter, seek out easter.dm

/mob/living/simple_animal/rabbit
	name = "\improper rabbit"
	desc = "The hippiest hop around."
	gender = PLURAL
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	health = 15
	maxHealth = 15
	icon = 'icons/mob/easter.dmi'
	icon_state = "b_rabbit_white"
	icon_living = "b_rabbit_white"
	icon_dead = "b_rabbit_white_dead"
	speak_emote = list("sniffles","twitches")
	emote_hear = list("hops.")
	emote_see = list("hops around","bounces up and down")
	butcher_results = list(/obj/item/food/meat/slab = 1)
	can_be_held = TRUE
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	///passed to animal_variety component as the prefix icon.
	var/icon_prefix = "rabbit"
	var/obj/item/inventory_head

/mob/living/simple_animal/rabbit/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "hops around happily!")
	AddElement(/datum/element/animal_variety, icon_prefix, pick("brown","black","white"), TRUE)
	var/list/feed_messages = list("[p_they()] nibbles happily.", "[p_they()] noms happily.")


/mob/living/simple_animal/rabbit/proc/place_on_head(obj/item/item_to_add, mob/user)
	if(inventory_head)
		if(user)
			to_chat(user, span_warning("You can't put more than one hat on [src]!"))
		return
	if(!item_to_add)
		user.visible_message(span_notice("[user] pets [src]."), span_notice("You rest your hand on [src]'s head for a moment."))
		if(flags_1 & HOLOGRAM_1)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
		return

/mob/living/simple_animal/rabbit/space
	icon_state = "s_rabbit_white"
	icon_living = "s_rabbit_white"
	icon_dead = "s_rabbit_white_dead"
	icon_prefix = "s_rabbit"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	unsuitable_atmos_damage = 0

/mob/living/simple_animal/rabbit/empty //top hats summon these kinds of rabbits instead of the normal kind
