
/// The difference betwen midnight (of the host computer) and 0 world.ticks.
GLOBAL_VAR_INIT(timezoneOffset, 0)

GLOBAL_VAR_INIT(year, time2text(world.realtime, "YYYY", NO_TIMEZONE))
GLOBAL_VAR_INIT(year_integer, text2num(year)) // = 2013???
