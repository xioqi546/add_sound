//
//  GameScene.m
//  JungleFeast
//
//  Created by Deng Yuanyuan on 13-9-16.
//  Copyright (c) 2013年 Sylvia. All rights reserved.
//

#import "GameScene.h"
#import "CCBReader.h"
#import "SimpleAudioEngine.h"
#import "MainMenuScene.h"
#import "Rabbit.h"
#import "Mouse.h"
#import "Bird2.h"
#import "Rhino.h"
#import "Plane.h"
#import "Arrow.h"

static GameScene* sharedScene;
@implementation GameScene


@synthesize dragon;
@synthesize fire;
@synthesize walkAction;
@synthesize flyAction;
@synthesize walkAction2;
@synthesize moveAction;
@synthesize castlemove;
@synthesize _food;


/*+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	GameScene *layer = [GameScene node];
	[scene addChild: layer];
	return scene;
}
 */
+ (GameScene *) sharedScene
{
    return sharedScene;
}


-(id) init {
    if((self = [super init])) {
        lives = 10;
        castleInitialActionStopFlag = 0;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite * back = [CCSprite spriteWithFile:@"background.png"];
        back.position = ccp( 3*winSize.width/2, winSize.height/2);
        [self addChild:back];
        // initial the danger and food array
        _food = [[NSMutableArray alloc] init];
        _danger = [[NSMutableArray alloc] init];
        // Castle appear
        [self addCastle];
        // particle effect
        fire = [CCParticleSystemQuad particleWithFile:@"kk.plist"];
        [self addChild:fire];
        [fire release];
        fire.positionType = kCCPositionTypeFree;
        fire.startSize = 0.5f;
        
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AnimDragon3.plist"];
        
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"AnimDragon3.png"];
        [self addChild:spriteSheet];
        
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for (int i=1; i<=4; i++) {
            [walkAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"dragon%d.png",i]]];
        }
        
        NSMutableArray *walkAnimFrames2 = [NSMutableArray array];
        for (int i=2; i<=5; i++) {
            [walkAnimFrames2 addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"dragon%d.png",i]]];
        }
        
        CCAnimation *walkAnim = [CCAnimation
                                 animationWithSpriteFrames:walkAnimFrames delay:0.2f];
        CCAnimation *walkAnim2 = [CCAnimation
                                  animationWithSpriteFrames:walkAnimFrames2 delay:0.1f];
        
        
        self.dragon = [CCSprite spriteWithSpriteFrameName:@"dragon2.png"];
        self.dragon.position = ccp(winSize.width/2, winSize.height/2);
        fire.position = self.dragon.position;
        self.walkAction = [CCRepeatForever actionWithAction:
                           [CCAnimate actionWithAnimation:walkAnim]];
        
        self.walkAction2 = [CCRepeatForever actionWithAction:
                            [CCAnimate actionWithAnimation:walkAnim2]];
        
        [self.dragon runAction:self.walkAction];
        
        [spriteSheet addChild:self.dragon];
        [self setTouchEnabled:YES];
        
        //Scores
        num = 0;
        
        
        //label = [CCLabelAtlas labelWithString:@"0" charMapFile:@"tuffy_bold_italic-charmap.png" itemWidth:48 itemHeight:64 startCharMap:' '];
        label = [CCLabelAtlas labelWithString:@"0" charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
        
        label.color = ccc3(0,0,0);
        //label.scale = 0.5;
        //Choose a position on the screen.
        label.position = ccp(winSize.width-100-self.position.x, winSize.height-100);
        //Add it to the scene.
        [self addChild:label];
        
        
    }
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGRect worldBoundary = CGRectMake(0, 0, winSize.width*3, winSize.height);
    [self runAction:[CCFollow actionWithTarget:dragon worldBoundary:worldBoundary]];
    [self schedule:@selector(gameLogic:) interval:2];
    [self schedule:@selector(foodLogic:) interval:2];
    [self schedule:@selector(update:)];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bg.mp3"];
    sharedScene = self;
    return self;
}

-(void)gameLogic:(ccTime)dt {
    [self addPlanes];
    [self addArrow];
    
}
-(void)foodLogic:(ccTime)dt {
    [self addMouse];
    [self addBird2];
    int value = (arc4random() % 20) + 1;
    if(value%2 == 0){
        [self addRabbit];
    }
    if(value%5==0){
        [self addRhino];
    }
}

- (void) addCastle {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AnimCastle.plist"];
    
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"AnimCastle.png"];
    [self addChild:spriteSheet];
    
    
    NSMutableArray *castleanimFrames = [NSMutableArray array];
    for (int i=1; i<=2; i++) {
        [castleanimFrames addObject:
         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
          [NSString stringWithFormat:@"castle%d.png",i]]];
    }
    CCAnimation *walkAnim = [CCAnimation
                             animationWithSpriteFrames:castleanimFrames delay:0.2f];
    CCAction *castleAction = [CCRepeatForever actionWithAction:
                              [CCAnimate actionWithAnimation:walkAnim]];
    
    
    
    self.castle = [CCSprite spriteWithSpriteFrameName:@"castle1.png"];
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    self.castle.position = ccp( winSize.width/2, winSize.height + self.castle.contentSize.height/2);
    
    [self addChild:self.castle];
    [self.castle runAction: castleAction];
    
    actionMove = [CCMoveTo actionWithDuration:3 position:ccp(winSize.width/2, winSize.height - self.castle.contentSize.height/2)];
    [self.castle runAction:[CCSequence actions:actionMove, nil]];
    
}


- (void) addPlanes {
    Plane * plane =[[[Plane alloc] init] autorelease];
    [self addChild:plane.charSprite];
    [_danger addObject:plane];
}

- (void) addArrow {
    Arrow * arrow =[[[Arrow alloc] init] autorelease];
    [self addChild:arrow.charSprite];
    [_danger addObject:arrow];
}

- (void) addRabbit {
    
    
    
    Rabbit * rabbit = [[[Rabbit alloc] init] autorelease];
    [self addChild:rabbit.charSprite];
    [_food addObject:rabbit];

}

- (void) addMouse {
    
    
    
    Mouse * mouse = [[[Mouse alloc] init] autorelease];
    [self addChild:mouse.charSprite];
    [_food addObject:mouse];
    
}

- (void) addBird2 {
    
    
    
    Bird2 * bird2 = [[[Bird2 alloc] init] autorelease];
    [self addChild:bird2.charSprite];
    [_food addObject:bird2];
    
}

- (void) addRhino {
    
    Rhino * rhino = [[[Rhino alloc] init] autorelease];
    [self addChild:rhino.charSprite];
    [_food addObject:rhino];
    
}



- (void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:
     self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    float dragonVelocity = screenSize.width / 3.0;
    if(touch.tapCount==2)
    {
        dragonVelocity = screenSize.width / 1.0;
    }
    CGPoint moveDifference = ccpSub(touchLocation, self.dragon.position);
    float distanceToMove = ccpLength(moveDifference);
    float moveDuration = distanceToMove / dragonVelocity;
    if (moveDifference.x > 0) {
        self.dragon.flipX = NO;
    } else {
        self.dragon.flipX = YES;
    }
    
    
    if (!dragonMoving) {
        [self.dragon stopAction:self.walkAction];
        [self.dragon runAction:self.walkAction2];
    }
    [self.dragon stopAction:self.moveAction];
    [self.castle stopAction:self.castlemove];
    if(castleInitialActionStopFlag == 0){
        [self.castle stopAction:actionMove];
        castleInitialActionStopFlag = 1;
    }
    
    
    
    self.moveAction = [CCSequence actions:
                       [CCMoveTo actionWithDuration:moveDuration position:touchLocation],
                       [CCCallFunc actionWithTarget:self selector:@selector(dragonMoveEnded)],
                       nil];
    CCAction *fireAction = [CCSequence actions:
                            [CCMoveTo actionWithDuration:moveDuration position:touchLocation],
                            nil];
    //****
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    self.castlemove = [CCMoveTo actionWithDuration:moveDuration*1.5 position:ccp(touchLocation.x, winSize.height - self.castle.contentSize.height/2)];
    [self.castle runAction:self.castlemove];
    //****
    [self.dragon runAction:self.moveAction];
    [self.fire runAction:fireAction];
    
    dragonMoving = YES;
    
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:[touch view]];
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    if(touchPoint.x < oldTouchLocation.x){
        dragon.flipX = YES;
    }else{
        dragon.flipX = NO;
    }
	dragon.position=ccp( dragon.position.x*0.95+(touchPoint.x -self.position.x)*0.05,dragon.position.y*0.95+touchPoint.y*0.05);
    
    //*****
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    self.castle.position = ccp( self.castle.position.x*0.97+(touchPoint.x -self.position.x)*0.03, winSize.height - self.castle.contentSize.height/2);
    //*****
    fire.position=dragon.position;
    
    
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    float dragonVelocity = screenSize.width / 3.0;
    float castleVelocity = dragonVelocity;
    if(touch.tapCount==2)
    {
        dragonVelocity = screenSize.width / 1.0;
    }
    CGPoint moveDifference = ccpSub(touchLocation, self.dragon.position);
    float distanceToMove = ccpLength(moveDifference);
    float moveDuration = distanceToMove / dragonVelocity;
    float castleMoveDuration = distanceToMove / castleVelocity;;
    if (moveDifference.x > 0) {
        self.dragon.flipX = NO;
    } else {
        self.dragon.flipX = YES;
    }
    
    
    if (!dragonMoving) {
        [self.dragon stopAction:self.walkAction];
        [self.dragon runAction:self.walkAction2];
    }
    [self.dragon stopAction:self.moveAction];
    [self.castle stopAction:self.castlemove];
    
    
    
    self.moveAction = [CCSequence actions:
                       [CCMoveTo actionWithDuration:moveDuration position:touchLocation],
                       [CCCallFunc actionWithTarget:self selector:@selector(dragonMoveEnded)],
                       nil];
    //****
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    self.castlemove = [CCMoveTo actionWithDuration:castleMoveDuration*1.5 position:ccp(touchLocation.x, winSize.height - self.castle.contentSize.height/2)];
    [self.castle runAction:self.castlemove];
    //****
    
    CCAction *fireAction = [CCSequence actions:
                            [CCMoveTo actionWithDuration:moveDuration position:touchLocation],
                            nil];
    [self.fire runAction:fireAction];
    [self.dragon runAction:self.moveAction];
    
    
    dragonMoving = YES;
}
- (void)dragonMoveEnded
{
    self.fire.position = self.dragon.position;
    [self.dragon stopAction:self.walkAction2];
    [self.dragon runAction:self.walkAction];
    self.fire.position = self.dragon.position;
    dragonMoving = NO;
}

- (void)update:(ccTime)dt {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    label.position = ccp(winSize.width-100-self.position.x, winSize.height-100);
    //    self.castle.position=ccp(winSize.width/2-self.position.x, winSize.height - self.castle.contentSize.height/2);
    //    CCMoveTo *self.castlemoveTo = [CCMoveTo actionWithDuration:1 position:ccp(winSize.width/2-self.position.x, winSize.height - self.castle.contentSize.height/2)];
    //    [self.castle runAction:self.castlemoveTo];
    //[self.castle runAction:[CCFollow actionWithTarget:self]];
    NSMutableArray *foodToDelete = [[NSMutableArray alloc] init];
    NSMutableArray *dangerToDelete = [[NSMutableArray alloc] init];
    for (Food *food in _food) {
        
        // run away function
        
         CGPoint moveDifference = ccpSub(food.charSprite.position, self.dragon.position);
        float distanceToMove = ccpLength(moveDifference);
        if (distanceToMove<200)
        {
            if (food.point >0) {
            //[foodToRunaway addObject:food];
            CGSize winSize = [CCDirector sharedDirector].winSize;
            int finalX;
           int speed = food.speed *3;
            if(food.charSprite.position.x > self.dragon.position.x){
                finalX = 3*winSize.width +food.charSprite.contentSize.width/2;
                food.charSprite.flipX = YES;
            }
            else{
                finalX = 0-food.charSprite.contentSize.width/2;
                food.charSprite.flipX = NO;
            }
            int actualDuration = abs(food.charSprite.position.x - finalX)/speed;
            CCMoveTo * actionMove1 = [CCMoveTo actionWithDuration:actualDuration
                                                         position:ccp(finalX, food.charSprite.position.y)];
            CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
                [node removeFromParentAndCleanup:YES];
            }];
            [food.charSprite stopAction:food.moveAction];
            [food.charSprite runAction:[CCSequence actions:actionMove1, actionMoveDone, nil]];
            }
            
            else {
                int speed = food.speed *2;
                int finalX;
                if(food.charSprite.position.x < self.dragon.position.x){
                    finalX = 3*winSize.width +food.charSprite.contentSize.width/2;
                    food.charSprite.flipX = YES;
                }
                else{
                    finalX = 0-food.charSprite.contentSize.width/2;
                    food.charSprite.flipX = NO;
                }
                int actualDuration = abs(food.charSprite.position.x - finalX)/speed;
                CCMoveTo * actionMove1 = [CCMoveTo actionWithDuration:actualDuration
                                                             position:ccp(finalX, food.charSprite.position.y)];
                CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
                    [node removeFromParentAndCleanup:YES];
                    food.isclean =YES;
                }];
                //[food.charSprite stopAction:food.moveAction];
                [food.charSprite runAction:[CCSequence actions:actionMove1, actionMoveDone, nil]];
            }
            
            
        }
        
    
    
        
        if (CGRectContainsPoint(food.charSprite.boundingBox, dragon.position))
        {
            [foodToDelete addObject:food];
            num = num + food.point;
            NSString *string= [NSString stringWithFormat:@"%i", num];
            [label setString:string];
            
        }
        if(food.isclean){
            [foodToDelete addObject:food];
        }
    }
    
    for (Food *food in foodToDelete) {
        [_food removeObject:food];
        [self removeChild:food.charSprite cleanup:YES];
    }
    [foodToDelete release];
    
    
    
    for (Danger *danger in _danger){
        if (CGRectContainsPoint(danger.charSprite.boundingBox, dragon.position)) {
            [dangerToDelete addObject:danger];
            num = num - danger.hurt;
            NSString *string= [NSString stringWithFormat:@"%i", num];
            [label setString:string];
        }
        if(danger.isclean){
            [dangerToDelete addObject:danger];
        }
    }
    for (Danger *danger in dangerToDelete) {
        [_danger removeObject:danger];
        [self removeChild:danger.charSprite cleanup:YES];
    }
    [dangerToDelete release];
    
    if (num < 0) {
        if(dragonMoving){
            [self.dragon stopAction:self.moveAction];
        }
        CGPoint location = CGPointMake(self.dragon.position.x, -self.dragon.contentSize.height/2 );
        self.dragon.flipY = YES;
        self.moveAction = [CCSequence actions:
                           [CCMoveTo actionWithDuration:0.5 position:location],
                           nil,
                           nil];
        
        [self.dragon runAction:self.moveAction];
        
        
        [[CCDirector sharedDirector] pushScene:[CCTransitionFade transitionWithDuration:1.0 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuScene.ccbi"]]];
        
    }
}

- (void) dealloc
{
    self.dragon=nil;
    self.fire=nil;
    self.walkAction=nil;
    self.flyAction=nil;
    self.walkAction2=nil;
    self.moveAction=nil;
    self.castlemove=nil;
    [_food release];
    _food = nil;
    [_danger release];
    _danger = nil;
    [super dealloc];
}



@end