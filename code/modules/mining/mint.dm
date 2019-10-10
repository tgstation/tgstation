/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/economy.dmi'
	icon_state = "coinpress0"
	density = TRUE
	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = FALSE
	var/chosen = /datum/material/iron //which material will be used to make coins
	var/coinsToProduce = 10
	speed_process = TRUE


/obj/machinery/mineral/mint/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(
		/datum/material/iron,
		/datum/material/plasma,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/uranium,
		/datum/material/titanium,
		/datum/material/diamond,
		/datum/material/bananium,
		/datum/material/adamantine,
		/datum/material/mythril,
		/datum/material/plastic,
		/datum/material/runite
	), MINERAL_MATERIAL_AMOUNT * 50, FALSE, /obj/item/stack)
	chosen = getmaterialref(chosen)


/obj/machinery/mineral/mint/process()
	var/turf/T = get_step(src, input_dir)
	if(!T)
		return

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/obj/item/stack/sheet/O in T)
		materials.insert_item(O)

/obj/machinery/mineral/mint/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/dat = "<b>Coin Press</b><br>"

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/datum/material/M in materials.materials)
		var/amount = materials.get_material_amount(M)
		if(!amount && chosen != M)
			continue
		dat += "<br><b>[M.name] amount:</b> [amount] cm<sup>3</sup> "
		if (chosen == M)
			dat += "<b>Chosen</b>"
		else
			dat += "<A href='?src=[REF(src)];choose=[REF(M)]'>Choose</A>"

	var/datum/material/M = chosen

	dat += "<br><br>Will produce [coinsToProduce] [lowertext(M.name)] coins if enough materials are available.<br>"
	dat += "<A href='?src=[REF(src)];chooseAmt=-10'>-10</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=-5'>-5</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=-1'>-1</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=1'>+1</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=5'>+5</A> "
	dat += "<A href='?src=[REF(src)];chooseAmt=10'>+10</A> "

	dat += "<br><br>In total this machine produced <font color='green'><b>[newCoins]</b></font> coins."
	dat += "<br><A href='?src=[REF(src)];makeCoins=[1]'>Make coins</A>"
	user << browse(dat, "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(processing==1)
		to_chat(usr, "<span class='notice'>The machine is processing.</span>")
		return
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(href_list["choose"])
		var/datum/material/new_material = locate(href_list["choose"])
		if(istype(new_material))
			chosen = new_material
	if(href_list["chooseAmt"])
		coinsToProduce = CLAMP(coinsToProduce + text2num(href_list["chooseAmt"]), 0, 1000)
		updateUsrDialog()
	if(href_list["makeCoins"])
		var/temp_coins = coinsToProduce
		processing = TRUE
		icon_state = "coinpress1"
		var/coin_mat = MINERAL_MATERIAL_AMOUNT * 0.2
		var/datum/material/M = chosen
		if(!M)
			updateUsrDialog()
			return

		while(coinsToProduce > 0 && materials.use_amount_mat(coin_mat, chosen))
			create_coins()
			coinsToProduce--
			newCoins++
			src.updateUsrDialog()
			sleep(5)

		icon_state = "coinpress0"
		processing = FALSE
		coinsToProduce = temp_coins
	src.updateUsrDialog()
	return

/obj/machinery/mineral/mint/proc/create_coins()
	var/turf/T = get_step(src,output_dir)
	var/temp_list = list()
	temp_list[chosen] = 400
	if(T)
		var/obj/item/O = new /obj/item/coin(src)
		var/obj/item/storage/bag/money/B = locate(/obj/item/storage/bag/money, T)
		O.set_custom_materials(temp_list)
		if(!B)
			B = new /obj/item/storage/bag/money(src)
			unload_mineral(B)
		O.forceMove(B)
