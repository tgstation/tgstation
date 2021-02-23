#define EXPERIMENT_CONFIG_ATTACKSELF "experiment_config_attackself"
#define EXPERIMENT_CONFIG_ALTCLICK "experiment_config_altclick"
#define EXPERIMENT_CONFIG_CLICK	"experiment_config_click"
#define EXPERIMENT_CONFIG_UI "experiment_config_ui"

/// Boolean stage, complete/incomplete. No specific progress to report.
#define EXP_BOOL_STAGE "bool"
/// Integer stages, should be whole numbers with total being included
/// to support rendering ``value of total``, or something akin to it.
#define EXP_INT_STAGE "integer"
/// Float stages, the value should be between 0 and 1 representing percent completion
#define EXP_FLOAT_STAGE	"float"
/// Detail stages, only provide more textual information and have no inherent progress
#define EXP_DETAIL_STAGE "detail"

/// Macro for defining a progress stage
#define EXP_PROGRESS(type, desc, values...)	list(list(type, desc, values))
/// Macro for boolean stages
#define EXP_PROG_BOOL(desc, complete) EXP_PROGRESS(EXP_BOOL_STAGE, desc, complete)
/// Macro for integer stages
#define EXP_PROG_INT(desc, complete, total) EXP_PROGRESS(EXP_INT_STAGE, desc, complete, total)
/// Macro for float stages
#define EXP_PROG_FLOAT(desc, complete) EXP_PROGRESS(EXP_FLOAT_STAGE, desc, complete)
/// Macro for non-valued stages, details for exp stages
#define EXP_PROG_DETAIL(desc, complete) EXP_PROGRESS(EXP_DETAIL_STAGE, desc, complete)

/// Destructive experiments which will destroy the sample
#define EXP_TRAIT_DESTRUCTIVE (1 << 0)

/// Will always attempt to action every experiment eligible with a single input,
/// no experiment selection required
#define EXPERIMENT_CONFIG_ALWAYS_ACTIVE	(1 << 0)
/// Experiment handlers with this flag will not automatically connect to the first techweb they find
/// on initialization
#define EXPERIMENT_CONFIG_NO_AUTOCONNECT (1 << 1)
