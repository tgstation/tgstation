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
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*20)
	build_path = /obj/item/golem_shell
	category = list(RND_CATEGORY_IMPORTED)

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/mob/shells.dmi'
	icon_state = "shell_unfinished"
	desc = "The incomplete body of a golem. Add ten sheets of certain minerals to finish."
	w_class = WEIGHT_CLASS_BULKY
	/// Amount of minerals you need to feed the shell to wake it up
	var/required_stacks = 10
	/// Type of shell to create
	var/shell_type = /obj/effect/mob_spawn/ghost_role/human/golem

/obj/item/golem_shell/attackby(obj/item/potential_food, mob/user, params)
	. = ..()
	if(!isstack(potential_food))
		balloon_alert(user, "not a mineral!")
		return
	var/obj/item/stack/stack_food = potential_food
	var/stack_type = stack_food.merge_type
	if (!is_path_in_list(stack_type, GLOB.golem_stack_food_directory))
		balloon_alert(user, "incompatible mineral!")
		return
	if(stack_food.amount < required_stacks)
		balloon_alert(user, "not enough minerals!")
		return
	if(!do_after(user, delay = 4 SECONDS, target = src))
		return
	if(!stack_food.use(required_stacks))
		balloon_alert(user, "not enough minerals!")
		return
	new shell_type(get_turf(src), /* creator = */ user, /* made_of = */ stack_type)
	qdel(src)

///made with xenobiology, the golem obeys its creator
/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	shell_type = /obj/effect/mob_spawn/ghost_role/human/golem/servant
