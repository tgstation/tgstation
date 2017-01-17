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
	var/max_amount = 50 //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/is_cyborg = 0 // It's 1 if module is used by a cyborg, and uses its storage
	var/datum/robot_energy_storage/source
	var/cost = 1 // How much energy from storage it costs
	var/merge_type = null // This path and its children should merge with this stack, defaults to src.type

/obj/item/stack/New(var/loc, var/amount=null)
	..()
	if (amount)
		src.amount = amount
	if(!merge_type)
		merge_type = src.type
	return

/obj/item/stack/Destroy()
	if (usr && usr.machine==src)
		usr << browse(null, "window=stack")
	return ..()

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

/obj/item/stack/attack_self(mob/user)
	interact(user)

/obj/item/stack/interact(mob/user)
	if (!recipes)
		return
	if (!src || get_amount() <= 0)
		user << browse(null, "window=stack")
		return
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
	if (usr.restrained() || usr.stat || usr.get_active_held_item() != src)
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
		O.setDir(usr.dir)
		use(R.req_amount * multiplier)

		//is it a stack ?
		if (R.max_res_amount > 1)
			var/obj/item/stack/new_item = O
			new_item.amount = R.res_amount*multiplier
			new_item.update_icon()

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
	if(R.on_floor && !isfloorturf(usr.loc))
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
	if(amount < 1)
		qdel(src)
		return 1
	return 0

/obj/item/stack/proc/add(amount)
	if (is_cyborg)
		source.add_charge(amount * cost)
	else
		src.amount += amount
	update_icon()

/obj/item/stack/proc/merge(obj/item/stack/S) //Merge src into S, as much as possible
	if(S == src) //amusingly this can cause a stack to consume itself, let's not allow that.
		return
	var/transfer = get_amount()
	if(S.is_cyborg)
		transfer = min(transfer, round((S.source.max_energy - S.source.energy) / S.cost))
	else
		transfer = min(transfer, S.max_amount - S.amount)
	if(pulledby)
		pulledby.start_pulling(S)
	S.copy_evidences(src)
	use(transfer)
	S.add(transfer)

/obj/item/stack/Crossed(obj/o)
	if(istype(o, merge_type) && !o.throwing)
		merge(o)
	return ..()

/obj/item/stack/hitby(atom/movable/AM, skip, hitpush)
	if(istype(AM, merge_type))
		merge(AM)
	return ..()

/obj/item/stack/attack_hand(mob/user)
	if (user.get_inactive_held_item() == src)
		if(zero_amount())
			return
		change_stack(user,1)
	else
		..()
	return

/obj/item/stack/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src))
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		if(zero_amount())
			return
		//get amount from user
		var/min = 0
		var/max = src.get_amount()
		var/stackmaterial = input(user,"How many sheets do you wish to take out of this stack? (Maximum  [max]") as num
		if(stackmaterial == null || stackmaterial <= min || stackmaterial >= src.get_amount())
			return
		else
			change_stack(user,stackmaterial)
			user << "<span class='notice'>You take [stackmaterial] sheets out of the stack</span>"

/obj/item/stack/proc/change_stack(mob/user,amount)
	var/obj/item/stack/F = new src.type(user, amount)
	. = F
	F.copy_evidences(src)
	user.put_in_hands(F)
	add_fingerprint(user)
	F.add_fingerprint(user)
	use(amount)



/obj/item/stack/attackby(obj/item/W, mob/user, params)
	if(istype(W, merge_type))
		var/obj/item/stack/S = W
		merge(S)
		user << "<span class='notice'>Your [S.name] stack now contains [S.get_amount()] [S.singular_name]\s.</span>"
	else
		return ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from as obj)
	src.blood_DNA = from.blood_DNA
	src.fingerprints  = from.fingerprints
	src.fingerprintshidden  = from.fingerprintshidden
	src.fingerprintslast  = from.fingerprintslast
	//TODO bloody overlay

/obj/item/stack/microwave_act(obj/machinery/microwave/M)
	if(M && M.dirty < 100)
		M.dirty += amount
		
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

/datum/stack_recipe/New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0)
	src.title = title
	src.result_type = result_type
	src.req_amount = req_amount
	src.res_amount = res_amount
	src.max_res_amount = max_res_amount
	src.time = time
	src.one_per_turf = one_per_turf
	src.on_floor = on_floor
