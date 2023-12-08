/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { ReactNode, RefObject, createRef, useEffect } from 'react';
import { addScrollableNode, removeScrollableNode } from '../events';
import { canRender, classes } from 'common/react';

export type SectionProps = Partial<{
  buttons: ReactNode;
  fill: boolean;
  fitted: boolean;
  scrollable: boolean;
  scrollableHorizontal: boolean;
  title: ReactNode;
  /** @member Allows external control of scrolling. */
  scrollableRef: RefObject<HTMLDivElement>;
  /** @member Callback function for the `scroll` event */
  onScroll: ((this: GlobalEventHandlers, ev: Event) => any) | null;
}> &
  BoxProps;

export const Section = (props: SectionProps) => {
  const {
    className,
    title,
    buttons,
    fill,
    fitted,
    scrollable,
    scrollableHorizontal,
    children,
    onScroll,
    ...rest
  } = props;

  const scrollableRef = props.scrollableRef || createRef();
  const hasTitle = canRender(title) || canRender(buttons);

  useEffect(() => {
    if (scrollable || scrollableHorizontal) {
      addScrollableNode(scrollableRef.current as HTMLElement);
      if (onScroll && scrollableRef.current) {
        scrollableRef.current.onscroll = onScroll;
      }
    }
    return () => {
      if (scrollable || scrollableHorizontal) {
        removeScrollableNode(scrollableRef.current as HTMLElement);
      }
    };
  }, []);

  return (
    <div
      className={classes([
        'Section',
        fill && 'Section--fill',
        fitted && 'Section--fitted',
        scrollable && 'Section--scrollable',
        scrollableHorizontal && 'Section--scrollableHorizontal',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}>
      {hasTitle && (
        <div className="Section__title">
          <span className="Section__titleText">{title}</span>
          <div className="Section__buttons">{buttons}</div>
        </div>
      )}
      <div className="Section__rest">
        <div onScroll={onScroll as any} className="Section__content">
          {children}
        </div>
      </div>
    </div>
  );
};
