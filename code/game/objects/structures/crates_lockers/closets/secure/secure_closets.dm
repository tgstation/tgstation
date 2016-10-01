/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = 1
	icon_state = "secure"
	health = 250
	maxhealth = 250
	armor = list(melee = 30, bullet = 50, laser = 50, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 80, acid = 80)
	secure = 1

/obj/structure/closet/secure_closet/attacked_by(obj/item/I, mob/living/user)
	if(I.force < 20)
		take_damage(0)
	else
		..()