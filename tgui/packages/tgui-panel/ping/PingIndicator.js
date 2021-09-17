/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Color } from 'common/color';
import { toFixed } from 'common/math';
import { useSelector } from 'common/redux';
import { Box } from 'tgui/components';
import { selectPing } from './selectors';

export const PingIndicator = (props, context) => {
  const ping = useSelector(context, selectPing);
  const color = Color.lookup(ping.networkQuality, [
    new Color(220, 40, 40),
    new Color(220, 200, 40),
    new Color(60, 220, 40),
  ]);
  const roundtrip = ping.roundtrip
    ? toFixed(ping.roundtrip)
    : '--';
  return (
    <div className="Ping">
      <Box
        className="Ping__indicator"
        backgroundColor={color} />
      {roundtrip}
    </div>
  );
};
