/datum/antagonist/rev
	name = "\improper Revolutionary"
	roundend_category = "revolutionaries" // if by some miracle revolutionaries without revolution happen
	antagpanel_category = "Revolution"
	job_rank = ROLE_REV
	antag_moodlet = /datum/mood_event/revolution
	antag_hud_name = "rev"
	suicide_cry = "VIVA LA REVOLUTION!!"
	stinger_sound = 'sound/music/antag/revolutionary_tide.ogg'
	var/datum/team/revolution/rev_team

	/// When this antagonist is being de-antagged, this is the source. Can be a mob (for mindshield/blunt force trauma) or a #define string.
	var/deconversion_source

/datum/antagonist/rev/can_be_owned(datum/mind/new_owner)
	if(new_owner.assigned_role.job_flags & JOB_HEAD_OF_STAFF)
		return FALSE
	if(new_owner.current && HAS_MIND_TRAIT(new_owner.current, TRAIT_UNCONVERTABLE))
		return FALSE
	return ..()

/datum/antagonist/rev/admin_add(datum/mind/new_owner, mob/admin)
	// No revolution exists which means admin adding this will create a new revolution team
	// This causes problems because revolution teams (currently) require a dynamic datum to process its victory / defeat conditions
	if(!(locate(/datum/team/revolution) in GLOB.antagonist_teams))
		var/confirm = tgui_alert(admin, "Notice: Revolutions do not function 100% when created via traitor panel instead of dynamic. \
			The leaders will be able to convert as normal, but the shuttle will not be blocked and there will be no announcements when either side wins. \
			Are you sure?", "Be Wary", list("Yes", "No"))
		if(QDELETED(src) || QDELETED(new_owner.current) || confirm != "Yes")
			return

	go_through_with_admin_add(new_owner, admin)

/datum/antagonist/rev/proc/go_through_with_admin_add(datum/mind/new_owner, mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has rev'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has rev'ed [key_name(new_owner)].")
	to_chat(new_owner.current, span_userdanger("You are a member of the revolution!"))

/datum/antagonist/rev/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	handle_clown_mutation(M, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	add_team_hud(M, /datum/antagonist/rev)

/datum/antagonist/rev/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	handle_clown_mutation(M, removing = FALSE)

/datum/antagonist/rev/on_mindshield(mob/implanter)
	remove_revolutionary(implanter)
	return COMPONENT_MINDSHIELD_DECONVERTED

/datum/antagonist/rev/proc/equip_rev()
	return

/datum/antagonist/rev/on_gain()
	. = ..()
	create_objectives()
	equip_rev()
	owner.current.log_message("has been converted to the revolution!", LOG_ATTACK, color="red")

/datum/antagonist/rev/on_removal()
	remove_objectives()
	. = ..()

/datum/antagonist/rev/greet()
	. = ..()
	to_chat(owner, span_userdanger("Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!"))
	owner.announce_objectives()

/datum/antagonist/rev/create_team(datum/team/revolution/new_team)
	if(!new_team)
		//For now only one revolution at a time
		for(var/datum/antagonist/rev/head/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.rev_team)
				rev_team = H.rev_team
				return
		rev_team = new /datum/team/revolution
		rev_team.update_objectives()
		rev_team.update_rev_heads()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	rev_team = new_team

/datum/antagonist/rev/get_team()
	return rev_team

/datum/antagonist/rev/proc/create_objectives()
	objectives |= rev_team.objectives

/datum/antagonist/rev/proc/remove_objectives()
	objectives -= rev_team.objectives

//Bump up to head_rev
/datum/antagonist/rev/proc/promote()
	var/old_team = rev_team
	var/datum/mind/old_owner = owner
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/rev)
	var/datum/antagonist/rev/head/new_revhead = new()
	new_revhead.silent = TRUE
	old_owner.add_antag_datum(new_revhead,old_team)
	new_revhead.silent = FALSE
	to_chat(old_owner, span_userdanger("You have proved your devotion to revolution! You are a head revolutionary now!"))

/datum/antagonist/rev/get_admin_commands()
	. = ..()
	.["Promote"] = CALLBACK(src, PROC_REF(admin_promote))

/datum/antagonist/rev/proc/admin_promote(mob/admin)
	var/datum/mind/O = owner
	promote()
	message_admins("[key_name_admin(admin)] has head-rev'ed [O].")
	log_admin("[key_name(admin)] has head-rev'ed [O].")

/datum/antagonist/rev/head/go_through_with_admin_add(datum/mind/new_owner, mob/admin)
	give_flash = TRUE
	give_hud = TRUE
	remove_clumsy = TRUE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has head-rev'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has head-rev'ed [key_name(new_owner)].")
	to_chat(new_owner.current, span_userdanger("You are a member of the revolutionaries' leadership now!"))

/datum/antagonist/rev/head/get_admin_commands()
	. = ..()
	. -= "Promote"
	.["Take flash"] = CALLBACK(src, PROC_REF(admin_take_flash))
	.["Give flash"] = CALLBACK(src, PROC_REF(admin_give_flash))
	.["Repair flash"] = CALLBACK(src, PROC_REF(admin_repair_flash))
	.["Demote"] = CALLBACK(src, PROC_REF(admin_demote))

/datum/antagonist/rev/head/proc/admin_take_flash(mob/admin)
	var/list/L = owner.current.get_contents()
	var/obj/item/assembly/flash/handheld/flash = locate() in L
	if (!flash)
		to_chat(admin, span_danger("Deleting flash failed!"))
		return
	qdel(flash)

/datum/antagonist/rev/head/proc/admin_give_flash(mob/admin)
	//This is probably overkill but making these impact state annoys me
	var/old_give_flash = give_flash
	var/old_give_hud = give_hud
	var/old_remove_clumsy = remove_clumsy
	give_flash = TRUE
	give_hud = FALSE
	remove_clumsy = FALSE
	equip_rev()
	give_flash = old_give_flash
	give_hud = old_give_hud
	remove_clumsy = old_remove_clumsy

/datum/antagonist/rev/head/proc/admin_repair_flash(mob/admin)
	var/list/L = owner.current.get_contents()
	var/obj/item/assembly/flash/handheld/flash = locate() in L
	if (!flash)
		to_chat(admin, span_danger("Repairing flash failed!"))
	else
		flash.burnt_out = FALSE
		flash.update_appearance()

/datum/antagonist/rev/head/proc/admin_demote(mob/admin)
	message_admins("[key_name_admin(admin)] has demoted [key_name_admin(owner)] from head revolutionary.")
	log_admin("[key_name(admin)] has demoted [key_name(owner)] from head revolutionary.")
	demote()

/datum/antagonist/rev/head
	name = "\improper Head Revolutionary"
	antag_hud_name = "rev_head"
	job_rank = ROLE_REV_HEAD

	preview_outfit = /datum/outfit/revolutionary
	hardcore_random_bonus = TRUE

	var/remove_clumsy = FALSE
	var/give_flash = FALSE
	var/give_hud = TRUE

/datum/antagonist/rev/head/pre_mindshield(mob/implanter, mob/living/mob_override)
	return COMPONENT_MINDSHIELD_RESISTED

/datum/antagonist/rev/head/on_removal()
	if(give_hud)
		var/mob/living/carbon/C = owner.current
		var/obj/item/organ/internal/cyberimp/eyes/hud/security/syndicate/S = C.get_organ_slot(ORGAN_SLOT_HUD)
		if(S)
			S.Remove(C)
	return ..()

/datum/antagonist/rev/head/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/real_mob = mob_override || owner.current
	real_mob.AddComponentFrom(REF(src), /datum/component/can_flash_from_behind)
	RegisterSignal(real_mob, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON, PROC_REF(on_flash_success))

/datum/antagonist/rev/head/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/real_mob = mob_override || owner.current
	real_mob.RemoveComponentSource(REF(src), /datum/component/can_flash_from_behind)
	UnregisterSignal(real_mob, COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON)

/// Signal proc for [COMSIG_MOB_SUCCESSFUL_FLASHED_CARBON].
/// Bread and butter of revolution conversion, successfully flashing a carbon will make them a revolutionary
/datum/antagonist/rev/head/proc/on_flash_success(mob/living/source, mob/living/carbon/flashed, obj/item/assembly/flash/flash, deviation)
	SIGNAL_HANDLER

	if(flashed.stat == DEAD)
		return
	if(flashed.stat != CONSCIOUS)
		to_chat(source, span_warning("[flashed.p_They()] must be conscious before you can convert [flashed.p_them()]!"))
		return

	if(isnull(flashed.mind) || !GET_CLIENT(flashed))
		to_chat(source, span_warning("[flashed]'s mind is so vacant that it is not susceptible to influence!"))
		return

	var/holiday_meme_chance = check_holidays(APRIL_FOOLS) && prob(10)
	if(add_revolutionary(flashed.mind, mute = !holiday_meme_chance)) // don't mute if we roll the meme holiday chance
		if(holiday_meme_chance)
			INVOKE_ASYNC(src, PROC_REF(_async_holiday_meme_say), flashed)
		flash.times_used-- // Flashes are less likely to burn out for headrevs, when used for conversion
	else
		to_chat(source, span_warning("[flashed] seems resistant to [flash]!"))

/// Used / called async from [proc/on_flash] to deliver a funny meme line
/datum/antagonist/rev/head/proc/_async_holiday_meme_say(mob/living/carbon/flashed)
	if(ishuman(flashed))
		var/mob/living/carbon/human/human_flashed = flashed
		human_flashed.force_say()
	flashed.say("You son of a bitch! I'm in.", forced = "That son of a bitch! They're in. (April Fools)")

/datum/antagonist/rev/head/antag_listing_name()
	return ..() + "(Leader)"

/datum/antagonist/rev/head/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)

	final_icon.Blend(make_assistant_icon("Business Hair"), ICON_UNDERLAY, -8, 0)
	final_icon.Blend(make_assistant_icon("CIA"), ICON_UNDERLAY, 8, 0)

	// Apply the rev head HUD, but scale up the preview icon a bit beforehand.
	// Otherwise, the R gets cut off.
	final_icon.Scale(64, 64)

	var/icon/rev_head_icon = icon('icons/mob/huds/antag_hud.dmi', "rev_head")
	rev_head_icon.Scale(48, 48)
	rev_head_icon.Crop(1, 1, 64, 64)
	rev_head_icon.Shift(EAST, 10)
	rev_head_icon.Shift(NORTH, 16)
	final_icon.Blend(rev_head_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/rev/head/proc/make_assistant_icon(hairstyle)
	var/mob/living/carbon/human/dummy/consistent/assistant = new
	assistant.set_hairstyle(hairstyle, update = TRUE)

	var/icon/assistant_icon = render_preview_outfit(/datum/outfit/job/assistant/consistent, assistant)
	assistant_icon.ChangeOpacity(0.5)

	qdel(assistant)

	return assistant_icon

/datum/antagonist/rev/proc/can_be_converted(mob/living/candidate)
	if(!candidate.mind)
		return FALSE
	if(!can_be_owned(candidate.mind))
		return FALSE
	var/mob/living/carbon/C = candidate //Check to see if the potential rev is implanted
	if(!istype(C)) //Can't convert simple animals
		return FALSE
	return TRUE

/**
 * Adds a new mind to our revoltuion
 *
 * * rev_mind - the mind we're adding
 * * stun - If TRUE, we will flash act and apply a long stun when we're applied
 * * mute - If TRUE, we will apply a mute when we're applied
 */
/datum/antagonist/rev/proc/add_revolutionary(datum/mind/rev_mind, stun = TRUE, mute = TRUE)
	if(!can_be_converted(rev_mind.current))
		return FALSE

	if(mute)
		rev_mind.current.set_silence_if_lower(10 SECONDS)
	if(stun)
		rev_mind.current.flash_act(1, 1)
		rev_mind.current.Stun(10 SECONDS)

	rev_mind.add_memory(/datum/memory/recruited_by_headrev, protagonist = rev_mind.current, antagonist = owner.current)
	rev_mind.add_antag_datum(/datum/antagonist/rev,rev_team)
	rev_mind.special_role = ROLE_REV
	return TRUE

/datum/antagonist/rev/head/proc/demote()
	var/datum/mind/old_owner = owner
	var/old_team = rev_team
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/rev/head)
	var/datum/antagonist/rev/new_rev = new /datum/antagonist/rev()
	new_rev.silent = TRUE
	old_owner.add_antag_datum(new_rev,old_team)
	new_rev.silent = FALSE
	to_chat(old_owner, span_userdanger("Revolution has been disappointed of your leader traits! You are a regular revolutionary now!"))

/datum/antagonist/rev/farewell()
	if(ishuman(owner.current))
		owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] real allegiance!"), null, null, null, owner.current)
		to_chat(owner, "<span class='deconversion_message bold'>You are no longer a brainwashed revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you....</span>")
	else if(issilicon(owner.current))
		owner.current.visible_message(span_deconversion_message("The frame beeps contentedly, purging the hostile memory engram from the MMI before initializing it."), null, null, null, owner.current)
		to_chat(owner, span_userdanger("The frame's firmware detects and deletes your neural reprogramming! You remember nothing but the name of the one who flashed you."))

/datum/antagonist/rev/head/farewell()
	if (deconversion_source == DECONVERTER_STATION_WIN)
		return
	if((ishuman(owner.current)))
		if(owner.current.stat != DEAD)
			owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] real allegiance!"), null, null, null, owner.current)
			to_chat(owner, "<span class='deconversion_message bold'>You have given up your cause of overthrowing the command staff. You are no longer a Head Revolutionary.</span>")
		else
			to_chat(owner, "<span class='deconversion_message bold'>The sweet release of death. You are no longer a Head Revolutionary.</span>")
	else if(issilicon(owner.current))
		owner.current.visible_message(span_deconversion_message("The frame beeps contentedly, suppressing the disloyal personality traits from the MMI before initializing it."), null, null, null, owner.current)
		to_chat(owner, span_userdanger("The frame's firmware detects and suppresses your unwanted personality traits! You feel more content with the leadership around these parts."))

/// Handles rev removal via IC methods such as borging, mindshielding, blunt force trauma to the head or revs losing.
/datum/antagonist/rev/proc/remove_revolutionary(deconverter)
	owner.current.log_message("has been deconverted from the revolution by [ismob(deconverter) ? key_name(deconverter) : deconverter]!", LOG_ATTACK, color=COLOR_CULT_RED)
	if(deconverter == DECONVERTER_BORGED)
		message_admins("[ADMIN_LOOKUPFLW(owner.current)] has been borged while being a [name]")
	owner.special_role = null
	deconversion_source = deconverter
	owner.remove_antag_datum(type)

/// This is for revheads, for which they ordinarily shouldn't be deconverted outside of revs losing. As an exception, forceborging can de-headrev them.
/datum/antagonist/rev/head/remove_revolutionary(deconverter)
	// If they're living and the station won, turn them into an exiled headrev.
	if(owner.current.stat != DEAD && deconverter == DECONVERTER_STATION_WIN)
		owner.add_antag_datum(/datum/antagonist/enemy_of_the_state)

	// Only actually remove headrev status on borging or when the station wins.
	if(deconverter == DECONVERTER_BORGED || deconverter == DECONVERTER_STATION_WIN)
		return ..()

/datum/antagonist/rev/head/equip_rev()
	var/mob/living/carbon/carbon_owner = owner.current
	if(!ishuman(carbon_owner))
		return

	if(give_flash)
		var/where = carbon_owner.equip_conspicuous_item(new /obj/item/assembly/flash/handheld)
		if (where)
			to_chat(carbon_owner, "The flash in your [where] will help you to persuade the crew to join your cause.")
		else
			to_chat(carbon_owner, "The Syndicate were unfortunately unable to get you a flash.")

	if(give_hud)
		var/obj/item/organ/internal/cyberimp/eyes/hud/security/syndicate/hud = new()
		hud.Insert(carbon_owner)
		if(carbon_owner.get_quirk(/datum/quirk/body_purist))
			to_chat(carbon_owner, "Being a body purist, you would never accept cybernetic implants. Upon hearing this, your employers signed you up for a special program, which... for \
			some odd reason, you just can't remember... either way, the program must have worked, because you have gained the ability to keep track of who is mindshield-implanted, and therefore unable to be recruited.")
		else
			to_chat(carbon_owner, "Your eyes have been implanted with a cybernetic security HUD which will help you keep track of who is mindshield-implanted, and therefore unable to be recruited.")

/datum/team/revolution
	name = "\improper Revolution"

	/// Maximum number of headrevs
	var/max_headrevs = 3

	/// List of all ex-headrevs. Useful because dynamic removes antag status when it ends, so this can be kept for the roundend report.
	var/list/ex_headrevs = list()

	/// List of all ex-revs. Useful because dynamic removes antag status when it ends, so this can be kept for the roundend report.
	var/list/ex_revs = list()

	/// The objective of the heads of staff, aka to kill the headrevs.
	var/list/datum/objective/mutiny/heads_objective = list()

/// Proc called on periodic timer.
/// Updates the rev team's objectives to make sure all heads are targets, useful when new heads latejoin.
/// Propagates all objectives to all revs.
/datum/team/revolution/proc/update_objectives(initial = FALSE)
	var/untracked_heads = SSjob.get_all_heads()

	for(var/datum/objective/mutiny/mutiny_objective in objectives)
		untracked_heads -= mutiny_objective.target

	for(var/datum/mind/extra_mutiny_target in untracked_heads)
		var/datum/objective/mutiny/new_target = new()
		new_target.team = src
		new_target.target = extra_mutiny_target
		new_target.update_explanation_text()
		objectives += new_target

	for(var/datum/mind/rev_member in members)
		var/datum/antagonist/rev/rev_antag = rev_member.has_antag_datum(/datum/antagonist/rev)
		rev_antag.objectives |= objectives

	addtimer(CALLBACK(src, PROC_REF(update_objectives)), HEAD_UPDATE_PERIOD, TIMER_UNIQUE)

/// Returns a list of all headrevs.
/datum/team/revolution/proc/get_head_revolutionaries()
	var/list/headrev_list = list()

	for(var/datum/mind/revolutionary in members)
		if(revolutionary.has_antag_datum(/datum/antagonist/rev/head))
			headrev_list += revolutionary

	return headrev_list

/// Proc called on periodic timer.
/// Tries to make sure an appropriate number of headrevs are part of the revolution.
/// Will promote up revs to headrevs as necessary based on the hard max_headrevs cap and the soft cap based on the number of heads of staff and sec.
/datum/team/revolution/proc/update_rev_heads()
	if(SSticker.HasRoundStarted())
		var/list/datum/mind/head_revolutionaries = get_head_revolutionaries()
		var/list/datum/mind/heads = SSjob.get_all_heads()
		var/list/sec = SSjob.get_all_sec()

		if(head_revolutionaries.len < max_headrevs && head_revolutionaries.len < round(heads.len - ((8 - sec.len) / 3)))
			var/list/datum/mind/non_heads = members - head_revolutionaries
			var/list/datum/mind/promotable = list()
			var/list/datum/mind/monkey_promotable = list()
			for(var/datum/mind/khrushchev in non_heads)
				if(khrushchev.current && !khrushchev.current.incapacitated && !HAS_TRAIT(khrushchev.current, TRAIT_RESTRAINED) && khrushchev.current.client)
					if((ROLE_REV_HEAD in khrushchev.current.client.prefs.be_special) || (ROLE_PROVOCATEUR in khrushchev.current.client.prefs.be_special))
						if(!ismonkey(khrushchev.current))
							promotable += khrushchev
						else
							monkey_promotable += khrushchev
			if(!promotable.len && monkey_promotable.len) //if only monkey revolutionaries remain, promote one of them to the leadership.
				promotable = monkey_promotable
			if(promotable.len)
				var/datum/mind/new_leader = pick(promotable)
				var/datum/antagonist/rev/rev = new_leader.has_antag_datum(/datum/antagonist/rev)
				rev.promote()

	addtimer(CALLBACK(src, PROC_REF(update_rev_heads)),HEAD_UPDATE_PERIOD,TIMER_UNIQUE)

/// Saves a list of all ex-headrevs and a list of all revs.
/datum/team/revolution/proc/save_members()
	ex_headrevs = get_antag_minds(/datum/antagonist/rev/head, TRUE)
	ex_revs = get_antag_minds(/datum/antagonist/rev, TRUE)

/// Checks if revs have won
/datum/team/revolution/proc/check_rev_victory()
	for(var/datum/objective/mutiny/objective in objectives)
		if(!(objective.check_completion()))
			return FALSE
	return TRUE

/// Checks if heads have won
/datum/team/revolution/proc/check_heads_victory()
	// List of headrevs we're currently tracking
	var/list/included_headrevs = list()
	// List of current headrevs
	var/list/current_headrevs = get_head_revolutionaries()
	// A copy of the head of staff objective list, since we're going to be modifying the original list.
	var/list/heads_objective_copy = heads_objective.Copy()

	var/objective_complete = TRUE
	// Here, we check current head of staff objectives and remove them if the target doesn't exist as a headrev anymore
	for(var/datum/objective/mutiny/objective in heads_objective_copy)
		if(!(objective.target in current_headrevs))
			heads_objective -= objective
			continue
		if(!objective.check_completion())
			objective_complete = FALSE
		included_headrevs += objective.target

	// Here, we check current headrevs and add them as objectives if they didn't exist as a head of staff objective before.
	// Additionally, we make sure the objective is not completed by running the check_completion check on them.
	for(var/datum/mind/rev_mind as anything in current_headrevs)
		if(!(rev_mind in included_headrevs))
			var/datum/objective/mutiny/objective = new()
			objective.target = rev_mind
			if(!objective.check_completion())
				objective_complete = FALSE
			heads_objective += objective

	return objective_complete

/// Updates the state of the world depending on if revs won or loss.
/// Returns who won, at which case this method should no longer be called.
/datum/team/revolution/proc/process_victory()
	if (check_rev_victory())
		victory_effects()
		return REVOLUTION_VICTORY

	if (!check_heads_victory())
		return

	. = STATION_VICTORY

	SSshuttle.clearHostileEnvironment(src)

	// Save rev lists before we remove the antag datums.
	save_members()

	// Remove everyone as a revolutionary
	for (var/datum/mind/rev_mind as anything in members)
		var/datum/antagonist/rev/rev_antag = rev_mind.has_antag_datum(/datum/antagonist/rev)
		if (!isnull(rev_antag))
			rev_antag.remove_revolutionary(DECONVERTER_STATION_WIN)
			if(rev_mind in ex_headrevs)
				LAZYADD(rev_mind.special_statuses, "<span class='bad'>Former head revolutionary</span>")
			else
				LAZYADD(rev_mind.special_statuses, "<span class='bad'>Former revolutionary</span>")

	defeat_effects()

/// Handles any pre-round-ending effects on rev victory. An example use case is recording memories.
/datum/team/revolution/proc/victory_effects()
	for(var/datum/mind/headrev_mind as anything in ex_headrevs)
		var/mob/living/real_headrev = headrev_mind.current
		if(isnull(real_headrev))
			continue
		add_memory_in_range(real_headrev, 5, /datum/memory/revolution_rev_victory, protagonist = real_headrev)

/// Handles effects of revs losing, such as making ex-headrevs unrevivable and setting up head of staff memories.
/datum/team/revolution/proc/defeat_effects()
	// If the revolution was quelled, make rev heads unable to be revived through pods
	for (var/datum/mind/rev_head as anything in ex_headrevs)
		if(!isnull(rev_head.current))
			ADD_TRAIT(rev_head.current, TRAIT_DEFIB_BLACKLISTED, REF(src))

	for(var/datum/objective/mutiny/head_tracker in objectives)
		var/mob/living/head_of_staff = head_tracker.target?.current
		if(!isnull(head_of_staff))
			add_memory_in_range(head_of_staff, 5, /datum/memory/revolution_heads_victory, protagonist = head_of_staff)

	priority_announce("It appears the mutiny has been quelled. Please return yourself and your incapacitated colleagues to work. \
		We have remotely blacklisted the head revolutionaries in your medical records to prevent accidental revival.", null, null, null, "[command_name()] Loyalty Monitoring Division")

/// Mutates the ticker to report that the revs have won
/datum/team/revolution/proc/round_result(finished)
	if (finished == REVOLUTION_VICTORY)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if (finished == STATION_VICTORY)
		SSticker.mode_result = "loss - rev heads killed"
		SSticker.news_report = REVS_LOSE

/datum/team/revolution/roundend_report()
	if(!members.len && !ex_headrevs.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'>"

	var/list/targets = list()
	var/list/datum/mind/headrevs
	var/list/datum/mind/revs
	if(ex_headrevs.len)
		headrevs = ex_headrevs
	else
		headrevs = get_antag_minds(/datum/antagonist/rev/head, TRUE)

	if(ex_revs.len)
		revs = ex_revs
	else
		revs = get_antag_minds(/datum/antagonist/rev, TRUE)

	var/num_revs = 0
	var/num_survivors = 0
	for(var/mob/living/carbon/survivor in GLOB.alive_mob_list)
		if(survivor.ckey)
			num_survivors += 1
			if ((survivor.mind in revs) || (survivor.mind in headrevs))
				num_revs += 1

	if(num_survivors)
		result += "Command's Approval Rating: <B>[100 - round((num_revs/num_survivors)*100, 0.1)]%</B><br>"

	if(headrevs.len)
		var/list/headrev_part = list()
		headrev_part += span_header("The head revolutionaries were:")
		headrev_part += printplayerlist(headrevs, !check_rev_victory())
		result += headrev_part.Join("<br>")

	if(revs.len)
		var/list/rev_part = list()
		rev_part += span_header("The revolutionaries were:")
		rev_part += printplayerlist(revs, !check_rev_victory())
		result += rev_part.Join("<br>")

	var/list/heads = SSjob.get_all_heads()
	if(heads.len)
		var/head_text = span_header("The heads of staff were:")
		head_text += "<ul class='playerlist'>"
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			head_text += "<li>"
			if(target)
				head_text += span_redtext("Target")
			head_text += "[printplayer(head, 1)]</li>"
		head_text += "</ul><br>"
		result += head_text

	result += "</div>"

	return result.Join()

/datum/team/revolution/antag_listing_entry()
	var/common_part = ""
	var/list/parts = list()
	parts += "<b>[antag_listing_name()]</b><br>"
	parts += "<table cellspacing=5>"

	var/list/heads = get_team_antags(/datum/antagonist/rev/head, FALSE)

	for(var/datum/antagonist/A in heads | get_team_antags())
		parts += A.antag_listing_entry()

	parts += "</table>"
	common_part = parts.Join()

	var/heads_report = "<b>Heads of Staff</b><br>"
	heads_report += "<table cellspacing=5>"
	for(var/datum/mind/N as anything in SSjob.get_living_heads())
		var/mob/M = N.current
		if(M)
			heads_report += "<tr><td><a href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
			heads_report += "<td><A href='?priv_msg=[M.ckey]'>PM</A></td>"
			heads_report += "<td><A href='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
			var/turf/mob_loc = get_turf(M)
			heads_report += "<td>[mob_loc.loc]</td></tr>"
		else
			heads_report += "<tr><td><a href='?_src_=vars;[HrefToken()];Vars=[REF(N)]'>[N.name]([N.key])</a><i>Head body destroyed!</i></td>"
			heads_report += "<td><A href='?priv_msg=[N.key]'>PM</A></td></tr>"
	heads_report += "</table>"
	return common_part + heads_report

/datum/outfit/revolutionary
	name = "Revolutionary (Preview only)"

	uniform = /obj/item/clothing/under/costume/soviet
	head = /obj/item/clothing/head/costume/ushanka
	gloves = /obj/item/clothing/gloves/color/black
	l_hand = /obj/item/spear
	r_hand = /obj/item/assembly/flash
