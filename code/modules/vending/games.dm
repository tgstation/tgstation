/obj/machinery/vending/games
	name = "\improper Good Clean Fun"
	desc = "Vends things that the Captain and Head of Personnel are probably not going to appreciate you fiddling with instead of your job..."
	product_ads = "Escape to a fantasy world!;Fuel your gambling addiction!;Ruin your friendships!;Roll for initiative!;Elves and dwarves!;Paranoid computers!;Totally not satanic!;Fun times forever!"
	icon_state = "games"
	products = list(/obj/item/toy/cards/deck = 5,
		            /obj/item/storage/pill_bottle/dice = 10,
		            /obj/item/toy/cards/deck/cas = 3,
		            /obj/item/toy/cards/deck/cas/black = 3)
	contraband = list(/obj/item/dice/fudge = 9)
	refill_canister = /obj/item/vending_refill/games

/obj/item/vending_refill/games
	machine_name = "\improper Good Clean Fun"
	icon_state = "refill_games"
