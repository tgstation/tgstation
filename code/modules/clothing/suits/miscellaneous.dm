/*
 * Contains:
 *		Lasertag
 *		Costume
 *		Misc
 */

/*
 * Lasertag
 */

/obj/item/clothing/suit/bluetag
	name = "blue laser tag armour"
	desc = "Blue Pride, Station Wide"
	icon_state = "bluetag"
	item_state = "bluetag"
	blood_overlay_type = "armor"
	origin_tech = "materials=1;magnets=2"
	body_parts_covered = FULL_TORSO
	allowed = list (/obj/item/weapon/gun/energy/laser/bluetag)
	siemens_coefficient = 3.0

/obj/item/clothing/suit/redtag
	name = "red laser tag armour"
	desc = "Pew pew pew"
	icon_state = "redtag"
	item_state = "redtag"
	blood_overlay_type = "armor"
	origin_tech = "materials=1;magnets=2"
	body_parts_covered = FULL_TORSO
	allowed = list (/obj/item/weapon/gun/energy/laser/redtag)
	siemens_coefficient = 3.0

/*
 * Costume
 */
/obj/item/clothing/suit/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	flags = FPRINT
	species_fit = list("Vox")
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV

/obj/item/clothing/suit/hgpirate
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	flags = FPRINT
	species_fit = list("Vox")
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV


/obj/item/clothing/suit/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"//broken on mob, item fine
	flags = FPRINT
	siemens_coefficient = 1
	fire_resist = T0C+5200
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS

/obj/item/clothing/suit/greatcoat
	name = "great coat"
	desc = "A Nazi great coat"
	icon_state = "nazi"//broken on mob, item fine
	flags = FPRINT


/obj/item/clothing/suit/johnny_coat
	name = "johnny~~ coat"
	desc = "Johnny~~"
	icon_state = "johnny"//broken on mob, item fine
	item_state = "johnny"
	flags = FPRINT


/obj/item/clothing/suit/justice
	name = "justice suit"
	desc = "this pretty much looks ridiculous"
	icon_state = "justice"
	flags = FPRINT
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS

/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	flags = FPRINT  | ONESIZEFITSALL
	allowed = list(/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/spacecash)


/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "vest"
	item_state = "wcoat"
	blood_overlay_type = "armor"
	body_parts_covered = FULL_TORSO


/obj/item/clothing/suit/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	item_state = "overalls"
	body_parts_covered = FULL_TORSO|LEGS


/obj/item/clothing/suit/syndicatefake
	name = "red space suit replica"
	icon_state = "syndicate"
	item_state = "space_suit_syndicate"
	desc = "A plastic replica of the syndicate space suit, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = 3
	flags = FPRINT
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen,/obj/item/toy)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS


/obj/item/clothing/suit/hastur
	name = "Hastur's Robes"
	desc = "Robes not meant to be worn by man"
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS

/obj/item/clothing/suit/imperium_monk
	name = "Imperium monk"
	desc = "Have YOU killed a xenos today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = FULL_TORSO|LEGS|FEET|ARMS


/obj/item/clothing/suit/chickensuit
	name = "Chicken Suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = FULL_TORSO|LEGS|FEET|ARMS
	siemens_coefficient = 2.0


/obj/item/clothing/suit/monkeysuit
	name = "Monkey Suit"
	desc = "A suit that looks like a primate"
	icon_state = "monkeysuit"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	siemens_coefficient = 2.0


/obj/item/clothing/suit/holidaypriest
	name = "Holiday Priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	item_state = "holidaypriest"


/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	item_state = "cardborg"
	starting_materials = list(MAT_CARDBOARD = 11250)
	w_type=RECYK_MISC

/*
 * Misc
 */

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer."
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	origin_tech = "biotech=2"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS

/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	body_parts_covered = ARMS|FULL_TORSO

//Blue suit jacket toggle
/obj/item/clothing/suit/suit/verb/toggle()
	set name = "Toggle Jacket Buttons"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.isUnconscious() || usr.restrained())
		return 0

	if(src.icon_state == "suitjacket_blue_open")
		src.icon_state = "suitjacket_blue"
		src.item_state = "suitjacket_blue"
		to_chat(usr, "You button up the suit jacket.")
	else if(src.icon_state == "suitjacket_blue")
		src.icon_state = "suitjacket_blue_open"
		src.item_state = "suitjacket_blue_open"
		to_chat(usr, "You unbutton the suit jacket.")
	else
		to_chat(usr, "You button-up some imaginary buttons on your [src].")
		return
	usr.update_inv_wear_suit()

//coats

/obj/item/clothing/suit/leathercoat
	name = "leather coat"
	desc = "A long, thick black leather coat."
	icon_state = "leathercoat"//broken completely
	flags = FPRINT

/obj/item/clothing/suit/browncoat
	name = "brown leather coat"
	desc = "A long, brown leather coat."
	icon_state = "browncoat"//broken completely
	flags = FPRINT

/obj/item/clothing/suit/neocoat
	name = "black coat"
	desc = "A flowing, black coat."
	icon_state = "neocoat"//broken completely
	flags = FPRINT

//actual suits

/obj/item/clothing/suit/creamsuit
	name = "cream suit"
	desc = "A cream coloured, genteel suit."
	icon_state = "creamsuit"//broken completely
	flags = FPRINT

//stripper

/obj/item/clothing/under/stripper/stripper_pink
	name = "pink swimsuit"
	desc = "A rather skimpy pink swimsuit."
	icon_state = "stripper_p_under"
	_color = "stripper_p"
	siemens_coefficient = 1

/obj/item/clothing/under/stripper/stripper_green
	name = "green swimsuit"
	desc = "A rather skimpy green swimsuit."
	icon_state = "stripper_g_under"
	_color = "stripper_g"
	siemens_coefficient = 1

/obj/item/clothing/suit/stripper/stripper_pink
	name = "pink skimpy dress"
	desc = "A rather skimpy pink dress."
	icon_state = "stripper_p_over"
	item_state = "stripper_p"
	siemens_coefficient = 1

/obj/item/clothing/suit/stripper/stripper_green
	name = "green skimpy dress"
	desc = "A rather skimpy green dress."
	icon_state = "stripper_g_over"
	item_state = "stripper_g"
	siemens_coefficient = 1

/obj/item/clothing/under/stripper/mankini
	name = "the mankini"
	desc = "No honest man would wear this abomination"
	icon_state = "mankini"
	_color = "mankini"
	siemens_coefficient = 1

/obj/item/clothing/suit/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	item_state = "xenos_helm"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	siemens_coefficient = 2.0

//swimsuit

/obj/item/clothing/under/swimsuit
	siemens_coefficient = 1
	body_parts_covered = 0

/obj/item/clothing/under/swimsuit/black
	name = "black swimsuit"
	desc = "An oldfashioned black swimsuit."
	icon_state = "swim_black"
	_color = "swim_black"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/blue
	name = "blue swimsuit"
	desc = "An oldfashioned blue swimsuit."
	icon_state = "swim_blue"
	_color = "swim_blue"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/purple
	name = "purple swimsuit"
	desc = "An oldfashioned purple swimsuit."
	icon_state = "swim_purp"
	_color = "swim_purp"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/green
	name = "green swimsuit"
	desc = "An oldfashioned green swimsuit."
	icon_state = "swim_green"
	_color = "swim_green"
	siemens_coefficient = 1

/obj/item/clothing/under/swimsuit/red
	name = "red swimsuit"
	desc = "An oldfashioned red swimsuit."
	icon_state = "swim_red"
	_color = "swim_red"
	siemens_coefficient = 1

/obj/item/clothing/suit/simonjacket
	name = "Simon's Jacket"
	desc = "Now you too can pierce the heavens"
	icon_state = "simonjacket"
	species_fit = list("Vox")
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV

/obj/item/clothing/suit/kaminacape
	name = "Kamina's Cape"
	desc = "Don't believe in yourself, dumbass. Believe in me. Believe in the Kamina who believes in you."
	icon_state = "kaminacape"
	body_parts_covered = 0

/obj/item/clothing/suit/storage/bandolier
	name = "bandolier"
	desc = "A bandolier designed to hold up to eight shotgun shells."
	icon_state = "bandolier"
	storage_slots = 8
	max_combined_w_class = 20
	can_only_hold = list("/obj/item/ammo_casing/shotgun")

/obj/item/clothing/suit/officercoat
	name = "Officer's Coat"
	desc = "Ein Mantel gemacht, um die Juden zu bestrafen."
	icon_state = "officersuit"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV

/obj/item/clothing/suit/soldiercoat
	name = "Soldier's Coat"
	desc = "Und das heiﬂt: Erika"
	icon_state = "soldiersuit"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV

/obj/item/clothing/suit/russofurcoat
	name = "russian fur coat"
	desc = "Let the land do the fighting for you."
	icon_state = "russofurcoat"
	allowed = list(/obj/item/weapon/gun)
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV

/obj/item/clothing/suit/doshjacket
	name = "Plasterer's Jacket"
	desc = "Perfect for doing up the house."
	icon_state = "doshjacket"
	body_parts_covered = FULL_TORSO|ARMS

/obj/item/clothing/suit/lordadmiral
	name = "Lord Admiral's Coat"
	desc = "You'll be the Ruler of the King's Navy in no time."
	icon_state = "lordadmiral"
	allowed = list (/obj/item/weapon/gun)

/obj/item/clothing/suit/raincoat
	name = "Raincoat"
	desc = "Do you like Huey Lewis and the News?"
	icon_state = "raincoat"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|IGNORE_INV //transparent
	allowed = list (/obj/item/weapon/fireaxe)

/obj/item/clothing/suit/kefkarobe
	name = "Crazed Jester's Robe"
	desc = "Do I look like a waiter?"
	icon_state = "kefkarobe"

/obj/item/clothing/suit/libertycoat
	name = "Liberty Coat"
	desc = "Smells faintly of freedom."
	icon_state = "libertycoat"
	body_parts_covered = FULL_TORSO|ARMS

/obj/item/clothing/suit/storage/draculacoat
	name = "Vampire Coat"
	desc = "What is a man? A miserable little pile of secrets."
	icon_state = "draculacoat"
	blood_overlay_type = "coat"
	cant_hold = list(/obj/item/weapon/nullrod, /obj/item/weapon/storage/bible)
	armor = list(melee = 30, bullet = 20, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/maidapron
	name = "Apron"
	desc = "Simple white apron."
	icon_state = "maidapron"
	body_parts_covered = FULL_TORSO

/obj/item/clothing/suit/clownpiece
	name = "small fairy wings"
	desc = "Some small and translucid insect-like wings."
	icon_state = "clownpiece"
	body_parts_covered = 0

/obj/item/clothing/suit/clownpiece/flying
	name = "small fairy wings"
	desc = "Some small and translucid insect-like wings. Looks like these are the real deal!"
	icon_state = "clownpiece-fly"

/obj/item/clothing/suit/clownpiece/flying/attack_hand(var/mob/living/carbon/human/H)
	if(!istype(H))
		return ..()
	if((src == H.wear_suit) && H.flying)
		H.flying = 0
		animate(H, pixel_y = pixel_y + 10 , time = 1, loop = 1)
		animate(H, pixel_y = pixel_y, time = 10, loop = 1, easing = SINE_EASING)
		animate(H)
		if(H.lying)//aka. if they have just been stunned
			H.pixel_y -= 6
	..()

/obj/item/clothing/suit/clownpiece/flying/equipped(var/mob/user, var/slot)
	var/mob/living/carbon/human/H = user
	if(!istype(H)) return
	if((slot == slot_wear_suit) && !user.flying)
		user.flying = 1
		animate(user, pixel_y = pixel_y + 10 , time = 10, loop = 1, easing = SINE_EASING)

/obj/item/clothing/suit/clownpiece/flying/dropped(mob/user as mob)
	if(user.flying)
		user.flying = 0
		animate(user, pixel_y = pixel_y + 10 , time = 1, loop = 1)
		animate(user, pixel_y = pixel_y, time = 10, loop = 1, easing = SINE_EASING)
		animate(user)
		if(user.lying)//aka. if they have just been stunned
			user.pixel_y -= 6
	..()


/obj/item/clothing/suit/jumper/christmas
	name = "christmas jumper"
	desc = "Made by professional knitting nanas to truly fit the festive mood."
	heat_conductivity = INS_ARMOUR_HEAT_CONDUCTIVITY
	body_parts_covered = FULL_TORSO|ARMS
	icon_state = "cjumper-red"

/obj/item/clothing/suit/jumper/christmas/red
	desc = "Made by professional knitting nanas to truly fit the festive mood. This one has a tasteful red colour to it, and a festive Fir tree."
	icon_state = "cjumper-red"

/obj/item/clothing/suit/jumper/christmas/blue
	desc = "Made by professional knitting nanas to truly fit the festive mood. This one has a nice light blue colouring to it, and has a snowman on it."
	icon_state = "cjumper-blue"

/obj/item/clothing/suit/jumper/christmas/green
	desc = "Made by professional knitting nanas to truly fit the festive mood. This one is green in colour, and has a reindeer with a red nose on the front. At least you think it's a reindeer."
	icon_state = "cjumper-green"

/obj/item/clothing/suit/spaceblanket
	w_class = 2
	icon_state = "shittyuglyawfulBADblanket"
	name = "space blanket"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	desc = "First developed by NASA in 1964 for the US space program!"
	heat_conductivity = 0 // Good luck losing heat in this!
	slowdown = 10
	var/bearpelt = 0

/obj/item/clothing/suit/spaceblanket/attackby(obj/item/W,mob/user)
	..()
	if(istype(W,/obj/item/clothing/head/bearpelt) && !bearpelt)
		to_chat(user,"<span class='notice'>You add \the [W] to \the [src].</span>")
		qdel(W)
		qdel(src)
		var/obj/advanced = new /obj/item/clothing/suit/spaceblanket/advanced (src.loc)
		user.put_in_hands(advanced)

/obj/item/clothing/suit/spaceblanket/advanced
	name = "advanced space blanket"
	desc = "Using an Advanced Space Blanket requires Advanced Power Blanket Training."
	icon_state = "goodblanket"
	heat_conductivity = 0
	slowdown = 5
	bearpelt = 1
