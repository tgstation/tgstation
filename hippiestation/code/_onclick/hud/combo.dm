/datum/hud/var/obj/screen/combo/combo_object

/obj/screen/combo
	icon = 'hippiestation/icons/mob/screen_gen.dmi'
	name = "combo"
	icon_state = null
	screen_loc = ui_combo
	var/cooldown = 0
	mouse_opacity = 0

/obj/screen/combo/update_icon(var/streak="", var/num = 100)
	cut_overlays()
	icon_state = null
	cooldown = world.time + num
	var/i = 1
	if(streak && length(streak))
		icon_state = "combo"
		while(i<=length(streak))
			var/n_letter = copytext(streak, i, i + 1)//copies text from a certain distance. In this case, only one letter at a time.
			var/image/img = image(icon,src,"combo_[n_letter]")
			if(img)
				i++
				var/spacing = 16
				img.pixel_x = -16 - spacing * length(streak) / 2 + spacing * i
				add_overlay(img)
