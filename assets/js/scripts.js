// Makes the custom scrollbar function
function customVerticalScrollbar({scrollableElements}) {
    scrollableHeight= foreacdocument.scrollHeight;
}


// Scales the font size of elements to fill container width
function scaleTextToFit({
    textSelector,           // required
    containerSelector,      // required, no default
    minFontSize = 10,
    maxFontSize = 500,
} = {}) {
    if (!textSelector) {
        console.warn('textSelector is required.');
        return;
    }
    if (!containerSelector) {
        console.warn('containerSelector is required.');
        return;
    }

    const elements = document.querySelectorAll(textSelector);
    const container = document.querySelector(containerSelector);

    if (!elements.length) {
        console.warn(`No elements found with selector "${textSelector}".`);
        return;
    }
    if (!container) {
        console.warn(`Container with selector "${containerSelector}" not found.`);
        return;
    }

    // Wait for fonts to load (with fallback for older browsers)
    const fontPromise = document.fonts?.ready || Promise.resolve();
    fontPromise.then(() => {
        // Get current font size
        const currentFontSize = parseFloat(window.getComputedStyle(elements[0]).fontSize);
        if (!currentFontSize) {
            console.warn('Could not determine current font size.');
            return;
        }

        // Find the widest element's width
        let currentMaxWidth = 0;
        elements.forEach(el => {
            currentMaxWidth = Math.max(currentMaxWidth, el.getBoundingClientRect().width);
        });

        if (!currentMaxWidth) {
            console.warn('Could not determine elements width.');
            return;
        }

        // Calculate scaling factor
        const fontToWidthFactor = currentMaxWidth / currentFontSize;

        // Get container width, subtracting padding
        const containerStyles = window.getComputedStyle(container);
        const containerWidth = container.clientWidth
            - parseFloat(containerStyles.paddingLeft)
            - parseFloat(containerStyles.paddingRight);

        if (!containerWidth) {
            console.warn('Container width is zero or invalid.');
            return;
        }

        // Calculate new font size with bounds
        let newFontSize = containerWidth / fontToWidthFactor;
        newFontSize = Math.min(Math.max(newFontSize, minFontSize), maxFontSize);

        // Apply new font size
        elements.forEach(el => {
            el.style.fontSize = `${newFontSize}px`;
        });
    }).catch(err => {
        console.error('Error scaling text:', err);
    });
}

// Debounce function for resize handling
function debounce(fn, delay) {
    let timeoutId;
    return (...args) => {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => fn(...args), delay);
    };
}

// Scale the hero title text to fit the container
const scaleHeroTitleText = () => scaleTextToFit({
    textSelector: '.word',
    containerSelector: '.hero',
    minFontSize: 12,
    maxFontSize: 500
});


document.addEventListener('DOMContentLoaded', () => {
    scaleHeroTitleText();
});    

window.addEventListener('resize', scaleHeroTitleText);