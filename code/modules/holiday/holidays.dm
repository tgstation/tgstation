/// List of all holiday-related mail. Do not edit this directly, instead add to var/list/holiday_mail
GLOBAL_LIST_INIT(holiday_mail, list())

/datum/holiday
	///Name of the holiday itself. Visible to players.
	var/name = "If you see this the holiday calendar code is broken"

	///What day of begin_month does the holiday begin on?
	var/begin_day = 1
	///What month does the holiday begin on?
	var/begin_month = 0
	/// What day of end_month does the holiday end? Default of 0 means the holiday lasts a single.
	var/end_day = 0
	/// What month does the holiday end on?
	var/end_month = 0
	/// for christmas neverending, or testing. Forces a holiday to be celebrated.
	var/always_celebrate = FALSE
	/// Held variable to better calculate when certain holidays may fall on, like easter.
	var/current_year = 0
	/// How many years are you offsetting your calculations for begin_day and end_day on. Used for holidays like easter.
	var/year_offset = 0
	///Timezones this holiday is celebrated in (defaults to three timezones spanning a 50 hour window covering all timezones)
	var/list/timezones = list(TIMEZONE_LINT, TIMEZONE_UTC, TIMEZONE_ANYWHERE_ON_EARTH)
	///If this is defined, drones/assistants without a default hat will spawn with this item in their head clothing slot.
	var/obj/item/holiday_hat
	///When this holiday is active, does this prevent mail from arriving to cargo? Overrides var/list/holiday_mail. Try not to use this for longer holidays.
	var/no_mail_holiday = FALSE
	/// The list of items we add to the mail pool. Can either be a weighted list or a normal list. Leave empty for nothing.
	var/list/holiday_mail = list()
	var/poster_name = "generic celebration poster"
	var/poster_desc = "A poster for celebrating some holiday. Unfortunately, its unfinished, so you can't see what the holiday is."
	var/poster_icon = "holiday_unfinished"
	/// Color scheme for this holiday
	var/list/holiday_colors
	/// The default pattern of the holiday, if the requested pattern is null.
	var/holiday_pattern = PATTERN_DEFAULT

// This proc gets run before the game starts when the holiday is activated. Do festive shit here.
/datum/holiday/proc/celebrate()
	if(no_mail_holiday)
		SSeconomy.mail_blocked = TRUE
	if(LAZYLEN(holiday_mail) && !no_mail_holiday)
		GLOB.holiday_mail += holiday_mail
	return

// When the round starts, this proc is ran to get a text message to display to everyone to wish them a happy holiday
/datum/holiday/proc/greet()
	return "Have a happy [name]!"

// Returns special prefixes for the station name on certain days. You wind up with names like "Christmas Object Epsilon". See new_station_name()
/datum/holiday/proc/getStationPrefix()
	//get the first word of the Holiday and use that
	var/i = findtext(name, " ")
	return copytext(name, 1, i)

// Return 1 if this holidy should be celebrated today
/datum/holiday/proc/shouldCelebrate(dd, mm, yyyy, ddd)
	if(always_celebrate)
		return TRUE

	if(!end_day)
		end_day = begin_day
	if(!end_month)
		end_month = begin_month
	if(end_month > begin_month) //holiday spans multiple months in one year
		if(mm == end_month) //in final month
			if(dd <= end_day)
				return TRUE

		else if(mm == begin_month)//in first month
			if(dd >= begin_day)
				return TRUE

		else if(mm in begin_month to end_month) //holiday spans 3+ months and we're in the middle, day doesn't matter at all
			return TRUE

	else if(end_month == begin_month) // starts and stops in same month, simplest case
		if(mm == begin_month && (dd in begin_day to end_day))
			return TRUE

	else // starts in one year, ends in the next
		if(mm >= begin_month && dd >= begin_day) // Holiday ends next year
			return TRUE
		if(mm <= end_month && dd <= end_day) // Holiday started last year
			return TRUE

	return FALSE

/// Procs to return holiday themed colors for recoloring atoms
/datum/holiday/proc/get_holiday_colors(atom/thing_to_color, pattern = holiday_pattern)
	if(!holiday_colors)
		return
	switch(pattern)
		if(PATTERN_DEFAULT)
			return holiday_colors[(thing_to_color.y % holiday_colors.len) + 1]
		if(PATTERN_VERTICAL_STRIPE)
			return holiday_colors[(thing_to_color.x % holiday_colors.len) + 1]

/proc/request_holiday_colors(atom/thing_to_color, pattern)
	switch(pattern)
		if(PATTERN_RANDOM)
			return "#[random_short_color()]"
		if(PATTERN_RAINBOW)
			var/datum/holiday/pride_week/rainbow_datum = new()
			return rainbow_datum.get_holiday_colors(thing_to_color, PATTERN_DEFAULT)
	if(!length(GLOB.holidays))
		return
	for(var/holiday_key in GLOB.holidays)
		var/datum/holiday/holiday_real = GLOB.holidays[holiday_key]
		if(!holiday_real.holiday_colors)
			continue
		return holiday_real.get_holiday_colors(thing_to_color, pattern || holiday_real.holiday_pattern)

// The actual holidays

// JANUARY

//Fleet Day is celebrated on Jan 19th, the date on which moths were merged (#34498)
/datum/holiday/fleet_day
	name = "Fleet Day"
	begin_month = JANUARY
	begin_day = 19
	holiday_hat = /obj/item/clothing/head/mothcap

/datum/holiday/fleet_day/greet()
	return "This day commemorates another year of successful survival aboard the Mothic Grand Nomad Fleet. Moths galaxywide are encouraged to eat, drink, and be merry."

/datum/holiday/fleet_day/getStationPrefix()
	return pick("Moth", "Fleet", "Nomadic")

// FEBRUARY

/datum/holiday/birthday
	name = "Birthday of Space Station 13"
	begin_day = 16
	begin_month = FEBRUARY
	holiday_hat = /obj/item/clothing/head/costume/festive
	poster_name = "station birthday poster"
	poster_desc = "A poster celebrating another year of the station's operation. Why anyone would be happy to be here is byond you."
	poster_icon = "holiday_cake" // is a lie
	holiday_mail = list(
		/obj/item/clothing/mask/party_horn,
		/obj/item/food/cakeslice/birthday,
		/obj/item/sparkler,
		/obj/item/storage/box/party_poppers,
	)

/datum/holiday/birthday/greet()
	var/game_age = text2num(time2text(world.timeofday, "YYYY", world.timezone)) - 2003
	var/Fact
	switch(game_age)
		if(16)
			Fact = " SS13 is now old enough to drive!"
		if(18)
			Fact = " SS13 is now legal!"
		if(21)
			Fact = " SS13 can now drink!"
		if(26)
			Fact = " SS13 can now rent a car!"
		if(30)
			Fact = " SS13 can now go home and be a family man!"
		if(35)
			Fact = " SS13 can now run for President of the United States!"
		if(40)
			Fact = " SS13 can now suffer a midlife crisis!"
		if(50)
			Fact = " Happy golden anniversary!"
		if(65)
			Fact = " SS13 can now start thinking about retirement!"
	if(!Fact)
		Fact = " SS13 is now [game_age] years old!"

	return "Say 'Happy Birthday' to Space Station 13, first publicly playable on February 16th, 2003![Fact]"

/datum/holiday/random_kindness
	name = "Random Acts of Kindness Day"
	begin_day = 17
	begin_month = FEBRUARY
	poster_name = "act of kindness poster"
	poster_desc = "A poster notifying the reader today is 'Act of Kindness' day. What a nice thing to do."
	poster_icon = "holiday_kind"

/datum/holiday/random_kindness/greet()
	return "Go do some random acts of kindness for a stranger!" //haha yeah right

/datum/holiday/leap
	name = "Leap Day"
	begin_day = 29
	begin_month = FEBRUARY

// MARCH

/datum/holiday/pi
	name = "Pi Day"
	begin_day = 14
	begin_month = MARCH
	poster_name = "pi day poster"
	poster_desc = "A poster celebrating the 3.141529th day of the year. At least theres free pie."
	poster_icon = "holiday_pi"
	holiday_mail = list(
		/obj/item/food/pieslice/apple,
		/obj/item/food/pieslice/bacid_pie,
		/obj/item/food/pieslice/blumpkin,
		/obj/item/food/pieslice/cherry,
		/obj/item/food/pieslice/frenchsilk,
		/obj/item/food/pieslice/frostypie,
		/obj/item/food/pieslice/meatpie,
		/obj/item/food/pieslice/pumpkin,
		/obj/item/food/pieslice/shepherds_pie,
		/obj/item/food/pieslice/tofupie,
		/obj/item/food/pieslice/xemeatpie,
	)

/datum/holiday/pi/getStationPrefix()
	return pick("Sine","Cosine","Tangent","Secant", "Cosecant", "Cotangent")

// APRIL

/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_month = APRIL
	begin_day = 1
	end_day = 2
	holiday_hat = /obj/item/clothing/head/chameleon/broken
	holiday_mail = list(
		/obj/item/clothing/head/costume/whoopee,
		/obj/item/grown/bananapeel/gros_michel,
	)

/datum/holiday/april_fools/celebrate()
	. = ..()
	SSjob.set_overflow_role(/datum/job/clown)
	SSticker.set_lobby_music('sound/music/lobby_music/clown.ogg', override = TRUE)
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/P = i
		if(P.client)
			P.client.playtitlemusic()

/datum/holiday/april_fools/get_holiday_colors(atom/thing_to_color)
	return "#[random_short_color()]"

/datum/holiday/spess
	name = "Cosmonautics Day"
	begin_day = 12
	begin_month = APRIL
	holiday_hat = /obj/item/clothing/head/syndicatefake

/datum/holiday/spess/greet()
	return "On this day over 600 years ago, Comrade Yuri Gagarin first ventured into space!"

/datum/holiday/tea
	name = "National Tea Day"
	begin_day = 21
	begin_month = APRIL
	holiday_mail = list(/obj/item/reagent_containers/cup/glass/mug/tea)

/datum/holiday/tea/getStationPrefix()
	return pick("Crumpet","Assam","Oolong","Pu-erh","Sweet Tea","Green","Black")

// MAY

//Draconic Day is celebrated on May 3rd, the date on which the Draconic language was merged (#26780)
/datum/holiday/draconic_day
	name = "Draconic Language Day"
	begin_month = MAY
	begin_day = 3

/datum/holiday/draconic_day/greet()
	return "On this day, Lizardkind celebrates their language with literature and other cultural works."

/datum/holiday/draconic_day/getStationPrefix()
	return pick("Draconic", "Literature", "Reading")

/datum/holiday/firefighter
	name = "Firefighter's Day"
	begin_day = 4
	begin_month = MAY
	holiday_hat = /obj/item/clothing/head/utility/hardhat/red
	holiday_mail = list(/obj/item/extinguisher/mini)

/datum/holiday/firefighter/getStationPrefix()
	return pick("Burning","Blazing","Plasma","Fire")

/datum/holiday/goth
	name = "Goth Day"
	begin_day = 22
	begin_month = MAY
	holiday_mail = list(
		/obj/item/lipstick,
		/obj/item/lipstick/black,
		/obj/item/clothing/suit/costume/gothcoat,
	)
	holiday_colors = list(
		COLOR_WHITE,
		COLOR_BLACK,
	)

/datum/holiday/goth/getStationPrefix()
	return pick("Goth", "Sanguine", "Tenebris", "Lacrimosa", "Umbra", "Noctis")

// JUNE

//The Festival of Atrakor's Might (Tizira's Moon) is celebrated on June 15th, the date on which the lizard visual revamp was merged (#9808)
/datum/holiday/atrakor_festival
	name = "Festival of Atrakor's Might"
	begin_month = JUNE
	begin_day = 15

/datum/holiday/atrakor_festival/greet()
	return "On this day, the Lizards traditionally celebrate the Festival of Atrakor's Might, where they honour the moon god with lavishly adorned clothing, large portions of food, and a massive celebration into the night."

/datum/holiday/atrakor_festival/getStationPrefix()
	return pick("Moon", "Night Sky", "Celebration")

/// Garbage DAYYYYY
/// Huh?.... NOOOO
/// *GUNSHOT*
/// AHHHGHHHHHHH
/datum/holiday/garbageday
	name = GARBAGEDAY
	begin_day = 17
	end_day = 17
	begin_month = JUNE
	holiday_mail = list(
		/obj/effect/spawner/random/trash/garbage,
		/obj/item/storage/bag/trash,
	)

/datum/holiday/summersolstice
	name = "Summer Solstice"
	begin_day = 21
	begin_month = JUNE
	holiday_hat = /obj/item/clothing/head/costume/garland

/datum/holiday/ufo
	name = "UFO Day"
	begin_day = 2
	begin_month = JULY
	holiday_hat = /obj/item/clothing/head/collectable/xenom
	holiday_mail = list(
		/obj/item/toy/plush/abductor,
		/obj/item/toy/plush/abductor/agent,
		/obj/item/toy/plush/rouny,
		/obj/item/toy/toy_xeno,
	)

/datum/holiday/ufo/getStationPrefix() //Is such a thing even possible?
	return pick("Ayy","Truth","Tsoukalos","Mulder","Scully") //Yes it is!

/datum/holiday/writer
	name = "Writer's Day"
	begin_day = 8
	begin_month = JULY
	holiday_mail = list(/obj/item/pen/fountain)

/datum/holiday/hotdogday
	name = HOTDOG_DAY
	begin_day = 17
	begin_month = JULY
	holiday_mail = list(/obj/item/food/hotdog)

/datum/holiday/hotdogday/greet()
	return "Happy National Hot Dog Day!"

//Gary Gygax's birthday, a fitting day for Wizard's Day
/datum/holiday/wizards_day
	name = "Wizard's Day"
	begin_month = JULY
	begin_day = 27
	holiday_hat = /obj/item/clothing/head/wizard

/datum/holiday/wizards_day/getStationPrefix()
	return pick("Dungeon", "Elf", "Magic", "D20", "Edition")

/datum/holiday/friendship
	name = "Friendship Day"
	begin_day = 30
	begin_month = JULY
	holiday_mail = list(/obj/item/food/grown/apple)

/datum/holiday/friendship/greet()
	return "Have a magical [name]!"

// SEPTEMBER

//Tiziran Unification Day is celebrated on Sept 1st, the day on which lizards were made a roundstart race
/datum/holiday/tiziran_unification
	name = "Tiziran Unification Day"
	begin_month = SEPTEMBER
	begin_day = 1
	holiday_hat = /obj/item/clothing/head/costume/lizard
	holiday_mail = list(/obj/item/toy/plush/lizard_plushie)

/datum/holiday/tiziran_unification/greet()
	return "On this day over 400 years ago, Lizardkind first united under a single banner, ready to face the stars as one unified people."

/datum/holiday/tiziran_unification/getStationPrefix()
	return pick("Tizira", "Lizard", "Imperial")

/datum/holiday/ianbirthday
	name = IAN_HOLIDAY //github.com/tgstation/tgstation/commit/de7e4f0de0d568cd6e1f0d7bcc3fd34700598acb
	begin_month = SEPTEMBER
	begin_day = 9
	end_day = 10
	holiday_mail = list(
		/obj/item/bedsheet/ian,
		/obj/item/bedsheet/ian/double,
		/obj/item/clothing/suit/costume/wellworn_shirt/graphic/ian,
		/obj/item/clothing/suit/costume/wellworn_shirt/messy/graphic/ian,
		/obj/item/clothing/suit/costume/wellworn_shirt/wornout/graphic/ian,
		/obj/item/clothing/suit/hooded/ian_costume,
		/obj/item/radio/toy,
		/obj/item/toy/figure/ian,
	)

/datum/holiday/ianbirthday/greet()
	return "Happy birthday, Ian!"

/datum/holiday/ianbirthday/getStationPrefix()
	return pick("Ian", "Corgi", "Erro")

/datum/holiday/questions
	name = "Stupid-Questions Day"
	begin_day = 28
	begin_month = SEPTEMBER

/datum/holiday/questions/greet()
	return "Are you having a happy [name]?"

// OCTOBER

/datum/holiday/smile
	name = "Smiling Day"
	begin_day = 7
	begin_month = OCTOBER
	holiday_hat = /obj/item/clothing/head/costume/papersack/smiley
	holiday_mail = list(/obj/item/sticker/smile)

// NOVEMBER

/datum/holiday/lifeday
	name = "Life Day"
	begin_day = 17
	begin_month = NOVEMBER

/datum/holiday/lifeday/getStationPrefix()
	return pick("Itchy", "Lumpy", "Malla", "Kazook") //he really pronounced it "Kazook", I wish I was making shit up

/datum/holiday/kindness
	name = "Kindness Day"
	begin_day = 13
	begin_month = NOVEMBER

/datum/holiday/flowers
	name = "Flowers Day"
	begin_day = 19
	begin_month = NOVEMBER
	holiday_hat = /obj/item/food/grown/moonflower
	holiday_mail = list(
		/obj/item/food/grown/harebell,
		/obj/item/food/grown/moonflower,
		/obj/item/food/grown/poppy,
		/obj/item/food/grown/poppy/geranium,
		/obj/item/food/grown/poppy/geranium/fraxinella,
		/obj/item/food/grown/poppy/lily,
		/obj/item/food/grown/rose,
		/obj/item/food/grown/sunflower,
		/obj/item/grown/carbon_rose,
		/obj/item/grown/novaflower,
	)

/datum/holiday/hello
	name = "Saying-'Hello' Day"
	begin_day = 21
	begin_month = NOVEMBER

/datum/holiday/hello/greet()
	return "[pick(list("Aloha", "Bonjour", "Hello", "Hi", "Greetings", "Salutations", "Bienvenidos", "Hola", "Howdy", "Ni hao", "Guten Tag", "Konnichiwa", "G'day cunt"))]! " + ..()

//The Festival of Holy Lights is celebrated on Nov 28th, the date on which ethereals were merged (#40995)
/datum/holiday/holy_lights
	name = "Festival of Holy Lights"
	begin_month = NOVEMBER
	begin_day = 28
	/// If there's more of them I forgot
	holiday_mail = list(
		/obj/item/food/energybar,
		/obj/item/food/pieslice/bacid_pie,
	)

/datum/holiday/holy_lights/greet()
	return "The Festival of Holy Lights is the final day of the Ethereal calendar. It is typically a day of prayer followed by celebration to close out the year in style."

/datum/holiday/holy_lights/getStationPrefix()
	return pick("Ethereal", "Lantern", "Holy")

// DECEMBER

/datum/holiday/monkey
	name = MONKEYDAY
	begin_day = 14
	begin_month = DECEMBER

/datum/holiday/monkey/celebrate()
	. = ..()
	SSstation.setup_trait(/datum/station_trait/job/pun_pun)

/datum/holiday/doomsday
	name = "Mayan Doomsday Anniversary"
	begin_day = 21
	begin_month = DECEMBER
/datum/holiday/new_year
	name = NEW_YEAR
	begin_day = 31
	begin_month = DECEMBER
	end_day = 2
	end_month = JANUARY
	holiday_hat = /obj/item/clothing/head/costume/festive
	no_mail_holiday = TRUE

/datum/holiday/new_year/getStationPrefix()
	return pick("Party","New","Hangover","Resolution", "Auld")

// MOVING DATES

/datum/holiday/friday_thirteenth
	name = "Friday the 13th"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yyyy, ddd)
	if(dd == 13 && ddd == FRIDAY)
		return TRUE
	return FALSE

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Mike","Friday","Evil","Myers","Murder","Deathly","Stabby")

/datum/holiday/programmers
	name = "Programmers' Day"
	holiday_mail = list(/obj/item/sticker/robot)

/datum/holiday/programmers/shouldCelebrate(dd, mm, yyyy, ddd) //Programmer's day falls on the 2^8th day of the year
	if(mm == 9)
		if(yyyy/4 == round(yyyy/4)) //Note: Won't work right on September 12th, 2200 (at least it's a Friday!)
			if(dd == 12)
				return TRUE
		else
			if(dd == 13)
				return TRUE
	return FALSE

/datum/holiday/programmers/getStationPrefix()
	return pick("span>","DEBUG: ","null","/list","EVENT PREFIX NOT FOUND") //Portability

/// Takes a holiday datum, a starting month, ending month, max amount of days to test in, and min/max year as input
/// Returns a list in the form list("yyyy/m/d", ...) representing all days the holiday runs on in the tested range
/proc/poll_holiday(datum/holiday/path, min_month, max_month, min_year, max_year, max_day)
	var/list/deets = list()
	for(var/year in min_year to max_year)
		for(var/month in min_month to max_month)
			for(var/day in 1 to max_day)
				var/datum/holiday/new_day = new path()
				if(new_day.shouldCelebrate(day, month, year, iso_to_weekday(day_of_month(year, month, day))))
					deets += "[year]/[month]/[day]"
	return deets

/// Does the same as [/proc/poll_holiday], but prints the output to admins instead of returning it
/proc/print_holiday(datum/holiday/path, min_month, max_month, min_year, max_year, max_day)
	var/list/deets = poll_holiday(path, min_month, max_month, min_year, max_year, max_day)
	message_admins("The accepted dates for [path] in the input range [min_year]-[max_year]/[min_month]-[max_month]/1-[max_day] are [deets.Join("\n")]")
