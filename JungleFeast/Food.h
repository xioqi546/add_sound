//
//  Food.h
//  JungleFeast
//
//  Created by Sylvia on 13-9-25.
//  Copyright 2013年 Sylvia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Food : CCNode {
    CCSprite *charSprite;
    CCAction *walkAction;
    int speed;
    int point;
    BOOL isclean;
    CCAction *moveAction;
}

@property (nonatomic, retain) CCSprite *charSprite;
@property (nonatomic, retain) CCAction *walkAction;
@property (readwrite) int speed;
@property (readwrite) int point;
@property (readwrite) BOOL isclean;
@property (nonatomic, strong) CCAction *moveAction;
@end
