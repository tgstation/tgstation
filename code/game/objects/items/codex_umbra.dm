///////////////// A magical device /////////////////////

/obj/item/codex_umbra
	name = "Codex Umbra"
	icon = null // Not finished
	desc = "A book containing the secrets of shadows. Summons a Ethereal Bodyguard at the cost of ones well being."
	var/mob/living/carbon/caster = null // Can be interpreted as owner too
	var/is_reading = 0 // A variable to hold if the caster is reading it currently
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
				to_chat(user, "<span class=notice>You start flipping through the pages.</span>")
				playsound(user.loc, 'sound/effects/pageturn1.ogg', 30, 1)
				if(do_after(user, 50, target = src))
					is_reading = 0
					to_chat(user, "<span class=warning>The shadows under you start to twist.</span>")
					damage_brain()
					caster.emote("scream")
				else
					is_reading = 0
					to_chat(user, "<span class=warning>You decide to leave the book alone.</span>")
		else
			to_chat(user, "<span class=warning>You are already reading this book.</span>")

/obj/item/codex_umbra/attack(mob/M as mob, mob/user as mob)
	if(istype(M, /mob/living/carbon))
		to_chat(user, "<span class=warning>You start focusing on [M]s brain.</span>")
		if(do_after(user, 100, target = M))
			playsound(M, 'sound/effects/light_flicker.ogg', 30, 1)
			to_chat(M, "<span class='userdanger'>You feel your mind dripple out of your head as you try to comprehend what is going on.</span>")



// First time used = 50dmg, second time = 100, third time = 200 (should kill you)
/obj/item/codex_umbra/proc/damage_brain()
	if(times_used == 0)
		caster.adjustBrainLoss(25)
		++times_used
	else if(times_used == 1)
		caster.adjustBrainLoss(100)
		++times_used
	else if(times_used >= 2)
		caster.adjustBrainLoss(200)
		++times_used



/*
TODO:
Finish the icon
Make it so others can't pick the item up if they are not the caster
Make it so you can also target other people
Actually make the damn thing work by spawning the ethereal minion
Also add a mood event when you cast it
*/