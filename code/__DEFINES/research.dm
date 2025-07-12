/// For instances where we don't want a design showing up due to it being for debug/sanity purposes
#define DESIGN_ID_IGNORE "IGNORE_THIS_DESIGN"

//! Techweb names for new point types. Can be used to define specific point values for specific types of research (science, security, engineering, etc.)
#define TECHWEB_POINT_TYPE_GENERIC "General Research"

//!  Amount of points required to unlock nodes of corresponding tiers
#define TECHWEB_TIER_1_POINTS 40
#define TECHWEB_TIER_2_POINTS 80
#define TECHWEB_TIER_3_POINTS 120
#define TECHWEB_TIER_4_POINTS 160
#define TECHWEB_TIER_5_POINTS 200

//! Amount of points gained per second by a single R&D server, see: [research][code/controllers/subsystem/research.dm]
#define TECHWEB_SINGLE_SERVER_INCOME 1

//! Swab cell line types
#define CELL_LINE_TABLE_SLUDGE "cell_line_sludge_table"
#define CELL_LINE_TABLE_MOLD "cell_line_mold_table"
#define CELL_LINE_TABLE_MOIST "cell_line_moist_table"
#define CELL_LINE_TABLE_BLOB "cell_line_blob_table"
#define CELL_LINE_TABLE_CLOWN "cell_line_clown_table"
#define CELL_LINE_TABLE_ALGAE "cell_line_algae_table"

//! Biopsy cell line types
#define CELL_LINE_TABLE_BEAR "cell_line_bear_table"
#define CELL_LINE_TABLE_BLOBBERNAUT "cell_line_blobbernaut_table"
#define CELL_LINE_TABLE_BLOBSPORE "cell_line_blobspore_table"
#define CELL_LINE_TABLE_CARP "cell_line_carp_table"
#define CELL_LINE_TABLE_CAT "cell_line_cat_table"
#define CELL_LINE_TABLE_CHICKEN "cell_line_chicken_table"
#define CELL_LINE_TABLE_COCKROACH "cell_line_cockroach_table"
#define CELL_LINE_TABLE_CORGI "cell_line_corgi_table"
#define CELL_LINE_TABLE_COW "cell_line_cow_table"
#define CELL_LINE_TABLE_MOONICORN "cell_line_moonicorn_table"
#define CELL_LINE_TABLE_GELATINOUS "cell_line_gelatinous_table"
#define CELL_LINE_TABLE_GLOCKROACH "cell_line_glockroach_table"
#define CELL_LINE_TABLE_GRAPE "cell_line_grape_table"
#define CELL_LINE_TABLE_HAUBEROACH "cell_line_hauberoach_table"
#define CELL_LINE_TABLE_MEGACARP "cell_line_megacarp_table"
#define CELL_LINE_TABLE_MOUSE "cell_line_mouse_table"
#define CELL_LINE_TABLE_PINE "cell_line_pine_table"
#define CELL_LINE_TABLE_PUG "cell_line_pug_table"
#define CELL_LINE_TABLE_SLIME "cell_line_slime_table"
#define CELL_LINE_TABLE_SNAKE "cell_line_snake_table"
#define CELL_LINE_TABLE_SNAIL "cell_line_snail_table"
#define CELL_LINE_TABLE_VATBEAST "cell_line_vatbeast_table"
#define CELL_LINE_TABLE_NETHER "cell_line_nether_table"
#define CELL_LINE_TABLE_GLUTTON "cell_line_glutton_table"
#define CELL_LINE_TABLE_CLOWNANA "cell_line_clownana_table"
#define CELL_LINE_TABLE_LONGFACE "cell_line_longface_table"
#define CELL_LINE_TABLE_FROG	"cell_line_frog_table"
#define CELL_LINE_TABLE_AXOLOTL	"cell_line_axolotl_table"
#define CELL_LINE_TABLE_WALKING_MUSHROOM "cell_line_walking_mushroom_table"
#define CELL_LINE_TABLE_QUEEN_BEE "cell_line_bee_queen_table"
#define CELL_LINE_TABLE_BUTTERFLY "cell_line_butterfly_table"
#define CELL_LINE_TABLE_MEGA_ARACHNID "cell_line_table_mega_arachnid"

//! Biopsy cell line organ types
#define CELL_LINE_ORGAN_HEART "cell_line_organ_heart"
#define CELL_LINE_ORGAN_LUNGS "cell_line_organ_lungs"
#define CELL_LINE_ORGAN_LIVER "cell_line_organ_liver"
#define CELL_LINE_ORGAN_STOMACH "cell_line_organ_stomach"

#define CELL_LINE_ORGAN_HEART_CURSED "cell_line_organ_heart_cursed"

//! All cell virus types
#define CELL_VIRUS_TABLE_GENERIC "cell_virus_generic_table"
#define CELL_VIRUS_TABLE_GENERIC_MOB "cell_virus_generic_mob_table"

//! General defines for vatgrowing
/// Past how much growth can the other cell_lines affect a finished cell line negatively
#define VATGROWING_DANGER_MINIMUM 30
//Defines how many percent of vat grown atoms come out as hue shifted color mutants. A flat chance for now, maybe in the future dependant on the cell line.
#define CYTO_SHINY_CHANCE 15

#define SCIPAPER_COOPERATION_INDEX 1
#define SCIPAPER_FUNDING_INDEX 2
#define SCIENTIFIC_COOPERATION_PURCHASE_MULTIPLIER 0.01
/// How much money is one point of gain worth.
#define SCIPAPER_GAIN_TO_MONEY 125

///Connects the 'server_var' to a valid research server on your Z level.
///Used for machines in LateInitialize, to ensure that RND servers are loaded first.
#define CONNECT_TO_RND_SERVER_ROUNDSTART(server_var, holder) do { \
	var/list/found_servers = SSresearch.get_available_servers(get_turf(holder)); \
	var/obj/machinery/rnd/server/selected_server = length(found_servers) ? found_servers[1] : null; \
	if (selected_server) { \
		server_var = selected_server.stored_research; \
	}; \
	else { \
		var/datum/techweb/station_fallback_web = locate(/datum/techweb/science) in SSresearch.techwebs; \
		server_var = station_fallback_web; \
	}; \
} while (FALSE)
