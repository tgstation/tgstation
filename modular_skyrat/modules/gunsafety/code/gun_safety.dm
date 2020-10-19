//WATCH YOUR TRIGGER FINGER FRANK
/obj/item/gun
	var/safety = TRUE //Gun safties, togglable.
	var/datum/action/item_action/toggle_safety/tsafety

/obj/item/gun/Initialize()
	. = ..()
	tsafety = new(src)

/datum/action/item_action/toggle_safety
	name = "Toggle Safety"
	icon_icon = 'modular_skyrat/modules/gunsafety/icons/hud/actions.dmi'
	button_icon_state = "safety_on"

/obj/item/gun/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, tsafety))
		toggle_safety(user)
	else
		..()

/obj/item/gun/proc/toggle_safety(mob/user)
	safety = !safety
	tsafety.button_icon_state = "safety_[safety ? "on" : "off"]"
	tsafety.UpdateButtonIcon()
	playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
	user.visible_message("<span class='notice'>[user] toggles [src]'s safety [safety ? "<font color='#00ff15'>ON</span>" : "<font color='#ff0000'>OFF</span>"].",
	"<span class='notice'>You toggle [src]'s safety [safety ? "<font color='#00ff15'>ON</span>" : "<font color='#ff0000'>OFF</span>"].</span>")

/obj/item/gun/afterattack(atom/target, mob/living/user, flag, params)
	if(safety)
		to_chat(user, "<span class='warning'>The safety is on!</span>")
		return
	else
		. = ..()
		update_icon()

/obj/item/gun/examine(mob/user)
	. = ..()
	. += "The safety is [safety ? "<font color='#00ff15'>ON</span>" : "<font color='#ff0000'>OFF</span>"]."
