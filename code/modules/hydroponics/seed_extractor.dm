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
	name = "Seed Extractor (Machine Board)"
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
			to_chat(user, "<span class='notice'>You put the seeds from \the [O.name] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>There are no seeds in \the [O.name].</span>")
		return

	else if(seedify(O,-1, src, user))
		to_chat(user, "<span class='notice'>You extract some seeds.</span>")
		return
	else if (istype(O,/obj/item/seeds))
		if(add_seed(O))
			to_chat(user, "<span class='notice'>You add [O] to [src.name].</span>")
			updateUsrDialog()
		return
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, "<span class='warning'>You can't extract any seeds from \the [O.name]!</span>")
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
		to_chat(usr, "<span class='notice'>\The [src] is full.</span>")
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
