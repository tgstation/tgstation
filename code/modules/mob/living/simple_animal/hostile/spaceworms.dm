
//Worm Segments, Dummy, has no AI, relies on the head.
/mob/living/simple_animal/hostile/spaceWorm
	name = "space worm segment"
	desc = "A part of a space worm."
	icon = 'icons/mob/animal.dmi'
	icon_state = "spaceworm"
	icon_living = "spaceworm"
	icon_dead = "spacewormdead"
	status_flags = 0

	speak_emote = list("screeches")
	emote_hear = list("screeches")

	response_help  = "touches"
	response_disarm = "flails at"
	response_harm   = "punches"

	harm_intent_damage = 2

	maxHealth = 50
	health = 50

	stop_automated_movement = 1
	animate_movement = SYNC_STEPS

	minbodytemp = 0
	maxbodytemp = 350
	min_oxy = 0
	max_co2 = 0
	max_tox = 0

	a_intent = "harm" //so they don't get pushed around

	environment_smash = 1

	speed = -1

	AIenabled = 0 //The body isn't conscious

	faction = list("spaceworms")

	var/mob/living/simple_animal/hostile/spaceWorm/previousWorm //next/previous segments, correspondingly
	var/mob/living/simple_animal/hostile/spaceWorm/nextWorm     //head is the nextest segment

	var/mob/living/simple_animal/hostile/spaceWorm/wormHead/myHead		//Can be the same as next, just a general reference to the main worm.

	var/stomachProcessProbability = 50
	var/digestionProbability = 20

	var/atom/currentlyEating //what the worm is currently eating
	var/plasmaPoopPotential = 5 //this mainly exists for the name


//Worm Head, Controls the AI for the entire worm "entity"
/mob/living/simple_animal/hostile/spaceWorm/wormHead
	name = "space worm head"
	icon_state = "spacewormhead"
	icon_living = "spacewormhead"
	icon_dead = "spacewormdead"

	//Stronger than normal segments
	maxHealth = 125
	health = 125

	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "bites"

	animate_movement = SLIDE_STEPS

	AIenabled = 1//The head is conscious
	stop_automated_movement = 0 //Ditto ^

	//head specific variables
	var/spawnWithSegments = 6
	var/list/totalWormSegments = list() //doesn't contain src
	var/catastrophicDeathProb = 15 //15% chance for the death of the head to kill the whole thing


/mob/living/simple_animal/hostile/spaceWorm/wormHead/New(var/location, var/segments = spawnWithSegments)
	..()

	if(!src)//This is to prevent a runtime.
		return

	myHead = src //It's it's own head.

	//Used in the for to attach each worm segment to the next in the sequence, instead of all of them to src
	var/mob/living/simple_animal/hostile/spaceWorm/currentWormSeg = src

	for(var/i = 1 to segments)
		var/mob/living/simple_animal/hostile/spaceWorm/newSegment = new /mob/living/simple_animal/hostile/spaceWorm(loc)
		currentWormSeg.Attach(newSegment)
		currentWormSeg = newSegment

	for(var/mob/living/simple_animal/hostile/spaceWorm/SW in totalWormSegments)
		SW.update_icon()

/mob/living/simple_animal/hostile/spaceWorm/wormHead/update_icon()
	if(stat == CONSCIOUS || stat == UNCONSCIOUS)
		icon_state = "spacewormhead[previousWorm ? 1 : 0]"
		if(previousWorm)
			dir = get_dir(previousWorm,src)
	else
		icon_state = "spacewormheaddead"

	for(var/mob/living/simple_animal/hostile/spaceWorm/SW in totalWormSegments)
		if(SW == src)//incase src ends up in here we don't want an infinite loop
			continue
		SW.update_icon()


//Try to move onto target's turf and eat them
/mob/living/simple_animal/hostile/spaceWorm/wormHead/AttackingTarget()
	..()
	attemptToEat(target)

//Attempt to eat things we bump into, Mobs, Walls, Clowns
/mob/living/simple_animal/hostile/spaceWorm/wormHead/Bump(atom/obstacle)
	attemptToEat(obstacle)

//Attempt to eat things, only the head can eat
/mob/living/simple_animal/hostile/spaceWorm/wormHead/proc/attemptToEat(var/atom/noms)
	if(!noms)
		return

	currentlyEating = noms

	var/nomDelay = 25
	var/turf/simulated/wall/W

	if(noms in totalWormSegments)
		return //Trying to eat part of self.

	if(istype(noms, /turf))
		if(istype(noms, /turf/simulated/wall))
			W = noms
			nomDelay *= 2
			if(W.walltype == "rwall")
				nomDelay *= 2
		else
			return

	if(do_after(src, nomDelay,5,0))
		if(noms && Adjacent(noms) && (currentlyEating == noms))//It exists, were next to it, and it's still the thing were eating
			if(W)
				W.ChangeTurf(/turf/simulated/floor/plasteel)
				new /obj/item/stack/sheet/metal(src, plasmaPoopPotential)
			else
				contents += noms


//Harder to kill the head, but it can kill off the whole worm
/mob/living/simple_animal/hostile/spaceWorm/wormHead/Die()
	..()
	if(prob(catastrophicDeathProb))
		for(var/mob/living/simple_animal/hostile/spaceWorm/SW in totalWormSegments)
			SW.Die()


/mob/living/simple_animal/hostile/spaceWorm/Life()
	if(nextWorm && !(Adjacent(nextWorm)))
		Detach(0)

	if(stat == DEAD)
		if(previousWorm)
			previousWorm.Detach(0)
		if(nextWorm)
			Detach(1)

	if(prob(stomachProcessProbability))
		ProcessStomach()

	update_icon()//While most mobs don't call this on Life(), the worm would probably look stupid without it
	//Plus the worm's update_icon() isn't as beefy.

	..() //Really high fuckin priority that this is at the bottom.


//if a chunk a destroyed, make a new worm out of the split halves
/mob/living/simple_animal/hostile/spaceWorm/Destroy()
	if(previousWorm)
		previousWorm.Detach(0)
	..()


//Move all segments if one piece moves.
/mob/living/simple_animal/hostile/spaceWorm/Move()
	var/segmentNextPos = loc
	if(..())
		if(previousWorm)
			previousWorm.Move(segmentNextPos)
		update_icon()


//Update the appearence of this big weird chain-worm-thingy
/mob/living/simple_animal/hostile/spaceWorm/proc/update_icon()
	if(stat != DEAD)
		if(previousWorm)
			icon_state = "spaceworm[get_dir(src,previousWorm) | get_dir(src,nextWorm)]"
		else
			icon_state = "spacewormtail"//end of rine
			dir = get_dir(src,nextWorm)

	else
		icon_state = "spacewormdead"



//Add a new worm segment
/mob/living/simple_animal/hostile/spaceWorm/proc/Attach(var/mob/living/simple_animal/hostile/spaceWorm/toAttach)
	if(!toAttach)
		return

	previousWorm = toAttach
	toAttach.nextWorm = src

	if(myHead)
		if(toAttach.myHead)
			toAttach.myHead.totalWormSegments -= src

		toAttach.myHead = myHead
		myHead.totalWormSegments |= toAttach

		//if toAttach is part of another worm, disconnect all those parts and connect them to the new worm.
		var/mob/living/simple_animal/hostile/spaceWorm/isPrevWorm
		if(toAttach.previousWorm)
			isPrevWorm = toAttach.previousWorm

		while(isPrevWorm)
			if(isPrevWorm.previousWorm)
				if(isPrevWorm.myHead)
					isPrevWorm.myHead.totalWormSegments -=isPrevWorm.previousWorm
					toAttach.myHead.totalWormSegments |= isPrevWorm.previousWorm
				isPrevWorm = isPrevWorm.previousWorm
			else
				isPrevWorm = null

	update_icons()


//Remove a worm segment
/mob/living/simple_animal/hostile/spaceWorm/proc/Detach(var/die = 0)
	var/mob/living/simple_animal/hostile/spaceWorm/wormHead/newHead = new /mob/living/simple_animal/hostile/spaceWorm/wormHead(loc,0)
	var/mob/living/simple_animal/hostile/spaceWorm/newHeadPrev

	if(previousWorm)
		newHeadPrev = previousWorm

	previousWorm = null

	if(newHeadPrev)
		newHead.Attach(newHeadPrev)

	if(myHead)
		myHead.totalWormSegments -= src

	if(die)
		newHead.Die()

	qdel(src)


/mob/living/simple_animal/hostile/spaceWorm/Die()
	..()
	if(myHead)
		myHead.totalWormSegments -= src


//Process nom noms, things we've eaten have a chance to become plasma
/mob/living/simple_animal/hostile/spaceWorm/proc/ProcessStomach()
	for(var/atom/movable/stomachContent in contents)
		if(prob(digestionProbability))
			new /obj/item/stack/sheet/mineral/plasma(src, plasmaPoopPotential)
			qdel(stomachContent)

	if(previousWorm)
		for(var/atom/movable/stomachContent in contents) //move it along the digestive tract
			contents -= stomachContent
			previousWorm.contents += stomachContent
	else
		var/turf/T = get_turf(src)
		for(var/atom/movable/stomachContent in contents)
			contents -= stomachContent
			stomachContent.loc = T


//Looks weird otherwise.
/mob/living/simple_animal/hostile/spaceWorm/float(on)
	return


//Jiggle the whole worm forwards towards the next segment
/mob/living/simple_animal/hostile/spaceWorm/do_attack_animation(atom/A)
	..()
	if(previousWorm)
		previousWorm.do_attack_animation(src)