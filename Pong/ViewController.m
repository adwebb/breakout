//
//  ViewController.m
//  Pong
//
//  Created by Andrew Webb on 1/16/14.
//  Copyright (c) 2014 Andrew Webb. All rights reserved.
//

#import "ViewController.h"
#import "BallView.h"
#import "PaddleView.h"

@interface ViewController () <UICollisionBehaviorDelegate>
{
    IBOutlet BallView* ballView;
    IBOutlet PaddleView* paddleView;
    IBOutlet PaddleView* autoPaddleView;
    
    UIDynamicAnimator* dynamicAnimator;
    UIPushBehavior* pushBehavior;
    UICollisionBehavior* collisionBehavior;
    BOOL autoPaddleCollisionRight;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIDynamicItemBehavior* ballDynamicBehavior;
    UIDynamicItemBehavior* paddleDynamicBehavior;
    
    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    pushBehavior = [[UIPushBehavior alloc] initWithItems:@[ballView] mode:UIPushBehaviorModeInstantaneous];
    
    float initialVectorX = arc4random()%101/100.0;
    float initialVectorY = arc4random()%101/100.0;
    
    int tempX = arc4random()%1;
    int tempY = arc4random()%1;
    
    if (tempX == 0) {
        initialVectorX *= -1;
    }
    
    if (tempY == 0) {
        initialVectorY *= -1;
    }
    
    pushBehavior.pushDirection = CGVectorMake(initialVectorX, initialVectorY);
    pushBehavior.active = YES;
    pushBehavior.magnitude = 0.5;
    
    [dynamicAnimator addBehavior:pushBehavior];
    
    collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[ballView,paddleView, autoPaddleView]];
    
    collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    
    [dynamicAnimator addBehavior:collisionBehavior];
    
    ballDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[ballView]];
    ballDynamicBehavior.allowsRotation = NO;
    ballDynamicBehavior.elasticity = 1.0;
    ballDynamicBehavior.friction = 0.0;
    ballDynamicBehavior.resistance = 0.0;
    ballDynamicBehavior.density = 1;
    
    [dynamicAnimator addBehavior:ballDynamicBehavior];
    
    paddleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[paddleView, autoPaddleView]];
    paddleDynamicBehavior.allowsRotation = NO;
    paddleDynamicBehavior.density = 1000000;
    
    [dynamicAnimator addBehavior:paddleDynamicBehavior];
    
    [UIView animateWithDuration:0.5 animations:^{
        autoPaddleView.center = CGPointMake(200, 200);
    } completion:^(BOOL finished) {
        [dynamicAnimator updateItemUsingCurrentState:autoPaddleView];
    }];
//    [UIView animateWithDuration:0.5 animations:^{;
 //       autoPaddleView.center = CGPointMake(200, 200);
        //autoPaddleView.transform = CGAffineTransformMakeTranslation((autoPaddleView.center.x + 108),autoPaddleView.center.y);
   // }];
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if([item isEqual:autoPaddleView])
    {
        if (autoPaddleCollisionRight)
        {
            [UIView animateWithDuration:1.0 animations:^{
                autoPaddleView.transform = CGAffineTransformMakeTranslation((autoPaddleView.center.x - 216),autoPaddleView.center.y);
                autoPaddleCollisionRight = NO;
            }];
        }else{
            [UIView animateWithDuration:1.0 animations:^{
                autoPaddleView.transform = CGAffineTransformMakeTranslation((autoPaddleView.center.x + 216),autoPaddleView.center.y);
                autoPaddleCollisionRight = YES;
            }];
        }
    }
    
    NSLog([NSString stringWithFormat:@"Collision with boundary %@", identifier]);
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p
{
    NSLog(@"Collision with Paddle");
}

-(IBAction)dragPaddle:(UIPanGestureRecognizer*)panGestureRecognizer
{
    paddleView.center = CGPointMake([panGestureRecognizer locationInView:self.view].x,paddleView.center.y);
    [dynamicAnimator updateItemUsingCurrentState:paddleView];
}

@end
