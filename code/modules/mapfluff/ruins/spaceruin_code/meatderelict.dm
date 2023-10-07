/obj/item/keycard/meatderelict/final
	name = "bloody keycard"
	desc = "A keycard covered in chunks of blood and meat. Swallowed, or was the thing you killed a formerly a person? Looks important."
	color = "#990000"
	puzzle_id = "md_vault"

/obj/item/keycard/meatderelict/director
	name = "directors keycard"
	desc = "A fancy keycard. Likely unlocks the directors office. The name tag is all smudged."
	color = "#990000"
	puzzle_id = "md_director"

/obj/item/paper/crumpled/bloody/fluff/meatderelict/directoroffice
	name = "directors note"
	default_raw_text = "<i>The research was going smooth... but the experiment did not go as planned. He squirmed and screamed as he slowly mutated into.. that thing. It started to spread everywhere, outside the lab too. There is no way we can cover up that we are not a teleport research outpost. I locked down the lab, but they already know. They sent a squad to rescue us, but...</i>"

/obj/machinery/door/puzzle/light/meatderelict
	name = "lockdown door"
	desc = "A beaten door, still sturdy. Impervious to conventional methods of destruction, must be a way to open it nearby."
	base_icon_state = "danger"
	icon_state = "danger_closed"

/mob/living/basic/meteor_heart/drops_card
	death_loot = list(/obj/effect/temp_visual/meteor_heart_death, /obj/item/keycard/meatderelict/final)

/obj/machinery/derelict_lockdown
	name = "lockdown panel"
	desc = "A panel that controls the lockdown of this outpost."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "lockdown0"
	base_icon_state = "lockdown"
	var/used = FALSE
	var/id = "md_prevault"

/obj/machinery/derelict_lockdown/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(used)
		return
	used = TRUE
	update_icon_state()
	playsound(src, 'sound/effects/alert.ogg', 100, TRUE)
	visible_message(span_warning("[src] lets out an alarm as the lockdown is lifted!"))
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_LIGHT_MECHANISM_COMPLETED, id) //gonna use this signal anyway because range sucks and im going to probably refactor puzzle stuff or goof does it anyway

/obj/machinery/derelict_lockdown/update_icon_state()
	icon_state = "[base_icon_state][used]"
	return ..()
