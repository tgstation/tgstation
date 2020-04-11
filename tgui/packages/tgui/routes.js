import { Window } from './layouts';

const routingError = (type, name) => () => {
  return (
    <Window resizable>
      <Window.Content scrollable>
        {type === 'notFound' && (
          <div>Interface <b>{name}</b> was not found.</div>
        )}
        {type === 'missingExport' && (
          <div>Interface <b>{name}</b> is missing an export.</div>
        )}
      </Window.Content>
    </Window>
  );
};

export const getRoutedComponent = state => {
  if (process.env.NODE_ENV !== 'production') {
    // Show a kitchen sink
    if (state.showKitchenSink) {
      const { KitchenSink } = require('./interfaces/KitchenSink');
      return KitchenSink;
    }
  }
  const name = state.config?.interface;
  let esModule;
  try {
    esModule = require(`./interfaces/${name}.js`);
  }
  catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      return routingError('notFound', name);
    }
    throw err;
  }
  const Component = esModule[name];
  if (!Component) {
    return routingError('missingExport', name);
  }
  return Component;
};

// const ROUTES = {
//   cargo: {
//     component: () => Cargo,
//     scrollable: true,
//   },
//   cargo_express: {
//     component: () => CargoExpress,
//     scrollable: true,
//   },
//   cargo_hold_terminal: {
//     component: () => CargoHoldTerminal,
//     scrollable: true,
//   },
//   cellular_emporium: {
//     component: () => CellularEmporium,
//     scrollable: true,
//   },
//   centcom_podlauncher: {
//     component: () => CentcomPodLauncher,
//     scrollable: false,
//   },
//   acclimator: {
//     component: () => ChemAcclimator,
//     scrollable: false,
//   },
//   chem_dispenser: {
//     component: () => ChemDispenser,
//     scrollable: true,
//   },
//   chemical_filter: {
//     component: () => ChemFilter,
//     scrollable: true,
//   },
//   chem_heater: {
//     component: () => ChemHeater,
//     scrollable: true,
//   },
//   chem_master: {
//     component: () => ChemMaster,
//     scrollable: true,
//   },
//   chem_press: {
//     component: () => ChemPress,
//     scrollable: false,
//   },
//   reaction_chamber: {
//     component: () => ChemReactionChamber,
//     scrollable: true,
//   },
//   chem_splitter: {
//     component: () => ChemSplitter,
//     scrollable: false,
//   },
//   chem_synthesizer: {
//     component: () => ChemDebugSynthesizer,
//     scrollable: false,
//   },
//   synthesizer: {
//     component: () => ChemSynthesizer,
//     scrollable: false,
//   },
//   codex_gigas: {
//     component: () => CodexGigas,
//     scrollable: false,
//   },
//   computer_fabricator: {
//     component: () => ComputerFabricator,
//     scrollable: false,
//   },
//   crayon: {
//     component: () => Crayon,
//     scrollable: true,
//   },
//   crew: {
//     component: () => CrewConsole,
//     scrollable: true,
//   },
//   cryo: {
//     component: () => Cryo,
//     scrollable: false,
//   },
//   decal_painter: {
//     component: () => DecalPainter,
//     scrollable: false,
//   },
//   disposal_unit: {
//     component: () => DisposalUnit,
//     scrollable: false,
//   },
//   dna_vault: {
//     component: () => DnaVault,
//     scrollable: false,
//   },
//   eightball: {
//     component: () => EightBallVote,
//     scrollable: false,
//   },
//   electropack: {
//     component: () => Electropack,
//     scrollable: false,
//   },
//   emergency_shuttle_console: {
//     component: () => EmergencyShuttleConsole,
//     scrollable: false,
//   },
//   engraved_message: {
//     component: () => EngravedMessage,
//     scrollable: false,
//   },
//   exosuit_control_console: {
//     component: () => ExosuitControlConsole,
//     scrollable: true,
//   },
//   gateway: {
//     component: () => Gateway,
//     scrollable: true,
//   },
//   gps: {
//     component: () => Gps,
//     scrollable: true,
//   },
//   gravity_generator: {
//     component: () => GravityGenerator,
//     scrollable: false,
//   },
//   gulag_console: {
//     component: () => GulagTeleporterConsole,
//     scrollable: false,
//   },
//   gulag_item_reclaimer: {
//     component: () => GulagItemReclaimer,
//     scrollable: true,
//   },
//   holodeck: {
//     component: () => Holodeck,
//     scrollable: true,
//   },
//   hypnochair: {
//     component: () => HypnoChair,
//     scrollable: false,
//   },
//   implantchair: {
//     component: () => ImplantChair,
//     scrollable: false,
//   },
//   infrared_emitter: {
//     component: () => InfraredEmitter,
//     scrollable: false,
//   },
//   intellicard: {
//     component: () => Intellicard,
//     scrollable: true,
//   },
//   keycard_auth: {
//     component: () => KeycardAuth,
//     scrollable: false,
//   },
//   labor_claim_console: {
//     component: () => LaborClaimConsole,
//     scrollable: false,
//   },
//   language_menu: {
//     component: () => LanguageMenu,
//     scrollable: true,
//   },
//   launchpad_console: {
//     component: () => LaunchpadConsole,
//     scrollable: true,
//   },
//   launchpad_remote: {
//     component: () => LaunchpadRemote,
//     scrollable: false,
//     theme: 'syndicate',
//   },
//   mech_bay_power_console: {
//     component: () => MechBayPowerConsole,
//     scrollable: false,
//   },
//   medical_kiosk: {
//     component: () => MedicalKiosk,
//     scrollable: false,
//   },
//   mining_vendor: {
//     component: () => MiningVendor,
//     scrollable: true,
//   },
//   mint: {
//     component: () => Mint,
//     scrollable: false,
//   },
//   malfunction_module_picker: {
//     component: () => MalfunctionModulePicker,
//     scrollable: true,
//     theme: 'malfunction',
//   },
//   mulebot: {
//     component: () => Mule,
//     scrollable: false,
//   },
//   nanite_chamber_control: {
//     component: () => NaniteChamberControl,
//     scrollable: true,
//   },
//   nanite_cloud_control: {
//     component: () => NaniteCloudControl,
//     scrollable: true,
//   },
//   nanite_program_hub: {
//     component: () => NaniteProgramHub,
//     scrollable: true,
//   },
//   nanite_programmer: {
//     component: () => NaniteProgrammer,
//     scrollable: true,
//   },
//   nanite_remote: {
//     component: () => NaniteRemote,
//     scrollable: true,
//   },
//   notificationpanel: {
//     component: () => NotificationPreferences,
//     scrollable: true,
//   },
//   ntnet_relay: {
//     component: () => NtnetRelay,
//     scrollable: false,
//   },
//   ntos_atmos: {
//     component: () => NtosAtmos,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_arcade: {
//     component: () => NtosArcade,
//     wrapper: () => NtosWrapper,
//     scrollable: false,
//     theme: 'ntos',
//   },
//   ntos_card: {
//     component: () => NtosCard,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_configuration: {
//     component: () => NtosConfiguration,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_crew_manifest: {
//     component: () => NtosCrewManifest,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_cyborg_monitor: {
//     component: () => NtosCyborgRemoteMonitor,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_job_manager: {
//     component: () => NtosJobManager,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
// };
