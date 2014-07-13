@interface SBIcon
-(BOOL)isFolderIcon;
@end
@interface SBFolderIcon : SBIcon
@end

@interface SBFolder
@property (assign,nonatomic) SBFolderIcon * icon;  
@end

@interface SBFolderBackgroundView
@end
@interface SBFloatyFolderView : UIView { 
	SBFolderBackgroundView* _backgroundView;
}
@property (nonatomic,retain) SBFolder * folder;  
-(BOOL)gestureRecognizer:(id)arg1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)arg2 ;
-(BOOL)gestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2 ;
-(BOOL)_tapToCloseGestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2 ;
-(void)_handleOutsideTap:(id)arg1 ;
-(id)hitTest:(CGPoint)arg1 withEvent:(id)arg2 ;
-(id)initWithFolder:(id)arg1 orientation:(int)arg2 ;
@end

@interface SBIconView
-(id)icon;
@end


static NSLock *sessionlock = [NSLock new];
static BOOL dontDismiss = false;

static SBIconView *icon = nil;

%hook SBFloatyFolderView
%new
- (void)handleTap:(UITapGestureRecognizer *)sender {
	%log;
	NSLog(@"%@ vs %@",icon,self);
	if (sender.state == UIGestureRecognizerStateEnded) {
		if((SBIconView *)self != icon) {
			[self _handleOutsideTap:sender];
		}
	}
}

-(void)prepareToOpen {
	[sessionlock lock];
	dontDismiss = false;
	[sessionlock unlock];
	UITapGestureRecognizer *bioTap = [[%c(UITapGestureRecognizer) alloc] initWithTarget:self action:@selector(handleTap:)];
	//bioTap.delegate = self;
	bioTap.cancelsTouchesInView = NO;
	bioTap.numberOfTapsRequired = 1; 
	[self addGestureRecognizer:bioTap];
	[bioTap release];
	%orig;
}

-(void)cleanupAfterClosing {
	%orig;
	dontDismiss = false;
}
%end

%hook SBIconView
-(void)touchesBegan:(id)arg1 withEvent:(id)arg2 {
	// EWW
	NSLog(@"icon = %@",[self icon]);
	if(![[self icon] isFolderIcon]) {
		NSLog(@"is NOT a folder");
	} else NSLog(@"is a folder");
	icon = self; 
	%orig;
}
// -(void)touchesEnded:(id)arg1 withEvent:(id)arg2 {
// 	// EWW
// 	NSLog(@"icon = %@",[self icon]);
// 	if(![[self icon] isFolderIcon]) {
// 		NSLog(@"is NOT a folder");
// 		[sessionlock lock];
// 		dontDismiss = true;
// 		[sessionlock unlock];
// 	} else NSLog(@"is a folder");
// 	icon = self;
// 	%orig;
// }
%end

// %hook SBAppToAppWorkspaceTransaction
// -(id)_setupAnimationFrom:(id)afrom to:(id)ato {
// 	dontDismiss = false;
// 	return %orig;
// }
// %end






@interface SBFolderSettings
-(BOOL)allowNestedFolders;
-(BOOL)pinchToClose;
@end
%hook SBFolderSettings
-(BOOL)allowNestedFolders { return YES; }
-(BOOL)pinchToClose { return YES; }
%end