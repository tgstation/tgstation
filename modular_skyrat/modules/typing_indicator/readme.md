## Title: Typing Indicator

MODULE ID: TYPING_INDICATOR

### Description:

Adds an asynchronously tracked typing indicator, which shows a typing bubble with an animation.
Added in a hacky way to make it very smooth on the user's end. It registers "T" and "M" keypresses for the indicator to popup, and makes it gone on mouse click, or say/emote send

### TG Proc Changes:

 - APPEND: code/modules/keybindings/setup.dm > /datum/proc/key_down()
 - ADDITION: code/onclick/_click.dm > /mob/proc/ClickOn() 
 - ADDITION: code/modules/mob/mob_say.dm > /mob/verb/say_verb(), /mob/verb/me_verb()
 - CHANGE: code\modules\mob\living\living_say.dm > /mob/living/send_speech

### Defines:

N/A

### Included files:

N/A

### Credits:

Azarak
