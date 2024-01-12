import { Placement } from '@popperjs/core';
import {
  PropsWithChildren,
  ReactNode,
  useEffect,
  useRef,
  useState,
} from 'react';
import { usePopper } from 'react-popper';

type Props = {
  /** The content to display in the popper */
  content: ReactNode;
  /** Whether the popper is open */
  isOpen: boolean;
  /** Called when the user clicks outside the popper */
  onClickOutside?: () => void;
  /** Where to place the popper relative to the reference element */
  placement?: Placement;
};

/**
 * ## Popper
 *  Popper lets you position elements so that they don't go out of the bounds of the window.
 * @url https://popper.js.org/ for more information.
 */
export function Popper(props: PropsWithChildren<Props>) {
  const { children, content, isOpen, onClickOutside, placement } = props;

  const [referenceElement, setReferenceElement] =
    useState<HTMLDivElement | null>(null);
  const [popperElement, setPopperElement] = useState<HTMLDivElement | null>(
    null,
  );

  // One would imagine we could just use useref here, but it's against react-popper documentation and causes a positioning bug
  const popperRef = useRef<HTMLDivElement | null>(null);
  const parentRef = useRef<HTMLDivElement | null>(null);

  const { styles, attributes } = usePopper(referenceElement, popperElement, {
    placement,
  });

  /** Close the popper when the user clicks outside */
  function handleClickOutside(event: MouseEvent) {
    if (
      !popperRef.current?.contains(event.target as Node) &&
      !parentRef.current?.contains(event.target as Node)
    ) {
      onClickOutside?.();
    }
  }

  useEffect(() => {
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    } else {
      document.removeEventListener('mousedown', handleClickOutside);
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  return (
    <>
      <div
        ref={(node) => {
          setReferenceElement(node);
          parentRef.current = node;
        }}
      >
        {children}
      </div>
      {isOpen && (
        <div
          ref={(node) => {
            setPopperElement(node);
            popperRef.current = node;
          }}
          style={{ ...styles.popper, zIndex: 5 }}
          {...attributes.popper}
        >
          {content}
        </div>
      )}
    </>
  );
}
