#define MAKESHIFT_BATON_CD 1.5

/obj/item/melee/baton
	var/stamforce = 80
	var/selfcharge = 0
	var/charge_sections = 0
	var/shaded_charge = 0
	var/charge_tick = 0
	var/charge_delay = 4
	var/cell_type = /obj/item/stock_parts/cell/potato

/obj/item/melee/baton/proc/recharge_newshot()
	return

/obj/item/melee/baton/attack_self(mob/user)
	if(cell && cell.charge >= hitcost)
		status = !status
		to_chat(user, "<span class='notice'>[src] is now [status ? "on" : "off"].</span>")
		playsound(loc, "sparks", 75, 1, -1)
	else
		status = 0
		if(!cell)
			to_chat(user, "<span class='warning'>[src] does not have a power source!</span>")
		else
			to_chat(user, "<span class='warning'>[src] is out of charge.</span>")
	update_icon()
	add_fingerprint(user)

/obj/item/melee/baton/stungun
	name = "stungun"
	desc = "A powerful, self-charging electric stun gun, courtesy of Nanotrasen's self-defense implements."
	icon = 'hippiestation/icons/obj/items_and_weapons.dmi'
	icon_state = "stungun"
	item_state = "stungun"
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 5
	stunforce = 100
	hitcost = 100
	throw_hit_chance = 20
	attack_verb = list("poked")
	selfcharge = 1
	charge_sections = 3
	shaded_charge = 1
	charge_tick = 0
	charge_delay = 10

/obj/item/melee/baton/stungun/Initialize()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	cell.give(cell.maxcharge)
	recharge_newshot(1)
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_icon()
	. = ..()

/obj/item/melee/baton/stungun/attack_self(mob/user)
	if(cell && cell.charge >= hitcost)
		..()

/obj/item/melee/baton/stungun/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/screwdriver))
		to_chat(user, "<span class='warning'>That would void the warranty.</span>")
		return

/obj/item/melee/baton/stungun/update_icon()
	..()
	var/ratio = Ceiling((cell.charge / cell.maxcharge) * charge_sections)
	var/iconState = "[initial(name)]_charge"
	var/itemState = null
	if(!initial(item_state))
		itemState = icon_state
	if(cell.charge < hitcost)
		add_overlay("[initial(name)]_empty")
	else
		if(!shaded_charge)
			var/mutable_appearance/charge_overlay = mutable_appearance(icon, iconState)
			for(var/i = ratio, i >= 1, i--)
				add_overlay(charge_overlay)
		else
			add_overlay("[initial(name)]_charge[ratio]")
	if(itemState)
		itemState += "[ratio]"
		item_state = itemState

/obj/item/melee/baton/stungun/process()
	if(selfcharge)
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!cell)
			return
		cell.give(100)
		if(cell && cell.charge < 300)
			playsound(src, 'hippiestation/sound/misc/charge.ogg', 35, FALSE, pressure_affected = FALSE)
			update_icon()

/obj/item/melee/baton/stungun/baton_stun()
	..()
	playsound(loc, 'hippiestation/sound/weapons/stungun.ogg', 75, 1, -1)
	update_icon()

/obj/item/melee/baton/cattleprod/hippie_cattleprod
	w_class = WEIGHT_CLASS_NORMAL
	stunforce = 0


/obj/item/melee/baton/proc/baton_stun_hippie_makeshift(mob/living/L, mob/user)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.check_shields(0, "[user]'s [name]", src, MELEE_ATTACK)) //No message; check_shields() handles that
			playsound(L, 'sound/weapons/Genhit.ogg', 50, 1)
			return 0
	if(iscyborg(loc))
		var/mob/living/silicon/robot/R = loc
		if(!R || !R.cell || !R.cell.use(hitcost))
			return 0
	else
		if(!deductcharge(hitcost))
			return 0

	L.Stun(stunforce)
	L.staminaloss += stamforce //Not reduced by armour to give it an edge over a taser.
	L.apply_effect(STUTTER, 7) //Duration of sec baton
	user.changeNext_move(CLICK_CD_MELEE * MAKESHIFT_BATON_CD)
	if(user)
		user.lastattacked = L
		L.lastattacker = user
		L.visible_message("<span class='danger'>[user] has stunned [L] with [src]!</span>", \
								"<span class='userdanger'>[user] has stunned you with [src]!</span>")
		add_logs(user, L, "stunned")

	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.forcesay(GLOB.hit_appends)

	return 1

#undef MAKESHIFT_BATON_CD
