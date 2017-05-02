/datum/language/common/codespeak
	name = "Codespeak"
	desc = "Syndicate operatives can use a series of codewords to convey complex information, while sounding like random concepts and drinks to anyone listening in."
	key = "t"
	default_priority = 0
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD
	icon_state = "codespeak"

/datum/language/common/codespeak/scramble(input)
	var/lookup = check_cache(input)
	if(lookup)
		return lookup

	. = ""
	var/list/words = list()
	while(length(.) < length(input))
		words += generate_code_phrase(return_list=TRUE)
		. = jointext(words, ", ")

	. = capitalize(.)

	add_to_cache(input, .)

/obj/item/weapon/codespeak_manual
	name = "codespeak manual"
	desc = "The book's cover reads: \"Codespeak(tm) - Secure your communication with metaphors so elaborate, they seem randomly generated!\""
	icon = 'icons/obj/library.dmi'
	icon_state = "book2"
	var/charges = 1

/obj/item/weapon/codespeak_manual/attack_self(mob/living/user)
	if(!isliving(user))
		return

	if(user.has_language(/datum/language/common/codespeak))
		to_chat(user, "<span class='boldannounce'>You start skimming through [src], but you already know Codespeak.</span>")
		return

	to_chat(user, "<span class='boldannounce'>You start skimming through [src], and suddenly your mind is filled with codewords and responses.</span>")
	user.grant_language(/datum/language/common/codespeak)

	use_charge()

/obj/item/weapon/codespeak_manual/attack(mob/living/M, mob/living/user)
	if(!istype(M) || !istype(user))
		return
	playsound(loc, "punch", 25, 1, -1)

	if(M.stat == DEAD)
		M.visible_message("<span class='danger'>[user] smacks [M]'s lifeless corpse with [src].</span>", "<span class='userdanger'>[user] smacks your lifeless corpse with [src].</span>", "<span class='italics'>You hear smacking.</span>")
	else if(M.has_language(/datum/language/common/codespeak))
		M.visible_message("<span class='danger'>[user] beats [M] over the head with [src]!</span>", "<span class='userdanger'>[user] beats you over the head with [src]!</span>", "<span class='italics'>You hear smacking.</span>")
	else
		M.visible_message("<span class='notice'>[user] teaches [M] by beating them over the head with [src]!</span>", "<span class='boldnotice'>As [user] hits you with [src], codewords and responses flow through your mind.</span>", "<span class='italics'>You hear smacking.</span>")
		M.grant_language(/datum/language/common/codespeak)
		use_charge()

/obj/item/weapon/codespeak_manual/proc/use_charge()
	charges--
	if(!charges)
		say("Automatic data erasure in progress!")
		visible_message("<span class='warning'>The cover and contents of [src] start shifting and changing!</span>")

		var/obj/item/weapon/book/random/newbook = new(get_turf(src))
		qdel(src)

		if(ismob(loc))
			var/mob/M = loc
			if(M.is_holding(src))
				M.put_in_active_hand(newbook)

/obj/item/weapon/codespeak_manual/unlimited
	name = "deluxe codespeak manual"
	charges = INFINITY
