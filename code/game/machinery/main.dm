/obj/machinery/New()
	..()
	machines.Add(src)

/obj/machinery/Del()
	machines.Remove(src)
	..()

/obj/machinery/proc/process()
	return

/obj/machinery/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(25))
				del(src)
				return
		else
	return

/obj/machinery/blob_act()
	if(prob(50))
		del(src)