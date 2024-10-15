/// Module is compatible with Security Cyborg model
#define BORG_MODEL_SECURITY (1<<0)
/// Module is compatible with Miner Cyborg model
#define BORG_MODEL_MINER (1<<1)
/// Module is compatible with Janitor Cyborg model
#define BORG_MODEL_JANITOR (1<<2)
/// Module is compatible with Medical Cyborg model
#define BORG_MODEL_MEDICAL (1<<3)
/// Module is compatible with Engineering Cyborg model
#define BORG_MODEL_ENGINEERING (1<<4)
/// Module is compatible with Service Cyborg model
#define BORG_MODEL_SERVICE (1<<5)

/// Module is compatible with Ripley Exosuit models
#define EXOSUIT_MODULE_RIPLEY (1<<0)
/// Module is compatible with Odyseeus Exosuit models
#define EXOSUIT_MODULE_ODYSSEUS (1<<1)
/// Module is compatible with Clarke Exosuit models
#define EXOSUIT_MODULE_CLARKE (1<<2)
/// Module is compatible with a mech carrying an empty Concealed Weapon Bay
#define EXOSUIT_MODULE_CONCEALED_WEP_BAY (1<<3)
/// Module is compatible with Gygax Exosuit models
#define EXOSUIT_MODULE_GYGAX (1<<4)
/// Module is compatible with Durand Exosuit models
#define EXOSUIT_MODULE_DURAND (1<<5)
/// Module is compatible with H.O.N.K Exosuit models
#define EXOSUIT_MODULE_HONK (1<<6)
/// Module is compatible with Phazon Exosuit models
#define EXOSUIT_MODULE_PHAZON (1<<7)
/// Module is compatible with Savannah Exosuit models
#define EXOSUIT_MODULE_SAVANNAH (1<<8)
/// Module is compatible with Reticence models
#define EXOSUIT_MODULE_RETICENCE (1<<9)
/// Module is compatible with Marauder models
#define EXOSUIT_MODULE_MARAUDER (1<<10)
/// Module is compatible with Paddy models
#define EXOSUIT_MODULE_PADDY (1<<11)
/// Module is compatible with Justice models
#define EXOSUIT_MODULE_JUSTICE (1<<12)

/// Module is compatible with "Working" Exosuit models - Ripley and Clarke
#define EXOSUIT_MODULE_WORKING (EXOSUIT_MODULE_RIPLEY | EXOSUIT_MODULE_CLARKE)
/// Module is compatible with "Combat" Exosuit models - Gygax, H.O.N.K, Durand and Phazon, or any Exosuit with an empty Concealed Weapon Bay
#define EXOSUIT_MODULE_COMBAT (EXOSUIT_MODULE_GYGAX | EXOSUIT_MODULE_HONK | EXOSUIT_MODULE_DURAND | EXOSUIT_MODULE_PHAZON | EXOSUIT_MODULE_SAVANNAH | EXOSUIT_MODULE_RETICENCE | EXOSUIT_MODULE_MARAUDER | EXOSUIT_MODULE_PADDY | EXOSUIT_MODULE_JUSTICE | EXOSUIT_MODULE_CONCEALED_WEP_BAY)
/// Module is compatible with "Medical" Exosuit modelsm - Odysseus
#define EXOSUIT_MODULE_MEDICAL EXOSUIT_MODULE_ODYSSEUS
