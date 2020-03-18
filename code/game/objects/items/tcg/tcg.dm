///A global list of cards, or rather changes to be applied to cards in the format
GLOBAL_LIST(card_list)
GLOBAL_LIST(card_template_list)
var/list/cardTypeLookup = list("name" = 0,
								"desc" = 1,
								"icon" = 2,
								"icon_state" = 3,
								"id" = 4,
								"power" = 5,
								"resolve" = 6,
								"tags" = 7,
								"cardtype" = 8,
								)
#define MAX_INDEX 8

/obj/item/tcgcard
	name = "Coder"
	desc = "Wow, a mint condition coder card! Better tell the Github all about this!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "runtime"
	var/id = -1 //Unique ID, for use in lookups and storage
	var/power = 0 //How hard this card hits (by default)
	var/resolve = 0 //How hard this card can get hit (by default)
	var/tags = "" //Special tags
	var/cardtype = "" //Cardtype, for use in battles. Arcane/Inept if you don't update this whole block when you finalize the game I will throw you into the sm

///Creates a card based on a passed card string
/obj/item/tcgcard/Initialize(mapload, card)
	if(card != "")
		//Applies template and default.
		card = expandCard(card, GLOB.card_template_list)
		//Sets the variables of the card based off the string
		name = extractCardVariable("name", card)
		desc = extractCardVariable("desc", card)
		var/icon/con = new(extractCardVariable("icon", card))
		icon = con
		icon_state = extractCardVariable("icon_state", card)
		id = text2num(extractCardVariable("id", card))
		power = text2num(extractCardVariable("power", card))
		resolve = text2num(extractCardVariable("resolve", card))
		tags = extractCardVariable("tags", card)
		cardtype = extractCardVariable("cardtype", card)
	. = ..()

/obj/item/cardpack
	name = "Trading Card Pack: Series 1"
	desc = "Contains six cards of varying rarity from Series 1. Collect them all!"
	icon = 'icons/obj/tcg.dmi'
	icon_state = "cardback_nt"
	var/series = "S1" //Mirrors the card series.
	var/contains_coin = 0 //Chance of the pack having a coin in it.

/obj/item/cardpack/attack_self(mob/user)
	. = ..()
	var/list/cards = extractAllMatchingCards("tags", series, GLOB.card_list, GLOB.card_template_list)
	for(var/i = 1 to 6)
		//Makes a new card based of the series of the pack.
		new /obj/item/tcgcard(get_turf(user), pick(cards))
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

///Extracts all matching cards from the list, and returns a list of them
/proc/extractAllMatchingCards(matchType = "id", matchBy = -1, cardList, templateList)
	var/list/toReturn = list()
	for(var/card in cardList)
		card = expandCard(cardList[card], templateList)
		if(isCardMatch(matchType, matchBy, card))
			toReturn += card
	return toReturn

///If the card string contains the input data at the type, we return true if it does, false if not
/proc/isCardMatch(matchType = "id", matchBy = -1, card)
	//What we're doing here is isolating the data of the index we want, assuming it's actually contained here
	var/list/content = splittext(card, "[cardTypeLookup[matchType]],")
	//If there is no match for the datatype
	if(content.len < 2)
		return FALSE
	//Now we attempt to isolate the datatype. This will return "" if we have malformed input
	content = splittext(content[2], "|")
	if(content.len < 2)
		return FALSE
	//This is where we isolate the data actually stored.
	//We will now loop through our options to see if either of them are an exact match
	content = splittext(content[1], "&")
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
	for(var/index in 0 to MAX_INDEX)
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
	var/list/toReturn = splittext(card, "|[cardTypeLookup[matchType]],")
	if(toReturn.len >= 2)
		toReturn = splittext(toReturn[2], "|")
		if(toReturn.len >= 2)
			return toReturn[1]
	return ""

/proc/loadAllCardFiles(cardFiles, directory)
	for(var/cardFile in cardFiles)
		loadCardFile(cardFile, directory)

/proc/printAllCards()
	for(var/card in GLOB.card_list)
		message_admins("[GLOB.card_list[card]]")

/proc/printAllTemplates()
	for(var/template in GLOB.card_template_list)
		message_admins("[GLOB.card_template_list[template]]")

/proc/reloadAllCardFiles(cardFiles, directory)
	GLOB.card_list = list()
	GLOB.card_template_list = list()
	loadAllCardFiles(cardFiles, directory)

/proc/loadCardFile(filename, directory = "strings/tcg")
	//The parser for vscode doesn't like raw strings, that's why this looks fucky
	var/regex/templates = regex("^(\[^$\\|\]+\\|)")
	for(var/card in splittext(file2text("[directory]/[filename]"), "\n"))
		//For quick lookup, if you don't have an index get dunked on
		var/index = text2num(extractCardVariable("id", card))
		if(index)
			if(templates.Find(card))
				GLOB.card_template_list["[index]"] = card
			else
				GLOB.card_list["[index]"] = card

