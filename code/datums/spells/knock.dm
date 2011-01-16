/obj/spell/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	school = "transmutation"
	recharge = 100
	clothes_req = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	range = 3

/obj/spell/knock/Click()
	..()

	if(!cast_check())
		return

	invocation()

	for(var/obj/machinery/door/G in oview(usr,range))
		spawn(1)
			G.open()
	return