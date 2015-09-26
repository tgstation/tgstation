#define CORRECT_STACK_NAME ((irregular_plural && amount > 1) ? irregular_plural : "[singular_name]\s")

/* Stack type objects!
 * Contains:
 * 		Stacks
 *		Recipe datum
 */

/*
 * Stacks
 */
/obj/item/stack
	gender = PLURAL
	origin_tech = "materials=1"
	var/list/datum/stack_recipe/recipes
	var/singular_name
	var/irregular_plural //"Teeth", for example. Without this, you'd see "There are 30 tooths in the stack."
	var/amount = 1
	var/perunit = 3750
	var/max_amount //also see stack recipes initialisation, param "max_res_amount" must be equal to this max_amount
	var/redeemed = 0 // For selling minerals to central command via supply shuttle.

/obj/item/stack/New(var/loc, var/amount=null)
	..()
	if (amount)
		src.amount=amount
	return

/obj/item/stack/Destroy()
	if (usr && usr.machine==src)
		usr << browse(null, "window=stack")
	src.loc = null
	..()

/obj/item/stack/examine(mob/user)
	..()
	var/be = "are"
	if(amount == 1) be = "is"

	user << "<span class='info'>There [be] [src.amount] [CORRECT_STACK_NAME] in the stack.</span>"

/obj/item/stack/attack_self(mob/user as mob)
	list_recipes(user)

/obj/item/stack/proc/list_recipes(mob/user as mob, recipes_sublist)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/stack/proc/list_recipes() called tick#: [world.time]")
	ASSERT(isnum(amount))
	if (!recipes)
		return
	if (!src || amount<=0)
		user << browse(null, "window=stack")
	user.set_machine(src) //for correct work of onclose
	var/list/recipe_list = recipes
	if (recipes_sublist && recipe_list[recipes_sublist] && istype(recipe_list[recipes_sublist], /datum/stack_recipe_list))
		var/datum/stack_recipe_list/srl = recipe_list[recipes_sublist]
		recipe_list = srl.recipes
	var/t1 = text("<HTML><HEAD><title>Constructions from []</title></HEAD><body><TT>Amount Left: []<br>", src, src.amount)
	for(var/i=1;i<=recipe_list.len,i++)
		var/E = recipe_list[i]
		if (isnull(E))
			t1 += "<hr>"
			continue

		if (i>1 && !isnull(recipe_list[i-1]))
			t1+="<br>"

		if (istype(E, /datum/stack_recipe_list))
			var/datum/stack_recipe_list/srl = E

			var/stack_name = (irregular_plural && srl.req_amount > 1) ? irregular_plural : "[singular_name]\s"
			if (src.amount >= srl.req_amount)
				t1 += "<a href='?src=\ref[src];sublist=[i]'>[srl.title] ([srl.req_amount] [stack_name])</a>"
			else
				t1 += "[srl.title] ([srl.req_amount] [stack_name]\s)<br>"

		if (istype(E, /datum/stack_recipe))
			var/datum/stack_recipe/R = E
			var/max_multiplier = round(src.amount / R.req_amount)
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
			//title+= " ([R.req_amount] [src.singular_name]\s)"
			title+= " ([R.req_amount] [CORRECT_STACK_NAME]"

			if (can_build)
				t1 += text("<A href='?src=\ref[src];sublist=[recipes_sublist];make=[i]'>[title]</A>)")
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

	if (href_list["sublist"] && !href_list["make"])
		list_recipes(usr, text2num(href_list["sublist"]))

	if (href_list["make"])
		if (src.amount < 1) returnToPool(src) //Never should happen
		var/list/recipes_list = recipes
		if (href_list["sublist"])
			var/datum/stack_recipe_list/srl = recipes_list[text2num(href_list["sublist"])]
			recipes_list = srl.recipes
		var/datum/stack_recipe/R = recipes_list[text2num(href_list["make"])]
		var/multiplier = text2num(href_list["multiplier"])
		if (!multiplier) multiplier = 1
		if (src.amount < R.req_amount*multiplier)
			if (R.req_amount*multiplier>1)
				usr << "<span class='warning'>You haven't got enough [src] to build \the [R.req_amount*multiplier] [R.title]\s!</span>"
			else
				usr << "<span class='warning'>You haven't got enough [src] to build \the [R.title]!</span>"
			return
		if (R.one_per_turf && (locate(R.result_type) in usr.loc))
			usr << "<span class='warning'>There is another [R.title] here!</span>"
			return
		if (R.on_floor && !istype(usr.loc, /turf/simulated/floor))
			usr << "<span class='warning'>\The [R.title] must be constructed on the floor!</span>"
			return
		if (R.time)
			usr << "<span class='notice'>Building [R.title] ...</span>"
			if (!do_after(usr, get_turf(src), R.time))
				return
		if (src.amount < R.req_amount*multiplier)
			return
		var/atom/O = new R.result_type( usr.loc )
		O.dir = usr.dir
		if(R.start_unanchored)
			var/obj/A = O
			A.anchored = 0
		if (R.max_res_amount>1)
			var/obj/item/stack/new_item = O
			new_item.amount = R.res_amount*multiplier
			//new_item.add_to_stacks(usr)
		src.use(R.req_amount*multiplier)
		if (src.amount<=0)
			var/oldsrc = src
			//src = null //dont kill proc after del()
			usr.before_take_item(oldsrc)
			returnToPool(oldsrc)
			if (istype(O,/obj/item))
				usr.put_in_hands(O)
		O.add_fingerprint(usr)
		//BubbleWrap - so newly formed boxes are empty
		if ( istype(O, /obj/item/weapon/storage) )
			for (var/obj/item/I in O)
				qdel(I)
		//BubbleWrap END
		if(istype(O, /obj/item/weapon/handcuffs/cable))
			var/obj/item/weapon/handcuffs/cable/C = O
			C._color = _color
			C.update_icon()
	if (src && usr.machine==src) //do not reopen closed window
		spawn( 0 )
			src.interact(usr)
			return
	return

/obj/item/stack/proc/use(var/amount)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/stack/proc/use() called tick#: [world.time]")
	ASSERT(isnum(src.amount))

	if(src.amount>=amount)
		src.amount-=amount
	else
		return 0
	. = 1
	if (src.amount<=0) //If the stack is empty after removing the required amount of items!
		if(usr)
			if(istype(usr,/mob/living/silicon/robot))
				var/mob/living/silicon/robot/R=usr
				if(R.module)
					R.module.modules -= src
				if(R.module_active == src) R.module_active = null
				if(R.module_state_1 == src)
					R.uneq_module(R.module_state_1)
					R.module_state_1 = null
					R.inv1.icon_state = "inv1"
				else if(R.module_state_2 == src)
					R.uneq_module(R.module_state_2)
					R.module_state_2 = null
					R.inv2.icon_state = "inv2"
				else if(R.module_state_3 == src)
					R.uneq_module(R.module_state_3)
					R.module_state_3 = null
					R.inv3.icon_state = "inv3"
			usr.before_take_item(src)
		spawn returnToPool(src)

/obj/item/stack/proc/add_to_stacks(mob/usr as mob)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/stack/proc/add_to_stacks() called tick#: [world.time]")
	for (var/obj/item/stack/item in usr.loc)
		if (src == item)
			continue
		if(!can_stack_with(item))
			continue
		if (item.amount>=item.max_amount)
			continue
		src.preattack(item, usr,1)
		break

/obj/item/stack/proc/can_stack_with(obj/item/other_stack)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/stack/proc/can_stack_with() called tick#: [world.time]")
	return src.type == other_stack.type

/obj/item/stack/attack_hand(mob/user as mob)
	if (user.get_inactive_hand() == src)
		var/obj/item/stack/F = new src.type( user, amount=1)
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

/obj/item/stack/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return 0

	if (can_stack_with(target))
		var/obj/item/stack/S = target
		if (amount >= max_amount)
			user << "\The [src] cannot hold anymore [CORRECT_STACK_NAME]."
			return 1
		var/to_transfer as num
		if (user.get_inactive_hand()==S)
			to_transfer = 1
		else
			to_transfer = min(S.amount, max_amount-amount)
		amount+=to_transfer
		user << "You add [to_transfer] [((to_transfer > 1) && S.irregular_plural) ? S.irregular_plural : "[S.singular_name]\s"] to \the [src]. It now contains [amount] [CORRECT_STACK_NAME]."
		if (S && user.machine==S)
			spawn(0) interact(user)
		S.use(to_transfer)
		if (src && user.machine==src)
			spawn(0) src.interact(user)
		update_icon()
		S.update_icon()
		return 1
	return ..()

/obj/item/stack/proc/copy_evidences(obj/item/stack/from as obj)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/stack/proc/copy_evidences() called tick#: [world.time]")
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
	var/start_unanchored = 0
	New(title, result_type, req_amount = 1, res_amount = 1, max_res_amount = 1, time = 0, one_per_turf = 0, on_floor = 0, start_unanchored = 0)
		src.title = title
		src.result_type = result_type
		src.req_amount = req_amount
		src.res_amount = res_amount
		src.max_res_amount = max_res_amount
		src.time = time
		src.one_per_turf = one_per_turf
		src.on_floor = on_floor
		src.start_unanchored = start_unanchored

/*
 * Recipe list datum
 */
/datum/stack_recipe_list
	var/title = "ERROR"
	var/list/recipes = null
	var/req_amount = 1
	New(title, recipes, req_amount = 1)
		src.title = title
		src.recipes = recipes
		src.req_amount = req_amount

/obj/item/stack/verb_pickup(mob/living/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/obj/item/stack/verb_pickup()  called tick#: [world.time]")
	var/obj/item/I = user.get_active_hand()
	if(I && can_stack_with(I))
		I.preattack(src, user, 1)
		return
	return ..()

#undef CORRECT_STACK_NAME
