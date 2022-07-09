//Plants / Plant Traits

///called when a plant with slippery skin is slipped on (mob/victim)
#define COMSIG_PLANT_ON_SLIP "plant_on_slip"
///called when a plant with liquid contents is squashed on (atom/target)
#define COMSIG_PLANT_ON_SQUASH "plant_on_squash"
///called when a plant backfires via the backfire element (mob/victim)
#define COMSIG_PLANT_ON_BACKFIRE "plant_on_backfire"
///called when a seed grows in a tray (obj/machinery/hydroponics)
#define COMSIG_SEED_ON_GROW "plant_on_grow"
///called when a seed is planted in a tray (obj/machinery/hydroponics)
#define COMSIG_SEED_ON_PLANTED "plant_on_plant"

//Hydro tray
///from base of /obj/machinery/hydroponics/set_seed() : (obj/item/new_seed)
#define COMSIG_HYDROTRAY_SET_SEED "hydrotray_set_seed"
///from base of /obj/machinery/hydroponics/set_self_sustaining() : (new_value)
#define COMSIG_HYDROTRAY_SET_SELFSUSTAINING "hydrotray_set_selfsustaining"
///from base of /obj/machinery/hydroponics/set_weedlevel() : (new_value)
#define COMSIG_HYDROTRAY_SET_WEEDLEVEL "hydrotray_set_weedlevel"
///from base of /obj/machinery/hydroponics/set_pestlevel() : (new_value)
#define COMSIG_HYDROTRAY_SET_PESTLEVEL "hydrotray_set_pestlevel"
///from base of /obj/machinery/hydroponics/set_waterlevel() : (new_value)
#define COMSIG_HYDROTRAY_SET_WATERLEVEL "hydrotray_set_waterlevel"
///from base of /obj/machinery/hydroponics/set_plant_health() : (new_value)
#define COMSIG_HYDROTRAY_SET_PLANT_HEALTH "hydrotray_set_plant_health"
///from base of /obj/machinery/hydroponics/set_toxic() : (new_value)
#define COMSIG_HYDROTRAY_SET_TOXIC "hydrotray_set_toxic"
///from base of /obj/machinery/hydroponics/set_plant_status() : (new_value)
#define COMSIG_HYDROTRAY_SET_PLANT_STATUS "hydrotray_set_plant_status"
///from base of /obj/machinery/hydroponics/update_tray() : (mob/user, product_count)
#define COMSIG_HYDROTRAY_ON_HARVEST "hydrotray_on_harvest"
///from base of /obj/machinery/hydroponics/plantdies()
#define COMSIG_HYDROTRAY_PLANT_DEATH "hydrotray_plant_death"
///from base of obj/item/attack(): (/mob/living/target, /mob/living/user)
