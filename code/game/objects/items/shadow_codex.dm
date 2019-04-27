///////////////// A magical device /////////////////////

/obj/item/shadow_codex
	name = "Shadow Codex"
	icon = 'icons/obj/library.dmi' // Finished, but could be better. If you want to sprite it.
	icon_state = "shadowcodex"
	desc = "A book containing the secrets of shadows, written by a mysterious dapper looking man, pictured on the first page. Looking at him fills you with <span class=warning>dread</span>."
	var/mob/living/carbon/caster = null // Can be interpreted as owner too
	var/is_reading = 0 // is the user reading the book
	var/is_converting = 0 // is the user using the book on someone else
	var/times_used = 0 // How many times has the object been used
	var/mob/living/carbon/human/shadowperson // The summoned minion

/obj/item/shadow_codex/pickup(mob/living/carbon/user) // called on pickup
	if(caster == null || user == caster) // If you spawn this in the world, be sure to be the first to pick it up, or you won't be able to be the owner of it
		caster = user
		to_chat(user, "<span class=notice>Use the knowledge contained in this book wisely.</span>")
	else if(shadowperson != null) // if you try to pickup the book as a shadow person
		to_chat(user, "<span class=warning>You try to return to your original body.</span>")
		if(do_after(user, 50, target = src)) // you can keep smashing the pickup and have multiple bars, it shouldn't break anything so im going to just leave it
			shadow_pickup(shadowperson)
			to_chat(user, "<span class='userdanger'>You return to your body, killing your shadow puppet.</span>")
		else
			user.Paralyze(100) // Quite a price to pay if you move when returning to your body
			to_chat(user, "<span class='userdanger'>You fail to return to your body. Perhaps you should try again.</span>")
	else // if you are not the caster of the book then this happens
		user.Paralyze(10)
		user.emote("scream")
		to_chat(user, "<span class=warning>You feel as if being watched by the shadows. It's probably best to leave this book alone.</span>")
		user.adjustBrainLoss(10) // don't touch it your you will go insane and die



/obj/item/shadow_codex/attack_self(mob/user) // when used inhand
	if(user.can_read(src))
		if(is_reading == 0) // is he already reading this
			if(istype(user, /mob/living/carbon/human))
				is_reading = 1
				to_chat(user, "<span class=notice>You start flipping through its pages, with each page, you feel more insane.</span>")
				playsound(user.loc, 'sound/effects/pageturn1.ogg', 30, 1)
				if(do_after(user, 50, target = src))
					is_reading = 0
					to_chat(user, "<span class='userdanger'>You recite the words written in the book. As they start to glow, you suddenly feel a sharp pain in your head.</span>")
					damage_brain(caster)
					spawn_minion(caster)
					caster.emote("scream")
				else // happens when you don't finish reading the book
					is_reading = 0
					to_chat(user, "<span class=notice>You decide to leave the book alone.</span>")
		else // happens when you are already reading it
			to_chat(user, "<span class=warning>You are already reading this book.</span>")

/obj/item/shadow_codex/attack(mob/M as mob, mob/user as mob)
	if(istype(M, /mob/living/carbon/human) && M != caster && is_converting == 0 && M.stat != DEAD) // you can only used this on a human and it can't be you, also you can't cast this multiple times at once
		is_converting = 1
		to_chat(user, "<span class=warning>You start focusing on [M]s brain, while reciting the words written in the book.</span>")
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

// This will be used to spawn the minion, The book won't listen to you when you are a shadow person, instead that will return you to your original body
/obj/item/shadow_codex/proc/spawn_minion(mob/living/carbon/human/H)
	H.visible_message("<span class='userdanger'>As the shadows form into a humanoid figure. You suddenly find yourself in the mind of another being.</span>")
	var/mob/living/carbon/human/shadowperson_holder = new(H.loc)
	var/mob/dead/observer/ghost = H.ghostize(0)
	shadowperson_holder.set_species(/datum/species/shadow)
	shadowperson_holder.key = ghost.key // this is where the transfer happens
	H.Unconscious(75)
	shadowperson_holder.Unconscious(75) // both of them unconscious
	qdel(ghost)
	shadowperson = shadowperson_holder // assign the local variable to the object variable


// This is called when you pickup the book as a shadowperson, this is also called when the shadowperson dies (except with some disbenefits)
/obj/item/shadow_codex/proc/shadow_pickup(mob/living/carbon/human/C)
	var/mob/dead/observer/ghost = C.ghostize(0)
	caster.key = ghost.key
	C.Unconscious(75)
	caster.Unconscious(75)
	qdel(ghost)
	shadowperson.gib()
	shadowperson = null


// This is called after the shadowperson dies.
/obj/item/shadow_codex/after_death()
			to_chat(shadowperson, "<span class='userdanger'>You have died. You feel your mind shifting back to its original host.</span>")
			var/mob/dead/observer/ghost = shadowperson.ghostize(0)
			caster.key = ghost.key
			caster.Unconscious(50)
			caster.adjustBrainLoss(100)
			shadowperson = null



/*
TODO:
Make it, so you can return to your old body, when you click on the shadow codex when you are a shadow person
Make it so others can't pick the item up if they are not the caster ( ehh )
Make it so if you die, as a shadowperson, your body suffers some additional damage
*/