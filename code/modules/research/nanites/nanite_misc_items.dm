/obj/item/nanite_injector
	name = "nanite injector"
	desc = "Injects nanites into a host. FOR TESTING PURPOSES."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_remote"

/obj/item/nanite_injector/attack_self(mob/user)
	user.AddComponent(/datum/component/nanites, 150)