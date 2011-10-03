/obj/effect/securearea/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			del(src)
			return
		if(3.0)
			return
		else
	return

/obj/effect/securearea/blob_act()
	if (prob(75))
		del(src)
		return
	return


/obj/effect/sign/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			del(src)
			return
		if(3.0)
			return
		else
	return

/obj/effect/sign/blob_act()
	if (prob(75))
		del(src)
		return
	return