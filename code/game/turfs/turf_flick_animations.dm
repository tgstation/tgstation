/turf/proc/turf_animation(var/anim_icon,var/anim_state,var/anim_x=0, var/anim_y=0, var/anim_layer=MOB_LAYER+1, var/anim_sound=null, var/anim_color=null)
	if(!c_animation)//spamming turf animations can have unintended effects, such as the overlays never disapearing. hence this check.
		if(anim_sound)
			playsound(src, anim_sound, 50, 1)
		c_animation = new /atom/movable/overlay(src)
		c_animation.name = "turf_animation"
		c_animation.density = 0
		c_animation.anchored = 1
		c_animation.icon = anim_icon
		c_animation.icon_state = anim_state
		c_animation.layer = anim_layer
		c_animation.master = src
		c_animation.pixel_x = anim_x
		c_animation.pixel_y = anim_y
		if(anim_color)
			c_animation.color = anim_color
		flick("turf_animation",c_animation)
		spawn(10)
			del(c_animation)


/*
//called when the tile is cultified
/turf/proc/cultification()
	if(!c_animation)
		c_animation = new /atom/movable/overlay(src)
		c_animation.name = "cultification"
		c_animation.density = 0
		c_animation.anchored = 1
		c_animation.icon = 'icons/effects/effects.dmi'
		c_animation.layer = 3
		c_animation.master = src
		if(density)
			c_animation.icon_state = "cultwall"
		else
			c_animation.icon_state = "cultfloor"
		c_animation.pixel_x = 0
		c_animation.pixel_y = 0
		flick("cultification",c_animation)
		spawn(10)
			del(c_animation)

//called by various cult runes
/turf/proc/invocanimation(var/animation_type)
	if(!c_animation)
		c_animation = new /atom/movable/overlay(src)
		c_animation.name = "invocanimation"
		c_animation.density = 0
		c_animation.anchored = 1
		c_animation.icon = 'icons/effects/effects.dmi'
		c_animation.layer = 5
		c_animation.master = src
		c_animation.icon_state = "[animation_type]"
		c_animation.pixel_x = 0
		c_animation.pixel_y = 0
		flick("invocanimation",c_animation)
		spawn(10)
			del(c_animation)

//called whenever a null rod is blocking a spell or rune
/turf/proc/nullding()
	playsound(src, 'sound/piano/Ab7.ogg', 50, 1)
	if(!c_animation)
		c_animation = new /atom/movable/overlay(src)
		c_animation.name = "nullding"
		c_animation.density = 0
		c_animation.anchored = 1
		c_animation.icon = 'icons/effects/96x96.dmi'
		c_animation.layer = 5
		c_animation.master = src
		c_animation.icon_state = "nullding"
		c_animation.pixel_x = -32
		c_animation.pixel_y = -32
		flick("nullding",c_animation)
		spawn(10)
			del(c_animation)


/turf/proc/beamin(var/color)
	if(color == "admin")
		playsound(src, 'sound/misc/adminspawn.ogg', 50, 1)
		color = ""
	else
		playsound(src, 'sound/weapons/emitter2.ogg', 50, 1)
	if(!c_animation)
		c_animation = new /atom/movable/overlay(src)
		c_animation.name = "beamin"
		c_animation.density = 0
		c_animation.anchored = 1
		c_animation.icon = 'icons/effects/96x96.dmi'
		c_animation.layer = 5
		c_animation.master = src
		c_animation.pixel_x = -32
		c_animation.icon_state = "beamin-[color]"
		if(color == "alien")
			c_animation.pixel_x = -16
		flick(icon_state,c_animation)
		spawn(10)
			del(c_animation)


/turf/proc/rejuv()
	playsound(src, 'sound/effects/rejuvinate.ogg', 50, 1)
	if(!c_animation)
		c_animation = new /atom/movable/overlay(src)
		c_animation.name = "rejuvinate"
		c_animation.density = 0
		c_animation.anchored = 1
		c_animation.icon = 'icons/effects/64x64.dmi'
		c_animation.layer = 5
		c_animation.master = src
		c_animation.icon_state = "rejuvinate"
		c_animation.pixel_x = -16
		flick("rejuvinate",c_animation)
		spawn(10)
			del(c_animation)


/turf/proc/busteleport(var/tpsound=1)
	if(tpsound)
		playsound(src, 'sound/effects/busteleport.ogg', 50, 1)
	if(!c_animation)
		c_animation = new /atom/movable/overlay(src)
		c_animation.name = "busteleport"
		c_animation.density = 0
		c_animation.anchored = 1
		c_animation.icon = 'icons/effects/160x160.dmi'
		c_animation.layer = 5
		c_animation.master = src
		c_animation.pixel_x = -64
		c_animation.pixel_y = -32
		c_animation.icon_state = "busteleport"
		flick("busteleport",c_animation)
		spawn(10)
			del(c_animation)
*/