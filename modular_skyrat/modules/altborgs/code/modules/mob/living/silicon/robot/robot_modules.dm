/obj/item/robot_module
	var/icon/cyborg_icon_override
	var/has_snowflake_deadsprite
	var/cyborg_pixel_offset
	var/moduleselect_alternate_icon
	var/dogborg = FALSE //Is this module a wider borg?

/obj/item/robot_module/proc/dogborg_equip()
	has_snowflake_deadsprite = TRUE
	cyborg_pixel_offset = -16
	hat_offset = INFINITY
	basic_modules += new /obj/item/dogborg_nose(src)
	basic_modules += new /obj/item/dogborg_tongue(src)
	var/mob/living/silicon/robot/cyborg = loc
	add_verb(cyborg , /mob/living/silicon/robot/proc/robot_lay_down)
	add_verb(cyborg , /mob/living/silicon/robot/proc/rest_style)
	rebuild_modules()

//ROBOT ADDITIONAL MODULES

//STANDARD
/obj/item/robot_module/standard/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/standard_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "robot"),
		"Marina" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "marinasd"),
		"Heavy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "heavysd"),
		"Eyebot" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "eyebotsd"),
		"Robot" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "robot_old"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootysd"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootysd"),
		"Protectron" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "protectron_standard"),
		"Miss m" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "missm_sd")
		)
	var/list/L = list("Fabulous" = "k69")
	for(var/a in L)
		var/image/wide = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = L[a])
		wide.pixel_x = -16
		standard_icons[a] = wide
	standard_icons = sortList(standard_icons)
	var/standard_borg_icon = show_radial_menu(cyborg, cyborg , standard_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(standard_borg_icon)
		if("Default")
			cyborg_base_icon = "robot"
		if("Marina")
			cyborg_base_icon = "marinasd"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Heavy")
			cyborg_base_icon = "heavysd"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Eyebot")
			cyborg_base_icon = "eyebotsd"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Robot")
			cyborg_base_icon = "robot_old"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Bootyborg")
			cyborg_base_icon = "bootysd"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootysd"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Protectron")
			cyborg_base_icon = "protectron_standard"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Miss m")
			cyborg_base_icon = "missm_sd"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		//Dogborgs
		if("Fabulous")
			cyborg_base_icon = "k69"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		else
			return FALSE
	return ..()

//MEDICAL
/obj/item/robot_module/medical/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/med_icons
	if(!med_icons)
		med_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "medical"),
		"Droid" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "medical"),
		"Sleek" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "sleekmed"),
		"Marina" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "marinamed"),
		"Eyebot" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "eyebotmed"),
		"Heavy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "heavymed"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootymedical"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootymedical"),
		"Protectron" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "protectron_medical"),
		"Miss m" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "missm_med"),
		"Qualified Doctor" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "qualified_doctor"),
		"Zoomba" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "zoomba_med"),
		)
		var/list/L = list("Medihound" = "medihound", "Medihound Dark" = "medihounddark", "Vale" = "valemed", "Drake" = "drakemedbox")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			med_icons[a] = wide
		med_icons = sortList(med_icons)
	var/med_borg_icon = show_radial_menu(cyborg, cyborg , med_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(med_borg_icon)
		if("Default")
			cyborg_base_icon = "medical"
		if("Zoomba")
			cyborg_base_icon = "zoomba_med"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Droid")
			cyborg_base_icon = "medical"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			hat_offset = 4
		if("Sleek")
			cyborg_base_icon = "sleekmed"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marinamed"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Eyebot")
			cyborg_base_icon = "eyebotmed"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavymed"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Bootyborg")
			cyborg_base_icon = "bootymedical"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootymedical"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Protectron")
			cyborg_base_icon = "protectron_medical"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Miss m")
			cyborg_base_icon = "missm_med"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Qualified Doctor")
			cyborg_base_icon = "qualified_doctor"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		//Dogborgs
		if("Medihound")
			cyborg_base_icon = "medihound"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_skyrat/modules/altborgs/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		if("Medihound Dark")
			cyborg_base_icon = "medihounddark"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_skyrat/modules/altborgs/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valemed"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_skyrat/modules/altborgs/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		if("Alina")
			cyborg_base_icon = "alina-med"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			special_light_key = "alina"
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_skyrat/modules/altborgs/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		if("Drake")
			cyborg_base_icon = "drakemed"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			moduleselect_icon = "medihound"
			moduleselect_alternate_icon = 'modular_skyrat/modules/altborgs/icons/ui/screen_cyborg.dmi'
			dogborg = TRUE
		else
			return FALSE
	return ..()

//ENGINEERING
/obj/item/robot_module/engineering/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/engi_icons
	if(!engi_icons)
		engi_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "engineer"),
		"Default - Treads" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "engi-tread"),
		"Loader" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "loaderborg"),
		"Handy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "handyeng"),
		"Sleek" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "sleekeng"),
		"Can" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "caneng"),
		"Marina" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "marinaeng"),
		"Spider" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "spidereng"),
		"Heavy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "heavyeng"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootyeng"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootyeng"),
		"Protectron" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "protectron_eng"),
		"Miss m" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "missm_eng"),
		"Zoomba" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "zoomba_engi"),
		)
		var/list/L = list("Pup Dozer" = "pupdozer", "Vale" = "valeeng", "Hound" = "engihound", "Darkhound" = "engihounddark", "Drake" = "drakeengbox")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			engi_icons[a] = wide
		engi_icons = sortList(engi_icons)
	var/engi_borg_icon = show_radial_menu(cyborg, cyborg , engi_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(engi_borg_icon)
		if("Default")
			cyborg_base_icon = "engineer"
		if("Zoomba")
			cyborg_base_icon = "zoomba_engi"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Default - Treads")
			cyborg_base_icon = "engi-tread"
			special_light_key = "engineer"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Loader")
			cyborg_base_icon = "loaderborg"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Handy")
			cyborg_base_icon = "handyeng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Sleek")
			cyborg_base_icon = "sleekeng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Can")
			cyborg_base_icon = "caneng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marinaeng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Spider")
			cyborg_base_icon = "spidereng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavyeng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Bootyborg")
			cyborg_base_icon = "bootyeng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootyeng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Protectron")
			cyborg_base_icon = "protectron_eng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Miss m")
			cyborg_base_icon = "missm_eng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		//Dogborgs
		if("Pup Dozer")
			cyborg_base_icon = "pupdozer"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valeeng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Hound")
			cyborg_base_icon = "engihound"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Darkhound")
			cyborg_base_icon = "engihounddark"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Alina")
			cyborg_base_icon = "alina-eng"
			special_light_key = "alina"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Drake")
			cyborg_base_icon = "drakeeng"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		else
			return FALSE
	return ..()

//SECURITY
/obj/item/robot_module/security/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/sec_icons
	if(!sec_icons)
		sec_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "sec"),
		"Default - Treads" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "sec-tread"),
		"Sleek" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "sleeksec"),
		"Can" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "cansec"),
		"Marina" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "marinasec"),
		"Spider" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "spidersec"),
		"Heavy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "heavysec"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootysecurity"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootysecurity"),
		"Protectron" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "protectron_security"),
		"Miss m" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "missm_security"),
		"Zoomba" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "zoomba_sec"),
		)
		var/list/L = list("K9" = "k9", "Vale" = "valesec", "K9 Dark" = "k9dark", "Otie" = "oties", "Drake" = "drakesecbox")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			sec_icons[a] = wide
		sec_icons = sortList(sec_icons)
	var/sec_borg_icon = show_radial_menu(cyborg, cyborg , sec_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(sec_borg_icon)
		if("Default")
			cyborg_base_icon = "sec"
		if("Zoomba")
			cyborg_base_icon = "zoomba_sec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Default - Treads")
			cyborg_base_icon = "sec-tread"
			special_light_key = "sec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Sleek")
			cyborg_base_icon = "sleeksec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marinasec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Can")
			cyborg_base_icon = "cansec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Spider")
			cyborg_base_icon = "spidersec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavysec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Bootyborg")
			cyborg_base_icon = "bootysecurity"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootysecurity"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Protectron")
			cyborg_base_icon = "protectron_security"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Miss m")
			cyborg_base_icon = "missm_security"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		//Dogborgs
		if("K9")
			cyborg_base_icon = "k9"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Otie")
			cyborg_base_icon = "oties"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Alina")
			cyborg_base_icon = "alina-sec"
			special_light_key = "alina"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("K9 Dark")
			cyborg_base_icon = "k9dark"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valesec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Drake")
			cyborg_base_icon = "drakesec"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		else
			return FALSE
	return ..()

//PEACEKEEPER
/obj/item/robot_module/peacekeeper/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/peace_icons
	if(!peace_icons)
		peace_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "peace"),
		"Borgi" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "borgi"),
		"Spider" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "whitespider"),
		"Sleek" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "sleekpeace"),
		"Marina" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "marinapeace"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootypeace"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootypeace"),
		"Protectron" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "protectron_peacekeeper")
		)
		var/list/L = list("Drake" = "drakepeacebox")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			peace_icons[a] = wide
		peace_icons = sortList(peace_icons)
	var/peace_borg_icon = show_radial_menu(cyborg, cyborg , peace_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(peace_borg_icon)
		if("Default")
			cyborg_base_icon = "peace"
		if("Sleek")
			cyborg_base_icon = "sleekpeace"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Spider")
			cyborg_base_icon = "whitespider"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Borgi")
			cyborg_base_icon = "borgi"
			moduleselect_icon = "borgi"
			moduleselect_alternate_icon = 'modular_skyrat/modules/altborgs/icons/ui/screen_cyborg.dmi'
			hat_offset = INFINITY
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Marina")
			cyborg_base_icon = "marinapeace"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Bootyborg")
			cyborg_base_icon = "bootypeace"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootypeace"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Protectron")
			cyborg_base_icon = "protectron_peacekeeper"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		//Dogborgs
		if("Drake")
			cyborg_base_icon = "drakepeace"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		else
			return FALSE
	return ..()

//JANITOR
/obj/item/robot_module/janitor/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/janitor_icons
	if(!janitor_icons)
		janitor_icons = list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "janitor"),
		"Marina" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "marinajan"),
		"Sleek" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "sleekjan"),
		"Can" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "canjan"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootyjanitor"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootyjanitor"),
		"Protectron" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "protectron_janitor"),
		"Miss m" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "missm_janitor"),
		"Heavy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "heavyres"),
		"Zoomba" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "zoomba_jani"),
		)
		var/list/L = list("Drake" = "drakejanitbox", "Otie" = "otiej", "Scrubpuppy" = "scrubpup")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			janitor_icons[a] = wide
		janitor_icons = sortList(janitor_icons)
	var/janitor_robot_icon = show_radial_menu(cyborg, cyborg , janitor_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(janitor_robot_icon)
		if("Default")
			cyborg_base_icon = "janitor"
		if("Zoomba")
			cyborg_base_icon = "zoomba_jani"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Marina")
			cyborg_base_icon = "marinajan"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Sleek")
			cyborg_base_icon = "sleekjan"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Can")
			cyborg_base_icon = "canjan"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavyres"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Bootyborg")
			cyborg_base_icon = "bootyjanitor"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootyjanitor"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Protectron")
			cyborg_base_icon = "protectron_janitor"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Miss m")
			cyborg_base_icon = "missm_janitor"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		//Dogborgs
		if("Scrubpuppy")
			cyborg_base_icon = "scrubpup"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Otie")
			cyborg_base_icon = "otiej"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Drake")
			cyborg_base_icon = "drakejanit"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		else
			return FALSE
	return ..()

//CLOWN
/obj/item/robot_module/clown/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/clown_icons = sortList(list(
		"Default" = image(icon = 'icons/mob/robots.dmi', icon_state = "clown"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootyclown"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootyclown"),
		"Marina" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "marina_mommy"),
		"Garish" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "garish"),
		"Robot" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "clownbot"),
		"Sleek" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "clownman")
		))
	var/clown_borg_icon = show_radial_menu(cyborg, cyborg , clown_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(clown_borg_icon)
		if("Default")
			cyborg_base_icon = "clown"
		if("Bootyborg")
			cyborg_base_icon = "bootyclown"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootyclown"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marina_mommy"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		if("Garish")
			cyborg_base_icon = "garish"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Robot")
			cyborg_base_icon = "clownbot"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Sleek")
			cyborg_base_icon = "clownman"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		else
			return FALSE
	return ..()

//SERVICE
/obj/item/robot_module/butler/skyrat
	name = "Skyrat Service"
	special_light_key = null

/obj/item/robot_module/butler/skyrat/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/service_icons
	if(!service_icons)
		service_icons = list(
		"Waitress" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_f"),
		"Butler" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_m"),
		"Bro" = image(icon = 'icons/mob/robots.dmi', icon_state = "brobot"),
		"Can" = image(icon = 'icons/mob/robots.dmi', icon_state = "kent"),
		"Tophat" = image(icon = 'icons/mob/robots.dmi', icon_state = "tophat"),
		"Sleek" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "sleekserv"),
		"Heavy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "heavyserv"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootyservice"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootyservice"),
		"Protectron" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "protectron_service"),
		"Miss m" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "missm_service"),
		)
		var/list/L = list("DarkK9" = "k50", "Vale" = "valeserv", "ValeDark" = "valeservdark", "Fabulous" = "k69")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			service_icons[a] = wide
		service_icons = sortList(service_icons)
	var/service_robot_icon = show_radial_menu(cyborg, cyborg , service_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(service_robot_icon)
		if("Waitress")
			cyborg_base_icon = "service_f"
			special_light_key = "service"
		if("Butler")
			cyborg_base_icon = "service_m"
			special_light_key = "service"
		if("Bro")
			cyborg_base_icon = "brobot"
			special_light_key = "service"
		if("Can")
			cyborg_base_icon = "kent"
			special_light_key = "medical"
			hat_offset = 3
		if("Tophat")
			cyborg_base_icon = "tophat"
			special_light_key = null
			hat_offset = INFINITY
		if("Sleek")
			cyborg_base_icon = "sleekserv"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavyserv"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Bootyborg")
			cyborg_base_icon = "bootyservice"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootyservice"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Protectron")
			cyborg_base_icon = "protectron_service"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Miss m")
			cyborg_base_icon = "missm_service"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		//Dogborgs
		if("DarkK9")
			cyborg_base_icon = "k50"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valeserv"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("ValeDark")
			cyborg_base_icon = "valeservdark"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Fabulous")
			cyborg_base_icon = "k69"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		else
			return FALSE
	return TRUE

//MINING
/obj/item/robot_module/miner/skyrat
	name = "Skyrat Miner"
	special_light_key = null

/obj/item/robot_module/miner/skyrat/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/mining_icons
	if(!mining_icons)
		mining_icons = list(
		"Lavaland" = image(icon = 'icons/mob/robots.dmi', icon_state = "miner"),
		"Asteroid" = image(icon = 'icons/mob/robots.dmi', icon_state = "minerOLD"),
		"Droid" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "miner"),
		"Sleek" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "sleekmin"),
		"Marina" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "marinamin"),
		"Can" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "canmin"),
		"Heavy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "heavymin"),
		"Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootyminer"),
		"Male Bootyborg" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootyminer"),
		"Protectron" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "protectron_miner"),
		"Miss m" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "missm_miner"),
		"Zoomba" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "zoomba_miner"),
		"Drake" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = "drakeminebox")
		)
		var/list/L = list("Blade" = "blade", "Vale" = "valemine")
		for(var/a in L)
			var/image/wide = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi', icon_state = L[a])
			wide.pixel_x = -16
			mining_icons[a] = wide
		mining_icons = sortList(mining_icons)
	var/mining_borg_icon = show_radial_menu(cyborg, cyborg , mining_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(mining_borg_icon)
		if("Lavaland")
			cyborg_base_icon = "miner"
		if("Asteroid")
			cyborg_base_icon = "minerOLD"
			special_light_key = "miner"
		if("Droid")
			cyborg_base_icon = "miner"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			hat_offset = 4
		if("Sleek")
			cyborg_base_icon = "sleekmin"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Can")
			cyborg_base_icon = "canmin"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Marina")
			cyborg_base_icon = "marinamin"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Spider")
			cyborg_base_icon = "spidermin"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "heavymin"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Bootyborg")
			cyborg_base_icon = "bootyminer"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Bootyborg")
			cyborg_base_icon = "male_bootyminer"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Protectron")
			cyborg_base_icon = "protectron_miner"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Miss m")
			cyborg_base_icon = "missm_miner"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Zoomba")
			cyborg_base_icon = "zoomba_miner"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
			has_snowflake_deadsprite = TRUE
		//Dogborgs
		if("Blade")
			cyborg_base_icon = "blade"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Vale")
			cyborg_base_icon = "valemine"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		if("Drake")
			cyborg_base_icon = "drakemine"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/widerobot.dmi'
			dogborg = TRUE
		else
			return FALSE
	return TRUE

//SYNDICATE
/obj/item/robot_module/syndicatejack
	name = "Syndicate"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/extinguisher,
		/obj/item/weldingtool/experimental,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/lightreplacer/cyborg,
		/obj/item/stack/sheet/metal,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel,
		/obj/item/stack/cable_coil,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/stack/medical/gauze,
		/obj/item/shockpaddles/cyborg,
		/obj/item/healthanalyzer/advanced,
		/obj/item/retractor/advanced,
		/obj/item/surgicaldrill,
		/obj/item/scalpel/advanced,
		/obj/item/gun/medbeam,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/borg/lollipop,
		/obj/item/holosign_creator/cyborg,
		/obj/item/stamp/chameleon,
		)
	cyborg_base_icon = "synd_engi"
	moduleselect_icon = "malf"
	magpulsing = TRUE
	hat_offset = INFINITY
	canDispose = TRUE

/obj/item/robot_module/syndicatejack/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/static/list/syndicatejack_icons = sortList(list(
		"Saboteur" = image(icon = 'icons/mob/robots.dmi', icon_state = "synd_engi"),
		"Medical" = image(icon = 'icons/mob/robots.dmi', icon_state = "synd_medical"),
		"Assault" = image(icon = 'icons/mob/robots.dmi', icon_state = "synd_sec"),
		"Heavy" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "syndieheavy"),
		"Miss m" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "missm_syndie"),
		"Spider" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "spidersyndi"),
		"Booty Striker" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootynukie"),
		"Booty Syndicate" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "bootysyndie"),
		"Male Booty Striker" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootynukie"),
		"Male Booty Syndicate" = image(icon = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi', icon_state = "male_bootysyndie"),
		))
	var/syndiejack_icon = show_radial_menu(cyborg, cyborg , syndicatejack_icons, custom_check = CALLBACK(src, .proc/check_menu, cyborg, old_module), radius = 42, require_near = TRUE)
	switch(syndiejack_icon)
		if("Saboteur")
			cyborg_base_icon = "synd_engi"
			cyborg_icon_override = 'icons/mob/robots.dmi'
		if("Medical")
			cyborg_base_icon = "synd_medical"
			cyborg_icon_override = 'icons/mob/robots.dmi'
		if("Assault")
			cyborg_base_icon = "synd_sec"
			cyborg_icon_override = 'icons/mob/robots.dmi'
		if("Heavy")
			cyborg_base_icon = "syndieheavy"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Miss m")
			cyborg_base_icon = "missm_syndie"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Spider")
			cyborg_base_icon = "spidersyndi"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Booty Striker")
			cyborg_base_icon = "bootynukie"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Booty Syndicate")
			cyborg_base_icon = "bootysyndie"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Booty Striker")
			cyborg_base_icon = "male_bootynukie"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		if("Male Booty Syndicate")
			cyborg_base_icon = "male_bootysyndie"
			cyborg_icon_override = 'modular_skyrat/modules/altborgs/icons/mob/robots.dmi'
		//Dogborgs

		else
			return FALSE
	return ..()

//Stray dog
