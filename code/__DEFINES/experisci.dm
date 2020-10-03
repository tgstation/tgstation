#define EXPERIMENT_CONFIG_ATTACKSELF 	"experiment_config_attackself"
#define EXPERIMENT_CONFIG_ALTCLICK 		"experiment_config_altclick"

/// Boolean stage, complete/incomplete. No specific progress to report.
#define EXP_BOOL_STAGE	"bool"
/// Integer stages, should be whole numbers with total being included
/// to ssupport rendering ``value of total``, or something akin to it.
#define EXP_INT_STAGE	"integer"
/// Float stages, the value should be between 0 and 1 representing percent completion
#define EXP_FLOAT_STAGE	"float"

/// Macro for defining a progress stage
#define EXP_PROGRESS(type, desc, values...)	list(list(type, desc, values))
/// Macro for boolean stages
#define EXP_PROG_BOOL(desc, complete) EXP_PROGRESS(EXP_BOOL_STAGE, desc, complete)
/// Macro for integer stages
#define EXP_PROG_INT(desc, complete, total) EXP_PROGRESS(EXP_INT_STAGE, desc, complete, total)
/// Macro for float stages
#define EXP_PROG_FLOAT(desc, complete) EXP_PROGRESS(EXP_FLOAT_STAGE, desc, complete)
