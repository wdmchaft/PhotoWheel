//
//  MainViewController.h
//  PhotoWheel
//
//  Created by Kirby Turner on 4/22/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoWheelView;

@interface MainViewController : UIViewController
{
    
}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet PhotoWheelView *photoWheelView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
