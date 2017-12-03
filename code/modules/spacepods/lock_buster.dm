/obj/item/device/lock_buster
	name = "pod lock buster"
	desc = "Destroys a podlock in mere seconds once applied. Waranty void if used."
	icon_state = "lock_buster_off"
	var/on = FALSE

/obj/item/device/lock_buster/attack_self(mob/user)
	on = !on
	if(on)
		icon_state = "lock_buster_on"
	else
		icon_state = "lock_buster_off"
	to_chat(user, "<span class='notice'>You turn the [src] [on ? "on" : "off"].</span>")