///////////////// A magical device /////////////////////

/obj/item/codex_umbra
	name = "Codex Umbra"
	icon = null // Not finished
	desc = "A book containing the secrets of shadows. Summons a Ethereal Bodyguard at the cost of ones well being."
	var/mob/living/carbon/caster = null // Can be interpreted as owner too
	var/is_reading = 0

/obj/item/codex_umbra/pickup(mob/user)
	if(caster == null || user == caster) // If you spawn this in the world, be sure to be the first to pick it up, or you won't be able to be the owner of it
		caster = user
		to_chat(user, "<span class=warning>You see shadows move in the corner of your eye.</span>")
	else
		user.emote("scream")
		to_chat(user, "<span class=warning>I wouldn't do that if I were you.</span>")



/obj/item/codex_umbra/attack_self(mob/user) // No way i made this fucking stupid dumb pathetic shit work
	if(user.can_read(src))
		if(is_reading == 0)
			if(istype(user, /mob/living/carbon))
				is_reading = 1
				to_chat(user, "<span class=warning>You start flipping through the pages.</span>")
				playsound(user.loc, 'sound/effects/pageturn1.ogg', 30, 1)
				if(do_after(user, 50, target = src))
					is_reading = 0
					to_chat(user, "<span class=warning>The shadows under you start to twist.</span>")
				else
					is_reading = 0
					to_chat(user, "<span class=warning>You decide to leave the book alone.</span>")
		else
			to_chat(user, "<span class=warning>You are already reading this book.</span>")