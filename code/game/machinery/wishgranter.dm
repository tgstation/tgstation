<<<<<<< HEAD
/obj/machinery/wish_granter
	name = "wish granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = 0
	anchored = 1
	density = 1

	var/charges = 1
	var/insisting = 0

/obj/machinery/wish_granter/attack_hand(mob/living/carbon/user)
	if(charges <= 0)
		user << "The Wish Granter lies silent."
		return

	else if(!ishuman(user))
		user << "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's."
		return

	else if(is_special_character(user))
		user << "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away."

	else if (!insisting)
		user << "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?"
		insisting++

	else
		user << "You speak.  [pick("I want the station to disappear","Humanity is corrupt, mankind must be destroyed","I want to be rich", "I want to rule the world","I want immortality.")].  The Wish Granter answers."
		user << "Your head pounds for a moment, before your vision clears.  You are the avatar of the Wish Granter, and your power is LIMITLESS!  And it's all yours.  You need to make sure no one can take it from you.  No one can know, first."

		charges--
		insisting = 0

		user.dna.add_mutation(HULK)
		user.dna.add_mutation(XRAY)
		user.dna.add_mutation(COLDRES)
		user.dna.add_mutation(TK)

		ticker.mode.traitors += user.mind
		user.mind.special_role = "Avatar of the Wish Granter"

		var/datum/objective/hijack/hijack = new
		hijack.owner = user.mind
		user.mind.objectives += hijack

		user.mind.announce_objectives()
		
		user << "You have a very bad feeling about this."

	return
=======
/obj/machinery/wish_granter
	name = "\improper Wish Granter"
	desc = "You're not so sure about this anymore."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	use_power = 0
	anchored = 1
	density = 1

	var/charges = 1
	var/insisting = 0
	var/wish_whispers = list("I want the station to disappear.", "Humanity is corrupt, mankind must be destroyed.", "I want to be rich.", "I want to rule the world.", "I want to uncover the truth.", "I want immortality.", "I want to become a god.", "I want my valids.")

/obj/machinery/wish_granter/attack_hand(var/mob/user as mob)
	usr.set_machine(src)

	if(charges <= 0)
		to_chat(user, "<span class='notice'>\the [src] lies silent.</span>")
		return

	else if(!istype(user, /mob/living/carbon/human))
		to_chat(user, "<span class='sinister'>You feel a dark stirring inside of \the [src], something you want nothing of! Your instincts are better than any man's.</span>")
		return

	else if(is_special_character(user))
		to_chat(user, "<span class='sinister'>Even to a heart as dark as yours, you know nothing good will come out of messing with \the [src]! Something instinctual pulls you away.</span>")

	else if (!insisting)
		user.visible_message("<span class='sinister'>[user] touches [src] delicately, causing it to stir.</span>", "<span class='sinister'>Your first touch makes [src] stir, listening to you. Are you still sure about this ?</span>")
		insisting++

	else
		user.whisper(pick(wish_whispers), heard="kneels before \the [src] and mumbles sinisterly,", unheard="kneels before \the [src] and mumbles something sinisterly.", allow_lastwords = 0)
		spawn(10) //OH SHI-
			message_admins("[user] has interacted with \the [src] (Wish Granter) and is now its powerful avatar!")
			user.visible_message("<span class='sinister'>[user] clenches in pain before \the [src] and then raises back up with a demonic and soulless expression!</span>", "<span class='sinister'>\the [src] answers and your head pounds for a moment before your vision clears. You are the avatar of [src], and your power is LIMITLESS! And it's all yours. You need to make sure no one can take it from you! No one must know, first!</span>", "<span class='sinister'>You hear a demonic hum, this can't be good!</span>")
			charges--
			insisting = 0

			if (!(M_HULK in user.mutations))
				user.dna.SetSEState(HULKBLOCK,1)

			if (!(M_LASER in user.mutations))
				user.mutations.Add(M_LASER)

			if (!(M_XRAY in user.mutations))
				user.mutations.Add(M_XRAY)
				user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
				user.see_in_dark = 8
				user.see_invisible = SEE_INVISIBLE_LEVEL_TWO

			if (!(M_RESIST_COLD in user.mutations))
				user.mutations.Add(M_RESIST_COLD)

			if (!(M_RESIST_HEAT in user.mutations))
				user.mutations.Add(M_RESIST_HEAT)

			if (!(M_TK in user.mutations))
				user.mutations.Add(M_TK)

			/* Not used
			if(!(HEAL in user.mutations))
				user.mutations.Add(HEAL)
			*/

			user.update_mutations()

			ticker.mode.traitors += user.mind
			user.mind.special_role = "Avatar of \the [src]" //Custom naming ahoy !

			var/datum/objective/silence/silence = new
			silence.owner = user.mind
			user.mind.objectives += silence

			var/obj_count = 1
			for(var/datum/objective/OBJ in user.mind.objectives)
				to_chat(user, "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]")
				obj_count++

			to_chat(user, "<span class='sinister'>You have a very bad feeling about this!</span>")

	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
