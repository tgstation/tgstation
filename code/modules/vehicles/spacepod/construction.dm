/datum/pod_construct
	/// the stuff we build
	var/build_path
	/// stuff we need to add to build, may be an item or a sheet type, 25 of this sheet
	var/build_needed_item

/datum/pod_construct/iron
	build_path = /obj/vehicle/sealed/space_pod
	build_needed_item = /obj/item/stack/sheet/iron

/datum/pod_construct/plasteel
	build_path = /obj/vehicle/sealed/space_pod/plasteel
	build_needed_item = /obj/item/stack/sheet/plasteel

/datum/pod_construct/titanium
	build_path = /obj/vehicle/sealed/space_pod/titanium
	build_needed_item = /obj/item/stack/sheet/mineral/titanium

// uncool boring stuff below

/obj/item/circuitboard/pod
	name = "pod control board"
	icon_state = "std_mod"

/obj/item/pod_runner
	name = "pod frame runner"
	desc = "A metal runner with pod frame parts. Use a wirecutter to snip them free. For your own sake, do this in the hangar bay and not robotics."
	var/build_path = /obj/structure/pod_construction

/obj/item/pod_runner/wirecutter_act(mob/living/user, obj/item/tool)
	. = NONE
	tool.play_tool_sound(src)
	if(!do_after(user, 5 SECONDS, src))
		return ITEM_INTERACT_FAILURE
	tool.play_tool_sound(src)
	new build_path(get_turf(src))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/pod_construction
	name = "in-progress pod"
	density = TRUE

/obj/structure/pod_construction/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/construction/mecha/pod)

// MAYBE:: window?
/datum/component/construction/mecha/pod // its convenient to inherit ok
	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 15

/datum/component/construction/mecha/pod/get_steps()
	return get_frame_steps() + get_circuit_steps() + get_inner_plating_steps() + get_outer_plating_steps()

/datum/component/construction/mecha/pod/get_frame_steps()
	return list(
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The frame can be connected together with a <b>wrench</b>.",
			"forward_message" = "assembled frame",
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The frame is flimsily connected together, and may be reinforced with a <b>welding tool</b>.",
			"forward_message" = "welded frame together",
			"backward_message" = "disassembled frame"
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 30,
			"back_key" = TOOL_WELDER,
			"desc" = "The frame is robustly connected together and may be <b>wired</b>.",
			"forward_message" = "added wiring",
			"backward_message" = "welded joints apart"
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added, and can be adjusted with <b>wirecutters</b>.",
			"forward_message" = "adjusted wiring",
			"backward_message" = "removed wiring"
		)
	)

/datum/component/construction/mecha/pod/get_circuit_steps()
	return list(
		list(
			"key" = /obj/item/circuitboard/pod,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted, and the <b>control module</b> can be added.",
			"forward_message" = "added control module",
			"backward_message" = "disconnected wiring"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The control module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured control module",
			"backward_message" = "removed control module"
		)
	)

/datum/component/construction/mecha/pod/get_inner_plating_steps()
	return list(
		list(
			"key" = inner_plating,
			"amount" = inner_plating_amount,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "[inner_plating_amount] sheets of [initial(inner_plating.name)] can be used as inner plating.",
			"forward_message" = "installed internal armor layer",
			"backward_message" = "unsecured control module"
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Inner plating is installed, and can be <b>wrenched</b> into place.",
			"forward_message" = "secured internal armor layer",
			"backward_message" = "pried off internal armor layer"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Inner plating is wrenched, and can be <b>welded</b>.",
			"forward_message" = "welded internal armor layer",
			"backward_message" = "unfastened internal armor layer"
		)
	)

/datum/component/construction/mecha/pod/get_outer_plating_steps()
	return list(
		list(
			"key" = /obj/item, // special handling
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Inner plating is welded, titanium, iron, plasteel or an armor kit can be used as external armor.",
			"forward_message" = "installed external armor layer",
			"backward_message" = "cut off internal armor layer"
		),
		list(
			"key" = TOOL_WRENCH,
			"desc" = "External armor is installed, and can be <b>wrenched</b> into place.",
			"forward_message" = "secured external armor layer",
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched, and can be <b>welded</b>.",
			"forward_message" = "welded external armor layer",
			"backward_message" = "unfastened external armor layer"
		)
	)

/datum/component/construction/mecha/pod/custom_action(obj/item/item, mob/living/user, diff)
	if(diff == BACKWARD || index != 10) //3rd last step
		return ..()
	var/obj/item/stack/sheet/as_sheet = item
	var/static/list/datum/pod_construct/constructs
	if(isnull(constructs))
		constructs = list()
		for(var/datum/pod_construct/construct as anything in subtypesof(/datum/pod_construct))
			constructs[initial(construct.build_needed_item)] = new construct

	var/datum/pod_construct/construct = constructs[item.type]
	if(isnull(construct))
		return ..()

	if(istype(as_sheet) && !as_sheet.use(25))
		var/atom/parent_atom = parent
		parent_atom.balloon_alert(user, "not enough!")
		return
	result = construct.build_path
	return ..()

/datum/component/construction/mecha/pod/spawn_result()
	var/obj/vehicle/sealed/space_pod/pod = new result(drop_location(), /*dont_equip*/ TRUE)
	pod.panel_open = TRUE
	pod.update_appearance(UPDATE_OVERLAYS)
	qdel(parent)
