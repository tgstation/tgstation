// Alien Resin Walls are dense and block line of sight. They should probably be much stronger than they are now. -- TLE

/*/obj/alien/resin/ex_act(severity)
	world << "[severity] - [health]"
	switch(severity)
		if(1.0)
			src.health -= 10
		if(2.0)
			src.health -= 5
		if(3.0)
			src.health -= 1
	if(src.health < 1)
		del(src)
	return*/

/obj/alien/resin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red <B>[src] is struck with [src]!</B>"), 1)
	src.health -= 2
	if(src.health <= 0)
		del(src)