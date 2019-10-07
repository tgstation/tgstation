import { Acclimator } from './interfaces/Acclimator';
import { AIAirlock } from './interfaces/AIAirlock';
import { AirAlarm } from './interfaces/AirAlarm';
import { ChemDispenser } from './interfaces/ChemDispenser';
import { KitchenSink } from './interfaces/KitchenSink';

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
  chem_dispenser: {
    component: () => ChemDispenser,
    scrollable: true,
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
