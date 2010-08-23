/*
CONTAINS:
BANANANANANA
BANANA PEEL
BIKE HORN

*/

/obj/item/weapon/banana/attack_self(mob/M as mob)
	var/obj/item/weapon/bananapeel/W = new /obj/item/weapon/bananapeel( M )
	M << "\blue You peel the banana."
	if (M.hand)
		M.l_hand = W
	else
		M.r_hand = W
	W.layer = 20
	W.add_fingerprint(M)
	del(src)
	return

/obj/item/weapon/bananapeel/HasEntered(AM as mob|obj)
	if (istype(AM, /mob/living/carbon))
		var/mob/M =	AM
		if ((istype(M, /mob/living/carbon/human) && istype(M:shoes, /obj/item/clothing/shoes/galoshes)))
			return

		M.pulling = null
		M << "\blue You slipped on the banana peel!"
		playsound(src.loc, 'slip.ogg', 50, 1, -3)
		M.stunned = 8
		M.weakened = 5

/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return