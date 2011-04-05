/obj/spell/conjure
	name = "Summon Bigger Carp"
	desc = "This spell conjures an elite carp."

	school = "conjuration"
	charge_max = 1200
	clothes_req = 1
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = "shout"
	range = 1 //radius in which objects are randomly summoned
	var/list/summon_type = list("/obj/livestock/spesscarp/elite") //determines what exactly will be summoned
	var/summon_duration = 0 // 0=permanent, any other time in deciseconds
	var/summon_amt = 1 //amount of objects summoned
	var/summon_ignore_density = 0 //if set to 1, adds dense tiles to possible spawn places
	var/summon_ignore_prev_spawn_points = 0 //if set to 1, each new object is summoned on a new spawn point

/obj/spell/conjure/Click()
	..()

	if(!cast_check())
		return

	invocation()

	var/list/possible_spawn_points = list()

	for(var/turf/T in oview(usr,range))
		if(!T.density || summon_ignore_density)
			possible_spawn_points += T

	for(var/i=0,i<summon_amt,i++)
		if(!possible_spawn_points.len)
			break
		var/summoned_object_type = text2path(pick(summon_type))
		var/spawn_place = pick(possible_spawn_points)
		if(summon_ignore_prev_spawn_points)
			possible_spawn_points -= spawn_place
		var/summoned_object = new summoned_object_type(spawn_place)
		if(summon_duration)
			spawn(summon_duration)
				if(summoned_object)
					del(summoned_object)

	return