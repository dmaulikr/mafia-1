//
//  Created by ZHENG Zhong on 2012-12-03.
//  Copyright (c) 2012 ZHENG Zhong. All rights reserved.
//
#import "MafiaHTMLPageController.h"
#import "MafiaHTMLPage.h"


@implementation MafiaHTMLPageController


@synthesize webView = _webView;
@synthesize htmlPage = _htmlPage;


+ (id)controllerWithHTMLPage:(MafiaHTMLPage *)htmlPage
{
    return [[self alloc] initWithHTMLPage:htmlPage];
}




- (id)initWithHTMLPage:(MafiaHTMLPage *)htmlPage
{
    if (self = [super initWithNibName:@"MafiaHTMLPageController" bundle:nil])
    {
        _htmlPage = htmlPage;
        self.title = htmlPage.title;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *resourcePath = [self.htmlPage resourcePath];
    NSData *htmlData = [NSData dataWithContentsOfFile:resourcePath];
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    if (htmlData)
    {
        [self.webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:baseURL];
    }
    self.webView.scalesPageToFit = NO;
}


@end // MafiaHTMLPageController

