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
import { BluespaceArtillery } from './interfaces/BluespaceArtillery';
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
import { ChemSplitter } from './interfaces/ChemSplitter';
import { CodexGigas } from './interfaces/CodexGigas';
import { Crayon } from './interfaces/Crayon';
import { CrewConsole } from './interfaces/CrewConsole';
import { Cryo } from './interfaces/Cryo';
import { DisposalUnit } from './interfaces/DisposalUnit';
import { KitchenSink } from './interfaces/KitchenSink';
import { LanguageMenu } from './interfaces/LanguageMenu';
import { Mint } from './interfaces/Mint';
import { OperatingComputer } from './interfaces/OperatingComputer';
import { PersonalCrafting } from './interfaces/PersonalCrafting';
import { PortableGenerator } from './interfaces/PortableGenerator';
import { ShuttleManipulator } from './interfaces/ShuttleManipulator';
import { SmartVend } from './interfaces/SmartVend';
import { SMES } from './interfaces/SMES';
import { ThermoMachine } from './interfaces/ThermoMachine';
import { VaultController } from './interfaces/VaultController';
import { Wires } from './interfaces/Wires';
import { ChemSynthesizer } from './interfaces/ChemSynthesizer';
import { ChemPress } from './interfaces/ChemPress';

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
  disposal_unit: {
    component: () => DisposalUnit,
    scrollable: false,
  },
  language_menu: {
    component: () => LanguageMenu,
    scrollable: true,
  },
  mint: {
    component: () => Mint,
    scrollable: false,
  },
  operating_computer: {
    component: () => OperatingComputer,
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
  shuttle_manipulator: {
    component: () => ShuttleManipulator,
    scrollable: true,
  },
  smartvend: {
    component: () => SmartVend,
    scrollable: true,
  },
  smes: {
    component: () => SMES,
    scrollable: false,
  },
  thermomachine: {
    component: () => ThermoMachine,
    scrollable: false,
  },
  vault_controller: {
    component: () => VaultController,
    scrollable: false,
  },
  wires: {
    component: () => Wires,
    scrollable: false,
  },
};

export const getRoute = state => {
  // Show a kitchen sink
  if (state.showKitchenSink) {
    return {
      component: () => KitchenSink,
      scrollable: true,
    };
  }
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};
