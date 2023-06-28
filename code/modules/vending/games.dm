/obj/machinery/vending/games
	name = "\improper Good Clean Fun"
	desc = "Vends things that the Captain and Head of Personnel are probably not going to appreciate you fiddling with instead of your job..."
	product_ads = "Escape to a fantasy world!;Fuel your gambling addiction!;Ruin your friendships!;Roll for initiative!;Elves and dwarves!;Paranoid computers!;Totally not satanic!;Fun times forever!"
	icon_state = "games"
	panel_type = "panel4"
	product_categories = list(
		list(
			"name" = "Cards",
			"icon" = "diamond",
			"products" = list(
				/obj/item/toy/cards/deck = 5,
				/obj/item/toy/cards/deck/blank = 3,
				/obj/item/toy/cards/deck/blank/black = 3,
				/obj/item/toy/cards/deck/cas = 3,
				/obj/item/toy/cards/deck/cas/black = 3,
				/obj/item/toy/cards/deck/kotahi = 3,
				/obj/item/toy/cards/deck/tarot = 3,
				/obj/item/toy/cards/deck/wizoff = 3,
			),
		),
		list(
			"name" = "Toys",
			"icon" = "hat-wizard",
			"products" = list(
				/obj/item/toy/captainsaid = 1,
				/obj/item/toy/intento = 3,
				/obj/item/storage/box/tail_pin = 1,
			),
		),
		list(
			"name" = "Art",
			"icon" = "palette",
			"products" = list(
				/obj/item/storage/crayons = 2,
				/obj/item/chisel = 3,
				/obj/item/paint_palette = 3,
				/obj/item/canvas/nineteen_nineteen = 5,
				/obj/item/canvas/twentythree_nineteen = 5,
				/obj/item/canvas/twentythree_twentythree = 5,
				/obj/item/canvas/twentyfour_twentyfour = 5,
				/obj/item/canvas/thirtysix_twentyfour = 3,
				/obj/item/canvas/fortyfive_twentyseven = 3,
				/obj/item/wallframe/painting/large = 5,
				/obj/item/stack/pipe_cleaner_coil/random = 10,
			),
		),
		list(
			"name" = "Skillchips",
			"icon" = "floppy-disk",
			"products" = list(
				/obj/item/skillchip/appraiser = 2,
				/obj/item/skillchip/basketweaving = 2,
				/obj/item/skillchip/bonsai = 2,
				/obj/item/skillchip/light_remover = 2,
				/obj/item/skillchip/sabrage = 2,
				/obj/item/skillchip/useless_adapter = 5,
				/obj/item/skillchip/wine_taster = 2,
			),
		),
		list(
			"name" = "Other",
			"icon" = "star",
			"products" = list(
				/obj/item/camera = 3,
				/obj/item/camera_film = 5,
				/obj/item/cardpack/resin = 20, //Both card packs have had their count raised to 20 from 10 until card persistance is implimented.
				/obj/item/cardpack/series_one = 20,
				/obj/item/dyespray = 3,
				/obj/item/hourglass = 2,
				/obj/item/instrument/piano_synth/headphones = 4,
				/obj/item/razor = 3,
				/obj/item/storage/card_binder = 10,
				/obj/item/storage/dice = 10,
			),
		),
	)
	contraband = list(
		/obj/item/dice/fudge = 9,
		/obj/item/clothing/shoes/wheelys/skishoes = 4,
		/obj/item/instrument/musicalmoth = 1,
	)
	premium = list(
		/obj/item/disk/holodisk = 5,
		/obj/item/rcl = 2,
		/obj/item/airlock_painter = 1,
		/obj/item/clothing/shoes/wheelys/rollerskates= 3,
		/obj/item/melee/skateboard/pro = 3,
		/obj/item/melee/skateboard/hoverboard = 1,
	)
	refill_canister = /obj/item/vending_refill/games
	default_price = PAYCHECK_CREW
	extra_price = PAYCHECK_COMMAND * 1.25
	payment_department = ACCOUNT_SRV
	light_mask = "games-light-mask"

/obj/item/vending_refill/games
	machine_name = "\improper Good Clean Fun"
	icon_state = "refill_games"
