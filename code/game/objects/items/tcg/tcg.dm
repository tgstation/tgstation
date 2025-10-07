#define TAPPED_ANGLE 90
#define UNTAPPED_ANGLE 0

/obj/item/tcgcard
	name = "Coder"
	desc = "Wow, a mint condition coder card! Better tell the GitHub all about this!"
	icon = DEFAULT_TCG_DMI_ICON
	icon_state = "runtime"
	w_class = WEIGHT_CLASS_TINY
	///Unique ID, for use in lookups and storage, used to index the global datum list where the rest of the card's info is stored
	var/id = "code"
	///Used along with the id for lookup
	var/series = "coderbus"
	///Is the card flipped?
	var/flipped = FALSE
	///Has this card been "tapped"? AKA, is it horizontal?
	var/tapped = FALSE
	///Cached icon used for inspecting the card
	var/icon/cached_flat_icon

/obj/item/tcgcard/Initialize(mapload, datum_series, datum_id)
	. = ..()
	AddElement(/datum/element/item_scaling, 0.3, 1)
	//If they are passed as null let's replace them with the vars on the card. this also means we can allow for map loaded ccards
	if(!datum_series)
		datum_series = series
	if(!datum_id)
		datum_id = id
	var/list/temp_list = SStrading_card_game.cached_cards[datum_series]
	if(!temp_list)
		return
	var/datum/card/temp = temp_list["ALL"][datum_id]
	if(!temp)
		return
	name = temp.name
	desc = "<i>[temp.desc]</i>"
	icon = icon(temp.icon)
	icon_state = temp.icon_state
	id = temp.id
	series = temp.series

// This totally isn't overengineered to hell, shut up
/**
 * Alright so some brief details here, we store all "immutable" (Think like power) card variables in a global list, indexed by id
 * This proc gets the card's associated card datum to play with
 */
/obj/item/tcgcard/proc/extract_datum()
	var/list/cached_cards = SStrading_card_game.cached_cards[series]
	if(!cached_cards)
		return null
	if(!cached_cards["ALL"][id])
		CRASH("A card without a datum has appeared, either the global list is empty, or you fucked up bad. Series{[series]} ID{[id]} Len{[SStrading_card_game.cached_cards.len]}")
	return cached_cards["ALL"][id]

/obj/item/tcgcard/get_name_chaser(mob/user, list/name_chaser = list())
	if(flipped)
		return ..()
	var/datum/card/data_holder = extract_datum()

	name_chaser += "Faction: [data_holder.faction]"
	name_chaser += "Cost: [data_holder.summoncost]"
	name_chaser += "Type: [data_holder.cardtype] - [data_holder.cardsubtype]"
	name_chaser += "Power/Resolve: [data_holder.power]/[data_holder.resolve]"
	if(data_holder.rules) //This can sometimes be empty
		name_chaser += "Ruleset: [data_holder.rules]"
	name_chaser += list("[icon2html(get_cached_flat_icon(), user, "extra_classes" = "hugeicon")]")

	return name_chaser

/obj/item/tcgcard/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
	return cached_flat_icon

GLOBAL_LIST_EMPTY(tcgcard_radial_choices)

/obj/item/tcgcard/attack_hand(mob/user, list/modifiers)
	if(!isturf(loc))
		return ..()
	var/list/choices = GLOB.tcgcard_radial_choices
	if(!length(choices))
		choices = GLOB.tcgcard_radial_choices = list(
		"Pickup" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_pickup"),
		"Tap" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_tap"),
		"Flip" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_flip"),
		)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(choice)
		if("Tap")
			tap_card(user)
		if("Pickup")
			user.put_in_hands(src)
		if("Flip")
			flip_card(user)
		if(null)
			return

/obj/item/tcgcard/attack_self(mob/user)
	. = ..()
	flip_card(user)

/obj/item/tcgcard/update_name(updates)
	. = ..()
	if(!flipped)
		var/datum/card/template = extract_datum()
		name = template.name
	else
		name = "Trading Card"

/obj/item/tcgcard/update_desc(updates)
	. = ..()
	if(!flipped)
		var/datum/card/template = extract_datum()
		desc = "<i>[template.desc]</i>"
	else
		desc = "It's the back of a trading card... no peeking!"

/obj/item/tcgcard/update_icon_state()
	if(flipped)
		icon_state = "cardback"
		return ..()

	var/datum/card/template = extract_datum()
	if(!template)
		return
	icon_state = template.icon_state
	return ..()

/obj/item/tcgcard/attackby(obj/item/item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(istype(item, /obj/item/tcgcard))
		var/obj/item/tcgcard/second_card = item
		var/obj/item/tcgcard_deck/new_deck = new /obj/item/tcgcard_deck(drop_location())
		new_deck.flipped = flipped
		user.transferItemToLoc(second_card, new_deck)//Start a new pile with both cards, in the order of card placement.
		user.transferItemToLoc(src, new_deck)
		new_deck.update_icon_state()
		user.put_in_hands(new_deck)
	if(istype(item, /obj/item/tcgcard_deck))
		var/obj/item/tcgcard_deck/old_deck = item
		if(length(old_deck.contents) >= 30)
			to_chat(user, span_notice("This pile has too many cards for a regular deck!"))
			return
		user.transferItemToLoc(src, old_deck)
		flipped = old_deck.flipped
		old_deck.update_appearance()
		update_appearance()
	return ..()

/obj/item/tcgcard/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/tcgcard/proc/tap_card(mob/user)
	var/matrix/ntransform = matrix(transform)
	if(tapped)
		ntransform.TurnTo(TAPPED_ANGLE , UNTAPPED_ANGLE)
	else
		ntransform.TurnTo(UNTAPPED_ANGLE , TAPPED_ANGLE)
	tapped = !tapped
	animate(src, transform = ntransform, time = 2, easing = SINE_EASING)

/obj/item/tcgcard/proc/flip_card(mob/user)
	to_chat(user, span_notice("You turn the card over."))
	if(!flipped)
		name = "Trading Card"
		desc = "It's the back of a trading card... no peeking!"
		icon_state = "cardback"
	else
		var/datum/card/template = extract_datum()
		name = template.name
		desc = "<i>[template.desc]</i>"
		icon_state = template.icon_state
	flipped = !flipped

/**
 * A stack item that's not actually a stack because ORDER MATTERS with a deck of cards!
 * The "top" card of the deck will always be the bottom card in the stack for our purposes.
 */
/obj/item/tcgcard_deck
	name = "Trading Card Pile"
	desc = "A stack of TCG cards."
	icon = 'icons/obj/toys/tcgmisc.dmi'
	icon_state = "deck_up"
	base_icon_state = "deck"
	obj_flags = UNIQUE_RENAME
	var/flipped = FALSE
	var/static/radial_draw = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_draw")
	var/static/radial_shuffle = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_shuffle")
	var/static/radial_pickup = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_pickup")

/obj/item/tcgcard_deck/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/tcg)
	RegisterSignal(atom_storage, COMSIG_STORAGE_REMOVED_ITEM, PROC_REF(on_item_removed))

/obj/item/tcgcard_deck/update_icon_state()
	if(!flipped)
		icon_state = "[base_icon_state]_up"
		return ..()

	switch(contents.len)
		if(1 to 10)
			icon_state = "[base_icon_state]_tcg_low"
		if(11 to 20)
			icon_state = "[base_icon_state]_tcg_half"
		if(21 to INFINITY)
			icon_state = "[base_icon_state]_tcg_full"
		else
			icon_state = "[base_icon_state]_tcg"
	return ..()

/obj/item/tcgcard_deck/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] has [contents.len] cards inside.")

/obj/item/tcgcard_deck/attack_hand(mob/user, list/modifiers)
	var/list/choices = list(
		"Draw" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_draw"),
		"Shuffle" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_shuffle"),
		"Pickup" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_pickup"),
		"Flip" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_flip"),
		)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(choice)
		if("Draw")
			draw_card(user)
		if("Shuffle")
			shuffle_deck(user)
		if("Pickup")
			user.put_in_hands(src)
		if("Flip")
			flip_deck()
		if(null)
			return

/obj/item/tcgcard_deck/Destroy()
	for(var/card in 1 to contents.len)
		var/obj/item/tcgcard/stored_card = contents[card]
		stored_card.forceMove(drop_location())
	. = ..()

/obj/item/tcgcard_deck/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/tcgcard_deck/attackby(obj/item/item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(istype(item, /obj/item/tcgcard))
		if(contents.len >= 30)
			to_chat(user, span_notice("This pile has too many cards for a regular deck!"))
			return FALSE
		var/obj/item/tcgcard/new_card = item
		new_card.flipped = flipped
		new_card.forceMove(src)


/obj/item/tcgcard_deck/attack_self(mob/living/carbon/user)
	shuffle_deck(user)
	return ..()

/**
 * The user draws a single card. The deck is then handled based on how many cards are left.
 */
/obj/item/tcgcard_deck/proc/draw_card(mob/user)
	if(!contents.len)
		CRASH("A TCG deck was created with no cards inside of it.")
	var/obj/item/tcgcard/drawn_card = contents[contents.len]
	user.put_in_hands(drawn_card)
	drawn_card.flipped = flipped //If it's a face down deck, it'll be drawn face down, if it's a face up pile you'll draw it face up.
	drawn_card.update_icon_state()
	user.visible_message(span_notice("[user] draws a card from \the [src]!"), \
					span_notice("You draw a card from \the [src]!"))
	if(contents.len <= 1)
		var/obj/item/tcgcard/final_card = contents[1]
		user.transferItemToLoc(final_card, drop_location())
		qdel(src)


/**
 * The user shuffles the order of the deck, then closes any visability into the deck's storage to prevent cheesing.
 * *User: The person doing the shuffling, used in visable message and closing UI.
 * *Visible: Will anyone need to hear the visable message about the shuffling?
 */
/obj/item/tcgcard_deck/proc/shuffle_deck(mob/user, visable = TRUE)
	if(!contents)
		return
	contents = shuffle(contents)
	if(user.active_storage)
		user.active_storage.hide_contents(user)
	if(visable)
		user.visible_message(span_notice("[user] shuffles \the [src]!"), \
						span_notice("You shuffle \the [src]!"))


/**
 * The user flips the deck, turning it into a face up/down pile, and reverses the order of the cards from top to bottom.
 */
/obj/item/tcgcard_deck/proc/flip_deck()
	flipped = !flipped
	var/list/temp_deck = contents.Copy()
	contents = reverse_range(temp_deck)
	//Now flip the cards to their opposite positions.
	for (var/obj/item/tcgcard/nu_card as anything in contents)
		nu_card.flipped = flipped
		nu_card.update_icon_state()
	update_icon_state()

/**
 * Signal handler for COMSIG_STORAGE_REMOVED_ITEM. Qdels src if contents are empty, flips the removed card if needed.
 */
/obj/item/tcgcard_deck/proc/on_item_removed(datum/storage/storage_datum, obj/item/thing, atom/remove_to_loc, silent = FALSE)
	SIGNAL_HANDLER

	if (!istype(thing, /obj/item/tcgcard))
		return
	var/obj/item/tcgcard/card = thing
	card.flipped = flipped
	card.update_appearance(UPDATE_ICON_STATE)

	if(length(contents) == 0)
		qdel(src)

/obj/item/cardpack
	name = "Trading Card Pack: Coder"
	desc = "Contains six complete fuckups by the coders. Report this on GitHub please!"
	icon = 'icons/obj/toys/tcgmisc.dmi'
	icon_state = "error"
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_CREW * 0.75 //Price reduced from * 2 to * 0.75, this is planned as a temporary measure until card persistence is added.
	///The card series to look in
	var/series = "MEME"
	///Chance of the pack having a coin in it out of 10
	var/contains_coin = -1
	///The amount of cards to draw from the rarity table
	var/card_count = 5
	///The rarity table, the set must contain at least one of each
	var/list/rarity_table = list(
		"common" = 900,
		"uncommon" = 300,
		"rare" = 100,
		"epic" = 30,
		"legendary" = 5,
		"misprint" = 1)
	///The amount of cards to draw from the guaranteed rarity table
	var/guaranteed_count = 1
	///The guaranteed rarity table, acts about the same as the rarity table. it can have as many or as few raritys as you'd like
	var/list/guar_rarity = list(
		"legendary" = 1,
		"epic" = 9,
		"rare" = 30,
		"uncommon" = 60)
	var/drop_all_cards = FALSE

/obj/item/cardpack/series_one
	name = "Trading Card Pack: Series 1"
	desc = "Contains six cards of varying rarity from the 2560 Core Set. Collect them all!"
	icon_state = "cardpack_series1"
	series = "coreset2020"
	contains_coin = 10

/obj/item/cardpack/resin
	name = "Trading Card Pack: Resin Frontier Booster Pack"
	desc = "Contains six cards of varying rarity from the Resin Frontier set. Collect them all!"
	icon_state = "cardpack_resin"
	series = "resinfront"
	contains_coin = 0
	rarity_table = list(
		"common" = 900,
		"uncommon" = 300,
		"rare" = 100,
		"epic" = 30,
		"legendary" = 5)

/obj/item/cardpack/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/item_scaling, 0.4, 1)
	rarity_table = SStrading_card_game.get_rarity_table(type, rarity_table)
	guar_rarity = SStrading_card_game.get_guarenteed_rarity_table(type, guar_rarity)

/obj/item/cardpack/attack_self(mob/user)
	. = ..()
	var/list/cards
	if(drop_all_cards)
		cards = SStrading_card_game.cached_cards[series]["ALL"]
	else
		cards = buildCardListWithRarity(card_count, guaranteed_count)

	for(var/template in cards)
		//Makes a new card based of the series of the pack.
		new /obj/item/tcgcard(get_turf(user), series, template)
	to_chat(user, span_notice("Wow! Check out these cards!"))
	new /obj/effect/decal/cleanable/wrapping(get_turf(user))
	playsound(loc, 'sound/items/poster/poster_ripped.ogg', 20, TRUE)
	if(prob(contains_coin))
		to_chat(user, span_notice("...and it came with a flipper, too!"))
		new /obj/item/coin/thunderdome(get_turf(user))
	qdel(src)

/obj/item/coin/thunderdome
	name = "\improper TGC Flipper"
	desc = "A TGC flipper, for deciding who gets to go first. Also conveniently acts as a counter, for various purposes."
	icon = 'icons/obj/toys/tcgmisc.dmi'
	icon_state = "coin_nanotrasen"
	custom_materials = list(/datum/material/plastic = SMALL_MATERIAL_AMOUNT*5)
	material_flags = NONE
	sideslist = list("nanotrasen", "syndicate")
	override_material_worth = TRUE

/obj/item/storage/card_binder
	name = "card binder"
	desc = "The perfect way to keep your collection of cards safe and valuable."
	icon = 'icons/obj/toys/tcgmisc.dmi'
	icon_state = "binder"
	inhand_icon_state = "album"
	lefthand_file = 'icons/mob/inhands/items/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/books_righthand.dmi'
	resistance_flags = FLAMMABLE //burn your enemies' collections, for only you can Collect Them All!
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	storage_type = /datum/storage/card_binder

///Returns a list of cards ids of card_cnt weighted by rarity from the pack's tables that have matching series, with gnt_cnt of the guaranteed table.
/obj/item/cardpack/proc/buildCardListWithRarity(card_cnt, rarity_cnt)
	var/list/toReturn = list()
	//You can always get at least one of some rarity
	toReturn += returnCardsByRarity(rarity_cnt, guar_rarity)
	toReturn += returnCardsByRarity(card_cnt, rarity_table)
	return toReturn

///Returns a list of card datums of the length cardCount that match a random rarity weighted by rarity_table[]
/obj/item/cardpack/proc/returnCardsByRarity(cardCount, list/rarity_table)
	var/list/toReturn = list()
	for(var/card in 1 to cardCount)
		var/rarity = 0
		//Some number between 1 and the sum of all values in the list
		var/weight = 0
		for(var/chance in rarity_table)
			weight += rarity_table[chance]
		var/random = rand(weight)
		for(var/bracket in rarity_table)
			//Steals blatantly from pick_weight(), sorry buddy I need the index
			random -= rarity_table[bracket]
			if(random <= 0)
				rarity = bracket
				break
		//What we're doing here is using the cached the results of the rarity we find.
		//This allows us to only have to run this once per rarity, ever.
		//Unless you reload the cards of course, in which case we have to do this again.
		var/list/cards = SStrading_card_game.cached_cards[series][rarity]
		if(cards.len)
			toReturn += pick(cards)
		else
			//If we still don't find anything yell into the void. Lazy coders.
			log_runtime("The index [rarity] of rarity_table does not exist in the global cache")
	return toReturn

//All of these values should be overridden by either a template or a card itself
/datum/card
	///Unique ID, for use in lookups and (eventually) for persistence. MAKE SURE THIS IS UNIQUE FOR EACH CARD IN AS SERIES, OR THE ENTIRE SYSTEM WILL BREAK, AND I WILL BE VERY DISAPPOINTED.
	var/id = "coder"
	var/name = "Coder"
	var/desc = "Wow, a mint condition coder card! Better tell the GitHub all about this!"
	///This handles any extra rules for the card, i.e. extra attributes, special effects, etc. If you've played any other card game, you know how this works.
	var/rules = "There are no rules here. There is no escape. No Recall or Intervention can work in this place."
	var/icon = DEFAULT_TCG_DMI
	var/icon_state = "template"
	///What it costs to summon this card to the battlefield.
	var/summoncost = -1
	///How hard this card hits (by default)
	var/power = -1
	///How hard this card can get hit (by default)
	var/resolve = -1
	///Someone please come up with a ruleset so I can comment this
	var/faction = "socks"
	///Used to define the behaviour the card uses during the game.
	var/cardtype ="C43a7u43?"
	///An extra descriptor for the card. Combined with the cardtype for a larger card descriptor, i.e. Creature- Xenomorph, Spell- Instant, that sort of thing. For creatures, this has no effect, for spells, this is important.
	var/cardsubtype = "Weeb"
	///Defines the series that the card originates from, this is *very* important for spawning the cards via packs.
	var/series = "hunter2"
	///The rarity of this card, determines how much (or little) it shows up in packs. Rarities are common, uncommon, rare, epic, legendary and misprint.
	var/rarity = "uber rare to the extreme"

	///Icon file that summons are pulled from
	var/summon_icon_file = "icons/obj/toys/tcgmisc.dmi"
	///Icon state for summons to use
	var/summon_icon_state = "template"

/datum/card/New(list/data = list(), list/templates = list())
	applyTemplates(data, templates)
	apply(data)
	applyKeywords(data | templates)

///For each var that the card datum and the json entry share, we set the datum var to the json entry
/datum/card/proc/apply(list/data)
	for(var/name in (data & vars))
		vars[name] = data[name]

///Applies a json file to a card datum
/datum/card/proc/applyTemplates(list/data, list/templates = list())
	apply(templates["default"])
	apply(templates[data["template"]])

///Searches for keywords in the card's variables, marked by wrapping them in {$}
///Adds on hovor logic to them, using the passed in list
///We use the changed_vars list just to make the var searching faster
/datum/card/proc/applyKeywords(list/changed_vars)
	for(var/name in (changed_vars & vars))
		var/value = vars[name]
		if(!istext(value))
			continue
		vars[name] = SStrading_card_game.resolve_keywords(value)

#undef TAPPED_ANGLE
#undef UNTAPPED_ANGLE
