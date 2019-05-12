GLOBAL_LIST_EMPTY(toolbox_statues)

/*
	The Statue
*/
/obj/structure/statue/toolbox/guaranteed
	prob_success = 100

/obj/structure/statue/toolbox
	name = "statue of a pure maiden"
	desc = "An ancient marble statue. The subject is depicted with a floor-length braid and is wielding a toolbox. By Jove, it's easily the most gorgeous depiction of a woman you've ever seen. The artist must truly be a master of his craft. Shame about the broken arm, though."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	anchored = TRUE
	CanAtmosPass = ATMOS_PASS_DENSITY
	resistance_flags = (LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF)
	max_integrity = 1000
	obj_integrity = 1000
	var/toolbox_pulled = 0
	var/mob/living/carbon/human/Holder = null
	var/obj/item/storage/toolbox/true/true_box
	var/list/failed_ckeys = list()
	var/sacrifices = 0
	var/toolbox_points = 0
	var/prob_success = 2
	var/chance_increase = 2 //how much prob_success increases each round.
	var/list/upgrades = list()
	var/list/sacrificed_ckeys = list()
	var/all_access_toolbox = 0
	var/armor_pen = 0
	var/freeze_beam = 0
	var/freeze_beam_cooldown = 100
	var/icon/true_icon = new('icons/oldschool/chaos_overlay.dmi', "chaos_a_overlay")

/obj/structure/statue/toolbox/New()
	flags_1 |= NODECONSTRUCT_1
	..()
	GLOB.toolbox_statues += src
	var/n = 0
	for (var/T in subtypesof(/datum/toolbox_upgrade))
		n = n + 1
		upgrades += new T()

/obj/structure/statue/toolbox/attackby(obj/item/W, mob/living/user, params)
	if (W == true_box && user == Holder && (user in view(1,src)))
		PerformSacrifice(user)
	else
		return ..()

/obj/structure/statue/toolbox/Topic(href, href_list)
	if (usr != Holder || !ishuman(usr) || !(usr in view(1, src)))
		return
	if (href_list["acquire"])
		var/datum/toolbox_upgrade/TU = locate(href_list["acquire"])
		if (istype(TU) && !TU.acquired)
			TU.acquire(usr, src)
	show_shop(usr)

/obj/structure/statue/toolbox/proc/show_shop(mob/living/carbon/human/user)
	var/data = "<HTML><HEAD><title>Chaos Upgrades</title></HEAD>"
	data += "<b>The maiden</b> is at <b>[obj_integrity] / [max_integrity]</b> health. <a href='?src=\ref[src]'>Refresh</a><br>"
	data += "You have made <b>[sacrifices]</b> sacrifices.<br>"
	data += "You have <b>[toolbox_points]</b> points left to spend.<br></b><hr>"
	data += "<b><div align='center'>Upgrades</div></b><br>"
	for (var/datum/toolbox_upgrade/TU in upgrades)
		if (TU.acquired || !TU.can_apply(user, src))
			data += "<i>[TU.name]</i> - [TU.acquired ? "<i>ACQUIRED</i>" : "<b>[TU.cost]</b> points"]. Minimum sacrifices: <b>[TU.min_sacrifices]</b><br>"
		else
			data += "<a href='?src=\ref[src];acquire=\ref[TU]'><b>[TU.name]</b></a> - [TU.acquired ? "<i>ACQUIRED</i>" : "<b>[TU.cost]</b> points"]. Minimum sacrifices: <b>[TU.min_sacrifices]</b><br>"
		data += "[TU.desc]<br><br>"
	data += "</HTML>"
	user << browse(data,"window=toolboxupgrades;size=400x600")

/obj/structure/statue/toolbox/Destroy()
	if (!toolbox_pulled)
		return ..()
	if (true_box && !QDELETED(true_box))
		qdel(true_box)
	if (Holder)
		for(var/obj/item/W in Holder)
			if(!Holder.dropItemToGround(W))
				qdel(W)
				Holder.regenerate_icons()

		Holder.gib(1, 0, 0)
	for (var/client/C in GLOB.clients)
		C << sound('sound/toolbox/toolbox_scream.ogg')
	to_chat(world, "<span class='userdanger'>The [toolbox_pulled ? "chaos" : "pure"] maiden has been vanquished!</span>")
	new /obj/effect/gibspawner/human(get_turf(src))
	..()

/obj/structure/statue/toolbox/ex_act(severity, target)
	if (!toolbox_pulled)
		return ..()
	switch(severity)
		if(1)
			take_damage(rand(250,500), BRUTE, "bomb", 0)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)

/obj/structure/statue/toolbox/proc/PerformSacrifice(mob/living/carbon/human/user)
	for (var/mob/living/carbon/human/H in view(2, src))
		if (H == Holder)
			continue
		if (H.stat == 0)
			to_chat(user, "<span class='danger'>[H] is too strong to be sacrificed!</span>")
			continue

		var/S_ckey
		if (H.ckey)
			S_ckey = H.ckey
		else if(H.mind && H.mind.key)
			S_ckey = ckey(H.mind.key)
		else
			continue

		if (S_ckey in sacrificed_ckeys)
			to_chat(user, "<span class='danger'>\The [src] rejects [H].</span>")
			continue

		sacrificed_ckeys += S_ckey

		for(var/obj/item/W in H)
			if(!Holder.dropItemToGround(W))
				qdel(W)
				H.regenerate_icons()

		obj_integrity = max_integrity
		sacrifices++
		toolbox_points++
		to_chat(world, "<span class='userdanger'>[H] has been sacrificed to the chaos maiden!</span>")
		H.gib(0, 0, 0)
		for (var/client/C in GLOB.clients)
			C << sound('sound/toolbox/toolbox_scream.ogg')
		return

	if (GLOB.clients.len < 10)
		for (var/mob/living/carbon/monkey/M in view(2, src))
			if (M.stat == 0)
				to_chat(user, "<span class='danger'>[M] is too strong to be sacrificed!</span>")
				continue

			for(var/obj/item/W in M)
				if(!Holder.dropItemToGround(W))
					qdel(W)
					M.regenerate_icons()

			to_chat(world, "<span class='userdanger'>[M] has been sacrificed to the chaos maiden!</span>")
			toolbox_points += 0.5
			M.gib(0, 0, 0)


/obj/structure/statue/toolbox/attack_hand(mob/living/user)
	if (!user || !user.mind)
		return
	if (!ishuman(user))
		return
	if (user == Holder && user in view(1, src))
		show_shop(user)
		return
	if (toolbox_pulled)
		user.visible_message("<span class='danger'>[user] inspects \the [src].</span>", "<span class='danger'>You inspect \the [src]. It appears to be missing something.</span>")
		return
	if (user.mind.assigned_role != "Assistant" || (user.ckey in failed_ckeys))
		user.visible_message("<span class='danger'>[user] approaches \the [src], but decides not to touch it after all.</span>","<span class='danger'>You approach \the [src], but a feeling of unworthiness holds you back.</span>")
		return
	if (prob(prob_success))
		toolbox_pulled = 1
		Holder = user
		update_icon()
		var/image/I = image('icons/oldschool/pentagram5x5_new.dmi', icon_state="pentagram5x5", layer=HIGH_SIGIL_LAYER)
		var/matrix/M = matrix()
		M.Translate(-64, -64)
		I.transform = M
		underlays += I
		to_chat(world, "<span class='userdanger'>[user] is the CHAOS ASSISTANT.</span>")
		for (var/client/C in GLOB.clients)
			C << sound('sound/toolbox/toolbox_scream.ogg')
		name = "statue of the chaos maiden"
		desc = "An ancient marble statue. The subject is depicted with a floor-length braid and is missing a toolbox. Something is very eerie about this statue. You could swear its eyes follow your movements..."
		make_True_Assistant(user)
		reset_chaos_assistant_chance()
	else
		failed_ckeys += user.ckey
		user.visible_message("<span class='boldannounce'>[user] failed to take the toolbox from the pure maiden.</span>")

/obj/structure/statue/toolbox/proc/make_True_Assistant(mob/living/carbon/human/H)
	H.mind.add_antag_datum(/datum/antagonist/traitor/human/assistant)
	true_box = new(H.loc)
	true_box.Statue = src
	H.put_in_active_hand(true_box)
	H.underlays += true_icon

/obj/structure/statue/toolbox/update_icon()
	if(toolbox_pulled)
		icon = 'icons/oldschool/chaosmaiden.dmi'
	else
		icon = initial(icon)
	icon_state = toolbox_pulled ? "venus_alt3" : "venus"

/*
	The objective
*/

/datum/antagonist/traitor/human/assistant //used to give custom objectives
	silent = FALSE
	give_objectives = TRUE
	should_give_codewords = FALSE
	should_specialise = FALSE

/datum/antagonist/traitor/human/assistant/equip()

/datum/antagonist/traitor/human/assistant/forge_traitor_objectives()
	var/datum/objective/true_assistant/TA = new
	TA.gen_amount_goal()
	TA.owner = owner
	add_objective(TA)

/datum/objective/true_assistant
	//dangerrating = 5

/datum/objective/true_assistant/proc/gen_amount_goal()
	target_amount = rand(2,10)
	explanation_text = "Sacrifice at least [target_amount] crew members to the chaos maiden. Do not allow the maiden to be destroyed."
	return target_amount

/datum/objective/true_assistant/check_completion()
	var/obj/structure/statue/toolbox/Statue = null
	for (var/obj/structure/statue/toolbox/T in GLOB.toolbox_statues)
		if (T.Holder == owner)
			Statue = T
			break
	if (Statue == null || QDELETED(Statue))
		return 0
	if (Statue.sacrifices >= target_amount)
		return 1
	return 0


/obj/structure/statue/toolbox/deconstruct(disassembled = TRUE)
	if (!toolbox_pulled)
		return ..()
	if (!disassembled)
		return ..()
/*
	The toolbox
*/

/obj/item/storage/toolbox/true
	name = "true toolbox"
	var/obj/structure/statue/toolbox/Statue
	icon_state = "red"
	item_state = "toolbox_red"
	block_chance = 60
	//origin_tech = null
	force = 12
	var/next_freeze = 0
	var/obj/item/ammo_casing/energy/temp/assistant/casing

/obj/item/storage/toolbox/true/New()
	..()

/obj/item/storage/toolbox/true/GetAccess()
	if (Statue.all_access_toolbox)
		return get_all_accesses()
	return ..()

/obj/item/storage/toolbox/true/Destroy()
	if (casing)
		qdel(casing)
	if (Statue != null && !QDELETED(Statue))
		qdel(Statue)
	..()

/obj/item/storage/toolbox/true/PopulateContents()
	new /obj/item/screwdriver/true(src)
	new /obj/item/wrench/true(src)
	new /obj/item/weldingtool/true(src)
	new /obj/item/crowbar/true(src)
	new /obj/item/wirecutters/true(src, "red")
	new /obj/item/device/multitool(src)
	new /obj/item/clothing/gloves/color/yellow(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/storage/belt/utility(src)
	new /obj/item/paper/chaos_guide(src)

/obj/item/storage/toolbox/true/attack(mob/living/target, mob/living/user)
	if (Statue == null || Statue.Holder == null)
		return
	if (user != Statue.Holder)
		to_chat(user, "<span class='warning'>You don't feel worthy of using this toolbox...</span>")
		return
	..()
	if (!isliving(target) || iscyborg(target) || !ishuman(user))
		return
	var/mob/living/carbon/human/H = target
	if (Statue.armor_pen != -1 && istype(H) && H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK, Statue.armor_pen))
		return


	target.Knockdown(60)
	add_logs(user, target, "stunned", src)
	src.add_fingerprint(user)
	target.visible_message("<span class ='danger'>[user] has knocked down [target] with [src]!</span>", \
		"<span class ='userdanger'>[user] has knocked down [target] with [src]!</span>")
	target.LAssailant = user

/obj/item/storage/toolbox/true/afterattack(atom/target, mob/living/user, flag, params)
	if (!Statue.freeze_beam || user != Statue.Holder)
		return ..()
	if (flag)
		return ..()
	if (next_freeze > world.time)
		to_chat(user, "<span class='warning'>\The [src] is still recharging!</span>")
		return ..()
	if (!casing)
		casing = new (Statue)

	next_freeze = world.time + Statue.freeze_beam_cooldown
	casing.newshot()
	casing.fire_casing(target, user, params)
	playsound(user, casing.fire_sound, 50, 1)


/obj/item/ammo_casing/energy/temp/assistant
	projectile_type = /obj/item/projectile/temp
	fire_sound = 'sound/weapons/pulse3.ogg'
	firing_effect_type = null

/*
	The tools
*/

/obj/item/screwdriver/true
	name = "true screwdriver"
	toolspeed = 0

/obj/item/wrench/true
	name = "true wrench"
	toolspeed = 0

/obj/item/weldingtool/true
	name = "true welding tool"
	toolspeed = 0

/obj/item/weldingtool/true/get_fuel()
	return 1337

/obj/item/weldingtool/true/use()
	return 1

/obj/item/weldingtool/true/attackby(obj/item/I, mob/user, params)
	..()

/obj/item/crowbar/true
	name = "true crowbar"
	toolspeed = 0

/obj/item/wirecutters/true
	name = "true wirecutters"
	toolspeed = 0

/*
	Chaos Guide
*/

/obj/item/paper/chaos_guide
	name = "Making Momma Proud"
	icon_state = "pamphlet"
	info = "<b>Welcome to your guide on how to make YOUR momma PROUD.</b><br>\
			It's your job to cause as much chaos as possible. To help you accomplish this goal, you have been given the <b>TRUE TOOLBOX</b>. It contains \
			some useful items as well as true tools - these tools are instantaneous. It should also be noted that not only can your welder \
			never run out, but it also won't hurt your eyes if you use it without protection. You are the <b>CHAOS ASSISTANT</b>. Your toolbox has a 60% \
			chance at blocking any attack thrown your way - including bullets, lasers, people disarming you and similar. It also has a <b>GUARANTEED KNOCKDOWN</b> unless \
			blocked by a shield or similar - but even that weakness can be eliminated by using the shop! \
			May God help those who come near you! Your toolbox starts off doing 12 damage, but this as well as many other powerful things can be upgraded \
			by using an empty hand on the maiden. Now, you may notice that you cannot upgrade anything. Well that's because you haven't sacrificed anyone, \
			dummy. Bring sacrifices onto the pentagon, and then click on the maiden with your toolbox. That ought to do it. Make sure they're in critical before \
			you do however, or it won't work. Now, you may be thinking to yourself - gee, why would I even sacrifice people if I've got this monster of a toolbox? \
			Well, at the very least you should keep an eye on the statue. It has 1000 health so it is beefy, but should it or your toolbox be destroyed you will be \
			gibbed instantly. Sacrifices will fully heal the statue, so unless you fuck off and do your own thing you should be fine. If there are less than 10 players \
			you can use monkeys for 0.5 points. Note that this will not count as an actual 'sacrifice' nor will it count towards your objective."

/obj/item/paper/chaos_guide/New()
	..()
	icon_state = "pamphlet"

//Making this happen more often -falaskian

GLOBAL_VAR_INIT(chaosassistantchancepath,"data/other_saves/chaos_assistant_chance.sav")
/proc/load_chaos_assistant_chance()
	if(GLOB && GLOB.chaosassistantchancepath)
		var/savefile/S = new(GLOB.chaosassistantchancepath)
		if(S)
			var/increase = 0
			var/next_increase = 0
			S["chance_increase"] >> increase
			for(var/obj/structure/statue/toolbox/statue in world)
				if(!next_increase)
					next_increase = increase+statue.chance_increase
				if(increase)
					statue.prob_success = increase
			if(next_increase)
				S["chance_increase"] << min(next_increase,100)

/proc/reset_chaos_assistant_chance()
	if(GLOB && GLOB.chaosassistantchancepath)
		var/savefile/S = new(GLOB.chaosassistantchancepath)
		if(S)
			var/new_value = 0
			for(var/obj/structure/statue/toolbox/statue in world)
				new_value = initial(statue.prob_success)
				break
			if(isnum(new_value))
				S["chance_increase"] << new_value




