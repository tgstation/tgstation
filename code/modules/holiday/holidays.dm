/datum/holiday
	var/name = "Bugsgiving"
	//Right now, only holidays that take place on a certain day or within a time period are supported
	//It would be nice to support things like "the second monday in march" or "the first sunday after the second sunday in june"
	var/begin_day = 1
	var/begin_month = 0
	var/end_day = 0 // Default of 0 means the holiday lasts a single day
	var/end_month = 0

	var/always_celebrate = FALSE // for christmas neverending, or testing.

// This proc gets run before the game starts when the holiday is activated. Do festive shit here.
/datum/holiday/proc/celebrate()

// When the round starts, this proc is ran to get a text message to display to everyone to wish them a happy holiday
/datum/holiday/proc/greet()
	return "Have a happy [name]!"

// Returns special prefixes for the station name on certain days. You wind up with names like "Christmas Object Epsilon". See new_station_name()
/datum/holiday/proc/getStationPrefix()
	//get the first word of the Holiday and use that
	var/i = findtext(name," ",1,0)
	return copytext(name,1,i)

// Return 1 if this holidy should be celebrated today
/datum/holiday/proc/shouldCelebrate(dd, mm, yy)
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

// The actual holidays

/datum/holiday/new_year
	name = NEW_YEAR
	begin_day = 30
	begin_month = DECEMBER
	end_day = 2
	end_month = JANUARY

/datum/holiday/new_year/getStationPrefix()
	return pick("Party","New","Hangover","Resolution")

/datum/holiday/groundhog
	name = "Groundhog Day"
	begin_day = 2
	begin_month = FEBRUARY

/datum/holiday/valentines
	name = VALENTINES
	begin_day = 13
	end_day = 15
	begin_month = FEBRUARY

/datum/holiday/valentines/getStationPrefix()
	return pick("Love","Amore","Single","Smootch","Hug")

/datum/holiday/birthday
	name = "Birthday of Space Station 13"
	begin_day = 16
	begin_month = FEBRUARY

/datum/holiday/birthday/greet()
	var/game_age = text2num(time2text(world.timeofday, "YY")) - 3
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
		if(40)
			Fact = " SS13 can now suffer a midlife crisis!"
		if(50)
			Fact = " Happy golden anniversary!"
		if(65)
			Fact = " SS13 can now start thinking about retirement!"
		if(96)
			Fact = " Please send a time machine back to pick me up, I need to update the time formatting for this feature!" //See you later suckers
	if(!Fact)
		Fact = " SS13 is now [game_age] years old!"

	return "Say 'Happy Birthday' to Space Station 13, first publicly playable on February 16th, 2003![Fact]"

/datum/holiday/random_kindness
	name = "Random Acts of Kindness Day"
	begin_day = 17
	begin_month = FEBRUARY

/datum/holiday/random_kindness/greet()
	return "Go do some random acts of kindness for a stranger!" //haha yeah right

/datum/holiday/leap
	name = "Leap Day"
	begin_day = 29
	begin_month = FEBRUARY

/datum/holiday/pi
	name = "Pi Day"
	begin_day = 14
	begin_month = MARCH

/datum/holiday/no_this_is_patrick
	name = "St. Patrick's Day"
	begin_day = 17
	begin_month = MARCH

/datum/holiday/no_this_is_patrick/getStationPrefix()
	return pick("Blarney","Green","Leprechaun","Booze")

/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_day = 1
	end_day = 2
	begin_month = APRIL

/datum/holiday/april_fools/celebrate()
	if(SSticker)
		SSticker.login_music = 'sound/ambience/clown.ogg'
		for(var/mob/dead/new_player/P in GLOB.mob_list)
			if(P.client)
				P.client.playtitlemusic()

/datum/holiday/fourtwenty
	name = "Four-Twenty"
	begin_day = 20
	begin_month = APRIL

/datum/holiday/fourtwenty/getStationPrefix()
	return pick("Snoop","Blunt","Toke","Dank")

/datum/holiday/earth
	name = "Earth Day"
	begin_day = 22
	begin_month = APRIL

/datum/holiday/labor
	name = "Labor Day"
	begin_day = 1
	begin_month = MAY

/datum/holiday/firefighter
	name = "Firefighter's Day"
	begin_day = 4
	begin_month = MAY

/datum/holiday/firefighter/getStationPrefix()
	return pick("Burning","Blazing","Plasma","Fire")

/datum/holiday/summersolstice
	name = "Summer Solstice"
	begin_day = 21
	begin_month = JUNE

/datum/holiday/doctor
	name = "Doctor's Day"
	begin_day = 1
	begin_month = JULY

/datum/holiday/UFO
	name = "UFO Day"
	begin_day = 2
	begin_month = JULY

/datum/holiday/UFO/getStationPrefix() //Is such a thing even possible?
	return pick("Ayy","Truth","Tsoukalos","Mulder") //Yes it is!

/datum/holiday/writer
	name = "Writer's Day"
	begin_day = 8
	begin_month = JULY

/datum/holiday/friendship
	name = "Friendship Day"
	begin_day = 30
	begin_month = JULY

/datum/holiday/friendship/greet()
	return "Have a magical [name]!"

/datum/holiday/beer
	name = "Beer Day"
	begin_day = 5
	begin_month = AUGUST

/datum/holiday/pirate
	name = "Talk-Like-a-Pirate Day"
	begin_day = 19
	begin_month = SEPTEMBER

/datum/holiday/pirate/greet()
	return "Ye be talkin' like a pirate today or else ye'r walkin' tha plank, matey!"

/datum/holiday/pirate/getStationPrefix()
	return pick("Yarr","Scurvy","Yo-ho-ho")

/datum/holiday/programmers
	name = "Programmers' Day"

/datum/holiday/programmers/shouldCelebrate(dd, mm, yy) //Programmer's day falls on the 2^8th day of the year
	if(mm == 9)
		if(yy/4 == round(yy/4)) //Note: Won't work right on September 12th, 2200 (at least it's a Friday!)
			if(dd == 12)
				return 1
		else
			if(dd == 13)
				return 1
	return 0

/datum/holiday/programmers/getStationPrefix()
	return pick("span>","DEBUG: ","null","/list","EVENT PREFIX NOT FOUND") //Portability

/datum/holiday/questions
	name = "Stupid-Questions Day"
	begin_day = 28
	begin_month = SEPTEMBER

/datum/holiday/questions/greet()
	return "Are you having a happy [name]?"

/datum/holiday/animal
	name = "Animal's Day"
	begin_day = 4
	begin_month = OCTOBER

/datum/holiday/animal/getStationPrefix()
	return pick("Parrot","Corgi","Cat","Pug","Goat","Fox")

/datum/holiday/smile
	name = "Smiling Day"
	begin_day = 7
	begin_month = OCTOBER

/datum/holiday/boss
	name = "Boss' Day"
	begin_day = 16
	begin_month = OCTOBER

/datum/holiday/halloween
	name = HALLOWEEN
	begin_day = 30
	begin_month = OCTOBER
	end_day = 2
	end_month = NOVEMBER

/datum/holiday/halloween/greet()
	return "Have a spooky Halloween!"

/datum/holiday/halloween/getStationPrefix()
	return pick("Bone-Rattling","Mr. Bones' Own","2SPOOKY","Spooky","Scary","Skeletons")

/datum/holiday/vegan
	name = "Vegan Day"
	begin_day = 1
	begin_month = NOVEMBER

/datum/holiday/kindness
	name = "Kindness Day"
	begin_day = 13
	begin_month = NOVEMBER

/datum/holiday/flowers
	name = "Flowers Day"
	begin_day = 19
	begin_month = NOVEMBER

/datum/holiday/hello
	name = "Saying-'Hello' Day"
	begin_day = 21
	begin_month = NOVEMBER

/datum/holiday/hello/greet()
	return "[pick(list("Aloha", "Bonjour", "Hello", "Hi", "Greetings", "Salutations", "Bienvenidos", "Hola", "Howdy"))]! " + ..()

/datum/holiday/human_rights
	name = "Human-Rights Day"
	begin_day = 10
	begin_month = DECEMBER

/datum/holiday/monkey
	name = "Monkey Day"
	begin_day = 14
	begin_month = DECEMBER

/datum/holiday/doomsday
	name = "Mayan Doomsday Anniversary"
	begin_day = 21
	begin_month = DECEMBER

/datum/holiday/xmas
	name = CHRISTMAS
	begin_day = 23
	begin_month = DECEMBER
	end_day = 25

/datum/holiday/xmas/greet()
	return "Have a merry Christmas!"

/datum/holiday/festive_season
	name = FESTIVE_SEASON
	begin_day = 1
	begin_month = DECEMBER
	end_day = 31

/datum/holiday/festive_season/greet()
	return "Have a nice festive season!"

/datum/holiday/boxing
	name = "Boxing Day"
	begin_day = 26
	begin_month = DECEMBER

/datum/holiday/friday_thirteenth
	name = "Friday the 13th"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yy)
	if(dd == 13)
		if(time2text(world.timeofday, "DDD") == "Fri")
			return TRUE
	return FALSE

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Mike","Friday","Evil","Myers","Murder","Deathly","Stabby")

/datum/holiday/easter
	name = EASTER
	var/const/days_early = 1 //to make editing the holiday easier
	var/const/days_extra = 1
	var/current_year = 0
	var/year_offset = 0

/datum/holiday/easter/shouldCelebrate(dd, mm, yy)
	if(!begin_month)
		current_year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/easterResults = EasterDate(current_year+year_offset)

		begin_day = easterResults["day"]
		begin_month = easterResults["month"]

		end_day = begin_day + days_extra
		end_month = begin_month
		if(end_day >= 32 && end_month == MARCH) //begins in march, ends in april
			end_day -= 31
			end_month++
		if(end_day >= 31 && end_month == APRIL) //begins in april, ends in june
			end_day -= 30
			end_month++

		begin_day -= days_early
		if(begin_day <= 0)
			if(begin_month == APRIL)
				begin_day += 31
				begin_month-- //begins in march, ends in april

	return ..()

/datum/holiday/easter/celebrate()
	..()
	GLOB.maintenance_loot += list(
		/obj/item/weapon/reagent_containers/food/snacks/egg/loaded = 15,
		/obj/item/weapon/storage/bag/easterbasket = 15)

/datum/holiday/easter/greet()
	return "Greetings! in the far flung past of [current_year], today would be easter, Be sure to have a happy one and keep an eye out for Bunnies!"


/datum/holiday/easter/spess
	name = SPACE_EASTER
	year_offset = 540 //Canonicially the year is CURRENT YEAR + 540, so this is Easter as it would be IN SS13 itself

/datum/holiday/easter/spess/greet()
	return "Greetings! the year is [current_year+year_offset], and it's easter! be sure to have a happy one and keep an eye out for Easter Bunnies!"


/datum/holiday/mothering_sunday
	name = "Mothering Sunday"

/datum/holiday/mothering_sunday/shouldCelebrate(dd, mm, yy)
	if(!begin_month)
		var/year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/motheringSundayResults = MotheringSundayDate(year)
		end_day = begin_day = motheringSundayResults["day"]
		end_month = begin_month = motheringSundayResults["month"]

	return ..()

/datum/holiday/mothering_sunday/greet()
	return "It's Mothering Sunday! the -REAL- Mother's Day, you did remember to get her a gift right?"


/datum/holiday/ashwednesday
	name = "Ash Wednesday"

/datum/holiday/ashwednesday/shouldCelebrate(dd, mm, yy)
	if(!begin_month)
		var/year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/ashWednesdayResults = AshWednesdayDate(year)
		end_day = begin_day = ashWednesdayResults["day"]
		end_month = begin_month = ashWednesdayResults["month"]

	return ..()


/datum/holiday/goodfriday
	name = "Good Friday"

/datum/holiday/goodfriday/shouldCelebrate(dd, mm, yy)
	if(!begin_month)
		var/year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/goodFridayResults = GoodFridayDate(year)
		end_day = begin_day = goodFridayResults["day"]
		end_month = begin_month = goodFridayResults["month"]

	return ..()


/datum/holiday/pancakeday
	name = "Pancake Day / Mardi Gras / Shrove Tuesday"

/datum/holiday/pancakeday/shouldCelebrate(dd, mm, yy)
	if(!begin_month)
		var/year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/shroveTuesdayResults = ShroveTuesdayDate(year)
		end_day = begin_day = shroveTuesdayResults["day"]
		end_month = begin_month = shroveTuesdayResults["month"]

	return ..()


/datum/holiday/pancakeday/greet()
	return "Today is Pancake day! also known as Mardi Gras and Shrove Tuesday, but who cares about that, PANCAAAAAKES!!!1!!"