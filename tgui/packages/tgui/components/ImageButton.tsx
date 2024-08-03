/**
 * @file
 * @copyright 2024 Aylong (https://github.com/AyIong)
 * @license MIT
 */

import { Placement } from '@popperjs/core';
import { BooleanLike, classes } from 'common/react';
import { ReactNode } from 'react';

import { resolveAsset } from '../assets';
import { BoxProps, computeBoxProps } from './Box';
import { DmIcon } from './DmIcon';
import { Icon } from './Icon';
import { Image } from './Image';
import { Stack } from './Stack';
import { Tooltip } from './Tooltip';

type Props = Required<{}> &
  Partial<{
    asset: string;
    assetResolve: string;
    base64: string;
    buttons: ReactNode;
    children: ReactNode;
    className: string;
    color: string;
    disabled: BooleanLike;
    dmFallback: ReactNode;
    dmIcon: string;
    dmIconState: string;
    imageSize: number;
    onClick: (e: any) => void;
    onRightClick: (e: any) => void;
    selected: BooleanLike;
    tooltip: ReactNode;
    tooltipPosition: Placement;
  }> &
  BoxProps;

export const ImageButton = (props: Props) => {
  const {
    asset,
    assetResolve,
    base64,
    buttons,
    children,
    className,
    color,
    disabled,
    dmFallback,
    dmIcon,
    dmIconState,
    imageSize = 64,
    onClick,
    onRightClick,
    selected,
    tooltip,
    tooltipPosition,
    ...rest
  } = props;

  const getFallback = (iconName: string, iconSpin: boolean) => (
    <Stack height={`${imageSize}px`} width={`${imageSize}px`}>
      <Stack.Item grow textAlign="center" align="center">
        <Icon
          spin={iconSpin}
          name={iconName}
          color="gray"
          style={{ fontSize: `calc(${imageSize}px * 0.75)` }}
        />
      </Stack.Item>
    </Stack>
  );

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
        ) : dmIcon && dmIconState ? (
          <DmIcon
            icon={dmIcon}
            icon_state={dmIconState}
            fallback={dmFallback ? dmFallback : getFallback('spinner', true)}
            height={`${imageSize}px`}
            width={`${imageSize}px`}
          />
        ) : (
          getFallback('question', false)
        )}
      </div>
      {children && (
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
      )}
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
    <div className={classes(['ImageButton', className])}>
      {buttonContent}
      {buttons && (
        <div
          className={classes([
            'ImageButton__buttons',
            !children && 'ImageButton__buttons--noContent',
          ])}
        >
          {buttons}
        </div>
      )}
    </div>
  );
};
