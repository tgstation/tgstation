
/datum/hud/proc/unplayer_hud()
	return

/datum/hud/proc/ghost_hud()
	mymob.visible = new /obj/screen()
	mymob.visible.icon = 'icons/mob/screen1_ghost.dmi'
	mymob.visible.icon_state = "visible0"
	mymob.visible.name = "visible"
	mymob.visible.screen_loc = ui_health

	mymob.client.screen = null

	mymob.client.screen += list(mymob.visible)

/datum/hud/proc/corgi_hud(u)
	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = new /obj/screen()
	mymob.pullin.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull

	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.toxin = new /obj/screen()
	mymob.toxin.icon = 'icons/mob/screen1_corgi.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin

	mymob.client.screen = null

	mymob.client.screen += list(mymob.fire, mymob.healths, mymob.pullin, mymob.oxygen, mymob.toxin)

/datum/hud/proc/brain_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')
	mymob.blind = new /obj/screen()
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0

/datum/hud/proc/blob_hud(ui_style = 'icons/mob/screen1_Midnight.dmi')

	blobpwrdisplay = new /obj/screen()
	blobpwrdisplay.name = "blob power"
	blobpwrdisplay.icon_state = "block"
	blobpwrdisplay.screen_loc = ui_health
	blobpwrdisplay.layer = 20

	blobhealthdisplay = new /obj/screen()
	blobhealthdisplay.name = "blob health"
	blobhealthdisplay.icon_state = "block"
	blobhealthdisplay.screen_loc = ui_internal
	blobhealthdisplay.layer = 20

	mymob.client.screen = null

	mymob.client.screen += list(blobpwrdisplay, blobhealthdisplay)

/datum/hud/proc/shade_hud()

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_shade.dmi'
	mymob.healths.icon_state = "shade_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health

	mymob.pullin = new /obj/screen()
	mymob.pullin.icon = 'icons/mob/screen1_shade.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull

	mymob.purged = new /obj/screen()
	mymob.purged.icon = 'icons/mob/screen1_shade.dmi'
	mymob.purged.icon_state = "purge0"
	mymob.purged.name = "purged"
	mymob.purged.screen_loc = ui_construct_purge

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen1_shade.dmi'
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.client.screen = null

	mymob.client.screen += list(mymob.healths, mymob.pullin, mymob.zone_sel, mymob.purged)

/datum/hud/proc/construct_hud()
	var/constructtype

	if(istype(mymob,/mob/living/simple_animal/construct/armoured) || istype(mymob,/mob/living/simple_animal/construct/behemoth))
		constructtype = "juggernaut"
	else if(istype(mymob,/mob/living/simple_animal/construct/builder))
		constructtype = "artificer"
	else if(istype(mymob,/mob/living/simple_animal/construct/wraith))
		constructtype = "wraith"
	else if(istype(mymob,/mob/living/simple_animal/construct/harvester))
		constructtype = "harvester"

	if(constructtype)
		mymob.fire = new /obj/screen()
		mymob.fire.icon = 'icons/mob/screen1_construct.dmi'
		mymob.fire.icon_state = "fire0"
		mymob.fire.name = "fire"
		mymob.fire.screen_loc = ui_construct_fire

		mymob.healths = new /obj/screen()
		mymob.healths.icon = 'icons/mob/screen1_construct.dmi'
		mymob.healths.icon_state = "[constructtype]_health0"
		mymob.healths.name = "health"
		mymob.healths.screen_loc = ui_construct_health

		mymob.pullin = new /obj/screen()
		mymob.pullin.icon = 'icons/mob/screen1_construct.dmi'
		mymob.pullin.icon_state = "pull0"
		mymob.pullin.name = "pull"
		mymob.pullin.screen_loc = ui_construct_pull

		mymob.zone_sel = new /obj/screen/zone_sel()
		mymob.zone_sel.icon = 'icons/mob/screen1_construct.dmi'
		mymob.zone_sel.overlays.Cut()
		mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

		mymob.purged = new /obj/screen()
		mymob.purged.icon = 'icons/mob/screen1_construct.dmi'
		mymob.purged.icon_state = "purge0"
		mymob.purged.name = "purged"
		mymob.purged.screen_loc = ui_construct_purge

	mymob.client.screen = null

	mymob.client.screen += list(mymob.fire, mymob.healths, mymob.pullin, mymob.zone_sel, mymob.purged)

	switch(constructtype)
		if("artificer")
			mymob.construct_spell1 = new /obj/screen()
			mymob.construct_spell1.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell1.icon_state = "spell_wall"
			mymob.construct_spell1.name = "wall"
			mymob.construct_spell1.screen_loc = ui_construct_spell1

			mymob.construct_spell2 = new /obj/screen()
			mymob.construct_spell2.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell2.icon_state = "spell_soulstone"
			mymob.construct_spell2.name = "soulstone"
			mymob.construct_spell2.screen_loc = ui_construct_spell2

			mymob.construct_spell3 = new /obj/screen()
			mymob.construct_spell3.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell3.icon_state = "spell_floor"
			mymob.construct_spell3.name = "floor"
			mymob.construct_spell3.screen_loc = ui_construct_spell3

			mymob.construct_spell4 = new /obj/screen()
			mymob.construct_spell4.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell4.icon_state = "spell_shell"
			mymob.construct_spell4.name = "shell"
			mymob.construct_spell4.screen_loc = ui_construct_spell4

			mymob.construct_spell5 = new /obj/screen()
			mymob.construct_spell5.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell5.icon_state = "spell_pylon"
			mymob.construct_spell5.name = "pylon"
			mymob.construct_spell5.screen_loc = ui_construct_spell5

			mymob.client.screen += list(mymob.construct_spell1, mymob.construct_spell2, mymob.construct_spell3, mymob.construct_spell4, mymob.construct_spell5)

		if("wraith")
			mymob.construct_spell1 = new /obj/screen()
			mymob.construct_spell1.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell1.icon_state = "spell_shift"
			mymob.construct_spell1.name = "shift"
			mymob.construct_spell1.screen_loc = ui_construct_spell1

			mymob.client.screen += mymob.construct_spell1

		if("juggernaut")
			mymob.construct_spell1 = new /obj/screen()
			mymob.construct_spell1.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell1.icon_state = "spell_juggerwall"
			mymob.construct_spell1.name = "juggerwall"
			mymob.construct_spell1.screen_loc = ui_construct_spell1

			mymob.client.screen += mymob.construct_spell1

		if("harvester")
			mymob.construct_spell1 = new /obj/screen()
			mymob.construct_spell1.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell1.icon_state = "spell_rune"
			mymob.construct_spell1.name = "rune"
			mymob.construct_spell1.screen_loc = ui_construct_spell1

			mymob.construct_spell2 = new /obj/screen()
			mymob.construct_spell2.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell2.icon_state = "spell_breakdoor"
			mymob.construct_spell2.name = "breakdoor"
			mymob.construct_spell2.screen_loc = ui_construct_spell2

			mymob.construct_spell3 = new /obj/screen()
			mymob.construct_spell3.icon = 'icons/mob/screen1_construct.dmi'
			mymob.construct_spell3.icon_state = "spell_harvest"
			mymob.construct_spell3.name = "harvest"
			mymob.construct_spell3.screen_loc = ui_construct_spell3

			mymob.client.screen += list(mymob.construct_spell1, mymob.construct_spell2, mymob.construct_spell3)

