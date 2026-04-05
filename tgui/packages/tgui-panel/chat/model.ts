/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createUuid } from 'tgui-core/uuid';

import { MESSAGE_TYPE_INTERNAL, MESSAGE_TYPES } from './constants';
import type { Page } from './types';

export function canPageAcceptType(page: Page, type: string): boolean {
  return type.startsWith(MESSAGE_TYPE_INTERNAL) || page.acceptedTypes[type];
}

export function createPage(obj: Record<string, unknown> = {}): Page {
  const acceptedTypes = {};

  for (const typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = !!typeDef.important;
  }

  return {
    isMain: false,
    id: createUuid(),
    name: 'New Tab',
    acceptedTypes,
    unreadCount: 0,
    hideUnreadCount: false,
    createdAt: Date.now(),
    ...obj,
  };
}

export function createMainPage(): Page {
  const acceptedTypes = {};
  for (const typeDef of MESSAGE_TYPES) {
    acceptedTypes[typeDef.type] = true;
  }
  return createPage({
    id: 'main',
    isMain: true,
    name: 'Main',
    acceptedTypes,
  });
}

export function createMessage(
  payload: Record<string, unknown>,
): SerializedMessage {
  return { createdAt: Date.now(), ...payload } as SerializedMessage;
}

export function serializeMessage(
  message: SerializedMessage,
): SerializedMessage {
  return {
    type: message.type,
    text: message.text,
    html: message.html,
    times: message.times,
    createdAt: message.createdAt,
  };
}

export function isSameMessage(
  a: SerializedMessage,
  b: SerializedMessage,
): boolean {
  return (
    (typeof a.text === 'string' && a.text === b.text) ||
    (typeof a.html === 'string' && a.html === b.html)
  );
}

type SerializedMessage = {
  type: string;
  createdAt: number;
} & Partial<{
  text: string;
  html: string;
  times: number;
  node: HTMLElement;
  avoidHighlighting: boolean;
}>;
