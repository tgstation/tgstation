/obj/item/clothing/suit/costume/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it, but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)
	///How many times has this shirt been washed? (In an ideal world this is just the determinant of the transform matrix.)
	var/wash_count = 0

/obj/item/clothing/suit/costume/ianshirt/machine_wash(obj/machinery/washing_machine/washer)
	. = ..()
	if(wash_count <= 5)
		transform *= TRANSFORM_USING_VARIABLE(0.8, 1)
		washer.visible_message("[src] appears to have shrunken after being washed.")
		wash_count += 1
	else
		washer.visible_message("[src] implodes due to repeated washing.")
		qdel(src)

/obj/item/clothing/suit/costume/nerdshirt
	name = "gamer shirt"
	desc = "A baggy shirt with vintage game character Phanic the Weasel. Why would anyone wear this?"
	icon_state = "nerdshirt"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)
