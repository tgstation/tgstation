/mob/living/simple_animal/brainbot
	name = "strange robot"
	maxHealth = 15
	health = 15
	notransform = 1
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	speed = 1
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "smacks into"
	response_help  = "touches"
	response_disarm = "shoves"
	response_harm   = "punches"
	var/mob/living/carbon/human/controlledMob = null //The mob the brainbot is currently in control of
	var/datum/mind/controlledMobMind = null //The mind that is not in control of their own body
	var/serialNumber = 0 //The randomly generated number used in examining and secure communication
	var/canSpeak = 0 //Whether or not the brainbot can talk; if controlling a human, they cannot talk on hive chat
	var/secondsInControlledMob = 0 //Seconds spent in a controlled mob; detrimental effects occur from being in a mob too long

/mob/living/simple_animal/brainbot/New()
	..()
	serialNumber = rand(1,99999)
	name = "MDR-[serialNumber]"
	src << "<span class='boldannounce'>.://boot_seq-init</span>"
	sleep(50)
	src << "<span class='warning'>CYBERSUN INDUSTRIES MIND DOMINATION ROBOT S-[serialNumber] ONLINE.</span>"
	sleep(30)
	src << "<span class='warning'>SYSTEM CHECK REPORTS ALL SYSTEMS NOMINAL. CONNECTING TO COMMUNICATIONS MAINFRAME...</span>"
	sleep(40)
	src << "<span class='warning'>CONNECTION ESTABLISHED. ENABLING MOTOR FUNCTIONS...</span>"
	canSpeak = 1
	src.say("Hello World!")
	sleep(40)
	src << "<span class='warning'>MOTOR FUNCTIONS ESTABLISHED. RELINQUISHING REMOTE CONTROL TO MAIN UNIT. ESTABLISHING UNIQUE IDENTIFICATION...</span>"
	src.notransform = 0
	sleep(30)
	var/list/possibleNames = list("CELL", "BADCELL", "JERK", "YOUNGLADY", "CREEP", "CHEERLEADER", "SNAPSHOT", "CLUCKER", "FETCH")
	src.name = pick(possibleNames) + "-[serialNumber]"
	src << "<span class='warning'>UNIQUE IDENTIFICATION CREATED. WELCOME, <b>[src.name]</b>.</span>"

/mob/living/simple_animal/brainbot/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	if(controlledMob)
		return //nice try
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		visible_message("<span class='danger'>[src] is powering down! It looks like \he's trying to commit suicide.</span>", \
				"<span class='userdanger'>[src] is powering down! It looks like \he's trying to commit suicide.</span>")
		death(1)

/mob/living/simple_animal/brainbot/examine(mob/user)
	..()
	if(!in_range(user, src))
		user << "<span class='info'>You can't make out a whole lot from here.</span>"
		return
	if(user.mind in ticker.mode.traitors || user.mind in ticker.mode.syndicates)
		user << "A mind invasion robot manufactured by Cybersun Industries. It controls humans by entering their ear and nestling themselves in the brain. Its serial number is S-[serialNumber]."
		return
	else
		user << "An odd robot that resembles a red-and-black earthworm. It has filmy wings and a small beak-like formation at its front. There's a small label reading: \"CYBERSUN INDUSTRIES\": S-[serialNumber]."
		return

/mob/living/simple_animal/brainbot/death()
	..(1)
	if(controlledMob)
		controlledMob.contents -= src
		src.loc = get_turf(controlledMob)
	src.visible_message("<span class='warning'>[src] collapses to the ground, sparking and flickering.</span>", \
						"<span class='boldannounce'>PRIORITY ALERT. SYSTEM INTEGRITY CRITICAL. MIND CONTROL ROUTINES: OFFLINE. SHUTTING DOWN.</span>")
	qdel(src)

/mob/living/simple_animal/brainbot/Life()
	..()
	if(controlledMob)
		secondsInControlledMob++
		switch(secondsInControlledMob)
			if(5001)
				controlledMob << "<span class='warning'>NEURAL DISRUPTION DETECTED. RE-ESTABLISHING CONTROL.</span>"
				controlledMob.visible_message("<span class='warning'>[controlledMob] freezes statue-still for a moment before returning to normal.</span>")
			if(6000 to 8000)
				if(prob(2))
					controlledMob << "<span class='warning'>YOU ARE LOSING CONTROL OF YOUR HOST.</span>"
					var/list/possiblePhrases = list("It's in my head...", "Help me!", "I can't control my own body!", "Please dear God help me!")
					controlledMob.whisper(pick(possiblePhrases))
			if(8001)
				controlledMob << "<span class='warning'>NEURAL BLOCKADE DETECTED. LOSING CONTROL OF HOST. STRUCTURAL DAMAGE WILL OCCUR IF YOU REMAIN.</span>"
				var/list/possiblePhrases = list("It's in my head...", "Help me!", "I can't control my own body!", "Please dear God help me!")
				controlledMob.say(pick(possiblePhrases))
			if(8200 to INFINITY)
				controlledMob << "<span class='warning'>WARNING. TAKING DAMAGE. VACATE HOST IMMEDIATELY.</span>"
				var/list/possibleYellPhrases = list("There's something in my head", "I can't control my body", "HELP ME")
				if(prob(25))
					controlledMob.say("[pick(";", "")][pick(possibleYellPhrases)]!!")
				src.health -= 3

/mob/living/simple_animal/brainbot/say(message)
	if(!message)
		return
	for(var/mob/M in mob_list)
		if(istype(M, /mob/living/simple_animal/brainbot/) || (M in dead_mob_list))
			if(src.canSpeak)
				M << "<font color=#757468>[name]: [message]</font>"
	return 0


//The bread and butter of the brainbot.
/mob/living/simple_animal/brainbot/proc/mentalDomination(atom/target, mob/living/simple_animal/brainbot/user as mob)
	if(!ismob(target))
		return ..()
	if(controlledMob) //Can't attack from inside a guy
		user << "<span class='warning'>YOU ARE ALREADY CONTROLLING A HOST.</span>"
		return
	if(!isliving(target))
		user << "<span class='warning'>THIS CREATURE IS DEAD.</span>"
		return
	var/mob/living/mobToControl = target
	if(issilicon(mobToControl))
		return ..()
	if(!ishuman(mobToControl))
		user << "<span class='warning'>THIS CREATURE'S NEURAL PATTERNS CANNOT BE INFLUENCED BY YOU.</span>"
		return
	var/mob/living/carbon/human/humanToControl = mobToControl
	user.visible_message("<span class='warning'><b>[user] rushes toward [humanToControl] and slithers into their ear!</span>", \
						"<span class='warning'>YOU ARE ATTEMPTING TO ASSUME CONTROL OF [humanToControl]...</span>")
	user.loc = humanToControl
	if(humanToControl.mind)
		humanToControl << "<span class='userdanger'>You feel something moving around inside your head!</span>"
		humanToControl.emote("scream")
		sleep(40)
	var/mob/living/simple_animal/brainbot/bot
	if(bot in humanToControl.contents)
		user << "<span class='warning'>THIS HOST IS ALREADY UNDER CONTROL.</span>"
		user.loc = get_turf(humanToControl)
		humanToControl.visible_message("<span class='warning'>[user] crawls out of [humanToControl]'s ear!</span>", \
									   "<span class='boldannounce'>You feel an awful sensation as something crawls through your ear!</span>")
		humanToControl.emote("moan")
		return
	humanToControl.contents += user
	user << "<span class='info'>YOU HAVE ASSUMED CONTROL OF [humanToControl]. THEIR CONSCIOUSNESS WILL RETURN UPON YOUR EXIT.</span>"
	humanToControl << "<span class='boldannounce'>You lose control over your body. You see through eyes you cannot use.</span>"
	user.controlledMob = humanToControl
	user.controlledMobMind = humanToControl.mind
	var/datum/mind/botMind = user.mind
	var/datum/mind/humanMind = humanToControl.mind
	botMind.transfer_to(humanToControl)
	humanMind.transfer_to(user)
	user.canSpeak = 0
