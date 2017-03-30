GLOBAL_EMPTY_LIST(clients)							//all clients
GLOBAL_EMPTY_LIST(admins)							//all clients whom are admins
GLOBAL_EMPTY_LIST(deadmins)							//all clients who have used the de-admin verb.
GLOBAL_EMPTY_LIST(directory)							//all ckeys with associated client
GLOBAL_EMPTY_LIST(stealthminID)						//reference list with IDs that store ckeys, for stealthmins

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_EMPTY_LIST(player_list)				//all mobs **with clients attached**. Excludes /mob/dead/new_player
GLOBAL_EMPTY_LIST(mob_list)					//all mobs, including clientless
GLOBAL_EMPTY_LIST(living_mob_list)			//all alive mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_EMPTY_LIST(dead_mob_list)				//all dead mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_EMPTY_LIST(joined_player_list)			//all clients that have joined the game at round-start or as a latejoin.
GLOBAL_EMPTY_LIST(silicon_mobs)				//all silicon mobs
GLOBAL_EMPTY_LIST(pai_list)
GLOBAL_EMPTY_LIST(available_ai_shells)