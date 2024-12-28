// The organ jar - a 150u bottle that can hold a single organ
/obj/item/reagent_containers/cup/organ_jar
	name = "organ jar"
	possible_transfer_amounts = list(10, 20, 30, 50, 150)
	// It's pretty big
	volume = 150
	icon_state = "organ_jar"
	fill_icon_state = "bottle"
	inhand_icon_state = "atoxinbottle"
	worn_icon_state = "bottle"
	var/obj/item/organ/held_organ = null

	var/mutable_appearance/organ_overlay

/obj/item/reagent_containers/cup/organ_jar/Initialize(mapload)
	. = ..()
	if(!icon_state)
		icon_state = "bottle"
	update_appearance()

// Alt click lets you take the organ out, if it's present
/obj/item/reagent_containers/cup/organ_jar/click_alt(mob/user)
	if(!isnull(held_organ))
		balloon_alert(user, "removed [held_organ]")
		user.put_in_hands(held_organ)
		held_organ = null
		name = "organ jar"
		update_appearance()
	else
		return ..()

// Clicking on the jar with an organ lets you put the organ inside, if there isn't one already
// Otherwise it should act like a normal bottle
/obj/item/reagent_containers/cup/organ_jar/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(istype(tool, /obj/item/organ))
		if(isnull(held_organ))
			if(!user.transferItemToLoc(tool, src))
				return ITEM_INTERACT_BLOCKING
			balloon_alert(user, "inserted [tool]")
			held_organ = tool
			name = "\improper [tool.name] in a jar"
			update_appearance()
		else
			balloon_alert(user, "the jar already contains [held_organ]")

#define JAR_INNER_ICON_SIZE 20

/obj/item/reagent_containers/cup/organ_jar/update_overlays()
	. = ..()
	// Put the organ icon inside the jar, if present
	if(!isnull(held_organ))
		// This code was mostly taken from the microwave overlay stuff
		var/image/organ_img = image(held_organ, src)
		var/list/icon_dimensions = get_icon_dimensions(held_organ.icon)
		organ_img.transform = organ_img.transform.Scale( // Make it smaller so it fits
			JAR_INNER_ICON_SIZE / icon_dimensions["width"],
			JAR_INNER_ICON_SIZE / icon_dimensions["height"],
		)
		organ_img.pixel_y -= 3
		//organ_overlay = mutable_appearance(held_organ.icon, held_organ.icon_state)
		. += organ_img

#undef JAR_INNER_ICON_SIZE
