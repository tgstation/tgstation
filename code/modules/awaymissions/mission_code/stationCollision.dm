/* Station-Collision(sc) away mission map specific stuff
 *
 * Notes:
 *		Feel free to use parts of this map, or even all of it for your own project. Just include me in the credits :)
 *
 *		Some of this code unnecessary, but the intent is to add a little bit of everything to serve as examples
 *		for anyone who wants to make their own stuff.
 *
 * Contains:
 *		Landmarks
 *		Guns
 *		Safe code hints
 *		Captain's safe
 *		Modified Nar-Sie
 */



/*
 * Landmarks - Instead of spawning a new object type, I'll spawn the bible using a landmark!
 */
/obj/effect/landmark/sc_bible_spawner
	name = "Safecode hint spawner"

/obj/effect/landmark/sc_bible_spawner/New()
	var/obj/item/weapon/storage/book/bible/B = new /obj/item/weapon/storage/book/bible/booze(src.loc)
	B.name = "The Holy book of the Geometer"
	B.deity_name = "Narsie"
	B.icon_state = "melted"
	B.item_state = "melted"
	new /obj/item/weapon/paper/sc_safehint_paper_bible(B)
	new /obj/item/weapon/pen(B)
	qdel(src)

/*
 * Guns - I'm making these specifically so that I dont spawn a pile of fully loaded weapons on the map.
 */
//Captain's retro laser - Fires practice laser shots instead.
/obj/item/weapon/gun/energy/laser/retro/sc_retro
	name ="retro laser"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's security or military forces."
//	projectile_type = "/obj/item/projectile/practice"
	clumsy_check = 0 //No sense in having a harmless gun blow up in the clowns face

//Syndicate sub-machine guns.
/obj/item/weapon/gun/ballistic/automatic/c20r/sc_c20r

/obj/item/weapon/gun/ballistic/automatic/c20r/sc_c20r/Initialize()
	. = ..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(95)) //95% chance
			magazine.stored_ammo -= ammo

//Barman's shotgun
/obj/item/weapon/gun/ballistic/shotgun/sc_pump

/obj/item/weapon/gun/ballistic/shotgun/sc_pump/Initialize()
	. = ..()
	for(var/ammo in magazine.stored_ammo)
		if(prob(95)) //95% chance
			magazine.stored_ammo -= ammo

//Lasers
/obj/item/weapon/gun/energy/laser/practice/sc_laser
	name = "Old laser"
	desc = "A once potent weapon, years of dust have collected in the chamber and lens of this weapon, weakening the beam significantly."
	clumsy_check = 0

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
/obj/item/weapon/paper/sc_safehint_paper_prison
	name = "smudged paper"

/obj/item/weapon/paper/sc_safehint_paper_prison/New()
	info = "<i>The ink is smudged, you can only make out a couple numbers:</i> '[GLOB.sc_safecode1]**[GLOB.sc_safecode4]*'"

/obj/item/weapon/paper/sc_safehint_paper_hydro
	name = "shredded paper"
/obj/item/weapon/paper/sc_safehint_paper_hydro/New()
	info = "<i>Although the paper is shredded, you can clearly see the number:</i> '[GLOB.sc_safecode2]'"

/obj/item/weapon/paper/sc_safehint_paper_caf
	name = "blood-soaked paper"
	//This does not have to be in New() because it is a constant. There are no variables in it i.e. [sc_safcode]
	info = "<font color=red><i>This paper is soaked in blood, it is impossible to read any text.</i></font>"

/obj/item/weapon/paper/sc_safehint_paper_bible
	name = "hidden paper"
/obj/item/weapon/paper/sc_safehint_paper_bible/New()
	info = {"<i>It would appear that the pen hidden with the paper had leaked ink over the paper.
			However you can make out the last three digits:</i>'[GLOB.sc_safecode3][GLOB.sc_safecode4][GLOB.sc_safecode5]'
			"}

/obj/item/weapon/paper/sc_safehint_paper_shuttle
	info = {"<b>Target:</b> Research-station Epsilon<br>
			<b>Objective:</b> Prototype weaponry. The captain likely keeps them locked in her safe.<br>
			<br>
			Our on-board spy has learned the code and has hidden away a few copies of the code around the station. Unfortunatly he has been captured by security
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
/obj/item/weapon/storage/secure/safe/sc_ssafe
	name = "Captain's secure safe"

/obj/item/weapon/storage/secure/safe/sc_ssafe/New()
	..()
	l_code = "[GLOB.sc_safecode1][GLOB.sc_safecode2][GLOB.sc_safecode3][GLOB.sc_safecode4][GLOB.sc_safecode5]"
	l_set = 1
	new /obj/item/weapon/gun/energy/mindflayer(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/clothing/suit/space/hardsuit/cult(src)
	//new /obj/item/weapon/teleportation_scroll(src)
	new /obj/item/weapon/ore/diamond(src)

/*
 * Modified Nar-Sie
 */
/obj/singularity/narsie/sc_Narsie
	desc = "Your body becomes weak and your feel your mind slipping away as you try to comprehend what you know can't be possible."
	move_self = 0 //Contianed narsie does not move!
	grav_pull = 0 //Contained narsie does not pull stuff in!
	var/uneatable = list(/turf/open/space, /obj/effect/overlay, /mob/living/simple_animal/hostile/construct)
//Override this to prevent no adminlog runtimes and admin warnings about a singularity without containment
/obj/singularity/narsie/sc_Narsie/admin_investigate_setup()
	return

/obj/singularity/narsie/sc_Narsie/process()
	eat()
	if(prob(25))
		mezzer()

/obj/singularity/narsie/sc_Narsie/consume(atom/A)
	if(is_type_in_list(A, uneatable))
		return 0
	if(isliving(A))
		var/mob/living/L = A
		L.gib()
	else if(istype(A, /obj/))
		var/obj/O = A
		O.ex_act(EXPLODE_DEVASTATE)
		if(O) qdel(O)
	else if(isturf(A))
		var/turf/T = A
		if(T.intact)
			for(var/obj/O in T.contents)
				if(O.level != 1)
					continue
				if(O.invisibility == INVISIBILITY_MAXIMUM)
					src.consume(O)
		T.ChangeTurf(/turf/open/space)
	return

/obj/singularity/narsie/sc_Narsie/ex_act()
	return