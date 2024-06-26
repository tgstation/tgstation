/obj/structure/table/optable/tablepush(mob/living/user, mob/living/pushed_mob)
	. = ..()
	buckle_mob(pushed_mob)

/obj/structure/table/sandstone
	name = "sandstone table"
	desc = "Woah! A sandstone TABLE!!"
	icon = 'monkestation/icons/obj/smooth_structures/sandstone_table.dmi'
	icon_state = "brass_table-0" //brass table is my best friend
	base_icon_state = "brass_table" //brass table is my best friend
	resistance_flags = FIRE_PROOF
	buildstack = /obj/item/stack/sheet/mineral/sandstone
	buildstackamount = 6
	framestackamount = 0
	smoothing_groups = SMOOTH_GROUP_SANDSTONE_TABLES
	canSmoothWith = SMOOTH_GROUP_SANDSTONE_TABLES
