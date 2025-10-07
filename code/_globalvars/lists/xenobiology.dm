///These global lists exist to allow our element to have weight tables without having to be separate instances.

///Assoc list of cell line define | assoc list of datum | cell_line
GLOBAL_LIST_INIT_TYPED(cell_line_tables, /list, list(
	CELL_LINE_TABLE_SLUDGE = list(
		/datum/micro_organism/cell_line/blobbernaut = 1,
		/datum/micro_organism/cell_line/chicken = 1,
		/datum/micro_organism/cell_line/cockroach = 2,
		/datum/micro_organism/cell_line/cow = 1,
		/datum/micro_organism/cell_line/mouse = 1,
		/datum/micro_organism/cell_line/sholean_grapes = 2,
		/datum/micro_organism/cell_line/slime = 2,
	),

	CELL_LINE_TABLE_MOIST = list(
		/datum/micro_organism/cell_line/carp = 1,
		/datum/micro_organism/cell_line/cockroach = 1,
		/datum/micro_organism/cell_line/gelatinous_cube = 2,
		/datum/micro_organism/cell_line/megacarp = 1,
		/datum/micro_organism/cell_line/slime = 2,
		/datum/micro_organism/cell_line/snake = 1,
		/datum/micro_organism/cell_line/glockroach = 1,
		/datum/micro_organism/cell_line/hauberoach = 1,
	),

	CELL_LINE_TABLE_BLOB = list(
		/datum/micro_organism/cell_line/blob_spore = 1,
		/datum/micro_organism/cell_line/blobbernaut = 1,
	),

	CELL_LINE_TABLE_MOLD = list(
		/datum/micro_organism/cell_line/bear = 1,
		/datum/micro_organism/cell_line/blob_spore = 1,
		/datum/micro_organism/cell_line/cat = 1,
		/datum/micro_organism/cell_line/cockroach = 1,
		/datum/micro_organism/cell_line/corgi = 1,
		/datum/micro_organism/cell_line/mouse = 2,
		/datum/micro_organism/cell_line/slime = 1,
		/datum/micro_organism/cell_line/vat_beast = 2,
	),

	CELL_LINE_TABLE_BEAR = list(/datum/micro_organism/cell_line/bear = 1),
	CELL_LINE_TABLE_BLOBBERNAUT = list(/datum/micro_organism/cell_line/blobbernaut = 1),
	CELL_LINE_TABLE_BLOBSPORE = list(/datum/micro_organism/cell_line/blob_spore = 1),
	CELL_LINE_TABLE_CARP = list(/datum/micro_organism/cell_line/carp = 1),
	CELL_LINE_TABLE_CAT = list(/datum/micro_organism/cell_line/cat = 1),
	CELL_LINE_TABLE_CHICKEN = list(/datum/micro_organism/cell_line/chicken = 1),
	CELL_LINE_TABLE_COCKROACH = list(/datum/micro_organism/cell_line/cockroach = 1),
	CELL_LINE_TABLE_CORGI = list(/datum/micro_organism/cell_line/corgi = 1),
	CELL_LINE_TABLE_COW = list(/datum/micro_organism/cell_line/cow = 1),
	CELL_LINE_TABLE_MOONICORN = list(/datum/micro_organism/cell_line/moonicorn = 1),
	CELL_LINE_TABLE_GELATINOUS = list(/datum/micro_organism/cell_line/gelatinous_cube = 1),
	CELL_LINE_TABLE_GLOCKROACH = list(/datum/micro_organism/cell_line/glockroach = 1),
	CELL_LINE_TABLE_GRAPE = list(/datum/micro_organism/cell_line/sholean_grapes = 1),
	CELL_LINE_TABLE_HAUBEROACH = list(/datum/micro_organism/cell_line/hauberoach = 1),
	CELL_LINE_TABLE_MEGACARP = list(/datum/micro_organism/cell_line/megacarp = 1),
	CELL_LINE_TABLE_MOUSE = list(/datum/micro_organism/cell_line/mouse = 1),
	CELL_LINE_TABLE_PINE = list(/datum/micro_organism/cell_line/pine = 1),
	CELL_LINE_TABLE_PUG = list(/datum/micro_organism/cell_line/pug = 1),
	CELL_LINE_TABLE_SLIME = list(/datum/micro_organism/cell_line/slime = 1),
	CELL_LINE_TABLE_SNAKE = list(/datum/micro_organism/cell_line/snake = 1),
	CELL_LINE_TABLE_SNAIL = list(/datum/micro_organism/cell_line/snail = 1),
	CELL_LINE_TABLE_VATBEAST = list(/datum/micro_organism/cell_line/vat_beast = 1),
	CELL_LINE_TABLE_NETHER = list(/datum/micro_organism/cell_line/netherworld = 1),
	CELL_LINE_TABLE_CLOWN = list(
		/datum/micro_organism/cell_line/clown/bananaclown = 1,
		/datum/micro_organism/cell_line/clown/glutton = 1,
		/datum/micro_organism/cell_line/clown/longclown = 1,
	),

	CELL_LINE_TABLE_GLUTTON = list(/datum/micro_organism/cell_line/clown/glutton = 1),
	CELL_LINE_TABLE_CLOWNANA = list(/datum/micro_organism/cell_line/clown/bananaclown = 1),
	CELL_LINE_TABLE_LONGFACE = list(/datum/micro_organism/cell_line/clown/longclown = 1),
	CELL_LINE_TABLE_FROG = list(/datum/micro_organism/cell_line/frog = 1),
	CELL_LINE_TABLE_AXOLOTL = list(/datum/micro_organism/cell_line/axolotl = 1),
	CELL_LINE_TABLE_WALKING_MUSHROOM = list(/datum/micro_organism/cell_line/walking_mushroom = 1),
	CELL_LINE_TABLE_QUEEN_BEE = list(/datum/micro_organism/cell_line/queen_bee = 1),
	CELL_LINE_TABLE_BUTTERFLY = list(/datum/micro_organism/cell_line/butterfly = 1),
	CELL_LINE_TABLE_MEGA_ARACHNID = list(/datum/micro_organism/cell_line/mega_arachnid = 1),
	CELL_LINE_TABLE_ALGAE = list(
		/datum/micro_organism/cell_line/frog = 2,
		/datum/micro_organism/cell_line/mega_arachnid = 1,
		/datum/micro_organism/cell_line/queen_bee = 1,
		/datum/micro_organism/cell_line/butterfly = 1,
		/datum/micro_organism/cell_line/snake = 1,
		/datum/micro_organism/cell_line/walking_mushroom = 2,
		/datum/micro_organism/cell_line/axolotl = 1,
	),
	CELL_LINE_ORGAN_HEART = list(
		/datum/micro_organism/cell_line/organs/heart = 3,
		/datum/micro_organism/cell_line/organs/heart/evolved = 1,
	),
	CELL_LINE_ORGAN_HEART_CURSED = list(
		/datum/micro_organism/cell_line/organs/heart/corrupt = 1,
		/datum/micro_organism/cell_line/organs/heart/sacred = 1,
	),
	CELL_LINE_ORGAN_LUNGS = list(
		/datum/micro_organism/cell_line/organs/lungs = 3,
		/datum/micro_organism/cell_line/organs/lungs/evolved = 1,
	),
	CELL_LINE_ORGAN_LIVER = list(
		/datum/micro_organism/cell_line/organs/liver = 3,
		/datum/micro_organism/cell_line/organs/liver/evolved = 1,
		/datum/micro_organism/cell_line/organs/liver/bloody = 1,
		/datum/micro_organism/cell_line/organs/liver/distillery = 1,
	),
	CELL_LINE_ORGAN_STOMACH = list(
		/datum/micro_organism/cell_line/organs/stomach = 3,
		/datum/micro_organism/cell_line/organs/stomach/evolved = 1,
	),
))

///Assoc list of cell virus define | assoc list of datum | cell_virus
GLOBAL_LIST_INIT(cell_virus_tables, list(
	CELL_VIRUS_TABLE_GENERIC = list(/datum/micro_organism/virus = 1),
	CELL_VIRUS_TABLE_GENERIC_MOB = list(/datum/micro_organism/virus = 1)
	))

///List of all possible sample colors
GLOBAL_LIST_INIT(xeno_sample_colors, list(
	COLOR_SAMPLE_BROWN,
	COLOR_SAMPLE_GRAY,
	COLOR_SAMPLE_GREEN,
	COLOR_SAMPLE_PURPLE,
	COLOR_SAMPLE_YELLOW,
))
