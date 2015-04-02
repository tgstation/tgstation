//banana flavored chaos and horror ahead

/obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "mk-honk prototype shoes"
	desc = "Lost prototype of advanced clown tech. Powered by bananium, these shoes leave a trail of chaos in their wake."
	icon_state = "clown_prototype_off"
	var/on = 0
	var/bananium = 0
	action_button_name = "Toggle Shoes"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/step_action()
	if(on)
		if(footstep > 1)//honks when activated
			playsound(src, "sound/items/bikehorn.ogg", 75, 1)
			footstep = 0
		else
			footstep++

		new/obj/item/weapon/grown/bananapeel/specialpeel(get_step(src,turn(usr.dir, 180)), 5) //honk
		bananium -= 100
		if(bananium < 100)
			on = !on
			update_icon()
			usr << "<span class='danger'>You ran out of bananium!</span>"
	else
		..()

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attack_self(mob/user)
	if(bananium > 0)
		var/sheet_amount = round(bananium / 2000)
		if(sheet_amount > 0)
			var/obj/item/stack/sheet/mineral/bananium/M = new/obj/item/stack/sheet/mineral/bananium(get_turf(loc))
			M.amount = sheet_amount
			bananium -= sheet_amount * 2000
			user << "<span class='notice'>You retrieve [sheet_amount] sheets of bananium.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attackby(obj/item/O, mob/user, params)
	if(istype(O,/obj/item/stack/sheet/mineral/bananium))
		var/obj/item/stack/sheet/mineral/bananium/M = O
		bananium += 2000 * M.amount
		user << "<span class='notice'>You insert [M.amount] bananium sheets into the prototype shoes.</span>"
		M.use(M.amount)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/examine(mob/user)
	..()
	user << "<span class='notice'>The shoes are [on ? "enabled" : "disabled"]. There is [bananium] bananium left.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/ui_action_click()
	if(bananium > 0)
		on = !on
		update_icon()
		usr << "You [on ? "activate" : "deactivate"] the prototype shoes."
	else
		usr << "You need bananium to turn the prototype shoes on."

/obj/item/clothing/shoes/clown_shoes/banana_shoes/update_icon()
	if(on)
		icon_state = "clown_prototype_on"
	else
		icon_state = "clown_prototype_off"
	usr.update_inv_shoes()

//////////////////////////////////////////////////
///////////BANANIUM PLATED CLOWN SHOES////////////
//////////////////////////////////////////////////

/obj/item/clothing/shoes/clown_shoes/bananium
	name = "bananium plated clown shoes"
	desc = "Trophy shoes for the loudest clowns."
	icon_state = "clown_bananium"
	var/sound = "sound/effects/clownstep1.ogg"
	var/list/sound_list = list("Clown squeak","Bike horn","Meteor","EMPulse","Bubbles","Bang","Body fall","Clang","Glass step","Glass knock","Mouse",
	"Snap","Sparks","Coin","Crowbar","Polaroid","Timer beep","Tray","Ping","Mecha","Slip","Hot","Laser sword","Gunshot","Laser","Taser")
	action_button_name = "Choose Noise"
	var/emagged = 0

/obj/item/clothing/shoes/clown_shoes/bananium/ui_action_click()
	var/pick_sound = input("Choose noise!","Noise") in sound_list
	switch(pick_sound)
		if("Clown squeak")
			sound = "sound/effects/clownstep[pick(1,2)].ogg"
		if("Bike horn")
			sound = "sound/items/bikehorn.ogg"
		if("Meteor")
			sound = "sound/effects/meteorimpact.ogg"
		if("EMPulse")
			sound = "sound/effects/EMPulse.ogg"
		if("Bubbles")
			sound = "sound/effects/bubbles.ogg"
		if("Bang")
			sound = "sound/effects/bang.ogg"
		if("Body fall")
			sound = "sound/effects/bodyfall[pick(1,2,3,4)].ogg"
		if("Clang")
			sound = "sound/effects/clang.ogg"
		if("Glass step")
			sound = "sound/effects/glass_step.ogg"
		if("Glass knock")
			sound = "sound/effects/Glassknock.ogg"
		if("Mouse")
			sound = "sound/effects/mousesqueek.ogg"
		if("Snap")
			sound = "sound/effects/snap.ogg"
		if("Sparks")
			sound = "sound/effects/sparks[pick(1,2,3,4)].ogg"
		if("Coin")
			sound = "sound/items/coinflip.ogg"
		if("Crowbar")
			sound = "sound/items/Crowbar.ogg"
		if("Polaroid")
			sound = "sound/items/polaroid[pick(1,2)].ogg"
		if("Timer beep")
			sound = "sound/items/timer.ogg"
		if("Tray")
			sound = "sound/items/trayhit[pick(1,2)].ogg"
		if("Ping")
			sound = "sound/machines/ping.ogg"
		if("Mecha")
			sound = "sound/mecha/mechstep.ogg"
		if("Slip")
			sound = "sound/misc/slip.ogg"
		if("Hot")
			sound = "sound/vox_fem/hot.ogg"
		if("Laser sword")
			sound = "sound/weapons/blade1.ogg"
		if("Gunshot")
			sound = "sound/weapons/Gunshot[pick(2,3,4)].ogg"
		if("Laser")
			sound = "sound/weapons/Laser.ogg"
		if("Taser")
			sound = "sound/weapons/Taser.ogg"

/obj/item/clothing/shoes/clown_shoes/bananium/step_action()
	if(footstep > 1)
		playsound(src, sound, 75, 1)
		footstep = 0
	else
		footstep++