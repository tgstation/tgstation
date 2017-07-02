/*

Contents:
- Procs that add ninja verbs to ninjas
- Procs that remove ninja verbs from ninjas
- Procs that add ninjasuit verbs to ninjas
- Procs that remove ninjasuit verbs from ninjas

*/

/obj/item/clothing/suit/space/space_ninja/proc/grant_equip_verbs()
	n_gloves.verbs += /obj/item/clothing/gloves/space_ninja/proc/toggledrain

	s_initialized = 1


/obj/item/clothing/suit/space/space_ninja/proc/remove_equip_verbs()
	if(n_gloves)
		n_gloves.verbs -= /obj/item/clothing/gloves/space_ninja/proc/toggledrain

	s_initialized = 0


/obj/item/clothing/suit/space/space_ninja/proc/grant_ninja_verbs()
	verbs += /obj/item/clothing/suit/space/space_ninja/proc/ninjashift

	s_initialized=1
	slowdown=0


/obj/item/clothing/suit/space/space_ninja/proc/remove_ninja_verbs()
	verbs -= /obj/item/clothing/suit/space/space_ninja/proc/ninjashift
