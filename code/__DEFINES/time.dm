///number of deciseconds in a day
#define MIDNIGHT_ROLLOVER 864000

///displays the current time into the round, with a lot of extra code just there for ensuring it looks okay after an entire day passes
#define ROUND_TIME(...) ( "[world.time - SSticker.round_start_time > MIDNIGHT_ROLLOVER ? "[round((world.time - SSticker.round_start_time)/MIDNIGHT_ROLLOVER)]:[worldtime2text()]" : worldtime2text()]" )

/// Define that just has the current in-universe year for use in whatever context you might want to display that in. (For example, 2022 -> 2562 given a 540 year offset)
#define CURRENT_STATION_YEAR (GLOB.year_integer + STATION_YEAR_OFFSET)

/// In-universe, SS13 is set 540 years in the future from the real-world day, hence this number for determining the year-offset for the in-game year.
#define STATION_YEAR_OFFSET 540

#define JANUARY 1
#define FEBRUARY 2
#define MARCH 3
#define APRIL 4
#define MAY 5
#define JUNE 6
#define JULY 7
#define AUGUST 8
#define SEPTEMBER 9
#define OCTOBER 10
#define NOVEMBER 11
#define DECEMBER 12

//Select holiday names -- If you test for a holiday in the code, make the holiday's name a define and test for that instead
#define NEW_YEAR "New Year"
#define VALENTINES "Valentine's Day"
#define APRIL_FOOLS "April Fool's Day"
#define EASTER "Easter"
#define HALLOWEEN "Halloween"
#define CHRISTMAS "Christmas"
#define FESTIVE_SEASON "Festive Season"
#define GARBAGEDAY "Garbage Day"
#define MONKEYDAY "Monkey Day"
#define PRIDE_WEEK "Pride Week"
#define MOTH_WEEK "Moth Week"
/*

Days of the week to make it easier to reference them.

When using time2text(), please use "DDD" to find the weekday. Refrain from using "Day"

*/

#define MONDAY "Mon"
#define TUESDAY "Tue"
#define WEDNESDAY "Wed"
#define THURSDAY "Thu"
#define FRIDAY "Fri"
#define SATURDAY "Sat"
#define SUNDAY "Sun"

#define INFINITE -1 // -1 is commonly used to indicate an infinite time duration

#define MILLISECONDS *0.01

#define DECISECONDS *1 //the base unit all of these defines are scaled by, because byond uses that as a unit of measurement for some fucking reason

#define SECONDS *10

#define MINUTES SECONDS*60

#define HOURS MINUTES*60

#define TICKS *world.tick_lag

#define DS2TICKS(DS) ((DS)/world.tick_lag)

#define TICKS2DS(T) ((T) TICKS)

#define MS2DS(T) ((T) MILLISECONDS)

#define DS2MS(T) ((T) * 100)

/*Timezones*/

/// Line Islands Time
#define TIMEZONE_LINT 14

// Chatham Daylight Time
#define TIMEZONE_CHADT 13.75

/// Tokelau Time
#define TIMEZONE_TKT 13

/// Tonga Time
#define TIMEZONE_TOT 13

/// New Zealand Daylight Time
#define TIMEZONE_NZDT 13

/// New Zealand Standard Time
#define TIMEZONE_NZST 12

/// Norfolk Time
#define TIMEZONE_NFT 11

/// Lord Howe Standard Time
#define TIMEZONE_LHST 10.5

/// Australian Eastern Standard Time
#define TIMEZONE_AEST 10

/// Australian Central Standard Time
#define TIMEZONE_ACST 9.5

/// Australian Central Western Standard Time
#define TIMEZONE_ACWST 8.75

/// Australian Western Standard Time
#define TIMEZONE_AWST 8

/// Christmas Island Time
#define TIMEZONE_CXT 7

/// Cocos Islands Time
#define TIMEZONE_CCT 6.5

/// Central European Summer Time
#define TIMEZONE_CEST 2

/// Coordinated Universal Time
#define TIMEZONE_UTC 0

/// Eastern Daylight Time
#define TIMEZONE_EDT -4

/// Eastern Standard Time
#define TIMEZONE_EST -5

/// Central Daylight Time
#define TIMEZONE_CDT -5

/// Central Standard Time
#define TIMEZONE_CST -6

/// Mountain Daylight Time
#define TIMEZONE_MDT -6

/// Mountain Standard Time
#define TIMEZONE_MST -7

/// Pacific Daylight Time
#define TIMEZONE_PDT -7

/// Pacific Standard Time
#define TIMEZONE_PST -8

/// Alaska Daylight Time
#define TIMEZONE_AKDT -8

/// Alaska Standard Time
#define TIMEZONE_AKST -9

/// Hawaii-Aleutian Daylight Time
#define TIMEZONE_HDT -9

/// Hawaii Standard Time
#define TIMEZONE_HST -10

/// Cook Island Time
#define TIMEZONE_CKT -10

/// Niue Time
#define TIMEZONE_NUT -11

/// Anywhere on Earth
#define TIMEZONE_ANYWHERE_ON_EARTH -12
