///////////////// A magical device /////////////////////

/obj/item/shadow_codex
	name = "Shadow Codex"
	icon = 'icons/obj/library.dmi' // Finished, but could be better. If you want to sprite it.
	icon_state = "shadowcodex"
	desc = "A book containing the secrets of shadows. Summons a Ethereal Bodyguard at the cost of ones well being."
	var/mob/living/carbon/caster = null // Can be interpreted as owner too
	var/is_reading = 0 // is the user reading the book
	var/is_converting = 0 // is the user using the book on someone else
	var/times_used = 0 // How many times has the object been used

/obj/item/shadow_codex/pickup(mob/user)
	if(caster == null || user == caster) // If you spawn this in the world, be sure to be the first to pick it up, or you won't be able to be the owner of it
		caster = user
		to_chat(user, "<span class=notice>Use the knowledge contained in this book wisely.</span>")
	else
		user.emote("scream")
		to_chat(user, "<span class=warning>I wouldn't do that if I were you.</span>")
		return ..()



/obj/item/shadow_codex/attack_self(mob/user)
	if(user.can_read(src))
		if(is_reading == 0)
			if(istype(user, /mob/living/carbon/human))
				is_reading = 1
				to_chat(user, "<span class=notice>You start flipping through its pages, with each page you feel more insane.</span>")
				playsound(user.loc, 'sound/effects/pageturn1.ogg', 30, 1)
				if(do_after(user, 50, target = src))
					is_reading = 0
					to_chat(user, "<span class='userdanger'>You repeat the words written in the book. Suddenly you feel a sharp pain in your head.</span>")
					damage_brain(caster)
					spawn_minion(caster)
					caster.emote("scream")
				else
					is_reading = 0
					to_chat(user, "<span class=notice>You decide to leave the book alone.</span>")
		else
			to_chat(user, "<span class=warning>You are already reading this book.</span>")

/obj/item/shadow_codex/attack(mob/M as mob, mob/user as mob)
	if(istype(M, /mob/living/carbon/human) && M != caster && is_converting == 0)
		is_converting = 1
		to_chat(user, "<span class=warning>You start focusing on [M]s brain while reciting the words written in the book.</span>")
		to_chat(M, "<span class='userdanger'>You begin to feel your mind drip</span>")
		M.emote("scream")
		if(do_after(user, 100, target = M))
			is_converting = 0
			playsound(M, 'sound/effects/light_flicker.ogg', 30, 1)
			damage_brain(M)
			spawn_minion(caster)
		else
			is_converting = 0
			to_chat(user, "<span class='userdanger'>The spell has been disrupted.</span>")
			to_chat(M, "<span class='userdanger'>You feel in control of your thoughts again.</span>")
	else
		if(is_converting == 1)
			to_chat(user, "<span class=warning>You are already casting a spell on [M]s brain.</span>")
		else
			to_chat(user, "<span class=warning>[M] is a unsuitable target for the spell.</span>")



// First time used = 25dmg (should display only a warning), second time = 100dmg(should give you a trauma), third time = 200 (should kill you)
/obj/item/shadow_codex/proc/damage_brain(mob/living/carbon/C) // C is the target off the proc
	if(times_used == 0)
		C.adjustBrainLoss(25)
		++times_used
	else if(times_used == 1)
		C.adjustBrainLoss(100)
		++times_used
	else if(times_used >= 2)
		C.adjustBrainLoss(200)
		++times_used

// This will be used to spawn the minion, now to decide if draining a mind of someone makes a stronger one or no.
/obj/item/shadow_codex/proc/spawn_minion(mob/living/carbon/human/H)
	H.visible_message("<span class='userdanger'>The shadows start to form into a humanoid being.</span>")
	var/mob/living/carbon/human/shadowperson = new(H.loc)
	shadowperson.apply_effect(25,EFFECT_UNCONSCIOUS, FALSE)
	shadowperson.set_species(/datum/species/shadow)

/*
TODO:
Make it so others can't pick the item up if they are not the caster
Actually make the damn thing work by spawning the ethereal minion
Also add a mood event when you cast it (maybe? maybe not..)
Add the spawn minion proc
profit
*/