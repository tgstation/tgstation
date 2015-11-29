//////////////////////////////////based on the original game by Hudson Soft
//Spess Bomberman, by Deity Link//
//////////////////////////////////

#define MAX_BOMB_POWER 16	//How far will the largest explosions reach.
#define MAX_SPEED_BONUS 10	//How fast can a player get by cumulating skates (his tally cannot exceed -1 anyway, but additional skates will allow him to stay fast while starving for example)

/*
////content://///
* BOMB DISPENSER	/obj/item/weapon/bomberman/
* BOMB				/obj/structure/bomberman
* FLAME/EXPLOSION	/obj/structure/bomberflame
* SOFT WALLS		/obj/structure/softwall
* HARD WALLS		/turf/unsimulated/wall/bomberman
* POWER-UPS			/obj/structure/powerup
* CLOTHING			/obj/item/clothing/suit/space/bomberman  AND /obj/item/clothing/head/helmet/space/bomberman


* ARENA BUILDER		/datum/bomberman_arena
* New()
* open()
* spawn_player()
* dress_player()
* start()
* reset()
* close()
* planner()

*/

///////////////////////////////BOMB DISPENSER//////////////////////////
var/global/list/bombermangear = list()
/obj/item/weapon/bomberman/
	name = "Bomberman's Bomb Dispenser"
	desc = "Now to not get yourself stuck in a corner."
	w_class = 5.0
	icon = 'icons/obj/bomberman.dmi'
	icon_state = "dispenser"
	var/bomblimit = 1	//how many bombs are currently in the dispenser
	var/bombtotal = 1	//how many bombs can this dispenser sustain in the world at once
	var/bombpower = 1	//how many tiles do the fire columns reach
	var/can_kick = 0	//allows its holder to kick bombs. kicked bombs roll until their reach an obstacle or detonate
	var/can_line = 0	//allows its user to deploy all his bombs in a line at once
	var/has_power = 0	//if this dispenser currently has no bombs in the world, its next bomb will have maximum power
	var/skate = 0
	var/speed_bonus = 0	//each skate power-up will speed-up its user. whoever holds the dispenser has the bonus.

	//griff modifiers, can be changed globaly with admin commands
	var/destroy_environnement = 0	//does it break wall/tables/closets
	var/hurt_players = 0	//damage dealt by the bombs to mobs

	//disease modifiers
	var/slow = 0
	var/fast = 0
	var/small_bomb = 0
	var/no_bomb = 0
	var/spam_bomb = 0

	var/datum/bomberman_arena/arena = null


/obj/item/weapon/bomberman/New()
	..()
	if(bomberman_hurt)
		hurt_players = 1
	if(bomberman_destroy)
		destroy_environnement = 1
	bombermangear += src

/obj/item/weapon/bomberman/Destroy()
	..()
	bombermangear -= src
	arena = null

/obj/item/weapon/bomberman/attack_self(mob/user)
	var/turf/T = get_turf(src)
	if(bomblimit && !no_bomb)
		var/power = bombpower
		if(small_bomb)
			power = 1
		if(!(locate(/obj/structure/bomberman) in T))
			playsound(T, 'sound/bomberman/bombplace.ogg', 50, 1)
			if(has_power && (bomblimit == bombtotal))
				bomblimit--
				new /obj/structure/bomberman/power(T, power, destroy_environnement, hurt_players, src)
			else
				bomblimit--
				new /obj/structure/bomberman(T, power, destroy_environnement, hurt_players, src)
		else if(can_line)
			playsound(T, 'sound/bomberman/bombplace.ogg', 50, 1)
			bomblimit--
			new /obj/structure/bomberman(T, power, destroy_environnement, hurt_players, src, user.dir)

/obj/item/weapon/bomberman/proc/cure(var/disease)
	spawn(400)
		switch(disease)
			if("Low Power Disease")
				small_bomb = 0
			if("Constipation")
				no_bomb = 0
			if("Diarrhea")
				spam_bomb = 0
			if("Slow Pace Disease")
				slow = 0
			if("Rapid Pace Disease")
				fast = 0
				speed_bonus = skate

/obj/item/weapon/bomberman/proc/lost()
	if(arena)
		arena.tools -= src
		spawn()	//we're not waiting for the arena to close to despawn the BBD
			arena.end()
	var/list/turfs = list()
	for(var/turf/T in range(loc,1))
		if(!T.density)
			turfs += T
	while(skate > 0)
		new/obj/structure/powerup/skate(pick(turfs))
		skate--
	while(bombtotal > 1)
		new/obj/structure/powerup/bombup(pick(turfs))
		bombtotal--
	while(bombpower > 1)
		new/obj/structure/powerup/fire(pick(turfs))
		bombpower--
	if(can_kick)
		new/obj/structure/powerup/kick(pick(turfs))
	if(can_line)
		new/obj/structure/powerup/line(pick(turfs))
	if(has_power)
		new/obj/structure/powerup/power(pick(turfs))
	qdel(src)

///////////////////////////////BOMB////////////////////////////////////
/obj/structure/bomberman
	name = "bomb"
	desc = "Tick, Tick, Tick!"
	icon = 'icons/obj/bomberman.dmi'
	icon_state = "bomb"
	density = 1
	anchored = 1
	var/bombpower = 1
	var/destroy_environnement = 0
	var/hurt_players = 0

	var/obj/item/weapon/bomberman/parent = null

	var/countdown = 3
	var/kicked = 0

/obj/structure/bomberman/power/
	icon_state = "bomb_power"

/obj/structure/bomberman/New(turf/loc, var/Bpower=1, var/destroy=0, var/hurt=0, var/dispenser=null, var/line_dir=null)
	..()
	bombpower = Bpower
	destroy_environnement = destroy
	hurt_players = hurt
	parent = dispenser
	bombermangear += src

	if((!parent || !parent.arena) && bomberman_hurt)
		hurt_players = 1
	if((!parent || !parent.arena) && bomberman_destroy)
		destroy_environnement = 1


	if(line_dir)
		var/turf/T1 = get_turf(src)
		step(src,line_dir)
		var/turf/T2 = get_turf(src)
		if(T1 == T2)
			qdel(src)
		else if(parent.bomblimit > 0)
			parent.bomblimit--
			new /obj/structure/bomberman(T2, bombpower, destroy_environnement, hurt_players, parent, line_dir)
	ticking()



/obj/structure/bomberman/Bump(atom/obstacle)
	kicked = 0
	..()

/obj/structure/bomberman/Bumped(M as mob|obj)	//kick bomb
	for (var/obj/item/weapon/bomberman/dispenser in M)
		if (dispenser.can_kick && !kicked)
			kicked = 1
			kicked(get_dir(M,src))
	..()

/obj/structure/bomberman/proc/ticking()
	countdown--
	sleep(10)
	if(countdown <= 0)
		detonate()
	else
		ticking()

/obj/structure/bomberman/proc/detonate()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/bomberman/bombexplode.ogg', 100, 1)
	spawn()
		new /obj/structure/bomberflame(T,1,bombpower,SOUTH,destroy_environnement,hurt_players)
	qdel(src)

/obj/structure/bomberman/power/detonate()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/bomberman/bombexplode.ogg', 100, 1)
	spawn()
		new /obj/structure/bomberflame(T,1,MAX_BOMB_POWER,SOUTH,destroy_environnement,hurt_players)
	qdel(src)

/obj/structure/bomberman/proc/kicked(var/kick_dir)
	var/turf/T1 = get_turf(src)
	step(src, kick_dir)
	var/turf/T2 = get_turf(src)
	if(locate(/obj/structure/bomberflame) in T2)	//if a kicked bomb rolls into an explosion, it detonates
		detonate()
	if(T1 != T2)
		sleep(2)
		kicked(kick_dir)
	else
		kicked = 0


/obj/structure/bomberman/Destroy()
	if(parent)
		parent.bomblimit++
	bombermangear -= src
	..()

/obj/structure/bomberman/emp_act(severity)	//EMPs can safely remove the bombs
	qdel(src)
	return

/obj/structure/bomberman/bullet_act(var/obj/item/projectile/Proj)
	visible_message("<span class='warning'>\The [Proj] hits \the [src].</span>")
	detonate()
	return

/obj/structure/bomberman/ex_act(severity)
	detonate()
	return

/obj/structure/bomberman/cultify()
	return

/obj/structure/bomberman/singuloCanEat()
	return 0

///////////////////////////////FLAME/EXPLOSION//////////////////////////
/obj/structure/bomberflame
	name = "explosion"
	desc = "Sidesteps are its only weakness."
	icon = 'icons/obj/bomberman.dmi'
	icon_state = "explosion_core"
	density = 0
	anchored = 1
	layer = LIGHTING_LAYER + 1
	var/destroy_environnement = 0
	var/hurt_players = 0

	var/fuel = 1

/obj/structure/bomberflame/New(turf/loc, var/initial=1, var/power=1, var/flame_dir=SOUTH, var/destroy=0, var/hurt=0)
	..()
	fuel = power
	dir = flame_dir
	destroy_environnement = destroy
	hurt_players = hurt
	var/turf/T1 = get_turf(src)
	var/turf/T2 = null
	if(!initial)
		if(fuel)
			icon_state = "explosion_branch"
		else
			icon_state = "explosion_tip"

		step(src, flame_dir)
		T2 = get_turf(src)
		if(T1 == T2)
			qdel(src)
			return
	else
		T2 = T1
	bombermangear += src

	collisions(T2)

	spawn(1)
		if(fuel)
			propagate(initial)

	sleep(5)
	collisions(T2)

	sleep(5)
	qdel(src)

obj/structure/bomberflame/Destroy()
	..()
	bombermangear -= src

/obj/structure/bomberflame/proc/collisions(var/turf/T)

	for(var/obj/item/weapon/bomberman/dispenser in T)
		dispenser.lost()
		T.turf_animation('icons/obj/bomberman.dmi',"dispenser_break",0,0,MOB_LAYER-0.1,'sound/bomberman/bombed.ogg')

	for(var/mob/living/L in T)
		for(var/obj/item/weapon/bomberman/dispenser in L)
			L.u_equip(dispenser,1)
			dispenser.loc = L.loc
			//dispenser.dropped(C)
			dispenser.lost()
			T.turf_animation('icons/obj/bomberman.dmi',"dispenser_break",0,0,MOB_LAYER-0.1,'sound/bomberman/bombed.ogg')

	if(hurt_players)
		for(var/mob/living/L in T)
			if(fuel <= 2)
				L.ex_act(3)
			else if(fuel <= 10)
				L.ex_act(2)
			else
				L.ex_act(1)

/obj/structure/bomberflame/proc/propagate(var/init)
	if(init)
		for(var/direction in cardinal)
			spawn()	//so we don't wait for the flame to die before it spawns the next one, duh
				new /obj/structure/bomberflame(get_turf(src),0,fuel-1,direction,destroy_environnement,hurt_players)
	else
		new /obj/structure/bomberflame(get_turf(src),0,fuel-1,dir,destroy_environnement,hurt_players)


/obj/structure/bomberflame/Bump(atom/obstacle)	//if an explosion reaches a bomb, it detonates
	if(istype(obstacle, /obj/structure/bomberman/))
		var/obj/structure/bomberman/chained_explosion = obstacle
		chained_explosion.detonate()

	else if(istype(obstacle, /obj/structure/softwall/))
		var/obj/structure/softwall/wall_break = obstacle
		wall_break.pulverized()

	if(destroy_environnement)
		if(istype(obstacle, /obj/structure/closet/))
			qdel(obstacle)

		else if(istype(obstacle, /obj/structure/table/))
			var/obj/structure/table/table = obstacle
			table.destroy()

		else if(istype(obstacle, /obj/structure/rack/))
			var/obj/structure/rack/rack = obstacle
			rack.destroy()

		else if(istype(obstacle, /obj/structure/grille))
			var/obj/structure/grille/grille = obstacle
			grille.broken = 1
			grille.icon_state = "[initial(grille.icon_state)]-b"
			grille.density = 0
			if(prob(35))
				var/turf/T = grille.loc
				T.spawn_powerup()

		else if(istype(obstacle, /obj/structure/window))
			qdel(obstacle)

		else if(istype(obstacle, /turf/simulated/wall/) && !istype(obstacle, /turf/simulated/wall/r_wall))
			var/turf/T = obstacle
			T.ChangeTurf(/turf/simulated/floor/plating)
			T.icon_state = "wall_thermite"
			if(prob(35))
				T.spawn_powerup()

		else if(istype(obstacle, /obj/structure/reagent_dispensers/fueltank))
			obstacle.ex_act(1)

		else if(istype(obstacle, /obj/machinery/portable_atmospherics/canister))
			var/obj/machinery/portable_atmospherics/canister/canister = obstacle
			canister.health = 0
			canister.healthcheck()

		else if(istype(obstacle, /obj/machinery/computer/))
			var/obj/machinery/computer/computer = obstacle
			for(var/x in computer.verbs)
				computer.verbs -= x
			computer.set_broken()

		else if(istype(obstacle, /obj/mecha))
			if(fuel <= 2)
				obstacle.ex_act(3)
			else if(fuel <= 10)
				obstacle.ex_act(2)
			else
				obstacle.ex_act(1)

	..()

/obj/structure/bomberflame/ex_act(severity)
	return

/obj/structure/bomberflame/cultify()
	return

/obj/structure/bomberflame/singuloCanEat()
	return 0


///////////////////////////////SOFT WALLS/////////////////////////////
/obj/structure/softwall
	name = "soft wall"
	desc = "Looks like even the weakest explosion could break this wall apart."
	icon = 'icons/obj/bomberman.dmi'
	icon_state = "softwall"
	density = 1
	anchored = 1

/obj/structure/softwall/New()
	..()
	bombermangear += src

/obj/structure/softwall/Destroy()
	..()
	bombermangear -= src

/obj/structure/softwall/proc/pulverized()
	icon_state = "softwall_break"
	density = 0
	mouse_opacity = 0
	spawn(5)
		if(prob(45))
			pick_a_powerup()
		spawn(5)
			qdel(src)

/obj/structure/softwall/proc/pick_a_powerup()
	var/powerup = pick(
		50;/obj/structure/powerup/bombup,
		50;/obj/structure/powerup/fire,
		50;/obj/structure/powerup/skate,
		10;/obj/structure/powerup/kick,
		10;/obj/structure/powerup/line,
		10;/obj/structure/powerup/power,
		10;/obj/structure/powerup/skull,
		5;/obj/structure/powerup/full,
		)
	new powerup(get_turf(src))

/obj/structure/softwall/ex_act(severity)
	pulverized()
	return

/obj/structure/softwall/cultify()
	return

/obj/structure/softwall/singuloCanEat()
	return 0

///////////////////////////////HARD WALLS/////////////////////////////
/turf/unsimulated/wall/bomberman
	name = "hard wall"
	icon = 'icons/obj/bomberman.dmi'
	icon_state = "hardwall"
	opacity = 0

/turf/unsimulated/wall/ex_act(severity)
	return

/turf/unsimulated/wall/cultify()
	return

/turf/unsimulated/wall/singuloCanEat()
	return 0

///////////////////////////////POWER-UPS//////////////////////////////
/obj/structure/powerup
	name = "powerup"
	desc = ""
	icon = 'icons/obj/bomberman.dmi'
	icon_state = "powerup"
	density = 1
	anchored = 1

/obj/structure/powerup/New()
	..()
	bombermangear += src

/obj/structure/powerup/Destroy()
	..()
	bombermangear -= src

/obj/structure/powerup/bombup
	name = "bomb-up"
	icon_state = "bombup"

/obj/structure/powerup/fire
	name = "fire"
	icon_state = "fire"

/obj/structure/powerup/full
	name = "full fire"
	icon_state = "full"

/obj/structure/powerup/kick
	name = "kick"
	icon_state = "kick"

/obj/structure/powerup/line
	name = "line bomb"
	icon_state = "line"

/obj/structure/powerup/power
	name = "power bomb"
	icon_state = "power"

/obj/structure/powerup/skate
	name = "skate"
	icon_state = "skate"

/obj/structure/powerup/skull
	name = "skull"
	icon_state = "skull"

/obj/structure/powerup/attackby(var/obj/item/weapon/bomberman/dispenser, var/mob/user)
	if(istype(dispenser))
		apply_power(dispenser)
	..()

/obj/structure/powerup/Bumped(M as mob|obj)	//kick bomb
	if (istype(M, /mob/living) || istype(M, /obj/mecha) || istype(M, /obj/structure/bed/chair/) || istype(M, /obj/structure/bomberflame))
		density = 0
		step(M, get_dir(M,src))
		spawn(1)	//to prevent an infinite loop when a player with no BBD is trying to walk over a tile with at least two power-ups.
			density = 1
	var/obj/item/weapon/bomberman/dispenser = locate() in M
	if (dispenser)
		apply_power(dispenser)
	if (istype(M, /obj/structure/bomberflame))
		icon_state = "powerup_break"
		spawn(5)
			qdel(src)

	..()

/obj/structure/powerup/proc/apply_power(var/obj/item/weapon/bomberman/dispenser)
	playsound(get_turf(src), 'sound/bomberman/powerup.ogg', 50, 1)
	qdel(src)
	return

/obj/structure/powerup/bombup/apply_power(var/obj/item/weapon/bomberman/dispenser)
	dispenser.bomblimit++
	dispenser.bombtotal++
	..()
	return

/obj/structure/powerup/fire/apply_power(var/obj/item/weapon/bomberman/dispenser)
	dispenser.bombpower = min(MAX_BOMB_POWER, dispenser.bombpower + 1)
	..()
	return

/obj/structure/powerup/full/apply_power(var/obj/item/weapon/bomberman/dispenser)
	dispenser.bombpower = MAX_BOMB_POWER
	..()
	return

/obj/structure/powerup/kick/apply_power(var/obj/item/weapon/bomberman/dispenser)
	dispenser.can_kick = 1
	..()
	return

/obj/structure/powerup/line/apply_power(var/obj/item/weapon/bomberman/dispenser)
	dispenser.can_line = 1
	..()
	return

/obj/structure/powerup/power/apply_power(var/obj/item/weapon/bomberman/dispenser)
	dispenser.has_power = 1
	..()
	return

/obj/structure/powerup/skate/apply_power(var/obj/item/weapon/bomberman/dispenser)
	dispenser.skate = min(MAX_SPEED_BONUS, dispenser.skate + 1)
	if(!dispenser.slow)
		dispenser.speed_bonus = min(MAX_SPEED_BONUS, dispenser.speed_bonus + 1)
	..()
	return

/obj/structure/powerup/skull/apply_power(var/obj/item/weapon/bomberman/dispenser)
	playsound(get_turf(src), 'sound/bomberman/disease.ogg', 50, 1)
	var/list/diseases = list(
		"Low Power Disease",
		"Constipation ",
		"Diarrhea",
		"Slow Pace Disease",
		"Rapid Pace Disease",
		"Change",
		"Fire",
		)
	var/disease = pick(diseases)
	to_chat(dispenser.loc, "<span class='danger'>[disease][((disease != "Fire")&&(disease != "Change")) ? " for 40 seconds" : ""]!!</span>")
	switch(disease)
		if("Low Power Disease")
			dispenser.small_bomb = 1
			dispenser.cure(disease)
		if("Constipation")
			dispenser.no_bomb = 1
			dispenser.cure(disease)
		if("Diarrhea")
			dispenser.spam_bomb = 1
			dispenser.cure(disease)
		if("Slow Pace Disease")
			dispenser.slow = 1
			dispenser.cure(disease)
		if("Rapid Pace Disease")
			dispenser.fast = 1
			dispenser.speed_bonus = MAX_SPEED_BONUS
			dispenser.cure(disease)
		if("Change")
			for(var/mob/living/L_other in player_list)
				var/obj/item/weapon/bomberman/target = locate() in L_other
				if(target)
					var/mob/living/L_self = src.loc
					var/turf/T_self = get_turf(L_self)
					var/turf/T_other = get_turf(L_other)
					L_self.loc = T_other
					L_other.loc = T_self
					playsound(T_self, 'sound/bomberman/disease.ogg', 50, 1)
					playsound(T_other, 'sound/bomberman/disease.ogg', 50, 1)
					qdel(src)
					return
		if("Fire")
			if(istype(dispenser.loc, /mob/living/carbon))
				var/mob/living/carbon/M = dispenser.loc
				M.adjust_fire_stacks(0.5)
				M.on_fire = 1
				M.update_icon = 1
				playsound(M.loc, 'sound/effects/bamf.ogg', 50, 0)

	qdel(src)
	return

/obj/structure/powerup/proc/pulverized()
	qdel(src)

/obj/structure/powerup/ex_act(severity)
	pulverized()
	return

/obj/structure/powerup/cultify()
	return

/obj/structure/powerup/singuloCanEat()
	return 0


///////////////////////////////CLOTHING///////////////////////////////
/obj/item/clothing/suit/space/bomberman
	name = "Bomberman's suit"
	desc = "Doesn't actually make you immune to bombs!"
	icon_state = "bomberman"
	item_state = "bomberman"
	slowdown = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 100, bio = 0, rad = 0)
	siemens_coefficient = 0
	flags = FPRINT  | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEJUMPSUIT
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	allowed = list(/obj/item/weapon/bomberman/)
	pressure_resistance = 40 * ONE_ATMOSPHERE
	species_restricted = list("exclude")
	var/never_removed = 1

/obj/item/clothing/suit/space/bomberman/New()
	..()
	bombermangear += src

/obj/item/clothing/suit/space/bomberman/Destroy()
	..()
	bombermangear -= src

/obj/item/clothing/suit/space/bomberman/dropped(mob/user as mob)
	..()
	never_removed = 0

/obj/item/clothing/head/helmet/space/bomberman
	name = "Bomberman head"
	desc = "Terrorism has never looked so adorable."
	icon_state = "bomberman"
	item_state = "bomberman"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 100, bio = 0, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	body_parts_covered = FULL_HEAD
	siemens_coefficient = 0
	species_restricted = list("exclude")
	var/never_removed = 1

/obj/item/clothing/head/helmet/space/bomberman/New()
	..()
	bombermangear += src

/obj/item/clothing/head/helmet/space/bomberman/Destroy()
	..()
	bombermangear -= src

/obj/item/clothing/head/helmet/space/bomberman/dropped(mob/user as mob)
	..()
	never_removed = 0

///////////////////////////////ARENA BUILDER///////////////////////////

var/global/list/arenas = list()
var/global/list/arena_spawnpoints = list()//used by /mob/dead/observer/Logout()

/datum/bomberman_spawn
	var/turf/spawnpoint = null
	var/availability = 0
	var/mob/living/carbon/human/player_mob = null
	var/client/player_client = null
	var/obj/structure/planner/spawnpoint/icon = null

/datum/bomberman_spawn/New()
	arena_spawnpoints += src


/datum/bomberman_arena
	var/name = "Bomberman Arena"
	var/status = ARENA_SETUP
	var/shape = ""
	var/violence = 1
	var/opacity = 0
	var/min_number_of_players = 2
	var/area/arena = null
	var/area/under = null
	var/turf/center = null		//middle of the arena.
	var/list/planners = list()	//these let you visualize the dimensions of the arena before building it.
	var/list/cameras = list()	//security cameras.
	var/list/spawns = list()	//player spawns.
	var/list/turfs = list()		//all of the arena's turfs. they get reverted to space tiles when the arena is removed.
	var/list/swalls = list()	//all of the soft walls. randomly spread over the arena between round.
	var/list/gladiators = list()//players that registered with this arena.
	var/list/tools = list()		//clothes and bomb dispensers spawned by the arena.
	var/auto_start = 60			//how long (in seconds) till the game automatically begins when at least two players have registered
	var/counting = 0

/datum/bomberman_arena/New(var/turf/a_center=null, var/size="",mob/user)
	if(!a_center)	return
	if(!size)	return
	if(!user)	return
	center = a_center
	name += " #[rand(1,999)]"
	open(size,user)
	arenas += src
	status = ARENA_AVAILABLE

	shape = size
	for(var/datum/bomberman_spawn/S in spawns)
		var/obj/structure/planner/spawnpoint/P = new(S.spawnpoint, src, S)
		S.icon = P
		planners += P

/datum/bomberman_arena/Destroy()
	..()
	arena = null
	under = null
	center = null
	planners = null
	cameras = null
	spawns = null
	turfs = null
	swalls = null
	gladiators = null
	tools = null

/datum/bomberman_arena/proc/open(var/size,mob/user)
	var/x = 1
	var/y = 1
	var/w = 1
	var/h = 1
	switch(size)
		if("15x13 (2 players)")
			w = 14
			h = 12
		if("15x15 (4 players)")
			w = 14
			h = 14

		if("39x23 (10 players)")
			w = 38
			h = 22

	if(planner(size,user))
		var/obj/machinery/camera/arena/C = new(center)
		cameras += C
		C.name = name
		C.c_tag = name
		C.network = list(
			"thunder",	//entertainment monitors
			"SS13",		//security monitors
			)

		var/obj/structure/planner/pencil = new(center, src)
		pencil.x -= (w/2)
		pencil.y -=	(h/2)
		x = pencil.x
		y = pencil.y
		var/turf/T = null

		under = get_area(pencil)

		while (pencil.y <= (y+h))	//placing the Hard Walls and floors
			pencil.x = x
			while(pencil.x <= (x+w))
				T = pencil.loc
				if((pencil.y == y) || (pencil.y == (y+h)))
					T.ChangeTurf(/turf/unsimulated/wall/bomberman)
					T.opacity = 1
					turfs += T
				else if((pencil.x == x) || (pencil.x == (x+w)))
					T.ChangeTurf(/turf/unsimulated/wall/bomberman)
					T.opacity = 1
					turfs += T
				else if((((pencil.x - x)%2) == 0) && (((pencil.y - y)%2) == 0))
					T.ChangeTurf(/turf/unsimulated/wall/bomberman)
					turfs += T
					if(opacity)
						T.opacity = 1
				else
					T.ChangeTurf(/turf/simulated/floor/plating)
					turfs += T
				pencil.x++
			sleep(2)	//giving the game some time to process to avoid unbearable lag spikes when we create an arena, plus it looks cool.
			pencil.y++

		pencil.x = x
		pencil.y = y	//placing the Spawns
		pencil.x++
		pencil.y++
		T = pencil.loc

		if(!(size == "15x13 (2 players)"))
			var/datum/bomberman_spawn/sp1 = new()
			sp1.spawnpoint = T
			spawns += sp1

		pencil.x = x+w-1
		T = pencil.loc

		var/datum/bomberman_spawn/sp2 = new()
		sp2.spawnpoint = T
		spawns += sp2

		pencil.y = y+h-1
		T = pencil.loc

		if(!(size == "15x13 (2 players)"))
			var/datum/bomberman_spawn/sp3 = new()
			sp3.spawnpoint = T
			spawns += sp3

		pencil.x = x+1
		T = pencil.loc

		var/datum/bomberman_spawn/sp4 = new()
		sp4.spawnpoint = T
		spawns += sp4

		if(size == "39x23 (10 players)")
			pencil.x = x + 10
			pencil.y = y + 7
			T = pencil.loc
			var/datum/bomberman_spawn/sp5 = new()
			sp5.spawnpoint = T
			spawns += sp5
			pencil.x = x + 10
			pencil.y = y + 15
			T = pencil.loc
			var/datum/bomberman_spawn/sp6 = new()
			sp6.spawnpoint = T
			spawns += sp6
			pencil.x = x + 19
			pencil.y = y + 1
			T = pencil.loc
			var/datum/bomberman_spawn/sp7 = new()
			sp7.spawnpoint = T
			spawns += sp7
			pencil.x = x + 19
			pencil.y = y + h - 1
			T = pencil.loc
			var/datum/bomberman_spawn/sp8 = new()
			sp8.spawnpoint = T
			spawns += sp8
			pencil.x = x + 28
			pencil.y = y + 7
			T = pencil.loc
			var/datum/bomberman_spawn/sp9 = new()
			sp9.spawnpoint = T
			spawns += sp9
			pencil.x = x + 28
			pencil.y = y + 15
			T = pencil.loc
			var/datum/bomberman_spawn/sp10 = new()
			sp10.spawnpoint = T
			spawns += sp10

		pencil.x = x
		pencil.y = y
		while (pencil.y <= (y+h))	//placing the Soft Walls
			pencil.x = x
			while(pencil.x <= (x+w))
				T = pencil.loc
				if(istype(T, /turf/simulated/floor/plating))
					if(prob(60))
						T = pencil.loc
						var/obj/structure/softwall/W = new(T)
						swalls += W
						if(opacity)
							W.opacity = 1
				pencil.x++
			sleep(2)	//giving the game some time to process to avoid unbearable lag spikes when we create a large arena, plus it looks cool.
			pencil.y++

		pencil.x = x
		pencil.y = y+h
		T = pencil.loc
		T.maptext = name
		T.maptext_width = 256
		//T.maptext_y = 20

		qdel(pencil)	//RIP sweet prince

		for (var/datum/bomberman_spawn/S in spawns)	//removing the soft walls near the spawns
			for (var/obj/structure/softwall/W in range(S.spawnpoint,1))
				swalls -= W
				qdel(W)
			S.availability = 1


		//now we just need to add a thunderdome jukebox to every map
		var/area/A = new
		A.name = name
		A.tag = "[A.type]/[md5(name)]"
		A.power_equip = 0
		A.power_light = 0
		A.power_environ = 0
		A.always_unpowered = 0
		A.jammed = SUPER_JAMMED	//lol telesci
		A.addSorted()
		arena = A

		spawn(0)
			A.contents.Add(turfs)
			for(var/turf/F in turfs)
				for(var/atom/movable/AM in F)
					AM.areaMaster = get_area_master(F)



		message_admins("[key_name_admin(user.client)] created a \"[size]\" Bomberman arena at [center.loc.name] ([center.x],[center.y],[center.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[center.x];Y=[center.y];Z=[center.z]'>JMP</A>)")
		log_game("[key_name_admin(user.client)] created a \"[size]\" Bomberman arena at [center.loc.name] ([center.x],[center.y],[center.z]) ")

		for(var/mob/dead/observer/O in observers)
			to_chat(O, "<spawn class='notice'><b>[user.client.key] created a \"[size]\" Bomberman arena at [center.loc.name]. <A HREF='?src=\ref[O];jumptoarenacood=1;targetarena=\ref[src]'>Click here to JUMP to it.</A></b></span>")

	else
		qdel(src)



/datum/bomberman_arena/proc/spawn_player(var/turf/T)
	var/mob/living/carbon/human/M = new(T)
	M.name = "Bomberman #[rand(1,999)]"
	M.real_name = M.name
	var/list/randomhexes = list(
		"7",
		"8",
		"9",
		"a",
		"b",
		"c",
		"d",
		"e",
		"f",
		)
	M.color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	return M

/datum/bomberman_arena/proc/dress_player(var/mob/living/carbon/human/M)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/darkblue(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/purple(M), slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/bomberman(M), slot_head)
	var/obj/item/clothing/suit/space/bomberman/bombsuit = new(M)
	M.equip_to_slot_or_del(bombsuit, slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/purple(M), slot_gloves)
	var/obj/item/weapon/bomberman/B = new(M)
	tools += B
	B.arena = src
	if(violence)
		B.hurt_players = 1
		B.bombpower = 2
	else
		B.hurt_players = 0
	B.destroy_environnement = 0
	M.equip_to_slot_or_del(B, slot_s_store)
	bombsuit.slowdown = 1
	for(var/obj/item/clothing/C in M)
		C.canremove = 0
		if(violence)
			C.armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

/datum/bomberman_arena/proc/start()
	status = ARENA_INGAME

	if(counting)
		counting = 0
		auto_start = 60
		for(var/obj/structure/planner/spawnpoint/S in arena)
			S.overlays.len = 0

	for(var/obj/structure/planner/spawnpoint/P in planners)
		P.icon_state = "planner_ready"

	var/readied = 0
	for(var/datum/bomberman_spawn/S in spawns)
		S.availability = 0
		S.icon.icon_state = "planner_ready"

		if(!S.player_client)
			continue
		var/client/C = 	S.player_client

		var/mob/client_mob = C.mob
		if(C in ready_gladiators)
			ready_gladiators -= C

		if(!isobserver(client_mob))
			continue

		var/mob/living/carbon/human/M = spawn_player(S.spawnpoint)
		dress_player(M)
		M.stunned = 3
		M.ckey = C.ckey
		gladiators += M

		if(S.player_mob)
			qdel(S.player_mob)

		S.player_mob = M

		if(S.player_mob.ckey)
			readied++

	if(readied < min_number_of_players)
		status = ARENA_AVAILABLE

		for(var/mob/M in arena)
			to_chat(M, "<span class='danger'>Not enough players. Round canceled.</span>")

		for(var/mob/M in gladiators)
			qdel(M)

		gladiators = list()
		for (var/datum/bomberman_spawn/S in spawns)
			S.player_mob = null
			S.player_client = null
			S.availability = 1
			S.icon.icon_state = "planner"
		return

	for(var/mob/M in arena)
		if(violence)
			to_chat(M, "Violence Mode activated! Bombs hurt players! Suits offer no protections! Initial Flame Range increased!")
		if(M.client)
			to_chat(M.client, sound('sound/bomberman/start.ogg'))
		to_chat(M, "<b>READY?</b>")

	for(var/obj/machinery/computer/security/telescreen/entertainment/E in machines)
		E.visible_message("<span style='color:grey'>\icon[E] \The [E] brightens as it appears that a round is starting in [name].</span>")
		flick("entertainment_arena",E)

	for(var/mob/dead/observer/O in observers)
		to_chat(O, "<b>A round has began in <A HREF='?src=\ref[O];jumptoarenacood=1;X=[center.x];Y=[center.y];Z=[center.z]'>[name]</A>!</b>")

	sleep(40)

	for(var/mob/M in arena)
		to_chat(M, "<span class='danger'>GO!</span>")

	return

/datum/bomberman_arena/proc/end()
	if(tools.len > 1)	return
	if(status == ARENA_ENDGAME)	return
	status = ARENA_ENDGAME
	var/mob/living/winner = null
	for(var/obj/item/weapon/bomberman/W in tools)
		W.hurt_players = 1	//FINISH THEM!
		if(istype(W.loc, /mob/living))
			winner = W.loc

	for(var/mob/M in arena)
		if(winner && winner.client)
			to_chat(M, "[winner ? "<b>[winner.client.key]</b> as <b>[winner.name]</b> wins this round! " : ""]Resetting arena in 20 seconds.")
		else
			to_chat(M, "Couldn't find a winner. Resetting arena in 20 seconds.")

	if(winner)
		if(winner.client.key in arena_leaderboard)
			arena_leaderboard[winner.client.key] = arena_leaderboard[winner.client.key] + 1
		else
			arena_leaderboard += winner.client.key
			arena_leaderboard[winner.client.key] = 1

	arena_rounds++

	sleep(200)
	reset()


/datum/bomberman_arena/proc/reset()
	status = ARENA_SETUP

	if(counting)
		counting = 0
		auto_start = 60
		for(var/obj/structure/planner/spawnpoint/S in arena)
			S.overlays.len = 0

	for (var/datum/bomberman_spawn/S in spawns)
		S.availability = 0
		S.icon.icon_state = "planner_ready"

	for(var/obj/structure/powerup/P in arena)
		qdel(P)

	for(var/obj/item/clothing/C in arena)
		qdel(C)

	for(var/obj/item/weapon/organ/O in arena)//gibs
		qdel(O)

	for(var/mob/living/M in gladiators)
		if(M)
			qdel(M)	//qdel doesn't work nicely with mobs
	gladiators = list()

	for(var/obj/structure/softwall/W in swalls)
		qdel(W)
	swalls = list()

	for(var/obj/T in tools)
		qdel(T)
	tools = list()


	var/obj/structure/planner/pencil = new(center, src)
	var/w = 1
	var/h = 1
	switch(shape)
		if("15x13 (2 players)")
			w = 14
			h = 12

		if("15x15 (4 players)")
			w = 14
			h = 14

		if("39x23 (10 players)")
			w = 38
			h = 22
	pencil.x -= (w/2)
	pencil.y -=	(h/2)
	var/x = pencil.x
	var/y = pencil.y
	var/turf/T = null

	sleep(40)	//waiting a moment, in case there are bombs waiting to explode in the arena

	while (pencil.y <= (y+h))	//replacing the Soft Walls
		pencil.x = x
		while(pencil.x <= (x+w))
			T = pencil.loc
			if(istype(T, /turf/simulated/floor/plating))
				if(prob(60))
					T = pencil.loc
					var/obj/structure/softwall/W = new(T)
					swalls += W
					if(opacity)
						W.opacity = 1
			pencil.x++
		sleep(2)
		pencil.y++

	qdel(pencil)

	for (var/datum/bomberman_spawn/S in spawns)	//removing the soft walls near the spawns
		for (var/obj/structure/softwall/W in range(S.spawnpoint,1))
			swalls -= W
			qdel(W)
		if(S.player_client)
			ready_gladiators -= S.player_client
		S.player_mob = null
		S.player_client = null
		S.availability = 1
		S.icon.icon_state = "planner"

	status = ARENA_AVAILABLE

/datum/bomberman_arena/proc/close(var/open_space=1)
	status = ARENA_SETUP
	for (var/obj/structure/planner/P in planners)
		qdel(P)

	for(var/obj/machinery/camera/C in cameras)
		qdel(C)
	cameras = list()

	for(var/obj/structure/softwall/W in swalls)
		qdel(W)
	swalls = list()

	for(var/obj/T in tools)
		qdel(T)
	tools = list()

	for(var/mob/living/M in gladiators)
		if(M)
			qdel(M)	//qdel doesn't work nicely with mobs
	gladiators = list()

	for(var/obj/item/weapon/organ/O in arena)//gibs
		qdel(O)

	for(var/obj/effect/decal/cleanable/C in arena)
		qdel(C)

	for(var/datum/bomberman_spawn/S in arena)
		arena_spawnpoints -= S
		if(S.player_client)
			ready_gladiators -= S.player_client
		S.player_client = null
		S.player_mob = null

	under.contents.Add(turfs)
	for(var/turf/T in turfs)
		for(var/atom/movable/AM in T)
			AM.areaMaster = get_area_master(T)
		if(open_space && (under.name == "Space"))
			T.ChangeTurf(get_base_turf(T.z))
		else
			T.ChangeTurf(/turf/simulated/floor/plating)
		T.maptext = null
	turfs = list()
	arenas -= src
	return

/datum/bomberman_arena/proc/update_ready()
	var/list/ready = list()
	var/slots = 0
	for(var/datum/bomberman_spawn/S in spawns)
		slots++
		if(S.player_client)
			if(isobserver(S.player_client.mob))
				ready += S.player_client
			else
				S.icon.ghost_unsubscribe(S.player_client.mob)
	if(slots == ready.len)
		start(ready)
	else if(ready.len >= min_number_of_players)
		if(!counting)
			counting = 1
			spawn()
				countin()
	else if(counting)
		counting = 0
		auto_start = 60
		for(var/obj/structure/planner/spawnpoint/S in arena)
			S.overlays.len = 0

/datum/bomberman_arena/proc/countin()
	if(counting)
		auto_start--
		for(var/obj/structure/planner/spawnpoint/S in arena)
			S.update_overlay(auto_start)
		if(auto_start <= 0)
			counting = 0
			auto_start = 60
			for(var/obj/structure/planner/spawnpoint/S in arena)
				S.overlays.len = 0
			start()
			return
		sleep(10)
		countin()

/datum/bomberman_arena/proc/planner(var/size,mob/user)
	var/choice = 0
	switch(size)
		if("15x13 (2 players)")
			var/obj/structure/planner/pencil = new(center, src)
			var/w = 14
			var/h = 12
			pencil.x -= (w/2)
			pencil.y -= (h/2)
			var/x = pencil.x
			var/y = pencil.y
			var/turf/T = null
			while (pencil.y <= (y+h))
				pencil.x = x
				while(pencil.x <= (x+w))
					T = pencil.loc
					var/obj/structure/planner/P = new(T, src)
					if(P.loc)
						planners += P
					pencil.x++
				pencil.y++
			qdel(pencil)
			if(planners.len == 195)
				var/achoice = alert(user, "All those green tiles (that only ghosts can see) will be part of the arena. Do you want to proceed?","Arena Creation", "Confirm","Cancel")
				if(achoice=="Confirm")
					choice = 1

		if("15x15 (4 players)")
			for(var/turf/T in range(center,7))
				var/obj/structure/planner/P = new(T, src)
				if(P.loc)
					planners += P
			if(planners.len == 225)
				var/achoice = alert(user, "All those green tiles (that only ghosts can see) will be part of the arena. Do you want to proceed?","Arena Creation", "Confirm","Cancel")
				if(achoice=="Confirm")
					choice = 1
			else
				to_chat(user, "<span class='warning'>Part of the arena was outside the Z-Level.</span>")
		if("39x23 (10 players)")
			var/obj/structure/planner/pencil = new(center, src)
			var/w = 38
			var/h = 22
			pencil.x -= (w/2)
			pencil.y -= (h/2)
			var/x = pencil.x
			var/y = pencil.y
			var/turf/T = null
			while (pencil.y <= (y+h))
				pencil.x = x
				while(pencil.x <= (x+w))
					T = pencil.loc
					var/obj/structure/planner/P = new(T, src)
					if(P.loc)
						planners += P
					pencil.x++
				pencil.y++
			qdel(pencil)
			if(planners.len == 897)
				var/achoice = alert(user, "All those green tiles (that only ghosts can see) will be part of the arena. Do you want to proceed?","Arena Creation", "Confirm","Cancel")
				if(achoice=="Confirm")
					choice = 1
	for (var/obj/structure/planner/P in planners)
		qdel(P)
	return	choice

/obj/structure/planner
	name = "arena planner"
	icon = 'icons/effects/effects.dmi'
	icon_state = "planner"
	density = 0
	anchored = 1
	invisibility = 60
	var/datum/bomberman_arena/arena = null

/obj/structure/planner/New(turf/loc,var/a)
	..()
	arena = a

/obj/structure/planner/Destroy()
	..()
	arena = null

/obj/structure/planner/ex_act(severity)
	return

/obj/structure/planner/cultify()
	return

/obj/structure/planner/singuloCanEat()
	return 0

/obj/structure/planner/spawnpoint
	name = "Spawn Point"
	desc = "Click to register yourself as a contestant."
	var/datum/bomberman_spawn/spawnpoint = null

/obj/structure/planner/spawnpoint/New(turf/loc,var/a,var/datum/bomberman_spawn/bs)
	..()
	arena = a
	spawnpoint = bs

/obj/structure/planner/spawnpoint/Destroy()
	..()
	spawnpoint = null

/obj/structure/planner/spawnpoint/attack_ghost(mob/user)
	if(arena.status != ARENA_AVAILABLE)	return

	if(spawnpoint.availability)
		if(!(user.client in never_gladiators) && !(user.client in ready_gladiators))
			ghost_subscribe(user)
	else
		if(spawnpoint.player_client == user.client)
			ghost_unsubscribe(user)

	arena.update_ready()

/obj/structure/planner/spawnpoint/proc/ghost_subscribe(mob/user)
	spawnpoint.player_client = user.client
	ready_gladiators += user.client
	spawnpoint.availability = 0
	icon_state = "planner_ready"

/obj/structure/planner/spawnpoint/proc/ghost_unsubscribe(mob/user)
	spawnpoint.player_client = null
	ready_gladiators -= user.client
	spawnpoint.availability = 1
	icon_state = "planner"

/obj/structure/planner/spawnpoint/proc/update_overlay(var/currentcount)
	overlays.len = 0
	if(arena.counting)
		var/first = round(currentcount/10)
		var/second = currentcount%10
		var/image/I1 = new('icons/obj/centcomm_stuff.dmi',src,"[first]",30)
		var/image/I2 = new('icons/obj/centcomm_stuff.dmi',src,"[second]",30)
		I1.pixel_x += 10
		I2.pixel_x += 17
		I1.pixel_y -= 11
		I2.pixel_y -= 11
		overlays += I1
		overlays += I2
