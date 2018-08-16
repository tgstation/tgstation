/obj/item/electropack/shockcollar
	name = "shock collar"
	desc = "A reinforced metal collar. It seems to have some form of wiring near the front. Strange.."
	icon = 'modular_citadel/icons/obj/clothing/cit_neck.dmi'
	icon_override = 'modular_citadel/icons/mob/citadel/neck.dmi'
	icon_state = "shockcollar"
	item_state = "shockcollar"
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK | ITEM_SLOT_DENYPOCKET   //no more pocket shockers
	w_class = WEIGHT_CLASS_SMALL
	strip_delay = 60
	equip_delay_other = 60
	materials = list(MAT_METAL=5000, MAT_GLASS=2000)
	var/tagname = null

/datum/design/electropack/shockcollar
	name = "Shockcollar"
	id = "shockcollar"
	build_type = AUTOLATHE
	build_path = /obj/item/electropack/shockcollar
	materials = list(MAT_METAL=5000, MAT_GLASS=2000)
	category = list("hacked", "Misc")

/obj/item/electropack/shockcollar/attack_hand(mob/user)
	if(loc == user && user.get_item_by_slot(SLOT_NECK))
		to_chat(user, "<span class='warning'>The collar is fastened tight! You'll need help taking this off!</span>")
		return
	..()

/obj/item/electropack/shockcollar/receive_signal(datum/signal/signal)
	if(!signal || signal.data["code"] != code)
		return

	if(isliving(loc) && on)
		if(shock_cooldown != 0)
			return
		shock_cooldown = 1
		spawn(100)
			shock_cooldown = 0
		var/mob/living/L = loc
		step(L, pick(GLOB.cardinals))

		to_chat(L, "<span class='danger'>You feel a sharp shock from the collar!</span>")
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, L)
		s.start()

		L.Knockdown(100)

	if(master)
		master.receive_signal()
	return

/obj/item/electropack/shockcollar/attack_self(mob/user) //Turns out can't fully source this from the parent item, spritepath gets confused if power toggled. Will come back to this when I know how to code better and readd powertoggle..
	var/option = "Change Name"
	option = input(user, "What do you want to do?", "[src]", option) as null|anything in list("Change Name", "Change Frequency")
	switch(option)
		if("Change Name")
			var/t = input(user, "Would you like to change the name on the tag?", "Name your new pet", tagname ? tagname : "Spot") as null|text
			if(t)
				tagname = copytext(sanitize(t), 1, MAX_NAME_LEN)
				name = "[initial(name)] - [tagname]"
		if("Change Frequency")
			if(!ishuman(user))
				return
			user.set_machine(src)
			var/dat = {"<SK><BR>
		<B>Frequency/Code</B> for shock collar:<BR>
		Frequency:
		<A href='byond://?src=\ref[src];freq=-10'>-</A>
		<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(frequency)]
		<A href='byond://?src=\ref[src];freq=2'>+</A>
		<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
		Code:
		<A href='byond://?src=\ref[src];code=-5'>-</A>
		<A href='byond://?src=\ref[src];code=-1'>-</A> [code]
		<A href='byond://?src=\ref[src];code=1'>+</A>
		<A href='byond://?src=\ref[src];code=5'>+</A><BR>
		</SK>"}

			user << browse(dat, "window=radio")
			onclose(user, "radio")
			return
