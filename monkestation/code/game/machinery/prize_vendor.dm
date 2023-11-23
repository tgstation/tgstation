//a machine that will vend random things from the subtypes of the provided dispense_types or dispense_list_override for an arcade ticket cost
/obj/machinery/prize_vendor
	name = "Generic Prize Vendor"
	desc = "Oops, all runtimes!"
	icon = 'monkestation/icons/obj/machines/prize_vendor.dmi'
	icon_state = "prize_vendor"
	layer = BELOW_OBJ_LAYER
	max_integrity = 300
	integrity_failure = 0.33
	armor_type = /datum/armor/prize_vendor
	circuit = /obj/item/circuitboard/machine/prize_vendor
	light_power = 0.7
	light_outer_range = MINIMUM_USEFUL_LIGHT_RANGE
	density = TRUE

	///What subtypes of things can we dispense
	var/dispense_type = /obj/item/circuitboard/machine/prize_vendor
	///If set then given things will be picked from this instead of subtypes of dispense_type, must be a list
	var/list/dispense_list_override
	///List of overlay images for the screen, generated on the first init of the subtype
	var/list/dispense_overlay_list = list()
	///List of all generated overlays to pick from
	var/static/list/all_generated_overlays = list()
	///How many arcade tickets does it cost to vend an item
	var/ticket_cost = 1
	///How many tickets have been inserted into the vendor, reset whenever an item is dispensed
	var/inserted_tickets = 0
	///var used for tracking overlay state
	var/overlay_state = 0
	///How much to size scale the overlay icons
	var/overlay_scaling = 0.5

/datum/armor/prize_vendor
	melee = 20
	fire = 50
	acid = 70

/obj/machinery/prize_vendor/Initialize(mapload)
	. = ..()
	if(dispense_list_override && !dispense_overlay_list.len)
		generate_overlay_list(dispense_list_override)
	else if(dispense_type && !dispense_overlay_list.len)
		generate_overlay_list(subtypesof(dispense_type))

	if(!dispense_type && !dispense_list_override)
		stack_trace("[type] initialized without set dispense_type or dispense_list_override")
	set_overlay_state()
	update_appearance()
	START_PROCESSING(SSmachines, src)

/obj/machinery/prize_vendor/Destroy()
	STOP_PROCESSING(SSmachines, src)
	return ..()

/obj/machinery/prize_vendor/process()
	if(dispense_overlay_list.len)
		set_overlay_state()
		update_appearance()

/obj/machinery/prize_vendor/update_overlays()
	. = ..()
	if(dispense_overlay_list.len && overlay_state)
		var/mutable_appearance/item_screen_overlay = dispense_overlay_list[overlay_state]
		. += item_screen_overlay

/obj/machinery/prize_vendor/examine(mob/user)
	. = ..()
	. += "It costs [ticket_cost] [ticket_cost == 1 ? "ticket" : "tickets"] to get a prize."
	. += "It currently has [inserted_tickets] [inserted_tickets == 1 ? "ticket" : "tickets"] inserted."

/obj/machinery/prize_vendor/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/stack/arcadeticket))
		vend_prize_check(weapon, user)
		return
	. = ..()

/obj/machinery/prize_vendor/proc/vend_prize_check(obj/item/stack/arcadeticket/ticket_stack, mob/user)
	var/ticket_amount = ticket_stack.get_amount()
	var/remaining_to_be_paid = ticket_cost - inserted_tickets
	if((ticket_amount - remaining_to_be_paid) >= 0)
		ticket_stack.amount -= remaining_to_be_paid
		inserted_tickets = 0
		vend_prize(user)
	else
		inserted_tickets += ticket_amount
		ticket_stack.amount = 0
		to_chat(user, "You insert [ticket_amount] [ticket_amount == 1 ? "ticket" : "tickets"] into \the [src] but it's still not enough! \
					   Looks you will need to get some more tickets.")

	if(ticket_stack.get_amount() <= 0)
		qdel(ticket_stack)
		return

/obj/machinery/prize_vendor/proc/vend_prize(mob/user, vended_prize)
	if(!vended_prize)
		if(dispense_list_override)
			vended_prize = pick_weight(dispense_list_override)
		else
			vended_prize = pick(subtypesof(dispense_type))

	vended_prize = new vended_prize(get_turf(user))

	if(isitem(vended_prize))
		user.put_in_hands(vended_prize)
	to_chat(user, "\The [src] dispenses the [vended_prize]")

/obj/machinery/prize_vendor/proc/set_overlay_state()
	if(!dispense_overlay_list)
		return
	if(dispense_overlay_list.len == 1)
		overlay_state = 1
		return
	if((overlay_state + 1) > dispense_overlay_list.len)
		overlay_state = 0
	overlay_state++

//generate the list of overlays to use
/obj/machinery/prize_vendor/proc/generate_overlay_list(list/list_to_generate_for)
	for(var/type_entry in list_to_generate_for)
		if(all_generated_overlays[type_entry])
			dispense_overlay_list += all_generated_overlays[type_entry]
			continue
		var/atom/made_atom = new type_entry(src)
		var/mutable_appearance/current_made_overlay = mutable_appearance()
		current_made_overlay.appearance = made_atom
		current_made_overlay.pixel_x = -3
		current_made_overlay.pixel_y = -3
		current_made_overlay.transform *= overlay_scaling
		all_generated_overlays[type_entry] = current_made_overlay
		dispense_overlay_list += current_made_overlay
		qdel(made_atom)

	if(!dispense_overlay_list.len)
		stack_trace("[type] failed to generate dispense_overlay_list")

/obj/machinery/prize_vendor/plushies
	name = "Plush Prize Vendor"
	desc = "Gives you a small marketable friend."
	dispense_type = /obj/item/toy/plush
	ticket_cost = 2
	circuit = /obj/item/circuitboard/machine/prize_vendor/plushies

/obj/machinery/prize_vendor/pets
	name = "Pet Prize Vendor"
	desc = "Friend dispenser."
	dispense_list_override = list(/mob/living/basic/parrot = 3,
								  /mob/living/basic/sloth = 3,
								  /mob/living/simple_animal/pet/cat = 3,
								  /mob/living/basic/pet/fox = 3,
								  /mob/living/simple_animal/pet/gondola = 1,
								  /mob/living/basic/pet/penguin/emperor = 2,
								  /mob/living/basic/crab = 2,
								  /mob/living/basic/axolotl = 2,
								  /mob/living/basic/frog = 2,
								  /mob/living/basic/mothroach = 3,
								  /mob/living/basic/pet/dog/bullterrier = 2,
								  /mob/living/basic/pet/dog/pug = 2,
								  /mob/living/basic/pet/dog/corgi = 2,
								  /mob/living/basic/rabbit = 2)
	ticket_cost = 4
	circuit = /obj/item/circuitboard/machine/prize_vendor/pets

/obj/machinery/prize_vendor/snacks
	name = "Snack Prize Vendor"
	desc = "Now with enough sugar to keep you gaming!"
	dispense_list_override = list(/obj/item/reagent_containers/cup/soda_cans/cola = 3,
								  /obj/item/reagent_containers/cup/soda_cans/space_mountain_wind = 3,
								  /obj/item/reagent_containers/cup/soda_cans/dr_gibb = 3,
								  /obj/item/reagent_containers/cup/soda_cans/starkist = 3,
								  /obj/item/reagent_containers/cup/soda_cans/space_up = 3,
								  /obj/item/reagent_containers/cup/soda_cans/pwr_game = 3,
								  /obj/item/reagent_containers/cup/soda_cans/lemon_lime = 3,
								  /obj/item/reagent_containers/cup/glass/bottle/mushi_kombucha = 1,
								  /obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola = 1,
								  /obj/item/reagent_containers/cup/soda_cans/monkey_energy = 1,
								  /obj/item/reagent_containers/cup/soda_cans/grey_bull = 1,
								  /obj/item/reagent_containers/cup/glass/bottle/rootbeer = 1,
								  /obj/item/food/spacetwinkie = 3,
								  /obj/item/food/cheesiehonkers = 3,
								  /obj/item/food/candy = 3,
						  		  /obj/item/food/chips = 3,
								  /obj/item/food/chips/shrimp = 3,
								  /obj/item/food/sosjerky = 3,
								  /obj/item/food/cornchips/random = 3,
								  /obj/item/food/sosjerky = 3,
								  /obj/item/food/no_raisin = 3,
								  /obj/item/food/peanuts = 3,
								  /obj/item/food/peanuts/random = 2,
								  /obj/item/food/cnds = 3,
								  /obj/item/food/cnds/random = 2,
								  /obj/item/food/semki = 3,
								  /obj/item/reagent_containers/cup/glass/dry_ramen = 2,
								  /obj/item/storage/box/gum = 2,
								  /obj/item/food/energybar = 2,
								  /obj/item/food/syndicake = 2,
								  /obj/item/food/peanuts/ban_appeal = 2,
								  /obj/item/food/candy/bronx = 1,
								  /obj/item/food/spacers_sidekick = 2,
								  /obj/item/food/pistachios = 2,
								  /obj/effect/spawner/random/food_or_drink/donkpockets = 2) //should just give a random donk pocket box
	overlay_scaling = 0.6
	circuit = /obj/item/circuitboard/machine/prize_vendor/snacks

/obj/machinery/prize_vendor/games
	name = "Game Prize Vendor"
	desc = "For all the non-gaming gamers in your life."
	dispense_list_override = list(/obj/item/toy/cards/deck = 2,
								  /obj/item/toy/cards/deck/blank = 2,
								  /obj/item/toy/cards/deck/blank/black = 2,
								  /obj/item/toy/cards/deck/cas = 2,
				 				  /obj/item/toy/cards/deck/cas/black = 2,
								  /obj/item/toy/cards/deck/kotahi = 2,
								  /obj/item/toy/cards/deck/tarot = 2,
								  /obj/item/toy/cards/deck/wizoff = 2,
								  /obj/item/toy/captainsaid = 1,
								  /obj/item/toy/intento = 2,
								  /obj/item/storage/box/tail_pin = 1,
								  /obj/item/skillchip/appraiser = 1,
								  /obj/item/skillchip/basketweaving = 1,
								  /obj/item/skillchip/bonsai = 1,
								  /obj/item/skillchip/light_remover = 1,
								  /obj/item/skillchip/sabrage = 1,
								  /obj/item/skillchip/useless_adapter = 1,
								  /obj/item/skillchip/wine_taster = 1,
								  /obj/item/camera = 1,
								  /obj/item/camera_film = 2,
								  /obj/item/cardpack/resin = 3,
								  /obj/item/cardpack/series_one = 3,
								  /obj/item/dyespray = 2,
								  /obj/item/hourglass = 1,
								  /obj/item/instrument/piano_synth/headphones = 1,
								  /obj/item/razor = 2,
								  /obj/item/storage/card_binder = 1,
								  /obj/item/storage/dice = 2)
	ticket_cost = 3
	circuit = /obj/item/circuitboard/machine/prize_vendor/games

/obj/machinery/prize_vendor/games/vend_prize(mob/user, vended_prize)
	if(prob(0.5)) //one in 200, can be tweaked
		vended_prize = /obj/item/dice/d20/fate/one_use
		to_chat(user, span_notice("\The [src] makes an odd sound, what did it just give you?"))
	. = ..()

/obj/machinery/prize_vendor/toy
	name = "Toy Prize Vendor"
	desc = "Nanotrasen is not responsible for lost eyes."
	dispense_list_override = list(/obj/item/gun/ballistic/automatic/toy/unrestricted = 1,
								  /obj/item/gun/ballistic/automatic/pistol/toy = 2,
								  /obj/item/gun/ballistic/shotgun/toy/unrestricted = 2,
								  /obj/item/toy/sword = 3,
								  /obj/item/ammo_box/foambox = 3,
								  /obj/item/toy/foamblade = 3,
								  /obj/item/toy/balloon/syndicate = 1,
								  /obj/item/gun/ballistic/shotgun/toy/crossbow = 2)
	ticket_cost = 6
	circuit = /obj/item/circuitboard/machine/prize_vendor/toy

//normally gotten with a one in 1 million chance from arcades
/obj/machinery/prize_vendor/pulse_prize
	name = "Grand Prize Vendor"
	desc = "The grand prize!"
	dispense_list_override = list(/obj/item/gun/energy/pulse/prize = 1)
	ticket_cost = 250
	circuit = /obj/item/circuitboard/machine/prize_vendor/pulse_prize

/obj/machinery/prize_vendor/pulse_prize/vend_prize(mob/user)
	. = ..()
	priority_announce("[user] is the winner of the grand prize at the arcade. Well done!", "Central Command Gaming Division")
	user.client.give_award(/datum/award/achievement/misc/pulse, user)

//these cant be made, they are just here to give you a chance to recover the machine if its destroyed, also fewer snowflake machines good
/obj/item/circuitboard/machine/prize_vendor
	name = "Prize Vendor"
	desc = "Makes a generic prize vendor."
	build_path = /obj/machinery/prize_vendor

/obj/item/circuitboard/machine/prize_vendor/plushies
	name = "Plush Prize Vendor"
	desc = "Makes a plush prize vendor."
	build_path = /obj/machinery/prize_vendor/plushies

/obj/item/circuitboard/machine/prize_vendor/pets
	name = "Pet Prize Vendor"
	desc = "Makes a pet prize vendor."
	build_path = /obj/machinery/prize_vendor/pets

/obj/item/circuitboard/machine/prize_vendor/snacks
	name = "Snack Prize Vendor"
	desc = "Makes a snack prize vendor."
	build_path = /obj/machinery/prize_vendor/snacks

/obj/item/circuitboard/machine/prize_vendor/toy
	name = "Toy Prize Vendor"
	desc = "Makes a snack prize vendor."
	build_path = /obj/machinery/prize_vendor/toy

/obj/item/circuitboard/machine/prize_vendor/games
	name = "Game Prize Vendor"
	desc = "Makes a game prize vendor."
	build_path = /obj/machinery/prize_vendor/games

/obj/item/circuitboard/machine/prize_vendor/pulse_prize
	name = "Grand Prize Vendor"
	desc = "Makes a grand prize vendor."
	build_path = /obj/machinery/prize_vendor/pulse_prize
