/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { map, zipWith } from 'common/collections';
import { pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { Box } from './Box';

const normalizeData = (data, scale, rangeX, rangeY) => {
  if (data.length === 0) {
    return [];
  }
  const min = zipWith(Math.min)(...data);
  const max = zipWith(Math.max)(...data);
  if (rangeX !== undefined) {
    min[0] = rangeX[0];
    max[0] = rangeX[1];
  }
  if (rangeY !== undefined) {
    min[1] = rangeY[0];
    max[1] = rangeY[1];
  }
  const normalized = map(point => {
    return zipWith((value, min, max, scale) => {
      return (value - min) / (max - min) * scale;
    })(point, min, max, scale);
  })(data);
  return normalized;
};

const dataToPolylinePoints = data => {
  let points = '';
  for (let i = 0; i < data.length; i++) {
    const point = data[i];
    points += point[0] + ',' + point[1] + ' ';
  }
  return points;
};

class LineChart extends Component {
  constructor(props) {
    super(props);
    this.ref = createRef();
    this.state = {
      // Initial guess
      viewBox: [600, 200],
    };
    this.handleResize = () => {
      const element = this.ref.current;
      this.setState({
        viewBox: [element.offsetWidth, element.offsetHeight],
      });
    };
  }

  componentDidMount() {
    window.addEventListener('resize', this.handleResize);
    this.handleResize();
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.handleResize);
  }

  render() {
    const {
      data = [],
      rangeX,
      rangeY,
      fillColor = 'none',
      strokeColor = '#ffffff',
      strokeWidth = 2,
      ...rest
    } = this.props;
    const { viewBox } = this.state;
    const normalized = normalizeData(data, viewBox, rangeX, rangeY);
    // Push data outside viewBox and form a fillable polygon
    if (normalized.length > 0) {
      const first = normalized[0];
      const last = normalized[normalized.length - 1];
      normalized.push([viewBox[0] + strokeWidth, last[1]]);
      normalized.push([viewBox[0] + strokeWidth, -strokeWidth]);
      normalized.push([-strokeWidth, -strokeWidth]);
      normalized.push([-strokeWidth, first[1]]);
    }
    const points = dataToPolylinePoints(normalized);
    return (
      <Box position="relative" {...rest}>
        {props => (
          <div ref={this.ref} {...props}>
            <svg
              viewBox={`0 0 ${viewBox[0]} ${viewBox[1]}`}
              preserveAspectRatio="none"
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                overflow: 'hidden',
              }}>
              <polyline
                transform={`scale(1, -1) translate(0, -${viewBox[1]})`}
                fill={fillColor}
                stroke={strokeColor}
                strokeWidth={strokeWidth}
                points={points} />
            </svg>
          </div>
        )}
      </Box>
    );
  }
}

LineChart.defaultHooks = pureComponentHooks;

const Stub = props => null;

// IE8: No inline svg support
export const Chart = {
  Line: Byond.IS_LTE_IE8 ? Stub : LineChart,
};
