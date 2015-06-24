/* Stack type objects!
 * Contains:
 * 		Stacks
 *		Recipe datum
 */

/*
 * Stacks
 */
/obj/item/stack
	origin_tech = "materials=1"
	gender = PLURAL
	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/amount = 1
	var/max_amount //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/is_cyborg = 0 // It's 1 if module is used by a cyborg, and uses its storage
	var/datum/robot_energy_storage/source
	var/cost = 1 // How much energy from storage it costs

/obj/item/stack/New(var/loc, var/amount=null)
	..()
	if (amount)
		src.amount = amount
	return

/obj/item/stack/Destroy()
	if (usr && usr.machine==src)
		usr << browse(null, "window=stack")
	src.loc = null
	..()

/obj/item/stack/examine(mob/user)
	..()
	if (is_cyborg)
		if(src.singular_name)
			user << "There is enough energy for [src.get_amount()] [src.singular_name]\s."
		else
			user << "There is enough energy for [src.get_amount()]."
		return
	if(src.singular_name)
		if(src.get_amount()>1)
			user << "There are [src.get_amount()] [src.singular_name]\s in the stack."
		else
			user << "There is [src.get_amount()] [src.singular_name] in the stack."
	else if(src.get_amount()>1)
		user << "There are [src.get_amount()] in the stack."
	else
		user << "There is [src.get_amount()] in the stack."

/obj/item/stack/proc/get_amount()
	if (is_cyborg)
		return round(source.energy / cost)
	else
		return (amount)

/obj/item/stack/attack_self(mob/user as mob)
	interact(user)

/obj/item/stack/interact(mob/user as mob)
	if (!recipes)
		return
	if (!src || get_amount() <= 0)
		user << browse(null, "window=stack")
	user.set_machine(src) //for correct work of onclose
	var/t1 = text("<HTML><HEAD><title>Constructions from []</title></HEAD><body><TT>Amount Left: []<br>", src, src.get_amount())
	for(var/i=1;i<=recipes.len,i++)
		var/datum/stack_recipe/R = recipes[i]
		if (isnull(R))
			t1 += "<hr>"
			continue
		if (i>1 && !isnull(recipes[i-1]))
			t1+="<br>"
		var/max_multiplier = round(src.get_amount() / R.req_amount)
		var/title as text
		var/can_build = 1
		can_build = can_build && (max_multiplier>0)
		/*
		if (R.one_per_turf)
			can_build = can_build && !(locate(R.result_type) in usr.loc)
		if (R.on_floor)
			can_build = can_build && istype(usr.loc, /turf/simulated/floor)
		*/
		if (R.res_amount>1)
			title+= "[R.res_amount]x [R.title]\s"
		else
			title+= "[R.title]"
		title+= " ([R.req_amount] [src.singular_name]\s)"
		if (can_build)
			t1 += text("<A href='?src=\ref[];make=[];multiplier=1'>[]</A>  ", src, i, title)
		else
			t1 += text("[]", title)
			continue
		if (R.max_res_amount>1 && max_multiplier>1)
			max_multiplier = min(max_multiplier, round(R.max_res_amount/R.res_amount))
			t1 += " |"
			var/list/multipliers = list(5,10,25)
			for (var/n in multipliers)
				if (max_multiplier>=n)
					t1 += " <A href='?src=\ref[src];make=[i];multiplier=[n]'>[n*R.res_amount]x</A>"
			if (!(max_multiplier in multipliers))
				t1 += " <A href='?src=\ref[src];make=[i];multiplier=[max_multiplier]'>[max_multiplier*R.res_amount]x</A>"

	t1 += "</TT></body></HTML>"
	user << browse(t1, "window=stack")
	onclose(user, "stack")
	return

/obj/item/stack/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.get_active_hand() != src))
		return
	if (href_list["make"])
		if (src.get_amount() < 1) qdel(src) //Never should happen

		var/datum/stack_recipe/R = recipes[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if (!multiplier ||(multiplier <= 0)) //href protection
			return
		if(!building_checks(R, multiplier))
			return
		if (R.time)
			usr.visible_message("<span class='notice'>[usr] starts building [R.title].</span>", "<span class='notice'>You start building [R.title]...</span>")
			if (!do_after(usr, R.time, target = usr))
				return
			if(!building_checks(R, multiplier))
				return

		var/atom/O = new R.result_type( usr.loc )
		O.dir = usr.dir
		use(R.req_amount * multiplier)

		//is it a stack ?
		if (R.max_res_amount > 1)
			var/obj/item/stack/new_item = O
			new_item.amount = R.res_amount*multiplier
			new_item.add_to_stacks(usr) //try to merge with existing stacks on current tile

			if(new_item.amount <= 0)//if the stack is empty, i.e it has been merged with an existing stack and has been garbage collected
				return

		if (istype(O,/obj/item))
			usr.put_in_hands(O)
		O.add_fingerprint(usr)

		//BubbleWrap - so newly formed boxes are empty
		if ( istype(O, /obj/item/weapon/storage) )
			for (var/obj/item/I in O)
				qdel(I)
		//BubbleWrap END

	if (src && usr.machine==src) //do not reopen closed window
		spawn( 0 )
			src.interact(usr)
			return
	return

/obj/item/stack/proc/building_checks(datum/stack_recipe/R, multiplier)
	if (src.get_amount() < R.req_amount*multiplier)
		if (R.req_amount*multiplier>1)
			usr << "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!</span>"
		else
			usr << "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>"
		return 0
	if (R.one_per_turf && (locate(R.result_type) in usr.loc))
		usr << "<span class='warning'>There is another [R.title] here!</span>"
		return 0
	if (R.on_floor && !istype(usr.loc, /turf/simulated/floor))
		usr << "<span class='warning'>\The [R.title] must be constructed on the floor!</span>"
		return 0
	return 1

/obj/item/stack/proc/use(var/used) // return 0 = borked; return 1 = had enough
	if(zero_amount())
		return 0
	if (is_cyborg)
		return source.use_charge(used * cost)
	if (amount < used)
		return 0
	amount -= used
	zero_amount()
	update_icon()
	return 1

/obj/item/stack/proc/zero_amount()
	if(is_cyborg)
		return source.energy < cost
	if (amount < 1)
		if(usr)
			usr.unEquip(src, 1)
		qdel(src)
		return 1
	return 0

/obj/item/stack/proc/add(var/amount)
	if (is_cyborg)
		source.add_charge(amount * cost)
	else
		src.amount += amount
	update_icon()

/obj/item/stack/proc/add_to_stacks(mob/usr as mob)
	var/obj/item/stack/oldsrc = src
	src = null
	for (var/obj/item/stack/item in usr.loc)
		if (item==oldsrc)
			continue
		if (!istype(item, oldsrc.type))
			continue
		if (item.amount>=item.max_amount)
			continue
		oldsrc.attackby(item, usr)
		usr << "<span class='notice'>You add new [item.singular_name] to the stack. It now contains [item.amount] [item.singular_name]\s.</span>"
		if(oldsrc.amount <= 0)
			break
	oldsrc.update_icon()

/obj/item/stack/attack_hand(mob/user as mob)
	if (user.get_inactive_hand() == src)
		if(zero_amount())	return
		var/obj/item/stack/F = new src.type( user, 1)
		F.copy_evidences(src)
		user.put_in_hands(F)
		src.add_fingerprint(user)
		F.add_fingerprint(user)
		use(1)
		if (src && usr.machine==src)
			spawn(0) src.interact(usr)
	else
		..()
	return

/obj/item/stack/attackby(obj/item/W as obj, mob/user as mob, params)

	if (istype(W, src.type))
		if(zero_amount())	return
		var/obj/item/stack/S = W
		if (S.is_cyborg)
			var/to_transfer = min(src.amount, round((S.source.max_energy - S.source.energy) / S.cost))
			S.add(to_transfer)
			if (S && usr.machine==S)
				spawn(0) S.interact(usr)
			src.use(to_transfer)
			if (src && usr.machine==src)
				spawn(0) src.interact(usr)
		else
			if (S.amount >= max_amount)
				return
			var/to_transfer as num
			if (user.get_inactive_hand()==src)
				to_transfer = 1
			else
				to_transfer = min(src.amount, S.max_amount-S.amount)
			S.amount+=to_transfer
			if (S && usr.machine==S)
				spawn(0) S.interact(usr)
			src.use(to_transfer)
			if (src && usr.machine==src)
				spawn(0) src.interact(usr)
			S.update_icon()

	else
		..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from as obj)
	src.blood_DNA = from.blood_DNA
	src.fingerprints  = from.fingerprints
	src.fingerprintshidden  = from.fingerprintshidden
	src.fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/*
 * Recipe datum
 */
/datum/stack_recipe
	var/title = "ERROR"
	var/result_type
	var/req_amount = 1
	var/res_amount = 1
	var/max_res_amount = 1
	var/time = 0
	var/one_per_turf = 0
	var/on_floor = 0
	New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0)
		src.title = title
		src.result_type = result_type
		src.req_amount = req_amount
		src.res_amount = res_amount
		src.max_res_amount = max_res_amount
		src.time = time
		src.one_per_turf = one_per_turf
		src.on_floor = on_floor