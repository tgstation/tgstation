/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';

type Props = Partial<{
  collapsing: boolean;
}> &
  BoxProps;

export function Table(props: Props) {
  const { className, collapsing, children, ...rest } = props;

  return (
    <table
      className={classes([
        'Table',
        collapsing && 'Table--collapsing',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      <tbody>{children}</tbody>
    </table>
  );
}

type RowProps = Partial<{
  header: boolean;
}> &
  BoxProps;

export function TableRow(props: RowProps) {
  const { className, header, ...rest } = props;

  return (
    <tr
      className={classes([
        'Table__row',
        header && 'Table__row--header',
        className,
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(rest)}
    />
  );
}

type CellProps = Partial<{
  collapsing: boolean;
  header: boolean;
}> &
  BoxProps;

export function TableCell(props: CellProps) {
  const { className, collapsing, header, ...rest } = props;

  return (
    <td
      className={classes([
        'Table__cell',
        collapsing && 'Table__cell--collapsing',
        header && 'Table__cell--header',
        className,
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(rest)}
    />
  );
}

Table.Row = TableRow; 
Table.Cell = TableCell;
