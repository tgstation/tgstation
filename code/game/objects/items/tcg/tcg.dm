///A global list of cards, or rather changes to be applied to cards in the format
#define CARD_RARITY_COMMON 1000
#define CARD_RARITY_UNCOMMON 100
#define CARD_RARITY_RARE 50
#define CARD_RARITY_EPIC 20
#define CARD_RARITY_LEGENDARY 2
#define CARD_RARITY_MISPRINT 1

GLOBAL_LIST_EMPTY_TYPED(card_list, /datum/card)
GLOBAL_LIST_INIT(cardTypeLookup, list("name" = 0,
								"desc" = 1,
								"icon" = 2,
								"icon_state" = 3,
								"id" = 4,
								"power" = 5,
								"resolve" = 6,
								"tags" = 7,
								"cardtype" = 8,
								"rarity" = 9,
								))

/obj/item/tcgcard
	name = "Coder"
	desc = "Wow, a mint condition coder card! Better tell the Github all about this!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "runtime"
	var/id = -1 //Unique ID, for use in lookups and storage, used to index the global datum list where the rest of the card's info is stored
	var/flipped = 0

/obj/item/tcgcard/Initialize(mapload, datum/card/temp)
	. = ..()
	name = temp.name
	desc = temp.desc
	icon = icon(temp.state_location)
	icon_state = temp.icon_state
	id = temp.id
	transform = matrix(0.3,0,0,0,0.3,0)

/datum/card
	var/name = "Coder"
	var/desc = "Wow, a mint condition coder card! Better tell the Github all about this!"
	var/state_location = 'icons/obj/tcg.dmi'
	var/icon_state = "runtime"
	var/id = -1 //Unique ID, for use in lookups and storage
	var/power = 0 //How hard this card hits (by default)
	var/resolve = 0 //How hard this card can get hit (by default)
	var/tags = "" //Special tags
	var/cardtype = "" //Cardtype, for use in battles. Arcane/Inept if you don't update this whole block when you finalize the game I will throw you into the sm
	var/rarity = 0 //The rarity of this card in a set, each set must have at least one of all types

/datum/card/New(location, card)
	if(card != "")
		//Sets the variables of the card based off the string
		name = extractCardVariable("name", card)
		desc = extractCardVariable("desc", card)
		state_location = extractCardVariable("icon", card)
		icon_state = extractCardVariable("icon_state", card)
		id = text2num(extractCardVariable("id", card))
		power = text2num(extractCardVariable("power", card))
		resolve = text2num(extractCardVariable("resolve", card))
		tags = extractCardVariable("tags", card)
		cardtype = extractCardVariable("cardtype", card)
		rarity = text2num(extractCardVariable("rarity", card))

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
	var/series = "MEME" //Mirrors the card series.
	var/contains_coin = -1 //Chance of the pack having a coin in it.
	///The amount of cards each pack contains
	var/card_count = 6
	///The guarenteed rarity, if none set this to 0
	var/guar_rarity = 4
	var/list/rarityTable = list(1,
							2,
							20,
							50,
							100,
							1000
							) //The rarity table, the set must contain at least one of each

/obj/item/cardpack/series_one
	name = "Trading Card Pack: Series 1"
	desc = "Contains six cards of varying rarity from Series 1. Collect them all!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "cardpack_series1"
	series = "S1"
	contains_coin = 0

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
	desc = "A Thunderdome TCG flipper, for finding who gets to go first."
	icon_state = "coin_valid"
	custom_materials = list(/datum/material/plastic = 400)
	material_flags = NONE

///Returns a list of cards of cardCount weighted by rarity from cardList that have matching tags to series, with at least one of guarenteedRarity.
/obj/item/cardpack/proc/buildCardListWithRarity(cardCount, guarenteedRarity, cardList)
	var/list/datum/card/readFrom = list()
	var/list/datum/card/toReturn = list()
	for(var/index in cardList)
		if(isCardTagsMatch(cardList[index], series))
			readFrom += cardList[index]
	//You can always get at least one of some rarity
	if(guarenteedRarity > 0 && guarenteedRarity <= rarityTable.len)
		cardCount--
		var/list/datum/card/forSure = list()
		for(var/datum/card/template in readFrom)
			if(template.rarity == guarenteedRarity)
				forSure += template
		if(forSure.len)
			toReturn += pick(forSure)
		else
			log_runtime("The guarenteed index [guarenteedRarity] of rarityTable does not exist in the supplied cardList")
	toReturn += returnCardsByRarity(cardCount, readFrom)
	return toReturn

///Returns a list of card datums of the length cardCount that match a random rarity weighted by rarityTable[]
/obj/item/cardpack/proc/returnCardsByRarity(cardCount, cardList)
	var/list/datum/card/toReturn = list()
	for(var/card in 1 to cardCount)
		var/rarity = 0
		//Some number between 1 and the sum of all values in the list
		var/weight = 0
		for(var/chance in rarityTable)
			weight += chance
		var/random = rand(weight)
		for(var/bracket in 1 to rarityTable.len)
			//Steals blatently from pickweight(), sorry buddy I need the index
			random -= rarityTable[bracket]
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
			log_runtime("The index [rarity] of rarityTable does not exist in the supplied cardList")
	return toReturn

///If the card's tags contain the input data, we return true, false if not
/proc/isCardTagsMatch(datum/card/template, matchBy)
	//This is where we isolate the data actually stored.
	//We will now loop through our options to see if either of them are an exact match
	var/content = splittext(template.tags, "&")
	for(var/tex in content)
		//We do this to allow number inputs for searches
		if(tex == "[matchBy]")
			return TRUE
	//If we found nothing
	return FALSE

///Gets the fully expanded card def based on the passed template list
/proc/expandCard(card, templates)
	//Gets the cards template
	var/temp = getCardTemplate(card)
	if(temp == "")
		//If it has no template
		return applyDefaultCardTemplate(card, templates)
	temp = findCardTemplate(temp, templates)
	if(temp == "")
		//If the list did not contain the right template
		return applyDefaultCardTemplate(card, templates)
	card = applyCardTemplate(temp, card)
	//Returns the card with the default template applied
	return applyDefaultCardTemplate(card, templates)

/proc/applyDefaultCardTemplate(card, templates)
	//Attempts to find the default template, so we can apply it
	//This template should fill all gaps so we can debug any malformed input
	var/temp = findCardTemplate("default", templates)
	if(temp == "")
		//If the list did not contain a default
		return card
	return applyCardTemplate(temp, card)

///Returns the name of the template the card is using, or returns ""
/proc/getCardTemplate(card)
	//Anything that's got a template mentioned at the start of it's def
	var/regex/template = regex("\[$\]+\[^\\|\]*\\|")
	if(template.Find(card))
		//If it's got a template def, it's gonna be the first thing
		return splittext(splittext(card, "|")[1], "$")[2]
	return ""

///Returns the template string in full based of the name if it exists, otherwise it returns ""
/proc/findCardTemplate(template, list/templates)
	var/regex/isIt = regex("[template]\\|")
	for(var/temp in templates)
		if(isIt.Find(templates[temp]))
			return templates[temp]
	return ""

///Applies the template to the card, returns the card with the template applied
/proc/applyCardTemplate(template, card)
	//Removes the template from the referance
	var/list/split = splittext(card, "[template]|")
	if(split.len >= 2)
		card = "|[split[2]]"
	var/done = ""
	for(var/index in 0 to GLOB.cardTypeLookup.len - 1)
		done += applyCardTemplateByIndex(index, card, template)
	return done + "|"

///Applies a template to a specified index
/proc/applyCardTemplateByIndex(index, card, template)
	//We're isolating the values, and trying to figure out if the card has that index defined
	var/list/isDefined = splittext(card, "[index],")
	var/list/plate = splittext(template, "[index],")
	//If both defs have the index
	if(isDefined.len >= 2 && plate.len >= 2)
		//Isolates the text
		isDefined = splittext(isDefined[2], "|")
		plate = splittext(plate[2], "|")
		//Cuts out the $
		isDefined = splittext(isDefined[1], "$")
		//If isDefined has a $
		if(isDefined.len >= 2 && plate.len >= 1)
			return "|[index],[isDefined[1]][plate[1]][isDefined[2]]"
		//Otherwise we should leave it untouched
		if(isDefined.len >= 1)
			return "|[index],[isDefined[1]]"
		//If only the template has the index we should just return the data it has
	if(plate.len >= 2)
		//Isolate the data
		plate = splittext(plate[2], "|")
		//Format it
		if(plate.len >= 1)
			return "|[index],[plate[1]]"
	//Returns the cards data if only it has the index
	if(isDefined.len >= 2)
		//Isolate the text
		isDefined = splittext(isDefined[2], "|")
		if(isDefined.len >= 1)
			return "|[index],[isDefined[1]]"
	//If nither has the index, return ""
	return ""

///Extracts the specified variable from the card and returns it
/proc/extractCardVariable(matchType = "id", card)
	var/list/toReturn = splittext(card, "|[GLOB.cardTypeLookup[matchType]],")
	if(toReturn.len >= 2)
		toReturn = splittext(toReturn[2], "|")
		if(toReturn.len >= 2)
			return toReturn[1]
	return ""

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
			if(isCardTagsMatch(GLOB.card_list[index], pack.series))
				cards += GLOB.card_list[index]
		var/list/rarityCheck = list("1" = FALSE)
		//Lets run a check to see if all the rarities exist that we want to exist
		for(var/I in 1 to pack.rarityTable.len)
			rarityCheck["[I]"] = FALSE
		for(var/datum/card/template in cards)
			if(template.rarity <= 0 || template.rarity > pack.rarityTable.len)
				message_admins("[pack.type] has a rarity [template.rarity] on the card [template.id] that is out of the bounds of 1 to [pack.rarityTable.len]")
				continue
			rarityCheck[template.rarity] = TRUE
		for(var/I in 1 to pack.rarityTable.len)
			if(rarityCheck["[I]"] == FALSE)
				message_admins("[pack.type] does not have the required rarity [rarityCheck[I]] in the range 1 to [pack.rarityTable.len]")
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

///Loads a card file and turns its contents into card datums using the currently loaded templates
/proc/loadCardFile(filename, directory = "strings/tcg", templates)
	//The parser for vscode doesn't like raw strings, that's why this looks fucky
	var/regex/template = regex("^(\[^$\\|\]+\\|)")
	var/list/temp_card_list = list()
	for(var/card in splittext(file2text("[directory]/[filename]"), "\n"))
		//For quick lookup, if you don't have an index get dunked on
		var/index = text2num(extractCardVariable("id", card))
		if(index)
			if(template.Find(card))
				templates["[index]"] = card
			else
				temp_card_list["[index]"] = card
	for(var/index in temp_card_list)
		var/full_card = expandCard(temp_card_list[index], templates)//Expands the card fully
		GLOB.card_list[index] = new /datum/card/(card = full_card)
