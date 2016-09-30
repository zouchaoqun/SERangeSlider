//
//  SERangeSlider.h
//  Range Slider
//
//  Created by Max on 27/9/16.
//  Copyright © 2016 Schneider Electric (Australia) Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 SERangeSlider is a slider control similar to UISlider. It provides two values which are the lower value and the upper value. The lower value is on the left part of the slider and it can no longer go over the upper value to the right part of the slider.
 
 The control uses the Target-Action design pattern to notify your app when the user moves the slider thumb. To be notified when the slider’s value changes, register your action method with the valueChanged event.
 
 UI customization like changing track color, thumb color, thumb image is supported.
 */
IB_DESIGNABLE
@interface SERangeSlider : UIControl

/**
 The minimum value of the slider on the left end.
 */
@property (nonatomic) IBInspectable float minValue;

/**
 The maximum value of the slider on the right end.
 */
@property (nonatomic) IBInspectable float maxValue;

/**
 The current lower value. It's always between the minimum value and the upper value.
 */
@property (nonatomic) IBInspectable float lowerValue;

/**
 The current upper value. It's always between the lower value and the maximum value.
 */
@property (nonatomic) IBInspectable float upperValue;

/**
 The gap between the minimum value and maximum value.
 */
@property (nonatomic) IBInspectable float valueGap;

/**
 Whether the slider will send out valueChanged event continuously when the user moves the slider's thumb. Setting it to false causes the slider to send an event only when the user releases the slider's thumb control, setting the final value.
 */
@property (nonatomic) IBInspectable BOOL continous;

/**
 The color of the whole track. The default color is the light gray color.
 */
@property (copy, nonatomic) IBInspectable UIColor *backgroundTrackColor;

/**
 The color of the part of the track between the lower value and the upper value. The default color is the blue color (52, 120, 246).
 */
@property (copy, nonatomic) IBInspectable UIColor *inRangeTrackColor;

/**
 The height of the track. Normally you don't need to change this value.
 */
@property (nonatomic) IBInspectable CGFloat trackHeight;

/**
 The background color of the lower thumb control. The default color is the white color.
 */
@property (copy, nonatomic) IBInspectable UIColor *lowerThumbColor;

/**
 The background color of the upper thumb control. The default color is the white color.
 */
@property (copy, nonatomic) IBInspectable UIColor *upperThumbColor;

/**
 The image on the lower thumb control. The default is no image. The image content mode is center and currently it can't be changed.
 */
@property (copy, nonatomic) IBInspectable UIImage *lowerThumbImage;

/**
 The image on the upper thumb control. The default is no image. The image content mode is center and currently it can't be changed.
 */
@property (copy, nonatomic) IBInspectable UIImage *upperThumbImage;

/**
 The thumb control is always a square and this is the side length of the thumb control.
 */
@property (nonatomic) IBInspectable CGFloat thumbSideLength;


@end
