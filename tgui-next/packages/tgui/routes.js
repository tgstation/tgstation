import { Achievements } from './interfaces/Achievements';
import { AiAirlock } from './interfaces/AiAirlock';
import { AirAlarm } from './interfaces/AirAlarm';
import { AirlockElectronics } from './interfaces/AirlockElectronics';
import { Apc } from './interfaces/Apc';
import { AtmosAlertConsole } from './interfaces/AtmosAlertConsole';
import { AtmosControlConsole } from './interfaces/AtmosControlConsole';
import { AtmosFilter } from './interfaces/AtmosFilter';
import { AtmosMixer } from './interfaces/AtmosMixer';
import { AtmosPump } from './interfaces/AtmosPump';
import { BankMachine } from './interfaces/BankMachine';
import { BlackmarketUplink } from './interfaces/BlackmarketUplink';
import { BluespaceArtillery } from './interfaces/BluespaceArtillery';
import { Bepis } from './interfaces/Bepis';
import { BorgPanel } from './interfaces/BorgPanel';
import { BrigTimer } from './interfaces/BrigTimer';
import { Canister } from './interfaces/Canister';
import { Cargo, CargoExpress } from './interfaces/Cargo';
import { CellularEmporium } from './interfaces/CellularEmporium';
import { CentcomPodLauncher } from './interfaces/CentcomPodLauncher';
import { ChemAcclimator } from './interfaces/ChemAcclimator';
import { ChemDebugSynthesizer } from './interfaces/ChemDebugSynthesizer';
import { ChemDispenser } from './interfaces/ChemDispenser';
import { ChemFilter } from './interfaces/ChemFilter';
import { ChemHeater } from './interfaces/ChemHeater';
import { ChemMaster } from './interfaces/ChemMaster';
import { ChemPress } from './interfaces/ChemPress';
import { ChemReactionChamber } from './interfaces/ChemReactionChamber';
import { ChemSplitter } from './interfaces/ChemSplitter';
import { ChemSynthesizer } from './interfaces/ChemSynthesizer';
import { CodexGigas } from './interfaces/CodexGigas';
import { ComputerFabricator } from './interfaces/ComputerFabricator';
import { Crayon } from './interfaces/Crayon';
import { CrewConsole } from './interfaces/CrewConsole';
import { Cryo } from './interfaces/Cryo';
import { DecalPainter } from './interfaces/DecalPainter';
import { DisposalUnit } from './interfaces/DisposalUnit';
import { DnaVault } from './interfaces/DnaVault';
import { EightBallVote } from './interfaces/EightBallVote';
import { EmergencyShuttleConsole } from './interfaces/EmergencyShuttleConsole';
import { EngravedMessage } from './interfaces/EngravedMessage';
import { Gps } from './interfaces/Gps';
import { GravityGenerator } from './interfaces/GravityGenerator';
import { GulagTeleporterConsole } from './interfaces/GulagTeleporterConsole';
import { GulagItemReclaimer } from './interfaces/GulagItemReclaimer';
import { Holodeck } from './interfaces/Holodeck';
import { ImplantChair } from './interfaces/ImplantChair';
import { Intellicard } from './interfaces/Intellicard';
import { KeycardAuth } from './interfaces/KeycardAuth';
import { LaborClaimConsole } from './interfaces/LaborClaimConsole';
import { LanguageMenu } from './interfaces/LanguageMenu';
import { LaunchpadConsole, LaunchpadRemote } from './interfaces/Launchpad';
import { MechBayPowerConsole } from './interfaces/MechBayPowerConsole';
import { MedicalKiosk } from './interfaces/MedicalKiosk';
import { Mint } from './interfaces/Mint';
import { Mule } from './interfaces/Mule';
import { NaniteChamberControl } from './interfaces/NaniteChamberControl';
import { NaniteCloudControl } from './interfaces/NaniteCloudControl';
import { NaniteProgramHub } from './interfaces/NaniteProgramHub';
import { NaniteProgrammer } from './interfaces/NaniteProgrammer';
import { NaniteRemote } from './interfaces/NaniteRemote';
import { NotificationPreferences } from './interfaces/NotificationPreferences';
import { NtnetRelay } from './interfaces/NtnetRelay';
import { NtosArcade } from './interfaces/NtosArcade';
import { NtosConfiguration } from './interfaces/NtosConfiguration';
import { NtosMain } from './interfaces/NtosMain';
import { NtosNetChat } from './interfaces/NtosNetChat';
import { NtosNetDownloader } from './interfaces/NtosNetDownloader';
import { NtosSupermatterMonitor } from './interfaces/NtosSupermatterMonitor';
import { NtosWrapper } from './interfaces/NtosWrapper';
import { NuclearBomb } from './interfaces/NuclearBomb';
import { OperatingComputer } from './interfaces/OperatingComputer';
import { OreBox } from './interfaces/OreBox';
import { OreRedemptionMachine } from './interfaces/OreRedemptionMachine';
import { Pandemic } from './interfaces/Pandemic';
import { PersonalCrafting } from './interfaces/PersonalCrafting';
import { PortableGenerator } from './interfaces/PortableGenerator';
import { PortablePump, PortableScrubber } from './interfaces/PortableAtmos';
import { PowerMonitor } from './interfaces/PowerMonitor';
import { Radio } from './interfaces/Radio';
import { RapidPipeDispenser } from './interfaces/RapidPipeDispenser';
import { Roulette } from './interfaces/Roulette';
import { SatelliteControl } from './interfaces/SatelliteControl';
import { ScannerGate } from './interfaces/ScannerGate';
import { ShuttleManipulator } from './interfaces/ShuttleManipulator';
import { Signaler } from './interfaces/Signaler';
import { Sleeper } from './interfaces/Sleeper';
import { SlimeBodySwapper } from './interfaces/SlimeBodySwapper';
import { SmartVend } from './interfaces/SmartVend';
import { Smes } from './interfaces/Smes';
import { SmokeMachine } from './interfaces/SmokeMachine';
import { SolarControl } from './interfaces/SolarControl';
import { SpaceHeater } from './interfaces/SpaceHeater';
import { SpawnersMenu } from './interfaces/SpawnersMenu';
import { StationAlertConsole } from './interfaces/StationAlertConsole';
import { SuitStorageUnit } from './interfaces/SuitStorageUnit';
import { Tank } from './interfaces/Tank';
import { TankDispenser } from './interfaces/TankDispenser';
import { ThermoMachine } from './interfaces/ThermoMachine';
import { TurbineComputer } from './interfaces/TurbineComputer';
import { Uplink } from './interfaces/Uplink';
import { VaultController } from './interfaces/VaultController';
import { Vending } from './interfaces/Vending';
import { Wires } from './interfaces/Wires';
import { SyndContractor } from './interfaces/SyndContractor';

const ROUTES = {
  achievements: {
    component: () => Achievements,
    scrollable: true,
  },
  ai_airlock: {
    component: () => AiAirlock,
    scrollable: false,
  },
  airalarm: {
    component: () => AirAlarm,
    scrollable: true,
  },
  airlock_electronics: {
    component: () => AirlockElectronics,
    scrollable: false,
  },
  apc: {
    component: () => Apc,
    scrollable: false,
  },
  atmos_alert: {
    component: () => AtmosAlertConsole,
    scrollable: true,
  },
  atmos_control: {
    component: () => AtmosControlConsole,
    scrollable: true,
  },
  atmos_filter: {
    component: () => AtmosFilter,
    scrollable: false,
  },
  atmos_mixer: {
    component: () => AtmosMixer,
    scrollable: false,
  },
  atmos_pump: {
    component: () => AtmosPump,
    scrollable: false,
  },
  bepis: {
    component: () => Bepis,
    scrollable: false,
  },
  bank_machine: {
    component: () => BankMachine,
    scrollable: false,
  },
  blackmarket_uplink: {
    component: () => BlackmarketUplink,
    scrollable: true,
    theme: 'hackerman',
  },
  borgopanel: {
    component: () => BorgPanel,
    scrollable: true,
  },
  brig_timer: {
    component: () => BrigTimer,
    scrollable: false,
  },
  bsa: {
    component: () => BluespaceArtillery,
    scrollable: false,
  },
  canister: {
    component: () => Canister,
    scrollable: false,
  },
  cargo: {
    component: () => Cargo,
    scrollable: true,
  },
  cargo_express: {
    component: () => CargoExpress,
    scrollable: true,
  },
  cellular_emporium: {
    component: () => CellularEmporium,
    scrollable: true,
  },
  centcom_podlauncher: {
    component: () => CentcomPodLauncher,
    scrollable: false,
  },
  acclimator: {
    component: () => ChemAcclimator,
    scrollable: false,
  },
  chem_dispenser: {
    component: () => ChemDispenser,
    scrollable: true,
  },
  chemical_filter: {
    component: () => ChemFilter,
    scrollable: true,
  },
  chem_heater: {
    component: () => ChemHeater,
    scrollable: true,
  },
  chem_master: {
    component: () => ChemMaster,
    scrollable: true,
  },
  chem_press: {
    component: () => ChemPress,
    scrollable: false,
  },
  reaction_chamber: {
    component: () => ChemReactionChamber,
    scrollable: true,
  },
  chem_splitter: {
    component: () => ChemSplitter,
    scrollable: false,
  },
  chem_synthesizer: {
    component: () => ChemDebugSynthesizer,
    scrollable: false,
  },
  synthesizer: {
    component: () => ChemSynthesizer,
    scrollable: false,
  },
  codex_gigas: {
    component: () => CodexGigas,
    scrollable: false,
  },
  computer_fabricator: {
    component: () => ComputerFabricator,
    scrollable: false,
  },
  crayon: {
    component: () => Crayon,
    scrollable: true,
  },
  crew: {
    component: () => CrewConsole,
    scrollable: true,
  },
  cryo: {
    component: () => Cryo,
    scrollable: false,
  },
  decal_painter: {
    component: () => DecalPainter,
    scrollable: false,
  },
  disposal_unit: {
    component: () => DisposalUnit,
    scrollable: false,
  },
  dna_vault: {
    component: () => DnaVault,
    scrollable: false,
  },
  eightball: {
    component: () => EightBallVote,
    scrollable: false,
  },
  emergency_shuttle_console: {
    component: () => EmergencyShuttleConsole,
    scrollable: false,
  },
  engraved_message: {
    component: () => EngravedMessage,
    scrollable: false,
  },
  gps: {
    component: () => Gps,
    scrollable: true,
  },
  gravity_generator: {
    component: () => GravityGenerator,
    scrollable: false,
  },
  gulag_console: {
    component: () => GulagTeleporterConsole,
    scrollable: false,
  },
  gulag_item_reclaimer: {
    component: () => GulagItemReclaimer,
    scrollable: true,
  },
  holodeck: {
    component: () => Holodeck,
    scrollable: true,
  },
  implantchair: {
    component: () => ImplantChair,
    scrollable: false,
  },
  intellicard: {
    component: () => Intellicard,
    scrollable: true,
  },
  keycard_auth: {
    component: () => KeycardAuth,
    scrollable: false,
  },
  labor_claim_console: {
    component: () => LaborClaimConsole,
    scrollable: false,
  },
  language_menu: {
    component: () => LanguageMenu,
    scrollable: true,
  },
  launchpad_console: {
    component: () => LaunchpadConsole,
    scrollable: true,
  },
  launchpad_remote: {
    component: () => LaunchpadRemote,
    scrollable: false,
    theme: 'syndicate',
  },
  mech_bay_power_console: {
    component: () => MechBayPowerConsole,
    scrollable: false,
  },
  medical_kiosk: {
    component: () => MedicalKiosk,
    scrollable: false,
  },
  mint: {
    component: () => Mint,
    scrollable: false,
  },
  mulebot: {
    component: () => Mule,
    scrollable: false,
  },
  nanite_chamber_control: {
    component: () => NaniteChamberControl,
    scrollable: true,
  },
  nanite_cloud_control: {
    component: () => NaniteCloudControl,
    scrollable: true,
  },
  nanite_program_hub: {
    component: () => NaniteProgramHub,
    scrollable: true,
  },
  nanite_programmer: {
    component: () => NaniteProgrammer,
    scrollable: true,
  },
  nanite_remote: {
    component: () => NaniteRemote,
    scrollable: true,
  },
  notificationpanel: {
    component: () => NotificationPreferences,
    scrollable: true,
  },
  ntnet_relay: {
    component: () => NtnetRelay,
    scrollable: false,
  },
  ntos_arcade: {
    component: () => NtosArcade,
    wrapper: () => NtosWrapper,
    scrollable: false,
    theme: 'ntos',
  },
  ntos_configuration: {
    component: () => NtosConfiguration,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  ntos_main: {
    component: () => NtosMain,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  ntos_net_chat: {
    component: () => NtosNetChat,
    wrapper: () => NtosWrapper,
    scrollable: false,
    theme: 'ntos',
  },
  ntos_net_downloader: {
    component: () => NtosNetDownloader,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  ntos_power_monitor: {
    component: () => PowerMonitor,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  ntos_station_alert: {
    component: () => StationAlertConsole,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  ntos_supermatter_monitor: {
    component: () => NtosSupermatterMonitor,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'ntos',
  },
  nuclear_bomb: {
    component: () => NuclearBomb,
    scrollable: false,
    theme: 'retro',
  },
  ore_redemption_machine: {
    component: () => OreRedemptionMachine,
    scrollable: true,
  },
  ore_box: {
    component: () => OreBox,
    scrollable: true,
  },
  operating_computer: {
    component: () => OperatingComputer,
    scrollable: true,
  },
  pandemic: {
    component: () => Pandemic,
    scrollable: true,
  },
  personal_crafting: {
    component: () => PersonalCrafting,
    scrollable: true,
  },
  portable_generator: {
    component: () => PortableGenerator,
    scrollable: false,
  },
  portable_pump: {
    component: () => PortablePump,
    scrollable: false,
  },
  portable_scrubber: {
    component: () => PortableScrubber,
    scrollable: false,
  },
  power_monitor: {
    component: () => PowerMonitor,
    scrollable: true,
  },
  radio: {
    component: () => Radio,
    scrollable: false,
  },
  roulette: {
    component: () => Roulette,
    scrollable: false,
    theme: 'cardtable',
  },
  rpd: {
    component: () => RapidPipeDispenser,
    scrollable: true,
  },
  sat_control: {
    component: () => SatelliteControl,
    scrollable: false,
  },
  scanner_gate: {
    component: () => ScannerGate,
    scrollable: true,
  },
  shuttle_manipulator: {
    component: () => ShuttleManipulator,
    scrollable: true,
  },
  signaler: {
    component: () => Signaler,
    scrollable: false,
  },
  sleeper: {
    component: () => Sleeper,
    scrollable: false,
  },
  slime_swap_body: {
    component: () => SlimeBodySwapper,
    scrollable: true,
  },
  smartvend: {
    component: () => SmartVend,
    scrollable: true,
  },
  smes: {
    component: () => Smes,
    scrollable: false,
  },
  smoke_machine: {
    component: () => SmokeMachine,
    scrollable: false,
  },
  solar_control: {
    component: () => SolarControl,
    scrollable: false,
  },
  space_heater: {
    component: () => SpaceHeater,
    scrollable: false,
  },
  spawners_menu: {
    component: () => SpawnersMenu,
    scrollable: true,
  },
  station_alert: {
    component: () => StationAlertConsole,
    scrollable: true,
  },
  suit_storage_unit: {
    component: () => SuitStorageUnit,
    scrollable: false,
  },
  synd_contract: {
    component: () => SyndContractor,
    wrapper: () => NtosWrapper,
    scrollable: true,
    theme: 'syndicate',
  },
  tanks: {
    component: () => Tank,
    scrollable: false,
  },
  tank_dispenser: {
    component: () => TankDispenser,
    scrollable: false,
  },
  thermomachine: {
    component: () => ThermoMachine,
    scrollable: false,
  },
  turbine_computer: {
    component: () => TurbineComputer,
    scrollable: false,
  },
  uplink: {
    component: () => Uplink,
    scrollable: true,
    theme: 'syndicate',
  },
  vault_controller: {
    component: () => VaultController,
    scrollable: false,
  },
  vending: {
    component: () => Vending,
    scrollable: true,
  },
  wires: {
    component: () => Wires,
    scrollable: false,
  },
};

export const getRoute = state => {
  if (process.env.NODE_ENV !== 'production') {
    // Show a kitchen sink
    if (state.showKitchenSink) {
      const { KitchenSink } = require('./interfaces/KitchenSink');
      return {
        component: () => KitchenSink,
        scrollable: true,
      };
    }
  }
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};
