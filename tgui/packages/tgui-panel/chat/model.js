/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createUuid } from 'common/uuid';
import { MESSAGE_TYPES, MESSAGE_TYPE_INTERNAL } from './constants';

export const canPageAcceptType = (page, type) => (
  type.startsWith(MESSAGE_TYPE_INTERNAL) || page.acceptedTypes[type]
);

export const createPage = obj => {
  let acceptedTypes = {};

  for (let typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = !!typeDef.important;
  }

  return {
    id: createUuid(),
    name: 'New Tab',
    acceptedTypes: acceptedTypes,
    unreadCount: 0,
    createdAt: Date.now(),
    ...obj,
  };
};

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
  html: message.html,
  times: message.times,
  createdAt: message.createdAt,
});

export const isSameMessage = (a, b) => (
  typeof a.text === 'string' && a.text === b.text
  || typeof a.html === 'string' && a.html === b.html
);
