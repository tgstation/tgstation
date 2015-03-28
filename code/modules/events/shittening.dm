/datum/round_event_control/shittening
	name = "Shitty Suggestion Activation"
	typepath = /datum/round_event/shittening
	weight = 0
	earliest_start = INFINITY //a REAL failsafe against it happening ever without admin intervention
	max_occurrences = 1

/datum/round_event/shittening
	announceWhen = 0
	startWhen = 1

/datum/round_event/shittening/announce()
	priority_announce("Unknown, possibly hostile alien lifeforms resembling feces detected aboard [station_name()], please be wary of shitty behaviors.", "Shit Alert")

//IT BEGINS
/datum/round_event/shittening/start()
	ticker.mode.shitty = 1
	world << "<span class='danger'>The world suddenly feels very shitty.</span>"



	//Mob changes
	for(var/mob/M in living_mob_list)
		if(M.job == "Chaplain")
			M << "<span class='notice'><b><font size=3>The light of [ticker.Bible_deity_name ? ticker.Bible_deity_name : "the gods"] suffuses you, igniting an inner fire. You are now a paladin!</font></span>"
			M.verbs += /mob/living/carbon/human/proc/smite_evil
			M.say("PRAISE")
		if(M.job == "Botanist")
			M << "<span class='notice'>You feel far out, man...</span>"
			M.verbs += /mob/living/carbon/human/proc/summon_dank_blade
		M << "You feel as if you could go to the nearest computer and create a sci-fi game about space stations."
		if(M.reagents)
			M.reagents.add_reagent("programming", 10)
		M.verbs += /client/verb/mentorhelp



	//Object changes
	for(var/obj/item/weapon/reagent_containers/food/snacks/faggot/F in world)
		if(istype(F, /obj/item/weapon/reagent_containers/food/snacks/faggot/deadchat))
			continue
		F.visible_message("<span class='deadsay'><b><i>Strange energies suddenly swirl around \the [F], which begins to glow with an eldritch light.</i></b></span>")
		new /obj/item/weapon/reagent_containers/food/snacks/faggot/deadchat(F.loc)
		qdel(F)

	/*
	for(var/obj/machinery/turret/T in global_turret_list)
		T.say("Firmware update complete: Switching to High Explosive Rounds.")
		T.lasertype = 7
	Uncomment for ~~fun~~! - Iamgoofball
	for(var/obj/machinery/porta_turret/T in global_turret_list)
		T.say("Firmware update complete: Switching to High Explosive Rounds.")
		T.projectile = /obj/item/projectile/bullet/gyro
		T.eprojectile = /obj/item/projectile/bullet/gyro
	*/

	for(var/obj/item/weapon/storage/box/monkeycubes/B in global_monkeycubebox_list)
		B.visible_message("<span class = 'notice'>[B] appears to go through box division, and has divided into 2 separate boxes! What could be inside the new box?")
		new /obj/item/weapon/storage/box/clowncubes(B.loc)

	for(var/obj/item/weapon/reagent_containers/food/snacks/pie/P in global_pie_list)
		if(istype(P, /obj/item/weapon/reagent_containers/food/snacks/pie/syndicate))
			continue
		P.visible_message("<span class = 'notice'>[P] transforms into a syndicate pie!</span>")
		new /obj/item/weapon/reagent_containers/food/snacks/pie/syndicate(P.loc)
		qdel(P)
	for(var/obj/item/weapon/reagent_containers/food/snacks/customizable/pie/P in global_pie_list)
		P.visible_message("<span class = 'notice'>[P] transforms into a syndicate pie!</span>")
		new /obj/item/weapon/reagent_containers/food/snacks/pie/syndicate(P.loc)
		qdel(P)

	for(var/obj/item/weapon/reagent_containers/food/drinks/ale/B in world)
		B.name = "Ale Mao"
		B.desc = "The most memetic drink you've ever laid eyes on."

	for(var/obj/item/weapon/kitchen/utensil/fork/F in world)
		F.visible_message("<span class='warning'>\The [F] suddenly seems a bit sharper...</span>")
		F.force = 10

	for(var/obj/item/weapon/reagent_containers/food/condiment/enzyme/E in world)
		E.visible_message("<span class='danger'>\The [E] suddenly looks that much more memetic.</span>")
		E.name = "mountain dew"



//Smite Evil: A chaplain ability that can either heal a non-antag or damage an antag. Has a 2-minute cooldown.
/mob/living/carbon/human/proc/smite_evil(var/mob/living/carbon/heathen)
	set name = "Smite Evil"
	set category = "Thaumaturgy"

	/*if(!ticker.mode.shitty)
		usr << "<span class='warning'>You feel insufficiently powerful to use this ability.</span>"
		return*/

	if(usr.stat)
		return

	if(usr == heathen)
		return

	if(!in_range(usr, heathen))
		return

	usr << "<span class='notice'>You call upon [ticker.Bible_deity_name ? "the light of " + ticker.Bible_deity_name : "the light of the gods "] and envelop [heathen] in a cocoon!</span>"
	heathen.visible_message("<span class='danger'>[usr] makes a gesture, and [heathen] is wrapped in white light!</span>")

	if(heathen.mind in ticker.mode.traitors || heathen.mind in ticker.mode.cult)
		heathen << "<span class='userdanger'>A blinding white light envelops you, and you feel your skin burning!</span>"
		heathen.take_organ_damage(0,25)
		heathen.audible_message("<b>[heathen]</b> screams!")
	else
		heathen << "<span class='notice'>A blinding white light envelops you, and you feel your skin mending!</span>"
		heathen.heal_organ_damage(25,25)
	playsound(heathen.loc, 'sound/weapons/sear.ogg', 50, 1)

	sleep(20)
	heathen.visible_message("<span class='danger'>The white light around [heathen] dissipates as suddenly as it appeared.</span>")

	usr.verbs -= /mob/living/carbon/human/proc/smite_evil
	usr << "<span class='warning'>Your inner fire simmers down to embers. Perhaps in time it will recover?</span>"
	sleep(1200) //2 minutes
	usr.verbs += /mob/living/carbon/human/proc/smite_evil
	usr << "<span class='notice'>You feel a holy energy fill you once more.</span>"



//Summon Grass Blade: One-use, summons a blade of grass for botanists
/mob/living/carbon/human/proc/summon_dank_blade()
	set name = "Summon Blade of Grass"
	set category = "The Magic of Peace, Man"

	/*if(!ticker.mode.shitty)
		usr << "<span class='warning'>You feel insufficiently hip to use this ability.</span>'
		return*/

	if(usr.stat)
		return

	usr.visible_message("<span class='danger'>[usr]'s arm rapidly morphs into a large blade-like plant closely resembling an ambrosia branch!</span>", \
					    "<font color=green>It's time to make some people <b>trip</b>, duuude.</font>")

	usr.put_in_hands(/obj/item/weapon/melee/arm_blade/grass)
	usr.verbs -= /mob/living/carbon/human/proc/summon_dank_blade



//Faggot of the Damned: Lets you speak a single message to all dead mobs, but only once! 1% chance after being used to gain another message
/obj/item/weapon/reagent_containers/food/snacks/faggot/deadchat
	name = "faggot of the damned"
	desc = "This mystical artifact allows you to speak a single message to the realm of the dead... but only once. To use it, simply activate it in your hand. Eating it will nullify its powers."
	unacidable = 1
	var/active = 0

/obj/item/weapon/reagent_containers/food/snacks/faggot/deadchat/attack_self(mob/sodiumchloride as mob)
	if(active)
		return //only one message
	active = 1
	sodiumchloride << "<span class='deadsay'>You feel the eyes of countless deceased souls upon you. Speak your message to them.</span>"
	var/what_to_send = stripped_input("", "Message to the Dead", "")
	if(!what_to_send)
		sodiumchloride << "<span class='notice'>You abruptly lower \the [src] from your eyes. Perhaps you should think this through.</span>"
		active = 0
		return
	playsound(src.loc, 'sound/effects/ghost2.ogg', 50, 1)
	sodiumchloride.visible_message("<span class='danger'>[sodiumchloride]'s eyes and mouth glow a deep violet as they speak, before slowly dimming back to normal...</span>", \
								   "<span class='deadsay'>You speak into \the [src], its energies swirling through your body.</span>")
	sodiumchloride.say(what_to_send)
	flags = NODROP

	for(var/mob/M in dead_mob_list)
		M << "<span class='deadsay'><b>A brief message comes from the realm of the living... </b> <i>[what_to_send]</i></span>"

	sleep(20)
	flags = null
	sodiumchloride.unEquip(src)
	if(prob(99))
		visible_message("<span class='warning'>Its unearthly powers expended, \the [src] falls to the ground. Within moments, it is just another faggot.</span>")
		new /obj/item/weapon/reagent_containers/food/snacks/faggot(loc)
		qdel(src)
	else
		visible_message("<span class='warning'>\The [src] glows a deep purple and throbs with energy. Its powers have not yet been expended.</span>")
		active = 0 //another message
	return



//Blade of Grass: Botanist arm-blade, instead of doing damage it injects people with space drugs and makes the attacker say hippie stuff
/obj/item/weapon/melee/arm_blade/grass
	name = "grass blade"
	desc = "Why make war when you can, like, make love, man?"
	force = 0
	attack_verb = list("tripped", "drugged", "totally far-outed", "conspiracied", "peaced")
	var/uses = 4 //5 hits total

/obj/item/weapon/melee/arm_blade/grass/attack(mob/living/carbon/human/druggie as mob, mob/living/carbon/human/hippie as mob)
	..()
	uses--
	var/trippy_phrases = list("Spread the love, maaaan...", "Duuuude...", "Make love, not war...", "Far out, bruh...", "It's all a conspiracy, duuuude...")
	druggie.reagents.add_reagent("space_drugs", 50)
	druggie << "<span class='userdanger'>[pick("Far out", "Trippy", "Woah")], m<font size=4>a</font><font size=3>a</font><font size=5>a</font><font size=3>a</font>an...</span>"
	if(prob(50))
		hippie.say(pick(trippy_phrases))

	if(uses <= 0)
		src.visible_message("<span class'danger'>\The [src] curls up, slipping off of [hippie]'s arm, and withers away.</span>")
		qdel(src)



//Putting heads on spears
/obj/item/organ/limb/head/attackby(var/obj/item/weapon/W, var/mob/living/user, params)
	if(istype(W, /obj/item/weapon/twohanded/spear) && ticker.mode.shitty)
		user << "<span class='notice'>You stick the head onto the spear and stand it upright on the ground.</span>"
		new /obj/structure/headspear(user.loc)
		qdel(W)
		qdel(src)
		return
	return ..()

/obj/item/weapon/twohanded/spear/attackby(var/obj/item/I, var/mob/living/user)
	if(istype(I, /obj/item/organ/limb/head) && ticker.mode.shitty)
		user << "<span class='notice'>You stick the head onto the spear and stand it upright on the ground.</span>"
		new /obj/structure/headspear(user.loc)
		qdel(I)
		qdel(src)
		return
	return ..()

/obj/structure/headspear
	name = "head on a spear"
	desc = "How barbaric."
	icon_state = "headspear"
	density = 0
	anchored = 1

/obj/structure/headspear/attack_hand(mob/living/user)
	user.visible_message("<span class='warning'>[user] kicks over \the [src]!</span>", "<span class='danger'>You kick down \the [src]!</span>")
	new /obj/item/weapon/twohanded/spear(loc)
	new /obj/item/organ/limb/head(loc)
	qdel(src)



//Liquid Programming
datum/reagent/medicine/programming
	name = "Liquid Programming"
	id = "programming"
	description = "This liquid is byond shit. It's completely shit."
	color = "#2D0F00" //brown

datum/reagent/medicine/programming/on_mob_life(var/mob/living/M as mob)
	..()
	var/effect = rand(1,3)
	if(prob(10))
		switch(effect)
			if(1)
				M << "<span class='notice'>You feel very balanced.</span>"
				M.SetStunned(0)
				M.SetWeakened(0)
			if(2)
				M << "<span class='notice'>You feel very salty.</span>"
				M.reagents.add_reagent("sodiumchloride", 5)
				M.say("[pick("", ";")]GOD FUCKING DAMN IT I HATE THESE FUCKING PIECE OF SHIT DAMN [pick("LINGS", "ADMINS", "CODERS", "ETHEREAL RULERS OF THE COSMOS", "TATORS", "REVS")]! FUCK THIS STATION!")
			if(3)
				M << "<span class='notice'>You feel very random.</span>"
				if(prob(50))
					if(prob(75))
						if(prob(90))
							M.visible_message("<b>[M]</b> holds up an imaginary spork!")
				var/random = rand(1,100 0000)
				M.say(random / rand(2,5) * rand(1,2) + rand(1,250))
				random = rand(1,2)
				if(prob(50))
					M.Stun(rand(random,random) * 2 / 2)
				else if(prob(50))
					M.Weaken(rand(random,random) * 2 / 2)
				else if(prob(50))
					M.say("FUCKING RANDOM NUMBERS!")



//Syndicate pies
/obj/item/weapon/reagent_containers/food/snacks/pie/syndicate
	name = "syndicate pie"
	desc = "A syndicate pie, still deadly."
	icon_state = "pie"
	list_reagents = list("cyanide" = 20)



//Emagging emags
/obj/item/weapon/card/emag/emag_act(mob/user)
	if(ticker.mode.shitty)
		user << "You emag the emag, giving you a new emag!"
		new /obj/item/weapon/card/emag(get_turf(src))
		new /obj/item/weapon/card/emag/emagged(get_turf(src))
		qdel(src)
	return

/obj/item/weapon/card/emag/emagged
	name = "emagged cryptographic sequencer"
	desc = "Looks pretty emagged."

/obj/item/weapon/card/emag/emagged/emag_act(mob/user)
	if(ticker.mode.shitty)
		user << "You emagg the emagged emag, creating an all access identification card!"
		new /obj/item/weapon/card/id/captains_spare(get_turf(src))
	return



//Mentorhelp
/client/verb/mentorhelp(msg as text)
	set category = "Admin"
	set name = "Mentorhelp"
	src << "<span class='deadsay'>PM to-<b>Mentors</b>: [msg]</span>"
	sleep(50)
	src << "<span class='deadsay'><font size='4'><b>-- Mentor private message --</b></font></span>"
	src << "<span class='deadsay'>Mentor PM from-<b>Mentor</b>: [pick("git gud", "Very carefully.", "Not at all")]</span>"
	src << "<span class='deadsay'><i>Click on the mentor's name to reply.</i></span>"
	src << 'sound/effects/adminhelp.ogg'
