///Defines for the R&D console, see: [/modules/research/rdconsole][rdconsole]
#define RDCONSOLE_UI_MODE_NORMAL 1
#define RDCONSOLE_UI_MODE_EXPERT 2
#define RDCONSOLE_UI_MODE_LIST 3

#define RDSCREEN_MENU 0
#define RDSCREEN_TECHDISK 1
#define RDSCREEN_DESIGNDISK 20
#define RDSCREEN_DESIGNDISK_UPLOAD 21
#define RDSCREEN_DECONSTRUCT 3
#define RDSCREEN_PROTOLATHE 40
#define RDSCREEN_PROTOLATHE_MATERIALS 41
#define RDSCREEN_PROTOLATHE_CHEMICALS 42
#define RDSCREEN_PROTOLATHE_CATEGORY_VIEW 43
#define RDSCREEN_PROTOLATHE_SEARCH 44
#define RDSCREEN_IMPRINTER 50
#define RDSCREEN_IMPRINTER_MATERIALS 51
#define RDSCREEN_IMPRINTER_CHEMICALS 52
#define RDSCREEN_IMPRINTER_CATEGORY_VIEW 53
#define RDSCREEN_IMPRINTER_SEARCH 54
#define RDSCREEN_SETTINGS 61
#define RDSCREEN_DEVICE_LINKING 62
#define RDSCREEN_TECHWEB 70
#define RDSCREEN_TECHWEB_NODEVIEW 71
#define RDSCREEN_TECHWEB_DESIGNVIEW 72

#define RDSCREEN_NOBREAK "<NO_HTML_BREAK>"

///Sanity check defines for when these devices aren't connected or no disk is inserted
#define RDSCREEN_TEXT_NO_PROTOLATHE "<div><h3>No Protolathe Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_IMPRINTER "<div><h3>No Circuit Imprinter Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_DECONSTRUCT "<div><h3>No Destructive Analyzer Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_TDISK "<div><h3>No Technology Disk Inserted!</h3></div><br>"
#define RDSCREEN_TEXT_NO_DDISK "<div><h3>No Design Disk Inserted!</h3></div><br>"
#define RDSCREEN_TEXT_NO_SNODE "<div><h3>No Technology Node Selected!</h3></div><br>"
#define RDSCREEN_TEXT_NO_SDESIGN "<div><h3>No Design Selected!</h3></div><br>"

#define RDSCREEN_UI_LATHE_CHECK if(QDELETED(linked_lathe)) { return RDSCREEN_TEXT_NO_PROTOLATHE }
#define RDSCREEN_UI_IMPRINTER_CHECK if(QDELETED(linked_imprinter)) { return RDSCREEN_TEXT_NO_IMPRINTER }
#define RDSCREEN_UI_DECONSTRUCT_CHECK if(QDELETED(linked_destroy)) { return RDSCREEN_TEXT_NO_DECONSTRUCT }
#define RDSCREEN_UI_TDISK_CHECK if(QDELETED(t_disk)) { return RDSCREEN_TEXT_NO_TDISK }
#define RDSCREEN_UI_DDISK_CHECK if(QDELETED(d_disk)) { return RDSCREEN_TEXT_NO_DDISK }
#define RDSCREEN_UI_SNODE_CHECK if(!selected_node) { return RDSCREEN_TEXT_NO_SNODE }
#define RDSCREEN_UI_SDESIGN_CHECK if(!selected_design) { return RDSCREEN_TEXT_NO_SDESIGN }

///Defines for the Protolathe screens, see: [/modules/research/machinery/protolathe][Protolathe]
#define RESEARCH_FABRICATOR_SCREEN_MAIN 1
#define RESEARCH_FABRICATOR_SCREEN_CHEMICALS 2
#define RESEARCH_FABRICATOR_SCREEN_MATERIALS 3
#define RESEARCH_FABRICATOR_SCREEN_SEARCH 4
#define RESEARCH_FABRICATOR_SCREEN_CATEGORYVIEW 5

///Department flags for techwebs. Defines which department can print what from each protolathe so Cargo can't print guns, etc.
#define DEPARTMENTAL_FLAG_SECURITY		(1<<0)
#define DEPARTMENTAL_FLAG_MEDICAL		(1<<1)
#define DEPARTMENTAL_FLAG_CARGO			(1<<2)
#define DEPARTMENTAL_FLAG_SCIENCE		(1<<3)
#define DEPARTMENTAL_FLAG_ENGINEERING	(1<<4)
#define DEPARTMENTAL_FLAG_SERVICE		(1<<5)

#define DESIGN_ID_IGNORE "IGNORE_THIS_DESIGN"			///For instances where we don't want a design showing up due to it being for debug/sanity purposes

#define RESEARCH_MATERIAL_RECLAMATION_ID "__materials"

///Techweb names for new point types. Can be used to define specific point values for specific types of research (science, security, engineering, etc.)
#define TECHWEB_POINT_TYPE_GENERIC "General Research"
#define TECHWEB_POINT_TYPE_NANITES "Nanite Research"

#define TECHWEB_POINT_TYPE_DEFAULT TECHWEB_POINT_TYPE_GENERIC

///Associative names for techweb point values, see: [/modules/research/techweb/all_nodes][all_nodes]
#define TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES list(\
	TECHWEB_POINT_TYPE_GENERIC = "General Research",\
	TECHWEB_POINT_TYPE_NANITES = "Nanite Research"\
	)

///R&D point value for a maxcap bomb. Can be adjusted if need be. Current Value Cap Radius: 100
#define TECHWEB_BOMB_POINTCAP		50000

///Research point values for slime extracts, see: [/modules/research/xenobiology/xenobio_camera][xenobio_camera]
#define SLIME_RESEARCH_TIER_0 100
#define SLIME_RESEARCH_TIER_1 500
#define SLIME_RESEARCH_TIER_2 1000
#define SLIME_RESEARCH_TIER_3 1500
#define SLIME_RESEARCH_TIER_4 2000
#define SLIME_RESEARCH_TIER_5 2500
#define SLIME_RESEARCH_TIER_RAINBOW 5000
