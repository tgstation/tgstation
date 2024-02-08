//also yes yes I know it goes at the back of a pistol
/obj/item/attachment/underbarrel/mk_58/makeshift/illegal_switch
	name = "illegal mk58 switch"
	desc = "You are certainly going to jail for this one."

	icon_state = "makeshift_switch"
	attachment_icon_state = "makeshift_switch"

	ease_of_use = 0.1 //lol
	noise_multiplier = 1.4
	stability = 0.01
	misfire_multiplier = 9

/obj/item/attachment/underbarrel/mk_58/makeshift/illegal_switch/unique_attachment_effects_per_reset(obj/item/gun/modular)
	modular.burst_size = 9
	modular.fire_delay = 1
	modular.w_class = WEIGHT_CLASS_BULKY


/obj/item/attachment/underbarrel/mk_58/makeshift/illegal_switch/unique_attachment_effects_removal(obj/item/gun/modular)
	modular.burst_size = initial(modular.burst_size)
	modular.fire_delay = initial(modular.fire_delay)
	modular.w_class = WEIGHT_CLASS_NORMAL
