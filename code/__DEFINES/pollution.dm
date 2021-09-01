#define REGISTER_POLLUTION(pollution) SSpollution.all_polution[pollution] = TRUE
#define UNREGISTER_POLLUTION(pollution) SSpollution.all_polution -= pollution
#define SET_ACTIVE_POLLUTION(pollution) SSpollution.active_pollution[pollution] = TRUE
#define SET_UNACTIVE_POLLUTION(pollution) SSpollution.active_pollution -= pollution
#define SET_PROCESSED_THIS_RUN(pollution) SSpollution.processed_this_run[pollution] = TRUE
#define REMOVE_POLLUTION_CURRENTRUN(pollution) SSpollution.current_run -= pollution

#define POLLUTION_HEIGHT_DIVISOR 10

#define TICKS_TO_DISSIPATE 20

#define POLLUTION_TASK_PROCESS 1
#define POLLUTION_TASK_DISSIPATE 2

#define SCENT_DESC_ODOR        "odour"
#define SCENT_DESC_SMELL       "smell"
#define SCENT_DESC_FRAGRANCE   "fragrance"

///Minimum amount of smell power to be able to sniff a pollutant
#define POLLUTANT_SMELL_THRESHOLD 3.5

#define POLLUTANT_SMELL_NORMAL 20
#define POLLUTANT_SMELL_STRONG 40

#define SMELL_COOLDOWN 1 MINUTES

//Bitflags for pollutants
///Pollutant has an appearance
#define POLLUTANT_APPEARANCE (1<<0)
///Pollutant has a smell
#define POLLUTANT_SMELL (1<<1)
///Pollutant calls TouchAct() on unprotected people touched by it
#define POLLUTANT_TOUCH_ACT (1<<2)
///Pollutant calls SmellAct() on people breathing it in
#define POLLUTANT_BREATHE_ACT (1<<3)

#define POLLUTANT_APPEARANCE_THICKNESS_THRESHOLD 30
#define THICKNESS_ALPHA_COEFFICIENT 0.0025

//.Cap for active emitters that can be running for a very long time
#define POLLUTION_ACTIVE_EMITTER_CAP 300
