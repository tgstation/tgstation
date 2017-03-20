GLOBAL_LIST_INIT(clients, list())							//all clients
GLOBAL_LIST_INIT(admins, list())							//all clients whom are admins
GLOBAL_LIST_INIT(deadmins, list())							//all clients who have used the de-admin verb.
GLOBAL_LIST_INIT(directory, list())							//all ckeys with associated client
GLOBAL_LIST_INIT(stealthminID, list())						//reference list with IDs that store ckeys, for stealthmins

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_LIST_INIT(player_list, list())				//all mobs **with clients attached**. Excludes /mob/dead/new_player
GLOBAL_LIST_INIT(mob_list, list())					//all mobs, including clientless
GLOBAL_LIST_INIT(living_mob_list, list())			//all alive mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_INIT(dead_mob_list, list())				//all dead mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_INIT(joined_player_list, list())			//all clients that have joined the game at round-start or as a latejoin.
GLOBAL_LIST_INIT(silicon_mobs, list())				//all silicon mobs
GLOBAL_LIST_INIT(pai_list, list())