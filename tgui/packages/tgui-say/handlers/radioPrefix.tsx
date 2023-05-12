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
export const handleRadioPrefix = function (this: Modal) {
  const { channel } = this.state;
  const { currentPrefix, currentValue: value } = this.fields;
  if (channel > 1 || !value || value.length < 3 || !channelRegex.test(value)) {
    return;
  }

  const prefix = value.slice(0, 3) as keyof typeof RADIO_PREFIXES;
  if (!RADIO_PREFIXES[prefix] || prefix === currentPrefix) {
    return;
  }

  // Remove the prefix from the value
  this.fields.currentValue = value.slice(3);
  // We're thinking, but binary is a "secret" channel
  Byond.sendMessage('thinking', { mode: prefix !== ':b ' });

  this.fields.currentPrefix = prefix;
  this.setState({
    buttonContent: RADIO_PREFIXES[prefix].label,
    channel: 0,
    edited: true,
  });
};
