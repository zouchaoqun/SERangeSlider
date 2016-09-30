//
//  SERangeSlider.m
//  Range Slider
//
//  Created by Max on 27/9/16.
//  Copyright © 2016 Schneider Electric (Australia) Pty Ltd. All rights reserved.
//

#import "SERangeSlider.h"

/**
 Default value of the slider track height
 */
static const CGFloat SERangeSliderTrackHeight = 2.0;

/**
 Default value of the slider thumb square side length
 */
static const CGFloat SERangeSliderThumbSideLength = 29.0;


/**
 The layer representing the track
 */
@interface SERangeSliderTrackLayer : CALayer

/**
 Weak reference to the slider control since we need a few properties from the slider for the track layer. It is used instead of the delegate pattern for simplicity.
 */
@property (weak, nonatomic) SERangeSlider *slider;

@end

/**
 The layer representing the thumb controls
 */
@interface SERangeSliderThumbLayer : CALayer

/**
 The thumb background color
 */
@property (copy, nonatomic) UIColor *thumbColor;

/**
 The thumb image
 */
@property (copy, nonatomic) UIImage *thumbImage;

/**
 Whether the thumb control is being dragged
 */
@property (nonatomic) BOOL tracking;

@end

@interface SERangeSlider ()

/**
 The track layer
 */
@property (strong, nonatomic) SERangeSliderTrackLayer *trackLayer;

/**
 The lower thumb layer
 */
@property (strong, nonatomic) SERangeSliderThumbLayer *lowerThumbLayer;

/**
 The upper thumb layer
 */
@property (strong, nonatomic) SERangeSliderThumbLayer *upperThumbLayer;

/**
 The previous touch location which is used to calculate the delta value after the thumb position is changed by user.
 */
@property (nonatomic) CGPoint previousTouchLocation;


/**
 Calculate the position inside the slider control for the given value.

 @param value The value

 @return The position
 */
- (CGFloat)positionForValue:(float)value;

@end

@implementation SERangeSlider

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.trackLayer = [[SERangeSliderTrackLayer alloc] init];
        self.lowerThumbLayer = [[SERangeSliderThumbLayer alloc] init];
        self.upperThumbLayer = [[SERangeSliderThumbLayer alloc] init];

        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
    
        self.trackLayer = [[SERangeSliderTrackLayer alloc] initWithCoder:aDecoder];
        self.lowerThumbLayer = [[SERangeSliderThumbLayer alloc] initWithCoder:aDecoder];
        self.upperThumbLayer = [[SERangeSliderThumbLayer alloc] initWithCoder:aDecoder];
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    // values
    self.minValue = 0;
    self.maxValue = 1;
    self.upperValue = 0.7;
    self.lowerValue = 0.2;
    self.valueGap =  0;
    
    self.continous = YES;
    
    // track layer
    self.backgroundTrackColor = [UIColor lightGrayColor];
    self.inRangeTrackColor = [UIColor colorWithRed:52.0/255.0 green:120.0/255.0 blue:246.0/255.0 alpha:1.0];
    self.trackHeight = SERangeSliderTrackHeight;
    
    self.trackLayer.slider = self;
    self.trackLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:self.trackLayer];
    
    // thumb layers
    self.lowerThumbColor = [UIColor whiteColor];
    self.upperThumbColor = [UIColor whiteColor];
    self.thumbSideLength = SERangeSliderThumbSideLength;

    self.lowerThumbLayer.thumbColor = self.lowerThumbColor;
    self.lowerThumbLayer.thumbImage = self.lowerThumbImage;
    self.lowerThumbLayer.contentsScale = [UIScreen mainScreen].scale;
    [self prepareThumbLayer:self.lowerThumbLayer];
    [self.layer addSublayer:self.lowerThumbLayer];

    self.upperThumbLayer.thumbColor = self.upperThumbColor;
    self.upperThumbLayer.thumbImage = self.upperThumbImage;
    self.upperThumbLayer.contentsScale = [UIScreen mainScreen].scale;
    [self prepareThumbLayer:self.upperThumbLayer];
    [self.layer addSublayer:self.upperThumbLayer];
}

#pragma mark - Value Properties

- (void)setMinValue:(float)minValue {
    if (_minValue != minValue) {
        _minValue = minValue;
     
        if (_lowerValue < _minValue) {
            _lowerValue = _minValue;
        }
        if (_upperValue < _minValue) {
            _upperValue = _minValue;
        }
        if (_maxValue < _minValue) {
            _maxValue = _minValue;
        }
        
        [self updateSubLayerFrames];
    }
}

- (void)setMaxValue:(float)maxValue {
    if (_maxValue != maxValue) {
        _maxValue = maxValue;
        
        if (_lowerValue > _maxValue) {
            _lowerValue = _maxValue;
        }
        if (_upperValue > _maxValue) {
            _upperValue = _maxValue;
        }
        if (_minValue > _maxValue) {
            _minValue = _maxValue;
        }
        
        [self updateSubLayerFrames];
    }
}

- (void)setLowerValue:(float)lowerValue {
    
    if (lowerValue < self.minValue || lowerValue > self.maxValue || lowerValue > self.upperValue) {
        return;
    }
    
    if (_lowerValue != lowerValue) {
        _lowerValue = lowerValue;
        
        [self updateSubLayerFrames];
    }
}

- (void)setUpperValue:(float)upperValue {
    
    if (upperValue < self.minValue || upperValue > self.maxValue || upperValue < self.lowerValue) {
        return;
    }
    
    if (_upperValue != upperValue) {
        _upperValue = upperValue;
        
        [self updateSubLayerFrames];
    }
}

- (void)setValueGap:(float)valueGap {
    
    if (_valueGap != valueGap) {
        _valueGap = valueGap;
        
        if (_upperValue - _lowerValue < _valueGap) {
        
            // try to move lower value first
            if (_upperValue - _valueGap >= _minValue) {
                _lowerValue = _upperValue - _valueGap;
            }
            else {
                _upperValue = _lowerValue + _valueGap;
            }
        
            [self updateSubLayerFrames];
        }
    }
}

#pragma mark - Drawing Properties

- (void)setBackgroundTrackColor:(UIColor *)backgroundTrackColor {
    if (_backgroundTrackColor != backgroundTrackColor) {
        _backgroundTrackColor = backgroundTrackColor;
        
        [self.trackLayer setNeedsDisplay];
    }
}

- (void)setInRangeTrackColor:(UIColor *)inRangeTrackColor {
    if (_inRangeTrackColor != inRangeTrackColor) {
        _inRangeTrackColor = inRangeTrackColor;
        
        [self.trackLayer setNeedsDisplay];
    }
}

- (void)setTrackHeight:(CGFloat)trackHeight {
    if (_trackHeight != trackHeight) {
        _trackHeight = trackHeight;
        
        [self updateSubLayerFrames];
    }
}

- (void)setLowerThumbColor:(UIColor *)lowerThumbColor {
    if (_lowerThumbColor != lowerThumbColor) {
        _lowerThumbColor = lowerThumbColor;
        
        self.lowerThumbLayer.thumbColor = lowerThumbColor;
        [self.lowerThumbLayer setNeedsDisplay];
    }
}

- (void)setLowerThumbImage:(UIImage *)lowerThumbImage {
    if (_lowerThumbImage != lowerThumbImage) {
        _lowerThumbImage = lowerThumbImage;
        
        self.lowerThumbLayer.thumbImage = lowerThumbImage;
        [self.lowerThumbLayer setNeedsDisplay];
    }
}

- (void)setUpperThumbColor:(UIColor *)upperThumbColor {
    if (_upperThumbColor != upperThumbColor) {
        _upperThumbColor = upperThumbColor;
        
        self.upperThumbLayer.thumbColor = upperThumbColor;
        [self.upperThumbLayer setNeedsDisplay];
    }
}

- (void)setUpperThumbImage:(UIImage *)upperThumbImage {
    if (_upperThumbImage != upperThumbImage) {
        _upperThumbImage = upperThumbImage;
        
        self.upperThumbLayer.thumbImage = upperThumbImage;
        [self.upperThumbLayer setNeedsDisplay];
    }
}

- (void)setThumbSideLength:(CGFloat)thumbSideLength {
    if (_thumbSideLength != thumbSideLength) {
        _thumbSideLength= thumbSideLength;
        
        [self updateSubLayerFrames];
    }
}

#pragma mark - UIView/UIControl Methods

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateSubLayerFrames];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    self.previousTouchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.upperThumbLayer.frame, self.previousTouchLocation)) {
        self.upperThumbLayer.tracking = YES;
    }
    else if (CGRectContainsPoint(self.lowerThumbLayer.frame, self.previousTouchLocation)) {
        self.lowerThumbLayer.tracking = YES;
    }
    
    return self.upperThumbLayer.tracking || self.lowerThumbLayer.tracking;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint location = [touch locationInView:self];

    float deltaValue = (location.x - self.previousTouchLocation.x) * (self.maxValue - self.minValue) / (self.bounds.size.width - self.thumbSideLength);
    self.previousTouchLocation = location;
    
    if (self.upperThumbLayer.tracking) {
        float newUpperValue = self.upperValue + deltaValue;
        self.upperValue = MIN(MAX(self.lowerValue + self.valueGap, newUpperValue), self.maxValue);
    }
    else if (self.lowerThumbLayer.tracking) {
        float newLowerValue = self.lowerValue + deltaValue;
        self.lowerValue = MAX(self.minValue, MIN(newLowerValue, self.upperValue - self.valueGap));
    }
    
    if (self.continous) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    self.upperThumbLayer.tracking = NO;
    self.lowerThumbLayer.tracking = NO;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Helpers

- (CGFloat)positionForValue:(float)value {
    if (self.maxValue - self.minValue == 0) {
        return 0;
    }
    
    return (self.bounds.size.width - self.thumbSideLength) * (value - self.minValue) / (self.maxValue - self.minValue) + self.thumbSideLength/2;
}

- (void)updateSubLayerFrames {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.trackLayer.frame = CGRectInset(self.bounds, 0, (self.bounds.size.height - self.trackHeight) / 2);
    [self.trackLayer setNeedsDisplay];
  
    CGFloat lowerPosition = [self positionForValue:self.lowerValue];
    self.lowerThumbLayer.frame = CGRectMake(lowerPosition - self.thumbSideLength/2, self.trackLayer.frame.origin.y - self.thumbSideLength/2, self.thumbSideLength, self.thumbSideLength);
    [self.lowerThumbLayer setNeedsDisplay];

    CGFloat upperPosition = [self positionForValue:self.upperValue];
    self.upperThumbLayer.frame = CGRectMake(upperPosition - self.thumbSideLength/2, self.trackLayer.frame.origin.y - self.thumbSideLength/2, self.thumbSideLength, self.thumbSideLength);
    [self.upperThumbLayer setNeedsDisplay];
    
    [CATransaction commit];
}

- (void)prepareThumbLayer:(SERangeSliderThumbLayer *)thumbLayer {
 
    // shadow - magic numbers are trying to mimic the UISlider shadow
    thumbLayer.shadowOffset = CGSizeMake(0, self.trackHeight*0.8);
    thumbLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    thumbLayer.shadowRadius = self.trackHeight*0.8;
    thumbLayer.shadowOpacity = 0.7;
}

@end

#pragma mark - Track Layer

@implementation SERangeSliderTrackLayer

- (void)drawInContext:(CGContextRef)ctx {
    
    if (!self.slider) {
        return;
    }
    
    // the whole track
    UIBezierPath *trackPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.height/2];
    CGContextAddPath(ctx, trackPath.CGPath);
    
    CGContextSetFillColorWithColor(ctx, self.slider.backgroundTrackColor.CGColor);
    CGContextFillPath(ctx);
    
    // the track part in the range
    CGFloat lowerPosition = [self.slider positionForValue:self.slider.lowerValue];
    CGFloat upperPositon = [self.slider positionForValue:self.slider.upperValue];
    CGRect rect = CGRectMake(lowerPosition, 0, upperPositon - lowerPosition, self.bounds.size.height);
    
    CGContextSetFillColorWithColor(ctx, self.slider.inRangeTrackColor.CGColor);
    CGContextFillRect(ctx, rect);
}

@end

#pragma mark - Thumb Layer

@interface SERangeSliderThumbLayer ()

@property (strong, nonatomic) CALayer *imageLayer;


@end

@implementation SERangeSliderThumbLayer

- (instancetype)init {
    if (self = [super init]) {
        self.thumbColor = [UIColor whiteColor];
        
        self.imageLayer = [CALayer layer];
        self.imageLayer.contentsScale = [UIScreen mainScreen].scale;
        self.imageLayer.contentsGravity = kCAGravityCenter;
        [self addSublayer:self.imageLayer];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    
    UIBezierPath *thumbPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    CGContextAddPath(ctx, thumbPath.CGPath);
    
    CGContextSetFillColorWithColor(ctx, self.thumbColor.CGColor);
    CGContextFillPath(ctx);
}

- (void)setThumbImage:(UIImage *)thumbImage {
    if (_thumbImage != thumbImage) {
        _thumbImage = thumbImage;
        
        if (_thumbImage) {
            self.imageLayer.frame = self.bounds;
            self.imageLayer.contents = (__bridge id _Nullable)(_thumbImage.CGImage);
        }
    }
}

@end
