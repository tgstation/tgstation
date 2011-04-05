/obj/spell/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain telekinesis for a short while."

	school = "transmutation"
	charge_max = 400
	clothes_req = 1
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	message = "\blue You feel strong! Your mind expands!"
	range = -1 //can affect only the user by default, but with var editing can be a mutate other spell
	var/mutate_duration = 300 //in deciseconds
	var/list/mutation_types = list("hulk","tk") //right now understands only "hulk", "tk", "cold resist", "xray" and "clown"

/obj/spell/mutate/Click()
	..()

	if(!cast_check())
		return

	var/mob/M

	if(range>=0)
		M = input("Choose whom to mutate", "ABRAKADABRA") as mob in view(usr,range)
	else
		M = usr

	if(!M)
		return

	invocation()

	M << text("[message]")
	var/mutation = 0
	for(var/MT in mutation_types)
		switch(MT)
			if("tk")
				mutation |= 1
			if("cold resist")
				mutation |= 2
			if("xray")
				mutation |= 4
			if("hulk")
				mutation |= 8
			if("clown")
				mutation |= 16
	M.mutations |= mutation
	spawn (mutate_duration)
		M.mutations &= ~mutation
	return