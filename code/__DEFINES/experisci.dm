#define EXPERIMENT_CONFIG_ATTACKSELF "experiment_config_attackself"
#define EXPERIMENT_CONFIG_ALTCLICK "experiment_config_altclick"
#define EXPERIMENT_CONFIG_CLICK "experiment_config_click"
#define EXPERIMENT_CONFIG_UI "experiment_config_ui"

/// Boolean stage, complete/incomplete. No specific progress to report.
#define EXPERIMENT_BOOL_STAGE "bool"
/// Integer stages, should be whole numbers with total being included
/// to support rendering ``value of total``, or something akin to it.
#define EXPERIMENT_INT_STAGE "integer"
/// Float stages, the value should be between 0 and 1 representing percent completion
#define EXPERIMENT_FLOAT_STAGE "float"
/// Detail stages, only provide more textual information and have no inherent progress
#define EXPERIMENT_DETAIL_STAGE "detail"

/// Macro for defining a progress stage
#define EXPERIMENT_PROGRESS(type, desc, values...) list(list(type, desc, values))
/// Macro for boolean stages
#define EXPERIMENT_PROG_BOOL(desc, complete) EXPERIMENT_PROGRESS(EXPERIMENT_BOOL_STAGE, desc, complete)
/// Macro for integer stages
#define EXPERIMENT_PROG_INT(desc, complete, total) EXPERIMENT_PROGRESS(EXPERIMENT_INT_STAGE, desc, complete, total)
/// Macro for float stages
#define EXPERIMENT_PROG_FLOAT(desc, complete) EXPERIMENT_PROGRESS(EXPERIMENT_FLOAT_STAGE, desc, complete)
/// Macro for non-valued stages, details for exp stages
#define EXPERIMENT_PROG_DETAIL(desc, complete) EXPERIMENT_PROGRESS(EXPERIMENT_DETAIL_STAGE, desc, complete)

/// Destructive experiments which will destroy the sample
#define EXPERIMENT_TRAIT_DESTRUCTIVE (1 << 0)
/// Used by scanning experiments: instead of storing refs or be a number, the list for scanned atoms is used as typecache
#define EXPERIMENT_TRAIT_TYPECACHE (1 << 1)

/// Will always attempt to action every experiment eligible with a single input,
/// no experiment selection required
#define EXPERIMENT_CONFIG_ALWAYS_ACTIVE (1 << 0)
/// Experiment handlers with this flag will not automatically connect to the first techweb they find
/// on initialization
#define EXPERIMENT_CONFIG_NO_AUTOCONNECT (1 << 1)
/// Experiment handlers with this flag won't pester the user of objects not pertinent to the test or if no experiment is selected
#define EXPERIMENT_CONFIG_SILENT_FAIL (1 << 2)
/// Experiment handlers with this flag will bypass any delay when trying to scan something
#define EXPERIMENT_CONFIG_IMMEDIATE_ACTION (1 << 3)
