GLOBAL_LIST_INIT(contractor_items, subtypesof(/datum/contractor_hub/item))

/datum/contractor_hub
	var/contract_rep = 0
	var/list/hub_items = list()
	var/list/purchased_items = list()

/datum/contractor_hub/proc/create_hub_items()
	for(var/path in GLOB.contractor_items)
		var/datum/contractor_hub/item/contractor_item = new path

		hub_items.Add(contractor_item)

/datum/contractor_hub/item
	var/name // Name of item
	var/desc // description of item in html
	var/item // item path, no item path means the purchase needs it's own handle_purchase()
	var/icon = "fa-broadcast-tower" // fontawesome icon to use inside the hub - https://fontawesome.com/icons/
	var/limited = -1 // Any number above 0 for how many times it can be bought in a round for a single traitor. -1 is unlimited.
	var/cost // Cost of the item in contract rep.

/datum/contractor_hub/item/contractor_pinpointer
	name = "Contractor Pinpointer"
	desc = "<p>A pinpointer that finds targets even without active suit sensors. Due to taking advantage of an exploit within the system, it can't pinpoint to the same accuracy as the traditional models.</p>"
	item = /obj/item/pinpointer/crew/contractor
	icon = "fa-search-location"
	cost = 1

/datum/contractor_hub/item/contractor_partner
	name = "Reinforcements"
	desc = "<p>Upon purchase we'll contact available units in the area. Should there be an agent free, we'll send them down to assist you. If no units are free, we refund your rep.</p> <p>We're only able to provide this once - should we send the agent to you, this will be unavailable to purchase again.</p>"
	icon = "fa-user-friends"
	limited = 1
	cost = 2

/datum/contractor_hub/item/contractor_pinpointer/handle_purchase()
	. = ..()

	if (.)
		var/obj/item/pinpointer/crew/contractor/pinpointer = .
		var/mob/living/user = usr

		pinpointer.pinpointer_owner = user


/datum/contractor_hub/item/contractor_partner/handle_purchase()
	. = ..()

	if (.)
		to_chat(usr, "We bought it.")

// Subtract cost, and spawn if it's an item.
/datum/contractor_hub/item/proc/handle_purchase()
	if (contract_rep >= cost)
		contract_rep -= cost
	else
		return FALSE

	if (limited > 1)
		limited--
	else if (limited == 0)
		return FALSE

	var/mob/living/user = usr

	if (item && ispath(item))
		var/atom/item_to_create = new item(get_turf(user))
		
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.put_in_hands(item_to_create))
				to_chat(H, "<span class='notice'>Your purchase materializes into your hands!</span>")
			else
				to_chat(user, "<span class='notice'>Your purchase materializes onto the floor.</span>")

		return item_to_create

/obj/item/pinpointer/crew/contractor
	name = "contractor pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. Ignores suit sensors, but is much less accurate."
	icon_state = "pinpointer_syndicate"
	minimum_range = 25
	ignore_suit_sensor_level = TRUE
