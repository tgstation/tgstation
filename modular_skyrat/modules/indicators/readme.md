## Title: Indicators

MODULE ID: INDICATORS

### Description:

The compilation of all player indicators (CI, SSD, Typing)
Combat Indicator - Toggleable by players, declares intent to engage in combat
SSD Indicator - Automatically shows when a player has disconnected
Typing Indicator - Shows when a player is typing

### TG Proc Changes:
Combat Indicator
 - ADDITION: code/modules/mob/living/death.dm > /mob/living/death()
 - CHANGE: code/datums/keybinding/mob.dm > /datum/keybinding/mob/toggle_move_intent()
Typing Indicator
 - APPEND: code/modules/keybindings/setup.dm > /datum/proc/key_down()
 - ADDITION: code/onclick/_click.dm > /mob/proc/ClickOn() 
 - ADDITION: code/modules/mob/mob_say.dm > /mob/verb/say_verb(), /mob/verb/me_verb()
 - CHANGE: code\modules\mob\living\living_say.dm > /mob/living/send_speech
 - ADDITION: code/modules/mob/living/death.dm > /mob/living/death()
SSD Indicator
 ./code/modules/mob/living/carbon/human/examine.dm > /mob/living/carbon/human/examine()
 - ADDITION: code/modules/mob/living/death.dm > /mob/living/death()

### Defines:

N/A

### Included files:

N/A

### Credits:

Azarak - Porting and OG code for Combat Indicator, Typing Indicator, SSD Indicator
FlamingLily - Consolidation, surrender alert
