import type { BooleanLike } from 'tgui-core/react';

export enum ShuttleState {
  BUYING_SHUTTLE = 'buying_shuttle',
  CHANGING_STATUS = 'changing_status',
  MAIN = 'main',
  MESSAGES = 'messages',
}

export type Shuttle = {
  activation: string;
  activationTime: number;
  creditCost: number;
  description: string;
  emagOnly: BooleanLike;
  expiration: string;
  expirationTime: number;
  id: number;
  image: string;
  initial_cost: number;
  name: string;
  occupancy_limit: number;
  prerequisites: string[];
  price: number;
  ref: string;
  refund: number;
};

type Message = {
  answered: number;
  content: string;
  title: string;
  possibleAnswers: string[];
};

export type CommsConsoleData = {
  alertLevel: string;
  alertLevelTick: number;
  aprilFools: BooleanLike;
  authenticated: BooleanLike;
  authorizeName: string;
  budget: number;
  canBuyShuttles: BooleanLike;
  canLogOut: BooleanLike;
  canMakeAnnouncement: BooleanLike;
  canMessageAssociates: BooleanLike;
  canRecallShuttles: BooleanLike;
  canRequestNuke: BooleanLike;
  canRequestSafeCode: BooleanLike;
  canSendToSectors: BooleanLike;
  canSetAlertLevel: string;
  canToggleEmergencyAccess: BooleanLike;
  emagged: BooleanLike;
  emergencyAccess: BooleanLike;
  hasConnection: BooleanLike;
  importantActionReady: BooleanLike;
  messages: Message[];
  page: ShuttleState;
  safeCodeDeliveryArea: string;
  safeCodeDeliveryWait: number;
  sectors: string[];
  shuttles: Shuttle[];
  shuttleCalled: BooleanLike;
  shuttleCalledPreviously: BooleanLike;
  shuttleCanEvacOrFailReason: string | 1;
  shuttleLastCalled: BooleanLike;
  shuttleRecallable: BooleanLike;
  syndicate: BooleanLike;

  // static_data
  callShuttleReasonMinLength: number;
  maxMessageLength: number;
  maxStatusLineLength: number;
};
