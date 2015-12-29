/obj/item/weapon/gun/energy/gun/advtaser/mounted
	name = "mounted taser"
	desc = "An arm mounted dual-mode weapon that fires electrodes and disabler shots."
	icon_state = "armcannon"
	force = 5
	selfcharge = 1
	flags = NODROP
	slot_flags = null
	w_class = 5
	can_flashlight = 0

/obj/item/weapon/gun/energy/gun/advtaser/mounted/dropped()//if somebody manages to drop this somehow...
	src.loc = null//send it to nullspace to get retrieved by the implant later on. gotta cover those edge cases.

/obj/item/weapon/gun/energy/laser/mounted
	name = "mounted laser"
	desc = "An arm mounted cannon that fires lethal lasers. Doesn't come with a charge beam."
	icon_state = "armcannon"
	item_state = "armcannonlase"
	force = 5
	selfcharge = 1
	flags = NODROP
	slot_flags = null
	w_class = 5
	materials = null

/obj/item/weapon/gun/energy/laser/mounted/dropped()
	src.loc = null
