/obj/alien/acid/proc/tick()
	ticks += 1
	for(var/mob/O in hearers(src, null))
		O.show_message("\green <B>[src.target] sizzles and begins to melt under the bubbling mess of acid!</B>", 1)
	if(prob(ticks*10))
		for(var/mob/O in hearers(src, null))
			O.show_message("\green <B>[src.target] collapses under its own weight into a puddle of goop and undigested debris!</B>", 1)
//		if(target.occupant) //I tried to fix mechas-with-humans-getting-deleted. Made them unacidable for now.
//			target.ex_act(1)
		del(target)
		del(src)
		return
	spawn(rand(200, 600)) tick()
