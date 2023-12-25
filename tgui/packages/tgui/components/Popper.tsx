import { createPopper, Placement } from '@popperjs/core';
import { ArgumentsOf } from 'common/types';
import React, { PropsWithChildren, useEffect, useRef, useState } from 'react';
import { CSSProperties, JSXElementConstructor, ReactElement } from 'react';
import { createPortal } from 'react-dom';

type Props = {
  isOpen: boolean;
  popperContent: ReactElement<any, string | JSXElementConstructor<any>> | null;
} & Partial<{
  additionalStyles: CSSProperties;
  onClickOutside: () => void;
  options: ArgumentsOf<typeof createPopper>[2];
  placement: Placement;
}> &
  PropsWithChildren;

export function Popper(props: Props) {
  const {
    additionalStyles,
    children,
    isOpen,
    placement,
    popperContent,
    options = {},
    onClickOutside,
  } = props;

  const parentRef = useRef<HTMLDivElement | null>(null);
  const popperRef = useRef<HTMLDivElement | null>(null);
  const [popperInstance, setPopperInstance] = useState<ReturnType<
    typeof createPopper
  > | null>(null);

  /** Create the popper instance when the component mounts */
  useEffect(() => {
    if (!parentRef.current || !popperRef.current) return;
    if (placement) options.placement = placement;

    const instance = createPopper(
      parentRef.current,
      popperRef.current,
      options,
    );
    setPopperInstance(instance);

    return () => {
      instance.destroy();
      setPopperInstance(null);
    };
  }, [options]);

  /** Update the popper instance when the content changes */
  useEffect(() => {
    if (!popperInstance) return;

    popperInstance.update();
  }, [popperContent]);

  /** Focus when opened */
  useEffect(() => {
    if (!isOpen) return;

    // focus the first element in the popper content
    const focusable = popperRef.current?.firstChild as HTMLElement | null;
    focusable?.focus();
  }, [isOpen]);

  /** Close the dropdown menu when clicking outside of it */
  useEffect(() => {
    if (!onClickOutside) return;

    function handleClickOutside(event: MouseEvent) {
      if (
        !parentRef.current?.contains(event.target as Node) &&
        !popperRef.current?.contains(event.target as Node)
      ) {
        onClickOutside?.();
      }
    }

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const contentStyle = {
    ...additionalStyles,
    position: 'absolute',
    zIndex: 1000,
  } as CSSProperties;

  return (
    <>
      <div ref={parentRef}>{children}</div>
      {createPortal(
        <div ref={popperRef} style={contentStyle}>
          {isOpen && popperContent}
        </div>,
        document.body,
      )}
    </>
  );
}
