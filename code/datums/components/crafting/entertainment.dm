/datum/crafting_recipe/mothplush
	name = "Moth Plushie"
	result = /obj/item/toy/plush/moth
	reqs = list(
		/obj/item/stack/sheet/animalhide/mothroach = 1,
		/obj/item/organ/internal/heart = 1,
		/obj/item/stack/sheet/cloth = 3,
	)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/mixedbouquet
	name = "Mixed bouquet"
	result = /obj/item/bouquet
	reqs = list(
		/obj/item/food/grown/poppy/lily = 2,
		/obj/item/food/grown/sunflower = 2,
		/obj/item/food/grown/poppy/geranium = 2,
	)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/sunbouquet
	name = "Sunflower bouquet"
	result = /obj/item/bouquet/sunflower
	reqs = list(/obj/item/food/grown/sunflower = 6)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/poppybouquet
	name = "Poppy bouquet"
	result = /obj/item/bouquet/poppy
	reqs = list (/obj/item/food/grown/poppy = 6)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/rosebouquet
	name = "Rose bouquet"
	result = /obj/item/bouquet/rose
	reqs = list(/obj/item/food/grown/rose = 6)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/spooky_camera
	name = "Camera Obscura"
	result = /obj/item/camera/spooky
	time = 1.5 SECONDS
	reqs = list(
		/obj/item/camera = 1,
		/datum/reagent/water/holywater = 10,
	)
	parts = list(/obj/item/camera = 1)
	category = CAT_ENTERTAINMENT


/datum/crafting_recipe/skateboard
	name = "Skateboard"
	result = /obj/vehicle/ridden/scooter/skateboard/improvised
	time = 6 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 10,
	)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/scooter
	name = "Scooter"
	result = /obj/vehicle/ridden/scooter
	time = 6.5 SECONDS
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 12,
	)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/headpike
	name = "Spike Head (Glass Spear)"
	time = 6.5 SECONDS
	reqs = list(
		/obj/item/spear = 1,
		/obj/item/bodypart/head = 1,
	)
	parts = list(
		/obj/item/bodypart/head = 1,
		/obj/item/spear = 1,
	)
	blacklist = list(
		/obj/item/spear/explosive,
		/obj/item/spear/bonespear,
		/obj/item/spear/bamboospear,
	)
	result = /obj/structure/headpike
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/headpikebone
	name = "Spike Head (Bone Spear)"
	time = 6.5 SECONDS
	reqs = list(
		/obj/item/spear/bonespear = 1,
		/obj/item/bodypart/head = 1,
	)
	parts = list(
		/obj/item/bodypart/head = 1,
		/obj/item/spear/bonespear = 1,
	)
	result = /obj/structure/headpike/bone
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/headpikebamboo
	name = "Spike Head (Bamboo Spear)"
	time = 6.5 SECONDS
	reqs = list(
		/obj/item/spear/bamboospear = 1,
		/obj/item/bodypart/head = 1,
	)
	parts = list(
		/obj/item/bodypart/head = 1,
		/obj/item/spear/bamboospear = 1,
	)
	result = /obj/structure/headpike/bamboo
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/guillotine
	name = "Guillotine"
	result = /obj/structure/guillotine
	time = 15 SECONDS // Building a functioning guillotine takes time
	reqs = list(
		/obj/item/stack/sheet/plasteel = 3,
		/obj/item/stack/sheet/mineral/wood = 20,
		/obj/item/stack/cable_coil = 10,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_WELDER)
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/toiletbong
	name = "Toiletbong"
	result = /obj/structure/toiletbong
	time = 5 SECONDS
	tool_behaviors = list(TOOL_WRENCH)
	reqs = list(/obj/item/flamethrower = 1)
	machinery = list(/obj/structure/toilet)
	additional_req_text = " plasma tank (on flamethrower), toilet"
	category = CAT_ENTERTAINMENT

/datum/crafting_recipe/toiletbong/check_requirements(mob/user, list/collected_requirements)
	if((locate(/obj/structure/toilet) in range(1, user.loc)) == null)
		return FALSE
	var/obj/item/flamethrower/flamethrower = collected_requirements[/obj/item/flamethrower][1]
	if(flamethrower.ptank == null)
		return FALSE
	return TRUE

/datum/crafting_recipe/toiletbong/on_craft_completion(mob/user, atom/result)
	var/obj/structure/toiletbong/toiletbong = result
	var/obj/structure/toilet/toilet = locate(/obj/structure/toilet) in range(1, user.loc)
	for (var/obj/item/cistern_item in toilet.contents)
		cistern_item.forceMove(user.loc)
		to_chat(user, span_warning("[cistern_item] falls out of the toilet!"))
	toiletbong.dir = toilet.dir
	toiletbong.loc = toilet.loc
	qdel(toilet)
	to_chat(user, span_notice("[user] attaches the flamethrower to the repurposed toilet."))

/datum/crafting_recipe/punching_bag
	name = "Punching Bag"
	result = /obj/structure/punching_bag
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/rods = 1,
		/obj/item/pillow = 1,
	)
	category = CAT_ENTERTAINMENT
	time = 10 SECONDS

/datum/crafting_recipe/stacklifter
	name = "Chest Press"
	result = /obj/structure/weightmachine/stacklifter
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 2,
		/obj/item/chair = 1,
	)
	category = CAT_ENTERTAINMENT
	time = 10 SECONDS

/datum/crafting_recipe/weightlifter
	name = "Bench Press"
	result = /obj/structure/weightmachine/weightlifter
	tool_behaviors = list(TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 2,
		/obj/item/chair = 1,
	)
	category = CAT_ENTERTAINMENT
	time = 10 SECONDS
