//If you're looking for spawners like ash walker eggs, check ghost_role_spawners.dm

///Wizard tower item
/obj/item/disk/design_disk/adv/knight_gear
	name = "Magic Disk of Smithing"

/obj/item/disk/design_disk/adv/knight_gear/Initialize(mapload)
	. = ..()
	var/datum/design/knight_armour/A = new
	var/datum/design/knight_helmet/H = new
	blueprints[1] = A
	blueprints[2] = H

//Free Golems

/obj/item/disk/design_disk/golem_shell
	name = "Golem Creation Disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"
	max_blueprints = 1

/obj/item/disk/design_disk/golem_shell/Initialize(mapload)
	. = ..()
	var/datum/design/golem_shell/G = new
	blueprints[1] = G

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 40000)
	build_path = /obj/item/golem_shell
	category = list("Imported")

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."
	var/shell_type = /obj/effect/mob_spawn/ghost_role/human/golem
	var/has_owner = FALSE //if the resulting golem obeys someone
	atom_size = WEIGHT_CLASS_BULKY

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	. = ..()
	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/sheet/iron = /datum/species/golem,
		/obj/item/stack/sheet/glass = /datum/species/golem/glass,
		/obj/item/stack/sheet/plasteel = /datum/species/golem/plasteel,
		/obj/item/stack/sheet/mineral/sandstone = /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/plasma = /datum/species/golem/plasma,
		/obj/item/stack/sheet/mineral/diamond = /datum/species/golem/diamond,
		/obj/item/stack/sheet/mineral/gold = /datum/species/golem/gold,
		/obj/item/stack/sheet/mineral/silver = /datum/species/golem/silver,
		/obj/item/stack/sheet/mineral/uranium = /datum/species/golem/uranium,
		/obj/item/stack/sheet/mineral/bananium = /datum/species/golem/bananium,
		/obj/item/stack/sheet/mineral/titanium = /datum/species/golem/titanium,
		/obj/item/stack/sheet/mineral/plastitanium = /datum/species/golem/plastitanium,
		/obj/item/stack/sheet/mineral/abductor = /datum/species/golem/alloy,
		/obj/item/stack/sheet/mineral/wood = /datum/species/golem/wood,
		/obj/item/stack/sheet/bluespace_crystal = /datum/species/golem/bluespace,
		/obj/item/stack/sheet/runed_metal = /datum/species/golem/runic,
		/obj/item/stack/medical/gauze = /datum/species/golem/cloth,
		/obj/item/stack/sheet/cloth = /datum/species/golem/cloth,
		/obj/item/stack/sheet/mineral/adamantine = /datum/species/golem/adamantine,
		/obj/item/stack/sheet/plastic = /datum/species/golem/plastic,
		/obj/item/stack/sheet/bronze = /datum/species/golem/bronze,
		/obj/item/stack/sheet/cardboard = /datum/species/golem/cardboard,
		/obj/item/stack/sheet/leather = /datum/species/golem/leather,
		/obj/item/stack/sheet/bone = /datum/species/golem/bone,
		/obj/item/stack/sheet/durathread = /datum/species/golem/durathread,
		/obj/item/stack/sheet/cotton/durathread = /datum/species/golem/durathread,
		/obj/item/stack/sheet/mineral/snow = /datum/species/golem/snow,
		/obj/item/stack/sheet/mineral/metal_hydrogen= /datum/species/golem/mhydrogen,
	)

	if(!istype(I, /obj/item/stack))
		return
	var/obj/item/stack/stuff_stack = I
	var/species = golem_shell_species_types[stuff_stack.merge_type]
	if(!species)
		to_chat(user, span_warning("You can't build a golem out of this kind of material!"))
		return
	if(!stuff_stack.use(10))
		to_chat(user, span_warning("You need at least ten sheets to finish a golem!"))
		return
	to_chat(user, span_notice("You finish up the golem shell with ten sheets of [stuff_stack]."))
	new shell_type(get_turf(src), species, user)
	qdel(src)

///made with xenobiology, the golem obeys its creator
/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	shell_type = /obj/effect/mob_spawn/ghost_role/human/golem/servant
