///These global lists exist to allow our element to have weight tables without having to be seperate instances.

///Assoc list of cell line define | assoc list of datum | cell_line
GLOBAL_LIST_INIT_TYPED(cell_line_tables, /list, list(
	CELL_LINE_TABLE_DUMPSTER = list(/datum/micro_organism/cell_line/mouse = 3, /datum/micro_organism/cell_line/chicken = 2, /datum/micro_organism/cell_line/cockroach = 2)
	))

///Assoc list of cell virus define | assoc list of datum | cell_virus
GLOBAL_LIST_INIT(cell_virus_tables, list(
	CELL_VIRUS_TABLE_DUMPSTER = list(/datum/micro_organism/virus = 1)
	))

///List of all possible sample colors
GLOBAL_LIST_INIT(xeno_sample_colors, list(SAMPLE_YELLOW, SAMPLE_PURPLE, SAMPLE_GREEN, SAMPLE_BROWN, SAMPLE_GRAY))
