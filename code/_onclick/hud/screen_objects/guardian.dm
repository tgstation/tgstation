/atom/movable/screen/guardian
	icon = 'icons/hud/guardian.dmi'
	mouse_over_pointer = MOUSE_HAND_POINTER

/atom/movable/screen/guardian/manifest
	name = "Manifest"
	desc = "Spring forth into battle!"
	icon_state = "manifest"

/atom/movable/screen/guardian/manifest/Click()
	if(isguardian(usr))
		var/mob/living/basic/guardian/user = usr
		user.manifest()

/atom/movable/screen/guardian/recall
	name = "Recall"
	desc = "Return to your user."
	icon_state = "recall"

/atom/movable/screen/guardian/recall/Click()
	if(isguardian(usr))
		var/mob/living/basic/guardian/user = usr
		user.recall()

/atom/movable/screen/guardian/toggle_mode
	name = "Toggle Mode"
	desc = "Switch between ability modes."
	icon_state = "toggle"

/atom/movable/screen/guardian/toggle_mode/Click()
	if(isguardian(usr))
		var/mob/living/basic/guardian/user = usr
		user.toggle_modes()

/atom/movable/screen/guardian/toggle_mode/inactive
	icon_state = "notoggle" //greyed out so it doesn't look like it'll work

/atom/movable/screen/guardian/toggle_mode/assassin
	name = "Toggle Stealth"
	desc = "Enter or exit stealth."
	icon_state = "stealth"

/atom/movable/screen/guardian/toggle_mode/gases
	name = "Toggle Gas"
	desc = "Switch between possible gases."
	icon_state = "gases"

/atom/movable/screen/guardian/communicate
	name = "Communicate"
	desc = "Communicate telepathically with your user."
	icon_state = "communicate"
	screen_loc = ui_back

/atom/movable/screen/guardian/communicate/Click()
	if(isguardian(usr))
		var/mob/living/basic/guardian/user = usr
		user.communicate()

/atom/movable/screen/guardian/toggle_light
	name = "Toggle Light"
	desc = "Glow like star dust."
	icon_state = "light"
	screen_loc = ui_inventory

/atom/movable/screen/guardian/toggle_light/Click()
	if(isguardian(usr))
		var/mob/living/basic/guardian/user = usr
		user.toggle_light()
