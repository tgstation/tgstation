/datum/antagonist/handofgod
	name = "Hand of God"
	roundend_category = "hands of god"
	antagpanel_category = "Hand of God"
	job_rank = ROLE_ALIEN
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE

/datum/antagonist/handofgod/greet()
	to_chat(owner, "<b>Let them eat meat.</b>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/demon_attack1.ogg'))

/datum/antagonist/handofgod/proc/forge_objectives()
	var/datum/objective/feed_people/foodobj = new()
	foodobj.hand = src
	foodobj.completed = TRUE
	objectives += foodobj

/datum/antagonist/handofgod/on_gain()
	forge_objectives()
	. = ..()
	
/datum/objective/feed_people
	var/datum/antagonist/handofgod/hand
	explanation_text = "Let them eat meat."
	
/datum/antagonist/handofgod/roundend_report()
	var/list/parts = list()
	parts += "<span class='redtext big'>The [name] has succeeded!</span>"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
