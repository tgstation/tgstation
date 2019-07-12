GLOBAL_LIST_INIT(contractor_items, subtypesof(/datum/contractor_item))

/datum/contractor_hub
	var/contract_rep = 10
	var/list/hub_items = list()
	var/list/purchased_items = list()

/datum/contractor_hub/proc/create_hub_items()
	for(var/path in GLOB.contractor_items)
		var/datum/contractor_item/contractor_item = new path

		hub_items.Add(contractor_item)

/datum/contractor_item
	var/name // Name of item
	var/desc // description of item
	var/item // item path, no item path means the purchase needs it's own handle_purchase()
	var/icon = "fa-broadcast-tower" // fontawesome icon to use inside the hub - https://fontawesome.com/icons/
	var/limited = -1 // Any number above 0 for how many times it can be bought in a round for a single traitor. -1 is unlimited.
	var/cost // Cost of the item in contract rep.

/datum/contractor_item/contractor_pinpointer
	name = "Contractor Pinpointer"
	desc = "A pinpointer that finds targets even without active suit sensors. Due to taking advantage of an exploit within the system, it can't pinpoint to the same accuracy as the traditional models."
	item = /obj/item/pinpointer/crew/contractor
	icon = "fa-search-location"
	cost = 1

/datum/contractor_item/contractor_partner
	name = "Reinforcements"
	desc = "Upon purchase we'll contact available units in the area. Should there be an agent free, we'll send them down to assist you immediately. If no units are free, we refund your rep. We're only able to provide this once - should we send the agent to you, this will be unavailable to purchase again."
	icon = "fa-user-friends"
	limited = 1
	cost = 2

/datum/contractor_item/contractor_pinpointer/handle_purchase(var/datum/contractor_hub/hub)
	. = ..()

	to_chat(world, "pinpointer special0")

	if (.)
		to_chat(world, "pinpointer special")
		var/obj/item/pinpointer/crew/contractor/pinpointer = .
		var/mob/living/user = usr

		pinpointer.pinpointer_owner = user


/datum/contractor_item/contractor_partner/handle_purchase(var/datum/contractor_hub/hub)
	. = ..()

	if (.)
		var/mob/living/user = usr

		to_chat(user, "The uplink vibrates quietly, connecting to nearby agents...")

		var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the Contractor Support Unit for [user.real_name]?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_CONTRACTOR_SUPPORT)

		if(LAZYLEN(candidates))
			var/mob/dead/observer/C = pick(candidates)
			spawn_contractor_partner(user, C.key)
		else
			to_chat(user, "No available agents at this time, please try again later.")

			// refund and add the limit back.
			limited += 1
			hub.contract_rep += cost

/datum/contractor_item/contractor_partner/proc/spawn_contractor_partner(mob/living/user, key)
	var/obj/effect/mob_spawn/human/syndicate/contractor_partner = new

	contractor_partner.create(key)

// Subtract cost, and spawn if it's an item.
/datum/contractor_item/proc/handle_purchase(var/datum/contractor_hub/hub)
	to_chat(world, "handling purchase")

	to_chat(world, num2text(cost))
	to_chat(world, num2text(hub.contract_rep))

	if (hub.contract_rep >= cost)
		hub.contract_rep -= cost
	else 
		return FALSE

	to_chat(world, num2text(limited))

	if (limited >= 1)
		limited -= 1
	else if (limited == 0)
		return FALSE

	to_chat(world, num2text(limited))

	to_chat(world, "limit handled")

	var/mob/living/user = usr

	if (item && ispath(item))
		to_chat(world, "if item path")

		var/atom/item_to_create = new item(get_turf(user))
		
		if(user.put_in_hands(item_to_create))
			to_chat(user, "<span class='notice'>Your purchase materializes into your hands!</span>")
		else
			to_chat(user, "<span class='notice'>Your purchase materializes onto the floor.</span>")

		return item_to_create
	return TRUE

/obj/item/pinpointer/crew/contractor
	name = "contractor pinpointer"
	desc = "A handheld tracking device that locks onto certain signals. Ignores suit sensors, but is much less accurate."
	icon_state = "pinpointer_syndicate"
	minimum_range = 25
	ignore_suit_sensor_level = TRUE
