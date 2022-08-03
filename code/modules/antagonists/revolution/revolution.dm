#define DECONVERTER_STATION_WIN "gamemode_station_win"
#define DECONVERTER_REVS_WIN "gamemode_revs_win"
//How often to check for promotion possibility
#define HEAD_UPDATE_PERIOD 300

/datum/antagonist/rev
	name = "\improper Revolutionary"
	roundend_category = "revolutionaries" // if by some miracle revolutionaries without revolution happen
	antagpanel_category = "Revolution"
	job_rank = ROLE_REV
	antag_moodlet = /datum/mood_event/revolution
	antag_hud_name = "rev"
	suicide_cry = "VIVA LA REVOLUTION!!"
	var/datum/team/revolution/rev_team
	///when this antagonist is being de-antagged, this is why
	var/deconversion_reason

	/// What message should the player receive when they are being demoted, and the revolution has won?
	var/victory_message = "The revolution has overpowered the command staff! Viva la revolution! Execute any head of staff and security should you find them alive."

/datum/antagonist/rev/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			return FALSE
		if(new_owner.unconvertable)
			return FALSE
		if(new_owner.current && HAS_TRAIT(new_owner.current, TRAIT_MINDSHIELD))
			return FALSE

/datum/antagonist/rev/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	handle_clown_mutation(M, mob_override ? null : "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
	add_team_hud(M, /datum/antagonist/rev)

/datum/antagonist/rev/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	handle_clown_mutation(M, removing = FALSE)

/datum/antagonist/rev/on_mindshield(mob/implanter)
	remove_revolutionary(FALSE, implanter)
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
		rev_team.update_heads()
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
	.["Promote"] = CALLBACK(src,.proc/admin_promote)

/datum/antagonist/rev/proc/admin_promote(mob/admin)
	var/datum/mind/O = owner
	promote()
	message_admins("[key_name_admin(admin)] has head-rev'ed [O].")
	log_admin("[key_name(admin)] has head-rev'ed [O].")

/datum/antagonist/rev/head/admin_add(datum/mind/new_owner,mob/admin)
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
	.["Take flash"] = CALLBACK(src,.proc/admin_take_flash)
	.["Give flash"] = CALLBACK(src,.proc/admin_give_flash)
	.["Repair flash"] = CALLBACK(src,.proc/admin_repair_flash)
	.["Demote"] = CALLBACK(src,.proc/admin_demote)

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

	var/remove_clumsy = FALSE
	var/give_flash = FALSE
	var/give_hud = TRUE

/datum/antagonist/rev/head/pre_mindshield(mob/implanter, mob/living/mob_override)
	return COMPONENT_MINDSHIELD_RESISTED

/datum/antagonist/rev/head/on_removal()
	if(give_hud)
		var/mob/living/carbon/C = owner.current
		var/obj/item/organ/internal/cyberimp/eyes/hud/security/syndicate/S = C.getorganslot(ORGAN_SLOT_HUD)
		if(S)
			S.Remove(C)
	return ..()

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
	assistant.hairstyle = hairstyle
	assistant.update_hair(is_creating = TRUE)

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

/datum/antagonist/rev/proc/add_revolutionary(datum/mind/rev_mind,stun = TRUE)
	if(!can_be_converted(rev_mind.current))
		return FALSE
	if(stun)
		if(iscarbon(rev_mind.current))
			var/mob/living/carbon/carbon_mob = rev_mind.current
			carbon_mob.silent = max(carbon_mob.silent, 5)
			carbon_mob.flash_act(1, 1)
		rev_mind.current.Stun(100)
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

/// Checks if the revolution succeeded, and lets them know.
/datum/antagonist/rev/proc/announce_victorious()
	. = rev_team.check_rev_victory()

	if (!.)
		return

	to_chat(owner, "<span class='deconversion_message bold'>[victory_message]</span>")
	var/policy = get_policy(ROLE_REV_SUCCESSFUL)
	if (policy)
		to_chat(owner, policy)

/datum/antagonist/rev/farewell()
	if (announce_victorious())
		return

	if(ishuman(owner.current))
		owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] real allegiance!"), null, null, null, owner.current)
		to_chat(owner, "<span class='deconversion_message bold'>You are no longer a brainwashed revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you....</span>")
	else if(issilicon(owner.current))
		owner.current.visible_message(span_deconversion_message("The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it."), null, null, null, owner.current)
		to_chat(owner, span_userdanger("The frame's firmware detects and deletes your neural reprogramming! You remember nothing but the name of the one who flashed you."))

/datum/antagonist/rev/head/farewell()
	if (announce_victorious() || deconversion_reason == DECONVERTER_STATION_WIN)
		return
	if((ishuman(owner.current)))
		if(owner.current.stat != DEAD)
			owner.current.visible_message(span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] real allegiance!"), null, null, null, owner.current)
			to_chat(owner, "<span class='deconversion_message bold'>You have given up your cause of overthrowing the command staff. You are no longer a Head Revolutionary.</span>")
		else
			to_chat(owner, "<span class='deconversion_message bold'>The sweet release of death. You are no longer a Head Revolutionary.</span>")
	else if(issilicon(owner.current))
		owner.current.visible_message(span_deconversion_message("The frame beeps contentedly, suppressing the disloyal personality traits from the MMI before initalizing it."), null, null, null, owner.current)
		to_chat(owner, span_userdanger("The frame's firmware detects and suppresses your unwanted personality traits! You feel more content with the leadership around these parts."))

//blunt trauma deconversions call this through species.dm spec_attacked_by()
/datum/antagonist/rev/proc/remove_revolutionary(borged, deconverter)
	owner.current.log_message("has been deconverted from the revolution by [ismob(deconverter) ? key_name(deconverter) : deconverter]!", LOG_ATTACK, color="#960000")
	if(borged)
		message_admins("[ADMIN_LOOKUPFLW(owner.current)] has been borged while being a [name]")
	owner.special_role = null
	if(iscarbon(owner.current) && deconverter != DECONVERTER_REVS_WIN)
		var/mob/living/carbon/C = owner.current
		C.Unconscious(100)
	deconversion_reason = deconverter
	owner.remove_antag_datum(type)

/datum/antagonist/rev/head/remove_revolutionary(borged, deconverter)
	var/re_antag = FALSE
	var/datum/mind/old_owner = owner //owner gets nulled when rev antag removed
	if(borged || deconverter == DECONVERTER_STATION_WIN || deconverter == DECONVERTER_REVS_WIN)
		if(owner.current.stat != DEAD && deconverter == DECONVERTER_STATION_WIN)
			re_antag = TRUE
		. = ..()
		if(re_antag)
			old_owner.add_antag_datum(/datum/antagonist/enemy_of_the_state) //needs to be post ..() so old antag status is cleaned up
/datum/antagonist/rev/head/equip_rev()
	var/mob/living/carbon/C = owner.current
	if(!ishuman(C))
		return

	if(give_flash)
		var/obj/item/assembly/flash/handheld/T = new(C)
		var/list/slots = list (
			"backpack" = ITEM_SLOT_BACKPACK,
			"left pocket" = ITEM_SLOT_LPOCKET,
			"right pocket" = ITEM_SLOT_RPOCKET
		)
		var/where = C.equip_in_one_of_slots(T, slots)
		if (!where)
			to_chat(C, "The Syndicate were unfortunately unable to get you a flash.")
		else
			to_chat(C, "The flash in your [where] will help you to persuade the crew to join your cause.")

	if(give_hud)
		var/obj/item/organ/internal/cyberimp/eyes/hud/security/syndicate/S = new()
		S.Insert(C)
		to_chat(C, "Your eyes have been implanted with a cybernetic security HUD which will help you keep track of who is mindshield-implanted, and therefore unable to be recruited.")

/datum/team/revolution
	name = "Revolution"
	var/max_headrevs = 3
	var/list/ex_headrevs = list() // Dynamic removes revs on loss, used to keep a list for the roundend report.
	var/list/ex_revs = list()

/datum/team/revolution/proc/update_objectives(initial = FALSE)
	var/untracked_heads = SSjob.get_all_heads()
	for(var/datum/objective/mutiny/O in objectives)
		untracked_heads -= O.target
	for(var/datum/mind/M in untracked_heads)
		var/datum/objective/mutiny/new_target = new()
		new_target.team = src
		new_target.target = M
		new_target.update_explanation_text()
		objectives += new_target
	for(var/datum/mind/M in members)
		var/datum/antagonist/rev/R = M.has_antag_datum(/datum/antagonist/rev)
		R.objectives |= objectives

	addtimer(CALLBACK(src,.proc/update_objectives),HEAD_UPDATE_PERIOD,TIMER_UNIQUE)

/datum/team/revolution/proc/head_revolutionaries()
	. = list()
	for(var/datum/mind/M in members)
		if(M.has_antag_datum(/datum/antagonist/rev/head))
			. += M

/datum/team/revolution/proc/update_heads()
	if(SSticker.HasRoundStarted())
		var/list/datum/mind/head_revolutionaries = head_revolutionaries()
		var/list/datum/mind/heads = SSjob.get_all_heads()
		var/list/sec = SSjob.get_all_sec()

		if(head_revolutionaries.len < max_headrevs && head_revolutionaries.len < round(heads.len - ((8 - sec.len) / 3)))
			var/list/datum/mind/non_heads = members - head_revolutionaries
			var/list/datum/mind/promotable = list()
			var/list/datum/mind/nonhuman_promotable = list()
			for(var/datum/mind/khrushchev in non_heads)
				if(khrushchev.current && !khrushchev.current.incapacitated() && !HAS_TRAIT(khrushchev.current, TRAIT_RESTRAINED) && khrushchev.current.client)
					if((ROLE_REV_HEAD in khrushchev.current.client.prefs.be_special) || (ROLE_PROVOCATEUR in khrushchev.current.client.prefs.be_special))
						if(ishuman(khrushchev.current))
							promotable += khrushchev
						else
							nonhuman_promotable += khrushchev
			if(!promotable.len && nonhuman_promotable.len) //if only nonhuman revolutionaries remain, promote one of them to the leadership.
				promotable = nonhuman_promotable
			if(promotable.len)
				var/datum/mind/new_leader = pick(promotable)
				var/datum/antagonist/rev/rev = new_leader.has_antag_datum(/datum/antagonist/rev)
				rev.promote()

	addtimer(CALLBACK(src,.proc/update_heads),HEAD_UPDATE_PERIOD,TIMER_UNIQUE)

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
	for(var/datum/mind/rev_mind in head_revolutionaries())
		var/turf/rev_turf = get_turf(rev_mind.current)
		if(!considered_afk(rev_mind) && considered_alive(rev_mind) && is_station_level(rev_turf.z))
			if(ishuman(rev_mind.current))
				return FALSE
	return TRUE

/// Updates the state of the world depending on if revs won or loss.
/// Returns who won, at which case this method should no longer be called.
/// If revs_win_injection_amount is passed, then that amount of threat will be added if the revs win.
/datum/team/revolution/proc/process_victory(revs_win_injection_amount)
	if (check_rev_victory())
		. = REVOLUTION_VICTORY
	else if (check_heads_victory())
		. = STATION_VICTORY
	else
		return

	SSshuttle.clearHostileEnvironment(src)
	save_members()

	var/charter_given = FALSE

	// Remove everyone as a revolutionary
	for (var/_rev_mind in members)
		var/datum/mind/rev_mind = _rev_mind
		if (rev_mind.has_antag_datum(/datum/antagonist/rev))
			var/datum/antagonist/rev/rev_antag = rev_mind.has_antag_datum(/datum/antagonist/rev)
			rev_antag.remove_revolutionary(FALSE, . == STATION_VICTORY ? DECONVERTER_STATION_WIN : DECONVERTER_REVS_WIN)
			if(!(rev_mind in ex_headrevs))
				LAZYADD(rev_mind.special_statuses, "<span class='bad'>Former revolutionary</span>")
			else
				LAZYADD(rev_mind.special_statuses, "<span class='bad'>Former head revolutionary</span>")
				add_memory_in_range(rev_mind.current, 7, MEMORY_WON_REVOLUTION, list(DETAIL_PROTAGONIST = rev_mind.current, DETAIL_STATION_NAME = station_name()), story_value = STORY_VALUE_LEGENDARY, memory_flags = MEMORY_FLAG_NOSTATIONNAME|MEMORY_CHECK_BLIND_AND_DEAF, protagonist_memory_flags = MEMORY_FLAG_NOSTATIONNAME)

	if (. == STATION_VICTORY)
		// If the revolution was quelled, make rev heads unable to be revived through pods
		for (var/datum/mind/rev_head as anything in ex_headrevs)
			if(!isnull(rev_head.current))
				ADD_TRAIT(rev_head.current, TRAIT_DEFIB_BLACKLISTED, REF(src))
				rev_head.current.med_hud_set_status()

		priority_announce("It appears the mutiny has been quelled. Please return yourself and your incapacitated colleagues to work. \
		We have remotely blacklisted the head revolutionaries in your medical records to prevent accidental revival.", null, null, null, "Central Command Loyalty Monitoring Division")
	else
		for(var/datum/mind/headrev_mind as anything in ex_headrevs)
			if(charter_given)
				break
			if(!headrev_mind.current || headrev_mind.current.stat != CONSCIOUS)
				continue
			charter_given = TRUE
			podspawn(list(
				"target" = get_turf(headrev_mind.current),
				"style" = STYLE_SYNDICATE,
				"spawn" = /obj/item/station_charter/revolution,
			))
			to_chat(headrev_mind.current, span_hear("You hear something crackle in your ears for a moment before a voice speaks. \
				\"Please stand by for a message from your benefactor. Message as follows, provocateur. \
				<b>You have been chosen out of your fellow provocateurs to rename the station. Choose wisely.</b> Message ends.\""))
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_REVOLUTION_TAX_REMOVAL)

		for (var/mob/living/player as anything in GLOB.player_list)
			var/datum/mind/player_mind = player.mind

			if (isnull(player_mind))
				continue

			if (!(player_mind.assigned_role.departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY|DEPARTMENT_BITFLAG_COMMAND)))
				continue

			if (player_mind in ex_revs + ex_headrevs)
				continue

			player_mind.add_antag_datum(/datum/antagonist/enemy_of_the_revolution)

			if (!istype(player))
				continue

			if(player_mind.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
				ADD_TRAIT(player, TRAIT_DEFIB_BLACKLISTED, REF(src))
				player.med_hud_set_status()

		for(var/datum/job/job as anything in SSjob.joinable_occupations)
			if(!(job.departments_bitflags & (DEPARTMENT_BITFLAG_SECURITY|DEPARTMENT_BITFLAG_COMMAND)))
				continue
			job.allow_bureaucratic_error = FALSE
			job.total_positions = 0

		if (revs_win_injection_amount)
			var/datum/game_mode/dynamic/dynamic = SSticker.mode
			dynamic.unfavorable_situation()

		priority_announce("A recent assessment of your station has marked your station as a severe risk area for high ranking Nanotrasen officials. \
		For the safety of our staff, we have blacklisted your station for new employment of security and command. \
		[pick(world.file2list("strings/anti_union_propaganda.txt"))]", null, null, null, "Central Command Loyalty Monitoring Division")

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
		headrev_part += "<span class='header'>The head revolutionaries were:</span>"
		headrev_part += printplayerlist(headrevs, !check_rev_victory())
		result += headrev_part.Join("<br>")

	if(revs.len)
		var/list/rev_part = list()
		rev_part += "<span class='header'>The revolutionaries were:</span>"
		rev_part += printplayerlist(revs, !check_rev_victory())
		result += rev_part.Join("<br>")

	var/list/heads = SSjob.get_all_heads()
	if(heads.len)
		var/head_text = "<span class='header'>The heads of staff were:</span>"
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

	var/list/heads = get_team_antags(/datum/antagonist/rev/head,TRUE)

	for(var/datum/antagonist/A in heads | get_team_antags())
		parts += A.antag_listing_entry()

	parts += "</table>"
	parts += antag_listing_footer()
	common_part = parts.Join()

	var/heads_report = "<b>Heads of Staff</b><br>"
	heads_report += "<table cellspacing=5>"
	for(var/datum/mind/N in SSjob.get_living_heads())
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
	head = /obj/item/clothing/head/ushanka
	gloves = /obj/item/clothing/gloves/color/black
	l_hand = /obj/item/spear
	r_hand = /obj/item/assembly/flash

#undef DECONVERTER_STATION_WIN
#undef DECONVERTER_REVS_WIN
