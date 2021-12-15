/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { sendMessage } from 'tgui/backend';
import { storage } from 'common/storage';
import { createLogger } from 'tgui/logging';
import FingerprintJS from '@fingerprintjs/fingerprintjs';

const logger = createLogger('telemetry');

const MAX_CONNECTIONS_STORED = 10;

// should this be done somewhere later maybe
const fpPromise = FingerprintJS.load({ monitoring: false });

const connectionsMatch = (a, b) => (
  a.ckey === b.ckey
    && a.address === b.address
    && a.computer_id === b.computer_id
);

export const telemetryMiddleware = store => {
  let telemetry;
  let wasRequestedWithPayload;
  return next => action => {
    const { type, payload } = action;
    // Handle telemetry requests
    if (type === 'telemetry/request') {
      // Defer telemetry request until we have the actual telemetry
      if (!telemetry) {
        logger.debug('deferred');
        wasRequestedWithPayload = payload;
        return;
      }
      logger.debug('sending');
      const limits = payload?.limits || {};
      // Trim connections according to the server limit
      const connections = telemetry.connections
        .slice(0, limits.connections);


      fpPromise.then(async (fp_js) => {
        const fp_result = await fp_js.get();
        const font_only_source = { "fonts": fp_result.components.fonts };
        const font_only_id = FingerprintJS.hashComponents(font_only_source);
        sendMessage({
          type: 'telemetry',
          payload: {
            connections,
            fingerprint: fp_result.visitorId,
            font_only_fingerprint: font_only_id,
          },
        });
      });
      return;
    }
    // Keep telemetry up to date
    if (type === 'backend/update') {
      next(action);
      (async () => {
        // Extract client data
        const client = payload?.config?.client;
        if (!client) {
          logger.error('backend/update payload is missing client data!');
          return;
        }
        // Load telemetry
        if (!telemetry) {
          telemetry = await storage.get('telemetry') || {};
          if (!telemetry.connections) {
            telemetry.connections = [];
          }
          logger.debug('retrieved telemetry from storage', telemetry);
        }
        // Append a connection record
        let telemetryMutated = false;
        const duplicateConnection = telemetry.connections
          .find(conn => connectionsMatch(conn, client));
        if (!duplicateConnection) {
          telemetryMutated = true;
          telemetry.connections.unshift(client);
          if (telemetry.connections.length > MAX_CONNECTIONS_STORED) {
            telemetry.connections.pop();
          }
        }
        // Save telemetry
        if (telemetryMutated) {
          logger.debug('saving telemetry to storage', telemetry);
          storage.set('telemetry', telemetry);
        }
        // Continue deferred telemetry requests
        if (wasRequestedWithPayload) {
          const payload = wasRequestedWithPayload;
          wasRequestedWithPayload = null;
          store.dispatch({
            type: 'telemetry/request',
            payload,
          });
        }
      })();
      return;
    }
    return next(action);
  };
};
