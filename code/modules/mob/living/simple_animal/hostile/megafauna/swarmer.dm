#define MEDAL_PREFIX "Swarmer Beacon"
#define TOO_MANY_SWARMERS_BEACON	10 //If there's this many swarmers, the beacon won't repopulate them
#define TOO_MANY_SWARMERS 50 //Cap of AI swarmers, no reproduction past this number


/*

Swarmer Beacon

A strange machine appears anywhere a normal lavaland mob can it produces a swarmer at a rate of
1/15 seconds, until there are 10 swarmers, after this it is up to the swarmers themselves to
increase their population (should they fall under 10, the machine will continue to repopulate back up to 10)

tl;dr A million of the little hellraisers spawn (controlled by AI) and try to eat mining

Loot: Not much, besides a shit load of artificial bluespace crystals, Oh and mining doesn't get eaten
that's a plus I suppose.

Difficulty: Special

*/

var/global/list/mob/living/simple_animal/hostile/swarmer/ai/AISwarmerMobs = list()

/mob/living/simple_animal/hostile/megafauna/swarmer_swarm_beacon
	name = "swarmer beacon"
	desc = "That name is a bit of a mouthful, but stop paying attention to your mouth they're eating everything!"
	icon = 'icons/mob/swarmer.dmi'
	icon_state = "swarmer_console"
	health = 2000
	maxHealth = 2000 //low-ish HP because it's a passive boss, and the swarm itself is the real foe
	medal_type = MEDAL_PREFIX
	score_type = SWARMER_BEACON_SCORE
	faction = list("mining", "boss", "swarmer")
	weather_immunities = list("lava","ash")
	canmove = FALSE
	wander = FALSE
	anchored = TRUE
	var/swarmer_spawn_cooldown = 0
	var/swarmer_spawn_cooldown_amt = 150 //Deciseconds between the swarmers we spawn


/mob/living/simple_animal/hostile/megafauna/swarmer_swarm_beacon/New()
	..()
	internal = new/obj/item/device/gps/internal/swarmer_beacon(src)
	for(var/ddir in cardinal)
		new /obj/structure/swarmer/blockade (get_step(src, ddir))


/mob/living/simple_animal/hostile/megafauna/swarmer_swarm_beacon/handle_automated_action()
	. = ..()
	if(.)
		if(AISwarmerMobs.len < TOO_MANY_SWARMERS_BEACON && world.time > swarmer_spawn_cooldown)
			swarmer_spawn_cooldown = world.time + swarmer_spawn_cooldown_amt
			new /mob/living/simple_animal/hostile/swarmer/ai(loc)


/obj/item/device/gps/internal/swarmer_beacon
	icon_state = null
	gpstag = "Hungry Signal"
	desc = "Transmited over the signal is a strange message repeated in every language you know of, and some you don't too..." //the message is "nom nom nom"
	invisibility = 100


//AI versions of the swarmer mini-antag
/mob/living/simple_animal/hostile/swarmer/ai
	wander = 1
	faction = list("swarmer", "mining")
	weather_immunities = list("ash") //wouldn't be fun otherwise
	AIStatus = AI_ON
	created_shell_type = /mob/living/simple_animal/hostile/swarmer/ai
	search_objects = 2
	attack_all_objects = TRUE //attempt to nibble everything
	lose_patience_timeout = 110 //11 seconds, just enough to pass DismantleMachine() do_after()s, but not too slow either
	var/static/list/sharedWanted = list(/turf/closed/mineral, /turf/closed/wall) //eat rocks and walls
	var/static/list/sharedIgnore = list()


/mob/living/simple_animal/hostile/swarmer/ai/New()
	..()
	ToggleLight() //so you can see them eating you out of house and home
	AISwarmerMobs += src
	sharedWanted = typecacheof(sharedWanted)
	sharedIgnore = typecacheof(sharedIgnore)


/mob/living/simple_animal/hostile/swarmer/ai/Destroy()
	AISwarmerMobs -= src
	return ..()


//This handles viable things to attack/eat
//Place specific cases of AI derpiness here
//Most can be left to the automatic Gain/LosePatience() system
/mob/living/simple_animal/hostile/swarmer/ai/CanAttack(atom/the_target)

	//SPECIFIC CASES:

	//Smash fulltile windows before grilles
	if(istype(the_target, /obj/structure/grille))
		for(var/obj/structure/window/rogueWindow in get_turf(the_target))
			if(rogueWindow.fulltile) //done this way because the subtypes are weird.
				the_target = rogueWindow
				break


	//GENERAL CASES:
	if(is_type_in_typecache(the_target, sharedIgnore)) //always ignore
		return FALSE
	if(is_type_in_typecache(the_target, sharedWanted)) //always eat
		return TRUE

	return ..()	//else, have a nibble, see if it's food


/mob/living/simple_animal/hostile/swarmer/ai/OpenFire(atom/A)
	if(isliving(A)) //don't shoot rocks, sillies.
		..()


/mob/living/simple_animal/hostile/swarmer/ai/AttackingTarget()
	if(target.swarmer_act(src))
		add_type_to_wanted(target.type)
	else
		add_type_to_ignore(target.type)


/mob/living/simple_animal/hostile/swarmer/ai/handle_automated_action()
	. = ..()
	if(.)
		if(!stop_automated_movement)
			if(AISwarmerMobs.len < TOO_MANY_SWARMERS && resources > 50)
				StartAction(100) //so they'll actually sit still and use the verbs
				CreateSwarmer()
				return

			if(resources > 5)
				if(prob(5)) //lower odds, as to prioritise reproduction
					StartAction(10) //not a typo
					CreateBarricade()
					return
				if(prob(5))
					CreateTrap()
					return

			if(health < maxHealth*0.25)
				StartAction(100)
				RepairSelf()
				return


/mob/living/simple_animal/hostile/swarmer/ai/proc/StartAction(deci = 0)
	stop_automated_movement = TRUE
	addtimer(src, "EndAction", deci, FALSE)


/mob/living/simple_animal/hostile/swarmer/ai/proc/EndAction()
	stop_automated_movement = FALSE


//So swarmers can learn what is and isn't food
/mob/living/simple_animal/hostile/swarmer/ai/proc/add_type_to_wanted(typepath)
	LAZYINITLIST(sharedWanted)
	if(!sharedWanted[typepath])// this and += is faster than |=
		sharedWanted += typecacheof(typepath)


/mob/living/simple_animal/hostile/swarmer/ai/proc/add_type_to_ignore(typepath)
	LAZYINITLIST(sharedIgnore)
	if(!sharedIgnore[typepath])
		sharedIgnore += typecacheof(typepath)


/mob/living/simple_animal/hostile/swarmer/ai/Move(atom/newloc)
	if(newloc)
		if(newloc.z == z) //so these actions are Z-specific
			if(istype(newloc, /turf/open/floor/plating/lava))
				var/turf/open/floor/plating/lava/L = newloc
				if(!L.is_safe())
					StartAction(20)
					new /obj/structure/lattice/catwalk/swarmer_catwalk(newloc)
					return FALSE

			if(istype(newloc, /turf/open/chasm) && !throwing)
				throw_at_fast(get_edge_target_turf(src, get_dir(src, newloc)), 7 , 3, spin = FALSE) //my planet needs me
				return FALSE

		return ..()




//Used so they can survive lavaland better
/obj/structure/lattice/catwalk/swarmer_catwalk
	name = "swarmer catwalk"
	desc = "a catwalk-like mesh, produced by swarmers to allow them to navigate hostile terrain."
	icon = 'icons/obj/smooth_structures/swarmer_catwalk.dmi'
	icon_state = "swarmer_catwalk"



#undef MEDAL_PREFIX
#undef TOO_MANY_SWARMERS_BEACON
#undef TOO_MANY_SWARMERS

