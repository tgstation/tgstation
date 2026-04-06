/**
 * Uses DOMPurify to purify/sanitise HTML.
 */

import DOMPurify from 'dompurify';

// Configuration interface for sanitization options
interface SanitizeConfig {
  allowExternalUrls?: boolean;
  maxStyleLength?: number;
  allowedDomains?: string[];
  enableLogging?: boolean;
  maxDimension?: number;
  maxZIndex?: number;
}

// Default configuration
const defaultConfig: Required<SanitizeConfig> = {
  allowExternalUrls: false,
  maxStyleLength: 1000,
  allowedDomains: [],
  enableLogging: true,
  maxDimension: 1000,
  maxZIndex: 100,
};

// Default values
const defTag = [
  'b',
  'blockquote',
  'br',
  'center',
  'code',
  'dd',
  'del',
  'div',
  'dl',
  'dt',
  'em',
  'font',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'hr',
  'i',
  'ins',
  'li',
  'menu',
  'ol',
  'p',
  'pre',
  'span',
  'strong',
  'table',
  'tbody',
  'td',
  'th',
  'thead',
  'tfoot',
  'tr',
  'u',
  'ul',
 // Additional safe tags for formatting and semantics
  'sup',
  'sub',
  'mark',
  'small',
  'kbd',
  'samp',
  'var',
  'abbr',
  'cite',
  'dfn',
  'q',
  's',
];

// Advanced HTML tags that we can trust admins (but not players) with
const advTag = ['img'];

// Safe CSS properties that players are allowed to use
const safeCSSProperties = [
  // Text properties
  'color',
  'font-size',
  'font-weight',
  'font-style',
  'font-family',
  'text-align',
  'text-decoration',
  'text-transform',
  'line-height',
  'letter-spacing',
  'word-spacing',

  // Layout properties
  'margin',
  'margin-top',
  'margin-right',
  'margin-bottom',
  'margin-left',
  'padding',
  'padding-top',
  'padding-right',
  'padding-bottom',
  'padding-left',

  // Border properties
  'border',
  'border-width',
  'border-style',
  'border-color',
  'border-radius',
  'border-top',
  'border-right',
  'border-bottom',
  'border-left',
  'border-spacing',

  // Background properties (limited)
  'background-color',
  'background-image',
  'background-repeat',
  'background-position',
  'background-size',
  'linear-gradient',
  'repeating-linear-gradient',

  // Display properties
  'display',
  'visibility',
  'opacity',
  'float',
  'clear',

  // Position properties
  'position',
  'top',
  'right',
  'bottom',
  'left',
  'z-index',

  // Size properties
  'width',
  'height',
  'min-width',
  'min-height',
  'max-width',
  'max-height',

  // List properties
  'list-style',
  'list-style-type',
  'list-style-position',
  'list-style-image',
  // Add border-collapse for table support
  'border-collapse',
];

// Dangerous CSS patterns to block
const dangerousCSSPatterns = [
  /expression\s*\(/i, // CSS expressions
  /javascript\s*:/i, // JavaScript URLs
  /vbscript\s*:/i, // VBScript URLs
  /data\s*:/i, // Data URLs
  /url\s*\(\s*['"]?\s*javascript\s*:/i, // JavaScript in URLs
  /url\s*\(\s*['"]?\s*vbscript\s*:/i, // VBScript in URLs
  /url\s*\(\s*['"]?\s*data\s*:/i, // Data URLs
  /behavior\s*:/i, // IE behaviors
  /binding\s*:/i, // Mozilla bindings
  /-moz-binding\s*:/i, // Mozilla bindings
  /-webkit-binding\s*:/i, // WebKit bindings
  /import\s+url\s*\(/i, // CSS imports
  /@import/i, // CSS imports
  /@charset/i, // Character set declarations
  /@namespace/i, // Namespace declarations
  /@media/i, // Media queries (can be used for timing attacks)
  /@keyframes/i, // Keyframes (can be used for timing attacks)
  /@supports/i, // Feature queries
  /@document/i, // Document rules
  /@page/i, // Page rules
  /@font-face/i, // Font face rules
  /@counter-style/i, // Counter style rules
  /@font-feature-values/i, // Font feature values
  /@property/i, // CSS custom properties
  // External resource blocking
  /url\s*\(\s*['"]?\s*https?:\/\//i, // External HTTP URLs
  /url\s*\(\s*['"]?\s*file:\/\//i, // File URLs
  /url\s*\(\s*['"]?\s*ftp:\/\//i, // FTP URLs
  /url\s*\(\s*['"]?\s*tel:\/\//i, // Tel URLs
  /url\s*\(\s*['"]?\s*mailto:\/\//i, // Mailto URLs
  // Animation restrictions
  /animation\s*:\s*[^;]*infinite/i, // Infinite animations
  /animation-iteration-count\s*:\s*infinite/i, // Infinite animation iterations
  // Layout constraints
  /z-index\s*:\s*\d{4,}/i, // High z-index values (>999)
  /position\s*:\s*fixed/i, // Fixed positioning
  /position\s*:\s*absolute/i, // Absolute positioning
  /width\s*:\s*\d{4,}px/i, // Very wide elements (>999px)
  /height\s*:\s*\d{4,}px/i, // Very tall elements (>999px)
  /min-width\s*:\s*\d{4,}px/i, // Very wide minimums
  /min-height\s*:\s*\d{4,}px/i, // Very tall minimums
  /max-width\s*:\s*\d{4,}px/i, // Very wide maximums
  /max-height\s*:\s*\d{4,}px/i, // Very tall maximums
];

// Trusted domains for background images (empty by default for maximum security)
const trustedDomains = [
  // Add trusted domains here if needed
  // 'trusted-domain.com',
  // 'cdn.example.com',
];

// Maximum file size for background images (1MB)
const MAX_BACKGROUND_SIZE = 1024 * 1024;

// Dangerous animations to block
const dangerousAnimations = [
  'spin',
  'blink',
  'flash',
  'pulse',
  'bounce',
  'shake',
  'wiggle',
  'tada',
  'rubberBand',
  'swing',
  'wobble',
];

// Maximum dimensions for elements
const MAX_DIMENSION = 1000; // Max width/height in pixels
const MAX_Z_INDEX = 100; // Max z-index value

// Safe attributes that are allowed for all users
const safeAttr = [
  // Table attributes
  'align',
  'valign',
  'colspan',
  'rowspan',
  'width',
  'height',
  'cellpadding',
  'cellspacing',
  'border',
  'bgcolor',
  // Font attributes
  'size',
  'face',
  'color',
  // Style attribute (will be validated separately)
  'style',
  // Other safe attributes
  'alt',
  'title',
  // Additional table attributes that might be needed
  'nowrap',
  'scope',
  'headers',
  'abbr',
  'axis',
  // Additional safe attributes for accessibility and linking
  'id', // Element ID
  'lang', // Language
  'dir', // Text direction
];

// Attributes that are forbidden for all users
const forbiddenAttr = [
  'class', // CSS classes (use inline styles instead)
  'background', // Background attribute (use CSS background properties instead)
  // Event handlers
  'onclick',
  'onerror',
  'onload',
  'onmouseover',
  'onmouseout',
  'onfocus',
  'onblur',
  'onchange',
  'onsubmit',
  'onreset',
  'onkeydown',
  'onkeyup',
  'onkeypress',
  'onabort',
  'onbeforeunload',
  'onhashchange',
  'onmessage',
  'onoffline',
  'ononline',
  'onpagehide',
  'onpageshow',
  'onpopstate',
  'onresize',
  'onstorage',
  'onunload',
  'oncontextmenu',
  'oninput',
  'oninvalid',
  'onsearch',
  // Dangerous attributes
  'formaction',
  'form',
  'target',
  'href',
  'xmlns',
  'xlink:href',
];

// Performance optimization: Cache compiled regex patterns
const compiledDangerousPatterns = new Set(dangerousCSSPatterns);

// Performance optimization: Cache dangerous animations as Set for O(1) lookup
const dangerousAnimationsSet = new Set(dangerousAnimations);

// Performance optimization: Cache safe CSS properties as Set
const safeCSSPropertiesSet = new Set(safeCSSProperties);

// Allowed font families for font-family property
const allowedFonts = [
  'arial',
  'helvetica',
  'sans-serif',
  'times new roman',
  'serif',
  'courier new',
  'monospace',
  'verdana',
  'tahoma',
  'georgia',
  'segoe script',
  'segoe ui',
  'comic sans ms',
  'cursive',
  'lucida console',
];

// Performance monitoring
let sanitizationStats = {
  totalSanitizations: 0,
  blockedContent: 0,
  errors: 0,
  totalProcessingTime: 0,
};

/**
 * Get sanitization statistics
 * @returns Current sanitization statistics
 */
export function getSanitizationStats() {
  return { ...sanitizationStats };
}

/**
 * Reset sanitization statistics
 */
export function resetSanitizationStats() {
  sanitizationStats = {
    totalSanitizations: 0,
    blockedContent: 0,
    errors: 0,
    totalProcessingTime: 0,
  };
}

/**
 * Update configuration at runtime
 * @param newConfig - New configuration options
 */
export function updateSanitizeConfig(newConfig: Partial<SanitizeConfig>) {
  Object.assign(defaultConfig, newConfig);
}

/**
 * Feed it a string and it should spit out a sanitized version.
 *
 * @param input - Input HTML string to sanitize
 * @param advHtml - Flag to enable/disable advanced HTML
 * @param tags - List of allowed HTML tags
 * @param forbidAttr - List of forbidden HTML attributes
 * @param advTags - List of advanced HTML tags allowed for trusted sources
 * @param config - Optional configuration overrides
 */
export function sanitizeText(
  input: string,
  advHtml = false,
  tags = defTag,
  forbidAttr = forbiddenAttr,
  advTags = advTag,
  config: Partial<SanitizeConfig> = {},
) {
  const startTime = performance.now();

  let blockedItems: string[] = [];

  for (const attr of forbidAttr) {
    const regex = new RegExp(`${attr}\\s*=`, 'i');
    if (regex.test(input)) {
      blockedItems.push(`Blocked attribute: ${attr}`);
    }
  }

  return safeExecuteWithContext(
    () => {
      if (!isValidInput(input)) {
        return { sanitized: '', blocked: false, blockedSummary: '' };
      }
      const finalConfig = { ...defaultConfig, ...config };
      if (advHtml) {
        tags = tags.concat(advTags);
      }
      const sanitized = DOMPurify.sanitize(input, {
        ALLOWED_TAGS: tags,
        ALLOWED_ATTR: safeAttr,
        FORBID_ATTR: forbidAttr,
      });
      const finalResult = postProcessStyles(sanitized, blockedItems);
      // Update statistics
      sanitizationStats.totalSanitizations++;
      const processingTime = performance.now() - startTime;
      sanitizationStats.totalProcessingTime += processingTime;
      if (finalConfig.enableLogging && input !== finalResult) {
        const originalLength = input.length;
        const finalLength = finalResult.length;
        const removedLength = originalLength - finalLength;
        if (removedLength > 0) {
          sanitizationStats.blockedContent++;
        }
      }
      // Log performance warnings for slow operations
      if (processingTime > 100) {
        // More than 100ms
        blockedItems.push(
          `Slow sanitization detected: ${processingTime.toFixed(2)}ms for ${input.length} chars`,
        );
      }
      return {
        sanitized: finalResult,
        blocked: blockedItems.length > 0,
        blockedSummary: blockedItems.join('; '),
      };
    },
    { sanitized: '', blocked: false, blockedSummary: '' },
    'sanitizeText',
    input,
  );
}

/**
 * Validates if a CSS property is safe to use
 * @param property - The CSS property name
 * @returns true if the property is safe
 */
function isSafeCSSProperty(property: string): boolean {
  return safeExecute(
    () => {
      if (!property || typeof property !== 'string') {
        return false;
      }
      return safeCSSPropertiesSet.has(property.toLowerCase().trim());
    },
    false,
    'isSafeCSSProperty',
  );
}

/**
 * Validates and sanitizes a style attribute
 * @param style - The style attribute value
 * @param blockedItems - Array to collect blocked CSS/font-family issues
 * @returns sanitized style string or empty string if unsafe
 *
 * This function is responsible for parsing the style attribute,
 * validating each property and value, and applying special rules
 * (such as font-family restrictions). It is the single source of truth
 * for what CSS is allowed in sanitized HTML.
 */
function validateAndSanitizeStyle(
  style: string,
  blockedItems: string[],
): string {
  return safeExecute(
    () => {
      if (!style || typeof style !== 'string') {
        return '';
      }
      const stylePairs = style
        .split(';')
        .map((pair) => pair.trim())
        .filter(Boolean);
      const safePairs: string[] = [];
      for (const pair of stylePairs) {
        const [propertyRaw, ...valueParts] = pair.split(':');
        if (!propertyRaw || valueParts.length === 0) continue;
        const property = propertyRaw.trim().toLowerCase();
        const value = valueParts.join(':').trim();
        // Check full property: value pair for dangerous patterns
        const fullPair = `${property}: ${value}`;
        let dangerous = false;
        for (const pattern of compiledDangerousPatterns) {
          if (pattern.test(fullPair)) {
            blockedItems.push(`Blocked CSS property: ${property}`);
            dangerous = true;
            break;
          }
        }
        // Also check the value alone for dangerous patterns
        if (!dangerous) {
          for (const pattern of compiledDangerousPatterns) {
            if (pattern.test(value)) {
              blockedItems.push(`Blocked CSS value: ${property}: ${value}`);
              dangerous = true;
              break;
            }
          }
        }
        if (dangerous) continue;
        if (property === 'font-family') {
          const fonts = value.split(',').map((f) =>
            f
              .trim()
              .replace(/^['"]|['"]$/g, '')
              .toLowerCase(),
          );
          let allAllowed = true;
          for (const font of fonts) {
            if (!allowedFonts.includes(font)) {
              allAllowed = false;
            }
          }
          if (!allAllowed) {
            blockedItems.push(`Blocked font-family: ${value}`);
            continue; // skip this property
          }
        }
        if (
          property &&
          value &&
          isSafeCSSProperty(property) &&
          isSafeCSSValue(value)
        ) {
          safePairs.push(`${property}: ${value}`);
        } else {
          blockedItems.push(`Blocked CSS property: ${property}`);
        }
      }
      return safePairs.join('; ');
    },
    '',
    'validateAndSanitizeStyle',
  );
}

/**
 * Post-processes HTML to validate style attributes
 * @param html - The HTML string to process
 * @param blockedItems - Array to collect blocked CSS/font-family issues
 * @returns HTML with validated style attributes
 */
function postProcessStyles(html: string, blockedItems: string[]): string {
  return safeExecute(
    () => {
      if (!html || typeof html !== 'string') {
        return html;
      }

      // Simple regex to find and validate style attributes
      return html.replace(
        /style\s*=\s*["']([^"']*)["']/gi,
        (match, styleContent) => {
          const sanitizedStyle = validateAndSanitizeStyle(
            styleContent,
            blockedItems,
          );
          return sanitizedStyle ? `style="${sanitizedStyle}"` : '';
        },
      );
    },
    html,
    'postProcessStyles',
  );
}

/**
 * Validate HTML input before processing
 * @param input - Input to validate
 * @returns true if input is valid
 */
function isValidInput(input: unknown): input is string {
  if (typeof input !== 'string') {
    return false;
  }

  if (input.length === 0) {
    return true; // Empty strings are valid
  }

  if (input.length > 100000) {
    // 100KB limit
    return false;
  }

  return true;
}

/**
 * Get a summary of blocked content for admin review
 * @returns Summary of recent sanitization activity
 */
export function getSanitizationSummary() {
  const avgTime =
    sanitizationStats.totalSanitizations > 0
      ? sanitizationStats.totalProcessingTime /
        sanitizationStats.totalSanitizations
      : 0;

  return {
    totalSanitizations: sanitizationStats.totalSanitizations,
    blockedContent: sanitizationStats.blockedContent,
    errors: sanitizationStats.errors,
    averageProcessingTime: avgTime.toFixed(2) + 'ms',
    totalProcessingTime:
      sanitizationStats.totalProcessingTime.toFixed(2) + 'ms',
    blockedPercentage:
      sanitizationStats.totalSanitizations > 0
        ? (
            (sanitizationStats.blockedContent /
              sanitizationStats.totalSanitizations) *
            100
          ).toFixed(1) + '%'
        : '0%',
  };
}

/**
 * Validates if a CSS value is safe to use
 * @param value - The CSS property value
 * @returns true if the value is safe
 */
function isSafeCSSValue(value: string): boolean {
  return safeExecute(
    () => {
      if (!value || typeof value !== 'string') {
        return false;
      }
      const lowerValue = value.toLowerCase();
      // Check for dangerous patterns using compiled regex
      for (const pattern of compiledDangerousPatterns) {
        if (pattern.test(lowerValue)) {
          return false;
        }
      }
      // Block overly long values (potential DoS)
      if (value.length > defaultConfig.maxStyleLength) {
        return false;
      }
      // Check for dangerous animations using Set for O(1) lookup
      for (const animation of dangerousAnimationsSet) {
        if (lowerValue.includes(animation)) {
          return false;
        }
      }
      // Validate URLs in background-image
      if (lowerValue.includes('url(')) {
        return isSafeURL(value);
      }
      // Validate dimensions
      if (lowerValue.includes('px')) {
        return isSafeDimension(value);
      }
      // Validate z-index
      if (lowerValue.includes('z-index') || lowerValue.match(/^\d+$/)) {
        return isSafeZIndex(value);
      }
      return true;
    },
    false,
    'isSafeCSSValue',
  );
}

/**
 * Validates if a URL is safe to use
 * @param url - The URL string
 * @returns true if the URL is safe
 */
function isSafeURL(url: string): boolean {
  return safeExecute(
    () => {
      // Extract URL from url() function
      const urlMatch = url.match(/url\s*\(\s*['"]?([^'"]*)['"]?\s*\)/i);
      if (!urlMatch) {
        return false;
      }
      const actualUrl = urlMatch[1];
      // Allow relative URLs
      if (
        actualUrl.startsWith('./') ||
        actualUrl.startsWith('../') ||
        actualUrl.startsWith('/')
      ) {
        return true;
      }
      // Allow data URLs for images only
      if (actualUrl.startsWith('data:image/')) {
        const safeTypes = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg'];
        const isSafe = safeTypes.some((type) => actualUrl.includes(type));
        return isSafe;
      }
      // Block all external URLs for maximum security
      if (actualUrl.startsWith('http://') || actualUrl.startsWith('https://')) {
        return false;
      }
      // Block other URL schemes
      if (
        actualUrl.startsWith('file://') ||
        actualUrl.startsWith('ftp://') ||
        actualUrl.startsWith('tel://') ||
        actualUrl.startsWith('mailto://')
      ) {
        return false;
      }
      return true;
    },
    false,
    'isSafeURL',
  );
}

/**
 * Validates if a dimension value is safe
 * @param value - The dimension value
 * @returns true if the dimension is safe
 */
function isSafeDimension(value: string): boolean {
  return safeExecute(
    () => {
      // Extract numeric value from CSS
      const match = value.match(/(\d+(?:\.\d+)?)\s*px/i);
      if (!match) {
        return true; // Non-pixel values are allowed
      }
      const numericValue = parseFloat(match[1]);
      const isSafe =
        numericValue <= defaultConfig.maxDimension && numericValue >= 0;
      return isSafe;
    },
    false,
    'isSafeDimension',
  );
}

/**
 * Validates if a z-index value is safe
 * @param value - The z-index value
 * @returns true if the z-index is safe
 */
function isSafeZIndex(value: string): boolean {
  return safeExecute(
    () => {
      // Extract numeric value
      const match = value.match(/(\d+)/);
      if (!match) {
        return true; // Non-numeric values are allowed
      }
      const numericValue = parseInt(match[1], 10);
      const isSafe =
        numericValue <= defaultConfig.maxZIndex && numericValue >= 0;
      return isSafe;
    },
    false,
    'isSafeZIndex',
  );
}

// Add back safeExecute and safeExecuteWithContext wrappers:
function safeExecute<T>(fn: () => T, fallback: T, context: string): T {
  try {
    return fn();
  } catch (error) {
    sanitizationStats.errors++;
    return fallback;
  }
}

function safeExecuteWithContext<T>(
  fn: () => T,
  fallback: T,
  context: string,
  input?: string,
): T {
  try {
    return fn();
  } catch (error) {
    sanitizationStats.errors++;
    return fallback;
  }
}
