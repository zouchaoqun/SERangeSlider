# SERangeSlider

UISlider alike control with two thumb controls for selecting a range.

SERangeSlider is a slider control similar to UISlider. It provides two values which are the lower value and the upper value. The lower value is on the left part of the slider and it can no longer go over the upper value to the right part of the slider.

Instead of using the center of the thumb controls as their value positions, the lower thumb uses its right edge as the value position and the upper thumb uses its left edge as its value position so they won't overlap even they have the same value.

![screenshot](https://github.com/zouchaoqun/SERangeSlider/blob/master/screen.gif "screenshot")
 
The control uses the Target-Action design pattern to notify your app when the user moves the slider thumb. To be notified when the slider’s value changes, register your action method with the valueChanged event.
 
UI customization like changing track color, thumb color, thumb image is supported.

The control is IBDesignable and most properties are IBInspectable.

Improvements to do:

- Improve dragging when the two thumbs overlap
- Improve IBInspectable properties
- Improve setters for better validation
