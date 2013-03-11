//This dm file includes some food processing machines:
// - I.   Mill
// - II.  Fermenter
// - III. Still
// - IV.  Squeezer
// - V.   Centrifuge



// I. The mill is intended to be loaded with produce and returns ground up items. For example: Wheat should become flour and grapes should become raisins.

/obj/machinery/mill
	var/list/obj/item/weapon/reagent_containers/food/input = list()
	var/list/obj/item/weapon/reagent_containers/food/output = list()
	var/obj/item/weapon/reagent_containers/food/milled_item
	var/busy = 0
	var/progress = 0
	var/error = 0
	name = "\improper Mill"
	desc = "It is a machine that grinds produce."
	icon_state = "autolathe"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 1000

/obj/machinery/mill/process()
	if(error)
		return

	if(!busy)
		use_power = 1
		if(input.len)
			milled_item = input[1]
			input -= milled_item
			progress = 0
			busy = 1
			use_power = 2
		return

	progress++
	if(progress < 10)	//Edit this value to make milling faster or slower
		return	//Not done yet.

	switch(milled_item.type)
		if(/obj/item/weapon/reagent_containers/food/snacks/grown/wheat)	//Wheat becomes flour
			var/obj/item/weapon/reagent_containers/food/drinks/flour/F = new(src)
			output += F
		if(/obj/item/weapon/reagent_containers/food/drinks/flour)	//Flour is still flour
			var/obj/item/weapon/reagent_containers/food/drinks/flour/F = new(src)
			output += F
		else
			error = 1

	del(milled_item)
	busy = 0

/obj/machinery/mill/attackby(var/obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food))
		user.u_equip(W)
		W.loc = src
		input += W
	else
		..()

/obj/machinery/mill/attack_hand(var/mob/user as mob)
	for(var/obj/item/weapon/reagent_containers/food/F in output)
		F.loc = src.loc
		output -= F






// II. The fermenter is intended to be loaded with food items and returns medium-strength alcohol items, sucha s wine and beer.

/obj/machinery/fermenter
	var/list/obj/item/weapon/reagent_containers/food/input = list()
	var/list/obj/item/weapon/reagent_containers/food/output = list()
	var/obj/item/weapon/reagent_containers/food/fermenting_item
	var/water_level = 0
	var/busy = 0
	var/progress = 0
	var/error = 0
	name = "\improper Fermenter"
	desc = "It is a machine that ferments produce into alcoholic drinks."
	icon_state = "autolathe"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 500

/obj/machinery/fermenter/process()
	if(error)
		return

	if(!busy)
		use_power = 1
		if(input.len)
			fermenting_item = input[1]
			input -= fermenting_item
			progress = 0
			busy = 1
			use_power = 2
		return

	if(!water_level)
		return

	water_level--

	progress++
	if(progress < 10)	//Edit this value to make milling faster or slower
		return	//Not done yet.

	switch(fermenting_item.type)
		if(/obj/item/weapon/reagent_containers/food/drinks/flour)	//Flour is still flour
			var/obj/item/weapon/reagent_containers/food/drinks/beer/B = new(src)
			output += B
		else
			error = 1

	del(fermenting_item)
	busy = 0

/obj/machinery/fermenter/attackby(var/obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food))
		user.u_equip(W)
		W.loc = src
		input += W
	else
		..()

/obj/machinery/fermenter/attack_hand(var/mob/user as mob)
	for(var/obj/item/weapon/reagent_containers/food/F in output)
		F.loc = src.loc
		output -= F



// III. The still is a machine that is loaded with food items and returns hard liquor, such as vodka.

/obj/machinery/still
	var/list/obj/item/weapon/reagent_containers/food/input = list()
	var/list/obj/item/weapon/reagent_containers/food/output = list()
	var/obj/item/weapon/reagent_containers/food/destilling_item
	var/busy = 0
	var/progress = 0
	var/error = 0
	name = "\improper Still"
	desc = "It is a machine that produces hard liquor from alcoholic drinks."
	icon_state = "autolathe"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 10000

/obj/machinery/still/process()
	if(error)
		return

	if(!busy)
		use_power = 1
		if(input.len)
			destilling_item = input[1]
			input -= destilling_item
			progress = 0
			busy = 1
			use_power = 2
		return

	progress++
	if(progress < 10)	//Edit this value to make distilling faster or slower
		return	//Not done yet.

	switch(destilling_item.type)
		if(/obj/item/weapon/reagent_containers/food/drinks/beer)	//Flour is still flour
			var/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/V = new(src)
			output += V
		else
			error = 1

	del(destilling_item)
	busy = 0

/obj/machinery/still/attackby(var/obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food))
		user.u_equip(W)
		W.loc = src
		input += W
	else
		..()

/obj/machinery/still/attack_hand(var/mob/user as mob)
	for(var/obj/item/weapon/reagent_containers/food/F in output)
		F.loc = src.loc
		output -= F




// IV. The squeezer is intended to destroy inserted food items, but return some of the reagents they contain.

/obj/machinery/squeezer
	var/list/obj/item/weapon/reagent_containers/food/input = list()
	var/obj/item/weapon/reagent_containers/food/squeezed_item
	var/water_level = 0
	var/busy = 0
	var/progress = 0
	var/error = 0
	name = "\improper Squeezer"
	desc = "It is a machine that squeezes extracts from produce."
	icon_state = "autolathe"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 500





// V. The centrifuge spins inserted food items. It is intended to squeeze out the reagents that are common food catalysts (enzymes currently)

/obj/machinery/centrifuge
	var/list/obj/item/weapon/reagent_containers/food/input = list()
	var/list/obj/item/weapon/reagent_containers/food/output = list()
	var/obj/item/weapon/reagent_containers/food/spinning_item
	var/busy = 0
	var/progress = 0
	var/error = 0
	var/enzymes = 0
	var/water = 0
	name = "\improper Centrifuge"
	desc = "It is a machine that spins produce."
	icon_state = "autolathe"
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 10000

/obj/machinery/centrifuge/process()
	if(error)
		return

	if(!busy)
		use_power = 1
		if(input.len)
			spinning_item = input[1]
			input -= spinning_item
			progress = 0
			busy = 1
			use_power = 2
		return

	progress++
	if(progress < 10)	//Edit this value to make milling faster or slower
		return	//Not done yet.

	var/transfer_enzymes = spinning_item.reagents.get_reagent_amount("enzyme")

	if(transfer_enzymes)
		enzymes += transfer_enzymes
		spinning_item.reagents.remove_reagent("enzyme",transfer_enzymes)

	output += spinning_item
	busy = 0

/obj/machinery/centrifuge/attackby(var/obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/reagent_containers/food))
		user.u_equip(W)
		W.loc = src
		input += W
	else
		..()

/obj/machinery/centrifuge/attack_hand(var/mob/user as mob)
	for(var/obj/item/weapon/reagent_containers/food/F in output)
		F.loc = src.loc
		output -= F
	while(enzymes >= 50)
		enzymes -= 50
		new/obj/item/weapon/reagent_containers/food/condiment/enzyme(src.loc)

