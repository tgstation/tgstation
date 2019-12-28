/datum/outfit/bee_terrorist/hooded
	name = "Bee Costume"
	head = /obj/item/clothing/head/hooded/bee_hood

/datum/outfit/bee_terrorist/hooded/sweater
	r_hand = /obj/item/clothing/suit/hooded/bee_costume

/datum/outfit/fancysuit
	name = "Fancy Suit"
	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/white

/datum/preset_holoimage/beecostume
	outfit_type = /datum/outfit/bee_terrorist/hooded

/datum/preset_holoimage/beecostume/moth
	species_type = /datum/species/moth

/datum/preset_holoimage/beecostume/moth/sweater
	outfit_type = /datum/outfit/bee_terrorist/hooded/sweater

/datum/preset_holoimage/beecostume/lizard
	species_type = /datum/species/lizard

/datum/preset_holoimage/beecostume/vampire
	species_type = /datum/species/vampire

/datum/preset_holoimage/suit
	outfit_type = /datum/outfit/fancysuit

/obj/machinery/holopad/ATHATH

/obj/machinery/holopad/ATHATH/Initialize(mapload)
    . = ..()   
    var/obj/item/disk/holodisk/new_disk = new /obj/item/disk/holodisk/ATHATH(src)
    new_disk.forceMove(src)
    disk = new_disk
    replay_start()

/obj/item/disk/holodisk/ATHATH
	name="The Tape"
	desc="Play me!"
	preset_image_type=/datum/preset_holoimage/suit
	preset_record_text={"
	NAME Bob Bobson
	SAY Greetings from the Phantom Zone, everyone!
	DELAY 30
	SAY I'm Research Director Bob Bobson, not to be confused with Captain Bob Bobson or Head of Personnel Bob Bobson.
	DELAY 50
	SAY Unfortunately, the other Bobs couldn't be here with me today, but I have a feeling that things would just get very confusing with them around.
	DELAY 50
	SAY So, how's the Winter Ball going?
	DELAY 80
	SAY Yeah, I thought so.
	DELAY 20
	SAY I was looking forward to attending this Winter Ball and performing in this talent show in person, but, ah, the gods kind of banished me from existence for a month- wait, no, this just in, the length of my banishment has been reduced to a "mere" 3 weeks.
	DELAY 60
	SAY So... yeah.
	DELAY 20
	SAY Fortunately, I'm still able to co- er, modify the fabric of reality from in here through a proxy or two (thanks, CitrusGender!), which is why you have this disk- it's my submission for this talent show!
	DELAY 50
	SAY More specifically, it's a reading of the first 3 minutes of the Bee Movie script... after I ran it through Space Google Translate 10 times!
	DELAY 50
	SAY This was originally gonna be a solo act, but since a bunch of my friends got banished to the Phantom Zone along with me, I've incorporated them into this too.
	DELAY 50
	SAY By the way, we're fine with whatever heckling you audience members want to do; it's not like we can hear you and have our feelings hurt mid-performance or anything.
	DELAY 50
	SAY And with that introduction over, the rest of the ATHATH group and I present to you: The First 3 Minutes of the Bee Movie, Space Google Translate Edition!
	DELAY 30
	NAME Bob Bobson (as Narrator)
	DELAY 30
	SAY In accordance with all recognized laws
	DELAY 30
	SAY aviation
	DELAY 20
	SAY There's no way
	DELAY 20
	SAY I have to be able to fly.
	DELAY 20
	SAY Your wings are too small
	DELAY 20
	SAY Some grease from the floor.
	DELAY 20
	SAY Of course, the bee is still flying.
	DELAY 20
	SAY because bees don't care
	DELAY 20
	SAY What people think is impossible.
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	DELAY 10
	SAY Gold, black, yellow, black
	DELAY 15
	SAY Gold, black, yellow, black
	DELAY 15
	PRESET /datum/preset_holoimage/beecostume/moth/sweater
	DELAY 10
	SAY Oh black and gold!
	DELAY 20
	SAY Shake gently.
	DELAY 20
	NAME Llabeht Stih (as Janet Benson)
	PRESET /datum/preset_holoimage/beecostume
	SAY Berries! Breakfast is ready!
	DELAY 20
	NAME DIO (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/vampire
	SAY The world!
	DELAY 30
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Wait a moment.
	DELAY 20
	SAY Hello
	DELAY 15
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY Barry?
	DELAY 15
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Adam?
	DELAY 15
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY What do you think will happen?
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY I can't choose you.
	DELAY 30
	SAY Are you OK.
	DELAY 20
	NAME Llabeht Stih (as Janet Benson)
	PRESET /datum/preset_holoimage/beecostume
	SAY Use the stairs. Your father
	DELAY 20
	SAY He paid them a lot of money.
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY I'm sorry, I'm happy.
	DELAY 20
	NAME Uzuzap I (as Martin Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY This is a graduate.
	DELAY 20
	SAY We are so proud of you, my son.
	DELAY 20
	SAY Perfect protocol, all b.
	DELAY 20
	NAME Llabeht Stih (as Janet Benson)
	PRESET /datum/preset_holoimage/beecostume
	SAY Very proud
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Mine! I have something to do here.
	DELAY 20
	NAME Uzuzap I (as Martin Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY You jumped on the wick
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY I! You have a choice!
	DELAY 20
	NAME Uzuzap I (as Martin Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Hello! Let it be around 118,000.
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Yes!
	DELAY 20
	NAME Llabeht Stih (as Janet Benson)
	PRESET /datum/preset_holoimage/beecostume
	SAY Barry, I told you
	DELAY 15
	SAY Stop flying home!
	DELAY 30
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	DELAY 10
	SAY Hi Adam.
	DELAY 15
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY Hi Barry.
	DELAY 15
	SAY Fossil fusion?
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY a little. A special day, gradually.
	DELAY 20
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY I never thought of doing it.
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY The third year
	DELAY 15
	SAY Greenhouse three days.
	DELAY 20
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY I am uncomfortable.
	DELAY 30
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Three days at university. I'm glad I got it
	DELAY 10
	SAY Once wrapped in a basket.
	DELAY 10
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY You came back different.
	DELAY 20
	NAME Elmagio Tonama (as Artie)
	PRESET /datum/preset_holoimage/beecostume
	SAY Hi Barry.
	DELAY 15
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Artie ban, mustache grow? Looks good
	DELAY 20
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY Did you hear Frankie?
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Yes, yes
	DELAY 20
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY Are you going to a funeral?
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY No, I won't go.
	DELAY 15
	SAY Everybody knows
	DELAY 15
	SAY Bite a man, die.
	DELAY 15
	SAY Don't miss the squirrel.
	DELAY 15
	SAY What a Girl
	DELAY 20
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY I think so
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY I just left
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY I just left
	DELAY 20
	SAY I like this addition
	DELAY 20
	SAY Play in the park today.
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY That's why we don't want a vacation.
	DELAY 30
	SAY Strong guy ...
	DELAY 20
	SAY in circumstances
	DELAY 20
	SAY Well, Adam, today we are men.
	DELAY 20
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY We are!
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY bees.
	DELAY 20
	NAME Hits-The-Ball (as Adam Flayman)
	PRESET /datum/preset_holoimage/beecostume/lizard
	SAY Amen!
	DELAY 20
	NAME Jack Jackson (as Barry B. Benson)
	PRESET /datum/preset_holoimage/beecostume/moth
	SAY Alleluia!
	DELAY 40
	NAME Bob Bobson
	PRESET /datum/preset_holoimage/suit
	SAY And that's all, folks!
	DELAY 20
	SAY My thanks go to all of you for letting us perform here for you today, and have a fantastic Winter Ball!
	DELAY 40
	SAY ... Hold on, the off button for this thing is somewhere...
	DELAY 30
	SAY Aha! Found i-
	DELAY 10
	"}