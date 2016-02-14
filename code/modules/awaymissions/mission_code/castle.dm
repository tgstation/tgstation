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