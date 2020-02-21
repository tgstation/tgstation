///These global lists exist to allow our element to have weight tables without having to be seperate instances.

///Assoc list of cell line define | assoc list of datum | cell_line
GLOBAL_LIST_INIT(cell_line_tables,
CELL_LINE_TABLE_DUMPSTER = list(/datum/micro_organism/cell_line/rat = 3, /datum/micro_organism/cell_line/gelatinous = 2, /datum/micro_organism/cell_line/cockroach = 2))

///Assoc list of cell virus define | assoc list of datum | cell_virus
GLOBAL_LIST_INIT(cell_virus_tables,
CELL_VIRUS_TABLE_DUMPSTER = list(/datum/micro_organism/cell_virus = 1))
