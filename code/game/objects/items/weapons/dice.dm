/obj/item/weapon/storage/pill_bottle/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"

/obj/item/weapon/storage/pill_bottle/dice/New()
	..()
	var/special_die = pick("1","2","fudge","00","100")
	if(special_die == "1")
		new /obj/item/weapon/dice/d1(src)
	if(special_die == "2")
		new /obj/item/weapon/dice/d2(src)
	new /obj/item/weapon/dice/d4(src)
	new /obj/item/weapon/dice/d6(src)
	if(special_die == "fudge")
		new /obj/item/weapon/dice/fudge(src)
	new /obj/item/weapon/dice/d8(src)
	new /obj/item/weapon/dice/d10(src)
	if(special_die == "00")
		new /obj/item/weapon/dice/d00(src)
	new /obj/item/weapon/dice/d12(src)
	new /obj/item/weapon/dice/d20(src)
	if(special_die == "100")
		new /obj/item/weapon/dice/d100(src)

/obj/item/weapon/dice //depreciated d6, use /obj/item/weapon/dice/d6 if you actually want a d6
	name = "die"
	desc = "A die with six sides. Basic and servicable."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = 1
	var/sides = 6
	var/result = null
	var/list/special_faces = list() //entries should match up to sides var if used

/obj/item/weapon/dice/New()
	result = rand(1, sides)
	update_icon()

/obj/item/weapon/dice/d1
	name = "d1"
	desc = "A die with one side. Deterministic!"
	icon_state = "d1"
	sides = 1

/obj/item/weapon/dice/d2
	name = "d2"
	desc = "A die with two sides. Coins are undignified!"
	icon_state = "d2"
	sides = 2

/obj/item/weapon/dice/d4
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/weapon/dice/d6
	name = "d6"

/obj/item/weapon/dice/fudge
	name = "fudge die"
	desc = "A die with six sides but only three results. Is this a plus or a minus? Your mind is drawing a blank..."
	sides = 3 //shhh
	icon_state = "fudge"
	special_faces = list("minus","blank","plus")

/obj/item/weapon/dice/d8
	name = "d8"
	desc = "A die with eight sides. It feels... lucky."
	icon_state = "d8"
	sides = 8

/obj/item/weapon/dice/d10
	name = "d10"
	desc = "A die with ten sides. Useful for percentages."
	icon_state = "d10"
	sides = 10

/obj/item/weapon/dice/d00
	name = "d00"
	desc = "A die with ten sides. Works better for d100 rolls than a golfball."
	icon_state = "d00"
	sides = 10

/obj/item/weapon/dice/d12
	name = "d12"
	desc = "A die with twelve sides. There's an air of neglect about it."
	icon_state = "d12"
	sides = 12

/obj/item/weapon/dice/d20
	name = "d20"
	desc = "A die with twenty sides. The prefered die to throw at the GM."
	icon_state = "d20"
	sides = 20

/obj/item/weapon/dice/d100
	name = "d100"
	desc = "A die with one hundred sides! Probably not fairly weighted..."
	icon_state = "d100"
	sides = 100

/obj/item/weapon/dice/d100/update_icon()
	return

/obj/item/weapon/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/weapon/dice/throw_at(atom/target, range, speed, mob/user, spin=1)
	if(!..())
		return
	diceroll(user)

/obj/item/weapon/dice/proc/diceroll(mob/user)
	result = rand(1, sides)
	var/fake_result = rand(1, sides)//Daredevil isn't as good as he used to be
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "Nat 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	update_icon()
	if(initial(icon_state) == "d00")
		result = (result - 1)*10
	if(special_faces.len == sides)
		result = special_faces[result]
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] has thrown [src]. It lands on [result]. [comment]", \
							 "<span class='notice'>You throw [src]. It lands on [result]. [comment]</span>", \
							 "<span class='italics'>You hear [src] rolling, it sounds like a [fake_result].</span>")
	else if(src.throwing == 0) //Dice was thrown and is coming to rest
		visible_message("<span class='notice'>[src] rolls to a stop, landing on [result]. [comment]</span>")

/obj/item/weapon/dice/d4/Crossed(mob/living/carbon/human/H)
	if(istype(H) && !H.shoes)
		if(PIERCEIMMUNE in H.dna.species.specflags)
			return 0
		H << "<span class='userdanger'>You step on the D4!</span>"
		H.apply_damage(4,BRUTE,(pick("l_leg", "r_leg")))
		H.Weaken(3)

/obj/item/weapon/dice/update_icon()
	cut_overlays()
	add_overlay("[src.icon_state][src.result]")