//The datum used in mob minds to control the mob's knowledge/affinity in witchcraft.

#define AFFINITY_EARTH 1
#define AFFINITY_FIRE 2
#define AFFINITY_WATER 3
#define AFFINITY_AIR 4
#define AFFINITY_MAGIC 5

var/list/witches = list() //All witches in the game

/datum/witch
	var/mob/witch_mob = null //The owner of the mind this datum is stored in
	var/affinity = 0 //The witch's elemental affinity: either Earth, Fire, Water, Air, or Magic. Controls various abilities and magic.

/datum/witch/New()
	..()
	witches.Add(src)

/datum/witch/Destroy()
	witches.Remove(src)
	..()
