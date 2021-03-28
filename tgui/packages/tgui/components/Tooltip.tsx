import { createPopper, Placement } from '@popperjs/core';
import { Component, createPortal, createRef, InfernoNode } from 'inferno';

const DEFAULT_PLACEMENT = "top";

type TooltipProps = {
  children?: InfernoNode;
  content: string;
  position?: Placement;
};

type TooltipState = {
  hovered: boolean;
};

export class Tooltip extends Component<TooltipProps, TooltipState> {
  containerRef = createRef<HTMLSpanElement>();
  tooltipRef = createRef<HTMLDivElement>();
  portalNode = document.createElement("div");

  constructor() {
    super();

    this.onMouseEnter = this.onMouseEnter.bind(this);
    this.onMouseLeave = this.onMouseLeave.bind(this);

    this.state = {
      hovered: false,
    };
  }

  componentDidMount() {
    document.body.appendChild(this.portalNode);

    createPopper(this.containerRef.current, this.tooltipRef.current, {
      placement: this.props.position || DEFAULT_PLACEMENT,
    });
  }

  componentWillUnmount() {
    document.body.removeChild(this.portalNode);
    this.portalNode = null;
  }

  onMouseEnter() {
    this.setState({
      hovered: true,
    });
  }

  onMouseLeave() {
    this.setState({
      hovered: false,
    });
  }

  render() {
    const {
      children,
      content,
    }: TooltipProps = this.props;

    return (
      <>
        <span
          ref={this.containerRef}
          onmouseenter={this.onMouseEnter}
          onmouseleave={this.onMouseLeave}
        >
          { children }
        </span>

        {createPortal(
          <div class="Tooltip" ref={this.tooltipRef} style={{
            opacity: this.state.hovered ? 1 : 0,
          }}>
            {content}
          </div>,
          this.portalNode,
        )}
      </>
    );
  }
}
