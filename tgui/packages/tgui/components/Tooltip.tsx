
import { Placement } from '@popperjs/core';
import { Component, findDOMfromVNode, InfernoNode } from 'inferno';
import { Popper } from "./Popper";

const DEFAULT_PLACEMENT = "top";

type TooltipProps = {
  children?: InfernoNode;
  content: InfernoNode;
  position?: Placement,
};

type TooltipState = {
  hovered: boolean;
};

const DISABLE_EVENT_LISTENERS = [{
  name: "eventListeners",
  enabled: false,
}];

export class Tooltip extends Component<TooltipProps, TooltipState> {
  state = {
    hovered: false,
  };

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

    domNode.addEventListener("mouseenter", () => {
      this.setState({
        hovered: true,
      });
    });

    domNode.addEventListener("mouseleave", () => {
      this.setState({
        hovered: false,
      });
    });
  }

  render() {
    return (
      <Popper
        options={{
          placement: this.props.position || "auto",
          modifiers: DISABLE_EVENT_LISTENERS,
        }}
        popperContent={
          <div
            className="Tooltip"
            style={{
              opacity: this.state.hovered ? 1 : 0,
            }}>
            {this.props.content}
          </div>
        }
        additionalStyles={{
          "pointer-events": "none",
          "z-index": 2,
        }}>
        {this.props.children}
      </Popper>
    );
  }
}
