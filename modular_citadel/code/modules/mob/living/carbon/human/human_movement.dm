/mob/living/carbon/human
	var/sprinting = FALSE

/mob/living/carbon/human/Move(NewLoc, direct)
	var/oldpseudoheight = pseudo_z_axis
	. = ..()
	if(. && sprinting && !(movement_type & FLYING) && canmove && !resting && m_intent == MOVE_INTENT_RUN)
		adjustStaminaLossBuffered(0.3)
		if((oldpseudoheight - pseudo_z_axis) >= 8)
			to_chat(src, "<span class='warning'>You trip off of the elevated surface!</span>")
			for(var/obj/item/I in held_items)
				accident(I)
			Knockdown(80)

/mob/living/carbon/human/movement_delay()
	. = 0
	if(!resting && m_intent == MOVE_INTENT_RUN && !sprinting)
		. += 1
	if(wrongdirmovedelay)
		. += 1
	. += ..()

/mob/living/carbon/human/proc/togglesprint() // If you call this proc outside of hotkeys or clicking the HUD button, I'll be disappointed in you.
	sprinting = !sprinting
	if(!resting && m_intent == MOVE_INTENT_RUN && canmove)
		if(sprinting)
			playsound_local(src, 'modular_citadel/sound/misc/sprintactivate.ogg', 50, FALSE, pressure_affected = FALSE)
		else
			playsound_local(src, 'modular_citadel/sound/misc/sprintdeactivate.ogg', 50, FALSE, pressure_affected = FALSE)
	if(hud_used && hud_used.static_inventory)
		for(var/obj/screen/sprintbutton/selector in hud_used.static_inventory)
			selector.insert_witty_toggle_joke_here(src)
	return TRUE
