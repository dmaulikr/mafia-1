//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaSettleTagsAction.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"


@interface MafiaSettleTagsAction ()

- (NSArray *)settleAssassinTag;

- (NSArray *)settleGuardianTag;

- (NSArray *)settleKillerTag;

- (NSArray *)settleDoctorTag;

- (NSArray *)settleIntrospectionTags;

@end


@implementation MafiaSettleTagsAction


- (id)initWithPlayerList:(MafiaPlayerList *)playerList
{
    if (self = [super initWithNumberOfActors:0 playerList:playerList])
    {
        self.isAssigned = YES; // TODO;
    }
    return self;
}


+ (id)actionWithPlayerList:(MafiaPlayerList *)playerList
{
    return [[[self alloc] initWithPlayerList:playerList] autorelease];
}


- (NSString *)description
{
    return @"Settle Tags";
}


- (void)reset
{
    [super reset];
    self.isAssigned = YES;
}


- (NSArray *)actors
{
    return [NSArray arrayWithObjects:nil];
}


- (BOOL)isPlayerSelectable:(MafiaPlayer *)player
{
    return NO;
}


- (void)beginAction
{
    [super beginAction];
    for (MafiaPlayer *player in self.playerList.players)
    {
        if ([player isUnrevealed])
        {
            player.role = [MafiaRole civilian];
        }
    }
}


- (NSArray *)endAction
{
    return [self settleTags];
}


- (NSArray *)settleTags
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    [messages addObjectsFromArray:[self settleAssassinTag]];
    [messages addObjectsFromArray:[self settleGuardianTag]];
    [messages addObjectsFromArray:[self settleKillerTag]];
    [messages addObjectsFromArray:[self settleDoctorTag]];
    [messages addObjectsFromArray:[self settleIntrospectionTags]];
    return messages;
}


#pragma mark - Private methods


- (NSArray *)settleAssassinTag
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If a player is assassined, he's definitely killed.
    BOOL isGuardianKilled = NO;
    for (MafiaPlayer *assassinedPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole assassin]])
    {
        [messages addObject:[NSString stringWithFormat:@"%@ was assassined.", assassinedPlayer]];
        [assassinedPlayer markDead];
        if (assassinedPlayer.role == [MafiaRole guardian])
        {
            isGuardianKilled = YES;
        }
    }
    // If guardian is assassined, the guarded player is also dead.
    // Note: when settling assassin tag, guardian tag has not yet been settled.
    if (isGuardianKilled)
    {
        for (MafiaPlayer *guardedPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole guardian]])
        {
            [messages addObject:[NSString stringWithFormat:@"%@ was guarded and was dead with guardian.", guardedPlayer]];
            [guardedPlayer markDead];
        }
    }
    return messages;
}


- (NSArray *)settleGuardianTag
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // Check the guarded players...
    for (MafiaPlayer *guardedPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole guardian]])
    {
        if (guardedPlayer.role == [MafiaRole killer])
        {
            // If killer is guarded, nobody can be shot except guardian himself.
            for (MafiaPlayer *shotPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole killer]])
            {
                if (shotPlayer.role != [MafiaRole guardian])
                {
                    [messages addObject:[NSString stringWithFormat:@"%@ was guarded and failed to shoot.", guardedPlayer]];
                    [shotPlayer unselectFromRole:[MafiaRole killer]];
                }
                else
                {
                    [messages addObject:[NSString stringWithFormat:@"%@ was guarded and %@ was shot.", guardedPlayer, shotPlayer]];
                }
            }
        }
        else if (guardedPlayer.role == [MafiaRole doctor])
        {
            // If doctor is guarded, nobody can be healt.
            [messages addObject:[NSString stringWithFormat:@"%@ was guarded and failed to heal.", guardedPlayer]];
            for (MafiaPlayer *healtPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole doctor]])
            {
                [healtPlayer unselectFromRole:[MafiaRole doctor]];
            }
        }
        // Generally, if a player is guarded, he can neither be healt nor be shot.
        // Exception: if guardian is guarded, he can still be shot.
        if ([guardedPlayer isSelectedByRole:[MafiaRole doctor]])
        {
            [messages addObject:[NSString stringWithFormat:@"%@ was guarded and could not be healt.", guardedPlayer]];
            [guardedPlayer unselectFromRole:[MafiaRole doctor]];
        }
        if ([guardedPlayer isSelectedByRole:[MafiaRole killer]] && guardedPlayer.role != [MafiaRole guardian])
        {
            [messages addObject:[NSString stringWithFormat:@"%@ was guarded and could not be shot.", guardedPlayer]];
            [guardedPlayer unselectFromRole:[MafiaRole killer]];
        }
    }
    // Make player unguardable if he's guarded twice continuously.
    for (MafiaPlayer *player in [self.playerList alivePlayers])
    {
        if ([player isSelectedByRole:[MafiaRole guardian]])
        {
            if (player.isJustGuarded)
            {
                [messages addObject:[NSString stringWithFormat:@"%@ was guarded twice continuously and became unguardable.", player]];
                player.isUnguardable = YES;
            }
            player.isJustGuarded = YES;
            [player unselectFromRole:[MafiaRole guardian]];
        }
        else
        {
            player.isJustGuarded = NO;
        }
    }
    // Return messages.
    return messages;
}


- (NSArray *)settleKillerTag
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If a player is shot, he's killed unless his role is assassin or he's healt.
    BOOL isGuardianKilled = NO;
    for (MafiaPlayer *shotPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole killer]])
    {
        if (shotPlayer.role == [MafiaRole assassin])
        {
            [messages addObject:[NSString stringWithFormat:@"%@ dodged the bullet from killer.", shotPlayer]];
            [shotPlayer unselectFromRole:[MafiaRole killer]];
        }
        else if ([shotPlayer isSelectedByRole:[MafiaRole doctor]])
        {
            [messages addObject:[NSString stringWithFormat:@"%@ was shot but healt.", shotPlayer]];
            [shotPlayer unselectFromRole:[MafiaRole killer]];
            [shotPlayer unselectFromRole:[MafiaRole doctor]];
        }
        else
        {
            [messages addObject:[NSString stringWithFormat:@"%@ was shot and killed.", shotPlayer]];
            [shotPlayer markDead];
            if (shotPlayer.role == [MafiaRole guardian])
            {
                isGuardianKilled = YES;
            }
        }
    }
    // If guardian is killed, the guarded player is also dead.
    // Note: when settling killer tag, guardian tag has already been settled.
    if (isGuardianKilled)
    {
        for (MafiaPlayer *player in [self.playerList alivePlayers])
        {
            if (player.isJustGuarded)
            {
                [messages addObject:[NSString stringWithFormat:@"%@ was guarded and was dead with guardian.", player]];
                [player markDead];
            }
        }
    }
    return messages;
}


- (NSArray *)settleDoctorTag
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If player is misdiagnosed twice, he's killed.
    for (MafiaPlayer *healtPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole doctor]])
    {
        if ([healtPlayer isSelectedByRole:[MafiaRole killer]])
        {
            [messages addObject:[NSString stringWithFormat:@"%@ was shot but healt.", healtPlayer]];
            [healtPlayer unselectFromRole:[MafiaRole killer]];
            [healtPlayer unselectFromRole:[MafiaRole doctor]];
        }
        else if (healtPlayer.isMisdiagnosed)
        {
            [messages addObject:[NSString stringWithFormat:@"%@ was misdiagnosed twice and killed.", healtPlayer]];
            [healtPlayer markDead];
        }
        else
        {
            [messages addObject:[NSString stringWithFormat:@"%@ was misdiagnosed.", healtPlayer]];
            healtPlayer.isMisdiagnosed = YES;
            [healtPlayer unselectFromRole:[MafiaRole doctor]];
        }
    }
    return messages;
}


- (NSArray *)settleIntrospectionTags
{
    for (MafiaPlayer *player in [self.playerList alivePlayers])
    {
        [player unselectFromRole:[MafiaRole detective]];
        [player unselectFromRole:[MafiaRole traitor]];
        [player unselectFromRole:[MafiaRole undercover]];
    }
    return [NSArray arrayWithObjects:nil];
}


@end // MafiaSettleTagsAction

