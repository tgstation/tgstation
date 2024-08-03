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
    buttonsAlt: boolean;
    children: ReactNode;
    className: string;
    color: string;
    disabled: BooleanLike;
    dmFallback: ReactNode;
    dmIcon: string | null;
    dmIconState: string | null;
    fluid: boolean;
    imageSize: number;
    onClick: (e: any) => void;
    onRightClick: (e: any) => void;
    selected: BooleanLike;
    title: string;
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
    buttonsAlt,
    children,
    className,
    color,
    disabled,
    dmFallback,
    dmIcon,
    dmIconState,
    fluid,
    imageSize = 64,
    onClick,
    onRightClick,
    selected,
    title,
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
      style={{ width: !fluid ? `calc(${imageSize}px + 0.5em + 2px)` : 'auto' }}
    >
      <div className={classes(['ImageButton__image'])}>
        {base64 || asset || assetResolve ? (
          <Image
            className={classes([!base64 && !assetResolve && asset])}
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
      {fluid ? (
        <div className={classes(['ImageButton__fluid--info'])}>
          {title && (
            <span
              className={classes([
                'ImageButton__fluid--title',
                children && 'ImageButton__fluid--title--divider',
              ])}
            >
              {title}
            </span>
          )}
          {children && (
            <span className={classes(['ImageButton__fluid--content'])}>
              {children}
            </span>
          )}
        </div>
      ) : (
        children && (
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
        )
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
    <div
      className={classes([
        !fluid ? 'ImageButton' : 'ImageButton__fluid',
        className,
      ])}
      {...computeBoxProps(rest)}
    >
      {buttonContent}
      {buttons && (
        <div
          className={classes([
            'ImageButton__buttons',
            buttonsAlt && 'ImageButton__buttons--alt',
            !children && 'ImageButton__buttons--noContent',
            fluid && color && typeof color === 'string'
              ? 'ImageButton__buttons--color--' + color
              : fluid && 'ImageButton__buttons--color--default',
          ])}
          style={{
            width: buttonsAlt ? `${imageSize}px` : 'auto',
          }}
        >
          {buttons}
        </div>
      )}
    </div>
  );
};
