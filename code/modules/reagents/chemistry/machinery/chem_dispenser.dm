/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "Creates and dispenses chemicals."
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = 1
	idle_power_usage = 40
	interact_offline = 1
	var/energy = 100
	var/max_energy = 100
	var/amount = 30
	var/recharged = 0
	var/recharge_delay = 5
	var/image/icon_beaker = null
	var/obj/item/weapon/reagent_containers/beaker = null
	var/list/dispensable_reagents = list(
		"hydrogen",
		"lithium",
		"carbon",
		"nitrogen",
		"oxygen",
		"fluorine",
		"sodium",
		"aluminium",
		"silicon",
		"phosphorus",
		"sulfur",
		"chlorine",
		"potassium",
		"iron",
		"copper",
		"mercury",
		"radium",
		"water",
		"ethanol",
		"sugar",
		"sacid",
		"welding_fuel",
		"silver",
		"iodine",
		"bromine",
		"stable_plasma"
	)

/obj/machinery/chem_dispenser/New()
	..()
	recharge()
	dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER

/obj/machinery/chem_dispenser/process()

	if(recharged < 0)
		recharge()
		recharged = recharge_delay
	else
		recharged -= 1

/obj/machinery/chem_dispenser/proc/recharge()
	if(stat & (BROKEN|NOPOWER)) return
	var/addenergy = 1
	var/oldenergy = energy
	energy = min(energy + addenergy, max_energy)
	if(energy != oldenergy)
		use_power(2500)

/obj/machinery/chem_dispenser/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_dispenser/blob_act()
	if(prob(50))
		qdel(src)

/obj/machinery/chem_dispenser/interact(mob/user)
	if(stat & BROKEN)
		return
	ui_interact(user)

/obj/machinery/chem_dispenser/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 0)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, force_open = force_open)
	if (!ui)
		ui = new(user, src, ui_key, "chem_dispenser", name, 530, 700)
		ui.open()

/obj/machinery/chem_dispenser/get_ui_data()
	var/data = list()
	data["amount"] = amount
	data["energy"] = energy
	data["maxEnergy"] = max_energy
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var beakerContents[0]
	var beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
		data["beakerTransferAmounts"] = beaker.possible_transfer_amounts
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null
		data["beakerTransferAmounts"] = null

	var chemicals[0]
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("reagent" = temp.id))))
	data["chemicals"] = chemicals
	return data

/obj/machinery/chem_dispenser/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("amount")
			amount = round(text2num(params["set"]), 5) // round to nearest 5
			if (amount < 0) // Since the user can actually type the commands himself, some sanity checking
				amount = 0
			if (amount > 100)
				amount = 100
		if("dispense")
			if(beaker && dispensable_reagents.Find(params["reagent"]))
				var/datum/reagents/R = beaker.reagents
				var/space = R.maximum_volume - R.total_volume

				R.add_reagent(params["reagent"], min(amount, energy * 10, space))
				energy = max(energy - min(amount, energy * 10, space) / 10, 0)
		if("remove")
			if(beaker)
				var/amount = text2num(params["amount"])
				if(isnum(amount) && (amount > 0) && (amount in beaker.possible_transfer_amounts))
					beaker.reagents.remove_all(amount)
		if("eject")
			if(beaker)
				beaker.loc = loc
				beaker = null
				overlays.Cut()
	return 1

/obj/machinery/chem_dispenser/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return

	if(isrobot(user))
		return

	var/obj/item/weapon/reagent_containers/B = I // Get a beaker from it?
	if(!istype(B))
		return // Not a beaker?

	if(beaker)
		user << "<span class='warning'>A beaker is already loaded into the machine!</span>"
		return

	if(!user.drop_item()) // Can't let go?
		return

	beaker = B
	beaker.loc = src
	user << "<span class='notice'>You add the beaker to the machine.</span>"

	if(!icon_beaker)
		icon_beaker = image('icons/obj/chemical.dmi', src, "disp_beaker") //randomize beaker overlay position.
	icon_beaker.pixel_x = rand(-10,5)
	overlays += icon_beaker

/obj/machinery/chem_dispenser/attack_hand(mob/user)
	if (!user)
		return
	interact(user)


/obj/machinery/chem_dispenser/constructable
	name = "portable chem dispenser"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "minidispenser"
	energy = 10
	max_energy = 10
	amount = 5
	recharge_delay = 30
	dispensable_reagents = list()
	var/list/dispensable_reagent_tiers = list(
		list(
			"hydrogen",
			"oxygen",
			"silicon",
			"phosphorus",
			"sulfur",
			"carbon",
			"nitrogen",
			"water"
		),
		list(
			"lithium",
			"sugar",
			"sacid",
			"copper",
			"mercury",
			"sodium",
			"iodine",
			"bromine"
		),
		list(
			"ethanol",
			"chlorine",
			"potassium",
			"aluminium",
			"radium",
			"fluorine",
			"iron",
			"welding_fuel",
			"silver",
			"stable_plasma"
		),
		list(
			"oil",
			"ash",
			"acetone",
			"saltpetre",
			"ammonia",
			"diethylamine"
		)
	)

/obj/machinery/chem_dispenser/constructable/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	RefreshParts()

/obj/machinery/chem_dispenser/constructable/RefreshParts()
	var/time = 0
	var/temp_energy = 0
	var/i
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		temp_energy += M.rating
	temp_energy--
	max_energy = temp_energy * 5  //max energy = (bin1.rating + bin2.rating - 1) * 5, 5 on lowest 25 on highest
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		time += C.rating
	for(var/obj/item/weapon/stock_parts/cell/P in component_parts)
		time += round(P.maxcharge, 10000) / 10000
	recharge_delay /= time/2         //delay between recharges, double the usual time on lowest 50% less than usual on highest
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		for(i=1, i<=M.rating, i++)
			dispensable_reagents |= dispensable_reagent_tiers[i]
	dispensable_reagents = sortList(dispensable_reagents)

/obj/machinery/chem_dispenser/constructable/attackby(var/obj/item/I, var/mob/user, params)
	..()
	if(default_deconstruction_screwdriver(user, "minidispenser-o", "minidispenser", I))
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			if(beaker)
				beaker.loc = loc
				beaker = null
			default_deconstruction_crowbar(I)
			return 1

/obj/machinery/chem_dispenser/drinks
	name = "soda dispenser"
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "soda_dispenser"
	amount = 10
	dispensable_reagents = list(
		"water",
		"ice",
		"coffee",
		"cream",
		"tea",
		"icetea",
		"cola",
		"spacemountainwind",
		"dr_gibb",
		"space_up",
		"tonic",
		"sodawater",
		"lemon_lime",
		"sugar",
		"orangejuice",
		"limejuice",
		"tomatojuice"
	)

/obj/machinery/chem_dispenser/drinks/attackby(obj/item/I, mob/user)
	if(default_unfasten_wrench(user, I))
		return

	if (istype(I, /obj/item/weapon/reagent_containers/glass) || \
		istype(I, /obj/item/weapon/reagent_containers/food/drinks/drinkingglass) || \
		istype(I, /obj/item/weapon/reagent_containers/food/drinks/shaker))

		if (beaker)
			return 1
		else
			if(!user.drop_item())
				return 1
			src.beaker =  I
			beaker.loc = src
			update_icon()
			return

/obj/machinery/chem_dispenser/drinks/beer
	name = "booze dispenser"
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "booze_dispenser"
	dispensable_reagents = list(
		"lemon_lime",
		"sugar",
		"orangejuice",
		"limejuice",
		"sodawater",
		"tonic",
		"beer",
		"kahlua",
		"whiskey",
		"wine",
		"vodka",
		"gin",
		"rum",
		"tequila",
		"vermouth",
		"cognac",
		"ale"
	)
