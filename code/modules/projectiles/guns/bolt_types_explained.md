# Balistic gun icon states explained


For a unknown period of time, `/obj/item/gun/ballistic` used the wrong icon state for its `bolt_type` and so, if you tried to copy how it worked to make your own gun, you'd get a broken sprite.  This documentation is intended to explain in detail what some of the variables and functions do, and how to make your own gun subtypes that work properly.

## Bolt Types
The easiest thing to screw up.  For a long time, `/obj/item/gun/ballistic` had `bolt_type` set to `BOLT_TYPE_STANDARD` when the sprite was configured to use `BOLT_TYPE_LOCKING` sprites.  Nobody noticed, because it wasn't obtainable through normal gameplay, and the Mosin which was broken by it only has like 3 pixels missing.


### BOLT_TYPE_STANDARD
This is for guns that don't lock their slides back.  Visually, it usually means guns that have an internal bolt that isn't visible, like the c20r or ARG Boarder.  The base icon state is all you need to make it work.

### BOLT_TYPE_OPEN
Pretty much like the Standard, but it takes rounds directly from the magazine without holding them in the chaimber first.  This means that when you remove the mag, there isn't going to still be a bullet in the chaimber.

### BOLT_TYPE_NO_BOLT
This is your revolvers and some(?) break action shotguns.  When you click to reload them, they'll drop all the bullets inside of the gun, unspent or not.

### BOLT_TYPE_LOCKING
The complicated one.  This is what most pistols and bolt action rifles are.  When you cycle (or fire) it on empty, it will lock back the slide, and you'll have to click it again to send the slide home.  For rifles with `semi_auto = FALSE`, they don't feed automatically, so you have to rack the slide after every shot.  (Like the Mosin)

Now, for the sprites, your base sprite should be the gun without a slide or bolt.  Take a look at the APS, deagle, or Mosin sprites.  If your icon state is `handcannon` you need to have a sprite for the slide as `handcannon_bolt`, and then a sprite for the bolt being locked back as `handcannon_bolt_locked`.

## Sawing off
For guns that have `can_be_sawn_off = TRUE`, you'll need to make an entire second set of sprites.  For `BOLT_TYPE_LOCKING`, this will look like the Mosin.  If you're making a sawn off version of `handcannon`, you'll need `hancannon_sawn` for the base, and then `hancannon_sawn_bolt` and `hancannon_sawn_bolt_locked`.

## Ammo display
You'll need `mag_display = TRUE` and a sprite called `handcannon_mag` to show the gun as having a magazine inserted into it.  It's set to true by default, though.

Perhaps you want to make some kind visual depiction of ammunition feed.  You can overlay over top of the magazine sprite of 100%, 80%, 60%, 40%, and 20% by having `mag_display_ammo = TRUE`.  Use `handcannon_mag_100`, `handcannon_mag_80`, ect... to display these.    There is no zero.  You can use a overlaying sprite for showing the gun as empty called `handcannon_empty`.  Take a look at the c20r as an example.


