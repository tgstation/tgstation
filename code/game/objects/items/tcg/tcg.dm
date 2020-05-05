///A global list of cards, or rather changes to be applied to cards in the format

GLOBAL_LIST_EMPTY_TYPED(card_list, /datum/card)

/obj/item/tcgcard
	name = "Coder"
	desc = "Wow, a mint condition coder card! Better tell the Github all about this!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "runtime"
	w_class = WEIGHT_CLASS_TINY
	var/id = -1 //Unique ID, for use in lookups and storage, used to index the global datum list where the rest of the card's info is stored
	var/flipped = 0

/obj/item/tcgcard/Initialize(mapload, datum/card/temp)
	. = ..()
	name = temp.name
	desc = temp.desc
	icon = icon(temp.icon)
	icon_state = temp.icon_state
	id = temp.id
	transform = matrix(0.3,0,0,0,0.3,0)

/datum/card
	var/id = -1 //Unique ID, for use in lookups and storage
	var/name = "Coder"
	var/desc = "Wow, a mint condition coder card! Better tell the Github all about this!"
	var/rules = "There are no rules here. There is no escape. No Recall or Intervention can work in this place."
	var/icon = "icons/obj/tcg.dmi"
	var/icon_state = "runtime"
	var/summoncost = -1
	var/power = 0 //How hard this card hits (by default)
	var/resolve = 0 //How hard this card can get hit (by default)
	var/faction = "socks" //Someone please come up with a ruleset so I can comment this
	var/cardtype ="C43a7u43?" //Used for something something card types, inept pls doc or sm, you know the deal
	var/cardsubtype = "Weeb"
	var/series = "coreset2020"
	var/rarity = "uber rare to the extreme" //The rarity of this card in a set, each set must have at least one of all types

/datum/card/New(list/data, list/templates = list())
	applyTemplates(data, templates)
	apply(data)

/datum/card/proc/apply(list/data)
	for(var/name in (vars & data))
		vars[name] = data[name]

/datum/card/proc/applyTemplates(list/data, list/templates = list())
	apply(templates["default"])
	apply(templates[data["template"]])

/obj/item/tcgcard/attack_self(mob/user)
	. = ..()
	to_chat(user, "<span_class='notice'>You turn the card over.</span>")
	if(flipped == 0)
		name = "Trading Card"
		desc = "It's the back of a trading card... no peeking!"
		icon_state = "cardback"
		flipped = 1
	else
		name = GLOB.card_list["[id]"].name
		desc = GLOB.card_list["[id]"].desc
		icon_state = GLOB.card_list["[id]"].icon_state
		flipped = 0

/obj/item/tcgcard/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/tcgcard/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.3,0,0,0,0.3,0)

/obj/item/cardpack
	name = "Trading Card Pack: Coder"
	desc = "Contains six complete fuckups by the coders. Report this on github please!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "cardback_nt"
	w_class = WEIGHT_CLASS_TINY
	var/series = "MEME" //Mirrors the card series.
	var/contains_coin = -1 //Chance of the pack having a coin in it.
	///The amount of cards each pack contains
	var/card_count = 6
	///The guaranteed rarity table, acts about the same as the rarity table. it can have as many or as few raritys as you'd like
	var/list/guar_rarity = list("misprint" = 1)
	var/list/rarityTable = list(
		"common" = 900,
		"uncommon" = 300,
		"rare" = 100,
		"epic" = 25,
		"legendary" = 10,
		"misprint" = 1)//The rarity table, the set must contain at least one of each

/obj/item/cardpack/series_one
	name = "Trading Card Pack: Series 1"
	desc = "Contains six cards of varying rarity from Series 1. Collect them all!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "cardpack_series1"
	series = "coreset2020"
	contains_coin = 10

/obj/item/cardpack/resin
	name = "Trading Card Pack: Resin Frontier Booster Pack"
	desc = "Contains six cards of varying rarity from the Resin Frontier set. Collect them all!"
	icon = 'icons/obj/tcg_xenos.dmi'
	icon_state = "cardpack_resin"
	series = "S2"
	contains_coin = 0
	rarityTable = list(2,
					20,
					50,
					100,
					1000
					)

/obj/item/cardpack/Initialize()
	. = ..()
	transform = matrix(0.4,0,0,0,0.4,0)

/obj/item/cardpack/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/cardpack/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.4,0,0,0,0.4,0)

/obj/item/cardpack/attack_self(mob/user)
	. = ..()
	var/list/datum/card/cards = buildCardListWithRarity(card_count, guar_rarity, GLOB.card_list)
	for(var/datum/card/template in cards)
		//Makes a new card based of the series of the pack.
		new /obj/item/tcgcard(get_turf(user), template)
	to_chat(user, "<span_class='notice'>Wow! Check out these cards!</span>")
	new /obj/effect/decal/cleanable/wrapping(get_turf(user))
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 20, TRUE)
	if(prob(contains_coin))
		to_chat(user, "<span_class='notice'>...and it came with a flipper, too!</span>")
		new /obj/item/coin/thunderdome(loc)
	qdel(src)

/obj/item/coin/thunderdome
	name = "Thunderdome Flipper"
	desc = "A Thunderdome TCG flipper, for deciding who gets to go first. Also conveniently acts as a counter, for various purposes."
	icon = 'icons/obj/tcg.dmi'
	icon_state = "coin_nanotrasen"
	custom_materials = list(/datum/material/plastic = 400)
	material_flags = NONE
	sideslist = list("nanotrasen", "syndicate")

/obj/item/coin/thunderdome/Initialize()
	. = ..()
	transform = matrix(0.4,0,0,0,0.4,0)

/obj/item/coin/thunderdome/equipped(mob/user, slot, initial)
	. = ..()
	transform = matrix()

/obj/item/coin/thunderdome/dropped(mob/user, silent)
	. = ..()
	transform = matrix(0.4,0,0,0,0.4,0)

///Returns a list of cards of cardCount weighted by rarity from cardList that have matching series, with at least one of guarenteedRarity.
/obj/item/cardpack/proc/buildCardListWithRarity(cardCount, list/guarenteedRarity, list/datum/card/cardList)
	var/list/datum/card/readFrom = list()
	var/list/datum/card/toReturn = list()
	for(var/index in cardList)
		if(cardList[index].series == series)
			readFrom += cardList[index]
	//You can always get at least one of some rarity
	if(guarenteedRarity.len)
		cardCount--
		toReturn += returnCardsByRarity(1, readFrom, guarenteedRarity)
	toReturn += returnCardsByRarity(cardCount, readFrom, rarityTable)
	return toReturn

///Returns a list of card datums of the length cardCount that match a random rarity weighted by rarity_table[]
/obj/item/cardpack/proc/returnCardsByRarity(cardCount, cardList, list/rarity_table)
	var/list/datum/card/toReturn = list()
	for(var/card in 1 to cardCount)
		var/rarity = 0
		//Some number between 1 and the sum of all values in the list
		var/weight = 0
		for(var/chance in rarity_table)
			weight += rarity_table[chance]
		var/random = rand(weight)
		for(var/bracket in rarity_table)
			//Steals blatently from pickweight(), sorry buddy I need the index
			random -= rarity_table[bracket]
			if(random <= 0)
				rarity = bracket
				break
		var/list/datum/card/cards = list()
		for(var/datum/card/template in cardList)
			if(template.rarity == rarity)
				cards += template
		if(cards.len)
			toReturn += pick(cards)
		else
			//If we still don't find anything yell into the void. Lazy coders.
			log_runtime("The index [rarity] of rarity_table does not exist in the supplied cardList")
	return toReturn

///Loads all the card files
/proc/loadAllCardFiles(cardFiles, directory)
	var/list/templates = list()
	for(var/cardFile in cardFiles)
		loadCardFile(cardFile, directory, templates)

///Prints all the cards names
/proc/printAllCards()
	for(var/card in GLOB.card_list)
		message_admins("[GLOB.card_list[card].name]")

///Checks the passed type list for missing raritys, or raritys out of bounds
/proc/checkCardpacks(cardPackList)
	for(var/cardPack in cardPackList)
		var/obj/item/cardpack/pack = new cardPack()
		//Lets build a list of all the cards in our series
		var/list/datum/card/cards = list()
		for(var/index in GLOB.card_list)
			if(GLOB.card_list[index].series == pack.series)
				cards += GLOB.card_list[index]
		var/list/rarityCheck = list("uncommon" = FALSE)
		//Lets run a check to see if all the rarities exist that we want to exist
		for(var/I in pack.rarityTable)
			rarityCheck["[I]"] = FALSE
		for(var/datum/card/template in cards)
			if(!(template.rarity in pack.rarityTable))
				message_admins("[pack.type] has a rarity [template.rarity] on the card [template.id] that does not exist")
				continue
			rarityCheck[template.rarity] = TRUE
		for(var/I in pack.rarityTable)
			if(rarityCheck["[I]"] == FALSE)
				message_admins("[pack.type] does not have the required rarity [I]")
		qdel(pack)

///Used to test open a large amount of cardpacks
/proc/checkCardDistribution(cardPack, batchSize, batchCount)
	var/totalCards = 0
	//Gotta make this look like an associated list so the implicit "does this exist" checks work proper later
	var/list/cardsByCount = list("" = 0)
	var/obj/item/cardpack/pack = new cardPack()
	for(var/index in 1 to batchCount)
		var/list/datum/card/cards = pack.buildCardListWithRarity(batchSize, 0, GLOB.card_list)
		for(var/datum/card/template in cards)
			totalCards++
			cardsByCount["[template.id]"] += 1
	var/toSend = "Out of [totalCards] cards"
	for(var/id in sortList(cardsByCount, /proc/cmp_num_string_asc))
		if(id)
			toSend += "\nID:[id] [GLOB.card_list["[id]"].name] [(cardsByCount[id] * 100) / totalCards]% Total:[cardsByCount[id]]"
	message_admins(toSend)
	qdel(pack)

///Reloads all card files
/proc/reloadAllCardFiles(cardFiles, directory)
	GLOB.card_list = list()
	loadAllCardFiles(cardFiles, directory)

/proc/loadCardFile(filename, directory = "strings/tcg")
	var/list/json = json_decode(file2text("[directory]/[filename]"))
	var/list/cards = json["cards"]
	var/list/templates = list()
	for(var/list/data in json["templates"])
		templates[data["template"]] = data
	for(var/list/data in cards)
		var/datum/card/c = new(data, templates)
		GLOB.card_list["[c.id]"] = c
