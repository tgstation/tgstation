/obj/item/device/meeseeks_box
	name = "Meeseeks Box"
	desc = "A blue box with a button on top. You hear a faint voice from inside desperate to help you."
	icon = 'icons/obj/objects.dmi'
	icon_state = "meeseeks_box"
	origin_tech = "programming=2;materials=3;bluespace=4"
	var/meeseeks = null  //The Meeseeks spawned from this box
	var/datum/species/golem/meeseeks/SM //the species of the meeseeks
	var/request = "Nothing"     //The Law passed on to the Meeseeks
	var/summon_time = 0 //to control the cooldown of summoning one.
	var/summoned = 0 //to control the jaunting

/obj/item/device/meeseeks_box/New()    //Doesn't do anything for now
	return



/obj/item/device/meeseeks_box/attack_self(mob/user)
	if(summoned && !meeseeks)	//happens if the meeseeks is destroyed without being desummoned
		var/list/turfs = list(	)
		for(var/turf/T in orange(80))
			if(T.x>world.maxx-8 || T.x<8)	continue	//putting them at the edge is dumb
			if(T.y>world.maxy-8 || T.y<8)	continue
			turfs += T
		visible_message("<span class='danger'> The Meeseeks box colapses on itself and warps space around it!")
		user.loc = get_turf(pick(turfs)) //randomly teleports the holder of the box
		qdel(src)

	if(!meeseeks)
		if(summon_time < world.time)
			usr << "<span class='notice'>You press the button on the box and it starts shaking gently.</span>"
			summon_time = world.time + 150
			var/list/candidates = getCandidates("Do you wish to be a Mr. Meeseeks and fulfill a task?", "pAI", null)
			shuffle(candidates)
			if(candidates.len)
				var/mob/dead/observer/C = pick(candidates)
				var/mob/living/carbon/human/M = new /mob/living/carbon/human
				var/randnum = rand(1, 1000)
				hardset_dna(M, null, null, "Mr. Meeseeks ([randnum])", null, /datum/species/golem/meeseeks)
				name = "Mr. Meeseeks ([randnum])'s Box" //so that players can tell which box is which
				M.set_cloned_appearance()
				M.job = "Mr. Meeseeks"
				M.dna.species.auto_equip(M)
				M.loc = user.loc
				M.key = C.key
				meeseeks = M //store the meeseeks, so we can delete it later
				SM = M.dna.species
				SM.master = user
				summoned = 1
				if(M.mind)
					M.mind.assigned_role = "Mr. Meeseeks" //Should prevent getting picked for antag as a meeseeks
				playsound(loc, 'sound/voice/meeseeks/meeseeksspawn.ogg', 40, 0, 1)
				request = stripped_input(user, "How should Mr. Meeseeks help you today?")
				playsound(loc, 'sound/voice/meeseeks/cando.ogg', 40, 0, 1)
				message_admins("[key_name_admin(user)] has summoned a Mr. Meeseeks([key_name_admin(M)]) with the request: [request]")
				log_game("[key_name(user)] has summoned a Mr. Meeseeks([key_name(M)]) with the request: [request]")
				M << "<span class='notice'>Your master, [user] has given you a command:"
				M << "<span class='notice'><b> [request].</b>"
				M << "<span class='notice'>Try to accomplish it as fast as possible!</span>"
				M.mind.store_memory("Your master, [user], has given you this command:")
				M.mind.store_memory("[request]")
			else
				usr << "<span class='notice'>The box is silent and the button rises. Maybe you should try again in a few minutes.</span>"
		else
			usr << "<span class='notice'>The box button hasn't raised again yet.</span>"


	else
		usr << "<span class='notice'>A Mr. Meeseeks has already left this box!</span>"
		switch(alert(user, "Do you wish to send Mr.Meeseeks away?","Mr. Meeseeks dismissal.","Yes","No"))
			if("Yes")
				var/meeseeks_in_view = 0
				for (var/mob/A in view(7, user))
					if (A == meeseeks)
						meeseeks_in_view = 1 //we can see the meeseeks
						break
				if(!meeseeks_in_view)
					usr << "<span class='danger'>Mr. Meeseeks is not in your view! You can't recall him!</span>"
					return

				if(SM.stage<3)
					//Dismissal not being logged right now because that's not in the spec
					SM.master = null
					meeseeks = null
					request = "Nothing"
					summoned = 0
					usr << "<span class='notice'>The box makes a weird pop sound and Mr. Meeseeks is gone.</span>"
					if(prob(15)) //15% of the box malfunctioning and getting corrupted
						var/obj/item/device/meeseeks_box/malf/M = new /obj/item/device/meeseeks_box/malf(user.loc)
						usr.unEquip(src)
						usr.put_in_hands(M)
						usr << "<span class='notice'>The box warps and loses it's colour. Something has gone terribly wrong!</span>"
						qdel(src)
				else
					usr << "<span class='danger'>Mr. Meeseeks is too desperate! He can't go away!</span>"
			if("No")
				return
			else
				return

/obj/item/device/meeseeks_box/malf
	name = "Strange Meeseeks Box"
	desc = "You feel a sense of dread. Maybe you should dispose of this box quickly."
	icon = 'icons/obj/objects.dmi'
	icon_state = "lingseeks_box"
	origin_tech = "programming=2;materials=3;bluespace=6"

/obj/item/device/meeseeks_box/malf/attack_self(mob/user)
	if(!meeseeks)
		if(summon_time < world.time)
			usr << "<span class='notice'>You press the button on the box and it starts shaking angrily.</span>"
			usr << "<span class='alert'>This is a bad idea.</span>"
			summon_time = world.time + 150
			var/list/candidates = getCandidates("Do you wish to be a Mr. MEe&%$seeks/(& an$d fUlFil%&l a Ta!#Sk?", "pAI", null)
			shuffle(candidates)
			if(candidates.len)
				var/mob/dead/observer/C = pick(candidates)
				var/mob/living/carbon/human/M = new /mob/living/carbon/human
				hardset_dna(M, null, null, "Abomination", null, /datum/species/golem/meeseeks)
				M.set_cloned_appearance()
				M.job = "Lingseek"
				M.dna.species.auto_equip(M)
				M.loc = user.loc
				M.key = C.key
				if(M.mind)
					M.mind.assigned_role = "Mr. Meeseeks" //Should prevent getting picked for antag as a meeseeks
				//playsound(loc, 'sound/voice/meeseeks/ling/lingseeksspawn.ogg', 40, 0, 1) //this sound is played on death, wouldn't make much sense playing two sounds.
				//request = stripped_input(user, "How should Mr. Meeseeks help you today?")
				playsound(loc, 'sound/voice/meeseeks/ling/lingseekscando.ogg', 40, 0, 1)
				message_admins("[key_name_admin(user)] has summoned a Lingseeks([key_name_admin(M)]) with the request: [request]")
				log_game("[key_name(user)] has summoned a Mr. Meeseeks([key_name(M)]) with the request: [request]")
				M << "<span class='notice'>You are in terrible danger! You must escape!</span>"
				M << "<span class='danger'>THERE IS NO ESCAPE</span>"
				M.mind.store_memory("RUN FROM EVERYTHING")
				M.mind.store_memory("HIDE FROM EVERYTHING")
				M.mind.store_memory("FEAR EVERYTHING")
				usr << "<span class='danger'>This is was a bad idea!</span>"
				qdel(src)
			else
				usr << "<span class='notice'>The box is silent and the button rises. Maybe you should try again in a few minutes.</span>"
		else
			usr << "<span class='notice'>The box button hasn't raised again yet.</span>"