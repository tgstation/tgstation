/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createUuid } from 'tgui-core/uuid';

import { MESSAGE_TYPE_INTERNAL, MESSAGE_TYPES } from './constants';

export const canPageAcceptType = (page, type) =>
  type.startsWith(MESSAGE_TYPE_INTERNAL) || page.acceptedTypes[type];

export const createPage = (obj) => {
  const acceptedTypes = {};

  for (const typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = !!typeDef.important;
  }

  return {
    isMain: false,
    id: createUuid(),
    name: 'New Tab',
    acceptedTypes: acceptedTypes,
    unreadCount: 0,
    hideUnreadCount: false,
    createdAt: Date.now(),
    ...obj,
  };
};

export const createMainPage = () => {
  const acceptedTypes = {};
  for (const typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = true;
  }
  return createPage({
    isMain: true,
    name: 'Main',
    acceptedTypes,
  });
};

export const createMessage = (payload) => ({
  createdAt: Date.now(),
  ...payload,
});

export const serializeMessage = (message) => ({
  type: message.type,
  text: message.text,
  html: message.html,
  times: message.times,
  createdAt: message.createdAt,
});

export const isSameMessage = (a, b) =>
  (typeof a.text === 'string' && a.text === b.text) ||
  (typeof a.html === 'string' && a.html === b.html);
