/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';

import { computeBoxClassName, computeBoxProps } from './Box';

export const Table = (props) => {
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
};

export const TableRow = (props) => {
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
};

export const TableCell = (props) => {
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
};

Table.Row = TableRow;
Table.Cell = TableCell;
