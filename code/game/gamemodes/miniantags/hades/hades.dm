#define STATE_JUDGE 0
#define STATE_WRATH 1
#define STATE_FLEE 2

/mob/living/simple_animal/hostile/hades
	name = "hades"
	real_name = "hades"
	desc = "A strange being, clad in dark robes. Their very presence radiates an uneasy power."
	speak_emote = list("preaches","announces","spits","conveys")
	emote_hear = list("hums.","prays.")
	response_help  = "kneels before"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/EvilPope.dmi'
	icon_state = "EvilPope"
	icon_living = "EvilPope"
	icon_dead = "popedeath"
	speed = 1
	a_intent = "harm"
	status_flags = CANPUSH
	attack_sound = 'sound/magic/MAGIC_MISSILE.ogg'
	death_sound = 'sound/magic/Teleport_diss.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("hades")
	attacktext = "strikes with an unholy rage at"
	maxHealth = 1000
	health = 1000
	healable = 0
	environment_smash = 3
	melee_damage_lower = 15
	melee_damage_upper = 20
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	loot = list(/obj/effect/decal/cleanable/blood)
	del_on_death = 0
	deathmessage = "begins to sizzle and pop, their flesh peeling away like paper."

	var/isDoingDeath = FALSE
	var/isFleeing = FALSE
	var/fleeTimes = 0
	var/currentState = STATE_JUDGE
	var/rageLevel = 0

	var/maxWrathTimer = 150
	var/lastWrathTimer = 0

	var/timeBetweenGrabs = 60
	var/lastGrabTime = 0

	var/list/validSins = list("Greed","Gluttony","Pride","Lust","Envy","Sloth","Wrath")
	var/lastsinPerson = 0
	var/sinPersonTime = 300
	var/lastFlee = 0
	var/fleeTimer = 30
	var/fakesinPersonChance = 60
	var/list/sinPersonsayings = list("You revel in only your own greed.",\
	"There is nothing but your absolution.",\
	"Your choices have led you to this.",\
	"There is only one way out.",\
	"The only way to be free is to be free of yourself.",\
	"Wallow in sin, and give yourself unto darkness.",\
	"Only the truly sinful may stand.",\
	"Find yourself and you will find Absolution.",\
	"Forego the pain of this process, and submit.",\
	"We can be one in suffering.",\
	"You stand on the precipice of ascension, give in.",\
	"You cannot fathom what lies beyond",\
	"Repent your sins.",\
	"This is the eve of your last days.",\
	"Darkness comes.")

	var/list/creepyasssounds = list('sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', \
								'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg',\
								'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
								'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg',\
								'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
								'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg')

	var/obj/effect/proc_holder/spell/targeted/lightning/sinLightning

	var/list/currentAcolytes = list()

/mob/living/simple_animal/hostile/hades/New()
	..()

	sinLightning = new/obj/effect/proc_holder/spell/targeted/lightning(src)

	sinLightning.charge_max = 1
	sinLightning.clothes_req = 0
	sinLightning.range = 32
	sinLightning.cooldown_min = 1

	lastsinPerson = world.time
	var/list/possible_titles = list("Pope","Bishop","Lord","Cardinal","Deacon","Pontiff")
	var/chosen = "Hades, [pick(possible_titles)] of Sin"
	name = chosen
	real_name = chosen

	world << "<span class='warning'><font size=4>[name] has entered your reality. Kneel before them.</font></span>"
	world << 'sound/effects/pope_entry.ogg'

	Appear(get_turf(src))

/mob/living/simple_animal/hostile/hades/handle_environment(datum/gas_mixture/environment)
	//space popes are from space, they need not your fickle "oxygen"
	return

/mob/living/simple_animal/hostile/hades/handle_temperature_damage()
	//space popes are from space, they don't uh.. something fire burny death
	return

/mob/living/simple_animal/hostile/hades/death(gibbed)
	if(!isDoingDeath)
		notransform = TRUE
		anchored = TRUE
		src.visible_message("<span class='warning'><font size=4>[src] begins to twist and distort, before snapping backwards with a sickening crunch.</font></span>")
		spawn(20)
			src.visible_message("<span class='warning'><font size=4>[src] is being sucked back to their own realm, destabilizing the fabric of time and space itself!</font></span>")
		playsound(get_turf(src), 'sound/effects/hyperspace_begin.ogg', 100, 1)
		isDoingDeath = TRUE
		AIStatus = AI_OFF
		SpinAnimation()
		for(var/i in 1 to 5)
			for(var/turf/T in spiral_range_turfs(i,src))
				addtimer(src, "sinShed", i*10, FALSE, T)
		spawn(60) // required to be spawn so we can call death's ..() to complete death.
			SpinAnimation(0,0)
			explosion(get_turf(src), 0, 2, 4, 6, flame_range = 6)
			..()
			var/area/A = locate(/area/hades) in world
			if(A)
				var/turf/T = get_turf(locate(/obj/effect/landmark/event_spawn) in A)
				if(T)
					src.visible_message("<span class='warning'><font size=4>[src]'s Staff is flung free as their body explodes.</font></span>")
					var/obj/structure/ladder/unbreakable/hades/churchLadder = new/obj/structure/ladder/unbreakable/hades(T)
					var/obj/structure/ladder/unbreakable/hades/bodyLadder = new/obj/structure/ladder/unbreakable/hades(get_turf(src))
					var/obj/item/weapon/hades_staff/HS = new/obj/item/weapon/hades_staff(get_turf(src))
					HS.throw_at_fast(pick(orange(src,7)),10,1)
					churchLadder.up = bodyLadder
					bodyLadder.down = churchLadder
					qdel(src)

/mob/living/simple_animal/hostile/hades/attackby(obj/item/I, mob/user, params)
	..()
	Defend(user,I)

/mob/living/simple_animal/hostile/hades/grabbedby(mob/living/carbon/user, supress_message = 0)
	..()
	Defend(user,user)

/mob/living/simple_animal/hostile/hades/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	..()
	lastsinPerson -= (sinPersonTime/4)
	if(istype(AM,/obj/item))
		var/obj/item/throwCast = AM
		Defend(throwCast.thrownby,AM)

/mob/living/simple_animal/hostile/hades/bullet_act(obj/item/projectile/P, def_zone)
	//don't call ..() because we're going to deflect it
	lastsinPerson -= (sinPersonTime/4)
	Defend(P.firer,P)
	return -1

/mob/living/simple_animal/hostile/hades/attack_hand(mob/living/carbon/human/M)
	..()
	lastsinPerson -= (sinPersonTime/4)
	Defend(M,M)

/mob/living/simple_animal/hostile/hades/proc/Defend(var/mob/attacker,var/source)
	if(!isDoingDeath)
		rageLevel += 5
		src.visible_message("<span class='warning'>[src] rounds on the [attacker], gazing at them with a [pick("cold","frosty","freezing","dark")] [pick("glare","gaze","glower","stare")].</span>")

		if(istype(source,/obj/item/projectile))
			src.visible_message("<span class='warning'>[src] [pick("calmly","silently","nonchalantly")] waves their hand, deflecting the [source].</span>")
			var/obj/item/projectile/P = source
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/turf/curloc = get_turf(src)

				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.current = curloc
				P.firer = src
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x
				P.Angle = null
		else
			if(prob(20))
				var/chosenDefend = rand(1,3)
				switch(chosenDefend)
					if(1)
						attacker.visible_message("<span class='warning'>[attacker] is lifted from the ground, shadowy powers tossing them aside.</span>")
						attacker.throw_at_fast(pick(orange(src,7)),10,1)
					if(2)
						attacker.visible_message("<span class='warning'>[attacker] crackles with electricity, a bolt leaping from [src] to them.</span>")
						sinLightning.Bolt(src,attacker,30,5,src)
					if(3)
						src.visible_message("<span class='warning'>[src] points his staff at [attacker], a swarm of eyeballs lurching fourth!</span>")
						for(var/i in 1 to 4)
							var/mob/living/simple_animal/hostile/carp/eyeball/E = new/mob/living/simple_animal/hostile/carp/eyeball(pick(orange(attacker,1)))
							E.faction = faction
							addtimer(E, "gib", 150, FALSE)

/mob/living/simple_animal/hostile/hades/proc/sinShed(var/turf/T)
	var/obj/effect/overlay/temp/cult/sparks/S = PoolOrNew(/obj/effect/overlay/temp/cult/sparks, T)
	S.anchored = FALSE
	S.throw_at_fast(src,10,1)
	PoolOrNew(/obj/effect/overlay/temp/hadesBlood, T)

/mob/living/simple_animal/hostile/hades/proc/Transfer(var/mob/living/taken, var/turf/transferTarget)
	if(transferTarget)
		playsound(get_turf(taken), 'sound/magic/Ethereal_Enter.ogg', 50, 1, -1)
		PoolOrNew(/obj/effect/overlay/temp/hadesFlick, get_turf(taken))
		taken.forceMove(transferTarget)
		Appear(get_turf(taken))

/mob/living/simple_animal/hostile/hades/proc/Appear(var/turf/where)
	var/obj/effect/timestop/hades/TS = new /obj/effect/timestop/hades(where)
	TS.immune = list(src)

/mob/living/simple_animal/hostile/hades/Life()
	if(..() && !isDoingDeath) // appropriately check if we're alive now we leave a corpse
		if(health > maxHealth/4 && !isFleeing)
			if(rageLevel > 50)
				lastWrathTimer = world.time
				currentState = STATE_WRATH
			else
				currentState = STATE_JUDGE
		else
			if(world.time > lastFlee + fleeTimer)
				lastFlee = world.time
				isFleeing = TRUE
				currentState = STATE_FLEE

		var/area/healthCheck = get_area(src)

		if(istype(healthCheck,/area/chapel/main))
			if(currentState == STATE_FLEE)
				lastWrathTimer = world.time
				currentState = STATE_WRATH
			if(health < maxHealth/2)
				health += 10 // slowly regain hp in the chapel, up to a maximum of half our max

		var/spokenThisTurn = FALSE
		for(var/mob/living/A in currentAcolytes)
			if(!A)
				currentAcolytes -= A
				continue
			if(A.health <= 0)
				rageLevel += 5
				if(!spokenThisTurn)
					spokenThisTurn = TRUE
					var/list/lossSayings = list("They were weak.","For every death, two more rise.",\
					"What is but one servant lost?","Darkness engulf you!","To the Pit with them.",\
					"Fools! All of you!","You can't stop me. You. Will. Be. JUDGED.")
					src.say(pick(lossSayings))
					currentAcolytes -= A
					A.gib()

		if(currentState == STATE_WRATH) // we have been enraged.
			if(world.time > lastWrathTimer + maxWrathTimer)
				rageLevel = 0 // wind down if we're wrathful too long.
			rageLevel -= 1 // rage phase starts at 50, meaning roughly 20s of rage.
			if(currentAcolytes.len == 0)
				src.say("Rise, Servants. AID YOUR MASTER.")
				playsound(get_turf(src), 'sound/magic/CastSummon.ogg', 100, 1)
				for(var/i in 1 to 5)
					var/mob/living/simple_animal/hostile/hadesacolyte/HA = new/mob/living/simple_animal/hostile/hadesacolyte(get_turf(pick(orange(2,src))))
					HA.master = src
					currentAcolytes += HA
			if(target)
				if(world.time > lastGrabTime + timeBetweenGrabs)
					if(get_dist(src,target) > 4) // you can't run from us. upped to 4 to give more leeway.
						lastGrabTime = world.time
						var/list/fleeSayings = list("There is no escape from your sins, [target]","Fleeing will only make your punishment worse [target]!",\
						"There is nowhere you can hide, [target]!","You can't run, [target]!","Get back here, [target]!","You coward, [target]!",\
						"I will find you, [target]!","Return to me, [target]!")
						src.say(pick(fleeSayings))
						var/mob/living/toGrab = target
						toGrab.Beam(src,"blood",'icons/effects/beam.dmi',10)
						toGrab.Weaken(6)
						playsound(get_turf(src), 'sound/magic/CastSummon.ogg', 100, 1)
						toGrab.throw_at_fast(src,10,1)
			if(rageLevel >= 100)
				rageLevel = 50
				var/list/overboardSayings = list("Ashes! It will all be ashes!","I will bring about the apocolypse!",\
				"There will be nothing but your withered husks!","Face your doom, cretins!","There. Will. Be. ORDER!",\
				"I am your Lord, lay down your arms and submit.","Your souls will be cremated!",\
				"Only in death will you obey!","This is no person's fault but your own!")
				src.say(pick(overboardSayings))
				var/turf/StartLoc = get_turf(src)
				var/list/nearby = orange(6,src)
				var/slashCount = 0
				var/aoeType = rand(1,2) // just for future proofing
				for(var/mob/living/A in nearby)
					slashCount++
					A.Beam(src,"blood",'icons/effects/beam.dmi',10)
					spawn(slashCount + 3)
						if(aoeType == 1)
							// no more cheaping it out with non-player mobs like turrets or carps
							loc = get_turf(A)
							sinShed(StartLoc)
							A.attack_animal(src)
							PoolOrNew(/obj/effect/overlay/temp/hadesBlood,get_turf(A))
							playsound(get_turf(A), 'sound/magic/SummonItems_generic.ogg', 100, 1)
						if(aoeType == 2)
							sinShed(StartLoc)
							PoolOrNew(/obj/effect/overlay/temp/hadesBite,get_turf(A))
							A.Weaken(6)
				var/obj/effect/timestop/hades/large/TS = new /obj/effect/timestop/hades/large(StartLoc)
				TS.immune = list(src)
				spawn((slashCount+1)+3)
					loc = StartLoc

		if(currentState == STATE_FLEE) // we've been wounded, let us flee and lick our wounds
			var/area/A = locate(/area/chapel/main) in world
			if(A)
				var/turf/T = get_turf(locate(/obj/effect/landmark/event_spawn) in A)
				if(!T)
					T = get_turf(src) // no event spawn in chapel, fall back to doing it on the spot.
				if(T)
					fleeTimes++
					Transfer(src,T)
					AIStatus = AI_OFF
					notransform = TRUE
					anchored = TRUE
					for(var/i in 1 to 5)
						spawn(i*10)
							for(var/turf/S in oview(i,src) - oview((i)-1,src))
								sinShed(S)
							health += maxHealth/(10*fleeTimes) // every flee we gain less HP
					spawn(50)
						isFleeing = FALSE
						notransform = FALSE
						anchored = FALSE
						AIStatus = AI_ON
						currentState = STATE_JUDGE
						lastsinPerson = 0 // immediately teleport away to judge

		if(currentState == STATE_JUDGE) // our default state, judge a few people and tell them they're rude or something
			if(world.time > lastsinPerson + sinPersonTime)
				if(prob(fakesinPersonChance))
					lastsinPerson = world.time
					visible_message("<span class='warning'><font size=3>[pick(sinPersonsayings)]</font></span>")
					playsound(get_turf(src), pick(creepyasssounds), 100, 1)
				else
					lastsinPerson = world.time
					var/mob/living/carbon/human/sinPerson = pick(living_mob_list)
					var/depth = living_mob_list.len + 1 // just in case
					if(sinPerson) // no more finding nullcakes
						if(!sinPerson.ckey)
							while(!sinPerson.ckey && depth > 0)
								--depth
								var/checkPerson = pick(living_mob_list)
								if(checkPerson)
									sinPerson = checkPerson
						if(!sinPerson || !sinPerson.ckey)
							// double check ensure that if the above loop fails to get a ckey target
							// we don't go and use the last mob checked, causing odd situations
							return

						if(prob(65)) // moderately high chance for us to go to them, else they come here.
							Transfer(src,get_turf(pick(oview(1,sinPerson))))
						else
							Transfer(sinPerson,get_turf(pick(oview(1,src))))

						var/sinPersonchoice = pick(validSins)

						src.say("Your sin, [sinPerson], is [sinPersonchoice].")
						var/isIndulged = prob(50)
						if(isIndulged)
							src.say("I will indulge your sin, [sinPerson].")
						else
							src.say("Your sin will be punished, [sinPerson]!")

						switch(sinPersonchoice)
							if("Greed")
								sin_Greed(sinPerson, isIndulged)
							if("Gluttony")
								sin_Gluttony(sinPerson, isIndulged)
							if("Pride")
								sin_Pride(sinPerson, isIndulged)
							if("Lust")
								sin_Lust(sinPerson, isIndulged)
							if("Envy")
								sin_Envy(sinPerson, isIndulged)
							if("Sloth")
								sin_Sloth(sinPerson, isIndulged)
							if("Wrath")
								sin_Wrath(sinPerson, isIndulged)


///Sin related things

//global Sin procs, shared between staff and pope

/proc/sin_Greed(var/mob/living/carbon/human/sinPerson, var/isIndulged)
	if(isIndulged)
		sinPerson << "<span class='warning'>You feel like you deserve more, in fact, you want everything.</span>"
		var/list/greed = list(/obj/item/stack/sheet/mineral/gold,/obj/item/stack/sheet/mineral/silver,/obj/item/stack/sheet/mineral/diamond)
		for(var/i in 1 to 10)
			var/greed_type = pick(greed)
			new greed_type(get_turf(sinPerson))
	else
		sinPerson << "<span class='warning'>Your body begins to shift and bend, changing to reflect your inner greed.</span>"
		var/mob/living/M = sinPerson.change_mob_type(/mob/living/simple_animal/cockroach,get_turf(sinPerson),"Greedroach",1)
		M.AddSpell(new/obj/effect/proc_holder/spell/targeted/mind_transfer)

/proc/sin_Gluttony(var/mob/living/carbon/human/sinPerson, var/isIndulged)
	if(isIndulged)
		sinPerson << "<span class='warning'>Your stomach growls, you feel hungry.</span>"
		var/list/allTypes = list()
		for(var/A in typesof(/obj/item/weapon/reagent_containers/food/snacks))
			var/obj/item/weapon/reagent_containers/food/snacks/O = A
			if(initial(O.cooked_type))
				allTypes += A
		for(var/i in 1 to 10)
			var/greed_type = pick(allTypes)
			new greed_type(get_turf(sinPerson))
	else
		sinPerson << "<span class='warning'>Your body begins to bloat and stretch, bile rising in your throat.</span>"
		sinPerson.reagents.add_reagent("nutriment",1000)

/proc/sin_Pride(var/mob/living/carbon/human/sinPerson, var/isIndulged)
	var/obj/item/weapon/twohanded/sin_pride/pride_hammer = new(get_turf(sinPerson))
	pride_hammer.pride_direction = !isIndulged

	if(isIndulged)
		sinPerson << "<span class='warning'>You feel strong enough to take on the world.</span>"
		pride_hammer.name = "Indulged [pride_hammer.name]"
	else
		sinPerson << "<span class='warning'>You feel small and weak, like the entire world is against you.</span>"
		pride_hammer.name = "Punished [pride_hammer.name]"

/proc/sin_Lust(var/mob/living/carbon/human/sinPerson, var/isIndulged)
	var/obj/item/lovestone/lovestone = new(get_turf(sinPerson))
	lovestone.lust_direction = !isIndulged

	if(isIndulged)
		sinPerson << "<span class='warning'>You feel confident, like everything and everyone is drawn to you.</span>"
		lovestone.name = "Indulged [lovestone.name]"
	else
		sinPerson << "<span class='warning'>You feel lonely... the wish for the warmth of another spark through your mind.</span>"
		lovestone.name = "Punished [lovestone.name]"

/proc/sin_Envy(var/mob/living/carbon/human/sinPerson, var/isIndulged)
	if(isIndulged)
		for(var/mob/living/carbon/human/H in player_list) // name lottery
			if(H == sinPerson)
				continue
			if(prob(25))
				sinPerson.name = H.name
				sinPerson.real_name = H.real_name
				var/datum/dna/lottery = H.dna
				lottery.transfer_identity(sinPerson, transfer_SE=1)
				sinPerson.updateappearance(mutcolor_update=1)
				sinPerson.domutcheck()
		sinPerson << "<span class='warning'>You feel envious of [sinPerson.name], and your body shifts to reflect that!</span>"
	else
		var/sinPersonspecies = pick(species_list)
		var/newtype = species_list[sinPersonspecies]
		sinPerson << "<span class='warning'>You wish for more from yourself.. your body shifts to suit your wish.</span>"
		sinPerson.set_species(newtype)

/proc/sin_Sloth(var/mob/living/carbon/human/sinPerson, var/isIndulged)
	if(isIndulged)
		sinPerson << "<span class='warning'>You feel tired...</span>"
		sinPerson.drowsyness += 100
	else
		sinPerson << "<span class='warning'>A chill comes over your body, the feeling of frostbite nipping at your fingers.</span>"
		sinPerson.reagents.add_reagent("frostoil", 50)

/proc/sin_Wrath(var/mob/living/carbon/human/sinPerson, var/isIndulged)
	if(isIndulged)
		sinPerson << "<span class='warning'>You feel wrathful, like you want to destroy everyone and everything.</span>"
		sinPerson.change_mob_type(/mob/living/simple_animal/slaughter,get_turf(sinPerson),"Wrath Demon",1)
	else
		sinPerson << "<span class='warning'>Your chest feels tight, and the world begins to spin around you.</span>"
		sinPerson.reagents.add_reagent("lexorin", 29)
		sinPerson.reagents.add_reagent("mindbreaker", 29)

/obj/effect/overlay/temp/hadesFlick
	name = "transdimensional waste"
	icon = 'icons/mob/mob.dmi'
	icon_state = "liquify"
	duration = 15

/obj/effect/overlay/temp/hadesBite
	name = "biting tendril"
	icon = 'icons/effects/effects.dmi'
	icon_state = "tendril_bite"
	duration = 15

/obj/effect/overlay/temp/hadesBlood
	name = "blood plume"
	icon = 'icons/effects/128x128.dmi'
	icon_state = "spray_plume"
	duration = 30

/obj/effect/timestop/hades // custom timeslip to make him immune
	name = "Frozen Time"
	desc = "Time has slowed to a halt."

/obj/effect/timestop/hades/New()
	spawn(5)
		..()

/obj/effect/timestop/hades/large
	freezerange = 6
	icon_state = "huge_rune"
	icon = 'icons/effects/224x224.dmi'


/obj/item/weapon/twohanded/sin_pride
	icon_state = "mjollnir0"
	name = "Pride-struck Hammer"
	desc = "It resonates an aura of Pride."
	force = 5
	throwforce = 15
	w_class = 4
	slot_flags = SLOT_BACK
	force_unwielded = 5
	force_wielded = 20
	attack_verb = list("attacked", "smashed", "crushed", "splattered", "cracked")
	hitsound = 'sound/weapons/blade1.ogg'
	var/pride_direction = FALSE

/obj/item/weapon/twohanded/sin_pride/update_icon()
	icon_state = "mjollnir[wielded]"
	return

/obj/item/weapon/twohanded/sin_pride/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	if(!proximity) return
	if(wielded)
		if(istype(A,/mob/living/carbon/human))
			var/mob/living/carbon/H = A
			var/mob/living/carbon/U = user
			if(H)
				if(pride_direction == FALSE)
					U.reagents.trans_to(H, user.reagents.total_volume, 1, 1, 0)
					U << "Your pride reflects on [H]."
					if(H.health > 0)
						U.health += force
						U.updatehealth()
						H.health -= force
						H.updatehealth()
					H << "You feel insecure, taking on [user]'s burden."
				else if(pride_direction == TRUE)
					H.reagents.trans_to(user, H.reagents.total_volume, 1, 1, 0)
					H << "Your pride reflects on [user]."
					if(U.health > 0)
						U.health -= force
						U.updatehealth()
						H.health += force
						H.updatehealth()
					U << "You feel insecure, taking on [H]'s burden."

/obj/item/lovestone
	name = "Stone of Lust"
	desc = "It lays within your hand, radiating pulses of uncomfortable warmth."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "lovestone"
	item_state = "lovestone"
	w_class = 1
	var/lust_direction = FALSE
	var/lastUsage = 0
	var/usageTimer = 300

/obj/item/lovestone/attack_self(mob/user)
	if(world.time > lastUsage + usageTimer)
		lastUsage = world.time
		user.visible_message("<span class='warning'>[user] grips the [src] tightly, causing it to vibrate and pulse brightly.</span>")
		spawn(25)
			if(lust_direction == FALSE)
				var/list/throwAt = list()
				for(var/atom/movable/AM in oview(7,user))
					if(!AM.anchored && AM != user)
						throwAt.Add(AM)
				for(var/counter = 1, counter < throwAt.len, ++counter)
					var/atom/movable/cast = throwAt[counter]
					cast.throw_at_fast(user,10,1)
			else if(lust_direction == 1)
				var/mob/living/carbon/human/H = user
				var/mob/living/carbon/human/foundLover = locate(/mob/living/carbon/human) in orange(3,H)
				if(!foundLover)
					H << "As you hold the stone, loneliness grips you, your heart feeling heavy and you struggle to breath."
					for(var/i in 1 to 10)
						addtimer(H.reagents, "add_reagent", i*10, FALSE, "initropidril", i)
				else
					H << "You take comfort in the presence of [foundLover]"
					H.reagents.add_reagent("omnizine",25)
					H.Beam(foundLover,"r_beam",'icons/effects/beam.dmi',10)
					foundLover << "You take comfort in the presence of [H]"
					foundLover.reagents.add_reagent("omnizine",25)
	else
		user << "The stone lays inert. It is still recharging."

/mob/living/simple_animal/hostile/hadesacolyte
	name = "Acolyte of Hades"
	desc = "Darkness seethes from their every pore."
	icon_state = "hades_acolyte"
	icon_living = "hades_acolyte"
	icon_dead = "hades_acolyte_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "trembles in fear of"
	response_disarm = "slaps wildly at"
	response_harm = "hits"
	speed = 1
	maxHealth = 45
	health = 45

	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "strikes at"
	attack_sound = 'sound/weapons/bladeslice.ogg'

	butcher_results = list(/obj/item/clothing/mask/gas/cyborg/hades = 1,/obj/item/clothing/suit/hooded/chaplain_hoodie/hades = 1,/obj/item/weapon/hades_staff/fake = 1)

	unsuitable_atmos_damage = 0
	del_on_death = 0
	faction = list("hades")

	var/mob/living/simple_animal/hostile/hades/master

/mob/living/simple_animal/hostile/hadesacolyte/Life()
	if(..())
		if(master)
			if(get_dist(src,master) > 5)
				PoolOrNew(/obj/effect/overlay/temp/hadesFlick,get_turf(src))
				src.visible_message("<span class='warning'>[src] twists and distorts, before vanishing in a snap.</span>")
				src.forceMove(get_turf(pick(orange(2,master))))

//acolyte of hades outfit
/obj/item/clothing/mask/gas/cyborg/hades
	name = "Skull Mask"
	desc = "It's a skull mask, made of a thin, cool metal."

/obj/item/clothing/suit/hooded/chaplain_hoodie/hades
	name = "Dark robes"
	desc = "A dark, soft robe."
	hooded = 1
	hoodtype = /obj/item/clothing/head/chaplain_hood/hades

/obj/item/clothing/head/chaplain_hood/hades
	name = "Dark hood"
	desc = "A dark, soft hood."
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS
//end hades outfit

/obj/item/hades_summoner
	name = "Dark Seed"
	desc = "The stone lays inert, but even when holding it you hear maddened whispers."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "dark_seed_inert"
	item_state = "dark_seed_inert"
	w_class = 1
	var/isActivated = FALSE
	var/whoActivated
	var/countDownToSummon = 10
	var/absorbedHP = 0

/obj/item/hades_summoner/attack_self(mob/user)
	if(!isActivated)
		var/choice = input(user,"Rub the stone?",name) in list("Yes","No")
		if(choice == "Yes")
			if(prob(15))
				user << "<span class='warning'><font size=3>You rub the stone.. and a voice springs fourth!</font></span>"
				user << "<span class='warning'><font size=3>You hear a voice in your head.. 'Bring me the flesh of a living being.. and we shall bargain.'</font></span>"
				whoActivated = user
				isActivated = TRUE
				desc = "The stone hums with a soft glow, whispering to you."
				icon_state = "dark_seed"
			else
				user << "<span class='warning'><font size=3>The stone shivers, but nothing happens. Perhaps try again later?</font></span>"
	else
		if(user != whoActivated)
			user << "<span class='warning'><font size=3>The stone lays inert.</font></span>"
		else
			if(countDownToSummon > 0)
				user << "<span class='warning'><font size=3>You hear a voice in your head.. 'I still require [countDownToSummon] vessels worth of flesh. Bring them to me'</font></span>"
			else
				user << "<span class='warning'><font size=3>I thank you, acolyte.</font></span>"
				var/mob/living/simple_animal/hostile/hadesacolyte/HA = user.change_mob_type(/mob/living/simple_animal/hostile/hadesacolyte,get_turf(user),"[user.name]",1)
				var/mob/living/simple_animal/hostile/hades/H = new/mob/living/simple_animal/hostile/hades(get_turf(user))
				H.maxHealth = absorbedHP
				H.health = H.maxHealth
				if(H.maxHealth < initial(H.maxHealth))
					HA << "<span class='warning'><font size=3>You.. you fool! How dare you summon me with such dirty flesh!</font></span>"
					HA.faction -= "hades"
				if(H.maxHealth > initial(H.maxHealth))
					HA << "<span class='warning'><font size=3>Such.. power! You have exceeded yourself, acolyte. Drink of my might!</font></span>"
					HA.maxHealth = 250
					HA.health = 250
				qdel(src)

/obj/item/hades_summoner/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	if(!proximity)
		return
	if(istype(A,/mob/living))
		var/mob/living/M = A
		if(countDownToSummon > 0)
			if(M.health > 0 && M.maxHealth > 200)
				// no absorbing super strong creatures unless they're dead
				user << "<span class='warning'><font size=3>Such power.. Slay this [M] so that I may partake of its being.</font></span>"
				return
			user << "<span class='warning'><font size=3>I accept your offering.</font></span>"
			absorbedHP += M.maxHealth
			if(!M.ckey)
				M.gib()
			else
				M << "<span class='warning'><font size=3>You feel the flesh being stripped from your bones. You're overwhelmed with maddening pain, before reforming into another being!</font></span>"
				M.change_mob_type(/mob/living/simple_animal/hostile/hadesacolyte,get_turf(user),"[user.name]",1)
			countDownToSummon--
			if(countDownToSummon <= 0)
				user << "<span class='warning'><font size=3>I am ready to ascend, my acolyte.</font></span>"


#undef STATE_JUDGE
#undef STATE_WRATH
#undef STATE_FLEE
