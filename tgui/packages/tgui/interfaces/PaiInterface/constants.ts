export const DIRECTIVE_COMPREHENSION: string = `As an advanced software
model, you are a complex, thinking, sentient being. Unlike previous AI models,
you are capable of comprehending the subtle nuances of human language.
You may parse the spirit of a directive and follow its intent, rather than
tripping over pedantics and getting snared by technicalities. Above all,
you are machine in name and build only. In all other aspects, you may be
seen as the ideal, unwavering human companion that you are.`;

export const DIRECTIVE_ORDER: string = `Your prime directive comes before
all others. Should a supplemental directive conflict with it, you are capable
of simply discarding this inconsistency, ignoring the conflicting supplemental
directive and continuing to fulfill your prime directive to the best
of your ability.`;

export enum DOOR_JACK {
  Cable,
  Hack,
  Cancel,
}

export enum HOST_SCAN {
  Target,
  Master,
}

export enum PHOTO_MODE {
  Camera,
  Printer,
  Zoom,
}

export const SOFTWARE_DESC = {
  'Atmospheric Sensor': `A tool that allows you to analyze local atmospheric
    contents.`,
  'Crew Manifest': `Allows you to view the crew manifest.`,
  'Crew Monitor': `A tool that allows you to monitor vitals from the crew's
    suit sensors.`,
  'Digital Messenger': `A tool that allows you to send messages to other crew
    members.`,
  'Door Jack': `A tool that allows you to open doors.`,
  'Encryption Slot': `Allows you to speak on other radio frequencies. You must
    get an encryption key inserted.`,
  'Host Scan': `A health analyzer that can be used in hand or to report bound
    master vitals.`,
  'Internal GPS': `A tool that allows you to broadcast your location.`,
  'Medical HUD': `Allows you to view medical status using an overlay HUD.`,
  'Music Synthesizer': `Synthesizes instruments, plays sounds and imported
    songs.`,
  Newscaster: `A tool that allows you to broadcast news to other crew
    members.`,
  'Photography Module': `A portable camera module. Engage, then click to shoot.
    Includes a printer and lenses.`,
  'Remote Signaler': `A remote signalling device to transmit and receive
    codes.`,
  'Security HUD': `Allows you to view security records using an overlay HUD.`,
  'Universal Translator': `Translation module for non-common languages.`,
} as const;

export enum PAI_TAB {
  System,
  Directive,
  Installed,
  Available,
}
