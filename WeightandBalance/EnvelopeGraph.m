//
//  envelopeGraph.m
//  WeightandBalance
//
//  Created by Adam on 5/1/13.
//  Copyright (c) 2013 Adam. All rights reserved.
//

#import "envelopeGraph.h"
#import "Aircraft.h"
#import "EnvelopePoint.h"

#define ENVELOPE_LINE_WIDTH    2.0
#define ENVELOPE_LINE_COLOR    redColor
#define NUM_X_GRID_LINES   5
#define NUM_Y_GRID_LINES   10
#define FRAME_SIZE_IN_POINTS 10         //gap bewteen the edge of the view and the actual graph - the axis labels and scale live here
#define LABEL_SIZE_IN_POINTS 8          // font size of the axis labels
#define Y_AXIS_LABEL @"Weight (lb)"     
#define X_AXIS_LABEL @"Arm (in)"

@implementation EnvelopeGraph
@synthesize envelope, currentLoading;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef cgx = UIGraphicsGetCurrentContext();
    CGRect graphRect = CGRectMake(FRAME_SIZE_IN_POINTS, FRAME_SIZE_IN_POINTS, self.bounds.size.width-(2*FRAME_SIZE_IN_POINTS), self.bounds.size.height-(2*FRAME_SIZE_IN_POINTS));
    
    if ([envelope count] >=3) {  //dont draw anything if not enough points
        
        //draw some grid lines
        CGContextSetLineWidth(cgx, 1);
        CGContextSetStrokeColorWithColor(cgx, [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]CGColor]);
    
        
        for (float i=0; i<NUM_X_GRID_LINES; i++){
            CGContextMoveToPoint(cgx, graphRect.origin.x, i*(graphRect.size.height/NUM_X_GRID_LINES)+graphRect.origin.y);
            CGContextAddLineToPoint(cgx, graphRect.origin.x+graphRect.size.width , i*(graphRect.size.height/NUM_X_GRID_LINES)+graphRect.origin.y);
        }
        
        for (int i=0; i<NUM_Y_GRID_LINES; i++) {
            CGContextMoveToPoint(cgx,i*graphRect.size.width/NUM_Y_GRID_LINES+graphRect.origin.x, graphRect.origin.y);
            CGContextAddLineToPoint(cgx, i*graphRect.size.width/NUM_Y_GRID_LINES+graphRect.origin.x, graphRect.origin.y+graphRect.size.height);
     
        }
        
        //complete the border
        CGContextMoveToPoint(cgx, graphRect.origin.x, graphRect.origin.y+graphRect.size.height);
        CGContextAddLineToPoint(cgx, graphRect.origin.x+graphRect.size.width, graphRect.origin.y+graphRect.size.height);
        CGContextAddLineToPoint(cgx, graphRect.origin.x+graphRect.size.width, graphRect.origin.y);
        CGContextDrawPath(cgx, kCGPathStroke);
        
        
        CGContextSetLineWidth(cgx, ENVELOPE_LINE_WIDTH);
        CGContextSetStrokeColorWithColor (cgx, [[UIColor ENVELOPE_LINE_COLOR]CGColor]);
        
        //create a resuable path for the envelope (we'll use it both to draw and to calc whether the X is inside)
        CGMutablePathRef envelopePath = CGPathCreateMutable();
        
        float maxArm = 0, maxWeight = 0, minArm = 999999, minWeight = 999999;
        
        for (EnvelopePoint *ep in envelope) {        //first capture the highest values
            maxArm = MAX(maxArm, [ep armAsFloat]);
            minArm = MIN(minArm, [ep armAsFloat]);
            maxWeight = MAX(maxWeight, [ep weightAsFloat]);
            minWeight = MIN(minWeight, [ep weightAsFloat]);
        }
        
        //check the loadpoint too for scaling
        if (currentLoading) {
            maxArm = MAX(maxArm, [currentLoading armAsFloat]);
            minArm = MIN(minArm, [currentLoading armAsFloat]);
            maxWeight = MAX(maxWeight, [currentLoading weightAsFloat]);
            minWeight = MIN(minWeight, [currentLoading weightAsFloat]);
        }
        
        
        
        
        //add some numbers to the picture
    
        //need to create a NSdictionary for the string attributes
        NSDictionary *labelDict = [[NSDictionary alloc] initWithObjects:@[[UIFont italicSystemFontOfSize:LABEL_SIZE_IN_POINTS]]forKeys:@[NSFontAttributeName]];
        
        CGSize maxArmSize = [[NSString stringWithFormat:@"%1.0f",maxArm] sizeWithAttributes:labelDict];
        CGSize maxWeightSize = [[NSString stringWithFormat:@"%1.0f",maxWeight] sizeWithAttributes:labelDict];
        CGSize xLabelSize = [[NSString stringWithFormat:X_AXIS_LABEL] sizeWithAttributes:labelDict];
        CGSize yLabelSize = [[NSString stringWithFormat:Y_AXIS_LABEL] sizeWithAttributes:labelDict];
        
        
        [[NSString stringWithFormat:@"%1.0f",minArm] drawAtPoint:CGPointMake(FRAME_SIZE_IN_POINTS, self.bounds.size.height- FRAME_SIZE_IN_POINTS) withAttributes:labelDict];
    
        [[NSString stringWithFormat:@"%1.0f",maxArm] drawAtPoint:CGPointMake(self.bounds.size.width-maxArmSize.width-FRAME_SIZE_IN_POINTS, self.bounds.size.height - FRAME_SIZE_IN_POINTS) withAttributes:labelDict];

        
        [self drawVerticallyAtPoint:[NSString stringWithFormat:@"%1.0f",maxWeight]
                        withContext:cgx
                            atPoint:CGPointMake(1, FRAME_SIZE_IN_POINTS+maxWeightSize.width)
                           withFont:[UIFont systemFontOfSize:LABEL_SIZE_IN_POINTS]];
        
        [self drawVerticallyAtPoint:[NSString stringWithFormat:@"%1.0f",minWeight]
                        withContext:cgx
                            atPoint:CGPointMake(1, self.bounds.size.height-FRAME_SIZE_IN_POINTS)
                           withFont:[UIFont systemFontOfSize:LABEL_SIZE_IN_POINTS]];

        //label the axes
        
        [self drawVerticallyAtPoint:Y_AXIS_LABEL withContext:cgx atPoint:CGPointMake(1, (graphRect.size.height+yLabelSize.width)/2+graphRect.origin.y) withFont:[UIFont systemFontOfSize:LABEL_SIZE_IN_POINTS]];
        
        [X_AXIS_LABEL drawAtPoint:CGPointMake(graphRect.origin.x+(graphRect.size.width-xLabelSize.width)/2 , self.bounds.size.height-FRAME_SIZE_IN_POINTS) withAttributes:labelDict];
       
        float hScale = (graphRect.size.width/(maxArm - minArm)) ;
        float vScale = (graphRect.size.height)/(maxWeight - minWeight);
        
        //move to the first envelope point
        CGPathMoveToPoint(envelopePath, NULL,
                          graphRect.origin.x+(([envelope[0] armAsFloat]-minArm)*hScale),
                          graphRect.origin.y+(maxWeight-[envelope[0] weightAsFloat])*vScale);
        
    
        for (EnvelopePoint *ep in envelope) {        //cycle through the points
            CGPathAddLineToPoint(envelopePath, NULL,
                                 graphRect.origin.x+(([ep armAsFloat]-minArm)*hScale),
                                 graphRect.origin.y+(maxWeight-[ep weightAsFloat])*vScale);
        }
          //and draw
        CGContextAddPath(cgx, envelopePath);
        CGContextDrawPath(cgx,kCGPathStroke);
        
        if ([self currentLoading]) {
            
            //grab a copy of the path, closing it first
            CGPathCloseSubpath(envelopePath);
            
            float crossX = graphRect.origin.x + (([[self currentLoading] armAsFloat]-minArm)*hScale);
            float crossY = graphRect.origin.y + ((maxWeight - [[self currentLoading] weightAsFloat])*vScale);
            
            CGContextMoveToPoint(cgx, crossX, crossY);
            
            float crossSize = 5;
            CGContextSetLineWidth(cgx, 3.0);
            
            //evaluate if the cross is inside the envelope
            BOOL crossIsInside  = CGPathContainsPoint(envelopePath, NULL, CGPointMake(crossX, crossY), NO);
            CGContextSetStrokeColorWithColor (cgx, (crossIsInside) ? [[UIColor greenColor]CGColor] :
                                                                     [[UIColor redColor]CGColor]);
            
            
            // draw an X
            CGContextMoveToPoint(cgx, crossX-crossSize, crossY-crossSize);
            CGContextAddLineToPoint(cgx,crossX+crossSize, crossY+crossSize);
            CGContextMoveToPoint(cgx, crossX-crossSize, crossY+crossSize);
            CGContextAddLineToPoint(cgx,crossX+crossSize, crossY-crossSize);
            CGContextDrawPath(cgx, kCGPathStroke);
        }
    }
}

    
- (void)drawVerticallyAtPoint:(NSString *)string
                  withContext:(CGContextRef)context
                      atPoint:(CGPoint)point
                     withFont:(UIFont *)font

    {
                CGContextSaveGState(context);
        CGContextTranslateCTM(context, point.x, point.y);
        
        CGAffineTransform textTransform = CGAffineTransformMakeRotation(-M_PI_2);
        CGContextConcatCTM(context, textTransform);
        CGContextTranslateCTM(context, -point.x, -point.y);
        NSDictionary *labelDict = [[NSDictionary alloc] initWithObjects:@[font]
                                                                forKeys:@[NSFontAttributeName]];
        
        [string drawAtPoint:point withAttributes:labelDict];
        CGContextRestoreGState(context);
    }
    

@end
