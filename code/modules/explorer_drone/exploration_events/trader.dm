/// Trader events - If drone is loaded with X exchanges it for Y, might require translator tool.
/datum/exploration_event/simple/trader
	root_abstract_type = /datum/exploration_event/simple/trader
	action_text = "Trade"
	/// Obj path we'll take or list of paths ,one path will be picked from it at init
	var/required_path
	/// Obj path we'll give out or list of paths ,one path will be picked from it at init
	var/traded_path
	//How many times we'll allow the trade
	var/amount = 1
	var/requires_translator = TRUE

/datum/exploration_event/simple/trader/New()
	. = ..()
	if(islist(required_path))
		required_path = pick(required_path)
	if(islist(traded_path))
		traded_path = pick(traded_path)

/datum/exploration_event/simple/trader/get_discovery_message(obj/item/exodrone/drone)
	if(requires_translator && !drone.has_tool(EXODRONE_TOOL_TRANSLATOR))
		return "You encountered [name] but could not understand what they want without a translator."
	var/obj/want = required_path
	var/obj/gives = traded_path
	return "Encountered [name] willing to trade [initial(gives.name)] for [initial(want.name)]"

/datum/exploration_event/simple/trader/get_description(obj/item/exodrone/drone)
	if(requires_translator && !drone.has_tool(EXODRONE_TOOL_TRANSLATOR))
		return "You encounter [name] but cannot understand what they want without a translator."
	var/obj/want = required_path
	var/obj/gives = traded_path
	return "You encounter [name] willing to trade [initial(want.name)] for [initial(gives.name)] [amount > 1 ? "[amount] times":""]."

/datum/exploration_event/simple/trader/is_targetable()
	return visited && (amount > 0)

/datum/exploration_event/simple/trader/action_enabled(obj/item/exodrone/drone)
	var/obj/trade_good = locate(required_path) in drone.contents
	return (amount > 0) && trade_good && (!requires_translator || drone.has_tool(EXODRONE_TOOL_TRANSLATOR))

/datum/exploration_event/simple/trader/fire(obj/item/exodrone/drone)
	if(!action_enabled(drone))
		end(drone)
		return
	amount--
	trade(drone)
	end(drone)

/datum/exploration_event/simple/trader/proc/trade(obj/item/exodrone/drone)
	var/obj/trade_good = locate(required_path) in drone.contents
	var/obj/loot = new traded_path()
	drone.drone_log("Traded [trade_good] for [loot].")
	qdel(trade_good)
	drone.try_transfer(loot)


/// Trade events

/datum/exploration_event/simple/trader/vendor_ai
	name = "sentient drug vending machine"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY)
	band_values = list(EXOSCANNER_BAND_TECH=2)
	requires_translator = FALSE
	required_path = /obj/item/stock_parts/power_store/cell/high
	traded_path = /obj/item/storage/pill_bottle/happy
	amount = 3

/datum/exploration_event/simple/trader/farmer_market
	name = "farmer's market"
	deep_scan_description = "You detect an area with an unusually high concentration of edibles on site."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_LIFE=2)
	required_path = /obj/item/stock_parts/servo/nano
	traded_path = list(/obj/item/seeds/tomato/killer,/obj/item/seeds/orange_3d,/obj/item/seeds/firelemon,/obj/item/seeds/gatfruit)
	amount = 1

/datum/exploration_event/simple/trader/fish
	name = "interstellar fish trader"
	requires_translator = FALSE
	deep_scan_description = "You spot a giant \"FRESH FISH\" sign on site."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_LIFE=2)
	required_path = /obj/item/stock_parts/power_store/cell/high
	traded_path = /obj/item/storage/fish_case/random
	amount = 3

/datum/exploration_event/simple/trader/shady_merchant
	name = "shady merchant"
	requires_translator = FALSE
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_path = list(/obj/item/organ/internal/heart,/obj/item/organ/internal/liver,/obj/item/organ/internal/stomach,/obj/item/organ/internal/eyes)
	traded_path = list(/obj/item/implanter/explosive)
	amount = 1

/datum/exploration_event/simple/trader/surplus
	name = "military surplus trader"
	deep_scan_description = "You decrypt a transmission advertising military surplus for sale on site."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_path = list(/obj/item/clothing/suit/armor,/obj/item/clothing/shoes/jackboots)
	traded_path = /obj/item/gun/energy/laser/retro/old
	amount = 3

/datum/exploration_event/simple/trader/flame_card
	name = "id card artisan"
	deep_scan_description = "You spy an advertisment for an ID card customisation workshop."
	required_site_traits = list(EXPLORATION_SITE_HABITABLE,EXPLORATION_SITE_CIVILIZED)
	band_values = list(EXOSCANNER_BAND_TECH=1)
	required_path = list(/obj/item/card/id) //If you trade a better card for worse that's on you
	traded_path = null
	requires_translator = FALSE
	amount = 1
	var/static/list/possible_card_states = list("card_flames","card_carp","card_rainbow")

/datum/exploration_event/simple/trader/flame_card/get_discovery_message(obj/item/exodrone/drone)
	return "Encountered [name] willing to customise any ID card you bring them."

/datum/exploration_event/simple/trader/flame_card/get_description(obj/item/exodrone/drone)
	return "You encounter a local craftsman willing to customise an ID card for you, free of charge."

/datum/exploration_event/simple/trader/flame_card/trade(obj/item/exodrone/drone)
	var/obj/item/card/id/card = locate(required_path) in drone.contents
	card.icon_state = pick(possible_card_states)
	card.update_icon() //Refresh cached helper image
	drone.drone_log("Let artisan work on [card.name].")
