#define HUNTER_SCAN_MIN_DISTANCE 8
#define HUNTER_SCAN_MAX_DISTANCE 15
/// 5s update time
#define HUNTER_SCAN_PING_TIME 20

/datum/antagonist/monsterhunter
	name = "\improper Monster Hunter"
	roundend_category = "Monster Hunters"
	antagpanel_category = "Monster Hunter"
	job_rank = ROLE_MONSTERHUNTER
	antag_hud_name = "obsessed"
	preview_outfit = /datum/outfit/monsterhunter
	var/list/datum/action/powers = list()
	var/give_objectives = TRUE
	///how many rabbits have we found
	var/rabbits_spotted = 0
	///the list of white rabbits
	var/list/obj/effect/client_image_holder/white_rabbit/rabbits = list()
	///the red card tied to this trauma if any
	var/obj/item/rabbit_locator/locator

/datum/antagonist/monsterhunter/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	ADD_TRAIT(current_mob, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	ADD_TRAIT(current_mob, TRAIT_NOCRITDAMAGE, BLOODSUCKER_TRAIT)
	owner.unconvertable = TRUE

/datum/antagonist/monsterhunter/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current
	REMOVE_TRAIT(current_mob, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(current_mob, TRAIT_NOCRITDAMAGE, BLOODSUCKER_TRAIT)
	owner.unconvertable = FALSE

/datum/antagonist/monsterhunter/on_gain()
	//Give Hunter Objective
	if(give_objectives)
		find_monster_targets()
	var/datum/map_template/wonderland/wonder = new()
	if(!wonder.load_new_z())
		message_admins("The wonderland failed to load.")
		CRASH("Failed to initialize wonderland!")

	//Teach Stake crafting
	owner.teach_crafting_recipe(/datum/crafting_recipe/hardened_stake)
	owner.teach_crafting_recipe(/datum/crafting_recipe/silver_stake)
	var/mob/living/carbon/criminal = owner.current
	var/obj/item/rabbit_locator/card = new(get_turf(criminal), src)
	var/list/slots = list ("backpack" = ITEM_SLOT_BACKPACK, "left pocket" = ITEM_SLOT_LPOCKET, "right pocket" = ITEM_SLOT_RPOCKET)
	criminal.equip_in_one_of_slots(card, slots, qdel_on_fail = FALSE)
	var/obj/item/hunting_contract/contract = new(get_turf(criminal), src)
	criminal.equip_in_one_of_slots(contract, slots, qdel_on_fail = FALSE)
	RegisterSignal(src, COMSIG_GAIN_INSIGHT, .proc/insight_gained)
	RegisterSignal(src, COMSIG_BEASTIFY, .proc/turn_beast)
	for(var/i in 1 to 5 )
		var/turf/rabbit_hole = get_safe_random_station_turf()
		var/obj/effect/client_image_holder/white_rabbit/cretin =  new(rabbit_hole, owner.current)
		cretin.hunter = src
		rabbits += cretin
	var/obj/effect/client_image_holder/white_rabbit/mask_holder = pick(rabbits)
	var/obj/effect/client_image_holder/white_rabbit/gun_holder = pick(rabbits)
	mask_holder.drop_mask = TRUE
	gun_holder.drop_gun = TRUE

	return ..()



/datum/antagonist/monsterhunter/on_removal()
	UnregisterSignal(src, COMSIG_GAIN_INSIGHT)
	UnregisterSignal(src, COMSIG_BEASTIFY)
	for(var/obj/effect/client_image_holder/white_rabbit/white as anything in rabbits)
		rabbits -= white
		qdel(white)
	if(locator)
		locator.hunter = null
	locator = null
	to_chat(owner.current, span_userdanger("Your hunt has ended: You enter retirement once again, and are no longer a Monster Hunter."))
	return ..()


/datum/antagonist/monsterhunter/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)

/datum/antagonist/monsterhunter/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/hunter = new
	var/icon/white_rabbit = icon('massmeta/icons/monster_hunter/rabbit.dmi', "white_rabbit")
	var/icon/red_rabbit = icon('massmeta/icons/monster_hunter/rabbit.dmi', "killer_rabbit")
	var/icon/hunter_icon = render_preview_outfit(/datum/outfit/monsterhunter, hunter)

	var/icon/final_icon = hunter_icon
	white_rabbit.Shift(EAST,8)
	white_rabbit.Shift(NORTH,18)
	red_rabbit.Shift(WEST,8)
	red_rabbit.Shift(NORTH,18)
	red_rabbit.Blend(rgb(165, 165, 165, 165), ICON_MULTIPLY)
	white_rabbit.Blend(rgb(165, 165, 165, 165), ICON_MULTIPLY)
	final_icon.Blend(white_rabbit, ICON_UNDERLAY)
	final_icon.Blend(red_rabbit, ICON_UNDERLAY)

	final_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	qdel(hunter)

	return finish_preview_icon(final_icon)

/datum/outfit/monsterhunter
	name = "Monster Hunter (Preview Only)"

	l_hand = /obj/item/knife/butcher
	mask = /obj/item/clothing/mask/monster_preview_mask
	uniform = /obj/item/clothing/under/suit/black
	suit =  /obj/item/clothing/suit/hooded/techpriest
	gloves = /obj/item/clothing/gloves/color/white

/// Mind version
/datum/mind/proc/make_monsterhunter()
	var/datum/antagonist/monsterhunter/monsterhunterdatum = has_antag_datum(/datum/antagonist/monsterhunter)
	if(!monsterhunterdatum)
		monsterhunterdatum = add_antag_datum(/datum/antagonist/monsterhunter)
		special_role = ROLE_MONSTERHUNTER
	return monsterhunterdatum

/datum/mind/proc/remove_monsterhunter()
	var/datum/antagonist/monsterhunter/monsterhunterdatum = has_antag_datum(/datum/antagonist/monsterhunter)
	if(monsterhunterdatum)
		remove_antag_datum(/datum/antagonist/monsterhunter)
		special_role = null

/// Called when using admin tools to give antag status
/datum/antagonist/monsterhunter/admin_add(datum/mind/new_owner, mob/admin)
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	new_owner.add_antag_datum(src)

/// Called when removing antagonist using admin tools
/datum/antagonist/monsterhunter/admin_remove(mob/user)
	if(!user)
		return
	message_admins("[key_name_admin(user)] has removed [name] antagonist status from [key_name_admin(owner)].")
	log_admin("[key_name(user)] has removed [name] antagonist status from [key_name(owner)].")
	on_removal()

/datum/antagonist/monsterhunter/proc/add_objective(datum/objective/added_objective)
	objectives += added_objective

/datum/antagonist/monsterhunter/proc/remove_objectives(datum/objective/removed_objective)
	objectives -= removed_objective

/datum/antagonist/monsterhunter/greet()
	. = ..()
	to_chat(owner.current, span_userdanger("After witnessing recent events on the station, we return to your old profession, we are a Monster Hunter!"))
	to_chat(owner.current, span_announce("While we can kill anyone in our way to destroy the monsters lurking around, <b>causing property damage is unacceptable</b>."))
	to_chat(owner.current, span_announce("However, security WILL detain us if they discover our mission."))
	to_chat(owner.current, span_announce("In exchange for our services, it shouldn't matter if a few items are gone missing for our... personal collection."))
	owner.current.playsound_local(null, 'massmeta/sounds/monster_hunter/monsterhunterintro.ogg', 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

//////////////////////////////////////////////////////////////////////////
//			Monster Hunter Pinpointer
//////////////////////////////////////////////////////////////////////////

/// TAKEN FROM: /datum/action/changeling/pheromone_receptors    // pheromone_receptors.dm    for a version of tracking that Changelings have!
/datum/status_effect/agent_pinpointer/hunter_edition
	alert_type = /atom/movable/screen/alert/status_effect/agent_pinpointer/hunter_edition
	minimum_range = HUNTER_SCAN_MIN_DISTANCE
	tick_interval = HUNTER_SCAN_PING_TIME
	duration = 10 SECONDS
	range_fuzz_factor = 5 //PINPOINTER_EXTRA_RANDOM_RANGE

/atom/movable/screen/alert/status_effect/agent_pinpointer/hunter_edition
	name = "Monster Tracking"
	desc = "You always know where the hellspawn are."

/datum/status_effect/agent_pinpointer/hunter_edition/scan_for_target()
	var/turf/my_loc = get_turf(owner)

	var/list/mob/living/carbon/monsters = list()
	for(var/datum/antagonist/monster in GLOB.antagonists)
		var/datum/mind/brain = monster.owner
		if(brain == owner || !brain)
			continue
		if(IS_HERETIC(brain.current) || IS_BLOODSUCKER(brain.current) || IS_CULTIST(brain.current) || IS_WIZARD(brain.current))
			monsters += brain
		if(brain.has_antag_datum(/datum/antagonist/changeling))
			monsters += brain
		if(brain.has_antag_datum(/datum/antagonist/ashwalker))
			monsters += brain

	if(monsters.len)
		/// Point at a 'random' monster, biasing heavily towards closer ones.
		scan_target = pick_weight(monsters)
		to_chat(owner, span_warning("You detect signs of monsters to the <b>[dir2text(get_dir(my_loc,get_turf(scan_target)))]!</b>"))
	else
		scan_target = null

/datum/status_effect/agent_pinpointer/hunter_edition/Destroy()
	if(scan_target)
		to_chat(owner, span_notice("You've lost the trail."))
	. = ..()


/datum/antagonist/monsterhunter/proc/insight_gained()
	SIGNAL_HANDLER

	var/description
	var/datum/objective/assassinate/obj
	if(objectives.len)
		obj = pick(objectives)
	if(obj)
		var/datum/antagonist/heretic/heretic_target = IS_HERETIC(obj.target.current)
		if(heretic_target)
			description = "your target [heretic_target.owner.current.real_name] follows the [heretic_target.heretic_path], dear hunter."

		else
			description = "O' hunter, your target [obj.target.current.real_name] bears these lethal abilities:  "
			for(var/datum/action/ability in obj.target.current.actions)
				if(!ability)
					continue
				if(!istype(ability, /datum/action/changeling) && !istype(ability, /datum/action/bloodsucker))
					continue
				description += "[ability.name], "

	rabbits_spotted++
	to_chat(owner.current,span_notice("[description]"))

/datum/antagonist/monsterhunter/proc/find_monster_targets()
	var/list/possible_targets = list()
	for(var/datum/antagonist/victim in GLOB.antagonists)
		if(!victim.owner)
			continue
		if(!victim.owner.current)
			continue
		if(victim.owner.current.stat == DEAD || victim.owner == owner)
			continue
		if(istype(victim, /datum/antagonist/changeling) || istype(victim, /datum/antagonist/heretic) || istype(victim, /datum/antagonist/bloodsucker))
			possible_targets += victim.owner
	for(var/i in 1 to 3) //we get 3 targets
		if(!(possible_targets.len))
			break
		var/datum/objective/assassinate/kill_monster = new
		kill_monster.owner = owner
		var/datum/mind/target = pick(possible_targets)
		possible_targets -= target
		kill_monster.target = target
		kill_monster.update_explanation_text()
		objectives += kill_monster


/datum/antagonist/monsterhunter/proc/turn_beast()
	SIGNAL_HANDLER

	var/datum/round_event_control/wonderlandapocalypse/invasion = new
	invasion.runEvent()



/obj/item/clothing/mask/monster_preview_mask
	name = "Monster Preview Mask"
	worn_icon = 'massmeta/icons/monster_hunter/worn_mask.dmi'
	worn_icon_state = "monoclerabbit"
