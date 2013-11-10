/*	Photocopiers!
 *	Contains:
 *		Photocopier
 *		Toner Cartridge
 */

/*
 * Photocopier
 */
/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	var/obj/item/weapon/paper/copy = null	//what's in the copier!
	var/obj/item/weapon/photo/photocopy = null
	var/copies = 1	//how many copies to print!
	var/toner = 40 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/greytoggle = "Greyscale"
	var/mob/living/ass = null


/obj/machinery/photocopier/attack_ai(mob/user)
	return attack_hand(user)


/obj/machinery/photocopier/attack_paw(mob/user)
	return attack_hand(user)


/obj/machinery/photocopier/attack_hand(mob/user)
	user.set_machine(src)

	var/dat = "Photocopier<BR><BR>"
	if(copy || photocopy || (ass && (ass.loc == src.loc)))
		dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=\ref[src];min=1'>-</a> "
			dat += "<a href='byond://?src=\ref[src];add=1'>+</a><BR><BR>"
			if(photocopy)
				dat += "Printing in <a href='byond://?src=\ref[src];colortoggle=1'>[greytoggle]</a><BR><BR>"
	else if(toner)
		dat += "Please insert paper to copy.<BR><BR>"
	if(istype(user,/mob/living/silicon/ai))
		dat += "<a href='byond://?src=\ref[src];aipic=1'>Print photo from database</a><BR><BR>"
	dat += "Current toner level: [toner]"
	if(!toner)
		dat +="<BR>Please insert a new toner cartridge!"
	user << browse(dat, "window=copier")
	onclose(user, "copier")

/obj/machinery/photocopier/Topic(href, href_list)
	if(..())
		return
	if(href_list["copy"])
		if(copy)
			for(var/i = 0, i < copies, i++)
				if(toner > 0)
					var/obj/item/weapon/paper/c = new /obj/item/weapon/paper (loc)
					if(toner > 10)	//lots of toner, make it dark
						c.info = "<font color = #101010>"
					else			//no toner? shitty copies for you!
						c.info = "<font color = #808080>"
					var/copied = html_decode(copy.info)
					copied = replacetext(copied, "<font face=\"[c.deffont]\" color=", "<font face=\"[c.deffont]\" nocolor=")	//state of the art techniques in action
					copied = replacetext(copied, "<font face=\"[c.crayonfont]\" color=", "<font face=\"[c.crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
					c.info += copied
					c.info += "</font>"
					c.name = copy.name
					c.fields = copy.fields
					c.updateinfolinks()
					toner--
					sleep(15)
				else
					break
			updateUsrDialog()
		else if(photocopy)
			for(var/i = 0, i < copies, i++)
				if(toner >= 5)  //Was set to = 0, but if there was say 3 toner left and this ran, you would get -2 which would be weird for ink
					var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
					var/icon/I = icon(photocopy.icon, photocopy.icon_state)
					var/icon/img = icon(photocopy.img)
					if(greytoggle == "Greyscale")
						if(toner > 10) //plenty of toner, go straight greyscale
							I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0)) //I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
							img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
						else //not much toner left, lighten the photo
							I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
							img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
						toner -= 5	//photos use a lot of ink!
					else if(greytoggle == "Color")
						if(toner >= 10)
							toner -= 10 //Color photos use even more ink!
						else
							continue
					p.icon = I
					p.img = img
					p.name = photocopy.name
					p.desc = photocopy.desc
					p.scribble = photocopy.scribble
					p.pixel_x = rand(-10, 10)
					p.pixel_y = rand(-10, 10)
					p.blueprints = photocopy.blueprints //a copy of a picture is still good enough for the syndicate

					sleep(15)
				else
					break
		else if(ass) //ASS COPY. By Miauw
			for(var/i = 0, i < copies, i++)
				var/icon/temp_img
				if(ishuman(ass) && (ass.get_item_by_slot(slot_w_uniform) || ass.get_item_by_slot(slot_wear_suit)))
					usr << "<span class='notice'>You feel kind of silly copying [ass == usr ? "your" : ass][ass == usr ? "" : "\'s"] ass with [ass == usr ? "your" : "their"] clothes on.</span>"
				else if(toner >= 5 && check_ass()) //You have to be sitting on the copier and either be a xeno or a human without clothes on.
					if(isalien(ass) || istype(ass,/mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
						temp_img = icon("icons/ass/assalien.png")
					else if(ishuman(ass)) //Suit checks are in check_ass
						if(ass.gender == MALE)
							temp_img = icon("icons/ass/assmale.png")
						else if(ass.gender == FEMALE)
							temp_img = icon("icons/ass/assfemale.png")
						else 									//In case anyone ever makes the generic ass. For now I'll be using male asses.
							temp_img = icon("icons/ass/assmale.png")
					else
						break
					var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
					p.desc = "You see [ass]'s ass on the photo."
					p.pixel_x = rand(-10, 10)
					p.pixel_y = rand(-10, 10)
					p.img = temp_img
					var/icon/small_img = icon(temp_img) //Icon() is needed or else temp_img will be rescaled too >.>
					var/icon/ic = icon('icons/obj/items.dmi',"photo")
					small_img.Scale(8, 8)
					ic.Blend(small_img,ICON_OVERLAY, 10, 13)
					p.icon = ic
					toner -= 5
					sleep(15)
				else
					break
		updateUsrDialog()
	else if(href_list["remove"])
		if(copy)
			if(!istype(usr,/mob/living/silicon/ai)) //surprised this check didn't exist before, putting stuff in AI's hand is bad
				copy.loc = usr.loc
				usr.put_in_hands(copy)
			else
				copy.loc = src.loc
			usr << "<span class='notice'>You take [copy] out of [src].</span>"
			copy = null
			updateUsrDialog()
		else if(photocopy)
			if(!istype(usr,/mob/living/silicon/ai)) //same with this one, wtf
				photocopy.loc = usr.loc
				usr.put_in_hands(photocopy)
			else
				photocopy.loc = src.loc
			usr << "<span class='notice'>You take [photocopy] out of [src].</span>"
			photocopy = null
			updateUsrDialog()
		else if(check_ass())
			ass << "<span class='notice'>You feel a slight pressure on your ass.</span>"
	else if(href_list["min"])
		if(copies > 1)
			copies--
			updateUsrDialog()
	else if(href_list["add"])
		if(copies < maxcopies)
			copies++
			updateUsrDialog()
	else if(href_list["aipic"])
		if(!istype(usr,/mob/living/silicon/ai)) return
		if(toner >= 5)
			var/list/nametemp = list()
			var/find
			var/datum/picture/selection
			var/mob/living/silicon/ai/tempAI = usr
			if(tempAI.aicamera.aipictures.len == 0)
				usr << "<FONT COLOR=red><B>No images saved<B>"
				return
			for(var/datum/picture/t in tempAI.aicamera.aipictures)
				nametemp += t.fields["name"]
			find = input("Select image (numbered in order taken)") in nametemp
			var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
			for(var/datum/picture/q in tempAI.aicamera.aipictures)
				if(q.fields["name"] == find)
					selection = q
					break
			var/icon/I = selection.fields["icon"]
			var/icon/img = selection.fields["img"]
			p.icon = I
			p.img = img
			p.desc = selection.fields["desc"]
			p.blueprints = selection.fields["blueprints"]
			p.pixel_x = rand(-10, 10)
			p.pixel_y = rand(-10, 10)
			toner -= 5	 //AI prints color pictures only, thus they can do it more efficiently
			sleep(15)
		updateUsrDialog()
	else if(href_list["colortoggle"])
		if(greytoggle == "Greyscale")
			greytoggle = "Color"
		else
			greytoggle = "Greyscale"
		updateUsrDialog()

/obj/machinery/photocopier/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/paper))
		if(copier_empty())
			user.drop_item()
			copy = O
			O.loc = src
			user << "<span class='notice'>You insert [O] into [src].</span>"
			flick("bigscanner1", src)
			updateUsrDialog()
		else
			user << "<span class='notice'>There is already something in [src].</span>"
	else if(istype(O, /obj/item/weapon/photo))
		if(copier_empty())
			user.drop_item()
			photocopy = O
			O.loc = src
			user << "<span class='notice'>You insert [O] into [src].</span>"
			flick("bigscanner1", src)
			updateUsrDialog()
		else
			user << "<span class='notice'>There is already something in [src].</span>"
	else if(istype(O, /obj/item/device/toner))
		if(toner <= 0)
			user.drop_item()
			del(O)
			toner = 40
			user << "<span class='notice'>You insert [O] into [src].</span>"
			updateUsrDialog()
		else
			user << "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>"
	else if(istype(O, /obj/item/weapon/wrench))
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		anchored = !anchored
		user << "<span class='notice'>You [anchored ? "wrench" : "unwrench"] [src].</span>"
	else if(istype(O, /obj/item/weapon/grab)) //For ass-copying.
		var/obj/item/weapon/grab/G = O
		if(ismob(G.affecting) && G.affecting != ass)
			var/mob/GM = G.affecting
			visible_message("<span class='warning'>[usr] drags [GM.name] onto the photocopier!</span>")
			GM.loc = get_turf(src)
			ass = GM
			if(photocopy)
				photocopy.loc = src.loc
				photocopy = null
			else if(copy)
				copy.loc = src.loc
				copy = null
			updateUsrDialog()

/obj/machinery/photocopier/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if(prob(50))
				del(src)
			else
				if(toner > 0)
					new /obj/effect/decal/cleanable/oil(get_turf(src))
					toner = 0
		else
			if(prob(50))
				if(toner > 0)
					new /obj/effect/decal/cleanable/oil(get_turf(src))
					toner = 0


/obj/machinery/photocopier/blob_act()
	if(prob(50))
		del(src)
	else
		if(toner > 0)
			new /obj/effect/decal/cleanable/oil(get_turf(src))
			toner = 0

/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/user)
	check_ass() //Just to make sure that you can re-drag somebody onto it after they moved off.
	if (!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai) || target == ass)
		return
	src.add_fingerprint(user)
	if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		visible_message("<span class='warning'>[usr] jumps onto the photocopier!</span>")
	else if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		if(target.anchored) return
		if(!ishuman(user) && !ismonkey(user)) return
		visible_message("<span class='warning'>[usr] drags [target.name] onto the photocopier!</span>")
	target.loc = get_turf(src)
	ass = target
	if(photocopy)
		photocopy.loc = src.loc
		visible_message("<span class='notice'>[photocopy] is shoved out of the way by [ass]!</span>")
		photocopy = null
	else if(copy)
		copy.loc = src.loc
		visible_message("<span class='notice'>[copy] is shoved out of the way by [ass]!</span>")
		copy = null
	updateUsrDialog()

/obj/machinery/photocopier/proc/check_ass() //I'm not sure wether I made this proc because it's good form or because of the name.
	if(!ass)
		return 0
	if(ass.loc != src.loc)
		ass = null
		updateUsrDialog()
		return 0
	else if(istype(ass,/mob/living/carbon/human))
		if(!ass.get_item_by_slot(slot_w_uniform) && !ass.get_item_by_slot(slot_wear_suit))
			return 1
		else
			return 0
	else
		return 1

/obj/machinery/photocopier/proc/copier_empty()
	if(copy || photocopy || check_ass())
		return 0
	else
		return 1

/*
 * Toner cartridge
 */
/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
	var/charges = 5
	var/max_charges = 5
