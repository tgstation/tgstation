/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { BooleanLike, classes } from 'common/react';
import { PropsWithChildren, ReactNode } from 'react';
import { Box, unit } from './Box';
import { Divider } from './Divider';
import { Tooltip } from './Tooltip';

export const LabeledList = (props: PropsWithChildren) => {
  const { children } = props;
  return <table className="LabeledList">{children}</table>;
};

type LabeledListItemProps = Partial<{
  buttons: ReactNode;
  className: string | BooleanLike;
  color: string;
  key: string | number;
  label: string | ReactNode | BooleanLike;
  labelColor: string;
  labelWrap: boolean;
  textAlign: string;
  /** @deprecated */
  content: any;
  children: ReactNode;
  verticalAlign: string;
  tooltip: string;
}>;

const LabeledListItem = (props: LabeledListItemProps) => {
  const {
    className,
    label,
    labelColor = 'label',
    labelWrap,
    color,
    textAlign,
    buttons,
    content,
    children,
    verticalAlign = 'baseline',
    tooltip,
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
            borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
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
        {content}
        {children}
      </Box>
      {buttons && (
        <td className="LabeledList__cell LabeledList__buttons">{buttons}</td>
      )}
    </tr>
  );
};

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
          paddingTop: padding,
          paddingBottom: padding,
        }}>
        <Divider />
      </td>
    </tr>
  );
};

LabeledList.Item = LabeledListItem;
LabeledList.Divider = LabeledListDivider;
