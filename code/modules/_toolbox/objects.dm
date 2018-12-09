/obj/effect/turf_decal/plaque/toolbox
	name = "plaque"
	icon = 'icons/oldschool/ss13sign1rowdecals.dmi'
	var/ismain = 0
/obj/effect/turf_decal/plaque/toolbox/New()
	. = ..()
	if(ismain)
		if(!isturf(loc))
			qdel(src)
			return
		var/startx = x-3
		for(var/i=1,i<=7,i++)
			var/turf/T = locate(startx,y,z)
			if(istype(T))
				var/obj/effect/turf_decal/plaque/toolbox/P = new(T)
				if(T == loc)
					P = src
				else
					P = new(T)
				P.icon_state = "S[i]"
			startx++
		ismain = 0

//rapid parts exchanger can now replace apc cells
/obj/machinery/power/apc/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	if(!istype(W) || !cell)
		return FALSE
	if(!W.works_from_distance && ((!usr.Adjacent(src)) || (cant_parts_exchange())))
		return FALSE
	for(var/obj/item/stock_parts/cell/C in W.contents)
		if(C.maxcharge > cell.maxcharge)
			var/atom/movable/oldcell = cell
			if(W.remove_from_storage(C))
				C.doMove(oldcell.loc)
				if(W.handle_item_insertion(oldcell, 1))
					cell = C
					W.notify_user_of_success(user,C,oldcell)
					W.play_rped_sound()
					return TRUE
	return ..()

/obj/machinery/power/apc/cant_parts_exchange()
	if(!panel_open)
		return 1

/obj/machinery/proc/cant_parts_exchange()
	if(flags_1 & NODECONSTRUCT_1)
		return 1


/obj/item/storage/part_replacer/proc/notify_user_of_success(mob/user,atom/newitem,atom/olditem)
	if(!user || !newitem || !olditem)
		return
	to_chat(user, "<span class='notice'>[olditem.name] replaced with [newitem.name].</span>")

//Cells construct with fullhealth
/obj/machinery/rnd/production/proc/Make_Cells_Fucking_Full_Charge_Because_Thats_So_Gay(obj/item/stock_parts/cell/C)
	if(istype(C))
		C.charge = C.maxcharge
		C.update_icon()

//reinforced delivery window. allows items to be placed on tables underneath it
/obj/structure/window/reinforced/fulltile/delivery
	name = "reinforced delivery window"
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "delivery_window"
	flags_1 = 0
	smooth = SMOOTH_FALSE
	canSmoothWith = list()
	glass_amount = 5
	CanAtmosPass = ATMOS_PASS_YES

/obj/structure/window/reinforced/fulltile/delivery/unanchored
	anchored = FALSE

//***************************
//plant disk organizing shelf
//***************************

#define EMPTYDISKNAME "Blank Disks"
/obj/structure/plant_disk_shelf
	name = "Plant Data Disk Storage Shelf"
	desc = "Where we store our plant genes."
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "plant_disk_shelf"
	anchored = 1
	density = 0
	pixel_y = 32
	var/max_disks = 26
	var/list/plant_disks = list()

/obj/structure/plant_disk_shelf/attack_hand(mob/living/user)
	user.set_machine(src)
	var/datum/browser/popup = new(user, "plantdiskstorage", "[name]", 450, 600)
	var/dat = "<B>Stored Plant Data Disks</B><BR><BR>"
	if(!plant_disks.len)
		dat += "Empty"
	else
		for(var/disk in plant_disks)
			if(istype(plant_disks[disk],/list))
				var/list/this_list = plant_disks[disk]
				if(this_list.len)
					dat += "[disk] ([this_list.len]) <A href='?src=\ref[src];disk=[disk]'>Remove</A><br>"
	popup.set_content(dat)
	popup.open()

/obj/structure/plant_disk_shelf/proc/remove_disk(disk)
	if(!disk)
		return
	var/diskname = disk
	if(istype(diskname,/obj/item/disk/plantgene))
		var/obj/item/disk/plantgene/P = disk
		if(P.gene)
			diskname = P.gene.get_name()
		else
			diskname = EMPTYDISKNAME
	if(diskname in plant_disks)
		var/list/this_list = plant_disks[diskname]
		if(istype(this_list,/list) && this_list.len)
			var/obj/item/disk/thedisk = pick(this_list)
			if(istype(thedisk))
				this_list -= thedisk
				if(!this_list.len)
					plant_disks.Remove(diskname)
				else
					plant_disks[diskname] = this_list
				thedisk.forceMove(loc)
				thedisk.pixel_x = rand(-4,4)
				thedisk.pixel_y = rand(-4,4)
				update_icon()
				return thedisk
	return null

/obj/structure/plant_disk_shelf/proc/add_disk(obj/item/disk/plantgene/disk)
	if(!istype(disk) || get_disk_count() >= max_disks)
		return 0
	disk.forceMove(src)
	if(disk.loc != src)
		return 0
	if(disk.gene)
		var/gene_name = disk.gene.get_name()
		if(gene_name in plant_disks && istype(plant_disks[gene_name],/list))
			var/list/this_list = plant_disks[gene_name]
			this_list += disk
			plant_disks[gene_name] = this_list
		else
			plant_disks[gene_name] = list(disk)
	else
		if((EMPTYDISKNAME in plant_disks) && istype(plant_disks[EMPTYDISKNAME],/list))
			var/list/this_list = plant_disks[EMPTYDISKNAME]
			this_list += disk
			plant_disks[EMPTYDISKNAME] = this_list
		else
			plant_disks[EMPTYDISKNAME] = list(disk)
	update_icon()
	return 1

/obj/structure/plant_disk_shelf/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)
	if(href_list["disk"])
		var/obj/item/disk/plantgene/disk = remove_disk(href_list["disk"])
		if(istype(disk) && ishuman(usr))
			usr.put_in_hands(disk)
		return attack_hand(usr)

/obj/structure/plant_disk_shelf/attackby(obj/item/W, mob/living/user, params)
	if(istype(W,/obj/item/disk/plantgene))
		if(get_disk_count() < max_disks)
			if(user.dropItemToGround(W))
				add_disk(W)
				if(user.machine == src)
					attack_hand(user)
		else
			to_chat(user, "<div class='warning'>You cannot put any more disks in the [src].</div>")
	else
		return ..()

/obj/structure/plant_disk_shelf/proc/get_disk_count()
	. = 0
	for(var/obj/item/disk/plantgene/P in src)
		.++
	return .

/obj/structure/plant_disk_shelf/update_icon()
	overlays.Cut()
	if(plant_disks && plant_disks.len)
		var/diskcount = get_disk_count()
		var/shelfcap = round(max_disks/2,1)
		var/pixelx = 0
		var/pixely = 0
		for(var/i=1,i<=diskcount,i++)
			if(i>(shelfcap*2))
				break
			var/image/I = new()
			I.icon = icon
			I.icon_state = "[icon_state]_disk"
			I.pixel_x = pixelx
			I.pixel_y = pixely
			pixelx = pixelx+2
			if(!pixely && i >= 13)
				pixelx = 0
				pixely = -10
			overlays += I

/obj/structure/plant_disk_shelf/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(istype(AM,/obj/item/disk))
			AM.pixel_x = rand(-4,4)
			AM.pixel_y = rand(-4,4)
	plant_disks = list()
	return ..()
#undef EMPTYDISKNAME

//animal cookies
/obj/item/reagent_containers/food/snacks/cracker
	var/copied = 0

/obj/item/reagent_containers/food/snacks/cracker/New()
	var/list/available = list()
	for(var/mob/living/M in range(3,get_turf(src)))
		if(istype(M,/mob/living/carbon/monkey) || (istype(M,/mob/living/simple_animal) && !istype(M,/mob/living/simple_animal/hostile) && !istype(M,/mob/living/simple_animal/bot) && !istype(M,/mob/living/simple_animal/slime)))
			available += M
	var/choice
	if(available.len)
		choice = pick(available)
	if(choice)
		copy_animal(choice)
	. = ..()

/obj/item/reagent_containers/food/snacks/cracker/proc/copy_animal(atom/A)
	if(!A)
		return
	overlays.Cut()
	var/matrix/M = new()
	transform = M
	name = "animal cracker"
	desc = "Its a [A.name]!"
	var/icon/mask = icon(A.icon,initial(A.icon_state),dir = 4)
	mask.Blend(rgb(255,255,255))
	mask.BecomeAlphaMask()
	var/icon/cracker = new/icon('icons/oldschool/objects.dmi', "crackertexture")
	cracker.AddAlphaMask(mask)
	var/image/overlay = image(cracker)
	overlays += overlay
	/*var/image/shades = new()
	shades.icon = A.icon
	shades.icon_state = A.icon_state
	shades.overlays += A.overlays
	shades.color = list(0.30,0.30,0.30,0, 0.60,0.60,0.60,0, 0.10,0.10,0.10,0, 0,0,0,1, 0,0,0,0)
	shades.alpha = round(255*0.5,1)
	overlays += shades*/
	M *= 0.6
	transform = M