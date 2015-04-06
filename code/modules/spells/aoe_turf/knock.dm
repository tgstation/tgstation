/spell/aoe_turf/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	school = "transmutation"
	charge_max = 100
	spell_flags = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = SpI_WHISPER
	range = 3
	cooldown_min = 20 //20 deciseconds reduction per rank

	hud_state = "wiz_knock"

/spell/aoe_turf/knock/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			spawn(1)
				if(istype(door,/obj/machinery/door/airlock))
					var/obj/machinery/door/airlock/AL = door //casting is important
					AL.locked = 0
				door.open()
	return


//Construct version
/spell/aoe_turf/knock/harvester
	name = "Disintegrate Doors"
	desc = "No door shall stop you."

	spell_flags = CONSTRUCT_CHECK

	charge_max = 100
	invocation = ""
	invocation_type = "silent"
	range = 5

	hud_state = "const_knock"

/spell/aoe_turf/knock/harvester/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			spawn door.cultify()
	return