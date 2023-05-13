import { BooleanLike } from 'common/react';
import { Handlers } from '.';
import { windowLoad, windowOpen } from '../helpers';
import { TguiSay } from '../TguiSay';

type ByondProps = {
  maxLength: number;
  lightMode: BooleanLike;
};

type ByondOpen = {
  channel: string;
};

/** Attach listeners, sets window size just in case */
export const handleComponentMount: Handlers['componentMount'] = function (
  this: TguiSay
) {
  const { channelIterator, innerRef } = this.fields;
  const { forceSay } = this.handlers;

  Byond.subscribeTo('props', (data: ByondProps) => {
    const { maxLength, lightMode } = data;
    this.fields.maxLength = maxLength;
    this.fields.lightMode = !!lightMode;
  });

  Byond.subscribeTo('force', () => {
    forceSay();
  });

  Byond.subscribeTo('open', (data: ByondOpen) => {
    const { channel } = data;

    channelIterator.set(channel);

    this.setState({ buttonContent: channelIterator.current() });

    setTimeout(() => {
      innerRef.current?.focus();
    }, 1);

    windowOpen(channelIterator.current());
  });

  windowLoad();
};
