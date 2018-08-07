/datum/buildmode_mode/boom
	key = "boom"
	
	var/devastation = -1
	var/heavy = -1
	var/light = -1
	var/flash = -1
	var/flames = -1

/datum/buildmode_mode/boom/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Mouse Button on obj  = Kaboom</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

/datum/buildmode_mode/boom/change_settings(mob/user)
	devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null) devastation = -1
	heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null) heavy = -1
	light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null) light = -1
	flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null) flash = -1
	flames = input("Range of flames. -1 to none", text("Input"))  as num|null
	if(flames == null) flames = -1

/datum/buildmode_mode/boom/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(left_click)
		explosion(object, devastation, heavy, light, flash, null, TRUE, flames)
