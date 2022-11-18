// crashedship / survey ship

//Areas

/area/awaymission/bmpship
	name = "BMP Asteroids"
	icon_state = "away"


/area/awaymission/bmpship/aft
	name = "Aft Block"
	icon_state = "away1"
	requires_power = TRUE

/area/awaymission/bmpship/midship
	name = "Midship Block"
	icon_state = "away2"
	requires_power = TRUE

/area/awaymission/bmpship/fore
	name = "Fore Block"
	icon_state = "away3"
	requires_power = TRUE

// crashedship corpse

/obj/effect/mob_spawn/corpse/human/laborer
	name = "Crashed Survey Ship Laborer"
	outfit = /datum/outfit/survey_laborer

/datum/outfit/survey_laborer
	name = "Crashed Survey Ship Laborer"
	uniform = /obj/item/clothing/under/misc/overalls
	shoes = /obj/item/clothing/shoes/workboots
	gloves = /obj/item/clothing/gloves/color/fyellow
	head = /obj/item/clothing/head/utility/hardhat
	r_pocket = /obj/item/paper/fluff/ruins/crashedship/old_diary
	l_pocket = /obj/item/stack/spacecash/c200
	mask = /obj/item/clothing/mask/breath
	belt = /obj/item/tank/internals/emergency_oxygen/engi

// crashedship items

/obj/item/paper/fluff/ruins/crashedship/scribbled
	name = "scribbled note"
	default_raw_text = "The next person who takes one of my screwdrivers gets stabbed with one. They are MINE. - Love, Madsen"

/obj/item/paper/fluff/ruins/crashedship/captains_log
	name = "Captain's log entry"
	default_raw_text = "This has got to be the least interesting assignment ever. We are about halfway through the planets we've got to survey and most of them are lifeless rocks. That being said, this next planet seems promising. \
	Fighting demons beats fighting boredom!"

/obj/item/paper/fluff/ruins/crashedship/old_diary
	name = "Old Diary"
	default_raw_text = "DEAR DIARY: So we was on route to survey some magma planet, rumored to be home to literal demons, when our pilot done smashed the ship right into the biggest space rock he could find. \
	Perhaps he took the hell planet talk too seriously. I was nappin' in the emergency supplies closet so I'm not wise to the details. I did peek out the door to see the whole engineering section gone. \
	It ain't long until the lights in here sap all the power, and I think I can get to our teleporter room without bein' sucked out into space. If I don't make it, give my stuff to charity."

