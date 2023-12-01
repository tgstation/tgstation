/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes, pureComponentHooks } from 'common/react';
import { InfernoNode } from 'inferno';
import { Box, unit } from './Box';
import { Divider } from './Divider';
import { Tooltip } from './Tooltip';

export const LabeledList = (props: { children?: any }) => {
  const { children } = props;
  return <table className="LabeledList">{children}</table>;
};

LabeledList.defaultHooks = pureComponentHooks;

type LabeledListItemProps = Partial<{
  buttons: InfernoNode;
  children: InfernoNode;
  className: string | BooleanLike;
  color: string;
  key: string | number;
  label: string | InfernoNode | BooleanLike;
  labelColor: string;
  labelWrap: boolean;
  textAlign: string;
  tooltip: string;
  verticalAlign: string;
}>;

const LabeledListItem = (props: LabeledListItemProps) => {
  const {
    buttons,
    children,
    className,
    color,
    label,
    labelColor = 'label',
    labelWrap,
    textAlign,
    tooltip,
    verticalAlign = 'baseline',
  } = props;

  let innerLabel;
  if (label) {
    innerLabel = label;
    if (typeof label === 'string') innerLabel += ':';
  }

  if (tooltip !== undefined) {
    innerLabel = (
      <Tooltip content={tooltip}>
        <Box
          as="span"
          style={{
            'border-bottom': '2px dotted rgba(255, 255, 255, 0.8)',
          }}>
          {innerLabel}
        </Box>
      </Tooltip>
    );
  }

  let labelChild = (
    <Box
      as="td"
      color={labelColor}
      className={classes([
        'LabeledList__cell',
        // Kinda flipped because we want nowrap as default. Cleaner CSS this way though.
        !labelWrap && 'LabeledList__label--nowrap',
      ])}
      verticalAlign={verticalAlign}>
      {innerLabel}
    </Box>
  );

  return (
    <tr className={classes(['LabeledList__row', className])}>
      {labelChild}
      <Box
        as="td"
        color={color}
        textAlign={textAlign}
        className={classes(['LabeledList__cell', 'LabeledList__content'])}
        colSpan={buttons ? undefined : 2}
        verticalAlign={verticalAlign}>
        {children}
      </Box>
      {buttons && (
        <td className="LabeledList__cell LabeledList__buttons">{buttons}</td>
      )}
    </tr>
  );
};

LabeledListItem.defaultHooks = pureComponentHooks;

type LabeledListDividerProps = {
  size?: number;
};

const LabeledListDivider = (props: LabeledListDividerProps) => {
  const padding = props.size ? unit(Math.max(0, props.size - 1)) : 0;
  return (
    <tr className="LabeledList__row">
      <td
        colSpan={3}
        style={{
          'padding-top': padding,
          'padding-bottom': padding,
        }}>
        <Divider />
      </td>
    </tr>
  );
};

LabeledListDivider.defaultHooks = pureComponentHooks;

LabeledList.Item = LabeledListItem;
LabeledList.Divider = LabeledListDivider;
