// Space Cash. Now it isn't that useless.
/datum/export/stack/cash
	cost = 1 // Multiplied both by value of each bill and by amount of bills in stack.
	unit_name = "credit"
	export_types = list(/obj/item/stack/spacecash)

/datum/export/stack/cash/get_amount(obj/O)
	var/obj/item/stack/spacecash/C = O
	return ..() * C.value


// Coins. At least the coins that do not contain any materials.
// Material-containing coins cost just as much as their materials do, see materials.dm for exact rates.
/datum/export/coin
	cost = 1 // Multiplied by coin's value
	unit_name = "credit"
	message = "worth of rare coins"
	export_types = list(/obj/item/weapon/coin)

/datum/export/coin/get_amount(obj/O)
	var/obj/item/weapon/coin/C = O
	if(C.materials && C.materials.len)
		return 0 // Sold as raw material instead.
	return ..() * C.value