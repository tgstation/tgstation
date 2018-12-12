/obj/item/etherealballdeployer
	name = "Portable Ethereal Disco Ball"
	desc = "Press the button for a deployment of PARTY!"
	icon = 'icons/obj/etherealball.dmi'
	icon_state = "ethdisc_carry"

/obj/item/etherealballdeployer/attack_self(mob/living/carbon/user)
	new /obj/structure/etherealball(user.loc)
	qdel(src)

/obj/structure/etherealball
	name = "Ethereal Disco Ball"
	desc = "The ethics of this discoball are questionable. Be sure to feed it snacks or else it might turn off!"
	icon = 'icons/obj/etherealball.dmi'
	icon_state = "ethdisco_head_0"
	anchored = TRUE
	density = TRUE
	var/TurnedOn = FALSE
	var/current_color
	var/TimerID

/obj/structure/etherealball/Initialize()
	. = ..()
	update_icon()

/obj/structure/etherealball/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(!ishuman(user))
		return //Bish we only play human
	var/mob/living/carbon/human/coolperson = user
	if(!(coolperson.ckey == "qustinnus" || coolperson.ckey == "mrdoombringer"))

		to_chat(user, "<span class='notice'>Hello buddy, sorry, only cool people can turn the Ethereal Ball 3000 on or off, you can feed it or give it water, though!</span>")
		return
	if(TurnedOn)
		TurnOff()
		to_chat(user, "<span class='notice'>You turn the disco ball off!</span>")
	else
		TurnOn()
		to_chat(user, "<span class='notice'>You turn the disco ball on!</span>")

/obj/structure/etherealball/proc/TurnOn()
	TurnedOn = TRUE //Same
	DiscoFever()
	anchored = TRUE

/obj/structure/etherealball/proc/TurnOff()
	TurnedOn = FALSE
	set_light(0)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	update_icon()
	anchored = FALSE

/obj/structure/etherealball/proc/DiscoFever()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	current_color = random_color()
	set_light(4, 3, current_color)
	add_atom_colour("#[current_color]", FIXED_COLOUR_PRIORITY)
	update_icon()
	TimerID = addtimer(CALLBACK(src, .proc/DiscoFever), 5, TIMER_STOPPABLE)  //Call ourselves every 0.5 seconds to change colors

/obj/structure/etherealball/update_icon()
	cut_overlays()
	icon_state = "ethdisco_head_[TurnedOn]"
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "ethdisco_base")
	base_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)
