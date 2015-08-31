
//**************************************************************
//
// Set Spawners
// -----------------
// The path is strange because 'set' is a keyword.
//
//**************************************************************

/obj/map/spawner/set_spawner
	var/subChance = 100

/obj/map/spawner/set_spawner/New()
	var/obj/spawned
	src.toSpawn = pick(src.toSpawn)
	for(src.amount,src.amount,src.amount--)
		for(spawned in src.toSpawn)
			if(src.subChance)
				new spawned(src.loc)
				if(src.jiggle)
					spawned.pixel_x = rand(-src.jiggle,src.jiggle)
					spawned.pixel_y = rand(-src.jiggle,src.jiggle)
	qdel(src)
	return
	
//**************************************************************
// Subtypes ////////////////////////////////////////////////////
//**************************************************************

/obj/map/spawner/set_spawner/theater
	name = "theater costume spawner"
	icon_state = "costumes"
	toSpawn = list(
	list(
		/obj/item/clothing/suit/chickensuit,
		/obj/item/clothing/head/chicken,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		),
	list(
		/obj/item/clothing/under/gladiator,
		/obj/item/clothing/head/helmet/gladiator,
		),
	list(
		/obj/item/clothing/under/gimmick/rank/captain/suit,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/suit/storage/labcoat/mad,
		/obj/item/clothing/glasses/gglasses,
		),
	list(
		/obj/item/clothing/under/gimmick/rank/captain/suit,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/mask/cigarette/cigar/havana,
		/obj/item/clothing/shoes/jackboots,
		),
	list(
		/obj/item/clothing/under/schoolgirl,
		/obj/item/clothing/head/kitty,
		),
	list(
		/obj/item/clothing/under/blackskirt,
		/obj/item/clothing/head/rabbitears,
		/obj/item/clothing/glasses/sunglasses/blindfold,
		),
	list(
		/obj/item/clothing/suit/wcoat,
		/obj/item/clothing/under/suit_jacket,
		/obj/item/clothing/head/that,
		),
	list(
		/obj/item/clothing/gloves/white,
		/obj/item/clothing/shoes/white,
		/obj/item/clothing/under/scratch,
		/obj/item/clothing/head/cueball,
		),
	list(
		/obj/item/clothing/under/kilt,
		/obj/item/clothing/head/beret,
		),
	list(
		/obj/item/clothing/suit/wcoat,
		/obj/item/clothing/glasses/monocle,
		/obj/item/clothing/head/that,
		/obj/item/clothing/shoes/black,
		/obj/item/weapon/cane,
		/obj/item/clothing/under/sl_suit,
		/obj/item/clothing/mask/fakemoustache,
		),
	list(
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/head/plaguedoctorhat,
		),
	list(
		/obj/item/clothing/under/owl,
		/obj/item/clothing/mask/gas/owl_mask,
		),
	list(
		/obj/item/clothing/under/waiter,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/suit/apron,
		),
	list(
		/obj/item/clothing/under/pirate,
		/obj/item/clothing/suit/pirate,
		/obj/item/clothing/head/pirate,
		/obj/item/clothing/glasses/eyepatch,
		),
	list(
		/obj/item/clothing/under/soviet,
		/obj/item/clothing/head/ushanka,
		),
	list(
		/obj/item/clothing/suit/imperium_monk,
		/obj/item/clothing/mask/gas/cyborg,
		),
	list(
		/obj/item/clothing/suit/holidaypriest,
		),
	list(
		/obj/item/clothing/head/wizard/marisa/fake,
		/obj/item/clothing/suit/wizrobe/marisa/fake,
		),
	list(
		/obj/item/clothing/under/sundress,
		/obj/item/clothing/head/witchwig,
		/obj/item/weapon/staff/broom,
		),
	list(
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/clothing/head/wizard/fake,
		/obj/item/weapon/staff,
		),
	list(
		/obj/item/clothing/mask/gas/sexyclown,
		/obj/item/clothing/under/sexyclown,
		),
	list(
		/obj/item/clothing/mask/gas/sexymime,
		/obj/item/clothing/under/sexymime,
		),
	)
