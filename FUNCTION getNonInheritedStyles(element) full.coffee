FUNCTION getNonInheritedStyles(element)
    // Read non-inherited CSS styles (inline, style tags, or external)
    SET computedStyles = window.getComputedStyle(element)
    SET styles = {}
    
    SET styles.position = computedStyles.position IS NOT 'static' ? computedStyles.position : 'fixed'
    SET styles.right = computedStyles.right IS NOT 'auto' ? computedStyles.right : '100%'
    SET styles.width = computedStyles.width IS NOT 'auto' ? computedStyles.width : '16px' // Chrome default scrollbar width
    
    RETURN styles
END FUNCTION

FUNCTION calculateScrollHeightRatio(container, scrollbarContainer)
    // Calculate scrollHeight to viewport height ratio
    SET viewportHeight = window.innerHeight
    SET scrollHeight = container.scrollHeight
    SET scrollHeightToVH = scrollHeight / viewportHeight
    
    // Set scrollbar visibility
    IF scrollHeightToVH <= 1
        SET scrollbarContainer.style.display = 'none'
    ELSE
        SET scrollbarContainer.style.display = 'fixed'
    END IF
    
    RETURN scrollHeightToVH
END FUNCTION

FUNCTION calculateThumbHeightAndPosition(container, track, thumb)
    // Calculate thumb height proportional to visible content
    SET viewportHeight = window.innerHeight
    SET scrollHeight = container.scrollHeight
    SET trackHeight = track.clientHeight
    SET thumbHeight = (viewportHeight / scrollHeight) * trackHeight
    SET thumbHeight = Math.max(thumbHeight, 20) // Minimum thumb height like Chrome
    
    // Set thumb styles
    SET thumb.style.height = thumbHeight + 'px'
    SET thumb.style.width = '100%' // Full track width
    SET thumb.style.backgroundColor = '#C1C1C1' // Chrome-like thumb color
    SET thumb.style.borderRadius = '4px' // Chrome-like rounded thumb
    
    // Calculate thumb position based on scroll position
    SET scrollTop = container.scrollTop
    SET maxScroll = scrollHeight - viewportHeight
    SET maxThumbTop = trackHeight - thumbHeight
    IF maxScroll > 0
        SET thumbTop = (scrollTop / maxScroll) * maxThumbTop
        SET thumb.style.top = thumbTop + 'px'
    ELSE
        SET thumb.style.top = '0'
    END IF
    
    // Hover effect like Chrome
    SET thumb.style.transition = 'background-color 0.2s'
    ADD EVENT LISTENER to thumb for 'hover'
        SET thumb.style.backgroundColor = '#A0A0A0' // Darker on hover
    END EVENT LISTENER
    ADD EVENT LISTENER to thumb for 'mouseleave'
        SET thumb.style.backgroundColor = '#C1C1C1'
    END EVENT LISTENER
END FUNCTION

FUNCTION customVerticalScrollbar(scrollableContainer)
    // Step 1: Validate scrollableContainer type
    IF scrollableContainer IS null OR scrollableContainer IS empty
        PRINT "No scrollable container provided. Please provide a string (ID with '#', class with '.', or tag name) or an HTMLElement."
        RETURN
    END IF
    
    IF TypeOf scrollableContainer IS NOT String AND TypeOf scrollableContainer IS NOT HTMLElement
        PRINT "Invalid input: scrollableContainer must be a string (ID with '#' + 'id', class with '.' + 'class', or tag name with 'tag') or a JavaScript HTMLElement."
        RETURN
    END IF

    // Step 2: Select container based on input
    SET selectedContainer = null
    SET containerSelector = null
    
    IF TypeOf scrollableContainer IS String
        IF scrollableContainer starts with '#'
            containerSelector = 'id'
            containerId = scrollableContainer.substring(1)
            selectedContainer = document.getElementById(containerId)
            IF selectedContainer IS null
                PRINT "No container found with ID " + scrollableContainer + ". Ensure the ID exists. If it has a unique class or tag, consider targeting it with its class ('.' + 'class') or tag ('tag'), or a JavaScript HTMLElement."
                RETURN
            END IF
        ELSE IF scrollableContainer starts with '.'
            containerSelector = 'class'
            containerClass = scrollableContainer.substring(1)
            containers = document.getElementsByClassName(containerClass)
            IF containers IS null OR containers.length == 0
                PRINT "No container found with class " + scrollableContainer + ". Ensure the class exists. Consider targeting it with an ID ('#' + 'id'), a unique tag ('tag'), or a JavaScript HTMLElement."
                RETURN
            END IF
            
            IF containers.length > 1
                PRINT "Multiple containers found with class " + scrollableContainer + ". Using the first one. To avoid ambiguity, ensure only one element has this class or consider targeting it with its ID ('#' + 'id'), a unique tag ('tag'), or a JavaScript HTMLElement."
                selectedContainer = containers[0]
            ELSE
                selectedContainer = containers[0]
            END IF
        ELSE
            containerSelector = 'tag'
            containers = document.getElementsByTagName(scrollableContainer)
            IF containers IS null OR containers.length == 0
                PRINT "No container found with tag " + scrollableContainer + ". Ensure the tag name is valid and has no prefix. Otherwise, consider targeting it with an ID ('#' + 'id'), a unique class ('.' + 'class'), or a JavaScript HTMLElement."
                RETURN
            END IF
            
            IF containers.length > 1
                PRINT "Multiple containers found with tag " + scrollableContainer + ". Using the first one. To avoid ambiguity, consider targeting it with its ID ('#' + 'id'), a unique class ('.' + 'class'), or a JavaScript HTMLElement."
                selectedContainer = containers[0]
            ELSE
                selectedContainer = containers[0]
            END IF
        END IF
    ELSE
        selectedContainer = scrollableContainer
        containerSelector = 'element'
    END IF

    // Step 3: Validate scrollbar structure with cached queries
    SET scrollbarContainer = selectedContainer.querySelector("div.scrollbar, div.custom-scrollbar, div.vertical-scrollbar")
    SET missingElements = []
    
    IF scrollbarContainer IS null
        ADD "a div with class .scrollbar, .custom-scrollbar, or .vertical-scrollbar" to missingElements
    ELSE
        SET scrollbarTrack = scrollbarContainer.querySelector('.scrollbar-track')
        SET scrollbarThumb = scrollbarTrack IS NOT null ? scrollbarTrack.querySelector('.scrollbar-thumb') : null
        SET scrollButtonUp = scrollbarContainer.querySelector('.scrollbar-button.scrollbar-button-up')
        SET scrollButtonDown = scrollbarContainer.querySelector('.scrollbar-button.scrollbar-button-down')
        
        IF scrollbarTrack IS null
            ADD "a .scrollbar-track div inside scrollbar container" to missingElements
        END IF
        IF scrollbarThumb IS null
            ADD "a .scrollbar-thumb div inside .scrollbar-track" to missingElements
        END IF
        IF scrollButtonUp IS null
            ADD "a .scrollbar-button.scrollbar-button-up button inside scrollbar container" to missingElements
        END IF
        IF scrollButtonDown IS null
            ADD "a .scrollbar-button.scrollbar-button-down button inside scrollbar container" to missingElements
        END IF
    END IF

    IF missingElements IS NOT empty
        PRINT "Invalid scrollbar structure in container. Missing: " + missingElements.join(', ') + ". Ensure the container has the required scrollbar elements."
        RETURN
    END IF

    // Step 4: Disable default scrollbar
    SET selectedContainer.style.overflow = 'hidden'

    // Step 5: Apply default styles to scrollbarContainer
    SET containerStyles = getNonInheritedStyles(scrollbarContainer)
    SET scrollbarContainer.style.position = containerStyles.position
    SET scrollbarContainer.style.left = containerStyles.left
    SET scrollbarContainer.style.right = containerStyles.right
    SET scrollbarContainer.style.width = containerStyles.width
    SET scrollbarContainer.style.height = '100%' // Full viewport height
    SET scrollbarContainer.style.backgroundColor = '#F5F5F5' // Chrome-like track background

    // Step 6: Style scrollbarTrack
    SET scrollbarTrack.style.position = 'relative'
    SET scrollbarTrack.style.width = '100%' // Full width of scrollbarContainer
    SET scrollbarTrack.style.backgroundColor = '#F5F5F5' // Chrome-like track color
    IF scrollButtonUp AND scrollButtonDown
        SET scrollbarTrack.style.top = scrollButtonUp.offsetHeight + 'px'
        SET scrollbarTrack.style.bottom = scrollButtonDown.offsetHeight + 'px'
    ELSE IF scrollButtonUp
        SET scrollbarTrack.style.top = scrollButtonUp.offsetHeight + 'px'
        SET scrollbarTrack.style.bottom = '0'
    ELSE IF scrollButtonDown
        SET scrollbarTrack.style.top = '0'
        SET scrollbarTrack.style.bottom = scrollButtonDown.offsetHeight + 'px'
    ELSE
        SET scrollbarTrack.style.top = '0'
        SET scrollbarTrack.style.bottom = '0'
    END IF

    // Step 7: Style buttons
    SET buttonWidth = scrollbarContainer.offsetWidth
    IF scrollButtonUp
        SET scrollButtonUp.style.position = 'relative'
        SET scrollButtonUp.style.top = '0'
        SET scrollButtonUp.style.width = buttonWidth + 'px'
        SET scrollButtonUp.style.height = buttonWidth + 'px' // Square buttons
        SET scrollButtonUp.style.backgroundColor = '#F5F5F5' // Chrome-like button color
        SET scrollButtonUp.style.border = 'none'
        SET scrollButtonUp.style.backgroundImage = 'url("data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 10 10\"><polygon points=\"5,2 2,8 8,8\" fill=\"#606060\"/></svg>")' // Up triangle
        SET scrollButtonUp.style.backgroundSize = '60%'
        SET scrollButtonUp.style.backgroundPosition = 'center'
        SET scrollButtonUp.style.backgroundRepeat = 'no-repeat'
        ADD EVENT LISTENER to scrollButtonUp for 'hover'
            SET scrollButtonUp.style.backgroundColor = '#E0E0E0' // Chrome-like hover
        END EVENT LISTENER
        ADD EVENT LISTENER to scrollButtonUp for 'mouseleave'
            SET scrollButtonUp.style.backgroundColor = '#F5F5F5'
        END EVENT LISTENER
    END IF
    IF scrollButtonDown
        SET scrollButtonDown.style.position = 'relative'
        SET scrollButtonDown.style.bottom = '100%'
        SET scrollButtonDown.style.width = buttonWidth + 'px'
        SET scrollButtonDown.style.height = buttonWidth + 'px' // Square buttons
        SET scrollButtonDown.style.backgroundColor = '#F5F5F5' // Chrome-like button color
        SET scrollButtonDown.style.border = 'none'
        SET scrollButtonDown.style.backgroundImage = 'url("data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 10 10\"><polygon points=\"5,8 2,2 8,2\" fill=\"#606060\"/></svg>")' // Down triangle
        SET scrollButtonDown.style.backgroundSize = '60%'
        SET scrollButtonDown.style.backgroundPosition = 'center'
        SET scrollButtonDown.style.backgroundRepeat = 'no-repeat'
        ADD EVENT LISTENER to scrollButtonDown for 'hover'
            SET scrollButtonDown.style.backgroundColor = '#E0E0E0' // Chrome-like hover
        END EVENT LISTENER
        ADD EVENT LISTENER to scrollButtonDown for 'mouseleave'
            SET scrollButtonDown.style.backgroundColor = '#F5F5F5'
        END EVENT LISTENER
    END IF

    // Step 8: Set scrollbar visibility and thumb size
    SET scrollHeightToVH = calculateScrollHeightRatio(selectedContainer, scrollbarContainer)
    CALL calculateThumbHeightAndPosition(selectedContainer, scrollbarTrack, scrollbarThumb)

    // Step 9: Handle interactions
    // Button click handlers
    IF scrollButtonUp
        ADD EVENT LISTENER to scrollButtonUp for 'click'
            SET selectedContainer.scrollTop = selectedContainer.scrollTop - 50 // Scroll up by 50px
            CALL calculateThumbHeightAndPosition(selectedContainer, scrollbarTrack, scrollbarThumb)
        END EVENT LISTENER
    END IF
    IF scrollButtonDown
        ADD EVENT LISTENER to scrollButtonDown for 'click'
            SET selectedContainer.scrollTop = selectedContainer.scrollTop + 50 // Scroll down by 50px
            CALL calculateThumbHeightAndPosition(selectedContainer, scrollbarTrack, scrollbarThumb)
        END EVENT LISTENER
    END IF

    // Thumb dragging
    SET isDragging = false
    SET startY = 0
    SET startScrollTop = 0
    ADD EVENT LISTENER to scrollbarThumb for 'mousedown'
        SET isDragging = true
        SET startY = event.clientY
        SET startScrollTop = selectedContainer.scrollTop
    END EVENT LISTENER
    ADD EVENT LISTENER to document for 'mousemove'
        IF isDragging
            SET deltaY = event.clientY - startY
            SET trackHeight = scrollbarTrack.clientHeight
            SET thumbHeight = scrollbarThumb.clientHeight
            SET maxThumbTop = trackHeight - thumbHeight
            SET maxScroll = selectedContainer.scrollHeight - window.innerHeight
            SET thumbTop = (startScrollTop / maxScroll) * maxThumbTop + deltaY
            SET thumbTop = Math.max(0, Math.min(thumbTop, maxThumbTop))
            SET selectedContainer.scrollTop = (thumbTop / maxThumbTop) * maxScroll
            CALL calculateThumbHeightAndPosition(selectedContainer, scrollbarTrack, scrollbarThumb)
        END IF
    END EVENT LISTENER
    ADD EVENT LISTENER to document for 'mouseup'
        SET isDragging = false
    END EVENT LISTENER

    // Track click to jump
    ADD EVENT LISTENER to scrollbarTrack for 'click'
        SET trackHeight = scrollbarTrack.clientHeight
        SET thumbHeight = scrollbarThumb.clientHeight
        SET maxThumbTop = trackHeight - thumbHeight
        SET clickY = event.clientY - scrollbarTrack.getBoundingClientRect().top
        SET thumbTop = clickY - (thumbHeight / 2)
        SET thumbTop = Math.max(0, Math.min(thumbTop, maxThumbTop))
        SET maxScroll = selectedContainer.scrollHeight - window.innerHeight
        SET selectedContainer.scrollTop = (thumbTop / maxThumbTop) * maxScroll
        CALL calculateThumbHeightAndPosition(selectedContainer, scrollbarTrack, scrollbarThumb)
    END EVENT LISTENER

    // Sync thumb with container scroll
    ADD EVENT LISTENER to selectedContainer for 'scroll'
        CALL calculateThumbHeightAndPosition(selectedContainer, scrollbarTrack, scrollbarThumb)
    END EVENT LISTENER

    // Step 10: Handle dynamic updates
    ADD EVENT LISTENER to window for 'resize'
        CALL calculateScrollHeightRatio(selectedContainer, scrollbarContainer)
        CALL calculateThumbHeightAndPosition(selectedContainer, scrollbarTrack, scrollbarThumb)
    END EVENT LISTENER

    // Observe content changes
    SET observer = new MutationObserver()
    ADD CALLBACK to observer
        CALL calculateScrollHeightRatio(selectedContainer, scrollbarContainer)
        CALL calculateThumbHeightAndPosition(selectedContainer, scrollbarTrack, scrollbarThumb)
    END CALLBACK
    OBSERVE selectedContainer for 'childList' and 'subtree' mutations
END FUNCTION