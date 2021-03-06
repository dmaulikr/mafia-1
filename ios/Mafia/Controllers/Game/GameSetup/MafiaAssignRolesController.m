//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//

#import "MafiaAssignRolesController.h"
#import "MafiaAutonomicGameController.h"
#import "MafiaJudgeDrivenGameController.h"
#import "MafiaAutonomicGameController.h"

#import "MafiaAssets.h"
#import "MafiaGameplay.h"
#import "UINavigationItem+MafiaBackTitle.h"
#import "UIView+MafiaAdditions.h"


static NSString *const kSegueStartJudgeDrivenGame = @"StartJudgeDrivenGame";

static NSString *const kTwoPlayersCellID = @"TwoPlayersCell";


@implementation MafiaTwoPlayersCell


- (void)setupWithPlayer:(MafiaPlayer *)player1 andPlayer:(MafiaPlayer *)player2 {
    self.player1 = player1;
    self.player2 = player2;
    self.isPlayer1Revealed = NO;
    self.isPlayer2Revealed = NO;
    [self mafia_refreshUI];
}


- (IBAction)player1ButtonTapped:(id)sender {
    self.isPlayer1Revealed = !self.isPlayer1Revealed;
    [self mafia_refreshUI];
}


- (IBAction)player2ButtonTapped:(id)sender {
    self.isPlayer2Revealed = !self.isPlayer2Revealed;
    [self mafia_refreshUI];
}


- (void)mafia_refreshUI {
    [self mafia_refreshButton:self.player1Button
                    imageView:self.player1ImageView
                        label:self.player1Label
                    forPlayer:self.player1
                     revealed:self.isPlayer1Revealed];
    [self mafia_refreshButton:self.player2Button
                    imageView:self.player2ImageView
                        label:self.player2Label
                    forPlayer:self.player2
                     revealed:self.isPlayer2Revealed];
}


- (void)mafia_refreshButton:(UIButton *)button
                  imageView:(UIImageView *)imageView
                      label:(UILabel *)label
                  forPlayer:(MafiaPlayer *)player
                   revealed:(BOOL)isRevealed {
    if (player != nil) {
        button.enabled = YES;
        button.hidden = NO;
        [button mafia_makeRoundCornersWithBorder:YES];
        imageView.hidden = NO;
        label.hidden = NO;
        if (isRevealed) {
            imageView.image = [MafiaAssets imageOfRole:player.role];
            label.text = player.role.displayName;
        } else {
            imageView.image = (player.avatarImage != nil ? player.avatarImage : [MafiaAssets imageOfAvatar:MafiaAvatarDefault]);
            label.text = player.displayName;
        }
        [imageView mafia_makeRoundCornersWithBorder:NO];
    } else {
        button.enabled = NO;
        button.hidden = YES;
        imageView.hidden = YES;
        label.hidden = YES;
    }
}


@end


@implementation MafiaAssignRolesController


#pragma mark - Public Methods


- (void)assignRolesRandomlyWithGameSetup:(MafiaGameSetup *)gameSetup {
    self.game = [[MafiaGame alloc] initWithGameSetup:gameSetup];
    [self.game assignRolesRandomly];
}


#pragma mark - Lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem mafia_clearBackTitle];
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // For N players, we need to have ceil(N / 2) cells, each cell holds 2 players.
    // Best way to calculate that: http://stackoverflow.com/questions/4926440/
    return ([self.game.playerList count] + 1) / 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MafiaTwoPlayersCell *cell = [tableView dequeueReusableCellWithIdentifier:kTwoPlayersCellID forIndexPath:indexPath];
    NSUInteger playerIndex = indexPath.row * 2;
    MafiaPlayer *player1 = nil;
    if (playerIndex < [self.game.playerList count]) {
        player1 = [self.game.playerList playerAtIndex:playerIndex];
    }
    MafiaPlayer *player2 = nil;
    if (playerIndex + 1 < [self.game.playerList count]) {
        player2 = [self.game.playerList playerAtIndex:(playerIndex + 1)];
    }
    [cell setupWithPlayer:player1 andPlayer:player2];
    return cell;
}


#pragma mark - Actions


- (IBAction)startButtonTapped:(id)sender {
    if ([self.game isReadyToStart]) {
        if (!self.game.gameSetup.isAutonomic) {
            // Judge-driven game.
            MafiaJudgeDrivenGameController *controller = [MafiaJudgeDrivenGameController controller];
            [controller startGame:self.game];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            // Autonomic game.
            MafiaAutonomicGameController *controller = [MafiaAutonomicGameController controller];
            [controller startGame:self.game];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}


@end
