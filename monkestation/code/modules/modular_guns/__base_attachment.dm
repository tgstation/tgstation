/obj/item/attachment
	name = "generic attachment"
	desc = "Weird how this got here huh."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'monkestation/code/modules/modular_guns/icons/ak.dmi'
	icon_state = "stock_wood"
	//here lies some variables we can tweak for each part

	///divisor to spread 1 is normal 0.5 is twice as unstable 2 is twice as stable
	var/stability = 1
	///fire multiplier
	var/fire_multipler = 1
	///noise multiplier multiplies the noise the gun makes
	var/noise_multiplier = 1
	///misfire multiplier
	var/misfire_multiplier = 1
	/// how much more cumbersome this is to use
	var/ease_of_use = 1
	///what gun type we can attach to
	var/attachment_rail = GUN_ATTACH_AK
	///what type of attachement are we ie what slot do we go in
	var/attachment_type
	///the icon_state our attachment adds
	var/attachment_icon_state = "stock_wood"
	///the icon of our attachment
	var/attachment_icon = 'monkestation/code/modules/modular_guns/icons/ak.dmi'
	///do we modify layer at all?
	var/layer_modifier = 0
	///how much we offset in y and x
	var/offset_y = 0
	var/offset_x = 0
	///special flags like colorable
	var/attachment_flags = NONE
	///the color of our attachment in hex
	var/attachment_color

/obj/item/attachment/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	SEND_SIGNAL(target, COMSIG_ATTACHMENT_ATTACH_ATTEMPT, user, target, src)

/obj/item/attachment/proc/unique_attachment_effects(obj/item/gun/modular)
	return

/obj/item/attachment/proc/unique_attachment_effects_removal(obj/item/gun/modular)
	return

/obj/item/attachment/proc/unique_attachment_effects_per_reset(obj/item/gun/modular)

/obj/item/attachment/AltClick(mob/user)
	. = ..()
	if(attachment_flags & ATTACHMENT_COLORABLE)
		var/new_choice = input(user,"","Choose Color",attachment_color) as color
		if(new_choice == null)
			return
		attachment_color = new_choice
		color = new_choice
