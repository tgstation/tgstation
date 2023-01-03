/// These tests perform no behavior of their own, and have their tests offloaded onto other procs.
/// This is useful in cases like in build_appearance_list where we want to know if any fail,
/// but is not useful to right a test for.
/// This file exists so that you can change any of these to TEST_FOCUS and only check for that test.
/// For example, change /datum/unit_test/focus_only/invalid_overlays to TEST_FOCUS(/datum/unit_test/focus_only/invalid_overlays),
/// and you will only test the check for invalid overlays in appearance building.
/datum/unit_test/focus_only

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
