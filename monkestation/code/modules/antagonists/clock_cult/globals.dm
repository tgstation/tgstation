GLOBAL_VAR_INIT(clock_power, 2500)
GLOBAL_VAR_INIT(max_clock_power, 2500) // Increases with every APC cogged
GLOBAL_VAR_INIT(clock_vitality, 100) //start with only a bit of vitality
GLOBAL_VAR_INIT(clock_installed_cogs, 0)
GLOBAL_LIST_INIT(clock_turf_types, typesof(/turf/open/floor/bronze, /turf/open/indestructible/reebe_flooring, /turf/closed/wall/clockwork))
GLOBAL_LIST_EMPTY(types_to_drop_on_clock_deonversion) //list of types to check for dropping on deconversion
//CONVERT TO GLOBAL DATUM
GLOBAL_VAR_INIT(narsie_breaching_rune, FALSE) //rune where nar'sie is trying to summon from, if it gets destroyed somehow then just summon her on a random station turf
