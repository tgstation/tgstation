/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { clamp, toFixed } from 'common/math';
import { Component, createRef } from 'react';

const isSafeNumber = (value: number) => {
  // prettier-ignore
  return typeof value === 'number'
    && Number.isFinite(value)
    && !Number.isNaN(value);
};

export type AnimatedNumberProps = {
  /**
   * The target value to approach.
   */
  value: number;

  /**
   * If provided, the initial value displayed. By default, the same as `value`.
   * If `initial` and `value` are different, the component immediately starts
   * animating.
   */
  initial?: number;

  /**
   * If provided, a function that formats the inner string. By default,
   * attempts to match the numeric precision of `value`.
   */
  format?: (value: number) => string;
};

/**
 * Animated numbers are animated at roughly 60 frames per second.
 */
const SIXTY_HZ = 1_000.0 / 60.0;

/**
 * The exponential moving average coefficient. Larger values result in a faster
 * convergence.
 */
const Q = 0.8333;

/**
 * A small number.
 */
const EPSILON = 10e-4;

/**
 * An animated number label. Shows a number, formatted with an optionally
 * provided function, and animates it towards its target value.
 */
export class AnimatedNumber extends Component<AnimatedNumberProps> {
  /**
   * The inner `<span/>` being updated sixty times per second.
   */
  ref = createRef<HTMLSpanElement>();

  /**
   * The interval being used to update the inner span.
   */
  interval?: NodeJS.Timeout;

  /**
   * The current value. This values approaches the target value.
   */
  currentValue: number = 0;

  constructor(props: AnimatedNumberProps) {
    super(props);

    const { initial, value } = props;

    if (initial !== undefined && isSafeNumber(initial)) {
      this.currentValue = initial;
    } else if (isSafeNumber(value)) {
      this.currentValue = value;
    }
  }

  componentDidMount() {
    if (this.currentValue !== this.props.value) {
      this.startTicking();
    }
  }

  componentWillUnmount() {
    // Stop animating when the component is unmounted.
    this.stopTicking();
  }

  shouldComponentUpdate(newProps: AnimatedNumberProps) {
    if (newProps.value !== this.props.value) {
      // The target value has been adjusted; start animating if we aren't
      // already.
      this.startTicking();
    }

    return false;
  }

  /**
   * Starts animating the inner span. If the inner span is already animating,
   * this is a no-op.
   */
  startTicking() {
    if (this.interval !== undefined) {
      // We're already ticking; do nothing.
      return;
    }

    this.interval = setInterval(() => this.tick(), SIXTY_HZ);
  }

  /**
   * Stops animating the inner span.
   */
  stopTicking() {
    if (this.interval === undefined) {
      // We're not ticking; do nothing.
      return;
    }

    clearInterval(this.interval);

    this.interval = undefined;
  }

  /**
   * Steps forward one frame.
   */
  tick() {
    const { currentValue } = this;
    const { value } = this.props;

    if (isSafeNumber(value)) {
      // Converge towards the value.
      this.currentValue = currentValue * Q + value * (1 - Q);
    } else {
      // If the value is unsafe, we're never going to converge, so stop ticking.
      this.stopTicking();
    }

    if (
      Math.abs(value - this.currentValue) < Math.max(EPSILON, EPSILON * value)
    ) {
      // We're about as close as we're going to get--snap to the value and
      // stop ticking.
      this.currentValue = value;
      this.stopTicking();
    }

    if (this.ref.current) {
      this.ref.current.textContent = this.getText();
    }
  }

  /**
   * Gets the inner text of the span.
   */
  getText() {
    const { props, currentValue } = this;
    const { format, value } = props;

    if (!isSafeNumber(value)) {
      return String(value);
    }

    if (format) {
      return format(this.currentValue);
    }

    const fraction = String(value).split('.')[1];
    const precision = fraction ? fraction.length : 0;

    return toFixed(currentValue, clamp(precision, 0, 8));
  }

  render() {
    return <span ref={this.ref}>{this.getText()}</span>;
  }
}
