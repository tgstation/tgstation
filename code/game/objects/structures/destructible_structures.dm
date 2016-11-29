/obj/structure/destructible //a base for destructible structures
	max_integrity = 100
	obj_integrity = 100
	var/break_message = "<span class='warning'>The strange, admin-y structure breaks!</span>" //The message shown when a structure breaks
	var/break_sound = 'sound/magic/clockwork/invoke_general.ogg' //The sound played when a structure breaks
	var/list/debris = null //Parts left behind when a structure breaks, takes the form of list(path = amount_to_spawn)

/obj/structure/destructible/deconstruct(disassembled = TRUE)
	if(!disassembled)
		if(!(flags & NODECONSTRUCT))
			if(islist(debris))
				for(var/I in debris)
					for(var/i in 1 to debris[I])
						new I (get_turf(src))
		visible_message(break_message)
		playsound(src, break_sound, 50, 1)
	qdel(src)
	return 1
