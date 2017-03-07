var/list/clients = list()							//all clients
var/list/admins = list()							//all clients whom are admins
var/list/deadmins = list()							//all clients who have used the de-admin verb.
var/list/directory = list()							//all ckeys with associated client
var/list/stealthminID = list()						//reference list with IDs that store ckeys, for stealthmins

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

var/global/list/player_list = list()				//all mobs **with clients attached**. Excludes /mob/new_player
var/global/list/mob_list = list()					//all mobs, including clientless
var/global/list/living_mob_list = list()			//all alive mobs, including clientless. Excludes /mob/new_player
var/global/list/dead_mob_list = list()				//all dead mobs, including clientless. Excludes /mob/new_player
var/global/list/joined_player_list = list()			//all clients that have joined the game at round-start or as a latejoin.
var/global/list/silicon_mobs = list()				//all silicon mobs
var/global/list/pai_list = list()