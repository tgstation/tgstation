/obj/item/storage/briefcase/secure/wargame_kit
	name = "DIY Wargaming Kit"
	desc = "Contains everything an aspiring naval officer (or just huge fucking nerd) would need for a proper modern naval wargame."
	custom_premium_price = PAYCHECK_CREW * 2

/obj/item/storage/briefcase/secure/white/wargame_kit/PopulateContents()
	var/static/items_inside = list(
		/obj/item/wargame_projector/ships = 1,
		/obj/item/wargame_projector/ships/red = 1,
		/obj/item/wargame_projector/terrain = 1,
		/obj/item/storage/dice = 1,
		/obj/item/book/manual/wargame_rules = 1,
		/obj/item/book/manual/wargame_rules/examples = 1,
		)
	generate_items_inside(items_inside,src)

/obj/item/book/manual/wargame_rules
	name = "Wargame: Blue Lizard - Example Ruleset"
	icon_state = "book"
	starting_author = "John War - CEO of War"
	starting_title = "Wargame: Blue Lizard - Example Ruleset"
	starting_content = "Formatting is a fuck - 2564 kill em all - Just go to this link in your browser <b>https://hackmd.io/@Paxilmaniac/H1ZVsTIYR</b>"

/obj/item/book/manual/wargame_rules/examples
	name = "Wargame: Blue Lizard - Example Ships and Scenarios"
	icon_state = "book1"
	starting_author = "John War - CEO of War"
	starting_title = "Wargame: Blue Lizard - Example Ships and Scenarios"
	starting_content = "Formatting is a fuck - 2564 kill em all - Just go to this link in your browser <b>https://hackmd.io/@Paxilmaniac/rJwy1C8KR</b>"
