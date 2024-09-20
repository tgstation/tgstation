## Title: More verbs and subtler.

MODULE ID: VERBS

### Description:

Adds the following new verbs:
- LOOC: OOC with a default range of 7 tiles.
- LOOC (Wallpierce): Like LOOC but a wall piercing version.
- Subtle (Anti-Ghost): Like Me but invisible to ghosts. Range can be 1 tile, choosing a character in this range or same tile.
- Do: Like Me but not centered on character. Perfect for narrations. Default range of 7 tiles.
- Do (Longer): Like Do but in a TGUI format.

Adds keybinds for LOOC, Do, Do (Longer) and Whisper.

### TG Proc Changes:

| proc                                                  | file                                          |
| ----------------------------------------------------- | --------------------------------------------- |
| `/proc/cmd_admin_mute(whom, mute_type, automute = 0)` | `code\modules\admin\verbs\admin.dm`           |
| `ADMIN_VERB_ONLY_CONTEXT_MENU(..., ..., ..., ...)`    | `code\modules\admin\verbs\admingame.dm`       |
| `/datum/tgui_say/proc/open(payload)`                  | `code\modules\tgui_input\say_modal\modal.dm`  |
| `/datum/tgui_say/proc/alter_entry(payload)`           | `code\modules\tgui_input\say_modal\speech.dm` |

### Defines:

- `code\__DEFINES\~doppler_defines\admin.dm` looc mute
- `code\__DEFINES\~doppler_defines\banning.dm` looc ban define
- `code\__DEFINES\~doppler_defines\keybindings.dm` looc, whisper and do keybinds
- `code\__DEFINES\~doppler_defines\logging.dm` subtle log define
- `code\__DEFINES\~doppler_defines\say.dm` looc range define
- `code\__DEFINES\~doppler_defines\span.dm` looc(wallpierce), do, subtle and span defines
- `code\__DEFINES\~doppler_defines\speech_channels.dm` looc, whis and do channel defines


### Included files that are not contained in this module:

- `code\__HELPERS\logging\_logging.dm` subtle logging
- `code\__HELPERS\logging\mob.dm` subtle messages readibility for admins
- `code\__HELPERS\~doppler_helpers\chat.dm` subtle formatting helper
- `code\__HELPERS\~doppler_helpers\logging.dm` subtle helper for logging
- `code\__HELPERS\~doppler_helpers\verbs.dm` looc range hearing helper
- `code\_globalvars\~doppler_globalvars\configuration.dm` looc configuration global var init
- `code\modules\admin\sql_ban_system.dm` looc ban option in admin banning panel
- `code\modules\admin\verbs\admingame.dm` looc mute message
- `modular_doppler\administration\code\preferences.dm` toggle admin preference datum
- `tgui\packages\tgui\interfaces\PreferencesMenu\preferences\features\dopplershift_preferences\looc.tsx` looc preferences visual components
- `tgui\packages\tgui-panel\chat\constants.ts`
- `tgui\packages\tgui-panel\styles\tgchat\chat-dark.scss` multiple font colors for dark theme
- `tgui\packages\tgui-panel\styles\tgchat\chat-light.scss` multiple font colors for light theme
- `tgui\packages\tgui-say\ChannelIterator.test.ts` whis, looc and do channel cycler test
- `tgui\packages\tgui-say\ChannelIterator.ts` whis, looc and do channel types and channel iterators
- `tgui\packages\tgui-say\styles\colors.scss` whis, looc and do font colors

### Credits:
Gandalf2k15 - porting and refactoring
yooriss - do verb
Kaostico - edition
