///////////////// A magical device /////////////////////

/obj/item/codex_umbra
	name = "Codex Umbra"
	icon = null // Not finished
	desc = "A book containing the secrets of shadows. Summons a Ethereal Bodyguard at the cost of ones well being."
	var/mob/living/carbon/caster = null // Can be interpreted as owner too
	var/is_reading = 0 // I made it a variable of the object for simplicity
	var/times_used = 0 // How many times has the object been used

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
					damage_brain()
				else
					is_reading = 0
					to_chat(user, "<span class=warning>You decide to leave the book alone.</span>")
		else
			to_chat(user, "<span class=warning>You are already reading this book.</span>")


// First time used = 50dmg, second time = 100, third time = 200 (should kill you)
/obj/item/codex_umbra/proc/damage_brain()
	if(times_used == 0)
		caster.apply_damage(damage = 50,damage_type = BRUTE, BODY_ZONE_CHEST)
		++times_used
	else if(times_used == 1)
		caster.apply_damage(damage = 100,damage_type = BRUTE, BODY_ZONE_CHEST)
		++times_used
	else if(times_used >= 2)
		caster.apply_damage(damage = 200,damage_type = BRUTE, BODY_ZONE_CHEST)
		++times_used



/*
TODO:
Finish the icon
Make it so others can't pick the item up if they are not the caster
Make a use var and damage the brain when it needs to be damaged
Make it so you can also target other people

uhhh
Play around with the damage_brain proc.
*/