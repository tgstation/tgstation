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

import { classes } from 'common/react';
import { InfernoNode } from 'inferno';

interface PointerProps {
  className?: string;
  top?: number;
  left: number;
  color: string;
}

export const Pointer = ({
  className,
  color,
  left,
  top = 0.5,
}: PointerProps): InfernoNode => {
  const nodeClassName = classes(['react-colorful__pointer', className]);

  const style = {
    top: `${top * 100}%`,
    left: `${left * 100}%`,
  };

  return (
    <div className={nodeClassName} style={style}>
      <div
        className="react-colorful__pointer-fill"
        style={{ 'background-color': color }}
      />
    </div>
  );
};
