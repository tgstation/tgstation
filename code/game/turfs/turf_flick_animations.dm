//called when the tile is cultified
/turf/proc/cultification()
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
	spawn()
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
	playsound(src, 'sound/weapons/emitter2.ogg', 50, 1)
	spawn()
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
