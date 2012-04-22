/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you looks useless, and only good for your sex appeal."
	icon_state = "bunny"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	flags = FPRINT | TABLEPASS
	var/icon/mob
	var/icon/mob2

	update_icon(var/mob/living/carbon/human/user)
		if(!istype(user)) return
		mob = new/icon("icon" = 'head.dmi', "icon_state" = "kitty")
		mob2 = new/icon("icon" = 'head.dmi', "icon_state" = "kitty2")
		mob.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)
		mob2.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)

		var/icon/earbit = new/icon("icon" = 'head.dmi', "icon_state" = "kittyinner")
		var/icon/earbit2 = new/icon("icon" = 'head.dmi', "icon_state" = "kittyinner2")
		mob.Blend(earbit, ICON_OVERLAY)
		mob2.Blend(earbit2, ICON_OVERLAY)

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	color = "red"

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	color = "rainbow"

/obj/item/clothing/mask/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"

/obj/item/clothing/under/owl
	name = "owl uniform"
	desc = "A jumpsuit with owl wings. Photorealistic owl feathers! Twooooo!"
	icon_state = "owl"
	color = "owl"

/obj/item/clothing/gloves/cyborg
	desc = "beep boop borp"
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	siemens_coefficient = 1

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop"
	icon_state = "death"

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume"
	icon_state = "boots"

/obj/item/clothing/suit/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"
	item_state = "death"
	flags = FPRINT | TABLEPASS | CONDUCT
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/*/obj/item/clothing/under/nazi1
	name = "Nazi uniform"
	desc = "SIEG HEIL!"
	icon_state = "nazi"
	color = "nazi1"*/ //no direction sprites

/obj/item/clothing/suit/greatcoat
	name = "great coat"
	desc = "A Nazi great coat"
	icon_state = "nazi"
	item_state = "nazi"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/under/johnny
	name = "johnny~~ jumpsuit"
	desc = "Johnny~~"
	icon_state = "johnny"
	color = "johnny"

/obj/item/clothing/suit/johnny_coat
	name = "johnny~~ coat"
	desc = "Johnny~~"
	icon_state = "johnny"
	item_state = "johnny"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	item_state = "ianshirt"

/obj/item/clothing/under/rainbow
	name = "rainbow"
	desc = "rainbow"
	icon_state = "rainbow"
	item_state = "rainbow"
	color = "rainbow"

/obj/item/clothing/under/cloud
	name = "cloud"
	desc = "cloud"
	icon_state = "cloud"
	color = "cloud"

/*/obj/item/clothing/under/yay
	name = "yay"
	desc = "Yay!"
	icon_state = "yay"
	color = "yay"*/ // no sprite --errorage

// UNUSED COLORS

/obj/item/clothing/under/psyche
	name = "psychedelic"
	desc = "Groovy!"
	icon_state = "psyche"
	color = "psyche"

/*
/obj/item/clothing/under/maroon
	name = "maroon"
	desc = "maroon"
	icon_state = "maroon"
	color = "maroon"*/ // no sprite -- errorage

/obj/item/clothing/under/lightblue
	name = "lightblue"
	desc = "lightblue"
	icon_state = "lightblue"
	color = "lightblue"

/obj/item/clothing/under/aqua
	name = "aqua"
	desc = "aqua"
	icon_state = "aqua"
	color = "aqua"

/obj/item/clothing/under/purple
	name = "purple"
	desc = "purple"
	icon_state = "purple"
	item_state = "p_suit"
	color = "purple"

/obj/item/clothing/under/lightpurple
	name = "lightpurple"
	desc = "lightpurple"
	icon_state = "lightpurple"
	color = "lightpurple"

/obj/item/clothing/under/lightgreen
	name = "lightgreen"
	desc = "lightgreen"
	icon_state = "lightgreen"
	color = "lightgreen"

/obj/item/clothing/under/lightblue
	name = "lightblue"
	desc = "lightblue"
	icon_state = "lightblue"
	color = "lightblue"

/obj/item/clothing/under/lightbrown
	name = "lightbrown"
	desc = "lightbrown"
	icon_state = "lightbrown"
	color = "lightbrown"

/obj/item/clothing/under/brown
	name = "brown"
	desc = "brown"
	icon_state = "brown"
	color = "brown"

/obj/item/clothing/under/yellowgreen
	name = "yellowgreen"
	desc = "yellowgreen"
	icon_state = "yellowgreen"
	color = "yellowgreen"

/obj/item/clothing/under/darkblue
	name = "darkblue"
	desc = "darkblue"
	icon_state = "darkblue"
	color = "darkblue"

/obj/item/clothing/under/lightred
	name = "lightred"
	desc = "lightred"
	icon_state = "lightred"
	color = "lightred"

/obj/item/clothing/under/darkred
	name = "darkred"
	desc = "darkred"
	icon_state = "darkred"
	color = "darkred"

// STEAMPUNK STATION

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol

/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state = "dg_suit"
	color = "green_suit"

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "teal_suit"
	item_state = "g_suit"
	color = "teal_suit"

/obj/item/clothing/under/suit_jacket
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "black_suit"
	item_state = "bl_suit"
	color = "black_suit"

/obj/item/clothing/under/suit_jacket/really_black
	name = "executive suit"
	desc = "A formal black suit and red tie, intended for the station's finest."
	icon_state = "really_black_suit"
	item_state = "bl_suit"
	color = "black_suit"

/obj/item/clothing/under/suit_jacket/red
	name = "red suit"
	desc = "A red suit and blue tie. Somewhat formal."
	icon_state = "red_suit"
	item_state = "r_suit"
	color = "red_suit"

/obj/item/clothing/under/blackskirt
	name = "black skirt"
	desc = "A black skirt, very fancy!"
	icon_state = "blackskirt"
	color = "blackskirt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/schoolgirl
	name = "schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	item_state = "schoolgirl"
	color = "schoolgirl"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
/*
/obj/item/clothing/under/gimmick/rank/police
	name = "police uniform"
	desc = "Move along, nothing to see here."
	icon_state = "police"
	item_state = "b_suit"
	color = "police"	*/	//No Sprite - Shiftyeyesshady

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"

/obj/item/clothing/under/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "lb_suit"
	color = "overalls"

/obj/item/weapon/melee/classic_baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon = 'weapons.dmi'
	icon_state = "baton"
	item_state = "classic_baton"
	flags = FPRINT | ONBELT | TABLEPASS
	force = 10

/obj/item/clothing/under/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	color = "pirate"

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"

/obj/item/clothing/suit/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	flags = FPRINT | TABLEPASS


/obj/item/clothing/suit/hgpirate
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	item_state = "hgpirate"
	flags = FPRINT | TABLEPASS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = "bandana"

/obj/item/clothing/under/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	item_state = "soviet"
	color = "soviet"

/obj/item/clothing/under/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	item_state = "redcoat"
	color = "redcoat"

/obj/item/clothing/head/ushanka
	name = "ushanka"
	desc = "Perfect for winter in Siberia, da?"
	icon_state = "ushankadown"
	item_state = "ushankadown"
	flags_inv = HIDEEARS

/obj/item/clothing/head/collectable			//Hat Station 13
	name = "collectable hat"
	desc = "A rare collectable hat."

/obj/item/clothing/head/collectable/petehat
	name = "ultra rare Pete's hat!"
	desc = "It smells faintly of plasma"
	icon_state = "petehat"

/obj/item/clothing/head/collectable/metroid
	name = "collectable metroid cap!"
	desc = "It just latches right in place!"
	icon_state = "metroid"

/obj/item/clothing/head/collectable/xenom
	name = "collectable xenomorph helmet!"
	desc = "Hiss hiss hiss!"
	icon_state = "xenom"

/obj/item/clothing/head/collectable/chef
	name = "collectable chef's hat"
	desc = "A rare Chef's Hat meant for hat collectors!"
	icon_state = "chef"
	item_state = "chef"

/obj/item/clothing/head/collectable/paper
	name = "collectable paper hat"
	desc = "What looks like an ordinary paper hat, is actually a rare and valuable collector's edition paper hat. Keep away from water, fire and Librarians."
	icon_state = "paper"

/obj/item/clothing/head/collectable/tophat
	name = "collectable top hat"
	desc = "A top hat worn by only the most prestigious hat collectors."
	icon_state = "tophat"
	item_state = "that"

/obj/item/clothing/head/collectable/captain
	name = "collectable captain's hat"
	desc = "A Collectable Hat that'll make you look just like a real comdom!"
	icon_state = "captain"
	item_state = "caphat"

/obj/item/clothing/head/collectable/police
	name = "collectable police officer's hat"
	desc = "A Collectable Police Officer's Hat. This hat emphasizes that you are THE LAW."
	icon_state = "policehelm"

/obj/item/clothing/head/collectable/beret
	name = "collectable beret"
	desc = "A Collectable red Beret. It smells faintly of Garlic."
	icon_state = "beret"

/obj/item/clothing/head/collectable/welding
	name = "collectable welding helmet"
	desc = "A Collectable Welding Helmet. Now with 80% less lead! Not for actual welding. Any welding done while wearing this Helmet is done so at the owner's own risk!"
	icon_state = "welding"
	item_state = "welding"

/obj/item/clothing/head/collectable/slime
	name = "collectable slime hat"
	desc = "Just like a real Brain Slug!"
	icon_state = "headslime"
	item_state = "headslime"

/obj/item/clothing/head/collectable/flatcap
	name = "collectable flat cap"
	desc = "A Collectible farmer's Flat Cap!"
	icon_state = "flat_cap"
	item_state = "detective"

/obj/item/clothing/head/collectable/pirate
	name = "collectable pirate hat"
	desc = "You'd make a great Dread Syndie Roberts!"
	icon_state = "pirate"
	item_state = "pirate"

/obj/item/clothing/head/collectable/kitty
	name = "collectable kitty ears"
	desc = "The fur feels.....a bit too realistic."
	icon_state = "kitty"
	item_state = "kitty"

/obj/item/clothing/head/collectable/rabbitears
	name = "collectable rabbit ears"
	desc = "Not as lucky as the feet!"
	icon_state = "bunny"
	item_state = "bunny"

/obj/item/clothing/head/collectable/wizard
	name = "collectable wizard's hat"
	desc = "NOTE:Any magical powers gained from wearing this hat are purely coincidental."
	icon_state = "wizard"

/obj/item/clothing/head/collectable/hardhat
	name = "collectable hard hat"
	desc = "WARNING! Offers no real protection, or luminosity, but it is damn fancy!"
	icon_state = "hardhat0_yellow"
	item_state = "hardhat0_yellow"

/obj/item/clothing/head/collectable/HoS
	name = "collectable HoS hat"
	desc = "Now you can beat prisoners, set silly sentences and arrest for no reason too!"
	icon_state = "hoscap"

/obj/item/clothing/head/collectable/thunderdome
	name = "collectable Thunderdome helmet"
	desc = "Go Red! I mean Green! I mean Red! No Green!"
	icon_state = "thunderdome"
	item_state = "thunderdome"

/obj/item/clothing/head/collectable/swat
	name = "collectable SWAT helmet"
	desc = "Now you can be in the Deathsquad too!"
	icon_state = "swat"
	item_state = "swat"

//obj/item/clothing/head/collectable



/* no left/right sprites
/obj/item/clothing/under/mario
	name = "Mario costume"
	desc = "Worn by Italian plumbers everywhere.  Probably."
	icon_state = "mario"
	item_state = "mario"
	color = "mario"

/obj/item/clothing/under/luigi
	name = "Mario costume"
	desc = "Player two.  Couldn't you get the first controller?"
	icon_state = "luigi"
	item_state = "luigi"
	color = "luigi"
*/

/obj/item/clothing/under/kilt
	name = "kilt"
	desc = "Includes shoes and plaid."
	icon_state = "kilt"
	item_state = "kilt"
	color = "kilt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|FEET

/obj/item/clothing/under/sexymime
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	color = "sexymime"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/head/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	item_state = "bowler"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "Fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

obj/item/clothing/suit/justice
	name = "justice suit"
	desc = "This pretty much looks ridiculous."
	icon_state = "justice"
	item_state = "justice"
	flags = FPRINT | TABLEPASS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/under/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	item_state = "gladiator"
	color = "gladiator"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = FPRINT|TABLEPASS|SUITSPACE|HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

//stylish new hats

/obj/item/clothing/head/bowlerhat
	name = "\improper Bowler hat"
	icon_state = "bowler_hat"
	item_state = "bowler_hat"
	desc = "For the gentleman of distinction."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/beaverhat
	name = "\improper Beaver hat"
	icon_state = "beaver_hat"
	item_state = "beaver_hat"
	desc = "Soft felt make this hat both comfortable and elegant."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/boaterhat
	name = "\improper Boater hat"
	icon_state = "boater_hat"
	item_state = "boater_hat"
	desc = "The ultimate in summer fashion."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/fedora
	name = "\improper Fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A sharp, stylish hat."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/feathertrilby
	name = "\improper Feather trilby"
	icon_state = "feather_trilby"
	item_state = "feather_trilby"
	desc = "A sharp, stylish hat with a feather."
	flags = FPRINT|TABLEPASS

/obj/item/clothing/head/fez
	name = "\improper Fez"
	icon_state = "fez"
	item_state = "fez"
	desc = "You should wear a Fez. Fezzes are cool."
	flags = FPRINT|TABLEPASS

//pyjamas

/obj/item/clothing/under/bluepyjamas
	name = "Blue pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "blue_pyjamas"
	item_state = "blue_pyjamas"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/under/redpyjamas
	name = "Red pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "red_pyjamas"
	item_state = "red_pyjamas"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

//scarves (fit in in mask slot)

/obj/item/clothing/mask/bluescarf
	name = "Blue neck scarf"
	desc = "A blue neck scarf."
	icon_state = "blueneckscarf"
	item_state = "blueneckscarf"
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/redscarf
	name = "Red scarf"
	desc = "A red and white checkered neck scarf."
	icon_state = "redwhite_scarf"
	item_state = "redwhite_scarf"
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/greenscarf
	name = "Green scarf"
	desc = "A green neck scarf."
	icon_state = "green_scarf"
	item_state = "green_scarf"
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

/obj/item/clothing/mask/ninjascarf
	name = "Ninja scarf"
	desc = "A stealthy, dark scarf."
	icon_state = "ninja_scarf"
	item_state = "ninja_scarf"
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90

//shoes

/obj/item/clothing/shoes/laceups
	name = "Laceup shoes"
	desc = "Stylish black leather."
	icon_state = "laceups"
	item_state = "laceups"
	color = "black"

//suits

/obj/item/clothing/suit/leathercoat
	name = "Leather Coat"
	desc = "A long, thick black leather coat."
	icon_state = "leathercoat"
	item_state = "leathercoat"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/suit/browncoat
	name = "Brown Leather Coat"
	desc = "A long, brown leather coat."
	icon_state = "browncoat"
	item_state = "browncoat"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/suit/neocoat
	name = "Black coat"
	desc = "A flowing, black coat."
	icon_state = "neocoat"
	item_state = "neocoat"
	flags = FPRINT | TABLEPASS

/obj/item/clothing/suit/creamsuit
	name = "Cream suit"
	desc = "A cream coloured, genteel suit."
	icon_state = "creamsuit"
	item_state = "creamsuit"
	flags = FPRINT | TABLEPASS
