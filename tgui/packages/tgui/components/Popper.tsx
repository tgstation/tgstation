import { createPopper, Placement } from '@popperjs/core';
import { ArgumentsOf } from 'common/types';
import {
  PropsWithChildren,
  useCallback,
  useEffect,
  useMemo,
  useRef,
} from 'react';
import { CSSProperties, JSXElementConstructor, ReactElement } from 'react';
import { createPortal } from 'react-dom';

type Props = {
  isOpen: boolean;
  popperContent: ReactElement<any, string | JSXElementConstructor<any>> | null;
} & Partial<{
  additionalStyles: CSSProperties;
  autoFocus: boolean;
  onClickOutside: () => void;
  options: ArgumentsOf<typeof createPopper>[2];
  placement: Placement;
}> &
  PropsWithChildren;

export function Popper(props: Props) {
  const {
    additionalStyles,
    autoFocus,
    children,
    isOpen,
    placement,
    popperContent,
    options = {},
    onClickOutside,
  } = props;

  const parentRef = useRef<HTMLDivElement | null>(null);
  const popperRef = useRef<HTMLDivElement | null>(null);

  const handleClickOutside = useCallback((event: MouseEvent) => {
    if (
      !parentRef.current?.contains(event.target as Node) &&
      !popperRef.current?.contains(event.target as Node)
    ) {
      onClickOutside?.();
    }
  }, []);

  /** Create the popper instance when the component mounts */
  useEffect(() => {
    if (!parentRef.current || !popperRef.current) return;
    if (placement) options.placement = placement;

    const instance = createPopper(
      parentRef.current,
      popperRef.current,
      options,
    );

    return () => {
      instance.destroy();
    };
  }, [options]);

  /** Focus when opened, adds click outside listener */
  useEffect(() => {
    if (!isOpen) return;

    if (autoFocus) {
      const focusable = popperRef.current?.firstChild as HTMLElement | null;
      focusable?.focus();
    }

    if (!onClickOutside) return;

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  const contentStyle = useMemo(() => {
    return {
      ...additionalStyles,
      position: 'absolute',
      zIndex: 1000,
    } as CSSProperties;
  }, [additionalStyles]);

  return (
    <>
      <div ref={parentRef}>{children}</div>
      {createPortal(
        <div ref={popperRef} style={isOpen ? contentStyle : {}}>
          {isOpen && popperContent}
        </div>,
        document.body,
      )}
    </>
  );
}
