/mob/proc/make_lesser_changeling()
	if(!changeling) changeling = new
	changeling.host = src

	src.verbs += /datum/changeling/proc/EvolutionMenu

	for(var/obj/effect/proc_holder/power/P in changeling.purchasedpowers)
		if(P.isVerb)
			if(P.allowduringlesserform)
				if(!(P in src.verbs))
					src.verbs += P.verbpath

/*	src.verbs += /client/proc/changeling_fakedeath
	src.verbs += /client/proc/changeling_lesser_transform
	src.verbs += /client/proc/changeling_blind_sting
	src.verbs += /client/proc/changeling_deaf_sting
	src.verbs += /client/proc/changeling_silence_sting
	src.verbs += /client/proc/changeling_unfat_sting
*/
	changeling.changeling_level = 1
	return

/mob/proc/make_changeling()
	if(!changeling) changeling = new
	changeling.host = src

	src.verbs += /datum/changeling/proc/EvolutionMenu

	for(var/obj/effect/proc_holder/power/P in changeling.purchasedpowers)
		if(P.isVerb)
			if(!(P in src.verbs))
				src.verbs += P.verbpath

/*
	src.verbs += /client/proc/changeling_absorb_dna
	src.verbs += /client/proc/changeling_transform
	src.verbs += /client/proc/changeling_lesser_form
	src.verbs += /client/proc/changeling_fakedeath

	src.verbs += /client/proc/changeling_deaf_sting
	src.verbs += /client/proc/changeling_blind_sting
	src.verbs += /client/proc/changeling_paralysis_sting
	src.verbs += /client/proc/changeling_silence_sting
	src.verbs += /client/proc/changeling_transformation_sting
	src.verbs += /client/proc/changeling_unfat_sting
	src.verbs += /client/proc/changeling_boost_range

*/
	changeling.changeling_level = 2
	if (!changeling.absorbed_dna)
		changeling.absorbed_dna = list()
	if (changeling.absorbed_dna.len == 0)
		changeling.absorbed_dna[src.real_name] = src.dna
	return

/mob/proc/make_greater_changeling()
	src.make_changeling()
	//This is a test function for the new changeling powers.  Grants all of them.
	return

/mob/proc/remove_changeling_powers()

	for(var/obj/effect/proc_holder/power/P in changeling.purchasedpowers)
		if(P.isVerb)
			src.verbs -= P.verbpath
/*
	src.verbs -= /client/proc/changeling_absorb_dna
	src.verbs -= /client/proc/changeling_transform
	src.verbs -= /client/proc/changeling_lesser_form
	src.verbs -= /client/proc/changeling_lesser_transform
	src.verbs -= /client/proc/changeling_fakedeath
	src.verbs -= /client/proc/changeling_deaf_sting
	src.verbs -= /client/proc/changeling_blind_sting
	src.verbs -= /client/proc/changeling_paralysis_sting
	src.verbs -= /client/proc/changeling_silence_sting
	src.verbs -= /client/proc/changeling_boost_range
	src.verbs -= /client/proc/changeling_transformation_sting
	src.verbs -= /client/proc/changeling_unfat_sting
*/
/client/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (!istype(usr.get_active_hand(), /obj/item/weapon/grab))
		usr << "\red We must be grabbing a creature in our active hand to absorb them."
		return

	var/obj/item/weapon/grab/G = usr.get_active_hand()
	var/mob/M = G.affecting

	if (!ishuman(M))
		usr << "\red This creature is not compatible with our biology."
		return

	if (NOCLONE in M.mutations)
		usr << "\red This creature's DNA is ruined beyond useability!"
		return

	if (!G.killing)
		usr << "\red We must have a tighter grip to absorb this creature."
		return

	if (usr.changeling.isabsorbing)
		usr << "\red We are already absorbing!"
		return



	var/mob/living/carbon/human/T = M

	usr << "\blue This creature is compatible. We must hold still..."
	usr.changeling.isabsorbing = 1
	feedback_add_details("changeling_powers","A1")
	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		usr.changeling.isabsorbing = 0
		return

	usr << "\blue We extend a proboscis."
	usr.visible_message(text("\red <B>[usr] extends a proboscis!</B>"))
	feedback_add_details("changeling_powers","A2")

	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		usr.changeling.isabsorbing = 0
		return

	usr << "\blue We stab [T] with the proboscis."
	usr.visible_message(text("\red <B>[usr] stabs [T] with the proboscis!</B>"))
	T << "\red <B>You feel a sharp stabbing pain!</B>"
	T.take_overall_damage(40)
	feedback_add_details("changeling_powers","A3")

	if (!do_mob(usr, T, 150))
		usr << "\red Our absorption of [T] has been interrupted!"
		usr.changeling.isabsorbing = 0
		return

	usr << "\blue We have absorbed [T]!"
	usr.visible_message(text("\red <B>[usr] sucks the fluids from [T]!</B>"))
	T << "\red <B>You have been absorbed by the changeling!</B>"
	feedback_add_details("changeling_powers","A4")

	usr.changeling.absorbed_dna[T.real_name] = T.dna
	if(usr.nutrition < 400) usr.nutrition = min((usr.nutrition + T.nutrition), 400)
	usr.changeling.chem_charges += 10
	usr.changeling.geneticpoints += 2
	if(T.changeling)
		if(T.changeling.absorbed_dna)
			usr.changeling.absorbed_dna |= T.changeling.absorbed_dna //steal all their loot
			usr.changeling.absorbedcount += T.changeling.absorbedcount

			T.changeling.absorbed_dna = list()
			T.changeling.absorbed_dna[T.real_name] = T.dna

		if(T.changeling.purchasedpowers)
			for(var/obj/effect/proc_holder/power/Tp in T.changeling.purchasedpowers)
				if(Tp in usr.changeling.purchasedpowers)
					continue
				else
					usr.changeling.purchasedpowers += Tp

					if(!Tp.isVerb)
						call(Tp.verbpath)()

					else
						if(usr.changeling.changeling_level == 1)
							usr.make_lesser_changeling()
						else
							usr.make_changeling()





		usr.changeling.chem_charges += T.changeling.chem_charges
		usr.changeling.geneticpoints += T.changeling.geneticpoints
		T.changeling.chem_charges = 0
	usr.changeling.absorbedcount++
	usr.changeling.isabsorbing = 0

	T.death(0)
	T.Drain()

	return

/client/proc/changeling_transform()
	set category = "Changeling"
	set name = "Transform (5)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (usr.changeling.absorbed_dna.len <= 0)
		usr << "\red We have not yet absorbed any compatible DNA."
		return

	if(usr.changeling.chem_charges < 5)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in usr.changeling.absorbed_dna

	if (S == null)
		return

	usr.changeling.chem_charges -= 5

	usr.visible_message(text("\red <B>[usr] transforms!</B>"))

	usr.dna = usr.changeling.absorbed_dna[S]
	usr.real_name = S
	updateappearance(usr, usr.dna.uni_identity)
	domutcheck(usr, null)
	feedback_add_details("changeling_powers","TR")

	usr.verbs -= /client/proc/changeling_transform

	spawn(10)
		usr.verbs += /client/proc/changeling_transform

	return

/client/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form (1)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if(usr.changeling.chem_charges < 1)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	if(usr.changeling.geneticdamage != 0)
		usr << "Our genes are still mending themselves!  We cannot transform!"
		return

	if(!iscarbon(usr))
		return //Changelings should only really be carbon as only monkeys/humans have DNA

	var/mob/living/carbon/C = usr

	C.changeling.chem_charges--

	C.remove_changeling_powers()

	C.visible_message(text("\red <B>[C] transforms!</B>"))

	C.changeling.geneticdamage = 30
	C << "Our genes cry out!"

	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/implant/W in C)
		implants += W

	C.regenerate_icons()
	C.monkeyizing = 1
	C.canmove = 0
	C.icon = null
	C.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( C.loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	del(animation)

	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(src)
	O.dna = C.dna
	C.dna = null
	O.changeling = C.changeling
	feedback_add_details("changeling_powers","LF")

	for(var/obj/item/W in C)
		C.drop_from_inventory(W)


	for(var/obj/T in C)
		del(T)
	//for(var/R in usr.organs) //redundant, let's give garbage collector work to do --rastaf0
	//	del(usr.organs[text("[]", R)])

	O.loc = C.loc

	O.name = text("monkey ([])",copytext(md5(C.real_name), 2, 6))
	O.setToxLoss(C.getToxLoss())
	O.adjustBruteLoss(C.getBruteLoss())
	O.setOxyLoss(C.getOxyLoss())
	O.adjustFireLoss(C.getFireLoss())
	O.stat = C.stat
	O.a_intent = "hurt"
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O
		continue

	if(C.mind)
		C.mind.transfer_to(O)

	O.make_lesser_changeling()
	O.verbs += /client/proc/changeling_lesser_transform
	del(usr)
	return

/client/proc/changeling_lesser_transform()
	set category = "Changeling"
	set name = "Transform (1)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if (usr.changeling.absorbed_dna.len <= 0)
		usr << "\red We have not yet absorbed any compatible DNA."
		return

	if(usr.changeling.chem_charges < 1)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	if(!iscarbon(usr))
		return //Only humans/monkeys have DNA

	var/S = input("Select the target DNA: ", "Target DNA", null) in usr.changeling.absorbed_dna

	if (S == null)
		return

	var/mob/living/carbon/C = usr

	C.changeling.chem_charges -= 1

	C.remove_changeling_powers()

	C.visible_message(text("\red <B>[C] transforms!</B>"))

	C.dna = C.changeling.absorbed_dna[S]

	var/list/implants = list()
	for (var/obj/item/weapon/implant/I in C) //Still preserving implants
		implants += I

	C.regenerate_icons()
	C.monkeyizing = 1
	C.canmove = 0
	C.icon = null
	C.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( C.loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)
	del(animation)

	for(var/obj/item/W in usr)
		C.u_equip(W)
		if (C.client)
			C.client.screen -= W
		if (W)
			W.loc = C.loc
			W.dropped(C)
			W.layer = initial(W.layer)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
	if (isblockon(getblock(C.dna.uni_identity, 11,3),11))
		O.gender = FEMALE
	else
		O.gender = MALE
	O.dna = C.dna
	C.dna = null
	O.changeling = C.changeling
	O.real_name = S
	feedback_add_details("changeling_powers","LFT")

	for(var/obj/T in C)
		del(T)

	O.loc = C.loc

	updateappearance(O,O.dna.uni_identity)
	domutcheck(O, null)
	O.setToxLoss(C.getToxLoss())
	O.adjustBruteLoss(C.getBruteLoss())
	O.setOxyLoss(C.getOxyLoss())
	O.adjustFireLoss(C.getFireLoss())
	O.stat = C.stat
	for (var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O
		continue

	if(C.mind)
		C.mind.transfer_to(O)

	O.make_changeling()

	del(usr)
	return


/client/proc/changeling_greater_form() // Oh shit, it's on now.

	set category = "Changeling"
	set name = "Greater Form"
	set desc = "Become onto the Goddess"

	if (usr.monkeyizing)
		return
	for(var/obj/item/W in src)
		usr.drop_from_inventory(W)
	usr.regenerate_icons()
	usr.monkeyizing = 1
	usr.canmove = 0
	usr.icon = null
	usr.invisibility = 101
	for(var/datum/organ/external/organ in usr:organs)
		del(organ)

	var/atom/movable/overlay/animation = new /atom/movable/overlay( usr.loc )
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(48)
	//animation = null
	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )//Removed Emissary shit -Sieve{R}
	del(animation)

	feedback_add_details("changeling_powers","GF")
	O.real_name = usr.real_name
	O.name = usr.name
	O.dna = usr.dna
	usr.dna = null
	O.changeling = usr.changeling
	updateappearance(O,O.dna.uni_identity)
	O.loc = usr.loc
	O.viruses = usr.viruses
	usr.viruses = list()
	for(var/datum/disease/D in O.viruses)
		D.affected_mob = O
	O.universal_speak = 1 //hacky fix until someone can figure out how to make them only understand humans

	if (usr.client)
		usr.client.mob = O
	if(usr.mind)
		usr.mind.transfer_to(O)

	spawn(300)
		command_alert("Extreme danger.  A level four biological entity has been detected on board the station.  Emergency evacuation procedures have begun.  Civilian staff, do NOT engage the creature if spotted.  Renforcements are on route.")
		emergency_shuttle.online = 1
		emergency_shuttle.settimeleft(10)
		spawn(10)
			var/list/candidates = list()

			for(var/mob/dead/observer/G in world)
				candidates += G

			for(var/mob/dead/observer/G in candidates)
				if(!G.client || !G.key)
					candidates.Remove(G)

			for(var/obj/structure/stool/bed/chair/C in locate(/area/shuttle/escape/transit))

				var/mob/living/carbon/human/new_commando = create_death_commando(C, 0)

				if(candidates.len)
					var/mob/dead/observer/G = pick(candidates)
					new_commando.mind.key = G.key//For mind stuff.
					new_commando.key = G.key
					new_commando.internal = new_commando.s_store
					new_commando.internals.icon_state = "internal1"
					candidates -= G
					del(G)
				else
					break

				//So they don't forget their code or mission.
				new_commando.mind.store_memory("<B>Mission:</B> \red Assist in mobilizing station crew against the hostile entity.  Do not allow the hostile entity to escape.  Do not leave or permit anyone to leave until the entity is contained.")

				new_commando << "\blue You are a Special Ops Commando in the service of Central Command. \nYour current mission is: \red<B>Assist in mobilizing station crew against the hostile entity.  Do not allow the hostile entity to escape.  Do not leave or permit anyone to leave until the entity is contained.</B>"
		spawn(100)
			emergency_shuttle.online = 0
			command_alert("The emergency shuttle will hold until the hostile entity has been terminated.  During evacuation, do NOT use escape pods.  To avoid the chance of a hostile entity escaping, the Thunderchild will be firing on and destorying any escape pods leaving the station")
			O << "Your way out has arrived.  Obtain the ID of three heads to override the holding protocol and escape.  Let none stand in your way, for you are a perfect creature."
			for(var/datum/objective/objective in O.mind.objectives)
				O.mind.objectives.Remove(objective)
				del(objective)
			var/datum/objective/new_objective = null
			new_objective = new /datum/objective/escape
			new_objective.owner = O.mind
			O.mind.objectives += new_objective

/*			spawn(0)
				while(emergency_shuttle.online == 0)
					sleep(10)
				command_alert("Authorization codes recieved, confirming hostile entity terminated.  The emergency shuttle is now departing.")
				spawn(900)
					for(var/mob/M in locate(/area/shuttle/escape_pod1/transit))
						M.gib()
					for(var/mob/M in locate(/area/shuttle/escape_pod2/transit))
						M.gib()
					for(var/mob/M in locate(/area/shuttle/escape_pod3/transit))
						M.gib()
					for(var/mob/M in locate(/area/shuttle/escape_pod5/transit))
						M.gib()
				while(emergency_shuttle.online == 1)
					sleep(10)
					if((locate(/mob/living/carbon/human/tajaran/Emissary) in locate(/area/shuttle/escape/centcom))   ||  (locate(/mob/living/carbon/human/tajaran/Emissary) in locate(/area/centcom/evac)) || (locate(/mob/living/carbon/human/tajaran/Emissary) in locate(/area/centcom/control)  )     )
						command_alert("What the fu- Shoot it!  SHOOT IT!  CENTRAL COMMAND TRANSMITTING DIST- *static*  Nevermind previous transmission, Nanotrasen.  We're all good here.  Subject contained. Standing down alert status.")
Tarjan shit, not recoding this -Sieve{R}*/

/client/proc/changeling_fakedeath()
	set category = "Changeling"
	set name = "Regenerative Stasis (20)"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 20)
		usr << "\red We don't have enough stored chemicals to do that!"
		return
	if(!isliving(usr)) return //This should NEVER happen

	var/mob/living/L = usr

	L.changeling.chem_charges -= 20

	L << "\blue We will regenerate our form."
	feedback_add_details("changeling_powers","FD")

	L.lying = 1
	L.canmove = 0
	L.changeling.changeling_fakedeath = 1
	L.remove_changeling_powers()

	L.emote("gasp")
	if(isnull(L.tod)) // If we weren't already dead
		L.tod = worldtime2text()

	spawn(1200)
		L.stat = 0
		//usr.fireloss = 0
		L.tod = null
		L.setToxLoss(0)
		//usr.bruteloss = 0
		L.setOxyLoss(0)
		L.setCloneLoss(0)
		L.SetParalysis(0)
		L.SetStunned(0)
		L.SetWeakened(0)
		L.radiation = 0
		//L.health = 100
		//L.updatehealth()
		var/mob/living/M = src
		M.heal_overall_damage(M.getBruteLoss(), M.getFireLoss())
		L.reagents.clear_reagents()
		L.lying = 0
		L.canmove = 1
		L << "\blue We have regenerated."
		L.visible_message(text("\red <B>[usr] appears to wake from the dead, having healed all wounds.</B>"))

		L.changeling.changeling_fakedeath = 0
		if (L.changeling.changeling_level == 1)
			L.make_lesser_changeling()
		else if (L.changeling.changeling_level == 2)
			L.make_changeling()

	return

/client/proc/changeling_boost_range()
	set category = "Changeling"
	set name = "Ranged Sting (10)"
	set desc="Your next sting ability can be used against targets 2 squares away."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.stat)
		usr << "\red Not when we are incapacitated."
		return

	if(usr.changeling.chem_charges < 10)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 10

	usr << "\blue Your throat adjusts to launch the sting."
	usr.changeling.sting_range = 2
	feedback_add_details("changeling_powers","RS")

	usr.verbs -= /client/proc/changeling_boost_range

	spawn(5)
		usr.verbs += /client/proc/changeling_boost_range

	return

/client/proc/changeling_silence_sting()
	set category = "Changeling"
	set name = "Silence sting (10)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/living/carbon/T = input(usr, "Who do you wish to sting?") as null | anything in victims
	if(T && T in view(usr.changeling.sting_range))

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 10)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 10
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."
		feedback_add_details("changeling_powers","SS")

		if(!T.changeling)
			T.silent += 30

		usr.verbs -= /client/proc/changeling_silence_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_silence_sting

		return

/client/proc/changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims
	if(T && T in view(usr.changeling.sting_range))
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 20)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 20
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."
		feedback_add_details("changeling_powers","BS")

		var/obj/effect/overlay/B = new /obj/effect/overlay( T.loc )
		B.icon_state = "blspell"
		B.icon = 'wizard.dmi'
		B.name = "spell"
		B.anchored = 1
		B.density = 0
		B.layer = 4
		T.canmove = 0
		spawn(5)
			del(B)
			T.canmove = 1

		if(!T.changeling)
			T << text("\blue Your eyes cry out in pain!")
			T.disabilities |= NEARSIGHTED
			spawn(300)
				T.disabilities &= ~NEARSIGHTED
			T.eye_blind = 10
			T.eye_blurry = 20

		usr.verbs -= /client/proc/changeling_blind_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_blind_sting

		return

/client/proc/changeling_deaf_sting()
	set category = "Changeling"
	set name = "Deaf sting (5)"
	set desc="Sting target:"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 5)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 5
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."
		feedback_add_details("changeling_powers","DS")

		if(!T.changeling)
			T.sdisabilities |= DEAF
			spawn(300)
				T.sdisabilities &= ~DEAF

		usr.verbs -= /client/proc/changeling_deaf_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_deaf_sting

		return

/client/proc/changeling_paralysis_sting()
	set category = "Changeling"
	set name = "Paralysis sting (30)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 30)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 30
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."
		feedback_add_details("changeling_powers","PS")

		if(!T.changeling)
			T << "You feel a small prick and your muscles stiffening."
			T.Weaken(10)
		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_paralysis_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_paralysis_sting

		return

/client/proc/changeling_transformation_sting()
	set category = "Changeling"
	set name = "Transformation sting (30)"
	set desc="Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 30)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		if(T.stat != 2 || (HUSK in T.mutations) || (!ishuman(T) && !ismonkey(T)))
			usr << "\red We can't transform that target!"
			return

		var/S = input("Select the target DNA: ", "Target DNA", null) in usr.changeling.absorbed_dna

		if (S == null)
			return

		usr.changeling.chem_charges -= 30
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."
		feedback_add_details("changeling_powers","TS")

		if(!T.changeling)
			T.visible_message(text("\red <B>[T] transforms!</B>"))

			T.dna = usr.changeling.absorbed_dna[S]
			T.real_name = S
			updateappearance(T, T.dna.uni_identity)
			domutcheck(T, null)

		usr.verbs -= /client/proc/changeling_transformation_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_transformation_sting

		return

/client/proc/changeling_unfat_sting()
	set category = "Changeling"
	set name = "Unfat sting (5)"
	set desc = "Sting target"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))
		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 5)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 5
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."
		feedback_add_details("changeling_powers","US")

		if(!T.changeling)
			T << "You feel a small prick and a burning sensation."
			T.overeatduration = 0
			T.nutrition -= 100
		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_unfat_sting

		spawn(5)
			usr.verbs += /client/proc/changeling_unfat_sting

	return

/client/proc/changeling_unstun()
	set category = "Changeling"
	set name = "Epinephrine Sacs (45)"
	set desc = "Removes all stuns"

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 45)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 45

	var/mob/living/carbon/human/C = usr

	if(C)
		C.stat = 0
		C.SetParalysis(0)
		C.SetStunned(0)
		C.SetWeakened(0)
		C.lying = 0
		C.canmove = 1

	feedback_add_details("changeling_powers","UNS")

	usr.verbs -= /client/proc/changeling_unstun

	spawn(5)
		usr.verbs += /client/proc/changeling_unstun



/client/proc/changeling_fastchemical()

	usr.changeling.chem_recharge_multiplier = usr.changeling.chem_recharge_multiplier*2

/client/proc/changeling_engorgedglands()

	usr.changeling.chem_storage = usr.changeling.chem_storage+25

/client/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camoflague (10)"
	set desc = "The AI can no longer track us, but we will look different if examined.  Has a constant cost while active."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 10)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 10

	var/mob/living/carbon/human/C = usr

	if(C)
		C << "[C.digitalcamo ? "We return to normal." : "We distort our form."]"
		C.digitalcamo = !C.digitalcamo
		spawn(0)
			while(C && C.digitalcamo)
				C.changeling.chem_charges -= 1/4
				sleep(10)

	feedback_add_details("changeling_powers","CAM")

	usr.verbs -= /client/proc/changeling_digitalcamo

	spawn(5)
		usr.verbs += /client/proc/changeling_digitalcamo


/client/proc/changeling_DEATHsting()
	set category = "Changeling"
	set name = "Death Sting (40)"
	set desc = "Causes spasms onto death."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/living/carbon/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 40)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 40
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."
		feedback_add_details("changeling_powers","DTHS")

		if(!T.changeling)
			T << "You feel a small prick and your chest becomes tight."

			T.silent = (10)
			T.Paralyse(10)
			T.make_jittery(1000)

			if (T.reagents)
				T.reagents.add_reagent("lexorin", 40)

		else
			T << "You feel a small prick."

		usr.verbs -= /client/proc/changeling_DEATHsting

		spawn(5)
			usr.verbs += /client/proc/changeling_DEATHsting

		return



/client/proc/changeling_rapidregen()
	set category = "Changeling"
	set name = "Rapid Regeneration (30)"
	set desc = "Begins rapidly regenerating.  Does not effect stuns or chemicals."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	if(usr.changeling.chem_charges < 30)
		usr << "\red We don't have enough stored chemicals to do that!"
		return

	usr.changeling.chem_charges -= 30

	var/mob/living/carbon/human/C = usr
	feedback_add_details("changeling_powers","RR")

	spawn(0)
		for(var/i = 0, i<10,i++)
			if(C)
				C.adjustBruteLoss(-10)
				C.adjustToxLoss(-10)
				C.adjustOxyLoss(-10)
				C.adjustFireLoss(-10)
				sleep(10)


	usr.verbs -= /client/proc/changeling_rapidregen

	spawn(5)
		usr.verbs += /client/proc/changeling_rapidregen




/client/proc/changeling_lsdsting()
	set category = "Changeling"
	set name = "Hallucination Sting (15)"
	set desc = "Causes terror in the target."

	if(!usr.changeling)
		usr << "\red You're not a changeling, something's wrong!"
		return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(usr.changeling.sting_range))
		victims += C
	var/mob/living/T = input(usr, "Who do you wish to sting?") as null | anything in victims

	if(T && T in view(usr.changeling.sting_range))

		if(usr.stat)
			usr << "\red Not when we are incapacitated."
			return

		if(usr.changeling.chem_charges < 15)
			usr << "\red We don't have enough stored chemicals to do that!"
			return

		usr.changeling.chem_charges -= 15
		usr.changeling.sting_range = 1

		usr << "\blue We stealthily sting [T]."
		feedback_add_details("changeling_powers","HS")

		if(!T.changeling)
		//	T << "You feel a small prick." // No warning.

			var/timer = rand(300,600)

			spawn(timer)
				if(T)
					if(T.reagents)
					//	T.reagents.add_reagent("LSD", 50) // Slight overkill, it seems.
						T.hallucination = 400


		usr.verbs -= /client/proc/changeling_lsdsting

		spawn(5)
			usr.verbs += /client/proc/changeling_lsdsting

		return