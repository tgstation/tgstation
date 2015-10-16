 //Suits for the pink and grey skeletons!

//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/hardsuit/plasmaman
	name = "plasmaman helmet"
	desc = "A special containment helmet designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	icon_state = "plasmaman_helmet0-plasma"
	item_color = "plasma" //needed for the helmet lighting
	item_state = "plasmaman_helmet0"
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE | THICKMATERIAL
	strip_delay = 80
	//Removed the NODROP from /helmet/space/hardsuit.
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	//Removed the HIDEFACE from /helmet/space/hardsuit
	basestate = "plasmaman_helmet"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

