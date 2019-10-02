/*
////////////////////////////////////////////////////////////////////////////////////////////////////
//										ASTROGEN
///////////////////////////////////////////////////////////////////////////////////////////////////
More fun chems!
When you take it, it spawns a ghost that the player controls. (No access to deadchat)
This ghost moves pretty quickly and is mostly invisible, but is still visible for people with eyes.
When it's out of your system, you return back to yourself. It doesn't last long and metabolism of the chem is exponential.
Addiction is particularlly brutal, it slowly turns you invisible with flavour text, then kills you at a low enough alpha. (i've also added something to prevent geneticists speeding this up)
There's afairly major catch regarding the death though. I'm not gonna say here, go read the code, it explains it and puts my comments on it in context. I know that anyone reading it without understanding it is going to freak out so, this is my attempt to get you to read it and understand it.
I'd like to point out from my calculations it'll take about 60-80 minutes to die this way too. Plenty of time to visit me and ask for some pills to quench your addiction.
*/



/datum/reagent/fermi/astral // Gives you the ability to astral project for a moment!
	name = "Astrogen"
	id = "astral"
	description = "An opalescent murky liquid that is said to distort your soul from your being."
	color = "#A080H4" // rgb: , 0, 255
	taste_description = "your mind"
	metabolization_rate = 0//Removal is exponential, see code
	overdose_threshold = 20
	addiction_threshold = 24.5
	addiction_stage1_end = 9999//Should never end. There is no escape make your time
	var/mob/living/carbon/origin
	var/mob/living/simple_animal/astral/G = null
	var/datum/mind/originalmind
	var/antiGenetics = 255
	var/sleepytime = 0
	InverseChemVal = 0.25
	can_synth = FALSE

/datum/action/chem/astral
	name = "Return to body"
	var/mob/living/carbon/origin = null
	var/mob/living/simple_animal/hostile/retaliate/ghost = null

/datum/action/chem/astral/Trigger()
	ghost.mind.transfer_to(origin)
	qdel(src)

/datum/reagent/fermi/astral/reaction_turf(turf/T, reac_volume)
	if(isplatingturf(T) || istype(T, /turf/open/floor/plasteel))
		var/turf/open/floor/F = T
		F.PlaceOnTop(/turf/open/floor/fakespace)
	..()

/datum/reagent/fermi/astral/reaction_obj(obj/O, reac_volume)
	if(istype(O, /obj/item/bedsheet))
		new /obj/item/bedsheet/cosmos(get_turf(O))
		qdel(O)


/datum/reagent/fermi/astral/on_mob_life(mob/living/carbon/M) // Gives you the ability to astral project for a moment!
	M.alpha = 255
	if(current_cycle == 0)
		originalmind = M.mind
		log_game("FERMICHEM: [M] ckey: [M.key] became an astral ghost")
		origin = M
		if (G == null)
			G = new(get_turf(M.loc))
		G.name = "[M]'s astral projection"
		var/datum/action/chem/astral/AS = new(G)
		AS.origin = M
		AS.ghost = G
		if(M.mind)
			M.mind.transfer_to(G)
		SSblackbox.record_feedback("tally", "fermi_chem", 1, "Astral projections")
	if(overdosed)
		if(prob(50))
			to_chat(G, "<span class='warning'>The high conentration of Astrogen in your blood causes you to lapse your concentration for a moment, bringing your projection back to yourself!</b></span>")
			do_teleport(G, M.loc)
	M.reagents.remove_reagent(id, current_cycle/10, FALSE)//exponent
	sleepytime+=5
	if(G)//This is a mess because of how slow qdel is, so this is all to stop runtimes.
		if(G.mind)
			if(G.stat == DEAD || G.pseudo_death == TRUE)
				G.mind.transfer_to(M)
				qdel(G)
	..()

/datum/reagent/fermi/astral/on_mob_delete(mob/living/carbon/M)
	if(!G)
		if(M.mind)
			var/mob/living/simple_animal/astral/G = new(get_turf(M.loc))
			M.mind.transfer_to(G)//Just in case someone else is inside of you, it makes them a ghost and should hopefully bring them home at the end.
			to_chat(G, "<span class='warning'>[M]'s conciousness snaps back to them as their astrogen runs out, kicking your projected mind out!'</b></span>")
			log_game("FERMICHEM: [M]'s possesser has been booted out into a astral ghost!")
		originalmind.transfer_to(M)
	else if(G.mind)
		G.mind.transfer_to(origin)
		qdel(G)
	if(overdosed)
		to_chat(M, "<span class='warning'>The high volume of astrogen you just took causes you to black out momentarily as your mind snaps back to your body.</b></span>")
		M.Sleeping(sleepytime, 0)
	antiGenetics = 255
	if(G)//just in case
		qdel(G)
	log_game("FERMICHEM: [M] has astrally returned to their body!")
	..()

//Okay so, this might seem a bit too good, but my counterargument is that it'll likely take all round to eventually kill you this way, then you have to be revived without a body. It takes approximately 50-80 minutes to die from this.
/datum/reagent/fermi/astral/addiction_act_stage1(mob/living/carbon/M)
	if(addiction_stage < 2)
		antiGenetics = 255
		M.alpha = 255 //Antigenetics is to do with stopping geneticists from turning people invisible to kill them.
	if(prob(70))
		M.alpha--
		antiGenetics--
	switch(antiGenetics)
		if(245)
			to_chat(M, "<span class='warning'>You notice your body starting to disappear, maybe you took too much Astrogen...?</b></span>")
			M.alpha--
			antiGenetics--
			log_game("FERMICHEM: [M] ckey: [M.key] has become addicted to Astrogen")
		if(220)
			to_chat(M, "<span class='notice'>Your addiction is only getting worse as your body disappears. Maybe you should get some more, and fast?</b></span>")
			M.alpha--
			antiGenetics--
		if(200)
			to_chat(M, "<span class='notice'>You feel a substantial part of your soul flake off into the ethereal world, rendering yourself unclonable.</b></span>")
			M.alpha--
			antiGenetics--
			ADD_TRAIT(M, TRAIT_NOCLONE, "astral") //So you can't scan yourself, then die, to metacomm. You can only use your memories if you come back as something else.
			M.hellbound = TRUE
		if(180)
			to_chat(M, "<span class='notice'>You feel fear build up in yourself as more and more of your body and consciousness begins to fade.</b></span>")
			M.alpha--
			antiGenetics--
		if(120)
			to_chat(M, "<span class='notice'>As you lose more and more of yourself, you start to think that maybe shedding your mortality isn't too bad.</b></span>")
			M.alpha--
			antiGenetics--
		if(80)
			to_chat(M, "<span class='notice'>You feel a thrill shoot through your body as what's left of your mind contemplates your forthcoming oblivion.</b></span>")
			M.alpha--
			antiGenetics--
		if(45)
			to_chat(M, "<span class='warning'>The last vestiges of your mind eagerly await your imminent annihilation.</b></span>")
			M.alpha--
			antiGenetics--
		if(-INFINITY to 30)
			to_chat(M, "<span class='warning'>Your body disperses from existence, as you become one with the universe.</b></span>")
			to_chat(M, "<span class='userdanger'>As your body disappears, your consciousness doesn't. Should you find a way back into the mortal coil, your memories of your previous life remain with you. (At the cost of staying in character while dead. Failure to do this may get you banned from this chem. You are still obligated to follow your directives if you play a midround antag, you do not remember the afterlife IC)</span>")//Legalised IC OOK? I have a suspicion this won't make it past the review. At least it'll be presented as a neat idea! If this is unacceptable how about the player can retain living memories across lives if they die in this way only.
			deadchat_broadcast("<span class='warning'>[M] has become one with the universe, meaning that their IC conciousness is continuous in a new life. If they find a way back to life, they are allowed to remember their previous life. Be careful what you say. If they abuse this, bwoink the FUCK outta them.</span>")
			M.visible_message("[M] suddenly disappears, their body evaporating from existence, freeing [M] from their mortal coil.")
			message_admins("[M] (ckey: [M.ckey]) has become one with the universe, and have continuous memories thoughout their lives should they find a way to come back to life (such as an inteligence potion, midround antag, ghost role).")
			SSblackbox.record_feedback("tally", "fermi_chem", 1, "Astral obliterations")
			qdel(M) //Approx 60minutes till death from initial addiction
			log_game("FERMICHEM: [M] ckey: [M.key] has been obliterated from Astrogen addiction")
	..()
