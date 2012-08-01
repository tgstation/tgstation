//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/global/list/player_list = list()//List of all logged in players (Based on mob reference)
var/global/list/admin_list = list()//List of all logged in admins (Based on mob reference)
var/global/list/mob_list = list()//List of all mobs, including clientless
var/global/list/living_mob_list = list()//List of all living mobs, including clientless
var/global/list/dead_mob_list = list()//List of all dead mobs, including clientless
var/global/list/client_list = list()//List of all clients, based on ckey
var/global/list/cable_list = list()//Index for all cables, so that powernets don't have to look through the entire world all the time
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
var/global/list/chemical_reactions_list				//list of all /datum/chemical_reaction datums. Used during chemical reactions
var/global/list/chemical_reagents_list				//list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff

//////////////////////////
/////Initial Building/////
//////////////////////////
//Realistically, these should never be run, but ideally, they should only be run once at round-start

/proc/make_datum_references_lists()
	var/list/paths
	//Hair - Initialise all /datum/sprite_accessory/hair into an list indexed by hair-style name
	paths = typesof(/datum/sprite_accessory/hair) - /datum/sprite_accessory/hair
	for(var/path in paths)
		var/datum/sprite_accessory/hair/H = new path()
		hair_styles_list[H.name] = H
	//Facial Hair - Initialise all /datum/sprite_accessory/facial_hair into an list indexed by facialhair-style name
	paths = typesof(/datum/sprite_accessory/facial_hair) - /datum/sprite_accessory/facial_hair
	for(var/path in paths)
		var/datum/sprite_accessory/facial_hair/H = new path()
		facial_hair_styles_list[H.name] = H

proc/make_player_list()//Global proc that rebuilds the player list
	for(var/mob/p in player_list)//Clears out everyone that logged out
		if(!(p.client))
			player_list -= p
	for(var/mob/M in world)//Adds everyone that has logged in
		if(M.client)
			player_list += M

proc/make_admin_list()//Rebuild that shit to try and avoid issues with stealthmins
	admin_list = list()
	for(var/client/C in client_list)
		if(C && C.holder)
			admin_list += C

proc/make_mob_list()
	for(var/mob/p in mob_list)
		if(!p)//If it's a null reference, remove it
			mob_list -= p
	for(var/mob/M in world)
		mob_list += M

proc/make_extra_mob_list()
	for(var/mob/p in living_mob_list)
		if(!p)
			living_mob_list -= p
		if(p.stat == DEAD)//Transfer
			living_mob_list -= p
			dead_mob_list += p
	for(var/mob/p in dead_mob_list)
		if(!p)
			dead_mob_list -= p
		if(p.stat != DEAD)
			dead_mob_list -= p
			living_mob_list += p
	for(var/mob/M in world)
		if(M.stat == DEAD)
			living_mob_list += M
		else
			dead_mob_list += M


//Alright, this proc should NEVER be called in the code, ever. This is more of an 'oh god everything is broken'-emergency button.
proc/rebuild_mob_lists()
	player_list = list()
	admin_list = list()
	mob_list = list()
	living_mob_list = list()
	dead_mob_list = list()
	client_list = list()
	for(var/mob/M in world)
		mob_list += M
		if(M.client)
			player_list += M
		if(M.stat != DEAD)
			living_mob_list += M
		else
			dead_mob_list += M
	for(var/client/C)
		client_list += C.ckey
		if(C.holder)
			admin_list += C

proc/add_to_mob_list(var/mob/A)//Adds an individual mob
	if(A)
		mob_list |= A
		if(istype(A,/mob/new_player))//New players are only on the mob list, but not the dead/living
			return
		else
			if(A.stat == 2)
				dead_mob_list |= A
			if(A.stat != 2)
				living_mob_list |= A
//		if(A.client)
//			player_list |= A

proc/remove_from_mob_list(var/mob/R)//Removes an individual mob
	mob_list -= R
	if(R.stat == 2)
		dead_mob_list -= R
	if(R.stat != 2)
		living_mob_list -= R
//	if(R.client)
//		player_list -= R

proc/make_client_list()//Rebuilds client list
	for(var/mob/c in client_list)
		if(!c.client)
			client_list -= c.ckey
	for(var/mob/M in world)
		if(M.client)
			client_list += M.ckey



/*/obj/item/listdebug//Quick debugger for the global lists
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "radio-igniter-tank"

/obj/item/listdebug/attack_self()
	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs", "Clients"))
		if("Players")
			usr << dd_list2text(player_list,",")
		if("Admins")
			usr << dd_list2text(admin_list,",")
		if("Mobs")
			usr << dd_list2text(mob_list,",")
		if("Living Mobs")
			usr << dd_list2text(living_mob_list,",")
		if("Dead Mobs")
			usr << dd_list2text(dead_mob_list,",")
		if("Clients")
			usr << dd_list2text(client_list,",")*/