///////////////// A magical device /////////////////////

/obj/item/shadow_codex
	name = "Shadow Codex"
	icon = 'icons/obj/library.dmi' // Finished, but could be better. If you want to sprite it.
	icon_state = "shadowcodex"
	desc = "A book containing the secrets of shadows, written by a mysterious dapper looking man pictured on the front side. Looking at him fills you with <span class='userdanger'>dread</span>."
	var/mob/living/carbon/caster = null // Can be interpreted as owner too
	var/is_reading = 0 // is the user reading the book
	var/is_converting = 0 // is the user using the book on someone else
	var/times_used = 0 // How many times has the object been used
	var/mob/living/carbon/human/shadowperson // The summoned minion

/obj/item/shadow_codex/pickup(mob/user)
	if(caster == null || user == caster) // If you spawn this in the world, be sure to be the first to pick it up, or you won't be able to be the owner of it
		caster = user
		to_chat(user, "<span class=notice>Use the knowledge contained in this book wisely.</span>")
	else
		user.emote("scream")
		to_chat(user, "<span class=warning>I wouldn't do that if I were you.</span>")



/obj/item/shadow_codex/attack_self(mob/user)
	if(user.can_read(src))
		if(is_reading == 0)
			if(istype(user, /mob/living/carbon/human))
				is_reading = 1
				to_chat(user, "<span class=notice>You start flipping through its pages, with each page, you feel more insane.</span>")
				playsound(user.loc, 'sound/effects/pageturn1.ogg', 30, 1)
				if(do_after(user, 50, target = src))
					is_reading = 0
					to_chat(user, "<span class='userdanger'>You repeat the words written in the book. You suddenly feel a sharp pain in your head.</span>")
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
			to_chat(user, "<span class=notice>You are already casting a spell on [M]s brain.</span>")
		else
			to_chat(user, "<span class=warning>[M] is a unsuitable target for the spell.</span>")



// First time used 75 brain damge, second time 200 which should kill you
/obj/item/shadow_codex/proc/damage_brain(mob/living/carbon/C) // C is the target off the proc
	if(times_used == 0)
		C.adjustBrainLoss(75)
		++times_used
	else if(times_used >= 1)
		C.adjustBrainLoss(200)
		++times_used

// This will be used to spawn the minion, woop woop! The book won't listen to you when you are a shadow person.
// Intentional bug :) I intend this as a feature. Since noone can steal it from the floor
/obj/item/shadow_codex/proc/spawn_minion(mob/living/carbon/human/H)
	H.visible_message("<span class='userdanger'>As the shadows form into a humanoid figure. You suddenly find yourself in the mind of another being.</span>")
	var/mob/living/carbon/human/shadowperson_holder = new(H.loc)
	var/mob/dead/observer/ghost = H.ghostize(0)
	shadowperson_holder.set_species(/datum/species/shadow)
	shadowperson_holder.key = ghost.key // this is where the transfer happens
	H.Unconscious(75)
	shadowperson_holder.Unconscious(75) // both of them unconscious
	qdel(ghost)
	shadowperson = shadowperson_holder

/*
TODO:
Make it, so you can return to your old body, when you click on the shadow codex when you are a shadow person
Make it so others can't pick the item up if they are not the caster
*/