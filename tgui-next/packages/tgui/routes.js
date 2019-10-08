import { Acclimator } from './interfaces/Acclimator';
import { AIAirlock } from './interfaces/AIAirlock';
import { AirAlarm } from './interfaces/AirAlarm';
import { Canister } from './interfaces/Canister';
import { ChemDispenser } from './interfaces/ChemDispenser';
import { KitchenSink } from './interfaces/KitchenSink';
import { Thermomachine } from './interfaces/Thermomachine';

const ROUTES = {
  airalarm: {
    component: () => AirAlarm,
    scrollable: true,
  },
  acclimator: {
    component: () => Acclimator,
    scrollable: false,
  },
  ai_airlock: {
    component: () => AIAirlock,
    scrollable: false,
  },
  canister: {
    component: () => Canister,
    scrollable: false,
  },
  chem_dispenser: {
    component: () => ChemDispenser,
    scrollable: true,
  },
  thermomachine: {
    component: () => Thermomachine,
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
