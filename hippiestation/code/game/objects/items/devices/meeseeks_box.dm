#define MEESEEKS_TICKS_STAGE_ONE	1
#define MEESEEKS_TICKS_STAGE_TWO	200
#define MEESEEKS_TICKS_STAGE_THREE	300
#define MEESEEKS_BOX_COOLDOWN		1800
#define MEESEEKS_BOX_FAILURE_TIME	1600

/obj/item/device/meeseeks_box
	name = "\improper Mr. Meeseeks Box"
	desc = "A blue box with a button on top. Press the button to call upon a Mr. Meeseeks."
	icon = 'hippiestation/icons/obj/device.dmi'
	icon_state = "meeseeks_box"
	origin_tech = "programming=2;materials=3;bluespace=4"
	var/request = "Nothing"
	var/next_summon
	var/summoned = FALSE
	var/summoning = FALSE
	var/mob/living/carbon/masters
	var/mob/living/carbon/human/meeseeks
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF

/obj/item/device/meeseeks_box/attack_self(mob/user)
	if(!iscarbon(user))
		return
	if(meeseeks)
		var/datum/species/meeseeks/SMS = meeseeks.dna.species
		to_chat(user, "<span class='warning'>A Mr. Meeseeks has already left this box!</span>")
		switch(alert(user, "Do you wish to send Mr.Meeseeks away?","Mr. Meeseeks dismissal.","Yes","No"))
			if("Yes")
				if(meeseeks in range(src, 7))
					if(SMS.stage_ticks < MEESEEKS_TICKS_STAGE_THREE)
						destroy_meeseeks(meeseeks, meeseeks.dna.species)
						masters = null
						meeseeks = null
						summoned = FALSE
					else
						to_chat(user, "<span class='danger'>You have lost control of Mr. Meeseeks!</span>")
				else
					to_chat(user, "<span class='warning'>Mr. Meeseeks is not close enough to be dismissed!</span>")
		return
	else if(summoned) //Meeseeks was destroyed
		to_chat(user, "<span class='warning'>[src] explodes!</span>")
		explosion(get_turf(src), null, null, 1, 2)
		qdel(src)
	else if(summoning)
		to_chat(user, "<span class='warning'>[src] is trying to summon a Mr. Meeseeks. Be patient, Meeseeks don't grow on trees.</span>")
	else if(next_summon < world.time)
		next_summon = world.time + MEESEEKS_BOX_COOLDOWN
		summoning = TRUE
		user.visible_message("<span class='notice'>[user] presses the button on [src]!</span>")
		var/list/candidates = pollGhostCandidates("Would you like to become a Mr. Meeseeks and fulfill a task?", poll_time=100)
		if(candidates.len)
			var/mob/dead/observer/Z = pick(candidates)
			masters = user
			meeseeks = new
			meeseeks.alpha = 0
			meeseeks.forceMove(get_turf(user))
			meeseeks.hardset_dna(null, null, "Mr. Meeseeks", null, /datum/species/meeseeks)
			var/datum/species/meeseeks/SM = meeseeks.dna.species
			SM.master = user
			meeseeks.set_cloned_appearance()
			meeseeks.job = "Mr. Meeseeks"
			new /obj/effect/cloud(get_turf(user))
			meeseeks.key = Z.key
			to_chat(meeseeks, "<span class='boldannounce'>You are a Mr. Meeseeks!</span>")
			var/request = stripped_input(user, "How should Mr. Meeseeks help you today?")
			if(!request)
				to_chat(user, "<span class='warning'>Mr. Meeseeks didn't get a request!</span>")
				destroy_meeseeks(meeseeks, SM)
				return
			playsound(loc, 'hippiestation/sound/voice/cando.ogg', 40)
			message_admins("[key_name_admin(user)] has summoned a Mr. Meeseeks([key_name_admin(meeseeks)]) with the request: [request]")
			log_game("[key_name(user)] has summoned a Mr. Meeseeks([key_name(meeseeks)]) with the request: [request]")
			if(meeseeks.mind)
				meeseeks.mind.assigned_role = "Mr. Meeseeks" //Should prevent getting picked for antag as a meeseeks
				var/datum/objective/objective = new
				objective.explanation_text = "Your master [masters] has asked that you complete the following task: [request]."
				objective.completed = FALSE
				meeseeks.mind.objectives += objective
				meeseeks.mind.announce_objectives()
				SM.objective = objective
			summoning = FALSE
			summoned = TRUE
		else
			next_summon -= MEESEEKS_BOX_FAILURE_TIME
			to_chat(user, "<span class='warning'>[src] failed to create a Mr. Meeseeks. Try again later!</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
			summoning = FALSE
	else
		to_chat(user, "<span class='warning'>[src] is silent. Try again in a few minutes.</span>")

/obj/item/device/meeseeks_box/Destroy()
	destroy_meeseeks(meeseeks, meeseeks.dna.species)
	..()
