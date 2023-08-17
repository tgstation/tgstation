GLOBAL_VAR_INIT(clock_power, 2500)
GLOBAL_VAR_INIT(max_clock_power, 2500) // Increases with every APC cogged
GLOBAL_VAR_INIT(clock_vitality, 50) //start with only a bit of vitality
GLOBAL_VAR_INIT(max_clock_vitality, 400) // This one however is constant
GLOBAL_VAR_INIT(clock_installed_cogs, 0)
GLOBAL_LIST_EMPTY(types_to_drop_on_clock_deonversion) //list of types to check for dropping on deconversion
GLOBAL_VAR_INIT(narsie_breaching_rune, FALSE) //rune where nar'sie is trying to summon from, if it gets destroyed somehow then just summon her on a random station turf
