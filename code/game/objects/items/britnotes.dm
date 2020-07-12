/obj/item/britnotes
	name = "RD's Personal Tablet"
	desc = "It smells vaguely of plasma-burned hay."
	icon = 'icons/obj/modular_tablet.dmi'
	var/icon_state_unpowered = null
	var/icon_state_powered = null
	icon_state_unpowered = "tablet-blue"
	icon_state_powered = "tablet-secret"
	w_class = WEIGHT_CLASS_SMALL
	force = 0.1
	var/has_light = TRUE
	var/light_on = FALSE						//If that light is enabled
	var/comp_light_luminosity = 2.3				//The brightness of that light
	var/enabled = 0
	attack_verb = list("tapped", "slapped", "hit")
	var/password = "rose"

//wallem made this

/obj/item/britnotes/Initialize()
	. = ..()
	ask_for_pass()
	update_icon()
	update_icon_state()

/obj/item/britnotes/update_icon_state()
	if(!enabled)
		icon_state = icon_state_unpowered
	else
		icon_state = icon_state_powered

/obj/item/britnotes/attack_self(mob/user)
	add_fingerprint(user)
	. = ..()
	if(enabled)
		if(ask_for_pass(user))
			open()
	else
		to_chat(user, "<span class='notice'>You press the power button, the screen shining with a dim grey light.</span>")
		enabled = 1
	update_icon()
	update_icon_state()

/obj/item/britnotes/proc/ask_for_pass(mob/user)
	var/guess = stripped_input(user,"Please insert password:", "Password", "")
	if(guess == password)
		return TRUE
	return FALSE

/obj/item/britnotes/proc/open(mob/user)
	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		if(alert("If this doesn't open a new page, DM Wallem the word 'carcerem' in discord.",,"Ok","No")!="Ok")
			return
		usr << link(rulesurl)
	else
		to_chat(src, "<span class='danger'>The notes URL is not set in the server configuration.</span>")
	return




