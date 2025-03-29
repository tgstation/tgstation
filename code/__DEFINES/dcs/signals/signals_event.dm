// Grey Tide event signals
/// Sent when the Grey Tide event begins affecting the station.
/// (list/area/greytide_areas)
#define COMSIG_GLOB_GREY_TIDE "grey_tide"

/// A different signal, used specifically for flickering the lights during the event
#define COMSIG_GLOB_GREY_TIDE_LIGHT "grey_tide_light"

/// Signal sent by round event controls when they create round event datums before calling setup() on them: (datum/round_event_control/source_event_control, datum/round_event/created_event)
#define COMSIG_CREATED_ROUND_EVENT "creating_round_event"

//* HOLIDAYS

/// April fools
/// Signal sent when the quartic reliquary updates its input contents
#define COMSIG_RELIQUARY_CONTENTS_UPDATED "reliquary_contents_updated"
/// Signal sent when the quartic reliquary finishes folding
#define COMSIG_RELIQUARY_FOLDING_COMPLETE "reliquary_folding_complete"
