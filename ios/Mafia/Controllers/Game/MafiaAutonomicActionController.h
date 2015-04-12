//
//  Created by ZHENG Zhong on 2015-04-11.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaAction;
@class MafiaGame;
@class MafiaInformation;
@class MafiaNumberRange;
@class MafiaPlayer;
@class MafiaRole;


// ------------------------------------------------------------------------------------------------
// Custom Cells
// ------------------------------------------------------------------------------------------------


@interface MafiaAutonomicActionHeaderCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *actorImageView;
@property (strong, nonatomic) IBOutlet UILabel *actionNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *actionRoleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *actionRoleImageView;
@property (strong, nonatomic) IBOutlet UILabel *actionPromptLabel;

- (void)setupWithAction:(MafiaAction *)action;

@end  // MafiaAutonomicActionHeaderCell


@interface MafiaTargetPlayerCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;

- (void)setupWithTargetPlayer:(MafiaPlayer *)player
                       ofRole:(MafiaRole *)role
                   selectable:(BOOL)selectable
                     selected:(BOOL)selected;

@end  // MafiaTargetPlayerCell


// ------------------------------------------------------------------------------------------------
// MafiaAutonomicActionController
// ------------------------------------------------------------------------------------------------


@protocol MafiaAuthnomicActionControllerDelegate <NSObject>

- (void)autonomicActionControllerDidCompleteAction:(UIViewController *)controller;

@end


@interface MafiaAutonomicActionController : UITableViewController

@property (strong, nonatomic) MafiaGame *game;
@property (strong, nonatomic) NSMutableArray *selectedPlayers;
@property (assign, nonatomic) BOOL isActionCompleted;

@property (weak, nonatomic) id<MafiaAuthnomicActionControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *okBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

- (void)setupWithGame:(MafiaGame *)game;

- (IBAction)okButtonTapped:(id)sender;

- (IBAction)doneButtonTapped:(id)sender;

@end  // MafiaAutonomicActionController
