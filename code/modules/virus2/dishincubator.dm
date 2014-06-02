/obj/machinery/disease2/incubator/
	name = "Pathogenic incubator"
	density = 1
	anchored = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"
	var/obj/item/weapon/virusdish/dish
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/radiation = 0

	var/on = 0
	var/power = 0

	var/foodsupply = 0
	var/toxins = 0

	var/virusing

/obj/machinery/disease2/incubator/attackby(var/obj/B as obj, var/mob/user as mob)
	if(istype(B, /obj/item/weapon/reagent_containers/glass) || istype(B,/obj/item/weapon/reagent_containers/syringe))

		if(src.beaker)
			if(istype(beaker,/obj/item/weapon/reagent_containers/syringe))
				user << "A syringe is already loaded into the machine."
			else
				user << "A beaker is already loaded into the machine."
			return

		src.beaker =  B
		user.drop_item()
		B.loc = src
		if(istype(B,/obj/item/weapon/reagent_containers/syringe))
			user << "You add the syringe to the machine!"
			src.updateUsrDialog()
		else
			user << "You add the beaker to the machine!"
			src.updateUsrDialog()
	else
		if(istype(B,/obj/item/weapon/virusdish))
			if(src.dish)
				user << "A dish is already loaded into the machine."
				return

			src.dish =  B
			user.drop_item()
			B.loc = src
			if(istype(B,/obj/item/weapon/virusdish))
				user << "You add the dish to the machine!"
				src.updateUsrDialog()

/obj/machinery/disease2/incubator/Topic(href, href_list)
	if(..()) return

	if(usr) usr.set_machine(src)

	if (href_list["ejectchem"])
		if(beaker)
			beaker.loc = src.loc
			beaker = null
	if(!dish)
		return
	if (href_list["power"])
		on = !on
		if(on)
			icon_state = "incubator_on"
		else
			icon_state = "incubator"
	if (href_list["ejectdish"])
		if(dish)
			dish.loc = src.loc
			dish = null
	if (href_list["rad"])
		radiation += 10
	if (href_list["flush"])
		radiation = 0
		toxins = 0
		foodsupply = 0

	if(href_list["virus"])
		if (!dish)
			state("\The [src.name] buzzes, \"No viral culture sample detected.\"", "blue")
		else
			var/datum/reagent/blood/B = locate(/datum/reagent/blood) in beaker.reagents.reagent_list
			if (!B)
				state("\The [src.name] buzzes, \"No suitable breeding enviroment detected.\"", "blue")
			else
				if (!B.data["virus2"])
					B.data["virus2"] = list()
				var/list/virus = list("[dish.virus2.uniqueID]" = dish.virus2.getcopy())
				B.data["virus2"] = virus

				state("\The [src.name] pings, \"Injection complete.\"", "blue")


	src.add_fingerprint(usr)
	src.updateUsrDialog()

/obj/machinery/disease2/incubator/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	user.set_machine(src)
	var/dat = ""
	if(!dish)
		dat = "Please insert dish into the incubator.<BR>"
	var/string = "Off"
	if(on)
		string = "On"
	dat += "Power status : <A href='?src=\ref[src];power=1'>[string]</a>"
	dat += "<BR>"
	dat += "Food supply : [foodsupply]"
	dat += "<BR>"
	dat += "Radiation Levels : [radiation] RADS : <A href='?src=\ref[src];rad=1'>Radiate</a>"
	dat += "<BR>"
	dat += "Toxins : [toxins]"
	dat += "<BR><BR>"
	if(beaker)
		dat += "Eject chemicals : <A href='?src=\ref[src];ejectchem=1'> Eject</a>"
		dat += "<BR>"
	if(dish)
		dat += "Eject Virus dish : <A href='?src=\ref[src];ejectdish=1'> Eject</a>"
		dat += "<BR>"
		if(beaker)
			dat += "Breed viral culture in beaker : <A href='?src=\ref[src];virus=1'> Start</a>"
			dat += "<BR>"
	dat += "<BR><BR>"
	dat += "<A href='?src=\ref[src];flush=1'>Flush system</a><BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	user << browse("<TITLE>Pathogenic incubator</TITLE>incubator menu:<BR><BR>[dat]", "window=incubator;size=575x400")
	onclose(user, "incubator")
	return

/obj/machinery/disease2/incubator/process()
	if(dish && on && dish.virus2)
		use_power(50,EQUIP)
		if(!powered(EQUIP))
			on = 0
			icon_state = "incubator"
		if(foodsupply)
			foodsupply -= 1
			dish.growth += 3
			if(dish.growth >= 100)
				state("The [src.name] pings", "blue")
		if(radiation)
			if(radiation > 50 & prob(5))
				dish.virus2.majormutate()
				if(dish.info)
					dish.info = "OUTDATED : [dish.info]"
					dish.analysed = 0
				state("The [src.name] beeps", "blue")

			else if(prob(5))
				dish.virus2.minormutate()
			radiation -= 1
		if(toxins && prob(5))
			dish.virus2.infectionchance -= 1
		if(toxins > 50)
			dish.virus2 = null
	else if(!dish)
		on = 0
		icon_state = "incubator"

	if(beaker)
		if(!beaker.reagents.remove_reagent("virusfood",5))
			foodsupply += 10
		if(!beaker.reagents.remove_reagent("toxin",1))
			toxins += 1

	src.updateUsrDialog()