/datum/antagonist/paradox_clone
	name = "\improper Paradox Clone"
	roundend_category = "Paradox Clone"
	job_rank = ROLE_PARADOX_CLONE
	prevent_roundtype_conversion = FALSE
	antag_hud_name = "paradox_clone"
	suicide_cry = "THERE CAN BE ONLY ONE!!"
	preview_outfit = /datum/outfit/paradox_clone
	count_against_dynamic_roll_chance = TRUE

	///Weakref to the clone's original, the target.
	var/datum/weakref/original_ref

/datum/antagonist/paradox_clone/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)

	final_icon.Blend(make_background_clone_icon(preview_outfit), ICON_UNDERLAY, -8, 0)

	final_icon.Scale(64, 64)

	return finish_preview_icon(final_icon)

/datum/antagonist/paradox_clone/proc/make_background_clone_icon(datum/outfit/clone_fit)
	var/mob/living/carbon/human/dummy/consistent/clone = new

	var/icon/clone_icon = render_preview_outfit(clone_fit, clone)
	clone_icon.ChangeOpacity(0.5)
	qdel(clone)

	return clone_icon

/datum/outfit/paradox_clone
	name = "Paradox Clone (Preview only)"

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/soft/purple

/datum/antagonist/paradox_clone/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/paradox_clone/Destroy()
	original_ref = null
	return ..()

/datum/antagonist/paradox_clone/proc/forge_objectives()

	if(!original_ref)//admins didn't set one
		original_ref = WEAKREF(find_original())
	if(!original_ref)//we didn't find one
		stack_trace("[src] was unable to find a target.")
		qdel(src)
		return

	var/datum/objective/assassinate/paradox_clone/kill = new
	kill.owner = owner
	kill.target = original_ref.resolve()
	kill.update_explanation_text()
	objectives += kill

/datum/antagonist/paradox_clone/proc/find_original()
	var/list/viable_minds = list()
	var/list/possible_targets = list() //filters out silicons and simplemobs
	var/chosen_victim  //The cloned player

	for(var/mob/living/carbon/human/player as anything in GLOB.player_list)//prevents cloning of non-crew
		if(!player.client || !player.mind || player.stat == DEAD)
			continue
		if(!(player.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		viable_minds += player.mind
	for(var/datum/mind/possible_target as anything in viable_minds)
		if(ishuman(possible_target.current))
			possible_targets += possible_target

	if(possible_targets.len > 0)
		chosen_victim = pick(possible_targets)
	return chosen_victim

/datum/objective/assassinate/paradox_clone
	name = "clone assassinate"

/datum/objective/assassinate/paradox_clone/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Murder and replace [target.name], the [!target_role_type ? target.assigned_role.title : target.special_role]. Remember, your mission is to blend in, do not kill anyone else unless you have to!"
	else
		message_admins("WARNING! [ADMIN_LOOKUPFLW(owner)] paradox clone objectives forged without an original!")
		explanation_text = "Free Objective"

/datum/antagonist/paradox_clone/roundend_report_header()
	return "<span class='header'>A paradox clone appeared on the station!</span><br>"

/datum/antagonist/paradox_clone/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("[type] antag datum found without an owner!")

	//roundend report
	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")
