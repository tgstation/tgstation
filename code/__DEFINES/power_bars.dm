#define POWER_BAR_DEPARTMENT_COMMON "common"
#define POWER_BAR_DEPARTMENT_CARGO "cargo"
#define POWER_BAR_DEPARTMENT_ENGINEERING "engineering"
#define POWER_BAR_DEPARTMENT_MEDICAL "medical"
#define POWER_BAR_DEPARTMENT_SCIENCE "science"
#define POWER_BAR_DEPARTMENT_SECURITY "security"

#define POWER_BAR_DONT_REACT (1 << 0)

// Feature flags to be flipped in TGS for live configuration
#define POWER_BAR_FLAG(flag, default) (max(-1, ##flag) == -1 ? default : ##flag)

#ifndef POWER_BAR_FEATURE_FLAG_OVERCLOCK_USES_SLEEP
#define POWER_BAR_FEATURE_FLAG_OVERCLOCK_USES_SLEEP
#endif
