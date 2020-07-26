import { createUuid } from 'common/uuid';

export const MESSAGE_TYPES = [
  {
    type: 'localchat',
    name: 'Local Chat',
    description: 'In-character local messages (say, emote, etc)',
    selector: '.filter_say, .say, .emote',
    important: false,
  },
  {
    type: 'radio',
    name: 'Radio Comms',
    description: 'All departments of radio messages',
    selector: '.filter_radio, .alert, .syndradio, .centradio, .airadio, .entradio, .comradio, .secradio, .engradio, .medradio, .sciradio, .supradio, .srvradio, .expradio, .radio, .deptradio, .newscaster',
    important: false,
  },
  {
    type: 'info',
    name: 'Informational',
    description: 'Non-urgent messages from the game and items',
    selector: '.filter_notice, .notice:not(.pm), .adminnotice, .info, .sinister, .cult',
    important: false,
  },
  {
    type: 'warnings',
    name: 'Warnings',
    description: 'Urgent messages from the game and items',
    selector: '.filter_warning, .warning:not(.pm), .critical, .userdanger, .italics',
    important: false,
  },
  {
    type: 'deadchat',
    name: 'Deadchat',
    description: 'All of deadchat',
    selector: '.filter_deadsay, .deadsay',
    important: false,
  },
  {
    type: 'globalooc',
    name: 'Global OOC',
    description: 'The bluewall of global OOC messages',
    selector: '.filter_ooc, .ooc:not(.looc)',
    important: false,
  },
  {
    type: 'adminpm',
    name: 'Admin PMs',
    description: 'Messages to/from admins (adminhelp)',
    selector: '.filter_pm, .pm',
    important: false,
  },
  {
    type: 'adminchat',
    name: 'Admin Chat',
    description: 'ASAY messages',
    selector: '.filter_ASAY, .admin_channel',
    important: false,
    admin: true,
  },
  {
    type: 'modchat',
    name: 'Mod Chat',
    description: 'MSAY messages',
    selector: '.filter_MSAY, .mod_channel',
    important: false,
    admin: true,
  },
  {
    type: 'eventchat',
    name: 'Event Chat',
    description: 'ESAY messages',
    selector: '.filter_ESAY, .event_channel',
    important: false,
    admin: true,
  },
  {
    type: 'combat',
    name: 'Combat Logs',
    description: 'Urist McTraitor has stabbed you with a knife!',
    selector: '.filter_combat, .danger',
    important: false,
  },
  {
    type: 'adminlogs',
    name: 'Admin Logs',
    description: 'ADMIN LOG: Urist McAdmin has jumped to coordinates X, Y, Z',
    selector: '.filter_adminlogs, .log_message',
    important: false,
    admin: true,
  },
  {
    type: 'attacklogs',
    name: 'Attack Logs',
    description: 'Urist McTraitor has shot John Doe',
    selector: '.filter_attacklogs',
    important: false,
    admin: true,
  },
  {
    type: 'debuglogs',
    name: 'Debug Logs',
    description: 'DEBUG: SSPlanets subsystem Recover().',
    selector: '.filter_debuglogs',
    important: false,
    admin: true,
  },
  {
    type: 'looc',
    name: 'Local OOC',
    description: 'Local OOC messages, always enabled',
    selector: '.ooc.looc, .ooc, .looc',
    important: true,
  },
  {
    type: 'system',
    name: 'System Messages',
    description: 'Messages from your client, always enabled',
    selector: '.boldannounce, .filter_system',
    important: true,
  },
  {
    type: 'unknown',
    name: 'Unsorted Messages',
    description: 'Everything we could not sort, always enabled',
    important: true,
  },
];

export const DEFAULT_PAGE = {
  id: createUuid(),
  name: 'Main',
  acceptedTypes: (() => {
    const obj = {};
    for (let typeDef of MESSAGE_TYPES) {
      obj[typeDef.type] = true;
    }
    return obj;
  })(),
  count: 0,
};
