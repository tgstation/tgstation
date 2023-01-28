/obj/effect/spawner/costume
	name = "costume spawner"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	color = "#00FF00"

	var/list/items

/obj/effect/spawner/costume/Initialize(mapload)
	. = ..()
	if(items?.len)
		for(var/path in items)
			new path(loc)

/obj/effect/spawner/costume/chicken
	name = "chicken costume spawner"
	items = list(
		/obj/item/clothing/suit/costume/chickensuit,
		/obj/item/clothing/head/costume/chicken,
		/obj/item/food/egg,
	)

/obj/effect/spawner/costume/gladiator
	name = "gladiator costume spawner"
	items = list(
		/obj/item/clothing/under/costume/gladiator,
		/obj/item/clothing/head/helmet/gladiator,
	)

/obj/effect/spawner/costume/madscientist
	name = "mad scientist costume spawner"
	items = list(
		/obj/item/clothing/under/rank/captain/suit,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/suit/toggle/labcoat/mad,
	)

/obj/effect/spawner/costume/elpresidente
	name = "el presidente costume spawner"
	items = list(
		/obj/item/clothing/under/rank/captain/suit,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/mask/cigarette/cigar/havana,
		/obj/item/clothing/shoes/jackboots,
	)

/obj/effect/spawner/costume/nyangirl
	name = "nyangirl costume spawner"
	items = list(
		/obj/item/clothing/under/costume/schoolgirl,
		/obj/item/clothing/head/costume/kitty,
		/obj/item/clothing/glasses/blindfold,
	)

/obj/effect/spawner/costume/maid
	name = "maid costume spawner"
	items = list(
		/obj/item/clothing/under/dress/skirt,
		/obj/effect/spawner/random/clothing/beret_or_rabbitears,
		/obj/item/clothing/glasses/blindfold,
	)


/obj/effect/spawner/costume/butler
	name = "butler costume spawner"
	items = list(
		/obj/item/clothing/accessory/waistcoat,
		/obj/item/clothing/under/suit/black,
		/obj/item/clothing/neck/tie/black,
		/obj/item/clothing/head/hats/tophat,
	)

/obj/effect/spawner/costume/referee
	name = "referee costume spawner"
	items = list(
		/obj/item/clothing/mask/whistle,
		/obj/item/clothing/gloves/latex,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/head/soft/black,
		/obj/item/clothing/under/costume/referee,
	)

/obj/effect/spawner/costume/highlander
	name = "highlander costume spawner"
	items = list(
		/obj/item/clothing/under/costume/kilt,
		/obj/item/clothing/head/beret,
	)

/obj/effect/spawner/costume/prig
	name = "prig costume spawner"
	items = list(
		/obj/item/clothing/accessory/waistcoat,
		/obj/item/clothing/glasses/monocle,
		/obj/effect/spawner/random/clothing/bowler_or_that,
		/obj/item/clothing/shoes/sneakers/black,
		/obj/item/cane,
		/obj/item/clothing/under/suit/sl,
		/obj/item/clothing/mask/fakemoustache,
	)

/obj/effect/spawner/costume/plaguedoctor
	name = "plague doctor costume spawner"
	items = list(
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/head/bio_hood/plague,
		/obj/item/clothing/mask/gas/plaguedoctor,
	)

/obj/effect/spawner/costume/nightowl
	name = "night owl costume spawner"
	items = list(
		/obj/item/clothing/suit/toggle/owlwings,
		/obj/item/clothing/under/costume/owl,
		/obj/item/clothing/mask/gas/owl_mask,
	)

/obj/effect/spawner/costume/griffin
	name = "griffin costume spawner"
	items = list(
		/obj/item/clothing/suit/toggle/owlwings/griffinwings,
		/obj/item/clothing/shoes/griffin,
		/obj/item/clothing/under/costume/griffin,
		/obj/item/clothing/head/costume/griffin,
	)

/obj/effect/spawner/costume/waiter
	name = "waiter costume spawner"
	items = list(
		/obj/item/clothing/under/suit/waiter,
		/obj/effect/spawner/random/clothing/kittyears_or_rabbitears,
		/obj/item/clothing/suit/apron,
	)

/obj/effect/spawner/costume/pirate
	name = "pirate costume spawner"
	items = list(
		/obj/item/clothing/under/costume/pirate,
		/obj/item/clothing/suit/costume/pirate,
		/obj/effect/spawner/random/clothing/pirate_or_bandana,
		/obj/item/clothing/glasses/eyepatch,
	)

/obj/effect/spawner/costume/commie
	name = "commie costume spawner"
	items = list(
		/obj/item/clothing/under/costume/soviet,
		/obj/item/clothing/head/costume/ushanka,
	)

/obj/effect/spawner/costume/imperium_monk
	name = "imperium monk costume spawner"
	items = list(
		/obj/item/clothing/suit/costume/imperium_monk,
		/obj/effect/spawner/random/clothing/twentyfive_percent_cyborg_mask,
	)

/obj/effect/spawner/costume/holiday_priest
	name = "holiday priest costume spawner"
	items = list(/obj/item/clothing/suit/chaplainsuit/holidaypriest)

/obj/effect/spawner/costume/marisawizard
	name = "marisa wizard costume spawner"
	items = list(
		/obj/item/clothing/shoes/sneakers/marisa,
		/obj/item/clothing/head/wizard/marisa/fake,
		/obj/item/clothing/suit/wizrobe/marisa/fake,
	)

/obj/effect/spawner/costume/cutewitch
	name = "cute witch costume spawner"
	items = list(
		/obj/item/clothing/under/dress/sundress,
		/obj/item/clothing/head/costume/witchwig,
		/obj/item/staff/broom,
	)

/obj/effect/spawner/costume/wizard
	name = "wizard costume spawner"
	items = list(
		/obj/item/clothing/shoes/sandal,
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/clothing/head/wizard/fake,
		/obj/item/staff,
	)

/obj/effect/spawner/costume/sexyclown
	name = "sexy clown costume spawner"
	items = list(
		/obj/item/clothing/mask/gas/sexyclown,
		/obj/item/clothing/under/rank/civilian/clown/sexy,
	)

/obj/effect/spawner/costume/sexymime
	name = "sexy mime costume spawner"
	items = list(
		/obj/item/clothing/mask/gas/sexymime,
		/obj/item/clothing/under/rank/civilian/mime/sexy,
	)

/obj/effect/spawner/costume/mafia
	name = "black mafia outfit spawner"
	items = list(
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/under/suit/blacktwopiece,
		/obj/item/clothing/shoes/laceup,
	)

/obj/effect/spawner/costume/mafia/white
	name = "white mafia outfit spawner"
	items = list(
		/obj/item/clothing/head/fedora/white,
		/obj/item/clothing/under/suit/white,
		/obj/item/clothing/shoes/laceup,
	)

/obj/effect/spawner/costume/mafia/checkered
	name = "checkered mafia outfit spawner"
	items = list(
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/under/suit/checkered,
		/obj/item/clothing/shoes/laceup,
	)

/obj/effect/spawner/costume/mafia/beige
	name = "beige mafia outfit spawner"
	items = list(
		/obj/item/clothing/head/fedora/beige,
		/obj/item/clothing/under/suit/beige,
		/obj/item/clothing/shoes/laceup,
	)
