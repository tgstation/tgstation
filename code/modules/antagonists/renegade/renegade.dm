/datum/antagonist/renegade
	name = "Renegade"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	job_rank = ROLE_RENEGADE
	antag_hud_name = "renegade"
	show_name_in_check_antagonists = TRUE
	roundend_category = "renegade"
	count_against_dynamic_roll_chance = FALSE
	silent = TRUE //not actually silent, because greet will be called by the trauma anyway.
	suicide_cry = "FOR MY SAFETY!!"
	preview_outfit = /datum/outfit/renegade
	var/datum/brain_trauma/special/renegade/trauma

/datum/antagonist/renegade/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		to_chat(admin, "[roundend_category] come from a brain trauma, so they need to at least be a carbon!")
		return
	if(!C.get_organ_by_type(/obj/item/organ/internal/brain)) // If only I had a brain
		to_chat(admin, "[roundend_category] come from a brain trauma, so they need to HAVE A BRAIN.")
		return
	message_admins("[key_name_admin(admin)] made [key_name_admin(new_owner)] into [name].")
	log_admin("[key_name(admin)] made [key_name(new_owner)] into [name].")
	//PRESTO FUCKIN MAJESTO
	C.gain_trauma(/datum/brain_trauma/special/renegade)//ZAP

/datum/antagonist/renegade/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/renegade.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	owner.announce_objectives()
	to_chat(owner, span_boldannounce("As a Renegade you're a secondary antagonist! You are allowed to escalate when there is any threat to your life, protecting it by any means! But you're not a murderer, you're just extremely scared for your life and paranoid of your surroundings."))

/datum/antagonist/renegade/Destroy()
	if(trauma)
		qdel(trauma)
	. = ..()

/datum/antagonist/renegade/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/victim_dummy = new
	victim_dummy.hair_color = "#bb9966" // Brown
	victim_dummy.hairstyle = "Messy"
	victim_dummy.update_body_parts()

	var/icon/renegade_icon = render_preview_outfit(preview_outfit)
	renegade_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)

	var/icon/final_icon = finish_preview_icon(renegade_icon)

	return final_icon

/datum/outfit/renegade
	name = "Renegade (Preview only)"

	uniform = /obj/item/clothing/under/rank/rnd/scientist
	head = /obj/item/clothing/head/helmet/sec
	gloves = /obj/item/clothing/gloves/latex
	suit = /obj/item/clothing/suit/armor/vest
	r_hand = /obj/item/gun/ballistic/automatic/pistol

/datum/outfit/renegade/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(TRUE))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	H.regenerate_icons()

/datum/antagonist/renegade/forge_objectives(datum/mind/renegademind)
	var/datum/objective/survive/survive = new
	survive.explanation_text = "Survive by any means possible, even if it means someone must be hurt! Whatever it takes you must do it, everyone around are totally plotting against you!"
	survive.owner = owner
	objectives += survive

/datum/antagonist/renegade/roundend_report_header()
	return "<span class='header'>Someone became paranoid!</span><br>"

/datum/antagonist/renegade/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(trauma)
		if(trauma.total_time_armed > 0)
			report += span_greentext("The [name] spent a total of [DisplayTimeText(trauma.total_time_armed)] armed!")
		else
			report += span_redtext("The [name] was paranoid without ever getting armed to protect himself!")
	else
		report += span_redtext("The [name] had no trauma attached to their antagonist ways! Either it bugged out or an admin incorrectly gave this good samaritan antag and it broke! You might as well show yourself!!")

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] did survive!</span>"
	else
		report += "<span class='redtext big'>The [name] has died!</span>"

	return report.Join("<br>")
