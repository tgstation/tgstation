/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl
	name = "hole in the ground"
	desc = "A clearly hand dug hole in the ground that appears to lead into a small cave of some kind? It's pretty dark in there."
	prompt_name = "icemoon dweller"
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "hole"
	mob_species = /datum/species/human/felinid/primitive
	outfit = /datum/outfit/primitive_catgirl
	density = FALSE
	you_are_text = "You are an icemoon dweller."
	flavour_text = "For as long as you can remember, the icemoon has been your home. \
		It's been the home of your ancestors, and their ancestors, and the ones before them. \
		Currently, you and your kin live in uneasy tension with your nearby human-and-otherwise \
		neighbors. Keep your village and your Kin safe, but bringing death on their heads from \
		being reckless with the outsiders will not have the Gods be so kind."
	spawner_job_path = /datum/job/primitive_catgirl
	interaction_flags_mouse_drop = NEED_DEXTERITY

	/// The team the spawner will assign players to and use to keep track of people that have already used the spawner
	var/datum/team/primitive_catgirls/team

	restricted_species = list(/datum/species/human/felinid/primitive)
	quirks_enabled = TRUE
	random_appearance = FALSE
	loadout_enabled = FALSE
	infinite_use = TRUE
	deletes_on_zero_uses_left = FALSE

	/// The list of real names of those that have gone back into the hole.
	/// Should get modified automatically by `create()` and `put_back_in()`.
	var/list/went_back_to_sleep = list()
	/// The cached string to display for additional info on who joined and who left.
	/// Nulled every time someone joins or leaves to ensure it gets re-generated.
	var/join_and_leave_log_cache = null
	/// The minimum time someone needs to be SSD before they can be put back in. Shares config "cryo_min_ssd_time" with cryopod
	var/ssd_time = 15 MINUTES
/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/Initialize(mapload)
	. = ..()
	team = new /datum/team/primitive_catgirls()
	ssd_time = CONFIG_GET(number/cryo_min_ssd_time)

/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/Destroy()
	team = null
	return ..()

/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/examine(mob/user)
	. = ..()

	if(isprimitivedemihuman(user) || isobserver(user))
		. += span_notice("<i>You could examine it more thoroughly...</i>")

	return .


/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/examine_more(mob/user)
	. = ..()

	if(!isprimitivedemihuman(user) && !isobserver(user))
		return

	. += get_joined_and_left_log()


/**
 * Returns the `join_and_leave_log_cache` string if it already exists, otherwise
 * generates and returns it.
 */
/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/proc/get_joined_and_left_log()
	if(join_and_leave_log_cache)
		return join_and_leave_log_cache

	var/list/joined_player_names = list()

	for(var/datum/mind/joined_mind in team.members)
		joined_player_names += joined_mind.name

	if(!length(joined_player_names) && !length(went_back_to_sleep))
		join_and_leave_log_cache = span_notice("Everyone still seems to be sleeping peacefully in the hole.")
		return join_and_leave_log_cache

	var/nobody_joined = !length(joined_player_names)
	var/nobody_returned = !length(went_back_to_sleep)
	var/should_add_newline = !nobody_returned && !nobody_joined // if we have both missing kin and kin who went back to sleep, add a newline

	join_and_leave_log_cache = span_notice( \
		"[nobody_joined ? "" : "You smell that the following kin are missing from the hole:\n\
		<b>[joined_player_names.Join("</b>, <b>")]</b>"]\
		[should_add_newline ? "\n\n" : ""]\
		[nobody_returned ? "" : "You catch the scent of the following kin having recently went back to sleep:\n\
		<b>[went_back_to_sleep.Join("</b>, <b>")]</b>"]" \
	)

	return join_and_leave_log_cache


/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/allow_spawn(mob/user, silent = FALSE)
	if(!(user.key in team.players_spawned)) // One spawn per person
		return TRUE
	if(!silent)
		to_chat(user, span_warning("It'd be weird if there were multiple of you in that cave, wouldn't it?"))
	return FALSE


/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/create(mob/mob_possessor, newname)
	. = ..()

	// We remove their name from there if they come back.
	went_back_to_sleep -= newname
	join_and_leave_log_cache = null


// This stuff is put on equip because it turns out /special sometimes just don't get called because Nova
/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/equip(mob/living/carbon/human/spawned_human)
	. = ..()

	spawned_human.mind.add_antag_datum(/datum/antagonist/primitive_catgirl, team)

	team.players_spawned += (spawned_human.key)


/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/mouse_drop_receive(mob/living/carbon/human/target, mob/user, params)
	if(!istype(target))
		return
	if(!isprimitivedemihuman(target) || target.buckled)
		return

	if(target.stat == DEAD)
		to_chat(user, span_danger("Dead kin cannot be put back to sleep."))
		return

	if(target.key && target != user)
		if(!target.get_organ_by_type(/obj/item/organ/internal/brain) || (target.mind && !target.ssd_indicator))
			to_chat(user, span_danger("Awake kin cannot be put back to sleep against their will."))
			return

		if(target.lastclienttime + ssd_time >= world.time)
			to_chat(user, span_userdanger("You can't put [target] into [src] for another <b>[round(((ssd_time - (world.time - target.lastclienttime)) / (1 MINUTES)), 1)]</b> minutes."))
			log_admin("[key_name(user)] has attempted to put [key_name(target)] back into [src], but they were only disconnected for [round(((world.time - target.lastclienttime) / (1 MINUTES)), 1)] minutes.")
			message_admins("[key_name(user)] has attempted to put [key_name(target)] back into [src]. [ADMIN_JMP(src)]")
			return

		else if(tgui_alert(user, "Would you like to place [target] into [src]?", "Put back to sleep?", list("Yes", "No")) == "Yes")

			visible_message(span_infoplain("[user] starts putting [target] into [src]..."))

			if(!do_after(user, 3 SECONDS, target))
				balloon_alert(user, "cancelled transfer!")
				return

			to_chat(user, span_danger("You put [target] into [src]."))
			log_admin("[key_name(user)] has put [key_name(target)] back into [src].")
			message_admins("[key_name(user)] has put [key_name(target)] back into [src]. [ADMIN_JMP(src)]")

	if(target == user)
		if(tgui_alert(target, "Would you like to go back to sleep?", "Go back to sleep?", list("Yes", "No")) != "Yes")
			return

		visible_message(span_infoplain("[user] starts climbing down into [src]..."))

		if(!do_after(user, 3 SECONDS, target))
			balloon_alert(user, "cancelled transfer!")
			return

	if(LAZYLEN(target.buckled_mobs) > 0)
		if(target == user)
			to_chat(user, span_danger("You can't fit into [src] while someone is buckled to you."))
		else
			to_chat(user, span_danger("You can't fit [target] into [src] while someone is buckled to them."))

		return

	// Just in case something happened in-between, to make sure it doesn't do unexpected behaviors.
	if(!isprimitivedemihuman(target) || !can_interact(user) || !target.Adjacent(user)  || target.buckled || target.stat == DEAD)
		return

	if(target == user)
		visible_message(span_infoplain("[user] climbs down into [src]."))
	else
		visible_message(span_infoplain("[user] puts [target] into [src]."))

	log_admin("[key_name(target)] returned to [src].")
	message_admins("[key_name_admin(target)] returned to [src]. [ADMIN_JMP(src)]")
	add_fingerprint(target)
	put_back_in(target)


/**
 * Puts the target back into the spawner, effectively qdel'ing them after
 * stripping them of all their items, and finishes by adding back a use to the
 * spawner.
 */
/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/proc/put_back_in(mob/living/carbon/human/target)
	if(!istype(target))
		return

	// We don't want to constantly drop stuff that they spawn with.
	var/static/list/item_drop_blacklist
	if(!item_drop_blacklist)
		item_drop_blacklist = generate_item_drop_blacklist()

	for(var/obj/item/item in target)
		if(item_drop_blacklist[item.type] || (item.item_flags & ABSTRACT) || HAS_TRAIT(item, TRAIT_NODROP))
			continue

		target.dropItemToGround(item, FALSE)

	// We make sure people can come back in again, if they needed to fix prefs
	// or whatever.
	team.players_spawned -= (target.key)
	team.remove_member(target.mind)
	went_back_to_sleep += target.real_name
	join_and_leave_log_cache = null

	for(var/list/record in GLOB.ghost_records)
		if(record["name"] == target.real_name)
			GLOB.ghost_records.Remove(list(record))
			break

	// Just so the target's ghost ends up above the hole.
	target.forceMove(loc)
	target.ghostize(FALSE)

	qdel(target)


/**
 * Simple helper to generate the item drop blacklist based on the spawner's
 * outfit, only taking the used slots into account.
 */
/obj/effect/mob_spawn/ghost_role/human/primitive_catgirl/proc/generate_item_drop_blacklist()
	PROTECTED_PROC(TRUE)

	var/list/blacklist = list()

	blacklist[initial(outfit.uniform)] = TRUE
	blacklist[initial(outfit.shoes)] = TRUE
	blacklist[initial(outfit.gloves)] = TRUE
	blacklist[initial(outfit.suit)] = TRUE
	blacklist[initial(outfit.neck)] = TRUE
	blacklist[initial(outfit.back)] = TRUE

	return blacklist


/datum/job/primitive_catgirl
	title = "Icemoon Dweller"

// Antag and team datums

/datum/team/primitive_catgirls
	name = "Icewalkers"
	member_name = "Icewalker"
	show_roundend_report = FALSE

/datum/team/primitive_catgirls/roundend_report()
	var/list/report = list()

	report += span_header("An Ice Walker Tribe inhabited the wastes...</span><br>")
	if(length(members))
		report += "The [member_name]s were:"
		report += printplayerlist(members)
	else
		report += "<b>But none of its members woke up!</b>"

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

// Antagonist datum

/datum/antagonist/primitive_catgirl
	name = "\improper Icewalker"
	job_rank = ROLE_LAVALAND // If you're ashwalker banned you should also not be playing this, other way around as well
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Icemoon Dwellers"
	count_against_dynamic_roll_chance = FALSE
	show_in_roundend = FALSE

	/// Tracks the antag datum's 'team' for showing in the ghost orbit menu
	var/datum/team/primitive_catgirls/feline_team

	antag_recipes = list(
		/datum/crafting_recipe/boneaxe,
		/datum/crafting_recipe/bonespear,
		/datum/crafting_recipe/bonedagger,
		/datum/crafting_recipe/anointing_oil,
		/datum/crafting_recipe/handcrafted_hearthkin_armor,
		/datum/crafting_recipe/black_pelt_bed,
		/datum/crafting_recipe/white_pelt_bed,
		/datum/crafting_recipe/frozen_breath,
	)

/datum/antagonist/primitive_catgirl/Destroy()
	feline_team = null
	return ..()

/datum/antagonist/primitive_catgirl/create_team(datum/team/team)
	if(team)
		feline_team = team
		objectives |= feline_team.objectives
	else
		feline_team = new

/datum/antagonist/primitive_catgirl/get_team()
	return feline_team
