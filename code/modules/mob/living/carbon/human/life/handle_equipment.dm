//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_equipment()
	if(head)
		if(istype(head, /obj/item/weapon/reagent_containers/glass/bucket))
			var/obj/item/weapon/reagent_containers/glass/bucket/B = head
			if(B.reagents.total_volume)
				for(var/atom/movable/O in loc)
					B.reagents.reaction(O, TOUCH)
				B.reagents.reaction(loc, TOUCH)
				visible_message("<span class='warning'>The bucket's content spills on [src]</span>")
				spawn(5)
					B.reagents.clear_reagents()
