<<<<<<< HEAD
/proc/seedify(obj/item/O, t_max, obj/machinery/seed_extractor/extractor, mob/living/user)
	var/t_amount = 0
	if(t_max == -1)
		if(extractor)
			t_max = rand(1,4) * extractor.seed_multiplier
		else
			t_max = rand(1,4)

	var/seedloc = O.loc
	if(extractor)
		seedloc = extractor.loc

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
		if(F.seed)
			if(user && !user.drop_item()) //couldn't drop the item
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.loc = seedloc
				t_amount++
			qdel(O)
			return 1

	else if(istype(O, /obj/item/weapon/grown))
		var/obj/item/weapon/grown/F = O
		if(F.seed)
			if(user && !user.drop_item())
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.loc = seedloc
				t_amount++
			qdel(O)
		return 1

	return 0


/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	var/piles = list()
	var/max_seeds = 1000
	var/seed_multiplier = 1

/obj/machinery/seed_extractor/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/seed_extractor(null)
	B.apply_default_parts(src)

/obj/item/weapon/circuitboard/machine/seed_extractor
	name = "circuit board (Seed Extractor)"
	build_path = /obj/machinery/seed_extractor
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/manipulator = 1)

/obj/machinery/seed_extractor/RefreshParts()
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		max_seeds = 1000 * B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		seed_multiplier = M.rating

/obj/machinery/seed_extractor/attackby(obj/item/O, mob/user, params)

	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if (istype(O,/obj/item/weapon/storage/bag/plants))
		var/obj/item/weapon/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			if(contents.len >= max_seeds)
				break
			++loaded
			add_seed(G)
		if (loaded)
			user << "<span class='notice'>You put the seeds from \the [O.name] into [src].</span>"
		else
			user << "<span class='notice'>There are no seeds in \the [O.name].</span>"
		return

	else if(seedify(O,-1, src, user))
		user << "<span class='notice'>You extract some seeds.</span>"
		return
	else if (istype(O,/obj/item/seeds))
		if(add_seed(O))
			user << "<span class='notice'>You add [O] to [src.name].</span>"
			updateUsrDialog()
		return
	else if(user.a_intent != "harm")
		user << "<span class='warning'>You can't extract any seeds from \the [O.name]!</span>"
	else
		return ..()

/datum/seed_pile
	var/name = ""
	var/lifespan = 0	//Saved stats
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = 0
	var/amount = 0

/datum/seed_pile/New(var/name, var/life, var/endur, var/matur, var/prod, var/yie, var/poten, var/am = 1)
	src.name = name
	src.lifespan = life
	src.endurance = endur
	src.maturation = matur
	src.production = prod
	src.yield = yie
	src.potency = poten
	src.amount = am

/obj/machinery/seed_extractor/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/seed_extractor/interact(mob/user)
	if (stat)
		return 0

	var/dat = "<b>Stored seeds:</b><br>"

	if (contents.len == 0)
		dat += "<font color='red'>No seeds</font>"
	else
		dat += "<table cellpadding='3' style='text-align:center;'><tr><td>Name</td><td>Lifespan</td><td>Endurance</td><td>Maturation</td><td>Production</td><td>Yield</td><td>Potency</td><td>Stock</td></tr>"
		for (var/datum/seed_pile/O in piles)
			dat += "<tr><td>[O.name]</td><td>[O.lifespan]</td><td>[O.endurance]</td><td>[O.maturation]</td>"
			dat += "<td>[O.production]</td><td>[O.yield]</td><td>[O.potency]</td><td>"
			dat += "<a href='byond://?src=\ref[src];name=[O.name];li=[O.lifespan];en=[O.endurance];ma=[O.maturation];pr=[O.production];yi=[O.yield];pot=[O.potency]'>Vend</a> ([O.amount] left)</td></tr>"
		dat += "</table>"
	var/datum/browser/popup = new(user, "seed_ext", name, 700, 400)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/seed_extractor/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)

	href_list["li"] = text2num(href_list["li"])
	href_list["en"] = text2num(href_list["en"])
	href_list["ma"] = text2num(href_list["ma"])
	href_list["pr"] = text2num(href_list["pr"])
	href_list["yi"] = text2num(href_list["yi"])
	href_list["pot"] = text2num(href_list["pot"])

	for (var/datum/seed_pile/N in piles)//Find the pile we need to reduce...
		if (href_list["name"] == N.name && href_list["li"] == N.lifespan && href_list["en"] == N.endurance && href_list["ma"] == N.maturation && href_list["pr"] == N.production && href_list["yi"] == N.yield && href_list["pot"] == N.potency)
			if(N.amount <= 0)
				return
			N.amount = max(N.amount - 1, 0)
			if (N.amount <= 0)
				piles -= N
				qdel(N)
			break

	for (var/obj/T in contents)//Now we find the seed we need to vend
		var/obj/item/seeds/O = T
		if (O.plantname == href_list["name"] && O.lifespan == href_list["li"] && O.endurance == href_list["en"] && O.maturation == href_list["ma"] && O.production == href_list["pr"] && O.yield == href_list["yi"] && O.potency == href_list["pot"])
			O.loc = src.loc
			break

	src.updateUsrDialog()
	return

/obj/machinery/seed_extractor/proc/add_seed(obj/item/seeds/O)
	if(contents.len >= 999)
		usr << "<span class='notice'>\The [src] is full.</span>"
		return 0

	if(istype(O.loc,/mob))
		var/mob/M = O.loc
		if(!M.drop_item())
			return 0
	else if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.loc = src
	. = 1
	for (var/datum/seed_pile/N in piles)
		if (O.plantname == N.name && O.lifespan == N.lifespan && O.endurance == N.endurance && O.maturation == N.maturation && O.production == N.production && O.yield == N.yield && O.potency == N.potency)
			++N.amount
			return

	piles += new /datum/seed_pile(O.plantname, O.lifespan, O.endurance, O.maturation, O.production, O.yield, O.potency)
	return
=======
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

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL

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
		user.drop_item(force_drop = 1)
		moveToStorage(O)
		to_chat(user, "<span class='notice'>You add [O] to [src.name].</span>")
		updateUsrDialog()
		return

	// Fruits and vegetables.
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown) || istype(O, /obj/item/weapon/grown))

		user.drop_item(O, force_drop = 1)

		var/datum/seed/new_seed_type
		if(istype(O, /obj/item/weapon/grown))
			var/obj/item/weapon/grown/F = O
			new_seed_type = plant_controller.seeds[F.plantname]
		else
			var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
			new_seed_type = plant_controller.seeds[F.plantname]

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
			user.drop_item(O, force_drop = 1)
			var/t_amount = 0
			var/t_max = rand(1,4)
			while(t_amount < t_max)
				new F.nonplant_seed_type(src.loc)
				t_amount++
			qdel(F)

	..()

	return

//Code shamelessly ported over and adapted from tgstation's github repo, PR #2973, credit to Kelenius for the original code
datum/seed_pile //Maybe there's a better way to do this.
	var/datum/seed/seed
	var/amount

datum/seed_pile/New(var/seed, var/amount = 1)
	src.seed = seed
	src.amount = amount

/obj/machinery/seed_extractor/attack_hand(mob/user as mob)
	interact(user)

obj/machinery/seed_extractor/interact(mob/user as mob)
	if (stat)
		return 0

	user.set_machine(src)

	var/dat = list()

	dat += "<b>Stored seeds:</b><br>"

	if (contents.len == 0)
		dat += "<font color='red'>No seeds in storage!</font>"
	else
		dat += "<table cellpadding='3' style='text-align:center;'><tr><td width=300>Name</td><td>Lifespan</td><td>Endurance</td><td>Maturation</td><td>Production</td><td>Yield</td><td>Potency</td><td width=180>Stock</td><td width=250>Notes (Mouseover for Info)</td></tr>"
		for (var/datum/seed_pile/P in piles)
			dat += "<tr><td width=300>[P.seed.display_name][P.seed.roundstart ? "":" (#[P.seed.uid])"]</td><td>[P.seed.lifespan]</td><td>[P.seed.endurance]</td><td>[P.seed.maturation]</td>"
			dat += "<td>[P.seed.production]</td><td>[P.seed.yield]</td><td>[P.seed.potency]</td><td width=180>"
			dat += "<a href='byond://?src=\ref[src];seed=[P.seed.name];amt=1'>Vend</a>"
			dat += "<a href='byond://?src=\ref[src];seed=[P.seed.name];amt=5'>5x</a>"
			dat += "<a href='byond://?src=\ref[src];seed=[P.seed.name];amt=[P.amount]'>All</a>"
			dat += "([P.amount] left)</td><td width=250> "
			if(P.seed.biolum && P.seed.biolum_colour)
				dat += "<span title=\"This plant is bioluminescent.\" color=[P.seed.biolum_colour]>LUM </span>"
			switch(P.seed.spread)
				if(1)
					dat += "<span title=\"This plant is capable of growing beyond the confines of a tray.\">CREEP </span>"
				if(2)
					dat += "<span title=\"This plant is a robust and vigorous vine that will spread rapidly.\">VINE </span>"
			switch(P.seed.carnivorous)
				if(1)
					dat += "<span title=\"This plant is carnivorous and will eat tray pests for sustenance.\">CARN </span>"
				if(2)
					dat += "<span title=\"This plant is carnivorous and poses a significant threat to living things around it.\">HCARN </span>"
			switch(P.seed.juicy)
				if(1)
					dat += "<span title=\"This plant's fruit is soft-skinned and abudantly juicy\">SPLAT</span>"
				if(2)
					dat += "<span title=\"This plant's fruit is excesively soft and juicy.\">SLIP </span>"
			if(P.seed.immutable > 0)    dat += "<span title=\"This plant does not possess genetics that are alterable.\">NOMUT </span>"
			if(P.seed.parasite)   		dat += "<span title=\"This plant is capable of parisitizing and gaining sustenance from tray weeds.\">PARA </span>"
			if(P.seed.hematophage)  	dat += "<span title=\"This plant is a highly specialized hematophage that will only draw nutrients from blood.\">BLOOD </span>"
			if(P.seed.alter_temp)   	dat += "<span title=\"This plant will gradually alter the local room temperature to match it's ideal habitat.\">TEMP </span>"
			if(P.seed.exude_gasses.len) dat += "<span title=\"This plant will exude gas into the environment.\">GAS </span>"
			if(P.seed.thorny)    		dat += "<span title=\"This plant possesses a cover of sharp thorns.\">THORN </span>"
			if(P.seed.stinging)			dat += "<span title=\"This plant possesses a cover of fine stingers capable of releasing chemicals on touch.\">STING </span>"
			if(P.seed.ligneous)   		dat += "<span title=\"This is a ligneous plant with strong and robust stems.\">WOOD </span>"
			if(P.seed.teleporting) 		dat += "<span title=\"This plant possesses a high degree of temporal/spatial instability and may cause spontaneous bluespace disruptions.\">TELE </span>"
			dat += "</td>"
		dat += "</table>"
	dat = jointext(dat,"")
	var/datum/browser/popup = new(user, "seed_ext", name, 1000, 400)
	popup.set_content(dat)
	popup.open()
	return

obj/machinery/seed_extractor/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)

	var/amt = text2num(href_list["amt"])
	var/datum/seed/S = plant_controller.seeds[href_list["seed"]]

	for(var/datum/seed_pile/P in piles)
		if(P.seed == S)
			if(P.amount <= 0)
				return
			P.amount -= amt
			if (P.amount <= 0)
				piles -= P
				qdel(P)
			break

	for (var/obj/item/seeds/O in contents) //Now we find the seed we need to vend
		//if (O.seed.display_name == href_list["name"] && O.seed.lifespan == href_list["li"] && O.seed.endurance == href_list["en"] && O.seed.maturation == href_list["ma"] && O.seed.production == href_list["pr"] && O.seed.yield == href_list["yi"] && O.seed.potency == href_list["pot"] && href_list["biolum_colour"] == O.seed.biolum_colour && href_list["gasexude"] == O.seed.exude_gasses.len && O.seed.spread == href_list["spread"] && O.seed.alter_temp == href_list["alter_temp"] && O.seed.carnivorous == href_list["carnivorous"] && O.seed.parasite == href_list["parasite"] && O.seed.hematophage == href_list["hematophage"] && O.seed.thorny == href_list["thorny"] && O.seed.stinging == href_list["stinging"] && O.seed.ligneous == href_list["ligneous"] && O.seed.teleporting == href_list["teleporting"] && O.seed.juicy == href_list["juicy"]) //If the spaghetti above wasn't proof enough, the length of of this line alone should tell you that something is probably very very wrong here and this whole fucking file probably shouldn't work the way it does. What it SHOULD do is just store the seed datum itself and check the stored seed's seed datum, which would be infinitely simpler. However, since no other machines use or are dependent on this shitcode, and due to the fact that seed datums will likely not be re-structured much if at all in the future, to that I say fuck it, it just werks. Sincerely, please don't git blame me I only intended well, oh god don't take my pomfcoins way no i didn't even come up with this system originally i just ported it and lazily expanded it please okay there I made it not shit chickenman no
		if(O.seed == S)
			O.forceMove(src.loc)
			amt--
			if (amt <= 0) break

	src.updateUsrDialog()
	return

obj/machinery/seed_extractor/proc/moveToStorage(var/obj/item/seeds/O as obj)
	if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.forceMove(src)

	for(var/datum/seed_pile/P in piles)
		if(P.seed == O.seed)
			P.amount++
			return
	piles += new /datum/seed_pile(O.seed)

obj/machinery/seed_extractor/proc/hasSpaceCheck(mob/user as mob)
	if(contents.len >= MAX_N_OF_ITEMS)
		to_chat(user, "<span class='notice'>\The [src] is full.</span>")
		return 0
	else return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
