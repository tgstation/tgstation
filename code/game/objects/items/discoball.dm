/obj/item/etherealballdeployer
	name = "Portable Ethereal Disco Ball"
	desc = "Press the button for a deployment of PARTY!"
	icon = 'icons/mob/human_parts.dmi'
	icon_state = "ethereal_head_m"

/obj/item/etherealballdeployer/attack_self(mob/living/carbon/user)
	new /obj/structure/etherealball(user.loc)
	qdel(src)

/obj/structure/etherealball
	name = "Ethereal Disco Ball"
	desc = "The ethics of this discoball are questionable. Be sure to feed it snacks or else it might turn off!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "ethdisco_head"
	anchored = TRUE
	density = TRUE
	var/TurnedOn = FALSE
	var/current_color
	var/TimerID
	
/obj/structure/etherealball/Initialize()
	. = ..()
	update_icon()

/obj/structure/etherealball/attack_hand(mob/user)
	. = ..()
	if(!ishuman(user))
		return //Bish we only play human
	var/mob/living/carbon/human/coolperson = user
	if(coolperson.ckey != "Qustinnus" || coolperson.ckey != "MrDoomBringer")
		to_chat("Hello buddy, sorry, only cool people can turn the Ethereal Ball 3000 on or off, you can feed it or give it water, though!")
		return
	if(TurnedOn)
		TurnOff()
		to_chat("You turn the disco ball off!")
	else
		TurnOn()
		to_chat("You turn the disco ball on!")

/obj/structure/etherealball/proc/TurnOn()
	TurnedOn = TRUE //Same
	DiscoFever()

/obj/structure/etherealball/proc/TurnOff()
	TurnedOn = FALSE
	set_light(0)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY,current_color)
	if(TimerID)
		deltimer(TimerID)

/obj/structure/etherealball/proc/DiscoFever()
	if(current_color)
		remove_atom_colour(TEMPORARY_COLOUR_PRIORITY,current_color)
	current_color = random_color()
	set_light(4, 3, current_color)
	add_atom_colour(current_color, TEMPORARY_COLOUR_PRIORITY)
	TimerID = addtimer(CALLBACK(src, .proc/DiscoFever), 5, TIMER_STOPPABLE)  //Call ourselves every 0.5 seconds to change colors

/obj/item/wirecutters/update_icon()
	cut_overlays()
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "ethdisco_base")
	var/mutable_appearance/glass_overlay = mutable_appearance(icon, "ethdisco_glass")
	base_overlay.appearance_flags = RESET_COLOR
	glass_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)
	add_overlay(glass_overlay)
