/obj/structure/locker/secure/freezer
	icon_state = "freezer"
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	door_anim_squish = 0.22
	door_anim_angle = 123
	door_anim_time = 4
	/// If FALSE, we will protect the first person in the freezer from an explosion / nuclear blast.
	var/jones = FALSE

/obj/structure/locker/secure/freezer/Destroy()
	toggle_organ_decay(src)
	return ..()

/obj/structure/locker/secure/freezer/Initialize(mapload)
	. = ..()
	toggle_organ_decay(src)

/obj/structure/locker/secure/freezer/open(mob/living/user, force = FALSE)
	if(opened || !can_open(user, force)) //dupe check just so we don't let the organs decay when someone fails to open the locker
		return FALSE
	toggle_organ_decay(src)
	return ..()

/obj/structure/locker/secure/freezer/close(mob/living/user)
	if(..()) //if we actually closed the locker
		toggle_organ_decay(src)
		return TRUE

/obj/structure/locker/secure/freezer/ex_act()
	if(jones)
		return ..()
	jones = TRUE
	flags_1 &= ~PREVENT_CONTENTS_EXPLOSION_1
	return FALSE

/obj/structure/locker/secure/freezer/atom_destruction(damage_flag)
	new /obj/item/stack/sheet/iron(drop_location(), 1)
	new /obj/item/assembly/igniter/condenser(drop_location())
	return ..()

/obj/structure/locker/secure/freezer/welder_act(mob/living/user, obj/item/tool)
	. = ..()

	if(!opened)
		balloon_alert(user, "open it first!")
		return TRUE

	if(!tool.use_tool(src, user, 40, volume=50))
		return TRUE

	new /obj/item/stack/sheet/iron(drop_location(), 2)
	new /obj/item/assembly/igniter/condenser(drop_location())
	qdel(src)

	return TRUE

/obj/structure/locker/secure/freezer/empty
	name = "freezer"

/obj/structure/locker/secure/freezer/empty/open
	req_access = null
	locked = FALSE

/obj/structure/locker/secure/freezer/kitchen
	name = "kitchen cabinet"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/locker/secure/freezer/kitchen/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/condiment/flour(src)
	new /obj/item/reagent_containers/condiment/rice(src)
	new /obj/item/reagent_containers/condiment/sugar(src)

/obj/structure/locker/secure/freezer/kitchen/maintenance
	name = "maintenance refrigerator"
	desc = "This refrigerator looks quite dusty, is there anything edible still inside?"
	req_access = list()

/obj/structure/locker/secure/freezer/kitchen/maintenance/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/condiment/milk(src)
		new /obj/item/reagent_containers/condiment/soymilk(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/locker/secure/freezer/kitchen/mining
	req_access = list()

/obj/structure/locker/secure/freezer/meat
	name = "meat fridge"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/locker/secure/freezer/meat/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/food/meat/slab/monkey(src)

/obj/structure/locker/secure/freezer/meat/open
	req_access = list()
	locked = FALSE

/obj/structure/locker/secure/freezer/gulag_fridge
	name = "refrigerator"

/obj/structure/locker/secure/freezer/gulag_fridge/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/cup/glass/bottle/beer/light(src)

/obj/structure/locker/secure/freezer/fridge
	name = "refrigerator"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/locker/secure/freezer/fridge/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/condiment/milk(src)
		new /obj/item/reagent_containers/condiment/soymilk(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/locker/secure/freezer/fridge/open
	req_access = null
	locked = FALSE

/obj/structure/locker/secure/freezer/money
	name = "freezer"
	desc = "This contains cold hard cash."
	req_access = list(ACCESS_VAULT)

/obj/structure/locker/secure/freezer/money/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/stack/spacecash/c1000(src)
	for(var/i in 1 to 5)
		new /obj/item/stack/spacecash/c500(src)
	for(var/i in 1 to 6)
		new /obj/item/stack/spacecash/c200(src)

/obj/structure/locker/secure/freezer/cream_pie
	name = "cream pie locker"
	desc = "Contains pies filled with cream and/or custard, you sickos."
	req_access = list(ACCESS_THEATRE)

/obj/structure/locker/secure/freezer/cream_pie/PopulateContents()
	..()
	new /obj/item/food/pie/cream(src)
