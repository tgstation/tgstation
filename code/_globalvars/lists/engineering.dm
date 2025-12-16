// List of all tool behaviours.
GLOBAL_LIST_INIT(all_tool_behaviours, list(
	TOOL_ANALYZER,
	TOOL_BLOODFILTER,
	TOOL_BONESET,
	TOOL_CAUTERY,
	TOOL_CROWBAR,
	TOOL_DRILL,
	TOOL_HEMOSTAT,
	TOOL_KNIFE,
	TOOL_MINING,
	TOOL_MULTITOOL,
	TOOL_RETRACTOR,
	TOOL_ROLLINGPIN,
	TOOL_RUSTSCRAPER,
	TOOL_SAW,
	TOOL_SCALPEL,
	TOOL_SCREWDRIVER,
	TOOL_SHOVEL,
	TOOL_WELDER,
	TOOL_WIRECUTTER,
	TOOL_WRENCH,
))

GLOBAL_LIST_INIT(all_mechanical_tools, list(
	TOOL_ANALYZER,
	TOOL_CROWBAR,
	TOOL_MULTITOOL,
	TOOL_SCREWDRIVER,
	TOOL_WELDER,
	TOOL_WIRECUTTER,
	TOOL_WRENCH,
))

GLOBAL_LIST_INIT(all_surgical_tools, list(
	TOOL_BONESET,
	TOOL_CAUTERY,
	TOOL_HEMOSTAT,
	TOOL_RETRACTOR,
	TOOL_SAW,
	TOOL_SCALPEL,
))

/// Mapping of tool types to icons that represent them
GLOBAL_LIST_INIT(tool_to_image, list(
	TOOL_CROWBAR = image(/obj/item/crowbar),
	TOOL_MULTITOOL = image(/obj/item/multitool),
	TOOL_SCREWDRIVER = image(/obj/item/screwdriver),
	TOOL_WIRECUTTER = image(/obj/item/wirecutters),
	TOOL_WRENCH = image(/obj/item/wrench),
	TOOL_WELDER = image(/obj/item/weldingtool/mini),
	TOOL_ANALYZER = image(/obj/item/analyzer),
	TOOL_MINING = image(/obj/item/pickaxe),
	TOOL_SHOVEL = image(/obj/item/shovel),
	TOOL_RETRACTOR = image(/obj/item/retractor),
	TOOL_HEMOSTAT = image(/obj/item/hemostat),
	TOOL_CAUTERY = image(/obj/item/cautery),
	TOOL_DRILL = image(/obj/item/surgicaldrill),
	TOOL_SCALPEL = image(/obj/item/scalpel),
	TOOL_SAW = image(/obj/item/circular_saw),
	TOOL_BONESET = image(/obj/item/bonesetter),
	TOOL_KNIFE = image(/obj/item/knife/kitchen),
	TOOL_BLOODFILTER = image(/obj/item/blood_filter),
	TOOL_ROLLINGPIN = image(/obj/item/kitchen/rollingpin),
	TOOL_RUSTSCRAPER = image(/obj/item/wirebrush),
))
