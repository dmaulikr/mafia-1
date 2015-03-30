//
//  Created by ZHENG Zhong on 2012-11-22.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaSettleTagsAction.h"
#import "MafiaInformation.h"
#import "MafiaNumberRange.h"
#import "MafiaPlayer.h"
#import "MafiaPlayerList.h"
#import "MafiaRole.h"


@interface MafiaSettleTagsAction ()

- (NSArray *)settleAssassinTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames;

- (NSArray *)settleGuardianTag;

- (NSArray *)settleKillerTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames;

- (NSArray *)settleDoctorTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames;

- (NSArray *)settleIntrospectionTags;

@end


@implementation MafiaSettleTagsAction


+ (id)actionWithPlayerList:(MafiaPlayerList *)playerList
{
    return [[self alloc] initWithPlayerList:playerList];
}


- (id)initWithPlayerList:(MafiaPlayerList *)playerList
{
    if (self = [super initWithNumberOfActors:0 playerList:playerList])
    {
        self.isAssigned = YES; // TODO;
    }
    return self;
}


- (NSString *)description
{
    return NSLocalizedString(@"Settle Tags", nil);
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


- (MafiaNumberRange *)numberOfChoices
{
    return [MafiaNumberRange numberRangeWithSingleValue:0];
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


- (MafiaInformation *)endAction
{
    return [self settleTags];
}


- (MafiaInformation *)settleTags
{
    MafiaInformation *information = [MafiaInformation announcementInformation];
    // Settle tags and collect information details.
    NSMutableArray *deadPlayerNames = [NSMutableArray arrayWithCapacity:4];
    [information addDetails:[self settleAssassinTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self settleGuardianTag]];
    [information addDetails:[self settleKillerTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self settleDoctorTagAndSaveDeadPlayerNamesTo:deadPlayerNames]];
    [information addDetails:[self settleIntrospectionTags]];
    // Construct information message.
    if ([deadPlayerNames count] == 0)
    {
        information.message = NSLocalizedString(@"Nobody was dead", nil);
    }
    else if ([deadPlayerNames count] == 1)
    {
        NSString *deadPlayerName = [deadPlayerNames objectAtIndex:0];
        information.message = [NSString stringWithFormat:NSLocalizedString(@"%@ was dead", nil), deadPlayerName];
    }
    else
    {
        NSString *deadPlayerNamesString = [deadPlayerNames componentsJoinedByString:@", "];
        information.message = [NSString stringWithFormat:NSLocalizedString(@"%@ were dead", nil), deadPlayerNamesString];
    }
    return information;
}


#pragma mark - Private methods


- (NSArray *)settleAssassinTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If a player is assassined, he's definitely killed.
    BOOL isGuardianKilled = NO;
    for (MafiaPlayer *assassinedPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole assassin]])
    {
        [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was assassined", nil), assassinedPlayer]];
        [assassinedPlayer markDead];
        [deadPlayerNames addObject:assassinedPlayer.name];
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
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and was dead with guardian", nil), guardedPlayer]];
            [guardedPlayer markDead];
            [deadPlayerNames addObject:guardedPlayer.name];
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
                    [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and failed to shoot", nil), guardedPlayer]];
                    [shotPlayer unselectFromRole:[MafiaRole killer]];
                }
                else
                {
                    [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%1$@ was guarded and %2$@ was shot", nil), guardedPlayer, shotPlayer]];
                }
            }
        }
        else if (guardedPlayer.role == [MafiaRole doctor])
        {
            // If doctor is guarded, nobody can be healt.
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and failed to heal", nil), guardedPlayer]];
            for (MafiaPlayer *healtPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole doctor]])
            {
                [healtPlayer unselectFromRole:[MafiaRole doctor]];
            }
        }
        // Generally, if a player is guarded, he can neither be healt nor be shot.
        // Exception: if guardian is guarded, he can still be shot.
        if ([guardedPlayer isSelectedByRole:[MafiaRole doctor]])
        {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and could not be healt", nil), guardedPlayer]];
            [guardedPlayer unselectFromRole:[MafiaRole doctor]];
        }
        if ([guardedPlayer isSelectedByRole:[MafiaRole killer]] && guardedPlayer.role != [MafiaRole guardian])
        {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and could not be shot", nil), guardedPlayer]];
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
                [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded twice continuously and became unguardable", nil), player]];
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


- (NSArray *)settleKillerTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If a player is shot, he's killed unless his role is assassin or he's healt.
    BOOL isGuardianKilled = NO;
    for (MafiaPlayer *shotPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole killer]])
    {
        if (shotPlayer.role == [MafiaRole assassin])
        {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ dodged the bullet from killer", nil), shotPlayer]];
            [shotPlayer unselectFromRole:[MafiaRole killer]];
        }
        else if ([shotPlayer isSelectedByRole:[MafiaRole doctor]])
        {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was shot but healt", nil), shotPlayer]];
            [shotPlayer unselectFromRole:[MafiaRole killer]];
            [shotPlayer unselectFromRole:[MafiaRole doctor]];
        }
        else
        {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was shot and killed", nil), shotPlayer]];
            [shotPlayer markDead];
            [deadPlayerNames addObject:shotPlayer.name];
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
                [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was guarded and was dead with guardian", nil), player]];
                [player markDead];
                [deadPlayerNames addObject:player.name];
            }
        }
    }
    return messages;
}


- (NSArray *)settleDoctorTagAndSaveDeadPlayerNamesTo:(NSMutableArray *)deadPlayerNames
{
    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:4];
    // If player is misdiagnosed twice, he's killed.
    for (MafiaPlayer *healtPlayer in [self.playerList alivePlayersSelectedBy:[MafiaRole doctor]])
    {
        if ([healtPlayer isSelectedByRole:[MafiaRole killer]])
        {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was shot but healt", nil), healtPlayer]];
            [healtPlayer unselectFromRole:[MafiaRole killer]];
            [healtPlayer unselectFromRole:[MafiaRole doctor]];
        }
        else if (healtPlayer.isMisdiagnosed)
        {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was misdiagnosed twice and killed", nil), healtPlayer]];
            [healtPlayer markDead];
            [deadPlayerNames addObject:healtPlayer.name];
        }
        else
        {
            [messages addObject:[NSString stringWithFormat:NSLocalizedString(@"%@ was misdiagnosed", nil), healtPlayer]];
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

