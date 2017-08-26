//A clockwork device intended to hurt, cut, slice, burn, dissolve, maim, or otherwise hinder any progress past it.
/obj/structure/destructible/clockwork/trap
	name = "clockwork trap"
	icon_state = "gear_base"
	density = FALSE
	construction_value = 1
	obj_integrity = 75
	max_integrity = 75

/obj/structure/destructible/clockwork/trap/base
	name = "groundwork gear"
	desc = "A huge gear made of solid metal. It looks very hard to break."
	clockwork_desc = "The bedrock of any well-defended base. It can be converted into various types of traps.\n\
	<span class='neovgre_small'>Interact with it to turn it into a new type of trap!</span>"
	density = TRUE
	armor = list(melee = 75, bullet = 50, laser = 80, energy = 5, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 100)
	break_message = "<span class='warning'>Twisted and bent, the gear forces itself into its base metal!</span>"
	debris = list(/obj/item/clockwork/component/replicant_alloy = 1)

/obj/structure/destructible/clockwork/trap/base/examine(mob/user)
	if(prob(1))
		desc = replacetext(desc, "very", "wheely")
	..() //Base clockwork objects' examine will reset the description even if the easter egg gets through

/obj/structure/destructible/clockwork/trap/base/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='danger'>You feel <i>drawn</i> to [src] somehow, but you don't know how to act on it...</span>")
		return
	var/list/dat = list()
	dat += "<b>Choose how to mold this groundwork gear.</b><br>"
	dat += "<hr>"
	dat += "<a href='?src=\ref[src];id=test_trap'><b>Transgression Ward</b></a> - A translucent sigil that stuns and applies Belligerent to any \
	non-Servants that cross it. <i>Destroyed upon activation.</i><br>"
	var/datum/browser/popup = new(user, "gear", "", 400, 400)
	popup.set_content(dat.Join(""))
	popup.open()

/obj/structure/destructible/clockwork/trap/base/Topic(href, href_list)
	if(QDELETED(src) || !usr.canUseTopic(src) || !is_servant_of_ratvar(usr))
		return
	if(href_list["id"])
		var/obj/trap_type
		switch(href_list["id"])
			if("test_trap")
				trap_type = type
		if(!trap_type)
			return
		usr.visible_message("<span class='warning'>[usr] begins to gesture, and [src]'s form responds in turn!</span>", \
		"<span class='brass'>You begin commanding [src] into a few new form...</span>")
		if(!do_after(usr, 50, target = src))
			return
		usr.visible_message("<span class='warning'>[usr] molds [src] into a new form!</span>", "<span class='brass'>You mold [src] into a [initial(trap_type.name)].</span>")
		playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 50, TRUE)
		new trap_type(get_turf(src))
		qdel(src)
