/obj/item/weapon/storage/pill_bottle/dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"

/obj/item/weapon/storage/pill_bottle/dice/New()
	..()
	var/list/include = list("1","2","4","6","8","10","00","12","20","100")
	while(include.len > 7)
		include -= pick(include)
	if("1" in include)		new /obj/item/weapon/dice/d1(src)
	if("2" in include)		new /obj/item/weapon/dice/d2(src)
	if("4" in include)		new /obj/item/weapon/dice/d4(src)
	if("6" in include)		new /obj/item/weapon/dice(src)
	if("8" in include)		new /obj/item/weapon/dice/d8(src)
	if("10" in include)		new /obj/item/weapon/dice/d10(src)
	if("00" in include)		new /obj/item/weapon/dice/d00(src)
	if("12" in include)		new /obj/item/weapon/dice/d12(src)
	if("20" in include)		new /obj/item/weapon/dice/d20(src)
	if("100" in include)	new /obj/item/weapon/dice/d100(src)

/obj/item/weapon/dice
	name = "d6"
	desc = "A die with six sides. Basic and servicable."
	icon = 'icons/obj/dice.dmi'
	icon_state = "d6"
	w_class = 1
	var/sides = 6
	var/result = null

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

/obj/item/weapon/dice/attack_self(mob/user)
	diceroll(user)

/obj/item/weapon/dice/throw_at(atom/target, range, speed, mob/user, spin=1)
	if(!..())
		return
	diceroll(user)

/obj/item/weapon/dice/proc/diceroll(mob/user)
	result = rand(1, sides)
	var/comment = ""
	if(sides == 20 && result == 20)
		comment = "Nat 20!"
	else if(sides == 20 && result == 1)
		comment = "Ouch, bad luck."
	update_icon()
	if(initial(icon_state) == "d00")
		result = (result - 1)*10
	if(user != null) //Dice was rolled in someone's hand
		user.visible_message("[user] has thrown [src]. It lands on [result]. [comment]", \
							 "<span class='notice'>You throw [src]. It lands on [result]. [comment]</span>", \
							 "<span class='italics'>You hear [src] rolling.</span>")
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
	overlays.Cut()
	if(sides == 100)
		return
	overlays += "[src.icon_state][src.result]"