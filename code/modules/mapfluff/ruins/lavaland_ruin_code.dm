//If you're looking for spawners like ash walker eggs, check ghost_role_spawners.dm

///Wizard tower item
/obj/item/disk/design_disk/knight_gear
	name = "Magic Disk of Smithing"

/obj/item/disk/design_disk/knight_gear/Initialize(mapload)
	. = ..()
	blueprints += new /datum/design/knight_armour
	blueprints += new /datum/design/knight_helmet

//Free Golems

/obj/item/disk/design_disk/golem_shell
	name = "Golem Creation Disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"

/obj/item/disk/design_disk/golem_shell/Initialize(mapload)
	. = ..()
	blueprints += new /datum/design/golem_shell

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 40000)
	build_path = /obj/item/golem_shell
	category = list(RND_CATEGORY_IMPORTED)

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."
	w_class = WEIGHT_CLASS_BULKY

	var/shell_type = /obj/effect/mob_spawn/ghost_role/human/golem

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	. = ..()
	// TODO: replace with something

///made with xenobiology, the golem obeys its creator
/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	shell_type = /obj/effect/mob_spawn/ghost_role/human/golem/servant
