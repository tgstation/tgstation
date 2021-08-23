
import { Placement } from '@popperjs/core';
import { Component, createRef, findDOMfromVNode, InfernoNode, RefObject } from 'inferno';
import { Popper } from "./Popper";

const TOOLTIP_UNRENDER_TIME = 200;

type TooltipProps = {
  children?: InfernoNode;
  content: string;
  position?: Placement,
};

type TooltipState = {
  hovered: boolean;
  renderInner: boolean;
};

export class Tooltip extends Component<TooltipProps, TooltipState> {
  tooltipRef: RefObject<HTMLDivElement> = createRef();
  unsetHoverTimeout?: NodeJS.Timeout;
    
  state = {
    hovered: false,
    renderInner: false,
  }

  constructor() {
    super();

    this.onHover = this.onHover.bind(this);
    this.onUnhover = this.onUnhover.bind(this);
  }

  onHover() {
    this.setState({
      hovered: true,
      renderInner: true,
    });

    if (this.unsetHoverTimeout) {
      clearTimeout(this.unsetHoverTimeout);
    }
  }

  onUnhover() {
    this.setState({
      hovered: false,
    });

    this.unsetHoverTimeout = setTimeout(() => {
      this.setState({
        renderInner: false,
      });
    }, TOOLTIP_UNRENDER_TIME);
  }

  componentWillUnmount() {
    if (this.unsetHoverTimeout) {
      clearTimeout(this.unsetHoverTimeout);
    }
  }

  componentDidMount() {
    // HACK: We don't want to create a wrapper, as it could break the layout
    // of consumers, so we do the inferno equivalent of `findDOMNode(this)`.
    // My attempt to avoid this was a render prop that passed in
    // callbacks to onmouseenter and onmouseleave, but this was unwiedly
    // to consumers, specifically buttons.
    // This code is copied from `findDOMNode` in inferno-extras.
    // Because this component is written in TypeScript, we will know
    // immediately if this internal variable is removed.
    const domNode = findDOMfromVNode(this.$LI, true);
      
    if (!domNode) {
      return;
    }

    domNode.addEventListener("mouseenter", this.onHover);
    domNode.addEventListener("mouseleave", this.onUnhover);
  }

  componentDidUpdate(prevProps, prevState: TooltipState) {
    if (this.state.hovered !== prevState.hovered && this.state.hovered) {
      const tooltip = this.tooltipRef.current;
      if (!tooltip) {
        return;
      }

      tooltip.style.opacity = "0";

      // This forces the CSS transition to start when we set the opacity to 1
      window.getComputedStyle(tooltip).opacity;

      tooltip.style.opacity = "1";
    }
  }

  render() {
    return (
      <Popper
        options={{
          placement: this.props.position || "auto",
        }}
        popperContent={
          this.state.renderInner ? (
            <div
              className="Tooltip"
              ref={this.tooltipRef}
              style={{
                opacity: this.state.hovered ? 1 : 0,
              }}>
              {this.props.content}
            </div>
          ) : null
        }
        additionalStyles={{
          "pointer-events": "none",
        }}>
        {this.props.children}
      </Popper>
    );
  }
}
