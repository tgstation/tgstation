
#define ARCHAEO_BOWL 1
#define ARCHAEO_URN 2
#define ARCHAEO_CUTLERY 3
#define ARCHAEO_STATUETTE 4
#define ARCHAEO_INSTRUMENT 5
#define ARCHAEO_KNIFE 6
#define ARCHAEO_COIN 7
#define ARCHAEO_HANDCUFFS 8
#define ARCHAEO_BEARTRAP 9
#define ARCHAEO_LIGHTER 10
#define ARCHAEO_BOX 11
#define ARCHAEO_GASTANK 12
#define ARCHAEO_TOOL 13
#define ARCHAEO_METAL 14
#define ARCHAEO_PEN 15
#define ARCHAEO_CRYSTAL 16
#define ARCHAEO_CULTBLADE 17
#define ARCHAEO_TELEBEACON 18
#define ARCHAEO_CLAYMORE 19
#define ARCHAEO_CULTROBES 20
#define ARCHAEO_SOULSTONE 21
#define ARCHAEO_SHARD 22
#define ARCHAEO_RODS 23
#define ARCHAEO_STOCKPARTS 24
#define ARCHAEO_KATANA 25
#define ARCHAEO_LASER 26
#define ARCHAEO_GUN 27
#define ARCHAEO_UNKNOWN 28
#define ARCHAEO_FOSSIL 29
#define ARCHAEO_SHELL 30
#define ARCHAEO_PLANT 31
//eggs
//droppings
//footprints
//alien clothing

//DNA sampling from fossils, or a new archaeo type specifically for it?

#define ARTIFACT_REMAINS_HUMANOID 1
#define ARTIFACT_REMAINS_ROBOT 2
#define ARTIFACT_REMAINS_XENO 3
#define ARTIFACT_MACHINERY 4
#define ARTIFACT_OCCULT 5
#define ARTIFACT_SYNDBEACON 6

//?
#define ARTIFACT_HEAL 4
#define ARTIFACT_BIODAM 5
#define ARTIFACT_POWERCHARGE 6
#define ARTIFACT_POWERDRAIN 7
#define ARTIFACT_EMP 8
#define ARTIFACT_PLANTGROW 9
#define ARTIFACT_WEAKEN 10
#define ARTIFACT_SLEEPY 11
#define ARTIFACT_TELEPORT 12
#define ARTIFACT_ROBOHURT 13
#define ARTIFACT_ROBOHEAL 14
#define ARTIFACT_DNASWITCH 15
//#define ARTIFACT_
//#define ARTIFACT_

//descending order of likeliness to spawn
#define DIGSITE_GARDEN 1
#define DIGSITE_ANIMAL 2
#define DIGSITE_HOUSE 3
#define DIGSITE_TECHNICAL 4
#define DIGSITE_TEMPLE 5
#define DIGSITE_WAR 6

/proc/get_responsive_reagent(var/find_type)
	switch(find_type)
		if(ARCHAEO_BOWL)
			return "aluminium"
		if(ARCHAEO_URN)
			return "aluminium"
		if(ARCHAEO_CUTLERY)
			return "aluminium"
		if(ARCHAEO_STATUETTE)
			return "aluminium"
		if(ARCHAEO_INSTRUMENT)
			return "aluminium"
		if(ARCHAEO_COIN)
			return "silicon"
		if(ARCHAEO_HANDCUFFS)
			return "aluminium"
		if(ARCHAEO_BEARTRAP)
			return "aluminium"
		if(ARCHAEO_LIGHTER)
			return "aluminium"
		if(ARCHAEO_BOX)
			return "aluminium"
		if(ARCHAEO_GASTANK)
			return "aluminium"
		if(ARCHAEO_TOOL)
			return "silicon"
		if(ARCHAEO_METAL)
			return "silicon"
		if(ARCHAEO_PEN)
			return "aluminium"
		if(ARCHAEO_CRYSTAL)
			return "helium"
		if(ARCHAEO_CULTBLADE)
			return "neon"
		if(ARCHAEO_TELEBEACON)
			return "neon"
		if(ARCHAEO_CLAYMORE)
			return "silicon"
		if(ARCHAEO_CULTROBES)
			return "neon"
		if(ARCHAEO_SOULSTONE)
			return "helium"
		if(ARCHAEO_SHARD)
			return "helium"
		if(ARCHAEO_RODS)
			return "silicon"
		if(ARCHAEO_STOCKPARTS)
			return "neon"
		if(ARCHAEO_KATANA)
			return "silicon"
		if(ARCHAEO_LASER)
			return "silicon"
		if(ARCHAEO_GUN)
			return "silicon"
		if(ARCHAEO_UNKNOWN)
			return "beryllium"
		if(ARCHAEO_FOSSIL)
			return "carbon"
		if(ARCHAEO_PLANT)
			return "carbon"
	return "chlorine"

//see /turf/simulated/mineral/New() in code/modules/mining/mine_turfs.dm
/proc/get_random_digsite_type()
	return pick(100;DIGSITE_GARDEN,95;DIGSITE_ANIMAL,90;DIGSITE_HOUSE,85;DIGSITE_TECHNICAL,80;DIGSITE_TEMPLE,75;DIGSITE_WAR)

/proc/get_random_find_type(var/digsite)

	var/find_type = 0
	switch(digsite)
		if(DIGSITE_GARDEN)
			find_type = pick(\
			100;ARCHAEO_PLANT,\
			25;ARCHAEO_SHELL,\
			25;ARCHAEO_FOSSIL,\
			5;ARCHAEO_BEARTRAP\
			)
		if(DIGSITE_ANIMAL)
			find_type = pick(\
			100;ARCHAEO_FOSSIL,\
			50;ARCHAEO_SHELL,\
			50;ARCHAEO_PLANT,\
			25;ARCHAEO_BEARTRAP\
			)
		if(DIGSITE_HOUSE)
			find_type = pick(\
			100;ARCHAEO_BOWL,\
			100;ARCHAEO_URN,\
			100;ARCHAEO_CUTLERY,\
			100;ARCHAEO_STATUETTE,\
			100;ARCHAEO_INSTRUMENT,\
			100;ARCHAEO_PEN,\
			100;ARCHAEO_LIGHTER,\
			100;ARCHAEO_BOX,\
			75;ARCHAEO_COIN,\
			75;ARCHAEO_UNKNOWN,\
			50;ARCHAEO_SHARD,\
			50;ARCHAEO_RODS,\
			25;ARCHAEO_METAL\
			)
		if(DIGSITE_TECHNICAL)
			find_type = pick(\
			100;ARCHAEO_METAL,\
			100;ARCHAEO_GASTANK,\
			100;ARCHAEO_TELEBEACON,\
			100;ARCHAEO_TOOL,\
			100;ARCHAEO_STOCKPARTS,\
			75;ARCHAEO_SHARD,\
			75;ARCHAEO_RODS,\
			75;ARCHAEO_UNKNOWN,\
			50;ARCHAEO_HANDCUFFS,\
			50;ARCHAEO_BEARTRAP,\
			)
		if(DIGSITE_TEMPLE)
			find_type = pick(\
			200;ARCHAEO_CULTROBES,\
			100;ARCHAEO_URN,\
			100;ARCHAEO_BOWL,\
			100;ARCHAEO_KNIFE,\
			100;ARCHAEO_CRYSTAL,\
			75;ARCHAEO_CULTBLADE,\
			50;ARCHAEO_SOULSTONE,\
			50;ARCHAEO_UNKNOWN,\
			25;ARCHAEO_HANDCUFFS,\
			25;ARCHAEO_BEARTRAP,\
			10;ARCHAEO_KATANA,\
			10;ARCHAEO_CLAYMORE,\
			10;ARCHAEO_SHARD,\
			10;ARCHAEO_RODS,\
			10;ARCHAEO_METAL\
			)
		if(DIGSITE_WAR)
			find_type = pick(\
			100;ARCHAEO_GUN,\
			100;ARCHAEO_KNIFE,\
			75;ARCHAEO_LASER,\
			75;ARCHAEO_KATANA,\
			75;ARCHAEO_CLAYMORE,\
			50;ARCHAEO_UNKNOWN,\
			50;ARCHAEO_CULTROBES,\
			50;ARCHAEO_CULTBLADE,\
			25;ARCHAEO_HANDCUFFS,\
			25;ARCHAEO_BEARTRAP,\
			25;ARCHAEO_TOOL\
			)
	return find_type

#undef ARCHAEO_BOWL
#undef ARCHAEO_URN
#undef ARCHAEO_CUTLERY
#undef ARCHAEO_STATUETTE
#undef ARCHAEO_INSTRUMENT
#undef ARCHAEO_KNIFE
#undef ARCHAEO_COIN
#undef ARCHAEO_HANDCUFFS
#undef ARCHAEO_BEARTRAP
#undef ARCHAEO_LIGHTER
#undef ARCHAEO_BOX
#undef ARCHAEO_GASTANK
#undef ARCHAEO_TOOL
#undef ARCHAEO_METAL
#undef ARCHAEO_PEN
#undef ARCHAEO_CRYSTAL
#undef ARCHAEO_CULTBLADE
#undef ARCHAEO_TELEBEACON
#undef ARCHAEO_CLAYMORE
#undef ARCHAEO_CULTROBES
#undef ARCHAEO_SOULSTONE
#undef ARCHAEO_SHARD
#undef ARCHAEO_RODS
#undef ARCHAEO_STOCKPARTS
#undef ARCHAEO_KATANA
#undef ARCHAEO_LASER
#undef ARCHAEO_GUN
#undef ARCHAEO_UNKNOWN
#undef ARCHAEO_FOSSIL
#undef ARCHAEO_SHELL
#undef ARCHAEO_PLANT
#undef ARCHAEO_REMAINS_HUMANOID
#undef ARCHAEO_REMAINS_ROBOT
#undef ARCHAEO_REMAINS_XENO

#undef DIGSITE_GARDEN
#undef DIGSITE_ANIMAL
#undef DIGSITE_HOUSE
#undef DIGSITE_TECHNICAL
#undef DIGSITE_TEMPLE
#undef DIGSITE_WAR
