/obj/item/autosurgeon/toolset
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/toolset

/obj/item/autosurgeon/surgery
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/surgery

/obj/item/autosurgeon/botany
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/botany

/obj/item/autosurgeon/janitor
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/janitor

/obj/item/autosurgeon/muscle
	starting_organ = /obj/item/organ/internal/cyberimp/arm/muscle

//syndie

/obj/item/autosurgeon/syndicate/esword_arm
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/esword

/obj/item/autosurgeon/syndicate/nodrop
	starting_organ = /obj/item/organ/internal/cyberimp/brain/anti_drop

/obj/item/autosurgeon/syndicate/baton
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/baton

/obj/item/autosurgeon/syndicate/flash
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/flash

//xeno-organs
/obj/item/autosurgeon/xeno
	name = "strange autosurgeon"
	icon = 'monkestation/code/modules/blueshift/icons/alien.dmi'
	surgery_speed = 2
	organ_whitelist = list(/obj/item/organ/internal/alien)

/obj/item/organ/internal/alien/plasmavessel/opfor
	stored_plasma = 500
	max_plasma = 500
	plasma_rate = 10

/obj/item/storage/organbox/strange
	name = "strange organ transport box"
	icon = 'monkestation/code/modules/blueshift/icons/alien.dmi'

/obj/item/storage/organbox/strange/Initialize(mapload)
	. = ..()
	reagents.add_reagent_list(list(/datum/reagent/cryostylane = 60))

/obj/item/storage/organbox/strange/PopulateContents()
	new /obj/item/autosurgeon/xeno(src)
	new /obj/item/organ/internal/alien/plasmavessel/opfor(src)
	new /obj/item/organ/internal/alien/resinspinner(src)
	new /obj/item/organ/internal/alien/acid(src)
	new /obj/item/organ/internal/alien/neurotoxin(src)
	new /obj/item/organ/internal/alien/hivenode(src)

/obj/item/storage/organbox/strange/eggsac/PopulateContents()
	. = ..()
	new /obj/item/organ/internal/alien/eggsac(src)
