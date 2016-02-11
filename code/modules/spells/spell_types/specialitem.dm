/obj/effect/proc_holder/spell/targeted/specialitem
	name = "Special Item"
	desc = "This spell is a test spell used to summon a specific item."
	school = "evocation"
	charge_max = 100
	clothes_req = 0
	invocation = "Firo Cona"
	invocation_type = "shout"
	range = -1
	level_max = 0 //cannot be improved
	cooldown_min = 100
	include_user = 1

	action_icon_state = "fireball"

	var/obj/item/specialItem = /obj/item/weapon/bikehorn/rubberducky //Quack

/obj/effect/proc_holder/spell/targeted/specialitem/cast(list/targets,mob/user = usr)
	if(!iscarbon(user))
		user << "<span class='warning'>You lack the hands to cast this.</span>"
	var/mob/living/carbon/C = user
	var/itemCreated = new specialItem
	if(!C.put_in_hands(itemCreated))
		user << "<span class='warning'>Your hands are full!</span>"
		return 0
	user << "<span class='notice'>[itemCreated] appears in your hand!</span>"
	return 1


/obj/effect/proc_holder/spell/targeted/specialitem/burninghands
	name = "Burning Hands"
	desc = "Ignite your hand to produce a cone of flame at will!"
	specialItem = /obj/item/weapon/flamehand //flamethrower.dm