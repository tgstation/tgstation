/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const MAX_VISIBLE_MESSAGES = 2500;
export const MAX_PERSISTED_MESSAGES = 1000;
export const MESSAGE_SAVE_INTERVAL = 10000;
export const MESSAGE_PRUNE_INTERVAL = 60000;
export const COMBINE_MAX_MESSAGES = 5;
export const COMBINE_MAX_TIME_WINDOW = 5000;
export const IMAGE_RETRY_DELAY = 250;
export const IMAGE_RETRY_LIMIT = 10;
export const IMAGE_RETRY_MESSAGE_AGE = 60000;

export const MESSAGE_TYPES = [
  // Always-on types
  {
    type: 'system',
    name: 'System Messages',
    description: 'Messages from your client, always enabled',
    selector: '.boldannounce, .filter_system',
    important: true,
  },
  // Basic types
  {
    type: 'localchat',
    name: 'Local',
    description: 'In-character local messages (say, emote, etc)',
    selector: '.filter_say, .say, .emote',
  },
  {
    type: 'radio',
    name: 'Radio',
    description: 'All departments of radio messages',
    selector: '.filter_radio, .alert, .syndradio, .centradio, .airadio, .entradio, .comradio, .secradio, .engradio, .medradio, .sciradio, .supradio, .srvradio, .expradio, .radio, .deptradio, .newscaster',
  },
  {
    type: 'info',
    name: 'Info',
    description: 'Non-urgent messages from the game and items',
    selector: '.filter_notice, .notice:not(.pm), .adminnotice, .info, .sinister, .cult',
  },
  {
    type: 'warning',
    name: 'Warnings',
    description: 'Urgent messages from the game and items',
    selector: '.filter_warning, .warning:not(.pm), .critical, .userdanger, .italics',
  },
  {
    type: 'deadchat',
    name: 'Deadchat',
    description: 'All of deadchat',
    selector: '.filter_deadsay, .deadsay',
  },
  {
    type: 'ooc',
    name: 'OOC',
    description: 'The bluewall of global OOC messages',
    selector: '.filter_ooc, .ooc, .adminooc',
  },
  {
    type: 'adminpm',
    name: 'Admin PMs',
    description: 'Messages to/from admins (adminhelp)',
    selector: '.filter_pm, .pm',
  },
  {
    type: 'combat',
    name: 'Combat Log',
    description: 'Urist McTraitor has stabbed you with a knife!',
    selector: '.filter_combat, .danger',
  },
  {
    type: 'unknown',
    name: 'Unsorted',
    description: 'Everything we could not sort, always enabled',
  },
  // Admin stuff
  {
    type: 'adminchat',
    name: 'Admin Chat',
    description: 'ASAY messages',
    selector: '.filter_ASAY, .admin_channel',
    admin: true,
  },
  {
    type: 'modchat',
    name: 'Mod Chat',
    description: 'MSAY messages',
    selector: '.filter_MSAY, .mod_channel',
    admin: true,
  },
  {
    type: 'eventchat',
    name: 'Event Chat',
    description: 'ESAY messages',
    selector: '.filter_ESAY, .event_channel',
    admin: true,
  },
  {
    type: 'adminlog',
    name: 'Admin Log',
    description: 'ADMIN LOG: Urist McAdmin has jumped to coordinates X, Y, Z',
    selector: '.filter_adminlog, .log_message',
    admin: true,
  },
  {
    type: 'attacklog',
    name: 'Attack Log',
    description: 'Urist McTraitor has shot John Doe',
    selector: '.filter_attacklog',
    admin: true,
  },
  {
    type: 'debuglog',
    name: 'Debug Log',
    description: 'DEBUG: SSPlanets subsystem Recover().',
    selector: '.filter_debuglog',
    admin: true,
  },
];
