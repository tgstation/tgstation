SUBSYSTEM_DEF(trading_card_game)
	name = "Trading Card Game"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TCG
	/// Base directory for all related string files
	var/card_directory = "strings/tcg"
	/// List of card files to load
	var/list/card_files = list("set_one.json", "set_two.json")
	/// List of keyword files
	/// These allow you to add on hovor logic to parts of a card's text, displaying extra info
	var/list/keyword_files = list("keywords.json")
	/// What cardpack types to load
	var/card_packs = list(/obj/item/cardpack/series_one, /obj/item/cardpack/resin)
	var/list/cached_guar_rarity = list()
	var/list/cached_rarity_table = list()
	/// List of all cards by series, with cards cached by rarity to make those lookups faster
	var/list/cached_cards = list()
	/// List of loaded keywords matched with their hovor text
	var/list/keywords = list()
	var/loaded = FALSE

//Let's load the cards before the map fires, so we can load cards on the map safely
/datum/controller/subsystem/trading_card_game/Initialize()
	reloadAllCardFiles()
	return SS_INIT_SUCCESS

///Loads all the card files
/datum/controller/subsystem/trading_card_game/proc/loadAllCardFiles()
	for(var/keyword_file in keyword_files)
		loadKeywordFile(keyword_file, card_directory)
	styleKeywords()
	for(var/card_file in card_files)
		loadCardFile(card_file, card_directory)

///Empty the rarity cache so we can safely add new cards
/datum/controller/subsystem/trading_card_game/proc/clearCards()
	loaded = FALSE
	cached_cards = list()
	keywords = list()

///Reloads all card files
/datum/controller/subsystem/trading_card_game/proc/reloadAllCardFiles()
	clearCards()
	loadAllCardFiles()
	loaded = TRUE

///Loads the contents of a json file into our global card list
/datum/controller/subsystem/trading_card_game/proc/loadKeywordFile(filename, directory = "strings/tcg")
	var/list/keyword_data = json_decode(file2text("[directory]/[filename]"))
	for(var/keyword in keyword_data)
		if(keywords[keyword])
			stack_trace("Dupe detected, [keyword] was defined by [directory]/[filename] after it already had a value!")
			continue
		keywords[keyword] = keyword_data[keyword]

///Styles our keywords, converting them from just the raw text to the output we want
/datum/controller/subsystem/trading_card_game/proc/styleKeywords()
	// Add the tooltip component to our text, make it pretty
	for(var/keyword in keywords)
		var/tooltip_text = keywords[keyword]
		keywords[keyword] = span_tooltip(tooltip_text, keyword)

///Takes a string as input. Searches it for keywords in the pattern {$keyword}, and replaces them with their expanded form, generated above
/datum/controller/subsystem/trading_card_game/proc/resolve_keywords(search_through)
	var/starting_text = search_through
	while(TRUE)
		var/fragment_start = findtext(search_through, "{$")
		if(!fragment_start)
			break
		var/fragment_end = findtext(search_through, "}")
		if(!fragment_end)
			CRASH("[starting_text] contains a {$ that denotes the start of a keyword replacement, but not a closing }!")
		///Gets the keyword this string wants to use
		///We offset the start by two indexes to account for
		var/keyword = copytext(search_through, fragment_start + 2, fragment_end)
		var/replacement = keywords[keyword]
		if(!replacement)
			CRASH("[starting_text] contains a non-existent keyword! \[[keyword]\]")
		search_through = replacetext(search_through, "{$[keyword]}", replacement)

	return search_through

///Loads the contents of a json file into our global card list
/datum/controller/subsystem/trading_card_game/proc/loadCardFile(filename, directory = "strings/tcg")
	var/list/json = json_decode(file2text("[directory]/[filename]"))
	var/list/cards = json["cards"]
	var/list/templates = list()
	for(var/list/data in json["templates"])
		templates[data["template"]] = data
	for(var/list/data in cards)
		var/datum/card/card = new(data, templates)
		//Lets cache the id by rarity, for top speed lookup later
		if(!cached_cards[card.series])
			cached_cards[card.series] = list()
			cached_cards[card.series]["ALL"] = list()
		if(!cached_cards[card.series][card.rarity])
			cached_cards[card.series][card.rarity] = list()
		cached_cards[card.series][card.rarity] += card.id
		//Let's actually store the datum here
		cached_cards[card.series]["ALL"][card.id] = card

///Because old me wanted to keep memory costs down, each cardpack type shares a rarity list
///We do the spooky stuff in here to ensure we don't have too many lists lying around
/datum/controller/subsystem/trading_card_game/proc/get_rarity_table(type, list/sample_table)
	//Pass by refrance moment
	//This lets us only have one rarity table per pack, badmins beware
	//Yes this is horribly overengineered. No I am not sorry
	if(!cached_rarity_table[type])
		cached_rarity_table[type] = sample_table
	return cached_rarity_table[type]

///See above
/datum/controller/subsystem/trading_card_game/proc/get_guarenteed_rarity_table(type, list/sample_table)
	if(!cached_guar_rarity[type])
		cached_guar_rarity[type] = sample_table
	return cached_guar_rarity[type]

///Prints all the cards names
/datum/controller/subsystem/trading_card_game/proc/printAllCards()
	for(var/card_set in cached_cards)
		message_admins("Printing the [card_set] set")
		for(var/card in cached_cards[card_set]["ALL"])
			var/datum/card/toPrint = cached_cards[card_set]["ALL"][card]
			message_admins(toPrint.name)

///Checks the passed type list for missing raritys, or raritys out of bounds
/datum/controller/subsystem/trading_card_game/proc/check_cardpacks(card_pack_list)
	var/toReturn = ""
	for(var/cardPack in card_pack_list)
		var/obj/item/cardpack/pack = new cardPack()
		//Lets see if someone made a type yeah?
		if(!cached_cards[pack.series])
			toReturn += "[pack.series] does not have any cards in it\n"
			continue
		for(var/card in cached_cards[pack.series]["ALL"])
			var/datum/card/template = cached_cards[pack.series]["ALL"][card]
			if(template.rarity == "ALL")
				toReturn += "[pack.type] has a rarity [template.rarity] on the card [template.id] that needs to be changed to something that isn't \"ALL\"\n"
				continue
			if(!(template.rarity in pack.rarity_table))
				toReturn += "[pack.type] has a rarity [template.rarity] on the card [template.id] that does not exist\n"
				continue
		//Lets run a check to see if all the rarities exist that we want to exist exist
		for(var/pack_rarity in pack.rarity_table)
			if(!cached_cards[pack.series][pack_rarity])
				toReturn += "[pack.type] does not have the required rarity [pack_rarity]\n"
		qdel(pack)

	return toReturn

///Checks the global card list for cards that don't override all the default values of the card datum
/datum/controller/subsystem/trading_card_game/proc/check_card_datums()
	var/toReturn = ""
	var/datum/thing = new()
	for(var/series in cached_cards)
		var/cards = cached_cards[series]["ALL"]
		for(var/card in cards)
			var/datum/card/target = cached_cards[series]["ALL"][card]
			var/toAdd = "The card [target.id] in [series] has the following default variables:"
			var/shouldAdd = FALSE
			for(var/current_var in (target.vars ^ thing.vars))
				if(current_var == "icon" && target.vars[current_var] == DEFAULT_TCG_DMI)
					continue
				if(target.vars[current_var] == initial(target.vars[current_var]))
					shouldAdd = TRUE
					toAdd += "\n[current_var] with a value of [target.vars[current_var]]"
			if(shouldAdd)
				toReturn += toAdd
	qdel(thing)

	return toReturn

///Used to test open a large amount of cardpacks
/datum/controller/subsystem/trading_card_game/proc/check_card_distribution(cardPack, batchSize, batchCount, guaranteed)
	var/totalCards = 0
	//Gotta make this look like an associated list so the implicit "does this exist" checks work proper later
	var/list/cardsByCount = list("" = 0)
	var/obj/item/cardpack/pack = new cardPack()
	for(var/index in 1 to batchCount)
		var/list/cards = pack.buildCardListWithRarity(batchSize, guaranteed)
		for(var/id in cards)
			totalCards++
			cardsByCount[id] += 1
	var/toSend = "Out of [totalCards] cards"
	for(var/id in sort_list(cardsByCount, GLOBAL_PROC_REF(cmp_num_string_asc)))
		if(id)
			var/datum/card/template = cached_cards[pack.series]["ALL"][id]
			toSend += "\nID:[id] [template.name] [(cardsByCount[id] * 100) / totalCards]% Total:[cardsByCount[id]]"
	message_admins(toSend)
	qdel(pack)
