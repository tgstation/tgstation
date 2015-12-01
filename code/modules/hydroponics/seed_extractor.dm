/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	var/piles = list()

	var/min_seeds = 1 //better manipulators improve this
	var/max_seeds = 4 //better scanning modules improve this

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

/********************************************************************
**   Adding Stock Parts to VV so preconstructed shit has its candy **
********************************************************************/
/obj/machinery/seed_extractor/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/seed_extractor,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/seed_extractor/RefreshParts()
	var/B=0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		B += (M.rating-1)*0.5
	min_seeds=1+B

	B=0
	for(var/obj/item/weapon/stock_parts/scanning_module/M in component_parts)
		B += M.rating-1
	max_seeds=4+B

obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob)

	// Emptying a plant bag
	if (istype(O,/obj/item/weapon/storage/bag/plants))
		if (!hasSpaceCheck(user))
			return
		var/obj/item/weapon/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			++loaded
			moveToStorage(G)
			if(contents.len >= MAX_N_OF_ITEMS)
				to_chat(user, "<span class='notice'>You fill \the [src] to the brim.</span>")
				return
		if (loaded)
			to_chat(user, "<span class='notice'>You put the seeds from \the [O.name] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>There are no seeds in \the [O.name].</span>")
		return

	// Loading individual seeds into the machine
	if (istype(O,/obj/item/seeds))
		if (!hasSpaceCheck(user))
			return
		user.drop_item()
		moveToStorage(O)
		to_chat(user, "<span class='notice'>You add [O] to [src.name].</span>")
		updateUsrDialog()
		return

	// Fruits and vegetables.
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown) || istype(O, /obj/item/weapon/grown))

		user.drop_item(O)

		var/datum/seed/new_seed_type
		if(istype(O, /obj/item/weapon/grown))
			var/obj/item/weapon/grown/F = O
			new_seed_type = seed_types[F.plantname]
		else
			var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
			new_seed_type = seed_types[F.plantname]

		if(new_seed_type)
			to_chat(user, "<span class='notice'>You extract some seeds from [O].</span>")
			var/produce = rand(min_seeds,max_seeds)
			for(var/i = 0;i<=produce;i++)
				var/obj/item/seeds/seeds = new(get_turf(src))
				seeds.seed_type = new_seed_type.name
				seeds.update_seed()
		else
			to_chat(user, "[O] doesn't seem to have any usable seeds inside it.")

		qdel(O)

	//Grass. //Why isn't this using the nonplant_seed_type functionality below?
	else if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		to_chat(user, "<span class='notice'>You extract some seeds from the [S.name].</span>")
		S.use(1)
		new /obj/item/seeds/grassseed(loc)

	if(O)
		var/obj/item/F = O
		if(F.nonplant_seed_type)
			to_chat(user, "<span class='notice'>You extract some seeds from the [F.name].</span>")
			user.drop_item(O)
			var/t_amount = 0
			var/t_max = rand(1,4)
			while(t_amount < t_max)
				new F.nonplant_seed_type(src.loc)
				t_amount++
			qdel(F)

	..()

	return
//Code shamelessly ported over from tgstation's github repo, PR #2973, credit to Kelenius for the original code
datum/seed_pile
	var/name = ""
	var/lifespan = 0	//Saved stats
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = 0
	var/amount = 0

datum/seed_pile/New(var/name, var/life, var/endur, var/matur, var/prod, var/yie, var/poten, var/am = 1)
	src.name = name
	src.lifespan = life
	src.endurance = endur
	src.maturation = matur
	src.production = prod
	src.yield = yie
	src.potency = poten
	src.amount = am

/obj/machinery/seed_extractor/attack_hand(mob/user as mob)
	interact(user)

obj/machinery/seed_extractor/interact(mob/user as mob)
	if (stat)
		return 0

	user.set_machine(src)

	var/dat = "<b>Stored seeds:</b><br>"

	if (contents.len == 0)
		dat += "<font color='red'>No seeds in storage!</font>"
	else
		dat += "<table cellpadding='3' style='text-align:center;'><tr><td>Name</td><td>Lifespan</td><td>Endurance</td><td>Maturation</td><td>Production</td><td>Yield</td><td>Potency</td><td>Stock</td></tr>"
		for (var/datum/seed_pile/O in piles)
			dat += "<tr><td>[O.name]</td><td>[O.lifespan]</td><td>[O.endurance]</td><td>[O.maturation]</td>"
			dat += "<td>[O.production]</td><td>[O.yield]</td><td>[O.potency]</td><td>"
			dat += "<a href='byond://?src=\ref[src];name=[O.name];li=[O.lifespan];en=[O.endurance];ma=[O.maturation];pr=[O.production];yi=[O.yield];pot=[O.potency];amt=1'>Vend</a>"
			dat += "<a href='byond://?src=\ref[src];name=[O.name];li=[O.lifespan];en=[O.endurance];ma=[O.maturation];pr=[O.production];yi=[O.yield];pot=[O.potency];amt=5'>5x</a>"
			dat += "<a href='byond://?src=\ref[src];name=[O.name];li=[O.lifespan];en=[O.endurance];ma=[O.maturation];pr=[O.production];yi=[O.yield];pot=[O.potency];amt=[O.amount]'>All</a>"
			dat += "([O.amount] left)</td></tr>"
		dat += "</table>"
	var/datum/browser/popup = new(user, "seed_ext", name, 725, 400)
	popup.set_content(dat)
	popup.open()
	return

obj/machinery/seed_extractor/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)

	href_list["li"] = text2num(href_list["li"])
	href_list["en"] = text2num(href_list["en"])
	href_list["ma"] = text2num(href_list["ma"])
	href_list["pr"] = text2num(href_list["pr"])
	href_list["yi"] = text2num(href_list["yi"])
	href_list["pot"] = text2num(href_list["pot"])
	var/amt = text2num(href_list["amt"])

	for (var/datum/seed_pile/N in piles)//Find the pile we need to reduce...
		if (href_list["name"] == N.name && href_list["li"] == N.lifespan && href_list["en"] == N.endurance && href_list["ma"] == N.maturation && href_list["pr"] == N.production && href_list["yi"] == N.yield && href_list["pot"] == N.potency)
			if(N.amount <= 0)
				return
			N.amount = max(N.amount - amt, 0)
			if (N.amount <= 0)
				piles -= N
				del(N)
			break

	for (var/obj/T in contents)//Now we find the seed we need to vend
		var/obj/item/seeds/O = T
		if (O.seed.display_name == href_list["name"] && O.seed.lifespan == href_list["li"] && O.seed.endurance == href_list["en"] && O.seed.maturation == href_list["ma"] && O.seed.production == href_list["pr"] && O.seed.yield == href_list["yi"] && O.seed.potency == href_list["pot"]) //Boy this sure is a long line, let's have this comment stretch it out even more!
			O.loc = src.loc
			amt--
			if (amt <= 0) break

	src.updateUsrDialog()
	return

obj/machinery/seed_extractor/proc/moveToStorage(var/obj/item/seeds/O as obj)
	if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.loc = src

	for (var/datum/seed_pile/N in piles)
		if (O.seed.display_name == N.name && O.seed.lifespan == N.lifespan && O.seed.endurance == N.endurance && O.seed.maturation == N.maturation && O.seed.production == N.production && O.seed.yield == N.yield && O.seed.potency == N.potency)
			++N.amount
			return

	piles += new /datum/seed_pile(O.seed.display_name, O.seed.lifespan, O.seed.endurance, O.seed.maturation, O.seed.production, O.seed.yield, O.seed.potency)
	return

obj/machinery/seed_extractor/proc/hasSpaceCheck(mob/user as mob)
	if(contents.len >= MAX_N_OF_ITEMS)
		to_chat(user, "<span class='notice'>\The [src] is full.</span>")
		return 0
	else return 1