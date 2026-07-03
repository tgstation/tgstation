/datum/antagonist/blood_worm
	name = "\improper Кровяной червь"
	roundend_category = "blood worms"
	antagpanel_category = ANTAG_GROUP_BLOODY
	pref_flag = ROLE_BLOOD_WORM
	antag_hud_name = "blood_worm"
	antag_moodlet = /datum/mood_event/blood_worm
	hijack_speed = 0.5
	show_to_ghosts = TRUE // I mean let's be honest, even the roundstart versions will become painfully apparent soon enough.
	stinger_sound = 'sound/effects/magic/exit_blood.ogg'
	ui_name = "AntagInfoBloodWorm"

	var/datum/team/blood_worm/team = null

/datum/antagonist/blood_worm/Destroy()
	team = null
	return ..()

/datum/antagonist/blood_worm/greet()
	. = ..()

	to_chat(owner, span_bold("Разновидность космических пиявок огромных размеров, известных своей свирепостью при охоте.\
							Большинству неизвестно ваше происхождение, но для некоторых вы являетесь одним из их величайших творений.\
							Неудачный проект биологического оружия Синдиката, закрытый покровителями из-за 'отсутствия результатов', и всё же...\
							Вы обнаруживаете себя на космической станции Нанотрейзен. Прекрасная среда обитания, не правда ли?"))
	to_chat(owner, span_bolddanger("УБЕЙ, ПОГЛОТИ, РАЗМНОЖЬСЯ, ЗАХВАТИ."))

	owner.announce_objectives()

/datum/antagonist/blood_worm/forge_objectives()
	objectives |= team.objectives

/datum/antagonist/blood_worm/create_team(datum/team/new_team)
	GLOB.blood_worm_team ||= new()
	team = GLOB.blood_worm_team

/datum/antagonist/blood_worm/get_team()
	return team

/datum/antagonist/blood_worm/on_gain()
	forge_objectives()
	ADD_TRAIT(owner, TRAIT_UNCONVERTABLE, REF(src)) // No blood cultist worms or whatever the fuck
	return ..()

/datum/antagonist/blood_worm/on_removal()
	REMOVE_TRAITS_IN(owner, REF(src))
	return ..()

/datum/antagonist/blood_worm/apply_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current

	add_team_hud(target)

	if (!istype(target, /mob/living/basic/blood_worm))
		target.add_faction(FACTION_BLOOD_WORM)

	// Apathy and fearlessness are traits inherent to the very mind of a blood worm.
	// Being immune to hunger, withdrawals, etc. are physical traits of blood worm hosts.
	target.add_traits(list(TRAIT_APATHETIC, TRAIT_FEARLESS), REF(src))

/datum/antagonist/blood_worm/remove_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current

	if (!istype(target, /mob/living/basic/blood_worm))
		target.remove_faction(FACTION_BLOOD_WORM)

	REMOVE_TRAITS_IN(target, REF(src))

/datum/antagonist/blood_worm/admin_add(datum/mind/new_owner, mob/admin)
	if (!new_owner.current)
		return

	if (!istype(new_owner.current, /mob/living/basic/blood_worm))
		var/old_mob = new_owner.current

		var/mob/living/basic/blood_worm/hatchling/new_worm = new(get_turf(new_owner.current))
		new_owner.transfer_to(new_worm, force_key_move = TRUE)

		qdel(old_mob)

	return ..()

/datum/antagonist/blood_worm/get_preview_icon()
	var/datum/universal_icon/icon = uni_icon('icons/mob/nonhuman-player/blood_worm_32x32.dmi', "juvenile")

	icon.crop(1, 1, 32, 32)
	icon.shift(SOUTH, 4)
	icon.scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return icon

/datum/antagonist/blood_worm/ui_static_data(mob/user)
	. = ..()
	var/list/team_data = list()
	team_data["blood_consumed_total"] = floor(team.blood_consumed_total)
	team_data["times_reproduced_total"] = floor(team.times_reproduced_total)
	.["team"] = team_data

/datum/antagonist/blood_worm/infestation
	pref_flag = ROLE_BLOOD_WORM_INFESTATION
	jobban_flag = ROLE_BLOOD_WORM
	show_in_antagpanel = FALSE
