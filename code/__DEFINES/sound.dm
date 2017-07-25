//max channel is 1024. Only go lower from here, because byond tends to pick the first availiable channel to play sounds on
#define CHANNEL_LOBBYMUSIC 1024
#define CHANNEL_ADMIN 1023
#define CHANNEL_VOX 1022
#define CHANNEL_JUKEBOX 1021
#define CHANNEL_JUSTICAR_ARK 1020
#define CHANNEL_HEARTBEAT 1019 //sound channel for heartbeats

//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED

#define CHANNEL_HIGHEST_AVAILABLE 1018


#define SOUND_MINIMUM_PRESSURE 10
#define FALLOFF_SOUNDS 0.5

//BYOND Sound Environment defines

#define SOUND_ENV_DEFAULT			-1
#define SOUND_ENV_GENERIC			0
#define SOUND_ENV_PADDED_CELL		1
#define SOUND_ENV_ROOM				2
#define SOUND_ENV_BATHROOM			3
#define SOUND_ENV_LIVINGROOM		4
#define SOUND_ENV_STONEROOM			5
#define SOUND_ENV_AUDITORIUM		6
#define SOUND_ENV_CONCERT_HALL		7
#define SOUND_ENV_CAVE				8
#define SOUND_ENV_ARENA				9
#define SOUND_ENV_HANGAR			10
#define SOUND_ENV_CARPETTED_HALLWAY	11
#define SOUND_ENV_HALLWAY			12
#define SOUND_ENV_STONE_CORRIDOOR	13
#define SOUND_ENV_ALLEY				14
#define SOUND_ENV_FOREST			15
#define SOUND_ENV_CITY				16
#define SOUND_ENV_MOUNTAINS			17
#define SOUND_ENV_QUARRY			18
#define SOUND_ENV_PLAIN				19
#define SOUND_ENV_PARKING_LOT		20
#define SOUND_ENV_SEWER_PIPE		21
#define SOUND_ENV_UNDERWATER		22
#define SOUND_ENV_DRUGGED			23
#define SOUND_ENV_DIZZY				24
#define SOUND_ENV_PSYCHOTIC			25