
GLOBAL_VAR_INIT(year, time2text(world.timeofday, "YYYY", TIMEZONE_UTC))
GLOBAL_VAR_INIT(year_integer, text2num(year)) // = 2013???
