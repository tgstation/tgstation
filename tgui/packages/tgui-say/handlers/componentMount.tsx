import { BooleanLike } from 'common/react';
import { windowLoad, windowOpen } from '../helpers';
import { Modal } from '../types';

type ByondProps = {
  maxLength: number;
  lightMode: BooleanLike;
};

type ByondOpen = {
  channel: number;
};

/** Attach listeners, sets window size just in case */
export const handleComponentMount: Modal['handlers']['componentMount'] =
  function (this: Modal) {
    const { channelIterator } = this.fields;

    Byond.subscribeTo('props', (data: ByondProps) => {
      const { maxLength, lightMode } = data;
      this.fields.maxLength = maxLength;
      this.fields.lightMode = !!lightMode;
    });

    Byond.subscribeTo('force', () => {
      this.handlers.forcesay();
    });

    Byond.subscribeTo('open', (data: ByondOpen) => {
      const { channel } = data;
      channelIterator.set(channel);

      this.setState({ buttonContent: channelIterator.current() });

      setTimeout(() => {
        this.fields.innerRef.current?.focus();
      }, 1);

      windowOpen(channelIterator.current());
    });

    windowLoad();
  };
