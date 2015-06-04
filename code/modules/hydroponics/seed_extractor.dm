/proc/seedify(var/obj/item/O as obj, var/t_max)
	var/t_amount = 0
	if(t_max == -1)
		t_max = rand(1,4)

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown/))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
		while(t_amount < t_max)
			var/obj/item/seeds/t_prod = new F.seed(O.loc, O)
			t_prod.lifespan = F.lifespan
			t_prod.endurance = F.endurance
			t_prod.maturation = F.maturation
			t_prod.production = F.production
			t_prod.yield = F.yield
			t_prod.potency = F.potency
			t_amount++
		qdel(O)
		return 1

	else if(istype(O, /obj/item/weapon/grown/))
		var/obj/item/weapon/grown/F = O
		if(F.seed)
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = new F.seed(O.loc, O)
				t_prod.lifespan = F.lifespan
				t_prod.endurance = F.endurance
				t_prod.maturation = F.maturation
				t_prod.production = F.production
				t_prod.yield = F.yield
				t_prod.potency = F.potency
				t_amount++
			qdel(O)
			return 1
		else return 0

	/*else if(istype(O, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/S = O
		new /obj/item/seeds/grassseed(O.loc)
		S.use(1)
		return 1*/

	else
		return 0


/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = 1
	anchored = 1
	var/piles = list()

/obj/machinery/seed_extractor/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(isrobot(user))
		return

	if (istype(O,/obj/item/weapon/storage/bag/plants))
		var/obj/item/weapon/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			if(contents.len >= 999)
				break
			++loaded
			add(G)
		if (loaded)
			user << "<span class='notice'>You put the seeds from \the [O.name] into [src].</span>"
		else
			user << "<span class='notice'>There are no seeds in \the [O.name].</span>"
		return

	if(!user.drop_item()) //couldn't drop the item
		user << "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the seed extractor!</span>"
		return

	if(O && O.loc)
		O.loc = src.loc

	if(seedify(O,-1))
		user << "<span class='notice'>You extract some seeds.</span>"
		return
	else if (istype(O,/obj/item/seeds))
		add(O)
		user << "<span class='notice'>You add [O] to [src.name].</span>"
		updateUsrDialog()
		return
	else
		user << "<span class='warning'>You can't extract any seeds from \the [O.name]!</span>"

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

/obj/machinery/seed_extractor/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/seed_extractor/interact(mob/user as mob)
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
				del(N)
			break

	for (var/obj/T in contents)//Now we find the seed we need to vend
		var/obj/item/seeds/O = T
		if (O.plantname == href_list["name"] && O.lifespan == href_list["li"] && O.endurance == href_list["en"] && O.maturation == href_list["ma"] && O.production == href_list["pr"] && O.yield == href_list["yi"] && O.potency == href_list["pot"])
			O.loc = src.loc
			break

	src.updateUsrDialog()
	return

/obj/machinery/seed_extractor/proc/add(var/obj/item/seeds/O as obj)
	if(contents.len >= 999)
		usr << "<span class='notice'>\The [src] is full.</span>"
		return 0

	if(istype(O.loc,/mob))
		var/mob/M = O.loc
		if(!M.unEquip(O))
			usr << "<span class='warning'>\the [O] is stuck to your hand, you cannot put it in \the [src]!</span>"
			return
	else if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.loc = src

	for (var/datum/seed_pile/N in piles)
		if (O.plantname == N.name && O.lifespan == N.lifespan && O.endurance == N.endurance && O.maturation == N.maturation && O.production == N.production && O.yield == N.yield && O.potency == N.potency)
			++N.amount
			return

	piles += new /datum/seed_pile(O.plantname, O.lifespan, O.endurance, O.maturation, O.production, O.yield, O.potency)
	return
