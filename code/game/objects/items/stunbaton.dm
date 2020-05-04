/obj/item/melee/baton
	name = "stun baton"
	desc = "A stun baton for incapacitating people with."

	icon_state = "stunbaton"
	item_state = "baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'

	force = 10
	attack_verb = list("beaten")

	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80)

	throwforce = 7
	//The likelihood of a thrown baton to apply it's stun effect. Otherwise, it's simply a standard non-stun hit.
	var/throw_stun_chance = 100
	
	var/obj/item/stock_parts/cell/cell
	var/preload_cell_type //if not empty the baton starts with this type of cell
	var/cell_hit_cost = 500 //How much do we deduct from our cell per hit
	var/can_remove_cell = TRUE

	//This var is used internally to determine if the baton is on or off.
	var/turned_on = FALSE
	var/activate_sound = "sparks"

	var/stun_sound = 'sound/weapons/egloves.ogg'
	
	//This var determines the stamina damage of the baton. This is used in the baton_effect proc. This value is reduced by armor.
	var/stamina_loss_amt = 30

	var/convertible = TRUE //if it can be converted with a conversion kit

/obj/item/melee/baton/get_cell()
	return cell

/obj/item/melee/baton/suicide_act(mob/user)
	if(cell && cell.charge && turned_on)
		user.visible_message("<span class='suicide'>[user] is putting the live [name] in [user.p_their()] mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		. = (FIRELOSS)
		attack(user,user)
	else
		user.visible_message("<span class='suicide'>[user] is shoving the [name] down their throat! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		. = (OXYLOSS)

/obj/item/melee/baton/Initialize()
	. = ..()
	if(preload_cell_type)
		if(!ispath(preload_cell_type,/obj/item/stock_parts/cell))
			log_mapping("[src] at [AREACOORD(src)] had an invalid preload_cell_type: [preload_cell_type].")
		else
			cell = new preload_cell_type(src)
	update_icon()
	RegisterSignal(src, COMSIG_PARENT_ATTACKBY, .proc/convert)


/obj/item/melee/baton/Destroy()
	if(cell)
		QDEL_NULL(cell)
	UnregisterSignal(src, COMSIG_PARENT_ATTACKBY)
	return ..()

/obj/item/melee/baton/proc/convert(datum/source, obj/item/I, mob/user)
	if(istype(I,/obj/item/conversion_kit) && convertible)
		var/turf/T = get_turf(src)
		var/obj/item/melee/classic_baton/B = new /obj/item/melee/classic_baton (T)
		B.alpha = 20
		playsound(T, 'sound/items/drill_use.ogg', 80, TRUE, -1)
		animate(src, alpha = 0, time = 10)
		animate(B, alpha = 255, time = 10)
		qdel(I)
		qdel(src)

/obj/item/melee/baton/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
		turned_on = FALSE
		update_icon()
	return ..()

/obj/item/melee/baton/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	//Only mob/living types have stun handling
	if(turned_on && prob(throw_stun_chance) && iscarbon(hit_atom))
		baton_effect(hit_atom)

/obj/item/melee/baton/loaded //this one starts with a cell pre-installed.
	preload_cell_type = /obj/item/stock_parts/cell/high

/obj/item/melee/baton/proc/deductcharge(chrgdeductamt)
	if(cell)
		//Note this value returned is significant, as it will determine
		//if a stun is applied or not
		. = cell.use(chrgdeductamt)
		if(turned_on && cell.charge < cell_hit_cost)
			//we're below minimum, turn off
			turned_on = FALSE
			update_icon()
			playsound(src, activate_sound, 75, TRUE, -1)


/obj/item/melee/baton/update_icon_state()
	if(turned_on)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/melee/baton/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>\The [src] is [round(cell.percent())]% charged.</span>"
	else
		. += "<span class='warning'>\The [src] does not have a power source installed.</span>"

/obj/item/melee/baton/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='warning'>[src] already has a cell!</span>")
		else
			if(C.maxcharge < cell_hit_cost)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			update_icon()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		tryremovecell(user)
	else
		return ..()

/obj/item/melee/baton/proc/tryremovecell(mob/user)
	if(cell && can_remove_cell)
		cell.update_icon()
		cell.forceMove(get_turf(src))
		cell = null
		to_chat(user, "<span class='notice'>You remove the cell from [src].</span>")
		turned_on = FALSE
		update_icon()

/obj/item/melee/baton/attack_self(mob/user)
	toggle_on(user)

/obj/item/melee/baton/proc/toggle_on(mob/user)
	if(cell && cell.charge > cell_hit_cost)
		turned_on = !turned_on
		to_chat(user, "<span class='notice'>[src] is now [turned_on ? "on" : "off"].</span>")
		playsound(src, activate_sound, 75, TRUE, -1)
	else
		turned_on = FALSE
		if(!cell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	update_icon()
	add_fingerprint(user)

///The clumsy check is used only for those who are clowns and clown-like. Honk.
/obj/item/melee/baton/proc/clumsy_check(mob/living/carbon/human/user)
	if(turned_on && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		playsound(src, stun_sound, 75, TRUE, -1)
		user.visible_message("<span class='danger'>[user] accidentally hits [user.p_them()]self with [src]!</span>", \
							"<span class='userdanger'>You accidentally hit yourself with [src]!</span>")
		user.Knockdown(15 SECONDS) //should really be an equivalent to attack(user,user)
		deductcharge(cell_hit_cost)
		return TRUE
	return FALSE

///This handles the special function that allows the baton to be used nonharmfully while also applying the stun effect regardless of intent. It also is where our clumsy check and martial counter, or CQC block, check is made.
/obj/item/melee/baton/attack(mob/M, mob/living/carbon/human/user)
	if(clumsy_check(user))
		return FALSE

	if(iscyborg(M))
		..()
		return


	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(check_martial_counter(L, user))
			return

	if(user.a_intent != INTENT_HARM)
		if(turned_on)
			if(baton_effect(M, user))
				user.do_attack_animation(M)
				return
			else
				to_chat(user, "<span class='danger'>The baton is still charging!</span>")
		else
			M.visible_message("<span class='warning'>[user] prods [M] with [src]. Luckily it was off.</span>", \
							"<span class='warning'>[user] prods you with [src]. Luckily it was off.</span>")
	else
		if(turned_on)
			baton_effect(M, user)
		..()

///This is the stun effect of the baton. It handles the stamina damage and other effects inflicted upon the attack, checks if the target has recently been hit with a baton, and handles logging.
/obj/item/melee/baton/proc/baton_effect(mob/living/L, mob/user)
	if(shields_blocked(L, user))
		return FALSE
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(cell_hit_cost))
			return FALSE
	else
		if(!deductcharge(cell_hit_cost))
			return FALSE
	//the zone the damage is applied against; the target's chest
	var/chest = L.get_bodypart(BODY_ZONE_CHEST)
	//how much the target's chest armor will block of the stamina damage
	var/zap_block = L.run_armor_check(chest, "melee")
	
	/// After a target is hit, we do a chunk of stamina damage, reduced by the target's armor
	L.Jitter(20)
	L.stuttering = max(8, L.stuttering)
	L.apply_damage(stamina_loss_amt, STAMINA, chest, zap_block)

	SEND_SIGNAL(L, COMSIG_LIVING_MINOR_SHOCK)

	if(user)
		L.lastattacker = user.real_name
		L.lastattackerckey = user.ckey
		L.visible_message("<span class='danger'>[user] stuns [L] with [src]!</span>", \
								"<span class='userdanger'>[user] stuns you with [src]!</span>")
		log_combat(user, L, "stunned")

	playsound(src, stun_sound, 50, TRUE, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(GLOB.hit_appends)

	return TRUE

/obj/item/melee/baton/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		deductcharge(1000 / severity)

///This is to ensure that the stun effect doesn't occur despite the attack being blocked by a shield or shield like effect, like hardsuit shields.
/obj/item/melee/baton/proc/shields_blocked(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(H, 'sound/weapons/genhit.ogg', 50, TRUE)
			return TRUE
	return FALSE

//Makeshift stun baton. Replacement for stun gloves.
/obj/item/melee/baton/cattleprod
	name = "stunprod"
	desc = "An improvised stun baton."
	icon_state = "stunprod"
	item_state = "prod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	throwforce = 5
	cell_hit_cost = 2000
	slot_flags = ITEM_SLOT_BACK
	convertible = FALSE
	var/obj/item/assembly/igniter/sparkler = 0

/obj/item/melee/baton/cattleprod/Initialize()
	. = ..()
	sparkler = new (src)

/obj/item/melee/baton/cattleprod/baton_effect()
	if(sparkler.activate())
		..()

/obj/item/melee/baton/cattleprod/Destroy()
	if(sparkler)
		QDEL_NULL(sparkler)
	return ..()

/obj/item/melee/baton/boomerang
	name = "\improper OZtek Boomerang"
	desc = "A device invented in 2486 for the great Space Emu War by the confederacy of Australicus, these high-tech boomerangs also work exceptionally well at stunning crewmembers. Just be careful to catch it when thrown!"
	throw_speed = 1
	icon_state = "boomerang"
	item_state = "boomerang"
	force = 5
	throwforce = 5
	throw_range = 5
	cell_hit_cost = 2000
	throw_stun_chance = 99  //Have you prayed today?
	convertible = FALSE
	custom_materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/silver = 10000, /datum/material/gold = 2000)

/obj/item/melee/baton/boomerang/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, gentle = FALSE, quickstart = TRUE)
	if(turned_on)
		if(ishuman(thrower))
			var/mob/living/carbon/human/H = thrower
			H.throw_mode_off() //so they can catch it on the return.
	return ..()

/obj/item/melee/baton/boomerang/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(turned_on)
		var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
		if(ishuman(hit_atom) && !caught && prob(throw_stun_chance))//if they are a carbon and they didn't catch it
			baton_effect(hit_atom)
		if(thrownby && !caught)
			sleep(1)
			if(!QDELETED(src))
				throw_at(thrownby, throw_range+2, throw_speed, null, TRUE)
	else
		return ..()


/obj/item/melee/baton/boomerang/update_icon_state()
	if(turned_on)
		icon_state = "[initial(icon_state)]_active"
	else if(!cell)
		icon_state = "[initial(icon_state)]_nocell"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/melee/baton/boomerang/loaded //Same as above, comes with a cell.
	preload_cell_type = /obj/item/stock_parts/cell/high
