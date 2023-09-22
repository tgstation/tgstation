/obj/item/food/prison_loaf
	name = "prison loaf"
	desc = "A barely edible brick of nutrients, designed as a low-cost solution to malnourishment."
	icon = 'monkestation/code/modules/loafing/icon/obj.dmi'
	icon_state = "loaf0"
	var/loaf_density = 1 //base loaf density
	var/can_condense = TRUE //for special loaves, make false


/obj/item/food/prison_loaf/proc/condense()
	if(!src.can_condense)
		return
	switch(src.loaf_density)

		if(0 to 10)
			src.name = "prison loaf"
			src.desc = "A barely edible brick of nutrients, designed as a low-cost solution to malnourishment."
			src.icon_state = "loaf0"
			src.force = 0
			src.throwforce = 0
		if(11 to 100)
			src.name = "dense prison loaf"
			src.desc = "This loaf is noticeably heavier than usual."
			src.icon_state = "loaf0"
			src.force = 3
			src.throwforce = 3
		if(101 to 250)
			src.name = "thicc ass prison loaf"
			src.desc = "This loaf is caked UP"
			src.icon_state = "loaf0"
			src.force = 5
			src.throwforce = 5
			src.throw_range = 6
		if(251 to 500)
			src.name = "thicc ass prison loaf"
			src.desc = "This loaf is caked UP"
			src.icon_state = "loaf1"
			src.force = 10
			src.throwforce = 10
			src.throw_range = 6
		if(501 to 2500)
			src.name = "thicc ass prison loaf"
			src.desc = "This loaf is caked UP"
			src.icon_state = "loaf1"
			src.force = 20
			src.throwforce = 20
			src.throw_range = 5
		if(2501 to 50000)
			src.name = "thicc ass prison loaf"
			src.desc = "This loaf is caked UP"
			src.icon_state = "loaf1"
			src.force = 40
			src.throwforce = 40
			src.throw_range = 4
		if(50001 to 250000)
			src.name = "thicc ass prison loaf"
			src.desc = "This loaf is caked UP"
			src.icon_state = "loaf1"
			src.force = 65
			src.throwforce = 65
			src.throw_range = 3
		if(250001 to 1000000)
			src.name = "thicc ass prison loaf"
			src.desc = "This loaf is caked UP"
			src.icon_state = "loaf1"
			src.force = 80
			src.throwforce = 80
			src.throw_range = 2
		if(250001 to 1000000)
			src.name = "thicc ass prison loaf"
			src.desc = "This loaf is caked UP"
			src.icon_state = "loaf1"
			src.force = 125
			src.throwforce = 125
			src.throw_range = 1
		if(250001 to 1000000)
			src.name = "quantum loaf"
			src.desc = "This loaf is caked UP"
			src.icon_state = "loaf1"
			src.force = 250
			src.throwforce = 250
			src.throw_range = 0


