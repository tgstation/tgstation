/atom/movable/screen/human
	icon = 'icons/hud/screen_midnight.dmi'

/atom/movable/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"
	base_icon_state = "toggle"
	mouse_over_pointer = MOUSE_HAND_POINTER
	screen_loc = ui_inventory

/atom/movable/screen/human/toggle/Click()
	var/mob/targetmob = usr

	if(isobserver(usr))
		if(ishuman(usr.client.eye) && (usr.client.eye != usr))
			var/mob/M = usr.client.eye
			targetmob = M

	if(usr.hud_used.inventory_shown && targetmob.hud_used)
		usr.hud_used.inventory_shown = FALSE
		usr.client.screen -= targetmob.hud_used.screen_groups[HUD_GROUP_TOGGLEABLE_INVENTORY]
	else
		usr.hud_used.inventory_shown = TRUE
		usr.client.screen += targetmob.hud_used.screen_groups[HUD_GROUP_TOGGLEABLE_INVENTORY]

	targetmob.hud_used.hidden_inventory_update(usr)
	update_appearance()

/atom/movable/screen/human/toggle/update_icon_state()
	icon_state = "[base_icon_state][hud?.inventory_shown ? "_active" : ""]"
	return ..()

/atom/movable/screen/ling
	icon = 'icons/hud/screen_changeling.dmi'

/atom/movable/screen/ling/chems
	name = "chemical storage"
	icon_state = "power_display"
	screen_loc = ui_lingchemdisplay

/atom/movable/screen/ling/sting
	name = "current sting"
	screen_loc = ui_lingstingdisplay
	invisibility = INVISIBILITY_ABSTRACT
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/ling/sting/Click()
	if(isobserver(usr))
		return
	var/mob/living/carbon/carbon_user = usr
	carbon_user.unset_sting()
