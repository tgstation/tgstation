//////////////////////////////////based on the original game by Hudson Soft
//Spess Bomberman, by Deity Link//
//////////////////////////////////

#define MAX_BOMB_POWER 16	//How far will the largest explosions reach.
#define MAX_SPEED_BONUS 10	//How fast can a player get by cumulating skates (his tally cannot exceed -1 anyway, but additional skates will allow him to stay fast while starving for example)

///////////////////////////////BOMB DISPENSER//////////////////////////
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
	world << "making a cure() for [disease]"
	spawn(400)
		world << "curing [disease]"
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
	var/list/turfs = list()
	for(var/turf/T in range(loc,1))
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
	layer = LIGHTING_LAYER+1
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
			del(src)
			return
	else
		T2 = T1

	collisions(T2)

	spawn(1)
		if(fuel)
			propagate(initial)

	sleep(5)
	collisions(T2)

	sleep(5)
	qdel(src)

/obj/structure/bomberflame/proc/collisions(var/turf/T)

	for(var/mob/living/carbon/C in T)
		for(var/obj/item/weapon/bomberman/dispenser in C.contents)
			C.u_equip(dispenser)
			dispenser.loc = C.loc
			dispenser.dropped(C)
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

/obj/structure/softwall/proc/pulverized()
	icon_state = "softwall_break"
	density = 0
	mouse_opacity = 0
	spawn(5)
		if(prob(35))
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
	if (istype(M, /mob/living) || istype(M, /obj/mecha) || istype(M, /obj/structure/stool/bed/chair/) || istype(M, /obj/structure/bomberflame))
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
	dispenser.loc << "<span class='danger'>[disease][((disease != "Fire")&&(disease != "Change")) ? " for 40 seconds" : ""]!!</span>"
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
			for(var/mob/living/carbon/C in player_list)
				var/obj/item/weapon/bomberman/target = locate() in C
				if(target)
					var/turf/T = get_turf(src)
					var/mob/living/L = src.loc
					L.loc = C.loc
					C.loc = T
					playsound(get_turf(src), 'sound/bomberman/disease.ogg', 50, 1)
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

/obj/item/clothing/head/helmet/space/bomberman
	name = "Bomberman head"
	desc = "Terrorism has never looked so adorable."
	icon_state = "bomberman"
	item_state = "bomberman"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 100, bio = 0, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR
	body_parts_covered = FULL_HEAD
	siemens_coefficient = 0

///////////////////////////////ARENA BUILDER///////////////////////////

var/global/list/arenas = list()

/datum/bomberman_spawn
	var/turf/spawnpoint = null
	var/availability = 0

/datum/bomberman_arena
	var/name = "Bomberman Arena"
	var/area/arena = null
	var/area/under = null
	var/turf/center = null		//middle of the arena.
	var/list/planners = list()	//these let you visualize the dimensions of the arena before building it.
	var/list/cameras = list()	//security cameras.
	var/list/spawns = list()	//player spawns.
	var/list/turfs = list()		//all of the arena's turfs. they get reverted to space tiles when the arena is removed.
	var/list/swalls = list()	//all of the soft walls. randomly spread over the arena between round.
	var/list/players = list()	//players that registered with this arena.
	var/list/tools = list()		//clothes and bomb dispensers spawned by the arena.

/datum/bomberman_arena/New(var/turf/a_center=null, var/size="",mob/user)
	if(!a_center)	return
	if(!size)	return
	if(!user)	return
	center = a_center
	name += " #[rand(1,999)]"
	open(size,user)
	arenas += src

/datum/bomberman_arena/proc/open(var/size,mob/user)
	switch(size)
		if("screensized")
			if(planner(size,user))
				var/obj/machinery/camera/C = new /obj/machinery/camera(center)
				cameras += C
				C.name = name
				C.c_tag = name
				C.network = list(
					"thunder",	//entertainment monitors
					"SS13",		//security monitors
					)

				var/obj/structure/planner/pencil = new /obj/structure/planner(center)
				pencil.x -= 7
				pencil.y -=	7
				var/x = pencil.x
				var/y = pencil.y
				var/w = 14
				var/h = 14
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
				var/datum/bomberman_spawn/sp1 = new/datum/bomberman_spawn()
				sp1.spawnpoint = T
				spawns += sp1
				pencil.x = x+w-1
				T = pencil.loc
				var/datum/bomberman_spawn/sp2 = new/datum/bomberman_spawn()
				sp2.spawnpoint = T
				spawns += sp2
				pencil.y = y+h-1
				T = pencil.loc
				var/datum/bomberman_spawn/sp3 = new/datum/bomberman_spawn()
				sp3.spawnpoint = T
				spawns += sp3
				pencil.x = x+1
				T = pencil.loc
				var/datum/bomberman_spawn/sp4 = new/datum/bomberman_spawn()
				sp4.spawnpoint = T
				spawns += sp4

				pencil.x = x
				pencil.y = y
				while (pencil.y <= (y+h))	//placing the Soft Walls
					pencil.x = x
					while(pencil.x <= (x+w))
						T = pencil.loc
						if(istype(T, /turf/simulated/floor/plating))
							if(prob(60))
								T = pencil.loc
								var/obj/structure/softwall/W = new /obj/structure/softwall(T)
								swalls += W
						pencil.x++
					sleep(2)	//giving the game some time to process to avoid unbearable lag spikes when we create a large arena, plus it looks cool.
					pencil.y++

				qdel(pencil)	//RIP sweet prince

				for (var/datum/bomberman_spawn/S in spawns)	//removing the soft walls near the spawns
					for (var/obj/structure/softwall/W in range(S.spawnpoint,1))
						swalls -= W
						qdel(W)


				//now we just need to add a thunderdome jukebox to every map
				var/area/A = new
				A.name = name
				A.tagbase = "[A.type]_[md5(name)]"
				A.tag = "[A.type]/[md5(name)]"
				A.master = A
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



				message_admins("[key_name_admin(user.mind)] created a \"[size]\" Bomberman arena at [center.loc.name] ([center.x],[center.y],[center.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[center.x];Y=[center.y];Z=[center.z]'>JMP</A>)")
				log_game("[key_name_admin(user.mind)] created a \"[size]\" Bomberman arena at [center.loc.name] ([center.x],[center.y],[center.z]) ")
			else
				qdel(src)

		if("saturntenplayers")
			qdel(src)

/datum/bomberman_arena/proc/reset()
	for(var/obj/structure/softwall/W in swalls)
		qdel(W)
	swalls = list()

	for(var/obj/T in tools)
		qdel(T)
	tools = list()

	for(var/mob/M in players)
		qdel(M)
	players = list()

	var/obj/structure/planner/pencil = new /obj/structure/planner(center)
	pencil.x -= 7
	pencil.y -=	7
	var/x = pencil.x
	var/y = pencil.y
	var/w = 14
	var/h = 14
	var/turf/T = null

	sleep(50)	//waiting a moment, in case there are bombs waiting to explode in the arena

	while (pencil.y <= (y+h))	//replacing the Soft Walls
		pencil.x = x
		while(pencil.x <= (x+w))
			T = pencil.loc
			if(istype(T, /turf/simulated/floor/plating))
				if(prob(60))
					T = pencil.loc
					var/obj/structure/softwall/W = new /obj/structure/softwall(T)
					swalls += W
			pencil.x++
		sleep(2)
		pencil.y++

	qdel(pencil)

	for (var/datum/bomberman_spawn/S in spawns)	//removing the soft walls near the spawns
		for (var/obj/structure/softwall/W in range(S.spawnpoint,1))
			swalls -= W
			qdel(W)

/datum/bomberman_arena/proc/close()
	for(var/obj/machinery/camera/C in cameras)
		qdel(C)
	cameras = list()

	for(var/obj/structure/softwall/W in swalls)
		qdel(W)
	swalls = list()

	for(var/obj/T in tools)
		qdel(T)
	tools = list()

	for(var/mob/M in players)
		qdel(M)
	players = list()

	under.contents.Add(turfs)
	for(var/turf/T in turfs)
		for(var/atom/movable/AM in T)
			AM.areaMaster = get_area_master(T)
		if(under.name == "Space")
			T.ChangeTurf(/turf/space)
		else
			T.ChangeTurf(/turf/simulated/floor/plating)
	turfs = list()
	arenas -= src
	return

/datum/bomberman_arena/proc/planner(var/size,mob/user)
	var/choice = 0
	switch(size)
		if("screensized")
			for(var/turf/T in range(center,7))
				var/obj/structure/planner/P = new /obj/structure/planner(T)
				if(P.loc)
					planners += P
			if(planners.len == 225)
				var/achoice = alert(user, "All those green tiles (that only ghosts can see) will be part of the arena. Do you want to proceed?","Arena Creation", "Confirm","Cancel")
				if(achoice=="Confirm")
					choice = 1
			else
				user << "<span class='warning'>Part of the arena was outside the Z-Level.</span>"
		if("saturntenplayers")
			choice = 0
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

/obj/structure/planner/ex_act(severity)
	return

/obj/structure/planner/cultify()
	return

/obj/structure/planner/singuloCanEat()
	return 0

/obj/structure/bomber_spawn
	name = "spawn"
	icon = 'icons/effects/effects.dmi'
	icon_state = "planner"
	density = 0
	anchored = 1
	invisibility = 60
	var/mob/living/carbon/bomber = null

/obj/structure/bomber_spawn/ex_act(severity)
	return

/obj/structure/bomber_spawn/cultify()
	return

/obj/structure/bomber_spawn/singuloCanEat()
	return 0



