/obj/item/food/prison_loaf
	name = "prison loaf"
	desc = "A barely edible brick of nutrients, designed as a low-cost solution to malnourishment."
	icon = 'monkestation/code/modules/loafing/icon/obj.dmi'
	icon_state = "loaf0"
	var/loaf_density = 0


/obj/item/food/prison_loaf/proc/condense()
	switch(src.loaf_density)

		if(0 to 100)
			src.name = "prison loaf"
			src.desc = "A barely edible brick of nutrients, designed as a low-cost solution to malnourishment."
			src.icon_state = "loaf0"
			src.force = 0
			src.throwforce = 0
		if(101 to 250)
			src.name = "dense prison loaf"
			src.desc = "This loaf is noticeably heavier than usual."
			src.icon_state = "loaf0"
			src.force = 3
			src.throwforce = 3

