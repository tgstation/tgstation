/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Component, createRef } from 'inferno';

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
   * If provided, a function that formats the inner string. By default, the
   * number itself, rounded off to `significantFigures`.
   */
  format?: (value: number) => string;

  /**
   * If provided, the number of decimal places to render. By default, zero
   * significant figures (no decimal places). If `format` is present, this does
   * nothing.
   */
  significantFigures?: number;
};

/**
 * Animated numbers are animated at roughly 60 frames per second.
 */
const SIXTY_HZ = 1_000.0 / 60.0;

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
    if (!isSafeNumber(newProps.value)) {
      // If the new value isn't safe, don't even bother.
      return false;
    }

    if (newProps.value !== this.props.value) {
      // The target value has been adjusted; start animating if we aren't
      // already.
      this.startTicking();
    }

    // We render the inner `span` directly using a ref to bypass inferno diffing
    // and reach 60 frames per second--tell inferno not to re-render this tree.
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

    this.currentValue += (value - currentValue) / SIXTY_HZ;

    if (Math.abs(value - this.currentValue) < EPSILON) {
      this.currentValue = value;
      this.stopTicking();
    }

    if (this.ref.current) {
      // Directly update the inner span, without bothering inferno.
      this.ref.current.innerText = this.getText();
    }
  }

  /**
   * Gets the inner text of the span.
   */
  getText() {
    const { format, significantFigures } = this.props;

    return format
      ? format(this.currentValue)
      : this.currentValue.toFixed(significantFigures ?? 0);
  }

  render() {
    return <span ref={this.ref}>{this.getText()}</span>;
  }
}
