/proc/tg_ui_icon_to_cit_ui(ui_style)
	switch(ui_style)
		if('icons/mob/screen_plasmafire.dmi')
			return 'modular_citadel/icons/ui/screen_plasmafire.dmi'
		if('icons/mob/screen_slimecore.dmi')
			return 'modular_citadel/icons/ui/screen_slimecore.dmi'
		if('icons/mob/screen_operative.dmi')
			return 'modular_citadel/icons/ui/screen_operative.dmi'
		if('icons/mob/screen_clockwork.dmi')
			return 'modular_citadel/icons/ui/screen_clockwork.dmi'
		else
			return 'modular_citadel/icons/ui/screen_midnight.dmi'
