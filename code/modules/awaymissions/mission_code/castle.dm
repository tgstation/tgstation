/*
 *Castle Away Misison
 */

/*
 *This mission bases heavily around two kingdoms in a never-ending battle powered by ghosts. Crew is dropped somewhere in the middle of it and need to escape
 *the mission while avoding becoming another casuality inbetween the two kingdom's eternal fued.
 */


//CTF code shamelessly ripped to fit the need for infinite-spawning knights thanks kor also please don't hurt me
#define WHITE_TEAM "nomad"
#define TOTH_TEAM "Totharene Kingdom"
#define YATH_TEAM "Yatherean Kingdom"
#define DEFAULT_RESPAWN 300 //30 seconds


/obj/machinery/knight
	name = "Portal"
	desc = "A mystical portal that seems to be the source of never-end knights."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	anchored = 1
	var/team = WHITE_TEAM
	var/respawn_cooldown = DEFAULT_RESPAWN
	var/list/team_members = list()
	var/knight_enabled = TRUE
	var/gear = /datum/outfit/knight

/obj/machinery/knight/New()
	..()
	poi_list |= src

/obj/machinery/knight/Destroy()
	poi_list.Remove(src)
	..()

/obj/machinery/knight/totharene
	name = "Totharene Portal"
	desc = "A mystical portal from the Totharene Kingdom."
	team = TOTH_TEAM
	color = rgb(225,100,100)
	gear = /datum/outfit/knight/totharene

/obj/machinery/knight/yatherean
	name = "Yatherean Portal"
	desc = "A mystical portal from the Yatherean Kingdom"
	team = YATH_TEAM
	color = rgb(000,000,225)
	gear = /datum/outfit/knight/yatherean

/obj/machinery/knight/attack_ghost(mob/user)
	if(knight_enabled == FALSE)
		return
	if(ticker.current_state != GAME_STATE_PLAYING)
		return
	if(user.ckey in team_members)
		if(user.mind.current && user.mind.current.timeofdeath + respawn_cooldown > world.time)
			user << "It must be more than [respawn_cooldown/10] seconds from your last death to respawn!"
			return
		var/client/new_team_member = user.client
		dust_old(user)
		spawn_team_member(new_team_member)
		return

	for(var/obj/machinery/knight/KGT in machines)
		if(KGT == src || KGT.knight_enabled == FALSE)
			continue
		if(user.ckey in KGT.team_members)
			user << "No switching sides, you traitor!"
			return
		if(KGT.team_members.len < src.team_members.len)
			user << "The [src.team] has more crusaders than the [KGT.team]. Try joining the [KGT.team] to even things up."
			return
	team_members |= user.ckey
	var/client/new_team_member = user.client
	dust_old(user)
	spawn_team_member(new_team_member)

/obj/machinery/knight/proc/dust_old(mob/user)
	if(user.mind && user.mind.current && user.mind.current.z == src.z)
		user.mind.current.dust()

/obj/machinery/knight/proc/spawn_team_member(client/new_team_member)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(src))
	new_team_member.prefs.copy_to(M)
	M.key = new_team_member.key
	M.faction += team
	M.equipOutfit(gear)

/datum/outfit/knight
	name = "Knight"
	uniform = /obj/item/clothing/under/color/grey
	suit = /obj/item/clothing/suit/armor/riot/knight
	head = /obj/item/clothing/head/helmet/knight
	shoes = /obj/item/clothing/shoes/roman
	gloves = /obj/item/clothing/gloves/combat
	r_hand = /obj/item/weapon/claymore
	l_hand = /obj/item/weapon/shield/riot/buckler

/datum/outfit/knight/totharene
	uniform = /obj/item/clothing/under/color/red
	suit = /obj/item/clothing/suit/armor/riot/knight/red
	head = /obj/item/clothing/head/helmet/knight/red

/datum/outfit/knight/yatherean
	uniform = /obj/item/clothing/under/color/blue
	suit = /obj/item/clothing/suit/armor/riot/knight/blue
	head = /obj/item/clothing/head/helmet/knight/blue

/obj/structure/divine/trap/knight
	name = "Eternal Barrier"
	desc = "A magical barrier that prevents knights from escaping from their eternal fight."
	icon_state = "trap"
	health = INFINITY
	maxhealth = INFINITY
	var/team = YATH_TEAM
	time_between_triggers = 1
	alpha = 255

/obj/structure/divine/trap/knight/toth
	team = TOTH_TEAM

/obj/structure/divine/trap/knight/trap_effect(mob/living/L)
	if(src.team in L.faction)
		L << "<span class='danger'><B>Who said you could escape your eternal punishment?</B></span>"
		L.dust()



//DARK WIZARD BOSS MOB
//The evil guy getting his kicks watching the two kingdoms fight for eternity
/mob/living/simple_animal/hostile/boss/dark_wizard
	name = "Dark Wizard"
	desc = "The dark wizard who trapped the two kingdoms here, they appear to have gone lichy in their old age"
	boss_abilities = list(/datum/action/boss/wizard_surround, /datum/action/boss/wizard_summon_knights, /datum/action/boss/wizard_slippy)
	faction = list("hostile","dark magicks")
	del_on_death = TRUE
	loot = list(/obj/item/clothing/suit/wizrobe/black,
				/obj/item/clothing/head/wizard/black,
				/obj/effect/decal/remains/human)
	icon_state = "dark_wizard"
	ranged = 1
	minimum_distance = 3
	retreat_distance = 3
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 1000
	maxHealth = 1000
	projectiletype = /obj/item/projectile/magic/pain
	projectilesound = 'sound/weapons/emitter.ogg'
	attack_sound = 'sound/hallucinations/growl1.ogg'
	var/list/copies = list()

//Hit the real guy? copies go bai-bai
/mob/living/simple_animal/hostile/boss/dark_wizard/adjustHealth(amount)
	if(amount > 0)//damage
		minimum_distance = 3
		retreat_distance = 3
		for(var/copy in copies)
			qdel(copy)
	..()



//WIZARD SURROUND
//Surrounds the target with 3 fake wizards, and the real one
//hitting the real one kills the fakes
//hitting a fake deals 50 damage to everyone nearby (except the real wizard)
//this damage will hurt any fallen knights he's summoned, that's how little he cares about them

/mob/living/simple_animal/hostile/boss/dark_wizard/copy
	desc = "tis a ruse!"
	health = 1
	maxHealth = 1
	alpha = 200
	boss_abilities = list()
	melee_damage_lower = 1
	melee_damage_upper = 5
	minimum_distance = 0
	retreat_distance = 0
	ranged = 0
	loot = list() //not even bones, they were never real! ~spook~
	var/mob/living/simple_animal/hostile/boss/dark_wizard/original


//Hit a fake? eat pain!
/mob/living/simple_animal/hostile/boss/dark_wizard/copy/adjustHealth(amount)
	if(amount > 0) //damage
		if(original)
			original.minimum_distance = 3
			original.retreat_distance = 3
			original.copies -= src
			for(var/c in original.copies)
				qdel(c)
		for(var/mob/living/L in range(5,src))
			if(L == original || istype(L, type))
				continue
			L.adjustBruteLoss(50)
		qdel(src)
	else
		..()

/mob/living/simple_animal/hostile/boss/dark_wizard/copy/examine(mob/user)
	..()
	qdel(src) //I see through your ruse!


/datum/action/boss/wizard_surround
	name = "Surround"
	button_icon_state = "wizard_surround"
	usage_probability = 30
	boss_cost = 20
	boss_type = /mob/living/simple_animal/hostile/boss/dark_wizard
	say_when_triggered = ""

/datum/action/boss/wizard_surround/Trigger()
	if(..())
		var/mob/living/target
		if(!boss.client) //AI's target
			target = boss.target
		else //random mob
			var/list/threats = boss.PossibleThreats()
			if(threats.len)
				target = pick(threats)
		if(target)
			var/mob/living/simple_animal/hostile/boss/dark_wizard/wiz = boss
			var/directions = cardinal.Copy()
			for(var/i in 1 to 3)
				var/mob/living/simple_animal/hostile/boss/dark_wizard/copy/C = new (get_step(target,pick_n_take(directions)))
				wiz.copies += C
				C.original = wiz
				C.say("Which one am I? Are you robust enough to find me? Nyeheheh...")
			wiz.say("Which one am I? Are you robust enough to find me? Nyeheheh...")
			wiz.forceMove(get_step(target,pick_n_take(directions)))
			wiz.minimum_distance = 1 //so he doesn't run away and ruin everything
			wiz.retreat_distance = 0
		else
			boss.atb.refund(boss_cost)



//SUMMON KNIGHTS
//Summons 4 AI Knights, 2 from each kingdom

/datum/action/boss/wizard_summon_knights
	name = "Summon Knights"
	button_icon_state = "knight_summon"
	usage_probability = 40
	boss_cost = 40
	boss_type = /mob/living/simple_animal/hostile/boss/dark_wizard
	needs_target = FALSE
	say_when_triggered = "Nyeheheh, knights, to me!"

/datum/action/boss/wizard_summon_knights/Trigger()
	if(..())
		var/list/knights = list(
		/mob/living/simple_animal/hostile/skeleton/templar/dark_wiz/totharene,
		/mob/living/simple_animal/hostile/skeleton/templar/dark_wiz/yatherean,
		/mob/living/simple_animal/hostile/skeleton/templar/dark_wiz/totharene,
		/mob/living/simple_animal/hostile/skeleton/templar/dark_wiz/yatherean)
		var/list/directions = cardinal.Copy()
		for(var/i in 1 to 4)
			var/knight = pick_n_take(knights)
			new knight (get_step(boss,pick_n_take(directions)))


/mob/living/simple_animal/hostile/skeleton/templar/dark_wiz
	faction = list("hostile","dark magicks")
	del_on_death = TRUE
	deathmessage = "The knight collaspes into a pile of bones!"

/mob/living/simple_animal/hostile/skeleton/templar/dark_wiz/totharene
	name = "fallen knight of totharene"
	desc = "they belongs to the dark wizard now..."
	speak = list("For tothar.. the dark wizard!","AAAAAAAAAAAAAAAH")
	icon_state = "toth_knight"
	loot = list(/obj/item/clothing/suit/armor/riot/knight/red,
				/obj/item/weapon/shield/riot/buckler,
				/obj/item/weapon/claymore,
				/obj/effect/decal/remains/human)

/mob/living/simple_animal/hostile/skeleton/templar/dark_wiz/yatherean
	name = "fallen knight of yatherean"
	desc = "they belongs to the dark wizard now..."
	speak = list("For yather.. the dark wizard!","AAAAARRRRGGGGGGH")
	icon_state = "yath_knight"
	loot = list(/obj/item/clothing/suit/armor/riot/knight/blue,
				/obj/item/weapon/shield/riot/buckler,
				/obj/item/weapon/claymore,
				/obj/effect/decal/remains/human)



//WIZARD SLIPPY
//Spawn lube around the wizard
//This is as evil as it sounds
//I can't really say I'm sorry either

/datum/action/boss/wizard_slippy
	name = "Grease" //lightning
	button_icon_state = "grease"
	usage_probability = 20
	boss_cost = 60
	boss_type = /mob/living/simple_animal/hostile/boss/dark_wizard
	say_when_triggered = "Ever been to a water park? this is going to be a bit like that! Nyeheheh..."

/datum/action/boss/wizard_slippy/Trigger()
	if(..())
		for(var/turf/simulated/S in range(5,boss))
			S.MakeSlippery(TURF_WET_LUBE)

