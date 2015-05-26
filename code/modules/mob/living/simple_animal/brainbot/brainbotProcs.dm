/mob/living/simple_animal/brainbot/proc/ejectFromMob()
	set name = "EJECT()"
	set desc = "EXITS A HOST BODY."
	set category = "SYSTEM FUNCTIONS"

	var/mob/living/simple_animal/brainbot/user = usr
	var/mob/living/carbon/human/host = user.controlledMob
	if(!istype(user) || !user)
		return
	if(user.stat)
		return
	if(!host)
		user << "<span class='warning'>YOU HAVE NO HOST.</span>"
		return
	user << "<span class='notice'>YOU BEGIN PREPARATION FOR THE EXIT OF YOUR HOST.</span>"
	sleep(50)
	if(host.stat)
		user << "<span class='warning'>YOUR HOST IS DEAD OR UNCONSCIOUS. THIS WILL BE MESSY.</span>"
		sleep(40)
		unassignControlledMob(user, 1)
		host.visible_message("<span class='boldannounce'>Something bursts through [host]'s forehead!</span>", \
				     "<span class='userdanger'>Something bursts through your forehead!</span>")
		host.emote("scream")
		host.apply_damage(75, BRUTE, "head")
		host.Weaken(7)
		playsound(host, 'sound/effects/splat.ogg', 50, -1)
		user << "<span class='boldannounce'><i>YOU EXIT YOUR HOST IN A SPRAY OF BLOOD.</i></span>"
		return
	user << "<span class='notice'>YOUR HOST IS CONSCIOUS. YOU RELEASE A DOSE OF AMNESIA SERUM AND BEGIN EXITING THEIR BRAIN.</span>"
	sleep(40)
	unassignControlledMob(user)
	host.visible_message("<span class='warning'>Something crawls out of [host]'s ear!</span>", \
			     "<span class='userdanger'>Something crawls out of your ear!</span>")
	host.emote("gasp")
	host.Weaken(6)
	sleep(30)
	host.visible_message("<span class='big'>[host] looks confused.</span>", \
			     "<span class='userdanger'>A wave of amnesia washes over you. You try to remember anything that's happened recently... but can't.</span>")


/mob/living/simple_animal/brainbot/proc/jumpInto(var/silent = 0, var/mob/living/carbon/human/hostToBe)
	var/mob/living/simple_animal/brainbot/user = usr
	var/mob/living/carbon/human/host = user.controlledMob
	if(!istype(user) || !user)
		return
	if(user.stat)
		return
	if(host)
		return
	if(hostToBe.stat)
		user << "<span class='warning'>THIS HOST IS NOT CONSCIOUS.</span>"
		return
	if(!ishuman(hostToBe))
		if(istype(hostToBe, /mob/living/simple_animal/brainbot))
			user << "<span class='warning'>YOU CANNOT CONTROL ANOTHER OF YOUR KIND.</span>"
			return
		if(issilicon(hostToBe))
			if(prob(1))
				user << "<span class='warning'>BEEP BOOP. CANNOT CONTROL ROBITS. BLEEP BORP.</span>"
			else
				user << "<span class='warning'>YOU CANNOT CONTROL ROBOTS.</span>"
			return
		user << "<span class='warning'>THIS CREATURE'S NEURAL INTERFACE IS INCOMPATIBLE WITH YOUR SYSTEM FUNCTIONS.</span>"
		return
	user.loc = hostToBe
	hostToBe.contents += user
	user.controlledMob = hostToBe
	if(prob(10))
		hostToBe << "<span class='notice'>Your head hurts.</span>" //Similar to the virus message, to avoid metagame and the host screeching ";BRAINBOTS HELP GIVE ME SURGERY"
	if(!silent)
		user << "<span class='notice'>YOU HAVE ENTERED A NEW HOST. ADDITIONAL FUNCTIONS NOW AVAILABLE.</span>"


/mob/living/simple_animal/brainbot/proc/unassignControlledMob(var/silent = 0)
	var/mob/living/simple_animal/brainbot/user = usr
	var/mob/living/carbon/human/host = user.controlledMob
	if(!istype(user) || !user)
		return
	if(user.stat)
		return
	if(!host)
		return
	user.loc = get_turf(host)
	host.contents -= user
	user.controlledMob = null
	user.secondsInControlledMob = 0
	if(!silent)
		user << "<span class='warning'>YOU HAVE EXITED YOUR HOST. ADDITIONAL FUNCTIONS NOW SUPPRESSED.</span>"


/mob/living/simple_animal/brainbot/proc/downloadMemory()
	set name = "DOWNLOAD()"
	set desc = "COPIES THE MEMORIES OF A HOST ONTO LOCAL STORAGE."
	set category = "SYSTEM FUNCTIONS"

	var/mob/living/simple_animal/brainbot/user = usr
	var/mob/living/carbon/human/host = user.controlledMob
	if(!istype(user) || !user)
		return
	if(user.stat)
		return
	if(!host)
		user << "<span class='warning'>YOU HAVE NO HOST.</span>"
		return
	if(host.mind in user.downloadedMinds)
		user << "<span class='warning'>YOU HAVE ALREADY DOWNLOADED THIS HOST'S MEMORIES.</span>"
		return
	if(!host.mind || !host.key)
		user << "<span class='warning'>THIS HOST HAS NO MEMORIES TO SPEAK OF.</span>"
		return
	if(!host.client) //No braindead downloading
		user << "<span class='warning'>THIS HOST'S MIND IS VACANT AND CANNOT BE STIMULATED WITH ELECTRICAL SIGNALS.</span>"
		return
	user << "<span class='notice'>YOU PLACE ELECTRODES ONTO THE BRAIN OF YOUR HOST AND BEGIN COPYING THEIR MEMORIES.</span>"
	host << "<span class='warning'>You feel an unpleasant sensation inside of your skull.</span>"
	sleep(50)
	host << "<span class='warning'>The sensation passes.</span>"
	user << "<span class='notice'>YOUR HOST'S MEMORIES HAVE BEEN COPIED ONTO A LOCAL DRIVE.</span>"
	if(host.mind)
		var/datum/mind/hostMind = host.mind
		if(hostMind in ticker.mode.traitors || hostMind in ticker.mode.syndicates)
			user << "<span class='notice'>YOUR HOST SERVES YOUR CREATORS, THE SYNDICATE. THEY ARE NOT TO BE HARMED.</span>"
		if(hostMind in ticker.mode.changelings)
			user << "<span class='notice'>YOUR HOST IS AN ALIEN CHANGELING.</span>"
		if(hostMind in ticker.mode.cult)
			user << "<span class='notice'>YOUR HOST SERVES THE GEOMETER OF BLOOD, NAR-SIE.</span>"
		if(hostMind in ticker.mode.wizards)
			user << "<span class='notice'>YOUR HOST IS A MUTANT SERVANT OF THE WIZARDS' FEDERATION.</span>"
		if(is_shadow(host))
			user << "<span class='notice'>YOUR HOST IS AN ALIEN SHADOWLING.</span>"
		if(is_thrall(host))
			user << "<span class='notice'>YOUR HOST IS THE THRALL OF A SHADOWLING.</span>"
	user.storedMemories++
	user << "<span class='notice'>YOUR HOST'S MEMORIES:</span>"
	host.mind.show_memory(user, 0)


/mob/living/simple_animal/brainbot/proc/helpHost()
	set name = "HELP()"
	set desc = "INJECTS A COCKTAIL OF BENEFICIAL CHEMICALS INTO YOUR HOST. CONTINUED USE MAY CAUSE DAMAGE."
	set category = "SYSTEM FUNCTIONS"
	var/cooldown = 0

	var/mob/living/simple_animal/brainbot/user = usr
	var/mob/living/carbon/human/host = user.controlledMob
	if(!istype(user) || !user)
		return
	if(user.stat)
		return
	if(!host)
		user << "<span class='warning'>YOU HAVE NO HOST.</span>"
		return
	if(!host.reagents)
		user << "<span class='warning'>YOUR HOST IS INCAPABLE OF METABOLIZING REAGENTS.</span>"
		return
	if(host.stat == DEAD)
		user << "<span class='warning'>YOUR HOST IS DEAD AND CANNOT METABOLIZE REAGENTS.</span>"
		return
	if(cooldown)
		user << "<span class='warning'>YOU ARE STILL SYNTHESIZING ANOTHER SERUM.</span>"
		return
	user << "<span class='notice'>YOU INJECT A SERUM OF STIMULANTS AND BENEFICIAL NARCOTICS INTO YOUR HOST. IT WILL TAKE SOME TIME TO CREATE MORE.</span>"
	host << "<span class='info'>You suddenly feel amazing! Your head is crystal-clear!</span>"
	host.reagents.add_reagent("methamphetamine", 3) //gotta go fast; doesn't inject enough to addict or overdose you
	host.reagents.add_reagent("ephedrine", 5)
	host.reagents.add_reagent("stimulants", 5)
	host.reagents.add_reagent("omnizine", 5)
	host.reagents.add_reagent("epinephrine", 5)
	host.reagents.add_reagent("space_drugs", 5)
	host.reagents.add_reagent("coffee", 5)
	host.AdjustStunned(-3)
	host.AdjustWeakened(-3)
	host.AdjustParalysis(-3)
	cooldown = 1
	spawn(1200) //2 minute cooldown
		cooldown = 0
		user << "<span class='notice'>YOU HAVE METABOLIZED ANOTHER BENEFICIAL SERUM. YOU MAY NOW USE HELP().</span>"


/mob/living/simple_animal/brainbot/proc/harmHost()
	set name = "BURN()"
	set desc = "INJECTS A COCKTAIL OF HARMFUL CHEMICALS INTO YOUR HOST. USE TO INVOKE OBEDIENCE."
	set category = "SYSTEM FUNCTIONS"
	var/cooldown = 0

	var/mob/living/simple_animal/brainbot/user = usr
	var/mob/living/carbon/human/host = user.controlledMob
	switch(alert("ARE YOU SURE? THIS WILL LIKELY KILL YOUR HOST.",,"CONFIRM","CANCEL"))
		if("CANCEL")
			return 0
	if(!istype(user) || !user)
		return
	if(user.stat)
		return
	if(!host)
		user << "<span class='warning'>YOU HAVE NO HOST.</span>"
		return
	if(!host.reagents)
		user << "<span class='warning'>YOUR HOST IS INCAPABLE OF METABOLIZING REAGENTS.</span>"
		return
	if(host.stat == DEAD)
		user << "<span class='warning'>YOUR HOST IS DEAD AND CANNOT METABOLIZE REAGENTS.</span>"
		return
	if(cooldown)
		user << "<span class='warning'>YOU ARE STILL SYNTHESIZING ANOTHER SERUM.</span>"
		return
	user << "<span class='notice'>YOU INJECT A SERUM OF TOXINS INTO YOUR HOST. IT WILL TAKE SOME TIME TO CREATE MORE.</span>"
	host << "<span class='boldannounce'>Your head throbs sharply, and you suddenly are engulfed in flames!</span>"
	host.reagents.add_reagent("clf3", 5)
	host.reagents.add_reagent("phlogiston", 5)
	host.reagents.add_reagent("thermite", 5)
	cooldown = 1
	spawn(600) //1 minute cooldown -- shorter than Help()
		cooldown = 0
		user << "<span class='notice'>YOU HAVE METABOLIZED ANOTHER HARMFUL SERUM. YOU MAY NOW USE BURN().</span>"


/mob/living/simple_animal/brainbot/proc/talkToHost()
	set name = "CONVERSE()"
	set desc = "SPEAKS SILENTLY TO YOUR HOST. THEY WILL WHISPER TO THEMSELVES IF CONSCIOUS."
	set category = "SYSTEM FUNCTIONS"

	var/mob/living/simple_animal/brainbot/user = usr
	var/mob/living/carbon/human/host = user.controlledMob
	if(!istype(user) || !user)
		return
	if(user.stat)
		return
	if(!host)
		user << "<span class='warning'>YOU HAVE NO HOST.</span>"
		return
	if(host.stat == DEAD)
		user << "<span class='warning'>YOUR HOST IS DEAD.</span>"
		return
	var/messageToSend = stripped_input(usr, "ENTER A MESSAGE TO SEND TO YOUR HOST.", "CONVERSE()", "")
	if(!messageToSend)
		return
	user << "<span class='boldannounce'>YOU TRANSMIT A MESSAGE TO YOUR HOST:</span> <span class='robot'>[messageToSend]</span>"
	host << "<span class='boldannounce'>You hear a synthetic voice in your head:</span><span class='robot'> [messageToSend]</span>"
	if(!host.stat)
		host.whisper(messageToSend)


/mob/living/simple_animal/brainbot/proc/silenceHost()
	set name = "SILENCE()"
	set desc = "INJECTS MUTING TOXIN INTO YOUR HOST. USED TO PREVENT SPEECH."
	set category = "SYSTEM FUNCTIONS"
	var/cooldown = 0

	var/mob/living/simple_animal/brainbot/user = usr
	var/mob/living/carbon/human/host = user.controlledMob
	if(!istype(user) || !user)
		return
	if(user.stat)
		return
	if(!host)
		user << "<span class='warning'>YOU HAVE NO HOST.</span>"
		return
	if(host.stat)
		user << "<span class='warning'>YOUR HOST MUST BE CONSCIOUS.</span>"
		return
	if(!host.reagents)
		user << "<span class='warning'>YOUR HOST IS INCAPABLE OF METABOLIZING REAGENTS.</span>"
		return
	if(cooldown)
		user << "<span class='warning'>YOU ARE STILL SYNTHESIZING ANOTHER SERUM.</span>"
		return
	user << "<span class='notice'>YOU SILENTLY INJECT A SPEECH-INHIBITING SERUM INTO YOUR HOST. IT WILL TAKE SOME TIME TO CREATE MORE.</span>"
	host << "<span class='notice'>Your throat hurts.</span>"
	host.reagents.add_reagent("mutetoxin", 5)
	spawn(600) //1 minute cooldown
		cooldown = 0
		user << "<span class='notice'>YOU HAVE METABOLIZED ANOTHER SILENCING SERUM. YOU MAY NOW USE SILENCE().</span>"
