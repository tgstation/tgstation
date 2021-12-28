#define SUMMON_POSSIBILITIES 3
#define CULT_VICTORY 1
#define CULT_LOSS 0
#define CULT_NARSIE_KILLED -1

/datum/antagonist/cult
	name = "Cultist"
	roundend_category = "cultists"
	antagpanel_category = "Cult"
	antag_moodlet = /datum/mood_event/cult
	suicide_cry = "FOR NAR'SIE!!"
	preview_outfit = /datum/outfit/cultist
	var/datum/action/innate/cult/comm/communion = new
	var/datum/action/innate/cult/mastervote/vote = new
	var/datum/action/innate/cult/blood_magic/magic = new
	job_rank = ROLE_CULTIST
	antag_hud_name = "cult"
	var/ignore_implant = FALSE
	var/give_equipment = FALSE
	var/datum/team/cult/cult_team


/datum/antagonist/cult/get_team()
	return cult_team

/datum/antagonist/cult/create_team(datum/team/cult/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/cult/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.cult_team)
				cult_team = H.cult_team
				return
		cult_team = new /datum/team/cult
		cult_team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	cult_team = new_team

/datum/antagonist/cult/proc/add_objectives()
	objectives |= cult_team.objectives

/datum/antagonist/cult/Destroy()
	QDEL_NULL(communion)
	QDEL_NULL(vote)
	return ..()

/datum/antagonist/cult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(. && !ignore_implant)
		. = is_convertable_to_cult(new_owner.current,cult_team)

/datum/antagonist/cult/greet()
	to_chat(owner, span_userdanger("You are a member of the cult!"))
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/cult/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	add_objectives()
	current.AddElement(/datum/element/cult_status) // TODO: send get_status() here (or get the status inside the element idk)
	if(give_equipment)
		equip_cultist(TRUE)
	current.log_message("has been converted to the cult of Nar'Sie!", LOG_ATTACK, color="#960000")

	if(cult_team.blood_target && cult_team.blood_target_image && current.client)
		current.client.images += cult_team.blood_target_image

	ADD_TRAIT(current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)

/datum/antagonist/cult/on_removal()
	REMOVE_TRAIT(owner.current, TRAIT_HEALS_FROM_CULT_PYLONS, CULT_TRAIT)
	var/mob/living/current = owner.current
	current.RemoveElement(/datum/element/cult_status)
	return ..()

/datum/antagonist/cult/get_preview_icon()
	var/icon/icon = render_preview_outfit(preview_outfit)

	// The longsword is 64x64, but getFlatIcon crunches to 32x32.
	// So I'm just going to add it in post, screw it.

	// Center the dude, because item icon states start from the center.
	// This makes the image 64x64.
	icon.Crop(-15, -15, 48, 48)

	var/obj/item/melee/cultblade/longsword = new
	icon.Blend(icon(longsword.lefthand_file, longsword.inhand_icon_state), ICON_OVERLAY)
	qdel(longsword)

	// Move the guy back to the bottom left, 32x32.
	icon.Crop(17, 17, 48, 48)

	return finish_preview_icon(icon)

/datum/antagonist/cult/proc/equip_cultist(metal=TRUE)
	var/mob/living/carbon/H = owner.current
	if(!istype(H))
		return
	. += cult_give_item(/obj/item/melee/cultblade/dagger, H)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H)
	to_chat(owner, "These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>")


/datum/antagonist/cult/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_LPOCKET,
		"right pocket" = ITEM_SLOT_RPOCKET
	)

	var/T = new item_path(mob)
	var/item_name = initial(item_path.name)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(mob, span_userdanger("Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE
	else
		to_chat(mob, span_danger("You have a [item_name] in your [where]."))
		if(where == "backpack")
			SEND_SIGNAL(mob.back, COMSIG_TRY_STORAGE_SHOW, mob)
		return TRUE

/datum/antagonist/cult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	current.faction |= "cult"
	current.grant_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	if(!cult_team.cult_master)
		vote.Grant(current)
	communion.Grant(current)
	if(ishuman(current))
		magic.Grant(current)
	current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	add_team_hud(current)

/datum/antagonist/cult/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	handle_clown_mutation(current, removing = FALSE)
	current.faction -= "cult"
	current.remove_language(/datum/language/narsie, TRUE, TRUE, LANGUAGE_CULTIST)
	vote.Remove(current)
	communion.Remove(current)
	magic.Remove(current)
	current.clear_alert("bloodsense")

/datum/antagonist/cult/on_mindshield(mob/implanter)
	if(!silent)
		to_chat(owner.current, span_warning("You feel something interfering with your mental conditioning, but you resist it!"))
	return

/datum/antagonist/cult/on_removal()
	if(!silent)
		owner.current.visible_message(span_deconversion_message("<span class'warningplain'>[owner.current] looks like [owner.current.p_theyve()] just reverted to [owner.current.p_their()] old faith!</span>"), null, null, null, owner.current)
		to_chat(owner.current, span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of the Geometer and all your memories as her servant."))
		owner.current.log_message("has renounced the cult of Nar'Sie!", LOG_ATTACK, color="#960000")
	if(cult_team.blood_target && cult_team.blood_target_image && owner.current.client)
		owner.current.client.images -= cult_team.blood_target_image
	. = ..()

/datum/antagonist/cult/admin_add(datum/mind/new_owner,mob/admin)
	give_equipment = FALSE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has cult-ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has cult-ed [key_name(new_owner)].")

/datum/antagonist/cult/admin_remove(mob/user)
	silent = TRUE
	return ..()

/datum/antagonist/cult/get_admin_commands()
	. = ..()
	.["Dagger"] = CALLBACK(src,.proc/admin_give_dagger)
	.["Dagger and Metal"] = CALLBACK(src,.proc/admin_give_metal)
	.["Remove Dagger and Metal"] = CALLBACK(src, .proc/admin_take_all)

/datum/antagonist/cult/proc/admin_give_dagger(mob/admin)
	if(!equip_cultist(metal=FALSE))
		to_chat(admin, span_danger("Spawning dagger failed!"))

/datum/antagonist/cult/proc/admin_give_metal(mob/admin)
	if (!equip_cultist(metal=TRUE))
		to_chat(admin, span_danger("Spawning runed metal failed!"))

/datum/antagonist/cult/proc/admin_take_all(mob/admin)
	var/mob/living/current = owner.current
	for(var/o in current.get_all_contents())
		if(istype(o, /obj/item/melee/cultblade/dagger) || istype(o, /obj/item/stack/sheet/runed_metal))
			qdel(o)

/datum/antagonist/cult/master
	ignore_implant = TRUE
	show_in_antagpanel = FALSE //Feel free to add this later
	antag_hud_name = "cultmaster"
	var/datum/action/innate/cult/master/finalreck/reckoning = new
	var/datum/action/innate/cult/master/cultmark/bloodmark = new
	var/datum/action/innate/cult/master/pulse/throwing = new

/datum/antagonist/cult/master/Destroy()
	QDEL_NULL(reckoning)
	QDEL_NULL(bloodmark)
	QDEL_NULL(throwing)
	return ..()

/datum/antagonist/cult/master/greet()
	to_chat(owner.current, "<span class='warningplain'><span class='cultlarge'>You are the cult's Master</span>. As the cult's Master, you have a unique title and loud voice when communicating, are capable of marking \
	targets, such as a location or a noncultist, to direct the cult to them, and, finally, you are capable of summoning the entire living cult to your location <b><i>once</i></b>. Use these abilities to direct the cult to victory at any cost.</span>")

/datum/antagonist/cult/master/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	if(!cult_team.reckoning_complete)
		reckoning.Grant(current)
	bloodmark.Grant(current)
	throwing.Grant(current)
	current.update_action_buttons_icon()
	current.apply_status_effect(/datum/status_effect/cult_master)
	add_team_hud(current, /datum/antagonist/cult)

/datum/antagonist/cult/master/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	reckoning.Remove(current)
	bloodmark.Remove(current)
	throwing.Remove(current)
	current.update_action_buttons_icon()
	current.remove_status_effect(/datum/status_effect/cult_master)

/datum/team/cult
	name = "Cult"

	var/blood_target
	var/image/blood_target_image
	var/blood_target_reset_timer

	var/cult_vote_called = FALSE
	var/mob/living/cult_master
	var/reckoning_complete = FALSE
	var/cult_risen = FALSE
	var/cult_ascendent = FALSE

/datum/team/cult/New(starting_members)
	. = ..()
	src.AddElement(/datum/element/cult_status)

/datum/team/cult/Destroy(force, ...)
	. = ..()
	src.RemoveElement(/datum/element/cult_status)

/datum/team/cult/proc/check_size()
	if(cult_ascendent)
		return
	var/alive = 0
	var/cultplayers = 0
	for(var/I in GLOB.player_list)
		var/mob/M = I
		if(M.stat != DEAD)
			if(IS_CULTIST(M))
				++cultplayers
			else
				++alive
	var/ratio = cultplayers/alive

	var/list/cult_members = list()
	for (var/datum/mind/cult_mind in members)
		cult_members.Add(cult_mind)

	if(ratio > CULT_RISEN && !cult_risen)
		cult_risen = TRUE
		log_game("The blood cult has risen with [cultplayers] players.")
		SEND_SIGNAL(src, COMSIG_CULT_STATUS_CHANGED, CULT_STATUS_RISEN)

	if(ratio > CULT_ASCENDENT && !cult_ascendent)
		cult_ascendent = TRUE
		log_game("The blood cult has ascended with [cultplayers] players.")
		SEND_SIGNAL(src, COMSIG_CULT_STATUS_CHANGED, CULT_STATUS_ASCENDED)

/datum/team/cult/proc/get_status()
	var/status = CULT_STATUS_NORMAL
	if (cult_ascendent)
		status = CULT_STATUS_ASCENDED
	else if (cult_risen)
		status = CULT_STATUS_RISEN
	return status

/datum/team/cult/proc/make_image(datum/objective/sacrifice/sac_objective)
	var/datum/job/job_of_sacrifice = sac_objective.target.assigned_role
	var/datum/preferences/prefs_of_sacrifice = sac_objective.target.current.client.prefs
	var/icon/reshape = get_flat_human_icon(null, job_of_sacrifice, prefs_of_sacrifice, list(SOUTH))
	reshape.Shift(SOUTH, 4)
	reshape.Shift(EAST, 1)
	reshape.Crop(7,4,26,31)
	reshape.Crop(-5,-3,26,30)
	sac_objective.sac_image = reshape

/datum/team/cult/proc/setup_objectives()
	var/datum/objective/sacrifice/sacrifice_objective = new
	sacrifice_objective.team = src
	sacrifice_objective.find_target()
	objectives += sacrifice_objective

	var/datum/objective/eldergod/summon_objective = new
	summon_objective.team = src
	objectives += summon_objective

/datum/objective/sacrifice
	var/sacced = FALSE
	var/sac_image

/// Unregister signals from the old target so it doesn't cause issues when sacrificed of when a new target is found.
/datum/objective/sacrifice/proc/clear_sacrifice()
	if(!target)
		return
	UnregisterSignal(target, COMSIG_MIND_TRANSFERRED)
	if(target.current)
		UnregisterSignal(target.current, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_MIND_TRANSFERRED_INTO))
	target = null

/datum/objective/sacrifice/find_target(dupe_search_range)
	clear_sacrifice()
	if(!istype(team, /datum/team/cult))
		return
	var/datum/team/cult/cult = team
	var/list/target_candidates = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && !is_convertable_to_cult(player) && player.stat != DEAD)
			target_candidates += player.mind
	if(target_candidates.len == 0)
		message_admins("Cult Sacrifice: Could not find unconvertible target, checking for convertible target.")
		for(var/mob/living/carbon/human/player in GLOB.player_list)
			if(player.mind && !player.mind.has_antag_datum(/datum/antagonist/cult) && player.stat != DEAD)
				target_candidates += player.mind
	list_clear_nulls(target_candidates)
	if(LAZYLEN(target_candidates))
		target = pick(target_candidates)
		update_explanation_text()
		// Register a bunch of signals to both the target mind and its body
		// to stop cult from softlocking everytime the target is deleted before being actually sacrificed.
		RegisterSignal(target, COMSIG_MIND_TRANSFERRED, .proc/on_mind_transfer)
		RegisterSignal(target.current, COMSIG_PARENT_QDELETING, .proc/on_target_body_del)
		RegisterSignal(target.current, COMSIG_MOB_MIND_TRANSFERRED_INTO, .proc/on_possible_mindswap)
	else
		message_admins("Cult Sacrifice: Could not find unconvertible or convertible target. WELP!")
		sacced = TRUE // Prevents another hypothetical softlock. This basically means every PC is a cultist.
	if(!sacced)
		cult.make_image(src)
	for(var/datum/mind/mind in cult.members)
		if(mind.current)
			mind.current.clear_alert("bloodsense")
			mind.current.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)

/datum/objective/sacrifice/proc/on_target_body_del()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/find_target)

/datum/objective/sacrifice/proc/on_mind_transfer(datum/source, mob/previous_body)
	SIGNAL_HANDLER
	//If, for some reason, the mind was transferred to a ghost (better safe than sorry), find a new target.
	if(!isliving(target.current))
		INVOKE_ASYNC(src, .proc/find_target)
		return
	UnregisterSignal(previous_body, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_MIND_TRANSFERRED_INTO))
	RegisterSignal(target.current, COMSIG_PARENT_QDELETING, .proc/on_target_body_del)
	RegisterSignal(target.current, COMSIG_MOB_MIND_TRANSFERRED_INTO, .proc/on_possible_mindswap)

/datum/objective/sacrifice/proc/on_possible_mindswap(mob/source)
	SIGNAL_HANDLER
	UnregisterSignal(target.current, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_MIND_TRANSFERRED_INTO))
	//we check if the mind is bodyless only after mindswap shenanigeans to avoid issues.
	addtimer(CALLBACK(src, .proc/do_we_have_a_body), 0 SECONDS)

/datum/objective/sacrifice/proc/do_we_have_a_body()
	if(!target.current) //The player was ghosted and the mind isn't probably going to be transferred to another mob at this point.
		find_target()
		return
	RegisterSignal(target.current, COMSIG_PARENT_QDELETING, .proc/on_target_body_del)
	RegisterSignal(target.current, COMSIG_MOB_MIND_TRANSFERRED_INTO, .proc/on_possible_mindswap)

/datum/objective/sacrifice/check_completion()
	return sacced || completed

/datum/objective/sacrifice/update_explanation_text()
	if(target)
		explanation_text = "Sacrifice [target], the [target.assigned_role.title] via invoking an Offer rune with [target.p_them()] on it and three acolytes around it."
	else
		explanation_text = "The veil has already been weakened here, proceed to the final objective."

/datum/objective/eldergod
	var/summoned = FALSE
	var/killed = FALSE
	var/list/summon_spots = list()

/datum/objective/eldergod/New()
	..()
	var/sanity = 0
	while(summon_spots.len < SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon_area = pick(GLOB.sortedAreas - summon_spots)
		if(summon_area && is_station_level(summon_area.z) && (summon_area.area_flags & VALID_TERRITORY))
			summon_spots += summon_area
		sanity++
	update_explanation_text()

/datum/objective/eldergod/update_explanation_text()
	explanation_text = "Summon Nar'Sie by invoking the rune 'Summon Nar'Sie'. <b>The summoning can only be accomplished in [english_list(summon_spots)] - where the veil is weak enough for the ritual to begin.</b>"

/datum/objective/eldergod/check_completion()
	if(killed)
		return CULT_NARSIE_KILLED // You failed so hard that even the code went backwards.
	return summoned || completed

/datum/team/cult/proc/check_cult_victory()
	for(var/datum/objective/O in objectives)
		if(O.check_completion() == CULT_NARSIE_KILLED)
			return CULT_NARSIE_KILLED
		else if(!O.check_completion())
			return CULT_LOSS
	return CULT_VICTORY

/datum/team/cult/roundend_report()
	var/list/parts = list()
	var/victory = check_cult_victory()

	if(victory == CULT_NARSIE_KILLED) // Epic failure, you summoned your god and then someone killed it.
		parts += "<span class='redtext big'>Nar'sie has been killed! The cult will haunt the universe no longer!</span>"
	else if(victory)
		parts += "<span class='greentext big'>The cult has succeeded! Nar'Sie has snuffed out another torch in the void!</span>"
	else
		parts += "<span class='redtext big'>The staff managed to stop the cult! Dark words and heresy are no match for Nanotrasen's finest!</span>"

	if(objectives.len)
		parts += "<b>The cultists' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_greentext("Success!")]"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] [span_redtext("Fail.")]"
			count++

	if(members.len)
		parts += "<span class='header'>The cultists were:</span>"
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/cult/proc/is_sacrifice_target(datum/mind/mind)
	for(var/datum/objective/sacrifice/sac_objective in objectives)
		if(mind == sac_objective.target)
			return TRUE
	return FALSE

/// Returns whether the given mob is convertable to the blood cult
/proc/is_convertable_to_cult(mob/living/M, datum/team/cult/specific_cult)
	if(!istype(M))
		return FALSE
	if(M.mind)
		if(ishuman(M) && (M.mind.holy_role))
			return FALSE
		if(specific_cult?.is_sacrifice_target(M.mind))
			return FALSE
		if(M.mind.enslaved_to && !IS_CULTIST(M.mind.enslaved_to))
			return FALSE
		if(M.mind.unconvertable)
			return FALSE
	else
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD) || issilicon(M) || isbot(M) || isdrone(M) || !M.client)
		return FALSE //can't convert machines, shielded, or braindead
	return TRUE

/datum/outfit/cultist
	name = "Cultist (Preview only)"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt
	shoes = /obj/item/clothing/shoes/cult/alt
	r_hand = /obj/item/melee/blood_magic/stun

/datum/outfit/cultist/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.eye_color = BLOODCULT_EYE
	H.update_body()

	var/obj/item/clothing/suit/hooded/hooded = locate() in H
	hooded.MakeHood() // This is usually created on Initialize, but we run before atoms
	hooded.ToggleHood()
