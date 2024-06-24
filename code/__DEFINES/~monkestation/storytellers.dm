
//Could be bitflags, but that would require a good amount of translations, which eh, either way works for me
/// When the event is combat oriented (spawning monsters, inherently hostile antags)
#define TAG_COMBAT "combat"
/// When the event is spooky (broken lights, some antags)
#define TAG_SPOOKY "spooky"
/// When the event is destructive in a decent capacity (meteors, blob)
#define TAG_DESTRUCTIVE "destructive"
/// When the event impacts most of the crewmembers in some capacity (comms blackout)
#define TAG_COMMUNAL "communal"
/// When the event targets a person for something (appendix, heart attack)
#define TAG_TARGETED "targeted"
/// When the event is positive and helps the crew, in some capacity (Shuttle Loan, Supply Pod)
#define TAG_POSITIVE "positive"
/// When one of the crewmembers becomes an antagonist
#define TAG_CREW_ANTAG "crew_antag"
/// When the antagonist event is focused around team cooperation.
#define TAG_TEAM_ANTAG "team_antag"
/// When one of the non-crewmember players becomes an antagonist
#define TAG_OUTSIDER_ANTAG "away_antag"
/// When the event impacts the overmap
#define TAG_OVERMAP "overmap"
/// When the event requires the station to be in space (meteors, carp)
#define TAG_SPACE "space"
/// When the event requires the station to be planetary.
#define TAG_PLANETARY "planetary"
/// When the event is an external threat (meteors, nukies).
#define TAG_EXTERNAL "external"
/// When the event is an alien threat (blob, xenos)
#define TAG_ALIEN "alien"
/// When the event is magical in nature
#define TAG_MAGICAL "magical"

#define EVENT_TRACK_MUNDANE "Mundane"
#define EVENT_TRACK_MODERATE "Moderate"
#define EVENT_TRACK_MAJOR "Major"
#define EVENT_TRACK_ROLESET "Roleset"
#define EVENT_TRACK_OBJECTIVES "Objectives"

#define ALL_EVENTS "All"
#define UNCATEGORIZED_EVENTS "Uncategorized"

#define STORYTELLER_WAIT_TIME 5 SECONDS

#define EVENT_POINT_GAINED_PER_SECOND 0.08

#define TRACK_FAIL_POINT_PENALTY_MULTIPLIER 0.75

#define GAMEMODE_PANEL_MAIN "Main"
#define GAMEMODE_PANEL_VARIABLES "Variables"

#define MUNDANE_POINT_THRESHOLD 40
#define MODERATE_POINT_THRESHOLD 70
#define MAJOR_POINT_THRESHOLD 130
#define ROLESET_POINT_THRESHOLD 150
#define OBJECTIVES_POINT_THRESHOLD 170

#define MUNDANE_MIN_POP 4
#define MODERATE_MIN_POP 6
#define MAJOR_MIN_POP 20
#define ROLESET_MIN_POP 25
#define OBJECTIVES_MIN_POP 20

/// Defines for how much pop do we need to stop applying a pop scalling penalty to event frequency.
#define MUNDANE_POP_SCALE_THRESHOLD 25
#define MODERATE_POP_SCALE_THRESHOLD 32
#define MAJOR_POP_SCALE_THRESHOLD 45
#define ROLESET_POP_SCALE_THRESHOLD 45
#define OBJECTIVES_POP_SCALE_THRESHOLD 45

/// The maximum penalty coming from pop scalling, when we're at the most minimum point, easing into 0 as we reach the SCALE_THRESHOLD. This is treated as a percentage.
#define MUNDANE_POP_SCALE_PENALTY 35
#define MODERATE_POP_SCALE_PENALTY 35
#define MAJOR_POP_SCALE_PENALTY 35
#define ROLESET_POP_SCALE_PENALTY 35
#define OBJECTIVES_POP_SCALE_PENALTY 35

#define STORYTELLER_VOTE "storyteller"

#define EVENT_TRACKS list(EVENT_TRACK_MUNDANE, EVENT_TRACK_MODERATE, EVENT_TRACK_MAJOR, EVENT_TRACK_ROLESET, EVENT_TRACK_OBJECTIVES)
#define EVENT_PANEL_TRACKS list(EVENT_TRACK_MUNDANE, EVENT_TRACK_MODERATE, EVENT_TRACK_MAJOR, EVENT_TRACK_ROLESET, EVENT_TRACK_OBJECTIVES, UNCATEGORIZED_EVENTS, ALL_EVENTS)

/// Defines for the antag cap to prevent midround injections.
#define ANTAG_CAP_FLAT 3
#define ANTAG_CAP_DENOMINATOR 30

///Below are defines for roundstart point pool. The GAIN ones are multiplied by ready population
#define ROUNDSTART_MUNDANE_BASE 20
#define ROUNDSTART_MUNDANE_GAIN 0.5

#define ROUNDSTART_MODERATE_BASE 35
#define ROUNDSTART_MODERATE_GAIN 1.2

#define ROUNDSTART_MAJOR_BASE 40
#define ROUNDSTART_MAJOR_GAIN 2

#define ROUNDSTART_ROLESET_BASE 60
#define ROUNDSTART_ROLESET_GAIN 2

#define ROUNDSTART_OBJECTIVES_BASE 40
#define ROUNDSTART_OBJECTIVES_GAIN 2

#define SHARED_HIGH_THREAT	"high threat event"
#define SHARED_ANOMALIES	"anomalous event"
#define SHARED_SCRUBBERS	"scrubber-related event"
#define SHARED_METEORS		"meteor event"
#define SHARED_BSOD			"tech malfunction event"
#define SHARED_CHANGELING	"changelings"
