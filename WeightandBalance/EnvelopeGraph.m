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
    CGRect graphSize = [self bounds];
    
    if ([envelope count] >=3) {  //dont draw anything if not enough points
        
        //draw some grid lines
        CGContextSetLineWidth(cgx, 1);
        CGContextSetStrokeColorWithColor(cgx, [[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]CGColor]);
    
        
        for (float i=0; i<NUM_X_GRID_LINES; i++){
            CGContextMoveToPoint(cgx, 0, i*(graphSize.size.height/NUM_X_GRID_LINES));
            CGContextAddLineToPoint(cgx, graphSize.size.width, i*(graphSize.size.height/NUM_X_GRID_LINES));
        }
        
        for (int i=0; i<NUM_Y_GRID_LINES; i++) {
            CGContextMoveToPoint(cgx,i*graphSize.size.width/NUM_Y_GRID_LINES, 0);
            CGContextAddLineToPoint(cgx, i*graphSize.size.width/NUM_Y_GRID_LINES, graphSize.size.height);
     
        }
        
        //complete the border
        CGContextMoveToPoint(cgx, 0, graphSize.size.height);
        CGContextAddLineToPoint(cgx, graphSize.size.width, graphSize.size.height);
        CGContextAddLineToPoint(cgx, graphSize.size.width, 0);
        CGContextDrawPath(cgx, kCGPathStroke);
        
        
        CGContextSetLineWidth(cgx, ENVELOPE_LINE_WIDTH);
        CGContextSetStrokeColor (cgx, CGColorGetComponents([[UIColor ENVELOPE_LINE_COLOR]CGColor]));
        
        //create a resuable path for the envelope (we'll use it both to draw and to calc whether the X is inside)
        CGMutablePathRef envelopePath = CGPathCreateMutable();
        CGPathMoveToPoint(envelopePath, NULL, 0, graphSize.size.height);     // start in the bottom left hand corner
        
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
        [[NSString stringWithFormat:@"%1.0f",maxWeight] drawAtPoint:CGPointMake(1, 0) withFont:[UIFont systemFontOfSize:8]];
        
        [[NSString stringWithFormat:@"%1.0f",minWeight] drawAtPoint:CGPointMake(1, graphSize.size.height-15) withFont:[UIFont systemFontOfSize:8]];
        
        [[NSString stringWithFormat:@"%1.0f",minArm] drawAtPoint:CGPointMake(20, graphSize.size.height - 10) withFont:[UIFont italicSystemFontOfSize:8]];
        
        CGSize maxArmSize = [[NSString stringWithFormat:@"%1.0f",maxArm] sizeWithFont:[UIFont italicSystemFontOfSize:8]];
        
        [[NSString stringWithFormat:@"%1.0f",maxArm] drawAtPoint:CGPointMake(graphSize.size.width-maxArmSize.width, graphSize.size.height - 10) withFont:[UIFont italicSystemFontOfSize:8]];
       
        float hScale = (graphSize.size.width/(maxArm - minArm)) ;
        float vScale = (graphSize.size.height)/(maxWeight - minWeight);
        
        

        for (EnvelopePoint *ep in envelope) {        //cycle through the points now add the points
            CGPathAddLineToPoint(envelopePath, NULL,([ep armAsFloat]-minArm)*hScale, (maxWeight-[ep weightAsFloat])*vScale);   //scale the height to the mgw
        }
          //and draw
        CGContextAddPath(cgx, envelopePath);
        CGContextDrawPath(cgx,kCGPathStroke);
        
        if ([self currentLoading]) {
            
            //grab a copy of the path, closing it first
            CGPathCloseSubpath(envelopePath);
            
            float crossX = ([[self currentLoading] armAsFloat]-minArm)*hScale;
            float crossY = (maxWeight - [[self currentLoading] weightAsFloat])*vScale;
            
            CGContextMoveToPoint(cgx, crossX, crossY);
            
            float crossSize = 5;
            CGContextSetLineWidth(cgx, 3.0);
            
            //evaluate if the cross is inside the envelope
            BOOL crossIsInside  = CGPathContainsPoint(envelopePath, NULL, CGPointMake(crossX, crossY), NO);
            CGContextSetStrokeColor (cgx, (crossIsInside) ? CGColorGetComponents([[UIColor greenColor]CGColor]) :
                                                            CGColorGetComponents([[UIColor redColor]CGColor]));
            
            
            // draw an X
            CGContextMoveToPoint(cgx, crossX-crossSize, crossY-crossSize);
            CGContextAddLineToPoint(cgx,crossX+crossSize, crossY+crossSize);
            CGContextMoveToPoint(cgx, crossX-crossSize, crossY+crossSize);
            CGContextAddLineToPoint(cgx,crossX+crossSize, crossY-crossSize);
            CGContextDrawPath(cgx, kCGPathStroke);
        }
    }
    
}
@end
