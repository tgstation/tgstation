/**
 * @file
 * @copyright 2024 Aylong (https://github.com/AyIong)
 * @license MIT
 */

import { Placement } from '@popperjs/core';
import { BooleanLike, classes } from 'common/react';
import {
  ChangeEvent,
  createRef,
  MouseEvent,
  ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';

import { resolveAsset } from '../assets';
import { Box, BoxProps, computeBoxClassName, computeBoxProps } from './Box';
import { Image } from './Image';
import { DmIcon } from './DmIcon';
import { Tooltip } from './Tooltip';

type Props = Required<{}> &
  Partial<{
    asset: string;
    base64: string;
    buttons: ReactNode;
    children: ReactNode;
    className: string;
    color: string;
    disabled: BooleanLike;
    dmIcon: string;
    dmIconState: string;
    dmFallback: ReactNode;
    imageSize: number;
    onClick: (e: any) => void;
    onRightClick: (e: any) => void;
    assetResolve: string;
    selected: BooleanLike;
    tooltip: ReactNode;
    tooltipPosition: Placement;
  }> &
  BoxProps;

export const ImageButton = (props: Props) => {
  const {
    asset,
    base64,
    buttons,
    children,
    className,
    color,
    disabled,
    dmIcon,
    dmIconState,
    dmFallback,
    imageSize = 64,
    onClick,
    onRightClick,
    assetResolve,
    selected,
    tooltip,
    tooltipPosition,
    ...rest
  } = props;

  let buttonContent = (
    <div
      className={classes([
        'ImageButton__container',
        selected && 'ImageButton--selected',
        disabled && 'ImageButton--disabled',
        color && typeof color === 'string'
          ? 'ImageButton--color--' + color
          : 'ImageButton--color--default',
      ])}
      tabIndex={!disabled ? 0 : undefined}
      onClick={(event) => {
        if (!disabled && onClick) {
          onClick(event);
        }
      }}
      onContextMenu={(event) => {
        event.preventDefault();
        if (!disabled && onRightClick) {
          onRightClick(event);
        }
      }}
      {...computeBoxProps(rest)}
      style={{ width: `calc(${imageSize}px + 0.5em + 2px)` }}
    >
      <div className={classes(['ImageButton__image'])}>
        {base64 || asset || assetResolve ? (
          <Image
            className={classes([asset])}
            src={
              assetResolve
                ? resolveAsset(assetResolve)
                : base64 && `data:image/jpeg;base64,${base64}`
            }
            height={`${imageSize}px`}
            width={`${imageSize}px`}
          />
        ) : (
          dmIcon &&
          dmIconState && (
            <DmIcon
              icon={dmIcon}
              icon_state={dmIconState}
              fallback={dmIcon && dmIconState && dmFallback}
              height={`${imageSize}px`}
              width={`${imageSize}px`}
            />
          )
        )}
      </div>
      <span
        className={classes([
          'ImageButton__content',
          selected && 'ImageButton__content--selected',
          disabled && 'ImageButton__content--disabled',
          color && typeof color === 'string'
            ? 'ImageButton__content--color--' + color
            : 'ImageButton__content--color--default',
        ])}
      >
        {children}
      </span>
    </div>
  );

  if (tooltip) {
    buttonContent = (
      <Tooltip content={tooltip} position={tooltipPosition as Placement}>
        {buttonContent}
      </Tooltip>
    );
  }

  return (
    <div className={classes(['ImageButton'])}>
      {buttonContent}
      {buttons && (
        <div className={classes(['ImageButton__buttons'])}>{buttons}</div>
      )}
    </div>
  );
};
