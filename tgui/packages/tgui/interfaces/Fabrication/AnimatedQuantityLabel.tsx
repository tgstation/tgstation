import { Component, createRef } from 'inferno';
import { formatSiUnit } from '../../format';

/**
 * The properties of an animated quantity label.
 */
export interface AnimatedQuantityLabelProps {
  /**
   * The target value to approach.
   */
  targetValue: number;
}

/**
 * Quantity labels are animated at roughly 60 frames per second.
 */
const SIXTY_HZ = 1_000.0 / 60.0;

/**
 * An animated quantity label. Shows an SI-encoded number, and animates it
 * towards towards the provided target value.
 */
export class AnimatedQuantityLabel extends Component<AnimatedQuantityLabelProps> {
  /**
   * The inner `<span/>` being updated sixty times per second.
   */
  protected ref = createRef<HTMLSpanElement>();

  /**
   * The interval being used to update the inner span.
   */
  protected interval?: NodeJS.Timeout;

  /**
   * The current value. This values approaches the target value.
   */
  protected currentValue: number = 0;

  constructor(props: AnimatedQuantityLabelProps) {
    super(props);

    this.currentValue = props.targetValue;
  }

  componentWillUnmount() {
    // Stop animating when the component is unmounted.
    this.stopTicking();
  }

  shouldComponentUpdate(newProps: AnimatedQuantityLabelProps) {
    if (newProps.targetValue !== this.props.targetValue) {
      // The target value has been adjusted; start animating if we aren't
      // already.
      this.startTicking();
    }

    // Never re-render this component; we handle it manually. Inferno is too
    // slow to handle 60 frames per second in IE.
    return false;
  }

  /**
   * Starts animating the inner span. If the inner span is already animating,
   * this is a no-op.
   */
  protected startTicking() {
    if (this.interval !== undefined) {
      return;
    }

    this.interval = setInterval(() => this.tick(), SIXTY_HZ);
  }

  /**
   * Stops animating the inner span.
   */
  protected stopTicking() {
    if (this.interval !== undefined) {
      clearInterval(this.interval);

      this.interval = undefined;
    }
  }

  /**
   * Steps forward one frame.
   */
  protected tick() {
    const { currentValue } = this;
    const { targetValue } = this.props;

    this.currentValue += (targetValue - currentValue) / SIXTY_HZ;

    if (Math.abs(targetValue - currentValue) < 1) {
      this.stopTicking();
    }

    if (this.ref.current) {
      this.ref.current.innerText = this.getText();
    }
  }

  /**
   * Returns the inner text of the span.
   */
  protected getText() {
    return formatSiUnit(this.currentValue, 0);
  }

  render() {
    // Only executes for the first render; afterwards, we directly animate
    // the inner contents using the ref.
    return <span ref={this.ref}>{this.getText()}</span>;
  }
}
