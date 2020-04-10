export const getRoutedComponent = state => {
  if (process.env.NODE_ENV !== 'production') {
    // Show a kitchen sink
    if (state.showKitchenSink) {
      const { KitchenSink } = require('./interfaces/KitchenSink');
      return KitchenSink;
    }
  }
  const name = state.config?.interface;
  if (!name) {
    throw new Error('Interface is undefined.');
  }
  const esModule = require(`./interfaces/${name}.js`);
  const Component = esModule[name];
  if (!Component) {
    throw new Error(`Interface "${name}" is missing an export.`);
  }
  return Component;
};

// const ROUTES = {
//   achievements: {
//     component: () => Achievements,
//     scrollable: true,
//   },
//   ai_airlock: {
//     component: () => AiAirlock,
//     scrollable: false,
//   },
//   ai_restorer: {
//     component: () => AiRestorer,
//     scrollable: true,
//   },
//   airlock_electronics: {
//     component: () => AirlockElectronics,
//     scrollable: false,
//   },
//   apc: {
//     component: () => Apc,
//     scrollable: false,
//   },
//   atmos_alert: {
//     component: () => AtmosAlertConsole,
//     scrollable: true,
//   },
//   atmos_control: {
//     component: () => AtmosControlConsole,
//     scrollable: true,
//   },
//   atmos_filter: {
//     component: () => AtmosFilter,
//     scrollable: false,
//   },
//   atmos_mixer: {
//     component: () => AtmosMixer,
//     scrollable: false,
//   },
//   atmos_pump: {
//     component: () => AtmosPump,
//     scrollable: false,
//   },
//   announcement_system: {
//     component: () => AutomatedAnnouncement,
//     scrollable: false,
//   },
//   bepis: {
//     component: () => Bepis,
//     scrollable: false,
//   },
//   bank_machine: {
//     component: () => BankMachine,
//     scrollable: false,
//   },
//   blackmarket_uplink: {
//     component: () => BlackmarketUplink,
//     scrollable: true,
//     theme: 'hackerman',
//   },
//   borgopanel: {
//     component: () => BorgPanel,
//     scrollable: true,
//   },
//   brig_timer: {
//     component: () => BrigTimer,
//     scrollable: false,
//   },
//   bsa: {
//     component: () => BluespaceArtillery,
//     scrollable: false,
//   },
//   camera_console: {
//     component: () => CameraConsole,
//     wrapper: () => CameraConsoleWrapper,
//     scrollable: true,
//   },
//   canister: {
//     component: () => Canister,
//     scrollable: false,
//   },
//   canvas: {
//     component: () => Canvas,
//     scrollable: false,
//   },
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
//   ntos_ai_restorer: {
//     component: () => AiRestorer,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
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
//   ntos_file_manager: {
//     component: () => NtosFileManager,
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
//   ntos_main: {
//     component: () => NtosMain,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_net_chat: {
//     component: () => NtosNetChat,
//     wrapper: () => NtosWrapper,
//     scrollable: false,
//     theme: 'ntos',
//   },
//   ntos_net_dos: {
//     component: () => NtosNetDos,
//     wrapper: () => NtosWrapper,
//     scrollable: false,
//     theme: 'syndicate',
//   },
//   ntos_net_downloader: {
//     component: () => NtosNetDownloader,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_net_monitor: {
//     component: () => NtosNetMonitor,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_power_monitor: {
//     component: () => PowerMonitor,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_revelation: {
//     component: () => NtosRevelation,
//     wrapper: () => NtosWrapper,
//     scrollable: false,
//     theme: 'syndicate',
//   },
//   ntos_robocontrol: {
//     component: () => NtosRoboControl,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_shipping: {
//     component: () => NtosShipping,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_station_alert: {
//     component: () => StationAlertConsole,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   ntos_supermatter_monitor: {
//     component: () => NtosSupermatterMonitor,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'ntos',
//   },
//   nuclear_bomb: {
//     component: () => NuclearBomb,
//     scrollable: false,
//     theme: 'retro',
//   },
//   ore_redemption_machine: {
//     component: () => OreRedemptionMachine,
//     scrollable: true,
//   },
//   ore_box: {
//     component: () => OreBox,
//     scrollable: true,
//   },
//   operating_computer: {
//     component: () => OperatingComputer,
//     scrollable: true,
//   },
//   pandemic: {
//     component: () => Pandemic,
//     scrollable: true,
//   },
//   particle_accelerator: {
//     component: () => ParticleAccelerator,
//     scrollable: false,
//   },
//   personal_crafting: {
//     component: () => PersonalCrafting,
//     scrollable: true,
//   },
//   portable_pump: {
//     component: () => PortablePump,
//     scrollable: false,
//   },
//   portable_scrubber: {
//     component: () => PortableScrubber,
//     scrollable: false,
//   },
//   power_monitor: {
//     component: () => PowerMonitor,
//     scrollable: true,
//   },
//   proximity_sensor: {
//     component: () => ProximitySensor,
//     scrollable: false,
//   },
//   radio: {
//     component: () => Radio,
//     scrollable: false,
//   },
//   radioactive_microlaser: {
//     component: () => RadioactiveMicrolaser,
//     scrollable: false,
//     theme: 'syndicate',
//   },
//   remote_robot_control: {
//     component: () => RemoteRobotControl,
//     scrollable: true,
//   },
//   robotics_control_console: {
//     component: () => RoboticsControlConsole,
//     scrollable: true,
//   },
//   roulette: {
//     component: () => Roulette,
//     scrollable: false,
//     theme: 'cardtable',
//   },
//   rpd: {
//     component: () => RapidPipeDispenser,
//     scrollable: true,
//   },
//   sat_control: {
//     component: () => SatelliteControl,
//     scrollable: false,
//   },
//   scanner_gate: {
//     component: () => ScannerGate,
//     scrollable: true,
//   },
//   shuttle_manipulator: {
//     component: () => ShuttleManipulator,
//     scrollable: true,
//   },
//   signaler: {
//     component: () => Signaler,
//     scrollable: false,
//   },
//   sleeper: {
//     component: () => Sleeper,
//     scrollable: false,
//   },
//   slime_swap_body: {
//     component: () => SlimeBodySwapper,
//     scrollable: true,
//   },
//   smartvend: {
//     component: () => SmartVend,
//     scrollable: true,
//   },
//   smes: {
//     component: () => Smes,
//     scrollable: false,
//   },
//   smoke_machine: {
//     component: () => SmokeMachine,
//     scrollable: false,
//   },
//   solar_control: {
//     component: () => SolarControl,
//     scrollable: false,
//   },
//   space_heater: {
//     component: () => SpaceHeater,
//     scrollable: false,
//   },
//   spawners_menu: {
//     component: () => SpawnersMenu,
//     scrollable: true,
//   },
//   station_alert: {
//     component: () => StationAlertConsole,
//     scrollable: true,
//   },
//   suit_storage_unit: {
//     component: () => SuitStorageUnit,
//     scrollable: false,
//   },
//   synd_contract: {
//     component: () => SyndContractor,
//     wrapper: () => NtosWrapper,
//     scrollable: true,
//     theme: 'syndicate',
//   },
//   tanks: {
//     component: () => Tank,
//     scrollable: false,
//   },
//   tank_dispenser: {
//     component: () => TankDispenser,
//     scrollable: false,
//   },
//   teleporter: {
//     component: () => Teleporter,
//     scrollable: false,
//   },
//   thermomachine: {
//     component: () => ThermoMachine,
//     scrollable: false,
//   },
//   timer: {
//     component: () => Timer,
//     scrollable: false,
//   },
//   transfer_valve: {
//     component: () => TransferValve,
//     scrollable: false,
//   },
//   turbine_computer: {
//     component: () => TurbineComputer,
//     scrollable: false,
//   },
//   uplink: {
//     component: () => Uplink,
//     scrollable: true,
//     theme: 'syndicate',
//   },
//   vault_controller: {
//     component: () => VaultController,
//     scrollable: false,
//   },
//   vending: {
//     component: () => Vending,
//     scrollable: true,
//   },
//   wires: {
//     component: () => Wires,
//     scrollable: false,
//   },
//   scan_consolenew: {
//     component: () => DnaConsole,
//     scrollable: true,
//   },
// };
