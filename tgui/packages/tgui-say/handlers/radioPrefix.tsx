import { RADIO_PREFIXES } from '../constants';
import { Modal } from '../types';

const channelRegex = /^:\w\s/;

/**
 * Gets any channel prefixes from the chat bar
 * and changes to the corresponding radio subchannel.
 *
 * Exemptions: Channel is OOC, value is too short,
 * Not a valid radio pref, or value is already the radio pref.
 */
export const handleRadioPrefix: Modal['handlers']['radioPrefix'] = function (
  this: Modal
) {
  const { channelIterator, currentPrefix, currentValue } = this.fields;

  if (
    !currentValue ||
    !channelIterator.isSay() ||
    currentValue.length < 3 ||
    !channelRegex.test(currentValue)
  ) {
    return;
  }

  const prefix = currentValue.slice(0, 3) as keyof typeof RADIO_PREFIXES;
  if (!RADIO_PREFIXES[prefix] || prefix === currentPrefix) {
    return;
  }

  // Remove the prefix from the currentValue
  this.fields.currentValue = currentValue.slice(3);
  // We're thinking, but binary is a "secret" channel
  Byond.sendMessage('thinking', { mode: prefix !== ':b ' });

  this.fields.currentPrefix = prefix;
  this.setState({
    buttonContent: RADIO_PREFIXES[prefix].label,
    edited: true,
  });
};
