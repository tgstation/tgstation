/obj/screen/mov_intent
	icon = 'modular_citadel/icons/ui/screen_midnight.dmi'

/obj/screen/sprintbutton
	name = "toggle sprint"
	icon = 'modular_citadel/icons/ui/screen_midnight.dmi'
	icon_state = "act_sprint"
	layer = ABOVE_HUD_LAYER - 0.1

/obj/screen/sprintbutton/Click()
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.togglesprint()

/obj/screen/sprintbutton/proc/insert_witty_toggle_joke_here(mob/living/carbon/human/H)
	if(!H)
		return
	if(H.sprinting)
		icon_state = "act_sprint_on"
	else
		icon_state = "act_sprint"

/obj/screen/restbutton
	name = "rest"
	icon = 'modular_citadel/icons/ui/screen_midnight.dmi'
	icon_state = "rest"

/obj/screen/restbutton/Click()
	if(isliving(usr))
		var/mob/living/theuser = usr
		theuser.lay_down()

/obj/screen/combattoggle
	name = "toggle combat mode"
	icon = 'modular_citadel/icons/ui/screen_midnight.dmi'
	icon_state = "combat_off"

/obj/screen/combattoggle/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_combat_mode()

/obj/screen/combattoggle/proc/rebasetointerbay(mob/living/carbon/C)
	if(!C)
		return
	if(C.combatmode)
		icon_state = "combat"
	else
		icon_state = "combat_off"
