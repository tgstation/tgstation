GLOBAL_LIST_INIT(rod_recipes, list ( \
	new/datum/stack_recipe("grille", /obj/structure/grille, 2, time = 10, one_per_turf = TRUE, on_solid_ground = FALSE, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("table frame", /obj/structure/table_frame, 2, time = 10, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_FURNITURE), \
	new/datum/stack_recipe("scooter frame", /obj/item/scooter_frame, 10, time = 25, one_per_turf = FALSE, category = CAT_ENTERTAINMENT), \
	new/datum/stack_recipe("linen bin", /obj/structure/bedsheetbin/empty, 2, time = 5, one_per_turf = FALSE, category = CAT_CONTAINERS), \
	new/datum/stack_recipe("railing", /obj/structure/railing, 6, time = 3.6 SECONDS, window_checks = TRUE, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("tank holder", /obj/structure/tank_holder, 2, time = 5, one_per_turf = TRUE, on_solid_ground = FALSE, category = CAT_FURNITURE), \
	new/datum/stack_recipe("ladder", /obj/structure/ladder/crafted, 15, time = 150, one_per_turf = TRUE, on_solid_ground = FALSE, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("catwalk floor tile", /obj/item/stack/tile/catwalk_tile, 1, 4, 20, category = CAT_TILES), \
	new/datum/stack_recipe("stairs frame", /obj/structure/stairs_frame, 10, time = 5 SECONDS, one_per_turf = TRUE, on_solid_ground = TRUE, category = CAT_STRUCTURE), \
	new/datum/stack_recipe("white cane", /obj/item/cane/white, 3, time = 10, one_per_turf = FALSE, category = CAT_TOOLS), \
	))

/obj/item/stack/rods
	name = "iron rod"
	desc = "Some rods. Can be used for building or something."
	singular_name = "iron rod"
	icon_state = "rods"
	inhand_icon_state = "rods"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_NORMAL
	force = 9
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	demolition_mod = 1.25
	mats_per_unit = list(/datum/material/iron=1000)
	max_amount = 50
	attack_verb_continuous = list("hits", "bludgeons", "whacks")
	attack_verb_simple = list("hit", "bludgeon", "whack")
	hitsound = 'sound/weapons/gun/general/grenade_launch.ogg'
	embedding = list(embed_chance = 50)
	novariants = TRUE
	matter_amount = 2
	cost = 250
	source = /datum/robot_energy_storage/iron
	merge_type = /obj/item/stack/rods

/obj/item/stack/rods/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to stuff \the [src] down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide!"))//it looks like theyre ur mum
	return BRUTELOSS

/obj/item/stack/rods/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	update_appearance()
	AddElement(/datum/element/openspace_item_click_handler)
	var/static/list/tool_behaviors = list(
		TOOL_WELDER = list(
			SCREENTIP_CONTEXT_LMB = "Craft iron sheets",
			SCREENTIP_CONTEXT_RMB = "Craft floor tiles",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/item/stack/rods/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		target.attackby(src, user, click_parameters)

/obj/item/stack/rods/get_main_recipes()
	. = ..()
	. += GLOB.rod_recipes

/obj/item/stack/rods/update_icon_state()
	. = ..()
	var/amount = get_amount()
	if(amount <= 5)
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/welder_act(mob/living/user, obj/item/tool)
	if(get_amount() < 2)
		balloon_alert(user, "not enough rods!")
		return
	if(tool.use_tool(src, user, delay = 0, volume = 40))
		var/obj/item/stack/sheet/iron/new_item = new(user.loc)
		user.visible_message(
			span_notice("[user.name] shaped [src] into iron sheets with [tool]."),
			blind_message = span_hear("You hear welding."),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = user
		)
		use(2)
		user.put_in_inactive_hand(new_item)
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/stack/rods/welder_act_secondary(mob/living/user, obj/item/tool)
	if(tool.use_tool(src, user, delay = 0, volume = 40))
		var/obj/item/stack/tile/iron/two/new_item = new(user.loc)
		user.visible_message(
			span_notice("[user.name] shaped [src] into floor tiles with [tool]."),
			blind_message = span_hear("You hear welding."),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = user
		)
		use(1)
		user.put_in_inactive_hand(new_item)
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/stack/rods/cyborg/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/stack/rods/two
	amount = 2

/obj/item/stack/rods/ten
	amount = 10

/obj/item/stack/rods/twentyfive
	amount = 25

/obj/item/stack/rods/fifty
	amount = 50

/obj/item/stack/rods/lava
	name = "heat resistant rod"
	desc = "Treated, specialized iron rods. When exposed to the vaccum of space their coating breaks off, but they can hold up against the extreme heat of active lava."
	singular_name = "heat resistant rod"
	icon_state = "rods"
	inhand_icon_state = "rods"
	color = "#5286b9ff"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_NORMAL
	mats_per_unit = list(/datum/material/iron=1000, /datum/material/plasma=500, /datum/material/titanium=2000)
	max_amount = 30
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	merge_type = /obj/item/stack/rods/lava

/obj/item/stack/rods/lava/thirty
	amount = 30
