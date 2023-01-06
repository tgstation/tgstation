#define BASIC_MOB_MAX_STAMINALOSS 200

///Basic mob flags
#define DEL_ON_DEATH (1<<0)
#define FLIP_ON_DEATH (1<<1)
#define UNDENSIFY_ON_DEATH (1<<2)
/// fails unit tests if the mob has no atmos requirements yet doesn't have this flag
#define NO_ATMOS_REQUIREMENTS (1<<3)
/// fails unit tests if the mob has no temperature limits yet doesn't have this flag
#define NO_TEMP_SENSITIVITY (1<<4)
/// fails unit tests if the mob has no possibility of sentience yet doesn't have this flag
#define NO_SENTIENCE_POSSIBILITY (1<<5)

/// typical atmos requirements you'd expect most mobs who have atmos requirements at all to have.
#define BASIC_ATMOS_REQUIREMENTS string_assoc_list(list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0))
