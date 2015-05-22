/mob/living/simple_animal/brainbot
	name = "strange robot"
	maxHealth = 15
	health = 15
	notransform = 1
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	speed = 1
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	melee_damage_lower = 5
	melee_damage_upper = 5
	ventcrawler = 1
	attacktext = "smacks into"
	response_help  = "touches"
	response_disarm = "shoves"
	response_harm   = "punches"
	var/mob/living/carbon/human/controlledMob = null //The mob the brainbot is currently in control of
	var/list/downloadedMinds = list() //A list of minds whose memories have been copied.
	var/serialNumber = 0 //The randomly generated number used in examining and secure communication
	var/secondsInControlledMob = 0 //Seconds spent in a controlled mob; detrimental effects occur from being in a mob too long
	var/storedMemories = 0 //How many memories have been downloaded by the brainbot - needs 4/7 in order to succeed

/mob/living/simple_animal/brainbot/New()
	..()
	if(!src.mind)
		message_admins("Brainbot was created but has no mind. Trying again in five seconds.")
		sleep(50)
		if(!src.mind)
			message_admins("Brainbot still has no mind. Deleting...")
			qdel(src)
		else
			message_admins("Situation resolved! The brainbot is now under control of [src.key].")
	src.mind.assigned_role = "mind control robot"
	src.mind.special_role = "mind control robot"
	serialNumber = rand(1,99999)
	name = "MDR-[serialNumber]"
	src << "<span class='boldannounce'>.://boot_seq-init</span>"
	sleep(50)
	src << "<span class='warning'>CYBERSUN INDUSTRIES MIND DOMINATION ROBOT S-[serialNumber] ONLINE.</span>"
	sleep(30)
	src << "<span class='warning'>SYSTEM CHECK REPORTS ALL SYSTEMS NOMINAL. CONNECTING TO COMMUNICATIONS MAINFRAME...</span>"
	sleep(40)
	src << "<span class='warning'>CONNECTION ESTABLISHED. ENABLING MOTOR FUNCTIONS...</span>"
	sleep(40)
	src << "<span class='warning'>MOTOR FUNCTIONS ESTABLISHED. RELINQUISHING REMOTE CONTROL TO MAIN UNIT. ESTABLISHING UNIQUE IDENTIFICATION...</span>"
	src.notransform = 0
	sleep(30)
	var/list/possibleNames = list("CELL", "BADCELL", "JERK", "YOUNGLADY", "CREEP", "CHEERLEADER", "SNAPSHOT", "CLUCKER", "FETCH")
	src.name = pick(possibleNames) + "-[serialNumber]"
	src << "<span class='warning'>UNIQUE IDENTIFICATION CREATED. WELCOME, <b>[src.name]</b>. INITIATING GREETING SEQUENCE AND UNLOCKING FUNCTIONS...</span>"
	sleep(30)
	src << "<span class='info'>csOS v1.3: CYBERSUN INDUSTRIES MIND CONTROL UNIT S-[serialNumber]</span>"
	src << "<span class='notice'>You are a Syndicate mind control robot manufactured by Cybersun Industries, a branch of the Syndicate.</span>"
	src << "<span class='notice'>You have been deployed to [world.name] in order to harvest the memories of individuals.</span>"
	src << "<span class='notice'>In order to do this, you must enter a host. This may be done by alt-clicking on a human.</span>"
	src << "<span class='notice'>You have a variety of software you may use to accomplish this task. Good luck, S-[serialNumber]!</span>"
	src << "<span class='warning'>...BOOT COMPLETE. Hello World!</span>"
	src.say("Hello World!")
	var/datum/objective/getMemories/O = new /datum/objective/getMemories()
	O.owner = src
	O.generateGoal()
	src.mind.objectives += O
	src.mind.current.verbs += /mob/living/simple_animal/brainbot/proc/ejectFromMob
	src.mind.current.verbs += /mob/living/simple_animal/brainbot/proc/downloadMemory
	src.mind.current.verbs += /mob/living/simple_animal/brainbot/proc/talkToHost
	src.mind.current.verbs += /mob/living/simple_animal/brainbot/proc/helpHost
	src.mind.current.verbs += /mob/living/simple_animal/brainbot/proc/harmHost
	src.mind.current.verbs += /mob/living/simple_animal/brainbot/proc/silenceHost

/mob/living/simple_animal/brainbot/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "MEMORIES DOWNLOADED: [storedMemories]TB")

/mob/living/simple_animal/brainbot/Process_Spacemove(var/movement_dir = 0)
	return 1 //Mainly to prevent the no-grav effect

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
		visible_message("<span class='suicide'>[src] is powering down! It looks like it's trying to commit suicide.</span>", \
				"<span class='userdanger'>[src] is powering down! It looks like it's trying to commit suicide.</span>")
		death(1)

/mob/living/simple_animal/brainbot/gib()
	return death(1)

/mob/living/simple_animal/brainbot/examine(mob/user)
	..()
	if(!in_range(user, src))
		user << "<span class='info'>You can't make out a whole lot from here.</span>"
		return
	if(user.mind in ticker.mode.traitors || user.mind in ticker.mode.syndicates)
		user << "A mind invasion robot manufactured by Cybersun Industries. It controls humans by entering their ear and nestling themselves in the brain. Its serial number is S-[serialNumber]."
		return
	else
		user << "An odd creature that resembles a robotic slug. There's a small label reading: \"CYBERSUN INDUSTRIES: S-[serialNumber].\""
		return

/mob/living/simple_animal/brainbot/death()
	..(1)
	if(controlledMob)
		controlledMob.contents -= src
		src.loc = get_turf(controlledMob)
	src.visible_message("<span class='warning'>[src] collapses to the ground, sparking and flickering.</span>", \
						"<span class='boldannounce'>PRIORITY ALERT. SYSTEM INTEGRITY CRITICAL. MIND CONTROL ROUTINES: OFFLINE. SHUTTING DOWN.</span>")

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
			M << "<font color=#757468>\[MCR BINARY] [name]: <span class='robot'>[message]</robot></font>"
	return 0

/mob/living/simple_animal/brainbot/AltClickOn(atom/clickedThingy, var/mob/living/simple_animal/brainbot/user = src)
	..()
	if(ishuman(clickedThingy) && in_range(user, clickedThingy))
		var/mob/living/carbon/human/H = clickedThingy
		if(user.controlledMob)
			return
		user.jumpInto(0, H)

/datum/objective/getMemories
	dangerrating = 69 // :^)

/datum/objective/getMemories/proc/generateGoal()
	target_amount = rand(5,7)
	explanation_text = "DOWNLOAD THE MEMORIES OF [target_amount] NANOTRASEN EMPLOYEES."
	return target_amount

/datum/objective/getMemories/check_completion()
	if(!istype(owner.current, /mob/living/simple_animal/brainbot))
		return 0
	var/mob/living/simple_animal/brainbot/H = owner.current
	if(!H || H.stat == DEAD)
		return 0
	var/memoryStored = H.storedMemories
	if(memoryStored < target_amount)
		return 0
	return 1
