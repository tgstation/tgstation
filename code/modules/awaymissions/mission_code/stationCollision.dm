/* Station-Collision(sc) away mission map specific stuff
 *
 * Notes:
 * Feel free to use parts of this map, or even all of it for your own project. Just include me in the credits :)
 *
 * Some of this code unnecessary, but the intent is to add a little bit of everything to serve as examples
 * for anyone who wants to make their own stuff.
 *
 * Contains:
 * Landmarks
 * Guns
 * Safe code hints
 * Captain's safe
 * Modified Nar'Sie
 */



/*
 * Landmarks - Instead of spawning a new object type, I'll spawn the bible using a landmark!
 */
/obj/effect/landmark/sc_bible_spawner
	name = "Safecode hint spawner"

/obj/effect/landmark/sc_bible_spawner/Initialize(mapload)
	. = ..()
	var/obj/item/book/bible/holy_bible = new /obj/item/book/bible/booze(loc)
	holy_bible.name = "The Holy book of the Geometer"
	holy_bible.deity_name = "Narsie"
	holy_bible.icon_state = "melted"
	holy_bible.inhand_icon_state = "melted"
	holy_bible.lefthand_file = 'icons/mob/inhands/items/books_lefthand.dmi'
	holy_bible.righthand_file = 'icons/mob/inhands/items/books_righthand.dmi'
	new /obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_bible(holy_bible)
	new /obj/item/pen(holy_bible)
	return INITIALIZE_HINT_QDEL

/*
 * Guns - I'm making these specifically so that I dont spawn a pile of fully loaded weapons on the map.
 */
//Captain's retro laser - Fires practice laser shots instead.
/obj/item/gun/energy/laser/retro/sc_retro
	name ="retro laser"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces."
	clumsy_check = FALSE //No sense in having a harmless gun blow up in the clowns face

//Syndicate sub-machine guns.
/obj/item/gun/ballistic/automatic/c20r/sc_c20r

/obj/item/gun/ballistic/automatic/c20r/sc_c20r/Initialize(mapload)
	. = ..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(95)) //95% chance
			magazine.stored_ammo -= ammo

//Barman's shotgun
/obj/item/gun/ballistic/shotgun/sc_pump

/obj/item/gun/ballistic/shotgun/sc_pump/Initialize(mapload)
	. = ..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(95)) //95% chance
			magazine.stored_ammo -= ammo

//Lasers
/obj/item/gun/energy/laser/practice/sc_laser
	name = "Old laser"
	desc = "A once potent weapon, years of dust have collected in the chamber and lens of this weapon, weakening the beam significantly."
	clumsy_check = FALSE

/*
 * Safe code hints
 */

//These vars hold the code itself, they'll be generated at round-start
GLOBAL_VAR_INIT(sc_safecode1, "[rand(0,9)]")
GLOBAL_VAR_INIT(sc_safecode2, "[rand(0,9)]")
GLOBAL_VAR_INIT(sc_safecode3, "[rand(0,9)]")
GLOBAL_VAR_INIT(sc_safecode4, "[rand(0,9)]")
GLOBAL_VAR_INIT(sc_safecode5, "[rand(0,9)]")

//Pieces of paper actually containing the hints
/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_prison
	name = "smudged paper"

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_prison/Initialize(mapload)
	default_raw_text = "<i>The ink is smudged, you can only make out a couple numbers:</i> '[GLOB.sc_safecode1]**[GLOB.sc_safecode4]*'"
	return ..()

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_hydro
	name = "shredded paper"

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_hydro/Initialize(mapload)
	default_raw_text = "<i>Although the paper is shredded, you can clearly see the number:</i> '[GLOB.sc_safecode2]'"
	return ..()

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_caf
	name = "blood-soaked paper"
	//This does not have to be in New() because it is a constant. There are no variables in it i.e. [sc_safcode]
	default_raw_text = "<font color=red><i>This paper is soaked in blood, it is impossible to read any text.</i></font>"

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_bible
	name = "hidden paper"

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_bible/Initialize(mapload)
	default_raw_text = {"<i>It would appear that the pen hidden with the paper had leaked ink over the paper.
			However you can make out the last three digits:</i>'[GLOB.sc_safecode3][GLOB.sc_safecode4][GLOB.sc_safecode5]'
			"}
	return ..()

/obj/item/paper/fluff/awaymissions/stationcollision/safehint_paper_shuttle
	default_raw_text = {"<b>Target:</b> Research-station Epsilon<br>
			<b>Objective:</b> Prototype weaponry. The captain likely keeps them locked in her safe.<br>
			<br>
			Our on-board spy has learned the code and has hidden away a few copies of the code around the station. Unfortunately he has been captured by security
			Your objective is to split up, locate any of the papers containing the captain's safe code, open the safe and
			secure anything found inside. If possible, recover the imprisioned syndicate operative and receive the code from him.<br>
			<br>
			<u>As always, eliminate anyone who gets in the way.</u><br>
			<br>
			Your assigned ship is designed specifically for penetrating the hull of another station or ship with minimal damage to operatives.
			It is completely fly-by-wire meaning you have just have to enjoy the ride and when the red light comes on... find something to hold onto!
			"}

/*
 * Captain's safe
 */
/obj/structure/secure_safe/sc_ssafe
	name = "Captain's secure safe"

/obj/structure/secure_safe/sc_ssafe/Initialize(mapload)
	. = ..()
	var/lock_code = "[GLOB.sc_safecode1][GLOB.sc_safecode2][GLOB.sc_safecode3][GLOB.sc_safecode4][GLOB.sc_safecode5]"
	AddComponent(/datum/component/lockable_storage, \
		lock_code = lock_code, \
		can_hack_open = FALSE, \
	)

/obj/structure/secure_safe/sc_ssafe/PopulateContents()
	. = ..()
	new /obj/item/gun/energy/mindflayer(src)
	new /obj/item/soulstone(src)
	new /obj/item/clothing/suit/hooded/cultrobes/hardened(src)
	new /obj/item/stack/ore/diamond(src)
