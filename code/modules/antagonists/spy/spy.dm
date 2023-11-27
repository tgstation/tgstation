/datum/antagonist/spy
	name = "\improper Spy"
	roundend_category = "spies"
	antagpanel_category = "Spy"
	job_rank = ROLE_SPY
	antag_moodlet = /datum/mood_event/focused
	hijack_speed = 1
	ui_name = "AntagInfoSpy"
	preview_outfit = /datum/outfit/spy

/datum/antagonist/spy/on_gain()
	. = ..()
	create_spy_uplink(owner.current)

/datum/antagonist/spy/proc/create_spy_uplink(mob/living/spy)
	var/spy_uplink_loc = spy.client?.prefs?.read_preference(/datum/preference/choiced/uplink_location)
	if(isnull(spy_uplink_loc) || spy_uplink_loc == UPLINK_IMPLANT)
		spy_uplink_loc = pick(UPLINK_PEN, UPLINK_PDA)

	var/obj/item/spy_uplink = spy.get_uplink_location(spy_uplink_loc)
	if(isnull(spy_uplink))
		// Back up case?
	else
		spy_uplink.AddComponent(/datum/component/spy_uplink, spy)

/datum/outfit/spy
	name = "Spy (Preview only)"

	uniform = /obj/item/clothing/under/color/black
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/balaclava
	shoes = /obj/item/clothing/shoes/jackboots
