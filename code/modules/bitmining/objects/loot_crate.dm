/obj/structure/closet/crate/bitminer_locked
	name = "Encrypted Loot Crate"
	desc = "Needs delivered back station side to be opened."

/obj/structure/closet/crate/bitminer_locked/open(mob/living/user, force, special_effects)
	balloon_alert(user, "encrypted! deliver it first.")
	return

/obj/structure/closet/crate/bitminer_unlocked
	name = "Decrypted Loot Crate"
	desc = "Materialized from the virtual domain. The reward of a successful bitminer."

/obj/structure/closet/crate/bitminer_loot/Initialize(mapload, datum/map_template/virtual_domain/completed_domain)
	. = ..()
	playsound(src, 'sound/magic/blink.ogg')

	if(!completed_domain)
		return

	SEND_SIGNAL(src, COMSIG_CLOSET_POPULATE_CONTENTS) // probably don't need this
	var/list/paths = completed_domain.extra_loot
	for(var/path in paths)
		new path()

	new /obj/item/stack/ore/iron()
	new /obj/item/stack/ore/glass()
	new /obj/item/stack/ore/plasma()

	if(completed_domain.difficulty > 1)
		new /obj/item/stack/ore/silver()
		new /obj/item/stack/ore/gold()
		new /obj/item/stack/ore/titanium()

	if(completed_domain.difficulty > 2)
		new /obj/item/stack/ore/uranium()
		new /obj/item/stack/ore/bluespace_crystal()
		new /obj/item/stack/ore/diamond()
