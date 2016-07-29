/*
Mineral Sheets
	Contains:
		- Sandstone
<<<<<<< HEAD
		- Sandbags
		- Diamond
		- Snow
=======
		- Brick
		- Diamond
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Clown
<<<<<<< HEAD
		- Titanium
		- Plastitanium
=======
		- Plastic
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	Others:
		- Adamantine
		- Mythril
		- Enriched Uranium
<<<<<<< HEAD
		- Abductor
*/

/obj/item/stack/sheet/mineral
	icon = 'icons/obj/mining.dmi'
=======
*/

/obj/item/stack/sheet/mineral
	w_type = RECYK_METAL
	var/recyck_mat

/obj/item/stack/sheet/mineral/recycle(var/datum/materials/rec)
	if(!recyck_mat)
		return 0

	rec.addAmount(recyck_mat, amount)
	. = 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/*
 * Sandstone
 */
<<<<<<< HEAD

var/global/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/structure/mineral_door/sandstone, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Assistant Statue", /obj/structure/statue/sandstone/assistant, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Breakdown into sand", /obj/item/weapon/ore/glass, 1, one_per_turf = 0, on_floor = 1), \
/*	new/datum/stack_recipe("sandstone wall", ???), \
		new/datum/stack_recipe("sandstone floor", ???),\ */
	)

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 3
	throw_range = 5
	origin_tech = "materials=1"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	sheettype = "sandstone"

/obj/item/stack/sheet/mineral/sandstone/New(var/loc, var/amount=null)
	recipes = sandstone_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/sandstone/thirty
	amount = 30

/*
 * Sandbags
 */

/obj/item/stack/sheet/mineral/sandbags
	name = "sandbags"
	icon = 'icons/obj/items.dmi'
	icon_state = "sandbags"
	singular_name = "sandbag"
	layer = LOW_ITEM_LAYER
	origin_tech = "materials=2"

var/global/list/datum/stack_recipe/sandbag_recipes = list ( \
	new/datum/stack_recipe("sandbags", /obj/structure/barricade/sandbags, 1, time = 25, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/sandbags/New(var/loc, var/amount=null)
	recipes = sandbag_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()
=======
/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone bricks"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	throw_speed = 4
	throw_range = 5
	origin_tech = "materials=1"
	sheettype = "sandstone"
	melt_temperature = MELTPOINT_GLASS
	recyck_mat = MAT_GLASS

var/global/list/datum/stack_recipe/sandstone_recipes = list ( \
	new/datum/stack_recipe("pile of dirt", /obj/machinery/portable_atmospherics/hydroponics/soil, 3, time = 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("sandstone door", /obj/machinery/door/mineral/sandstone, 10, one_per_turf = 1, on_floor = 1), \
/*	new/datum/stack_recipe("sandstone wall", ???), \
		new/datum/stack_recipe("sandstone floor", ???),\ */
	)

/obj/item/stack/sheet/mineral/sandstone/New(var/loc, var/amount=null)
	recipes = sandstone_recipes
	..()

/*
 * Brick
 */
/obj/item/stack/sheet/mineral/brick
	name ="brick"
	singular_name = "brick"
	icon_state = "sheet-brick"
	force = 5.0
	throwforce = 5
	throw_range = 3
	throw_speed = 3
	w_class = W_CLASS_MEDIUM
	melt_temperature = 2473.15
	sheettype = "brick"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/*
 * Diamond
 */
/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
<<<<<<< HEAD
	icon_state = "sheet-diamond"
	singular_name = "diamond"
	origin_tech = "materials=6"
	sheettype = "diamond"
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)

var/global/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond door", /obj/structure/mineral_door/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("diamond tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20),  \
	new/datum/stack_recipe("Captain Statue", /obj/structure/statue/diamond/captain, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Hologram Statue", /obj/structure/statue/diamond/ai1, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("AI Core Statue", /obj/structure/statue/diamond/ai2, 5, one_per_turf = 1, on_floor = 1), \
=======
	singular_name = "diamond sheet"
	icon_state = "sheet-diamond"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_range = 3
	origin_tech = "materials=6"
	perunit = 1750
	sheettype = "diamond"
	melt_temperature = 3820 // In a vacuum, but fuck dat
	recyck_mat = MAT_DIAMOND

var/global/list/datum/stack_recipe/diamond_recipes = list ( \
	new/datum/stack_recipe("diamond floor tile", /obj/item/stack/tile/mineral/diamond, 1, 4, 20), \
	new/datum/stack_recipe("diamond door", /obj/machinery/door/mineral/transparent/diamond, 10, one_per_turf = 1, on_floor = 1), \
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	)

/obj/item/stack/sheet/mineral/diamond/New(var/loc, var/amount=null)
	recipes = diamond_recipes
<<<<<<< HEAD
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	..()

/*
 * Uranium
 */
/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
<<<<<<< HEAD
	icon_state = "sheet-uranium"
	singular_name = "uranium sheet"
	origin_tech = "materials=5"
	sheettype = "uranium"
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)

var/global/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium door", /obj/structure/mineral_door/uranium, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("uranium tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	new/datum/stack_recipe("Nuke Statue", /obj/structure/statue/uranium/nuke, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Engineer Statue", /obj/structure/statue/uranium/eng, 5, one_per_turf = 1, on_floor = 1), \
=======
	singular_name = "uranium sheet"
	icon_state = "sheet-uranium"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 2000
	sheettype = "uranium"
	melt_temperature = 1132+T0C
	recyck_mat = MAT_URANIUM

var/global/list/datum/stack_recipe/uranium_recipes = list ( \
	new/datum/stack_recipe("uranium floor tile", /obj/item/stack/tile/mineral/uranium, 1, 4, 20), \
	new/datum/stack_recipe("uranium door", /obj/machinery/door/mineral/uranium, 10, one_per_turf = 1, on_floor = 1), \
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	)

/obj/item/stack/sheet/mineral/uranium/New(var/loc, var/amount=null)
	recipes = uranium_recipes
<<<<<<< HEAD
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	..()

/*
 * Plasma
 */
/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
<<<<<<< HEAD
	icon_state = "sheet-plasma"
	singular_name = "plasma sheet"
	origin_tech = "plasmatech=2;materials=2"
	sheettype = "plasma"
	burn_state = FLAMMABLE
	burntime = 5
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)

var/global/list/datum/stack_recipe/plasma_recipes = list ( \
	new/datum/stack_recipe("plasma door", /obj/structure/mineral_door/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("plasma tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	new/datum/stack_recipe("Scientist Statue", /obj/structure/statue/plasma/scientist, 5, one_per_turf = 1, on_floor = 1), \
=======
	singular_name = "plasma sheet"
	icon_state = "sheet-plasma"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "plasmatech=2;materials=2"
	perunit = 2000
	sheettype = "plasma"
	melt_temperature = MELTPOINT_STEEL + 500
	recyck_mat = MAT_PLASMA

var/global/list/datum/stack_recipe/plasma_recipes = list ( \
	new/datum/stack_recipe("plasma floor tile", /obj/item/stack/tile/mineral/plasma, 1, 4, 20), \
	new/datum/stack_recipe("plasma door", /obj/machinery/door/mineral/transparent/plasma, 10, one_per_turf = 1, on_floor = 1), \
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	)

/obj/item/stack/sheet/mineral/plasma/New(var/loc, var/amount=null)
	recipes = plasma_recipes
<<<<<<< HEAD
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/obj/item/stack/sheet/mineral/plasma/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma sheets ignited by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
		log_game("Plasma sheets ignited by [key_name(user)] in ([x],[y],[z])")
		fire_act()
	else
		return ..()

/obj/item/stack/sheet/mineral/plasma/fire_act()
	atmos_spawn_air("plasma=[amount*10];TEMP=1000")
	qdel(src)
=======

	..()

/obj/item/stack/sheet/mineral/plastic
	name = "plastic"
	singular_name = "plastic sheet"
	icon_state = "sheet-plastic"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=3"
	perunit = 2000
	melt_temperature = MELTPOINT_PLASTIC
	sheettype = "plastic"
	recyck_mat = MAT_PLASTIC

var/global/list/datum/stack_recipe/plastic_recipes = list ( \
	new/datum/stack_recipe("plastic floor tile", /obj/item/stack/tile/mineral/plastic, 1, 4, 20), \
	new/datum/stack_recipe("plastic crate", /obj/structure/closet/pcrate, 10, one_per_turf = 1, on_floor = 1, one_per_turf = 1), \
	new/datum/stack_recipe("plastic ashtray", /obj/item/ashtray/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic fork", /obj/item/weapon/kitchen/utensil/fork/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic spoon", /obj/item/weapon/kitchen/utensil/spoon/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic knife", /obj/item/weapon/kitchen/utensil/knife/plastic, 1, on_floor = 1), \
	new/datum/stack_recipe("plastic bag", /obj/item/weapon/storage/bag/plasticbag, 3, on_floor = 1), \
	new/datum/stack_recipe("blood bag", /obj/item/weapon/reagent_containers/blood/empty, 3, on_floor = 1), \
	new/datum/stack_recipe("plastic coat", /obj/item/clothing/suit/raincoat, 5), \
	new/datum/stack_recipe("plastic flaps", /obj/structure/plasticflaps, 10, one_per_turf = 1, on_floor = 1, start_unanchored = 1), \
	new/datum/stack_recipe("water-cooler", /obj/structure/reagent_dispensers/water_cooler, 4, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe_list("curtains",list(
		new/datum/stack_recipe("white curtains", /obj/structure/curtain, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("black curtains", /obj/structure/curtain/black, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("medical curtains", /obj/structure/curtain/medical, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("bed curtains", /obj/structure/curtain/open/bed, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("privacy curtains", /obj/structure/curtain/open/privacy, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("shower curtains", /obj/structure/curtain/open/shower, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("engineering shower curtains", /obj/structure/curtain/open/shower/engineering, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("security shower curtains", /obj/structure/curtain/open/shower/medical, 4, one_per_turf = 1, on_floor = 1), \
		new/datum/stack_recipe("medical shower curtains", /obj/structure/curtain/open/shower/security, 4, one_per_turf = 1, on_floor = 1), \
		), 4),
	)

/obj/item/stack/sheet/mineral/plastic/New(var/loc, var/amount=null)
	recipes = plastic_recipes
	..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/*
 * Gold
 */
/obj/item/stack/sheet/mineral/gold
	name = "gold"
<<<<<<< HEAD
	icon_state = "sheet-gold"
	singular_name = "gold bar"
	origin_tech = "materials=4"
	sheettype = "gold"
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)

var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden door", /obj/structure/mineral_door/gold, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("gold tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	new/datum/stack_recipe("HoS Statue", /obj/structure/statue/gold/hos, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("HoP Statue", /obj/structure/statue/gold/hop, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CE Statue", /obj/structure/statue/gold/ce, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("RD Statue", /obj/structure/statue/gold/rd, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("CMO Statue", /obj/structure/statue/gold/cmo, 5, one_per_turf = 1, on_floor = 1), \
=======
	singular_name = "gold sheet"
	icon_state = "sheet-gold"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000
	melt_temperature = 1064+T0C
	sheettype = "gold"
	recyck_mat = MAT_GOLD

var/global/list/datum/stack_recipe/gold_recipes = list ( \
	new/datum/stack_recipe("golden floor tile", /obj/item/stack/tile/mineral/gold, 1, 4, 20), \
	new/datum/stack_recipe("golden door", /obj/machinery/door/mineral/gold, 10, one_per_turf = 1, on_floor = 1), \
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	)

/obj/item/stack/sheet/mineral/gold/New(var/loc, var/amount=null)
	recipes = gold_recipes
<<<<<<< HEAD
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
=======
	..()

/*
 * Phazon
 */
var/global/list/datum/stack_recipe/phazon_recipes = list( \
	new/datum/stack_recipe("phazon floor tile", /obj/item/stack/tile/mineral/phazon, 1, 4, 20), \
	)

/obj/item/stack/sheet/mineral/phazon
	name = "phazon"
	singular_name = "phazon sheet"
	desc = "Holy christ what is this?"
	icon_state = "sheet-phazon"
	item_state = "sheet-phazon"
	sheettype = "phazon"
	perunit = 1500
	melt_temperature = MELTPOINT_PLASTIC
	throwforce = 15.0
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = "materials=9"
	recyck_mat = MAT_PHAZON

/obj/item/stack/sheet/mineral/phazon/New(var/loc, var/amount=null)
		recipes = phazon_recipes
		return ..()

/*
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
 * Silver
 */
/obj/item/stack/sheet/mineral/silver
	name = "silver"
<<<<<<< HEAD
	icon_state = "sheet-silver"
	singular_name = "silver bar"
	origin_tech = "materials=4"
	sheettype = "silver"
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)

var/global/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver door", /obj/structure/mineral_door/silver, 10, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("silver tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	new/datum/stack_recipe("Med Officer Statue", /obj/structure/statue/silver/md, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Janitor Statue", /obj/structure/statue/silver/janitor, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Officer Statue", /obj/structure/statue/silver/sec, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Sec Borg Statue", /obj/structure/statue/silver/secborg, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Med Borg Statue", /obj/structure/statue/silver/medborg, 5, one_per_turf = 1, on_floor = 1), \
=======
	singular_name = "silver sheet"
	icon_state = "sheet-silver"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=3"
	perunit = 2000
	sheettype = "silver"
	recyck_mat = MAT_SILVER

var/global/list/datum/stack_recipe/silver_recipes = list ( \
	new/datum/stack_recipe("silver floor tile", /obj/item/stack/tile/mineral/silver, 1, 4, 20), \
	new/datum/stack_recipe("silver door", /obj/machinery/door/mineral/silver, 10, one_per_turf = 1, on_floor = 1), \
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	)

/obj/item/stack/sheet/mineral/silver/New(var/loc, var/amount=null)
	recipes = silver_recipes
<<<<<<< HEAD
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	..()

/*
 * Clown
 */
<<<<<<< HEAD
/obj/item/stack/sheet/mineral/bananium
	name = "bananium"
	icon_state = "sheet-clown"
	singular_name = "bananium sheet"
	origin_tech = "materials=4"
	sheettype = "clown"
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)

var/global/list/datum/stack_recipe/clown_recipes = list ( \
	new/datum/stack_recipe("bananium tile", /obj/item/stack/tile/mineral/bananium, 1, 4, 20), \
	new/datum/stack_recipe("Clown Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/mineral/bananium/New(var/loc, var/amount=null)
	recipes = clown_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/*
 * Titanium
 */
/obj/item/stack/sheet/mineral/titanium
	name = "titanium"
	icon_state = "sheet-titanium"
	singular_name = "titanium sheet"
	force = 5
	throwforce = 5
	w_class = 3
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "titanium"
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT)

var/global/list/datum/stack_recipe/titanium_recipes = list ( \
	new/datum/stack_recipe("titanium tile", /obj/item/stack/tile/mineral/titanium, 1, 4, 20), \
	)

/obj/item/stack/sheet/mineral/titanium/New(var/loc, var/amount=null)
	recipes = titanium_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()


/*
 * Plastitanium
 */
/obj/item/stack/sheet/mineral/plastitanium
	name = "plastitanium"
	icon_state = "sheet-plastitanium"
	singular_name = "plastitanium sheet"
	force = 5
	throwforce = 5
	w_class = 3
	throw_speed = 1
	throw_range = 3
	origin_tech = "materials=4"
	sheettype = "plastitanium"
	materials = list(MAT_TITANIUM=6000, MAT_PLASMA=6000)

var/global/list/datum/stack_recipe/plastitanium_recipes = list ( \
	new/datum/stack_recipe("plas-titanium tile", /obj/item/stack/tile/mineral/plastitanium, 1, 4, 20), \
	)

/obj/item/stack/sheet/mineral/plastitanium/New(var/loc, var/amount=null)
	recipes = plastitanium_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()


/*
 * Snow
 */
/obj/item/stack/sheet/mineral/snow
	name = "snow"
	icon_state = "sheet-snow"
	singular_name = "snow block"
	force = 1
	throwforce = 2
	origin_tech = "materials=1"
	sheettype = "snow"

var/global/list/datum/stack_recipe/snow_recipes = list ( \
	new/datum/stack_recipe("Snow Wall",/turf/closed/wall/mineral/snow, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Snowman", /obj/structure/statue/snow/snowman, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Snowball", /obj/item/toy/snowball, 1), \
	)

/obj/item/stack/sheet/mineral/snow/New(var/loc, var/amount=null)
	recipes = snow_recipes
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4
	..()

/****************************** Others ****************************/

/*
 * Enriched Uranium
 */
/obj/item/stack/sheet/mineral/enruranium
	name = "enriched uranium"
	icon_state = "sheet-enruranium"
	singular_name = "enriched uranium sheet"
	origin_tech = "materials=6"
	materials = list(MAT_URANIUM=3000)

/*
 * Adamantine
 */
/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	singular_name = "adamantine sheet"
	origin_tech = "materials=4"

/*
 * Mythril
 */
/obj/item/stack/sheet/mineral/mythril
	name = "mythril"
	icon_state = "sheet-mythril"
	singular_name = "mythril sheet"
	origin_tech = "materials=4"

/*
 * Alien Alloy
 */
/obj/item/stack/sheet/mineral/abductor
	name = "alien alloy"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "sheet-abductor"
	singular_name = "alien alloy sheet"
	origin_tech = "materials=6;abductor=1"
	sheettype = "abductor"

var/global/list/datum/stack_recipe/abductor_recipes = list ( \
/*	new/datum/stack_recipe("alien chair", /obj/structure/chair, one_per_turf = 1, on_floor = 1), \ */
	new/datum/stack_recipe("alien bed", /obj/structure/bed/abductor, 2, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien locker", /obj/structure/closet/abductor, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien table frame", /obj/structure/table_frame/abductor, 1, time = 15, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("alien airlock assembly", /obj/structure/door_assembly/door_assembly_abductor, 4, time = 20, one_per_turf = 1, on_floor = 1), \
	null, \
	new/datum/stack_recipe("alien floor tile", /obj/item/stack/tile/mineral/abductor, 1, 4, 20), \
/*	null, \
	new/datum/stack_recipe("Abductor Agent Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("Abductor Sciencist Statue", /obj/structure/statue/bananium/clown, 5, one_per_turf = 1, on_floor = 1)*/
	)

/obj/item/stack/sheet/mineral/abductor/New(var/loc, var/amount=null)
	recipes = abductor_recipes
	..()
=======
/obj/item/stack/sheet/mineral/clown
	name = "bananium"
	singular_name = "bananium sheet"
	icon_state = "sheet-clown"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000
	sheettype = "clown"
	recyck_mat = MAT_CLOWN

var/global/list/datum/stack_recipe/clown_recipes = list ( \
	new/datum/stack_recipe("bananium floor tile", /obj/item/stack/tile/mineral/clown, 1, 4, 20), \
	)

/obj/item/stack/sheet/mineral/clown/New(var/loc, var/amount=null)
	recipes = clown_recipes
	..()

/****************************** Others ****************************/
/*
 * Adamantine
 */
/obj/item/stack/sheet/mineral/adamantine
	name = "adamantine"
	icon_state = "sheet-adamantine"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000

/*
 * Mythril
 */
/obj/item/stack/sheet/mineral/mythril
	name = "mythril"
	icon_state = "sheet-mythril"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=4"
	perunit = 2000

/*
/obj/item/stack/sheet/mineral/pharosium
	name = "pharosium"
	icon_state = "sheet-pharosium"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750

/obj/item/stack/sheet/mineral/char
	name = "char"
	icon_state = "sheet-char"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/claretine
	name = "claretine"
	icon_state = "sheet-claretine"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/cobryl
	name = "cobryl"
	icon_state = "sheet-cobryl"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/bohrum
	name = "bohrum"
	icon_state = "sheet-bohrum"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/syreline
	name = "syreline"
	icon_state = "sheet-syreline"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/erebite
	name = "erebite"
	icon_state = "sheet-erebite"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/cerenkite
	name = "cerenkite"
	icon_state = "sheet-cerenkite"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/cytine
	name = "cytine"
	icon_state = "sheet-cytine"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/uqill
	name = "uqill"
	icon_state = "sheet-uqill"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/telecrystal
	name = "telecrystal"
	icon_state = "sheet-telecrystal"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/mauxite
	name = "mauxite"
	icon_state = "sheet-mauxite"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750


/obj/item/stack/sheet/mineral/molitz
	name = "molitz"
	icon_state = "sheet-molitz"
	force = 5.0
	throwforce = 5
	w_class = W_CLASS_MEDIUM
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=5"
	perunit = 3750
*/
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
