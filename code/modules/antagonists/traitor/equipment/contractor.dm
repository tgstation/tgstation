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

		to_chat(user, "<span class='notice'>The uplink vibrates quietly, connecting to nearby agents...</span>")

		var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the Contractor Support Unit for [user.real_name]?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_CONTRACTOR_SUPPORT)

		if(LAZYLEN(candidates))
			var/mob/dead/observer/C = pick(candidates)
			spawn_contractor_partner(user, C.key)
		else
			to_chat(user, "<span class='notice'>No available agents at this time, please try again later.</span>")

			// refund and add the limit back.
			limited += 1
			hub.contract_rep += cost

/datum/outfit/contractor_partner
	name = "Contractor Support Unit"
	
	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	back = /obj/item/storage/backpack
	belt = /obj/item/pda/chameleon
	mask = /obj/item/clothing/mask/cigarette/syndicate
	shoes = /obj/item/clothing/shoes/chameleon/noslip
	ears = /obj/item/radio/headset/chameleon
	id = /obj/item/card/id/syndicate
	r_hand = /obj/item/storage/toolbox/syndicate

	backpack_contents = list(/obj/item/storage/box/survival, /obj/item/implanter/uplink, /obj/item/clothing/mask/chameleon, 
							/obj/item/storage/fancy/cigarettes/cigpack_syndicate, /obj/item/lighter)

/datum/contractor_item/contractor_partner/proc/spawn_contractor_partner(mob/living/user, key)
	var/mob/living/carbon/human/partner = new()
	var/datum/outfit/contractor_partner/partner_outfit = new()

	partner_outfit.equip(partner)

	var/obj/structure/closet/supplypod/arrival_pod = new()

	arrival_pod.style = STYLE_SYNDICATE
	arrival_pod.explosionSize = list(0,0,0,1)

	var/turf/free_location = find_obstruction_free_location(3, user)

	// We really want to send them - if we can't find a nice location just land it on top of them.
	if (!free_location)
		free_location = get_turf(user)

	partner.forceMove(arrival_pod)
	partner.ckey = key

	// flavour text
	to_chat(partner, "<span class='big bold'>You are the Syndicate agent that answered the requested for backup.</span><span class='big'> <span class='danger'><b>Your mission is to support the specialist agent, [user.real_name], anyway possible - you must stay with them, and follow any orders they give.</b></span><br>\
	<br>\
	<span class='danger'><b>Work as a team with your assigned agent, their mission comes first above all else.</b></span></span>")
	partner.playsound_local(partner, 'sound/ambience/antag/tatoralert.ogg', 100)

	new /obj/effect/DPtarget(free_location, arrival_pod)

// Subtract cost, and spawn if it's an item.
/datum/contractor_item/proc/handle_purchase(var/datum/contractor_hub/hub)
	if (hub.contract_rep >= cost)
		hub.contract_rep -= cost
	else 
		return FALSE

	if (limited >= 1)
		limited -= 1
	else if (limited == 0)
		return FALSE

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
