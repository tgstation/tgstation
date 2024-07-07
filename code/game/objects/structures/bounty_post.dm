#define BOUNTY_COOLDOWN 10 MINUTES
#define BOUNTY_MARKER "bounty marker"
#define EASY_BOUNTY_MULTIPLIER 1.25
#define MEDIUM_BOUNTY_MULTIPLIER 1.5
#define HARD_BOUNTY_MULTIPLIER 2

GLOBAL_LIST_EMPTY(holy_contracts)
GLOBAL_LIST_EMPTY(contract_points)
GLOBAL_LIST_EMPTY(assigned_bounties)
GLOBAL_LIST_EMPTY(bounty_points_tracker)

GLOBAL_LIST_INIT(possible_monsters, list(
	/mob/living/basic/mining/ice_whelp,
	/mob/living/basic/mining/ice_demon,
	/mob/living/basic/mining/lobstrosity,
))
////items we can buy
/datum/bounty_store_item
	///typepath of our item
	var/obj/item/item_path
	///price of our item
	var/item_price

/datum/bounty_store_item/legion_core
	item_path = /obj/item/organ/internal/monster_core/regenerative_core/legion
	item_price = 100

/datum/bounty_store_item/plasma_flame
	item_path = /obj/item/crusher_trophy/plasma_flame
	item_price = 1500

/datum/bounty_store_item/kinetic_cosmetic
	item_path = /obj/item/borg/upgrade/modkit/crystal
	item_price = 500

/datum/bounty_store_item/godslayer_blade
	item_path = /obj/item/divine_blade
	item_price = 10000

/datum/holy_bounty
	///name of the bounty
	var/bounty_name = "Eliminate Monster"
	///details of the contract
	var/bounty_description = "some bounty"
	///associated icon
	var/icon/bounty_icon
	///the gps location of our bounty
	var/gps_location
	///type to create
	var/bounty_typepath
	///reward we get from bounty
	var/reward_points = 500
	///who we have assigned this contract to
	var/datum/weakref/assignee
	///possible difficulty settings and their reward prices
	var/static/list/difficulty_settings = list(
		"easy" = list("multiplier" = EASY_BOUNTY_MULTIPLIER, "price" = 400),
		"medium" = list("multiplier" = MEDIUM_BOUNTY_MULTIPLIER, "price" = 600),
		"hard" = list("multiplier" = HARD_BOUNTY_MULTIPLIER, "price" = 800),
	)
	///difficulty of our bounty
	var/bounty_difficulty_multiplier

/datum/holy_bounty/New()
	. = ..()
	GLOB.holy_contracts += src
	var/mob/living/picked_path = pick(GLOB.possible_monsters)
	bounty_typepath = picked_path
	bounty_name = "[picked_path::name]"
	var/image/bounty_image = image(icon = picked_path::icon, icon_state = picked_path::icon_state)
	bounty_image.color = "#642600"
	bounty_icon = getFlatIcon(bounty_image)
	var/picked_difficulty = pick(difficulty_settings)
	bounty_difficulty_multiplier = difficulty_settings[picked_difficulty]["multiplier"]
	reward_points = difficulty_settings[picked_difficulty]["price"]

/datum/holy_bounty/proc/assign_bounty(mob/living/user)
	var/wait_period = GLOB.assigned_bounties[REF(user)]
	if(wait_period && world.time < wait_period)
		to_chat(user, span_warning("You cannot accept a bounty just yet!"))
		return FALSE

	var/atom/bounty_target = create_bounty()
	if(isnull(bounty_target))
		return FALSE
	register_bounty_signals(bounty_target)
	GLOB.assigned_bounties[REF(user)] = world.time + BOUNTY_COOLDOWN
	assignee = WEAKREF(user)
	assign_difficulty(bounty_target)
	bounty_target.add_filter(BOUNTY_MARKER, 2, list("type" = "outline", "color" = COLOR_MEDIUM_DARK_RED, "alpha" = 0, "size" = 1))
	var/filter = bounty_target.get_filter(BOUNTY_MARKER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)
	return TRUE

/datum/holy_bounty/proc/assign_difficulty(mob/living/basic/bounty_target)
	bounty_target.maxHealth *= bounty_difficulty_multiplier
	bounty_target.heal_overall_damage(bounty_target.maxHealth)
	bounty_target.melee_damage_lower *= bounty_difficulty_multiplier
	bounty_target.melee_damage_upper *= bounty_difficulty_multiplier

/datum/holy_bounty/proc/register_bounty_signals(atom/bounty_target)
	RegisterSignals(bounty_target, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(claim_bounty))

/datum/holy_bounty/proc/claim_bounty()
	SIGNAL_HANDLER

	var/mob/living/hunter = assignee?.resolve()
	if(isnull(hunter))
		return
	GLOB.bounty_points_tracker[REF(hunter)] += reward_points
	GLOB.assigned_bounties -= REF(hunter)
	SEND_SIGNAL(SSdcs, COMSIG_BOUNTY_COMPLETE)
	qdel(src)

/datum/holy_bounty/proc/create_bounty()
	var/list/possible_turfs = get_area_turfs(/area/icemoon/underground/unexplored/rivers)
	var/turf/chosen_turf
	shuffle_inplace(possible_turfs)

	for(var/turf/possible_turf as anything in possible_turfs)
		if(!possible_turf.is_blocked_turf() && !isgroundlessturf(possible_turf))
			chosen_turf = possible_turf
			break

	if(isnull(chosen_turf))
		return null

	var/atom/created_bounty = new bounty_typepath(chosen_turf)
	gps_location = "Bounty [rand(1,1000)]"
	created_bounty.AddComponent(/datum/component/gps, gps_location)
	return created_bounty

/datum/holy_bounty/Destroy()
	. = ..()
	GLOB.holy_contracts -= src
	assignee = null

/////bounty contract
/obj/item/bounty_contract
	name = "bounty contract"
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "bounty_paper"
	item_flags = NOBLUDGEON
	///our bounty
	var/datum/holy_bounty/our_bounty

/obj/item/bounty_contract/proc/set_bounty(datum/bounty)
	our_bounty = bounty
	RegisterSignal(our_bounty, COMSIG_QDELETING, PROC_REF(solve_contract))

/obj/item/bounty_contract/ui_interact(mob/user, datum/tgui/ui)
	if(isnull(our_bounty))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "bountypaper")
		ui.open()

/obj/item/bounty_contract/ui_static_data(mob/user)
	var/list/data = list()
	data["bounty_name"] = our_bounty.bounty_name
	data["bounty_icon"] = icon2base64(our_bounty.bounty_icon)
	data["bounty_reward"] = our_bounty.reward_points
	data["bounty_gps"] = our_bounty.gps_location
	return data

/obj/item/bounty_contract/proc/solve_contract(datum/source)
	SIGNAL_HANDLER
	our_bounty = null

////our bounty billboard
/obj/structure/bounty_post
	name = "Bounty billboard"
	desc = "An honest man's work!"
	icon = 'icons/obj/structures.dmi'
	icon_state = "bounty_post"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	///maximum amount of bounties we can hold
	var/bounty_amount = 8

/obj/structure/bounty_post/Initialize(mapload)
	. = ..()
	setup_bounties()

/obj/structure/bounty_post/proc/setup_bounties()
	var/bounties_to_set = bounty_amount - length(GLOB.holy_contracts)
	for(var/count in 1 to bounties_to_set)
		new /datum/holy_bounty
	addtimer(CALLBACK(src, PROC_REF(setup_bounties)), 10 MINUTES) //every 10 minutes, regenerate bounties

/obj/structure/bounty_post/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "bountypost")
		ui.open()

/obj/structure/bounty_post/ui_data(mob/user)
	var/list/data = list()
	data["bounty"] = list()
	for(var/datum/holy_bounty/our_bounty as anything in GLOB.holy_contracts)
		if(!isnull(our_bounty.assignee?.resolve()))
			continue //dont display bounties that are already claimed
		data["bounty"] += list(list(
			"bounty_id" = REF(our_bounty),
			"bounty_name" = our_bounty.bounty_name,
			"bounty_icon" = icon2base64(our_bounty.bounty_icon),
			"bounty_reward" = our_bounty.reward_points,
		))
	data["user_points"] = GLOB.bounty_points_tracker[REF(user)] || 0
	return data

/obj/structure/bounty_post/ui_static_data(mob/user)
	var/list/data = list()
	data["shop_item"] = list()
	for(var/datum/bounty_store_item/shop_item as anything in subtypesof(/datum/bounty_store_item))
		var/obj/item/item_path = shop_item::item_path
		data["shop_item"] += list(list(
			"item_ref" = shop_item::type,
			"item_name" = item_path::name,
			"item_price" = shop_item::item_price,
			"item_icon" = icon2base64(getFlatIcon(image(icon = item_path::icon, icon_state = item_path::icon_state), no_anim=TRUE)),
			"item_description" = item_path::desc,
		))
	data["coins_icon"] = icon2base64(icon('icons/obj/mining.dmi', "shop_coins"))
	return data

/obj/structure/bounty_post/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !isliving(ui.user))
		return TRUE
	var/mob/living/user = ui.user
	switch(action)
		if("claim")
			var/datum/holy_bounty/selected_bounty
			if(isnull(params["reference"]))
				return TRUE
			for(var/datum/holy_bounty/bounty as anything in GLOB.holy_contracts)
				if(params["reference"] != REF(bounty))
					continue
				selected_bounty = bounty
				break
			if(isnull(selected_bounty))
				return TRUE
			if(selected_bounty.assignee?.resolve())
				to_chat(user, span_warning("This bounty has already been assigned to someone!"))
				return TRUE
			if(!selected_bounty.assign_bounty(user))
				return TRUE
			var/obj/item/bounty_contract/contract = new()
			contract.set_bounty(selected_bounty)
			user.put_in_hands(contract)
			return TRUE
		if("purchase")
			var/datum/bounty_store_item/reward_path = text2path(params["reference"])
			if(isnull(reward_path))
				return TRUE
			if(!(reward_path in subtypesof(/datum/bounty_store_item)))
				return TRUE
			if(reward_path::item_price > GLOB.bounty_points_tracker[REF(user)])
				to_chat(user, span_warning("Not enough funds!"))
				return TRUE
			var/item_path =  reward_path::item_path
			var/obj/item/reward_item = new item_path()
			GLOB.bounty_points_tracker[REF(user)] = max(GLOB.bounty_points_tracker[REF(user)] - reward_path::item_price, 0)
			user.put_in_hands(reward_item)
