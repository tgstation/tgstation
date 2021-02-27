/obj/machinery/vending/games
	name = "\improper Good Clean Fun"
	desc = "Vends things that the Captain and Head of Personnel are probably not going to appreciate you fiddling with instead of your job..."
	product_ads = "Escape to a fantasy world!;Fuel your gambling addiction!;Ruin your friendships!;Roll for initiative!;Elves and dwarves!;Paranoid computers!;Totally not satanic!;Fun times forever!"
	icon_state = "games"
	products = list(/obj/item/toy/cards/deck = 5,
		            /obj/item/storage/pill_bottle/dice = 10,
		            /obj/item/toy/cards/deck/cas = 3,
		            /obj/item/toy/cards/deck/cas/black = 3,
					/obj/item/toy/cards/deck/kotahi = 3,
					/obj/item/toy/cards/deck/tarot = 3,
					/obj/item/toy/cards/deck/wizoff = 3,
					/obj/item/hourglass = 2,
					/obj/item/instrument/piano_synth/headphones = 4,
					/obj/item/camera = 3,
					/obj/item/cardpack/series_one = 10,
					/obj/item/cardpack/resin = 10,
					/obj/item/storage/card_binder = 10,
					/obj/item/skillchip/basketweaving=2,
					/obj/item/skillchip/bonsai=2,
					/obj/item/skillchip/wine_taster=2,
					/obj/item/skillchip/light_remover=2,
					/obj/item/skillchip/useless_adapter=5)
	contraband = list(/obj/item/dice/fudge = 9,
					/obj/item/clothing/shoes/wheelys/skishoes=4,
					/obj/item/instrument/musicalmoth=1)
	premium = list(/obj/item/melee/skateboard/pro = 3,
					/obj/item/clothing/shoes/wheelys/rollerskates= 3,
					/obj/item/melee/skateboard/hoverboard = 1,
					/obj/item/storage/box/tail_pin = 1,
					/obj/item/toy/intento = 3)
	refill_canister = /obj/item/vending_refill/games
	default_price = PAYCHECK_ASSISTANT
	extra_price = PAYCHECK_HARD * 1.25
	payment_department = ACCOUNT_SRV
	light_mask = "games-light-mask"

/obj/item/vending_refill/games
	machine_name = "\improper Good Clean Fun"
	icon_state = "refill_games"
