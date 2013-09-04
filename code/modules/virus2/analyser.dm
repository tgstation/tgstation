/obj/machinery/disease2/diseaseanalyser
	name = "Disease Analyser"
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1

	var/scanning = 0
	var/pause = 0

	var/obj/item/weapon/virusdish/dish = null

/obj/machinery/disease2/diseaseanalyser/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/virusdish))
		var/mob/living/carbon/c = user
		if(!dish)
			dish = I
			c.drop_item()
			I.loc = src
			for(var/mob/M in viewers(src))
				if(M == user)	continue
				M.show_message("\blue [user.name] inserts the [dish.name] in the [src.name]", 3)
		else
			user << "There is already a dish inserted"
	return


/obj/machinery/disease2/diseaseanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(500)

	if(scanning)
		scanning -= 1
		if(scanning == 0)
			var/r = dish.virus2.get_info()

			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src.loc)
			P.info = r
			dish.info = r
			dish.analysed = 1
			if (dish.virus2.addToDB())
				src.state("\The [src.name] states, \"Added new pathogen to database.\"")
			dish.loc = src.loc
			dish = null
			icon_state = "analyser"

			src.state("\The [src.name] prints a sheet of paper")

	else if(dish && !scanning && !pause)
		if(dish.virus2 && dish.growth > 50)
			dish.growth -= 10
			scanning = 5
			icon_state = "analyser_processing"
		else
			pause = 1
			spawn(25)
				dish.loc = src.loc
				dish = null
				src.state("\The [src.name] buzzes")
				pause = 0
	return