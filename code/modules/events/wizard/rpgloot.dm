/datum/round_event_control/wizard/rpgloot //its time to minmax your shit
	name = "RPG Loot"
	weight = 3
	typepath = /datum/round_event/wizard/rpgloot/
	max_occurrences = 1
	earliest_start = 0

/datum/round_event/wizard/rpgloot/start()
	var/list/prefixespositive 	= list("greater", "major", "blessed", "superior", "enpowered", "honed", "true", "glorious", "robust")
	var/list/prefixesnegative 	= list("lesser", "minor", "blighted", "inferior", "enfeebled", "rusted", "unsteady", "tragic", "gimped")
	var/list/suffixes			= list("orc-slaying", "elf-slaying", "corgi-slaying", "strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma", "the forest", "the hills", "the plains", "the sea", "the sun", "the moon", "the void", "the world", "the fool", "many secrets", "many tales", "many colors", "rending", "sundering", "the night", "the day")

	for(var/obj/item/I in world)
		if(istype(I,/obj/item/organ/))
			continue
		var/quality = rand(-5,5)
		if(quality > 0)
			I.name = "[pick(prefixespositive)] [I.name] of [pick(suffixes)] +[quality]"
		else if(quality < 0)
			I.name = "[pick(prefixesnegative)] [I.name] of [pick(suffixes)] [quality]"
		else
			I.name = "[I.name] of [pick(suffixes)]"

		I.force 		+= quality
		I.force			= max(0,I.force)
		I.throwforce 	+= quality
		I.throwforce	= max(0,I.throwforce)