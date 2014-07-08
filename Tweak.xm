// @interface SBFolderController
// -(void)folderControllerShouldClose:(id)arg1 ;
// -(void)folderViewShouldClose:(id)arg1 ;
// -(id)folder;
// @end

// %hook SBFolderController
// -(void)folderControllerShouldClose:(id)arg1 { 
// 	%log; 
// 	NSLog(@"folder = %@",[self folder]);
// 	%orig; 
// }
// -(void)folderViewShouldClose:(id)arg1 { 
// 	%log;
// 	NSLog(@"folder = %@",[self folder]);
// 	%orig; 
// }
// %end

// @interface SBFolderViewDelegate
// -(void)folderViewShouldClose:(id)arg1;
// @end

// %hook SBFolderViewDelegate
// -(void)folderViewShouldClose:(id)arg1 { %log; %orig; }
// %end


// @interface SBFolderControllerDelegate
// -(void)folderControllerShouldClose:(id)arg1;
// @end

// %hook SBFolderControllerDelegate
// -(void)folderControllerShouldClose:(id)arg1 { %log; %orig; }
// %end

@interface UITouchesEvent : UITouch
@end

@interface SBIconListPageControl
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2 ;
@end

%hook SBIconListPageControl
-(void)touchesEnded:(id)arg1 withEvent:(id)arg2 {
	%log;
	%orig;
}
%end



@interface SBFolderBackgroundView
@end
@interface SBFloatyFolderView : UIView { 
	SBFolderBackgroundView* _backgroundView;
}
-(BOOL)gestureRecognizer:(id)arg1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)arg2 ;
-(BOOL)gestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2 ;
-(BOOL)_tapToCloseGestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2 ;
-(void)_handleOutsideTap:(id)arg1 ;
-(id)hitTest:(CGPoint)arg1 withEvent:(id)arg2 ;
-(id)initWithFolder:(id)arg1 orientation:(int)arg2 ;
@end

static NSLock *sessionlock = [NSLock new];
static BOOL dontDismiss = false;

%hook SBFloatyFolderView
// -(id)initWithFolder:(id)arg1 orientation:(int)arg2 {
// 	%log;
// 	self = %orig;

// 	return self;
// }


-(BOOL)gestureRecognizer:(id)arg1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)arg2 {
	%log;
	return %orig;
}
-(BOOL)gestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2 {
	%log;
	return %orig;
}
-(BOOL)_tapToCloseGestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2 {
	%log;
	return %orig;
}
-(void)_handleOutsideTap:(id)arg1 {
	%log;
	%orig;
}

%new
- (void)handleUITap:(UITapGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded) {
		[sessionlock lock];
		if(!dontDismiss) {
			[self _handleOutsideTap:sender];
		}
		[sessionlock unlock];
	}
}

-(id)hitTest:(CGPoint)arg1 withEvent:(UITouchesEvent *)arg2 {
	%log;
	[sessionlock lock];
	dontDismiss = false;
	[sessionlock unlock];
	UITapGestureRecognizer *bioTap = [[%c(UITapGestureRecognizer) alloc] initWithTarget:self action:@selector(handleUITap:)];
	//bioTap.delegate = self;
	bioTap.cancelsTouchesInView = NO;
	bioTap.numberOfTapsRequired = 1; 
	[self addGestureRecognizer:bioTap];
	[bioTap release];
	return %orig;
}
%end

%hook SBAppToAppWorkspaceTransaction
-(id)_setupAnimationFrom:(id)afrom to:(id)ato {
	%log;
	dontDismiss = true;
	return %orig;
}
%end

%hook SBIconView
-(BOOL)isTouchDownInIcon {
	%log;
	dontDismiss = true;
	return %orig;
}
-(BOOL)pointMostlyInside:(CGPoint)arg1 withEvent:(id)arg2 {
	%log;
	dontDismiss = true;
	return %orig;
}
-(BOOL)pointInside:(CGPoint)arg1 withEvent:(id)arg2 {
	%log;
	[sessionlock lock];
	dontDismiss = true;
	[sessionlock unlock];
	return %orig;
}
-(void)gestureEnded:(id)arg1  {
	%log;
	dontDismiss = true;
	return %orig;
}
%end

%hook SBIcon
-(void)launchFromLocation:(int)arg1 {
	%log;
	dontDismiss = true;
	%orig;
}
%end

%hook SBIconViewDelegate
-(void)iconTapped:(id)tapped {
	%log;
	dontDismiss = true;
	%orig;
}
%end

%hook SBIconDelegate
-(void)iconTapped:(id)tapped {
	%log;
	dontDismiss = true;
	%orig;
}
%end










@interface SBFolderSettings
-(BOOL)allowNestedFolders;
-(BOOL)pinchToClose;
@end
%hook SBFolderSettings
-(BOOL)allowNestedFolders { return YES; }
-(BOOL)pinchToClose { return YES; }
%end

// -(int)numberOfSectionsInTableView:(UITableView *)arg1 {
// 	if(!added) {
// 		UITapGestureRecognizer *bioTap = [[%c(UITapGestureRecognizer) alloc] initWithTarget:self action:@selector(handleUITap:)];
// 		bioTap.delegate = self;
// 		bioTap.cancelsTouchesInView = NO;
// 		bioTap.numberOfTapsRequired = 1; 
// 		[arg1 addGestureRecognizer:bioTap];
// 		[bioTap release];
// 		added = YES;
// 	}
	
// 	return %orig;
// }

// %new 
// - (void)handleUITap:(UITapGestureRecognizer *)sender {
// 	if (sender.state == UIGestureRecognizerStateEnded) [self dismiss];
// }