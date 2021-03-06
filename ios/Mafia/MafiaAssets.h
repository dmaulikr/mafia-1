//
//  Created by ZHENG Zhong on 2015-09-07.
//  Copyright (c) 2015 ZHENG Zhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MafiaRole;


typedef NS_ENUM(NSInteger, MafiaColorStyle) {
    MafiaColorStylePrimary,
    MafiaColorStyleInfo,
    MafiaColorStyleSuccess,
    MafiaColorStyleWarning,
    MafiaColorStyleDanger,
    MafiaColorStyleMuted,
};


typedef NS_ENUM(NSInteger, MafiaAvatar) {
    MafiaAvatarDefault,
    MafiaAvatarWenwen,
    MafiaAvatarXiaohe,
    MafiaAvatarLangni,
    MafiaAvatarDashu,
    MafiaAvatarQingqing,
    MafiaAvatarLaoyao,
    MafiaAvatarZhengdao,
    MafiaAvatarInfo,
};


typedef NS_ENUM(NSInteger, MafiaStatus) {
    MafiaStatusJustGuarded,
    MafiaStatusUnguardable,
    MafiaStatusMisdiagnosed,
    MafiaStatusVoted,
    MafiaStatusDead,
};


typedef NS_ENUM(NSInteger, MafiaIcon) {
    MafiaIconDummy,
};


@interface MafiaAssets : NSObject

+ (UIColor *)colorOfStyle:(MafiaColorStyle)colorStyle;

+ (UIImage *)imageOfAvatar:(MafiaAvatar)avatar;

+ (UIImage *)imageOfRole:(MafiaRole *)role;

+ (UIImage *)smallImageOfRole:(MafiaRole *)role;

+ (UIImage *)imageOfStatus:(MafiaStatus)status;

+ (UIImage *)imageOfSelected;

+ (UIImage *)imageOfUnselected;

+ (UIImage *)imageOfUnselectable;

+ (UIImage *)imageOfTag;

+ (UIImage *)imageOfPositiveAnswer;

+ (UIImage *)imageOfNegativeAnswer;

+ (UIImage *)imageOfIcon:(MafiaIcon)icon;

+ (void)imageView:(UIImageView *)imageView setIcon:(MafiaIcon)icon colorStyle:(MafiaColorStyle)colorStyle;

@end
