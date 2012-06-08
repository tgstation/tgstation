//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

/obj/effect/critter
	name = "Critter"
	desc = "Generic critter."
	icon = 'critter.dmi'
	icon_state = "basic"
	layer = 5.0
	density = 1
	anchored = 0
	var/alive = 1
	var/health = 10
	var/max_health = 10
	var/aggression = 100
	var/speed = 8
	var/list/access_list = list()//accesses go here
//AI things
	var/task = "thinking"
	//Attacks at will
	var/aggressive = 1
	//Will target an attacker
	var/defensive = 0
	//Will randomly move about
	var/wanderer = 1
	//Will open doors it bumps ignoring access
	var/opensdoors = 0
	//Will randomly travel through vents
	var/ventcrawl = 0

	//Internal tracking ignore
	var/frustration = 0
	var/max_frustration = 8
	var/attack = 0
	var/attacking = 0
	var/steps = 0
	var/last_found = null
	var/target = null
	var/oldtarget_name = null
	var/target_lastloc = null

	var/thinkspeed  = 15
	var/chasespeed  = 4
	var/wanderspeed = 10
		//The last guy who attacked it
	var/attacker = null
		//Will not attack this thing
	var/friend = null
		//How far to look for things dont set this overly high
	var/seekrange = 7

	//If true will attack these things
	var/atkcarbon = 1
	var/atksilicon = 0
	var/atkcritter = 0
		//Attacks critters of the same type
	var/atksame = 0
	var/atkmech = 0

		//Attacks syndies/traitors (distinguishes via mind)
	var/atksynd = 1
		//Attacks things NOT in its obj/req_access list
	var/atkreq = 0

	//Damage multipliers
	var/brutevuln = 1
	var/firevuln = 1
		//DR
	var/armor = 0

		//How much damage it does it melee
	var/melee_damage_lower = 1
	var/melee_damage_upper = 2
		//Basic attack message when they move to attack and attack
	var/angertext = "charges at"
	var/attacktext = "attacks"
	var/deathtext = "dies!"

	var/chasestate = null // the icon state to use when attacking or chasing a target
	var/attackflick = null // the icon state to flick when it attacks
	var/attack_sound = null // the sound it makes when it attacks!

	var/attack_speed = 25 // delay of attack


	proc
		patrol_step()
		seek_target()
		Die()
		ChaseAttack()
		RunAttack()
		TakeDamage(var/damage = 0)
		Target_Attacker(var/target)
		Harvest(var/obj/item/weapon/W, var/mob/living/user)//Controls havesting things from dead critters
		AfterAttack(var/mob/living/target)



/* TODO:Go over these and see how/if to add them

	proc/set_attack()
		state = 1
		if(path_idle.len) path_idle = new/list()
		trg_idle = null

	proc/set_idle()
		state = 2
		if (path_target.len) path_target = new/list()
		target = null
		frustration = 0

	proc/set_null()
		state = 0
		if (path_target.len) path_target = new/list()
		if (path_idle.len) path_idle = new/list()
		target = null
		trg_idle = null
		frustration = 0

	proc/path_idle(var/atom/trg)
		path_idle = AStar(src.loc, get_turf(trg), /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, anicard, null)
		path_idle = reverselist(path_idle)

	proc/path_attack(var/atom/trg)
		path_target = AStar(src.loc, trg.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, anicard, null)
		path_target = reverselist(path_target)


//Look these over
	var/list/path = new/list()
	var/patience = 35						//The maximum time it'll chase a target.
	var/list/mob/living/carbon/flee_from = new/list()
	var/list/path_target = new/list()		//The path to the combat target.

	var/turf/trg_idle					//It's idle target, the one it's following but not attacking.
	var/list/path_idle = new/list()		//The path to the idle target.



*/
