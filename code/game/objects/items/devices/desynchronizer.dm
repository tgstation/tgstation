/obj/item/desynchronizer
	name = "desynchronizer"
	desc = "An experimental device that can temporarily desynchronize the user from spacetime, effectively making them disappear while it's active."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker_forcefield"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NOBLUDGEON
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	materials = list(MAT_METAL=250, MAT_GLASS=500)
	var/max_duration = 3000
	var/duration = 300
	var/obj/effect/abstract/sync_holder/sync_holder
	
/obj/item/desynchronizer/attack_self(mob/user)
	if(!sync_holder)
		desync(user)
	else
		resync()

/obj/item/desynchronizer/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to customize the duration. Current duration: [duration / 10] seconds.</span>")
	to_chat(user, "<span class='notice'>Can be used to .</span>")
	
/obj/item/desynchronizer/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	var/new_duration = input(user, "Set the duration (5-300):", "Desynchronizer", duration / 10) as null|num
	if(new_duration)
		new_duration = new_duration SECONDS
		new_duration = CLAMP(new_duration, 50, max_duration)
		duration = new_duration
		to_chat(user, "<span class='notice'>You set the duration to [duration / 10] seconds.</span>")

/obj/item/desynchronizer/proc/desync(mob/living/user)
	if(sync_holder)
		return
	sync_holder = new(drop_location())
	to_chat(user, "<span class='notice'>You activate [src], desynchronizing yourself from the present. You can still see your surroundings, but you feel eerily dissociated from reality.</span>")
	user.forceMove(sync_holder)
	addtimer(CALLBACK(src, .proc/resync), duration)
	
/obj/item/desynchronizer/proc/resync()
	QDEL_NULL(sync_holder)

/obj/item/desynchronizer/Destroy()
	resync()
	return ..()

/obj/effect/abstract/sync_holder
	name = "desyncronized pocket"
	desc = "A pocket in spacetime, keeping the user a fraction of a second in the future."
	icon = null
	icon_state = null
	alpha = 0
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

/obj/structure/abstract/sync_holder/Destroy()
	for(var/I in src)
		var/atom/movable/AM = I
		AM.forceMove(drop_location())
	return ..()

/obj/structure/abstract/sync_holder/AllowDrop()
	return TRUE //no dropping spaghetti out of your spacetime pocket
