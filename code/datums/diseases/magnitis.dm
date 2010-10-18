/datum/disease/magnitis
	name = "Magnitis"
	max_stages = 4
	spread = "Airborne"
	cure = "Iron"
	agent = "Fukkos Miracos"
	affected_species = list("Human")
	curable = 0

/datum/disease/magnitis/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob << "\red You feel a slight shock course through your body."
			if(prob(2))
				for(var/obj/M in orange(2,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						step_towards(M,affected_mob)
						/*
						if(M.x > affected_mob.x)
							M.x--
						else if(M.x < affected_mob.x)
							M.x++
						if(M.y > affected_mob.y)
							M.y--
						else if(M.y < affected_mob.y)
							M.y++
						*/
		if(3)
			if(prob(2))
				affected_mob << "\red You feel a strong shock course through your body."
			if(prob(2))
				affected_mob << "\red You feel like clowning around."
			if(prob(4))
				for(var/obj/M in orange(4,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						var/i
						var/iter = rand(1,2)
						for(i=0,i<iter,i++)
							step_towards(M,affected_mob)
						/*
						if(M.x > affected_mob.x)
							M.x-=rand(1,min(3,M.x-affected_mob.x))
						else if(M.x < affected_mob.x)
							M.x+=rand(1,min(3,affected_mob.x-M.x))
						if(M.y > affected_mob.y)
							M.y-=rand(1,min(3,M.y-affected_mob.y))
						else if(M.y < affected_mob.y)
							M.y+=rand(1,min(3,affected_mob.y-M.y))
						*/
		if(4)
			if(prob(2))
				affected_mob << "\red You feel a powerful shock course through your body."
			if(prob(2))
				affected_mob << "\red You query upon the nature of miracles."
			if(prob(8))
				for(var/obj/M in orange(6,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						var/i
						var/iter = rand(1,3)
						for(i=0,i<iter,i++)
							step_towards(M,affected_mob)
						/*
						if(M.x > affected_mob.x)
							M.x-=rand(1,min(5,M.x-affected_mob.x))
						else if(M.x < affected_mob.x)
							M.x+=rand(1,min(5,affected_mob.x-M.x))
						if(M.y > affected_mob.y)
							M.y-=rand(1,min(5,M.y-affected_mob.y))
						else if(M.y < affected_mob.y)
							M.y+=rand(1,min(5,affected_mob.y-M.y))
						*/
	return