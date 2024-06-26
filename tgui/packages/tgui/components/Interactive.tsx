/**
 * MIT License
 * https://github.com/omgovich/react-colorful/
 *
 * Copyright (c) 2020 Vlad Shilov <omgovich@ya.ru>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import { clamp } from 'common/math';
import { Component, InfernoNode, createRef, RefObject } from 'inferno';

export interface Interaction {
  left: number;
  top: number;
}

// Finds the proper window object to fix iframe embedding issues
const getParentWindow = (node?: HTMLDivElement | null): Window => {
  return (node && node.ownerDocument.defaultView) || self;
};

// Returns a relative position of the pointer inside the node's bounding box
const getRelativePosition = (
  node: HTMLDivElement,
  event: MouseEvent,
): Interaction => {
  const rect = node.getBoundingClientRect();
  const pointer = event as MouseEvent;
  return {
    left: clamp(
      (pointer.pageX - (rect.left + getParentWindow(node).pageXOffset)) /
        rect.width,
      0,
      1,
    ),
    top: clamp(
      (pointer.pageY - (rect.top + getParentWindow(node).pageYOffset)) /
        rect.height,
      0,
      1,
    ),
  };
};

export interface InteractiveProps {
  onMove: (interaction: Interaction) => void;
  onKey: (offset: Interaction) => void;
  children: InfernoNode[];
  style?: any;
}

export class Interactive extends Component {
  containerRef: RefObject<HTMLDivElement>;
  props: InteractiveProps;

  constructor(props: InteractiveProps) {
    super();
    this.props = props;
    this.containerRef = createRef();
  }

  handleMoveStart = (event: MouseEvent) => {
    const el = this.containerRef?.current;
    if (!el) return;

    // Prevent text selection
    event.preventDefault();
    el.focus();
    this.props.onMove(getRelativePosition(el, event));
    this.toggleDocumentEvents(true);
  };

  handleMove = (event: MouseEvent) => {
    // Prevent text selection
    event.preventDefault();

    // If user moves the pointer outside of the window or iframe bounds and release it there,
    // `mouseup`/`touchend` won't be fired. In order to stop the picker from following the cursor
    // after the user has moved the mouse/finger back to the document, we check `event.buttons`
    // and `event.touches`. It allows us to detect that the user is just moving his pointer
    // without pressing it down
    const isDown = event.buttons > 0;

    if (isDown && this.containerRef?.current) {
      this.props.onMove(getRelativePosition(this.containerRef.current, event));
    } else {
      this.toggleDocumentEvents(false);
    }
  };

  handleMoveEnd = () => {
    this.toggleDocumentEvents(false);
  };

  handleKeyDown = (event: KeyboardEvent) => {
    const keyCode = event.which || event.keyCode;

    // Ignore all keys except arrow ones
    if (keyCode < 37 || keyCode > 40) return;
    // Do not scroll page by arrow keys when document is focused on the element
    event.preventDefault();
    // Send relative offset to the parent component.
    // We use codes (37←, 38↑, 39→, 40↓) instead of keys ('ArrowRight', 'ArrowDown', etc)
    // to reduce the size of the library
    this.props.onKey({
      left: keyCode === 39 ? 0.05 : keyCode === 37 ? -0.05 : 0,
      top: keyCode === 40 ? 0.05 : keyCode === 38 ? -0.05 : 0,
    });
  };

  toggleDocumentEvents(state?: boolean) {
    const el = this.containerRef?.current;
    const parentWindow = getParentWindow(el);

    // Add or remove additional pointer event listeners
    const toggleEvent = state
      ? parentWindow.addEventListener
      : parentWindow.removeEventListener;
    toggleEvent('mousemove', this.handleMove);
    toggleEvent('mouseup', this.handleMoveEnd);
  }

  componentDidMount() {
    this.toggleDocumentEvents(true);
  }

  componentWillUnmount() {
    this.toggleDocumentEvents(false);
  }

  render() {
    return (
      <div
        {...this.props}
        style={this.props.style}
        ref={this.containerRef}
        onMouseDown={this.handleMoveStart}
        className="react-colorful__interactive"
        onKeyDown={this.handleKeyDown}
        tabIndex={0}
        role="slider"
      >
        {this.props.children}
      </div>
    );
  }
}
