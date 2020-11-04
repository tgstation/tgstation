/atom/movable/spawner/bundle
	name = "bundle spawner"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"

	var/list/items

/atom/movable/spawner/bundle/Initialize(mapload)
	..()
	if(items?.len)
		for(var/path in items)
			new path(loc)
	return INITIALIZE_HINT_QDEL

/atom/movable/spawner/bundle/costume/chicken
	name = "chicken costume spawner"
	items = list(
		/obj/item/clothing/suit/chickensuit,
		/obj/item/clothing/head/chicken,
		/obj/item/food/egg)

/atom/movable/spawner/bundle/costume/gladiator
	name = "gladiator costume spawner"
	items = list(
		/obj/item/clothing/under/costume/gladiator,
		/obj/item/clothing/head/helmet/gladiator)

/atom/movable/spawner/bundle/costume/madscientist
	name = "mad scientist costume spawner"
	items = list(
		/obj/item/clothing/under/rank/captain/suit,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/suit/toggle/labcoat/mad)

/atom/movable/spawner/bundle/costume/elpresidente
	name = "el presidente costume spawner"
	items = list(
		/obj/item/clothing/under/rank/captain/suit,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/mask/cigarette/cigar/havana,
		/obj/item/clothing/shoes/jackboots)

/atom/movable/spawner/bundle/costume/nyangirl
	name = "nyangirl costume spawner"
	items = list(
		/obj/item/clothing/under/costume/schoolgirl,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/glasses/blindfold)

/atom/movable/spawner/bundle/costume/maid
	name = "maid costume spawner"
	items = list(
		/obj/item/clothing/under/dress/skirt,
		/atom/movable/spawner/lootdrop/minor/beret_or_rabbitears,
		/obj/item/clothing/glasses/blindfold)


/atom/movable/spawner/bundle/costume/butler
	name = "butler costume spawner"
	items = list(
		/obj/item/clothing/accessory/waistcoat,
		/obj/item/clothing/under/suit/black,
		/obj/item/clothing/head/that)

/atom/movable/spawner/bundle/costume/highlander
	name = "highlander costume spawner"
	items = list(
		/obj/item/clothing/under/costume/kilt,
		/obj/item/clothing/head/beret)

/atom/movable/spawner/bundle/costume/prig
	name = "prig costume spawner"
	items = list(
		/obj/item/clothing/accessory/waistcoat,
		/obj/item/clothing/glasses/monocle,
		/atom/movable/spawner/lootdrop/minor/bowler_or_that,
		/obj/item/clothing/shoes/sneakers/black,
		/obj/item/cane,
		/obj/item/clothing/under/suit/sl,
		/obj/item/clothing/mask/fakemoustache)

/atom/movable/spawner/bundle/costume/plaguedoctor
	name = "plague doctor costume spawner"
	items = list(
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/head/plaguedoctorhat,
		/obj/item/clothing/mask/gas/plaguedoctor)

/atom/movable/spawner/bundle/costume/nightowl
	name = "night owl costume spawner"
	items = list(
		/obj/item/clothing/suit/toggle/owlwings,
		/obj/item/clothing/under/costume/owl,
		/obj/item/clothing/mask/gas/owl_mask)

/atom/movable/spawner/bundle/costume/griffin
	name = "griffin costume spawner"
	items = list(
		/obj/item/clothing/suit/toggle/owlwings/griffinwings,
		/obj/item/clothing/shoes/griffin,
		/obj/item/clothing/under/costume/griffin,
		/obj/item/clothing/head/griffin)

/atom/movable/spawner/bundle/costume/waiter
	name = "waiter costume spawner"
	items = list(
		/obj/item/clothing/under/suit/waiter,
		/atom/movable/spawner/lootdrop/minor/kittyears_or_rabbitears,
		/obj/item/clothing/suit/apron)

/atom/movable/spawner/bundle/costume/pirate
	name = "pirate costume spawner"
	items = list(
		/obj/item/clothing/under/costume/pirate,
		/obj/item/clothing/suit/pirate,
		/atom/movable/spawner/lootdrop/minor/pirate_or_bandana,
		/obj/item/clothing/glasses/eyepatch)

/atom/movable/spawner/bundle/costume/commie
	name = "commie costume spawner"
	items = list(
		/obj/item/clothing/under/costume/soviet,
		/obj/item/clothing/head/ushanka)

/atom/movable/spawner/bundle/costume/imperium_monk
	name = "imperium monk costume spawner"
	items = list(
		/obj/item/clothing/suit/imperium_monk,
		/atom/movable/spawner/lootdrop/minor/twentyfive_percent_cyborg_mask)

/atom/movable/spawner/bundle/costume/holiday_priest
	name = "holiday priest costume spawner"
	items = list(
		/obj/item/clothing/suit/chaplainsuit/holidaypriest)

/atom/movable/spawner/bundle/costume/marisawizard
	name = "marisa wizard costume spawner"
	items = list(
		/obj/item/clothing/shoes/sandal/marisa,
		/obj/item/clothing/head/wizard/marisa/fake,
		/obj/item/clothing/suit/wizrobe/marisa/fake)

/atom/movable/spawner/bundle/costume/cutewitch
	name = "cute witch costume spawner"
	items = list(
		/obj/item/clothing/under/dress/sundress,
		/obj/item/clothing/head/witchwig,
		/obj/item/staff/broom)

/atom/movable/spawner/bundle/costume/wizard
	name = "wizard costume spawner"
	items = list(
		/obj/item/clothing/shoes/sandal,
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/clothing/head/wizard/fake,
		/obj/item/staff)

/atom/movable/spawner/bundle/costume/sexyclown
	name = "sexy clown costume spawner"
	items = list(
		/obj/item/clothing/mask/gas/sexyclown,
		/obj/item/clothing/under/rank/civilian/clown/sexy)

/atom/movable/spawner/bundle/costume/sexymime
	name = "sexy mime costume spawner"
	items = list(
		/obj/item/clothing/mask/gas/sexymime,
		/obj/item/clothing/under/rank/civilian/mime/sexy)

/atom/movable/spawner/bundle/costume/mafia
	name = "black mafia outfit spawner"
	items = list(
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/under/suit/blacktwopiece,
		/obj/item/clothing/shoes/laceup)

/atom/movable/spawner/bundle/costume/mafia/white
	name = "white mafia outfit spawner"
	items = list(
		/obj/item/clothing/head/fedora/white,
		/obj/item/clothing/under/suit/white,
		/obj/item/clothing/shoes/laceup)

/atom/movable/spawner/bundle/costume/mafia/checkered
	name = "checkered mafia outfit spawner"
	items = list(
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/under/suit/checkered,
		/obj/item/clothing/shoes/laceup)

/atom/movable/spawner/bundle/costume/mafia/beige
	name = "beige mafia outfit spawner"
	items = list(
		/obj/item/clothing/head/fedora/beige,
		/obj/item/clothing/under/suit/beige,
		/obj/item/clothing/shoes/laceup)

/atom/movable/spawner/bundle/hobo_squat
	name = "hobo squat spawner"
	items = list(/obj/structure/bed/maint,
				/atom/movable/spawner/scatter/grime,
				/atom/movable/spawner/lootdrop/maint_drugs)

/atom/movable/spawner/bundle/moisture_trap
	name = "moisture trap spawner"
	items = list(/atom/movable/spawner/scatter/moisture,
				/obj/structure/moisture_trap)
