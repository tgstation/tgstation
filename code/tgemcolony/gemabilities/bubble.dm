/datum/action/innate/gem/bubble
	name = "Bubble Gem"
	desc = "Prevent a gem from reforming by trapping them in a bubble"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "healingtears"
	background_icon_state = "bg_spell"

/datum/action/innate/gem/bubble/Activate()
	if(istype(owner, /mob/living/carbon))
		var/mob/living/carbon/C = owner
		var/obj/item/O = C.get_active_held_item()
		if(O != null)
			if(istype(O,/obj/item/gem)) //LET'S GET BUBBLING
				var/obj/item/gem/G = O
				if(G.bubbled == FALSE)
					G.bubbled = TRUE
					G.icon_state = "[G.baseicon]bubbled"
					C.visible_message("<span class='danger'>[C] bubbles [G]!</span>")