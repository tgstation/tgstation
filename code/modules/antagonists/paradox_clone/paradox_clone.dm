/datum/antagonist/paradox_clone
	name = "\improper Paradox Clone"
	roundend_category = "Paradox Clone"
	job_rank = ROLE_PARADOX_CLONE
	prevent_roundtype_conversion = FALSE
	antag_hud_name = "paradox_clone"
	suicide_cry = "FOR ME!!"
	preview_outfit = /datum/outfit/paradox_clone
	count_against_dynamic_roll_chance = TRUE
	//our target
	var/datum/mind/original

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

	uniform = /obj/item/clothing/under/misc/overalls
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	neck = /obj/item/camera
	suit = /obj/item/clothing/suit/apron

/datum/antagonist/paradox_clone/on_gain()
	forge_objectives(original)
	. = ..()

/datum/antagonist/paradox_clone/proc/forge_objectives(datum/mind/original)
	var/datum/objective/assassinate/paradox_clone/kill = new
	kill.owner = owner
	kill.target = original
	kill.explanation_text = "Kill your counterpart and take their place."
	objectives += kill

	if(!original)//admins didn't set one
		original = find_original()
		if(!original)//we didn't find one
			qdel(src)
			return

/datum/antagonist/paradox_clone/proc/find_original()
	var/list/viable_minds = list() //The first list, which excludes hijinks
	var/list/possible_targets = list() //The second list, which filters out silicons and simplemobs
	var/chosen_victim  //The obsession target

	for(var/mob/player as anything in GLOB.player_list)//prevents crew members falling in love with nuke ops they never met, and other annoying hijinks
		if(!player.client || !player.mind || isnewplayer(player) || player.stat == DEAD || isbrain(player) || player == owner)
			continue
		if(!(player.mind.assigned_role.job_flags & JOB_CREW_MEMBER))
			continue
		viable_minds += player.mind
	for(var/datum/mind/possible_target as anything in viable_minds)
		if(possible_target != owner && ishuman(possible_target.current))
			possible_targets += possible_target.current

	if(possible_targets.len > 0)
		chosen_victim = pick(possible_targets)
	return chosen_victim

/datum/objective/assassinate/paradox_clone

/datum/objective/assassinate/paradox_clone/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Murder [target.name], the [!target_role_type ? target.assigned_role.title : target.special_role]."
	else
		message_admins("WARNING! [ADMIN_LOOKUPFLW(owner)] paradox clone objectives forged without an original!")
		explanation_text = "Free Objective"

/datum/antagonist/paradox_clone/roundend_report_header()
	return "<span class='header'>A paradox clone appeared on the station!</span><br>"

/datum/antagonist/paradox_clone/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

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
