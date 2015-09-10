/obj/structure/closet/cardboard
	name = "large cardboard box"
	desc = "Just a box..."
	//icon_state = "cardboard" //NEEDS SPRITES
	health = 10 //At the end of the day it's still just a box
	mob_storage_capacity = 1
	burntime = 20
	can_weld_shut = 0
	cutting_tool = /obj/item/weapon/wirecutters
	open_sound = 'sound/effects/rustle2.ogg'
	cutting_sound = 'sound/items/poster_ripped.ogg'
	material_drop = /obj/item/stack/sheet/cardboard
	var/move_delay = 0

/obj/structure/closet/cardboard/relaymove(mob/user, direction) //!
	if(opened || move_delay || user.stat || user.stunned || user.weakened || user.paralysis || !isturf(loc) || !has_gravity(loc))
		return
	step(src, direction)
	move_delay = 1
	spawn(config.walk_speed) //Kept you waiting, huh?
		move_delay = 0