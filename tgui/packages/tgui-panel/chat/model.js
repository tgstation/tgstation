/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { MESSAGE_TYPES } from './constants';
import { createUuid } from 'common/uuid';

export const canPageAcceptType = (page, type) => (
  type.startsWith('internal') || page.acceptedTypes[type]
);

export const createPage = obj => ({
  id: createUuid(),
  name: 'New Tab',
  acceptedTypes: {},
  count: 0,
  unreadCount: 0,
  createdAt: Date.now(),
  ...obj,
});

export const createMainPage = () => {
  const acceptedTypes = {};
  for (let typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = true;
  }
  return createPage({
    name: 'Main',
    acceptedTypes,
  });
};

export const createMessage = payload => ({
  createdAt: Date.now(),
  ...payload,
});

export const serializeMessage = message => ({
  type: message.type,
  text: message.text,
  times: message.times,
  createdAt: message.createdAt,
});
