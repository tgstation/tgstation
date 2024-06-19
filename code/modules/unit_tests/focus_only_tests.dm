/// These tests perform no behavior of their own, and have their tests offloaded onto other procs.
/// This is useful in cases like in build_appearance_list where we want to know if any fail,
/// but is not useful to right a test for.
/// This file exists so that you can change any of these to TEST_FOCUS and only check for that test.
/// For example, change /datum/unit_test/focus_only/invalid_overlays to TEST_FOCUS(/datum/unit_test/focus_only/invalid_overlays),
/// and you will only test the check for invalid overlays in appearance building.
/datum/unit_test/focus_only

/// Checks that every created emissive has a valid icon_state
/datum/unit_test/focus_only/invalid_emissives

/// Checks that every overlay passed into build_appearance_list exists in the icon
/datum/unit_test/focus_only/invalid_overlays

/// Checks that every icon sent to the research_designs spritesheet is valid
/datum/unit_test/focus_only/invalid_research_designs

/// Checks that every icon sent to vending machines is valid
/datum/unit_test/focus_only/invalid_vending_machine_icon_states

/// Checks that space does not initialize multiple times
/datum/unit_test/focus_only/multiple_space_initialization

/// Checks that smoothing_groups and canSmoothWith are properly sorted in /atom/Initialize
/datum/unit_test/focus_only/sorted_smoothing_groups

/// Checks that floor tiles are properly mapped to broken/burnt
/datum/unit_test/focus_only/valid_turf_states

/// Checks that nightvision eyes have a full set of color lists
/datum/unit_test/focus_only/nightvision_color_cutoffs

/// Checks that no light shares a tile/pixel offsets with another
/datum/unit_test/focus_only/stacked_lights

/// Checks for bad icon / icon state setups in cooking crafting menu
/datum/unit_test/focus_only/bad_cooking_crafting_icons

/// Ensures openspace never spawns on the bottom of a z stack
/datum/unit_test/focus_only/openspace_clear

/// Checks to ensure that variables expected to exist in a job datum (for config reasons) actually exist
/datum/unit_test/focus_only/missing_job_datum_variables

/// Checks that the contents of the fish_counts list are also present in fish_table
/datum/unit_test/focus_only/fish_sources_tables

/// Checks that maploaded mobs with either the `atmos_requirements` or `body_temp_sensitive`
/datum/unit_test/focus_only/atmos_and_temp_requirements
