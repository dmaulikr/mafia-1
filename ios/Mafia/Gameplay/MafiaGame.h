//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MafiaAction;
@class MafiaGameSetup;
@class MafiaPlayer;
@class MafiaPlayerList;
@class MafiaRole;


@interface MafiaGame : NSObject

@property (readonly, strong, nonatomic) MafiaGameSetup *gameSetup;
@property (readonly, strong, nonatomic) MafiaPlayerList *playerList;
@property (copy, nonatomic) NSArray *actions;
@property (assign, nonatomic) NSInteger round;
@property (assign, nonatomic) NSInteger actionIndex;
@property (copy, nonatomic) NSString *winner;

- (instancetype)initWithPlayerNames:(NSArray *)playerNames isTwoHanded:(BOOL)isTwoHanded;

- (instancetype)initWithGameSetup:(MafiaGameSetup *)gameSetup
    NS_DESIGNATED_INITIALIZER;

- (void)reset;

- (BOOL)checkGameOver;

- (void)assignRole:(MafiaRole *)role toPlayers:(NSArray *)players;

- (void)assignCivilianRoleToUnrevealedPlayers;

- (void)assignRolesRandomly;

- (BOOL)isReadyToStart;

- (void)startGame;

- (MafiaAction *)currentAction;

- (MafiaAction *)continueToNextAction;

@end
