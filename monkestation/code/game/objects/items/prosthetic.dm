// Prosthetic Beacon//

/obj/item/choice_beacon/prosthetic
	name = "prosthetic replacement kit"
	desc = "All the prosthetics you could ever want. If you even wanted."

/obj/item/choice_beacon/prosthetic/generate_display_names()
	var/static/list/prosthetics
	if(!prosthetics)
		prosthetics = list()
		var/list/templist = list(
			/obj/item/bodypart/l_arm/robot,
			/obj/item/bodypart/r_arm/robot,
			/obj/item/bodypart/l_leg/robot,
			/obj/item/bodypart/r_leg/robot,
			/obj/item/bodypart/l_arm/robot/surplus,
			/obj/item/bodypart/r_arm/robot/surplus,
			/obj/item/bodypart/l_leg/robot/surplus,
			/obj/item/bodypart/r_leg/robot/surplus)
		for(var/object in templist)
			var/atom/our_atom = object
			prosthetics[initial(our_atom.name)] = our_atom
	return prosthetics

/obj/item/choice_beacon/prosthetic/spawn_option(obj/choice, mob/living/carbon/human/nerd) //Overwrite to instantly apply the prosthetic. No middleman here.
	var/obj/item/bodypart/new_item = new choice()
	new_item.replace_limb(nerd, TRUE)
	playsound(get_turf(nerd), 'sound/weapons/circsawhit.ogg', 50, 1)
