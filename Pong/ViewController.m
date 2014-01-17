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
#import "BlockView.h"

@interface ViewController () <UICollisionBehaviorDelegate, UIDynamicAnimatorDelegate>
{
    IBOutlet BallView* ballView;
    IBOutlet PaddleView* paddleView;
   // IBOutlet BlockView* blockView;
    
    NSMutableArray* blocks;
    
    UIDynamicAnimator* dynamicAnimator;
    UIPushBehavior* pushBehavior;
    UICollisionBehavior* collisionBehavior;
    
    UIDynamicItemBehavior* ballDynamicBehavior;
    UIDynamicItemBehavior* paddleDynamicBehavior;
    
    int frameOffset;
}

@end

@implementation ViewController

- (void)viewDidLoad


{
    [super viewDidLoad];
    dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    dynamicAnimator.delegate = self;
    frameOffset = (self.view.frame.size.height - ballView.frame.size.height);
    
    blocks = [NSMutableArray array];
    int blockCount;
    for (blockCount = 9; blockCount > 0; blockCount--) {
        BlockView* block = [[BlockView alloc] initWithFrame:CGRectMake(blockCount*50.0, blockCount*50.0, 25.0, 25.0)];
        block.backgroundColor = [UIColor whiteColor];
        [blocks addObject:block];
        [self.view addSubview:block];
    }
    UIDynamicItemBehavior* blockBehavior = [[UIDynamicItemBehavior alloc] initWithItems:blocks];
    blockBehavior.allowsRotation = NO;
    blockBehavior.density = 10000;

    [dynamicAnimator addBehavior:blockBehavior];

//    int i = 1;
//    for (BlockView* block in blocks) {
//        [self.view addSubview:block];
//        int offset = 100*(i%3);
//        float offsetF = offset;
//        
//        [block setFrame:CGRectMake(offsetF, offsetF, 50.0, 50.0)];
//        
//        
//        i++;
//    }
    
    [self addAllBehaviorsToDynamicAnimator];
  
}

-(void)addAllBehaviorsToDynamicAnimator
{
    
        pushBehavior = [[UIPushBehavior alloc] initWithItems:@[ballView] mode:UIPushBehaviorModeInstantaneous];
        pushBehavior.pushDirection = CGVectorMake(0.5, 1.0);
        pushBehavior.active = YES;
        pushBehavior.magnitude = 0.3;
        [dynamicAnimator addBehavior:pushBehavior];
    
        NSMutableArray* everythingCollides = blocks;
        [everythingCollides addObject:ballView];
        [everythingCollides addObject:paddleView];
    
        collisionBehavior = [[UICollisionBehavior alloc] initWithItems:everythingCollides];
        collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
        collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
        collisionBehavior.collisionDelegate = self;
        [dynamicAnimator addBehavior:collisionBehavior];
        
        ballDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[ballView]];
        ballDynamicBehavior.allowsRotation = NO;
        ballDynamicBehavior.elasticity = 1.0;
        ballDynamicBehavior.friction = 0.0;
        ballDynamicBehavior.resistance = 0.0;
        [dynamicAnimator addBehavior:ballDynamicBehavior];
        
        paddleDynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[paddleView]];
        paddleDynamicBehavior.allowsRotation = NO;
        paddleDynamicBehavior.density = 10000;
        [dynamicAnimator addBehavior:paddleDynamicBehavior];
}

-(void)removeEverything
{
    ballView.center = self.view.center;
    [pushBehavior removeItem:ballView];
    [collisionBehavior removeItem:ballView];
    [collisionBehavior removeItem:paddleView];
    [ballDynamicBehavior removeItem:ballView];
    [paddleDynamicBehavior removeItem:paddleView];
    
    [dynamicAnimator removeAllBehaviors];
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    if (ballView.center.y > frameOffset) {
       
        [self removeEverything];
        
    }
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2
{
    if ([item1 isKindOfClass:[BlockView class]]){
        [self removeBlock:item1];
        [blocks removeObject:item1];
        [collisionBehavior removeItem:item1];
        
    }
    
    if ([item2 isKindOfClass:[BlockView class]]) {
        [self removeBlock:item2];
        [blocks removeObject:item2];
        [collisionBehavior removeItem:item1];

    }
}


-(void)removeBlock:(BlockView*)block
{
    [block removeFromSuperview];
}

-(void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    [self addAllBehaviorsToDynamicAnimator];
}

-(IBAction)dragPaddle:(UIPanGestureRecognizer*)panGestureRecognizer
{
    paddleView.center = CGPointMake([panGestureRecognizer locationInView:self.view].x,paddleView.center.y);
    [dynamicAnimator updateItemUsingCurrentState:paddleView];
}

@end
