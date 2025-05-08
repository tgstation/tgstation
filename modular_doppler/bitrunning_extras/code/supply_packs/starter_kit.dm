
/datum/supply_pack/service/bitrunnerkit
	name = "Bitrunner Starter Kit"
	desc = "Need a break from all that laborious cargo work? An assistant that needs more stimulation in their life? \
		Either way, this kit is all you'll ever need to allow your regular station crewman to seek some temporary reprieve from the ever-present troubles of station life. \
		Contains a personalizer avatar disk, a bitrunner suit, a six-pack of gamer drinks, much-needed snacks, \
		a gamerscore folder, and a towel to unceremoniously wipe off the netpod gunk."
	cost = CARGO_CRATE_VALUE * 4
	access = ACCESS_BIT_DEN
	access_view = ACCESS_BIT_DEN
	contains = list(
		/obj/item/bitrunning_disk/preferences,
		/obj/item/storage/cans/sixgamerdrink,
		/obj/item/folder/gamer,
		/obj/item/towel,
	)
	crate_name = "bitrunner starter kit"
	crate_type = /obj/structure/closet/crate/secure/cargo

	/// Amount of snack items we roll to add
	var/snack_count = 6
	/// Pool of snack items we may add from
	var/list/snack_options = list(
		/obj/item/food/cornchips,
		/obj/item/food/cornchips/green,
		/obj/item/food/cornchips/red,
		/obj/item/food/cornchips/purple,
		/obj/item/food/cornchips/blue,
		/obj/item/food/cornchips/random,
	)
	/// Pool of special items we may add from
	var/list/special_options = list(
	//	/obj/item/storage/pill_bottle/transgender_allegory,
		/obj/item/storage/box/papersack/gamer_lunch,
		/obj/item/reagent_containers/hypospray/medipen/methamphetamine/gamer,
	)

/datum/supply_pack/service/bitrunnerkit/fill(obj/structure/closet/crate/our_crate)
	. = ..()
	for(var/i in 1 to snack_count)
		var/obj/item/chosen_snack = pick(snack_options)
		new chosen_snack(our_crate)

	if(prob(5))
		new /obj/item/clothing/glasses/sunglasses(our_crate)
		new /obj/item/clothing/gloves/color/black(our_crate)
		new /obj/item/clothing/shoes/laceup(our_crate)
		new /obj/item/clothing/under/suit/black_really(our_crate)
	else
		new /obj/item/clothing/under/rank/cargo/bitrunner(our_crate)

	if(prob(20))
		var/obj/item/special_snack = pick(special_options)
		new special_snack(our_crate)

/obj/item/folder/gamer
	name = "folder - 'domain certificates'"
	desc = "A folder to keep track of all your gamer highscores."
