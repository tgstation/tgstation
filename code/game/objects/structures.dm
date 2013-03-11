obj/structure
	icon = 'icons/obj/structures.dmi'

obj/structure/blob_act()
	if(prob(50))
		del(src)

obj/structure/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if(prob(50))
				del(src)
				return
		if(3.0)
			return

obj/structure/meteorhit(obj/O as obj)
	del(src)







