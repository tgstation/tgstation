import { createPopper, Placement, VirtualElement } from '@popperjs/core';
import { Component, findDOMfromVNode, InfernoNode, render } from 'inferno';

type TooltipProps = {
  children?: InfernoNode;
  content: InfernoNode;
  position?: Placement;
};

type TooltipState = {
  hovered: boolean;
};

const DEFAULT_OPTIONS = {
  modifiers: [
    {
      name: 'eventListeners',
      enabled: false,
    },
  ],
};

const NULL_RECT = {
  width: 0,
  height: 0,
  top: 0,
  right: 0,
  bottom: 0,
  left: 0,
};

export class Tooltip extends Component<TooltipProps, TooltipState> {
  // Mounting poppers is really laggy because popper.js is very slow.
  // Thus, instead of using the Popper component, Tooltip creates ONE popper
  // and stores every tooltip inside that.
  // This means you can never have two tooltips at once, for instance.
  static renderedTooltip: HTMLDivElement | undefined;
  static singletonPopper: ReturnType<typeof createPopper> | undefined;
  static currentHoveredElement: Element | undefined;
  static virtualElement: VirtualElement = {
    // prettier-ignore
    getBoundingClientRect: () => (
      Tooltip.currentHoveredElement?.getBoundingClientRect()
        ?? NULL_RECT
    ),
  };

  getDOMNode() {
    // HACK: We don't want to create a wrapper, as it could break the layout
    // of consumers, so we do the inferno equivalent of `findDOMNode(this)`.
    // My attempt to avoid this was a render prop that passed in
    // callbacks to onmouseenter and onmouseleave, but this was unwiedly
    // to consumers, specifically buttons.
    // This code is copied from `findDOMNode` in inferno-extras.
    // Because this component is written in TypeScript, we will know
    // immediately if this internal variable is removed.
    return findDOMfromVNode(this.$LI, true);
  }

  componentDidMount() {
    const domNode = this.getDOMNode();

    if (!domNode) {
      return;
    }

    domNode.addEventListener('mouseenter', () => {
      let renderedTooltip = Tooltip.renderedTooltip;
      if (renderedTooltip === undefined) {
        renderedTooltip = document.createElement('div');
        renderedTooltip.className = 'Tooltip';
        document.body.appendChild(renderedTooltip);
        Tooltip.renderedTooltip = renderedTooltip;
      }

      Tooltip.currentHoveredElement = domNode;

      renderedTooltip.style.opacity = '1';

      this.renderPopperContent();
    });

    domNode.addEventListener('mouseleave', () => {
      this.fadeOut();
    });
  }

  fadeOut() {
    if (Tooltip.currentHoveredElement !== this.getDOMNode()) {
      return;
    }

    Tooltip.currentHoveredElement = undefined;
    Tooltip.renderedTooltip!.style.opacity = '0';
  }

  renderPopperContent() {
    const renderedTooltip = Tooltip.renderedTooltip;
    if (!renderedTooltip) {
      return;
    }

    render(
      <span>{this.props.content}</span>,
      renderedTooltip,
      () => {
        let singletonPopper = Tooltip.singletonPopper;
        if (singletonPopper === undefined) {
          singletonPopper = createPopper(
            Tooltip.virtualElement,
            renderedTooltip!,
            {
              ...DEFAULT_OPTIONS,
              placement: this.props.position || 'auto',
            }
          );

          Tooltip.singletonPopper = singletonPopper;
        } else {
          singletonPopper.setOptions({
            ...DEFAULT_OPTIONS,
            placement: this.props.position || 'auto',
          });

          singletonPopper.update();
        }
      },
      this.context
    );
  }

  componentDidUpdate() {
    if (Tooltip.currentHoveredElement !== this.getDOMNode()) {
      return;
    }

    this.renderPopperContent();
  }

  componentWillUnmount() {
    this.fadeOut();
  }

  render() {
    return this.props.children;
  }
}
