/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { canRender, classes } from 'common/react';
import { forwardRef, ReactNode, RefObject, useEffect } from 'react';

import { addScrollableNode, removeScrollableNode } from '../events';
import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';

export type SectionProps = Partial<{
  buttons: ReactNode;
  fill: boolean;
  fitted: boolean;
  scrollable: boolean;
  scrollableHorizontal: boolean;
  title: ReactNode;
  /** @member Callback function for the `scroll` event */
  onScroll: ((this: GlobalEventHandlers, ev: Event) => any) | null;
}> &
  BoxProps;

export const Section = forwardRef(
  (props: SectionProps, ref: RefObject<HTMLDivElement>) => {
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

    const hasTitle = canRender(title) || canRender(buttons);

    useEffect(() => {
      if (!ref?.current) return;

      if (scrollable || scrollableHorizontal) {
        addScrollableNode(ref.current);
        if (onScroll && ref.current) {
          ref.current.onscroll = onScroll;
        }
      }
      return () => {
        if (!ref?.current) return;

        if (scrollable || scrollableHorizontal) {
          removeScrollableNode(ref.current);
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
        {...computeBoxProps(rest)}
        ref={ref}
      >
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
  },
);
