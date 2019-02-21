/obj/item/pickaxe/minecraft
	name = "Pickaxe"
	desc = "it mines things, very cool!"
	icon = 'icons/obj/minecraft_items.dmi'
	icon_state = "pickaxe"

/turf/closed/wall/minecraft
	name = "dirt block"
	desc = "it's....totally square?"
	icon = 'icons/turf/minecraft.dmi'
	icon_state = "dirt"
	smooth = FALSE
	var/strong = FALSE //can you mine this by hand? if false, you can
	var/hit_sounds = list('sound/effects/minecraft/grass1.ogg','sound/effects/minecraft/grass2.ogg','sound/effects/minecraft/grass3.ogg','sound/effects/minecraft/grass4.ogg')
	var/beingdug = FALSE
	var/floor_type = /turf/open/floor/minecraft
	var/drop_type = /obj/item/minecraft
	var/mob/steve
	var/ores = list(/obj/item/stack/ore/iron,/obj/item/stack/ore/uranium,/obj/item/stack/ore/diamond,/obj/item/stack/ore/silver,/obj/item/stack/ore/plasma,/obj/item/stack/ore/bluespace_crystal,/obj/item/stack/ore/bananium)

/turf/open/floor/attackby(obj/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/minecraft))
		to_chat(user, "You begin placing a block...")
		if(do_after(user, 20, target = src))
			var/obj/item/minecraft/X = I
			to_chat(user, "You place [I].")
			ChangeTurf(X.build_type)
			qdel(I)

/obj/item/minecraft
	name = "Block"
	desc = "You build things with it :)"
	icon = 'icons/obj/minecraft_items.dmi'
	icon_state = "dirt"
	var/build_type = /turf/closed/wall/minecraft

/obj/item/minecraft/stone
	icon_state = "stone"
	build_type = /turf/closed/wall/minecraft/stone

/obj/item/minecraft/cobblestone
	icon_state = "cobblestone"
	build_type = /turf/closed/wall/minecraft/cobblestone

/obj/item/minecraft/andesite
	icon_state = "andesite"
	build_type = /turf/closed/wall/minecraft/andesite

/obj/item/minecraft/stonebrick
	icon_state = "stonebrick"
	build_type = /turf/closed/wall/minecraft/stonebrick

/obj/item/minecraft/Initialize()
	. = ..()
	SpinAnimation(1000,1000)

/turf/closed/wall/minecraft/attack_hand(mob/user)
	if(strong)
		to_chat(user, "<span_class='warning'>[src] is too strong to mine by hand!</span>")
		return
	if(isliving(user))
		to_chat(user, "You start picking away at [src].")
		START_PROCESSING(SSfastprocess,src)
		beingdug = TRUE
		steve = user
		if(do_after(user, 30, target = src))
			var/sound = pick(hit_sounds)//Spam the mining sound minecraft style :)
			playsound(src,sound,50)
			new drop_type(src)
			ChangeTurf(floor_type)
		beingdug = FALSE
		STOP_PROCESSING(SSfastprocess,src)
		steve = null

/turf/closed/wall/minecraft/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/pickaxe))
		to_chat(user, "You start picking away at [src].")
		START_PROCESSING(SSfastprocess,src)
		beingdug = TRUE
		steve = user
		if(do_after(user, 20, target = src))
			var/sound = pick(hit_sounds)//Spam the mining sound minecraft style :)
			SEND_SOUND(user,sound)
			if(strong)
				if(prob(5))
					var/mineralType = pick(ores)
					var/num = rand(1,5)
					new mineralType(src, num)
					return
			new drop_type(src)
			ChangeTurf(floor_type)
		beingdug = FALSE
		STOP_PROCESSING(SSfastprocess,src)
		steve = null

/turf/closed/wall/minecraft/process()
	if(steve)
		var/sound = pick(hit_sounds)//Spam the mining sound minecraft style :)
		SEND_SOUND(steve, sound)

/turf/open/floor/minecraft
	name = "dirt block"
	desc = "it's....totally square?"
	icon_state = "dirt"
	icon = 'icons/turf/minecraft.dmi'

/turf/closed/wall/minecraft/stone
	name = "stone block"
	icon_state = "stone"
	strong = TRUE
	drop_type = /obj/item/minecraft/cobblestone
	floor_type = /turf/open/floor/minecraft/stone
	hit_sounds = list('sound/effects/minecraft/stone1.ogg','sound/effects/minecraft/stone2.ogg','sound/effects/minecraft/stone3.ogg','sound/effects/minecraft/stone4.ogg')

/turf/open/floor/minecraft/stone
	name = "stone block"
	icon_state = "stone"

/turf/closed/wall/minecraft/andesite
	name = "andesite block"
	icon_state = "andesite"
	strong = TRUE
	floor_type = /turf/open/floor/minecraft/stone
	drop_type = /obj/item/minecraft/andesite
	hit_sounds = list('sound/effects/minecraft/stone1.ogg','sound/effects/minecraft/stone2.ogg','sound/effects/minecraft/stone3.ogg','sound/effects/minecraft/stone4.ogg')

/turf/closed/wall/minecraft/stonebrick
	name = "stone brick block"
	icon_state = "stonebrick"
	strong = TRUE
	floor_type = /turf/open/floor/minecraft/stone
	drop_type = /obj/item/minecraft/stonebrick
	hit_sounds = list('sound/effects/minecraft/stone1.ogg','sound/effects/minecraft/stone2.ogg','sound/effects/minecraft/stone3.ogg','sound/effects/minecraft/stone4.ogg')

/turf/closed/wall/minecraft/cobblestone
	name = "cobblestone block"
	icon_state = "cobblestone"
	strong = TRUE
	floor_type = /turf/open/floor/minecraft/stone
	drop_type = /obj/item/minecraft/cobblestone
	hit_sounds = list('sound/effects/minecraft/stone1.ogg','sound/effects/minecraft/stone2.ogg','sound/effects/minecraft/stone3.ogg','sound/effects/minecraft/stone4.ogg')