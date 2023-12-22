import { createPopper } from '@popperjs/core';
import { ArgumentsOf } from 'common/types';
import React, { PropsWithChildren, useEffect, useRef, useState } from 'react';
import { CSSProperties, JSXElementConstructor, ReactElement } from 'react';
import { createPortal } from 'react-dom';

type Props = {
  additionalStyles?: CSSProperties;
  className?: string;
  options?: ArgumentsOf<typeof createPopper>[2];
  popperContent: ReactElement<any, string | JSXElementConstructor<any>> | null;
} & PropsWithChildren;

export function Popper(props: Props) {
  const { className, popperContent, options, additionalStyles, children } =
    props;

  const referenceElement = useRef<HTMLDivElement | null>(null);
  const popperElement = useRef<HTMLDivElement | null>(null);
  const [popperInstance, setPopperInstance] = useState<ReturnType<
    typeof createPopper
  > | null>(null);

  useEffect(() => {
    if (referenceElement.current && popperElement.current) {
      const instance = createPopper(
        referenceElement.current,
        popperElement.current,
        options,
      );
      setPopperInstance(instance);

      return () => {
        instance.destroy();
      };
    }
  }, [options]);

  useEffect(() => {
    if (popperInstance) {
      popperInstance.update();
    }
  }, [popperContent]);

  const contentStyle = {
    ...additionalStyles,
    position: 'absolute',
    zIndex: 1000,
  } as CSSProperties;

  return (
    <>
      <div ref={referenceElement}>{children}</div>
      {createPortal(
        <div className={className} ref={popperElement} style={contentStyle}>
          {popperContent}
        </div>,
        document.body,
      )}
    </>
  );
}
