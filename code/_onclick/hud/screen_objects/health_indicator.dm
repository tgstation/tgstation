/obj/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health

/obj/screen/healths/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_alien_health

/obj/screen/healths/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_health

/obj/screen/healths/blob
	name = "blob health"
	icon_state = "block"
	screen_loc = ui_internal
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/blob/naut
	name = "health"
	icon = 'icons/mob/blob.dmi'
	icon_state = "nauthealth"

/obj/screen/healths/blob/naut/core
	name = "overmind health"
	screen_loc = ui_health
	icon_state = "corehealth"

/obj/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/clock
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_clock"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/clock/gear
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "bg_gear"
	screen_loc = ui_internal

/obj/screen/healths/revenant
	name = "essence"
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_revenant"
	screen_loc = ui_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/construct
	icon = 'icons/mob/screen_construct.dmi'
	icon_state = "artificer_health0"
	screen_loc = ui_construct_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healthdoll
	name = "health doll"
	screen_loc = ui_healthdoll
