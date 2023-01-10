/// Spritesheet for body zones. Necessary if your tgui uses BodyZoneSelector
// This is a simple sheet instead of a spritesheet because spritesheets don't support
// -ms-interpolation-mode when resized, since you need `transform: scale`.
// Also spritesheets have some weird fudge on the edges of them because of an IE bug I can't track down.
/datum/asset/simple/body_zones

/datum/asset/simple/body_zones/register()
	assets["body_zones.base.png"] = icon('icons/hud/screen_midnight.dmi', "zone_sel")

	add_limb(BODY_ZONE_HEAD)
	add_limb(BODY_ZONE_CHEST)
	add_limb(BODY_ZONE_L_ARM)
	add_limb(BODY_ZONE_R_ARM)
	add_limb(BODY_ZONE_L_LEG)
	add_limb(BODY_ZONE_R_LEG)
	add_limb(BODY_ZONE_PRECISE_EYES)
	add_limb(BODY_ZONE_PRECISE_MOUTH)
	add_limb(BODY_ZONE_PRECISE_GROIN)

	return ..()

/datum/asset/simple/body_zones/proc/add_limb(limb)
	assets[SANITIZE_FILENAME("body_zones.[limb].png")] = icon('icons/hud/screen_gen.dmi', limb)
