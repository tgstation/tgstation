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
directive and continuing to fulfillyour prime directive to the best
of your ability.`;

export const ICON_MAP = {
  'angry': 'angry',
  'cat': 'cat',
  'extremely-happy': 'grin-beam',
  'face': 'grin-alt',
  'happy': 'smile',
  'laugh': 'grin-tears',
  'null': 'meh',
  'off': 'meh-blank',
  'sad': 'sad-cry',
  'sunglasses': 'sun',
  'what': 'frown-open',
} as const;

export const SOFTWARE_DESC = {
  'Atmospheric Sensor': `A tool that allows you to analyze local atmospheric
    contents.`,
  'Crew Manifest': `Allows you to view the crew manifest.`,
  'Digital Messenger': `A tool that allows you to send messages to other crew
    members.`,
  'Door Jack': `A tool that allows you to open doors.`,
  'Encryption Slot': `Allows you to speak on other radio frequencies. You must
    get an encryption key inserted.`,
  'Host Scan': `A health analyzer that can be used in hand or to report bound
    master vitals.`,
  'Internal GPS': `A tool that allows you to broadcast your location.`,
  'Medical HUD': `Allows you to view medical status using an overlay HUD.`,
  'Medical Records': `A tool that allows you to view station medical records.`,
  'Music Synthesizer': `Synthesizes instruments, plays sounds and imported
    songs.`,
  'Newscaster': `A tool that allows you to broadcast news to other crew
    members.`,
  'Photography Module': `A portable camera module. Engage, then click to shoot.
    Includes a printer and lenses.`,
  'Remote Signaler': `A remote signalling device to transmit and receive
    codes.`,
  'Security HUD': `Allows you to view security records using an overlay HUD.`,
  'Security Records': `Provides access to wanted status and reported crimes.`,
  'Universal Translator': `Translation module for non-common languages.`,
} as const;

export enum TAB {
  System,
  Directive,
  Installed,
  Available,
}
