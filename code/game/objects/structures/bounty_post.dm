#define BOUNTY_COOLDOWN 10 MINUTES

GLOBAL_LIST_EMPTY(holy_contracts)
GLOBAL_LIST_EMPTY(contract_points)
GLOBAL_LIST_EMPTY(assigned_bounties)
GLOBAL_LIST_EMPTY(bounty_points_tracker)

GLOBAL_LIST_INIT(possible_monsters, list(
	/mob/living/basic/mining/ice_whelp,
	/mob/living/basic/mining/ice_demon,
	/mob/living/basic/mining/lobstrosity,
))

/datum/holy_bounty
	///name of the bounty
	var/bounty_name = "bounty"
	///details of the contract
	var/bounty_description = "some bounty"
	///associated icon
	var/icon/bounty_icon
	///the gps location of our bounty
	var/gps_location
	///type to create
	var/bounty_typepath
	///reward we get from bounty
	var/reward_points
	///who we have assigned this contract to
	var/datum/weakref/assignee

/datum/holy_bounty/New()
	. = ..()
	GLOB.holy_contracts += src

/datum/holy_bounty/proc/assign_bounty(mob/living/user)
	var/wait_period = GLOB.assigned_bounties[REF(user)]
	if(wait_period && world.time < wait_period)
		return

	var/atom/bounty_target = create_bounty()
	if(isnull(bounty_target))
		return
	var/image/bounty_image = image(icon = bounty_target.icon, icon_state = bounty_target.icon_state)
	bounty_image.color = "#642600"
	bounty_icon = getFlatIcon(bounty_image)
	register_bounty_signals(bounty_target)
	GLOB.assigned_bounties[REF(user)] = world.time + BOUNTY_COOLDOWN
	assignee = WEAKREF(user)

/datum/holy_bounty/proc/register_bounty_signals(atom/bounty_target)
	return

/datum/holy_bounty/proc/claim_bounty()
	var/mob/living/hunter = assignee?.resolve()
	if(isnull(hunter))
		return
	GLOB.bounty_points_tracker[REF(hunter)] += reward_points

/datum/holy_bounty/proc/create_bounty()
	var/list/possible_turfs = get_area_turfs(/area/icemoon/underground/unexplored/rivers/deep)
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
	post_create_bounty(created_bounty)
	return created_bounty

/datum/holy_bounty/proc/post_create_bounty()
	return

/datum/holy_bounty/Destroy()
	. = ..()
	GLOB.holy_contracts -= src
	assignee = null

/datum/holy_bounty/eliminate_monster
	bounty_name = "Eliminate Monster"
	reward_points = 500

/datum/holy_bounty/eliminate_monster/New()
	. = ..()
	var/mob/living/picked_path = pick(GLOB.possible_monsters)
	bounty_typepath = picked_path
	bounty_name = "[picked_path::name]"

/datum/holy_bounty/seal_portal
	bounty_name = "Seal Portal"
	reward_points = 600

/////bounty contract
/obj/item/bounty_contract
	name = "bounty contract"
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "bounty_paper"
	item_flags = NOBLUDGEON
	var/datum/holy_bounty/eliminate_monster/our_bounty

/obj/item/bounty_contract/Initialize(mapload)
	. = ..()
	our_bounty = new()

/obj/item/bounty_contract/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "bountypaper")
		ui.open()

/obj/item/bounty_contract/attack_self(mob/user)
	. = ..()
	if(.)
		return TRUE
	our_bounty.assign_bounty(user)
	return TRUE

/obj/item/bounty_contract/ui_static_data(mob/user)
	var/list/data = list()
	data["bounty_name"] = our_bounty.bounty_name
	data["bounty_icon"] = icon2base64(our_bounty.bounty_icon)
	data["bounty_reward"] = our_bounty.reward_points
	data["bounty_gps"] = our_bounty.gps_location
	return data
