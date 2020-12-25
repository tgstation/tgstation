///These global lists exist to allow our element to have weight tables without having to be seperate instances.

///Assoc list of cell line define | assoc list of datum | cell_line
GLOBAL_LIST_INIT_TYPED(cell_line_tables, /list, list(
	CELL_LINE_TABLE_SLUDGE = list(/datum/micro_organism/cell_line/sholean_grapes = 2, /datum/micro_organism/cell_line/blobbernaut = 1, /datum/micro_organism/cell_line/slime = 2, /datum/micro_organism/cell_line/cow = 1, /datum/micro_organism/cell_line/mouse = 1, /datum/micro_organism/cell_line/chicken = 1, /datum/micro_organism/cell_line/cockroach = 2),
	CELL_LINE_TABLE_MOIST = list(/datum/micro_organism/cell_line/gelatinous_cube = 2, /datum/micro_organism/cell_line/megacarp = 1, /datum/micro_organism/cell_line/slime = 2, /datum/micro_organism/cell_line/snake = 1, /datum/micro_organism/cell_line/carp = 1, /datum/micro_organism/cell_line/cockroach = 1),
	CELL_LINE_TABLE_BLOB = list(/datum/micro_organism/cell_line/blobbernaut = 1, /datum/micro_organism/cell_line/blob_spore = 1),
	CELL_LINE_TABLE_MOLD = list(/datum/micro_organism/cell_line/vat_beast = 2, /datum/micro_organism/cell_line/bear = 1, /datum/micro_organism/cell_line/slime = 1, /datum/micro_organism/cell_line/blob_spore = 1, /datum/micro_organism/cell_line/mouse = 2, /datum/micro_organism/cell_line/corgi = 1, /datum/micro_organism/cell_line/cockroach = 1, /datum/micro_organism/cell_line/cat = 1),
	CELL_LINE_TABLE_BEAR = list(/datum/micro_organism/cell_line/bear = 1),
	CELL_LINE_TABLE_BLOBBERNAUT = list(/datum/micro_organism/cell_line/blobbernaut = 1),
	CELL_LINE_TABLE_BLOBSPORE = list(/datum/micro_organism/cell_line/blob_spore = 1),
	CELL_LINE_TABLE_CARP = list(/datum/micro_organism/cell_line/carp = 1),
	CELL_LINE_TABLE_CAT = list(/datum/micro_organism/cell_line/cat = 1),
	CELL_LINE_TABLE_CHICKEN = list(/datum/micro_organism/cell_line/chicken = 1),
	CELL_LINE_TABLE_COCKROACH = list(/datum/micro_organism/cell_line/cockroach = 1),
	CELL_LINE_TABLE_CORGI = list(/datum/micro_organism/cell_line/corgi = 1),
	CELL_LINE_TABLE_COW = list(/datum/micro_organism/cell_line/cow = 1),
	CELL_LINE_TABLE_GELATINOUS = list(/datum/micro_organism/cell_line/gelatinous_cube = 1),
	CELL_LINE_TABLE_GRAPE = list(/datum/micro_organism/cell_line/sholean_grapes = 1),
	CELL_LINE_TABLE_MEGACARP = list(/datum/micro_organism/cell_line/megacarp = 1),
	CELL_LINE_TABLE_MOUSE = list(/datum/micro_organism/cell_line/mouse = 1),
	CELL_LINE_TABLE_PINE = list(/datum/micro_organism/cell_line/pine = 1),
	CELL_LINE_TABLE_PUG = list(/datum/micro_organism/cell_line/pug = 1),
	CELL_LINE_TABLE_SLIME = list(/datum/micro_organism/cell_line/slime = 1),
	CELL_LINE_TABLE_SNAKE = list(/datum/micro_organism/cell_line/snake = 1),
	CELL_LINE_TABLE_VATBEAST = list(/datum/micro_organism/cell_line/vat_beast = 1),
	CELL_LINE_TABLE_NETHER = list(/datum/micro_organism/cell_line/netherworld = 1),
	CELL_LINE_TABLE_CLOWN = list(/datum/micro_organism/cell_line/clown/bananaclown = 1, /datum/micro_organism/cell_line/clown/glutton = 1, /datum/micro_organism/cell_line/clown/longclown = 1),
	CELL_LINE_TABLE_GLUTTON = list(/datum/micro_organism/cell_line/clown/glutton = 1)
	))

///Assoc list of cell virus define | assoc list of datum | cell_virus
GLOBAL_LIST_INIT(cell_virus_tables, list(
	CELL_VIRUS_TABLE_GENERIC = list(/datum/micro_organism/virus = 1),
	CELL_VIRUS_TABLE_GENERIC_MOB = list(/datum/micro_organism/virus = 1)
	))

///List of all possible sample colors
GLOBAL_LIST_INIT(xeno_sample_colors, list(COLOR_SAMPLE_YELLOW, COLOR_SAMPLE_PURPLE, COLOR_SAMPLE_GREEN, COLOR_SAMPLE_BROWN, COLOR_SAMPLE_GRAY))
