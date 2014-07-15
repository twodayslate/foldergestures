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
@interface SBFloatyFolderView : UIView
@property (nonatomic,retain) SBFolder * folder;  
-(void)_handleOutsideTap:(id)arg1 ;
@end

@interface SBIconView
-(id)icon;
@end

static SBIconView *icon = nil;

%hook SBFloatyFolderView
%new
- (void)tapToClose:(UITapGestureRecognizer *)sender {
	// %log;
	// NSLog(@"%@",[icon icon]);
	// NSLog(@"%@",[[self folder] icon]);
	// NSLog(@"comparison = %d",[icon icon] == [[self folder] icon]);
	// NSLog(@"isFolder = %d",[[[self folder] icon]isFolderIcon]);
	// NSLog(@"senderView = %@",sender.view);
	if (sender.state == UIGestureRecognizerStateEnded) {
		if(icon == nil || [[self folder] icon] == [icon icon]) {
				[self _handleOutsideTap:sender];
				icon = nil;
		}
	}
}

-(void)prepareToOpen {
	UITapGestureRecognizer *bioTap = [[%c(UITapGestureRecognizer) alloc] initWithTarget:self action:@selector(tapToClose:)];
	//bioTap.delegate = self;
	bioTap.cancelsTouchesInView = NO;
	bioTap.numberOfTapsRequired = 1; 
	[self addGestureRecognizer:bioTap];
	[bioTap release];
	icon = nil;
	%orig;
}

-(void)cleanupAfterClosing {
	%orig;
	icon = nil;
}

-(void)_setCurrentPageIndex:(int)arg1 { 
	//%log; 
	//NSLog(@"icon removed");
	icon = nil; 
	%orig; 
}
-(void)scrollViewDidScroll:(id)arg1 { 
	//%log; 
	//NSLog(@"icon removed");
	icon = nil; 
	%orig; 
}
%end

%hook SBIconView
-(void)touchesBegan:(id)arg1 withEvent:(id)arg2 {
	//%log;
	icon = self; 
	//NSLog(@"icon changed");
	%orig;
}
// -(void)touchesEnded:(id)arg1 withEvent:(id)arg2 {
// 	%log;
// 	icon = nil; 
// 	%orig;
// }

%end

%hook SBAppToAppWorkspaceTransaction
-(id)_setupAnimationFrom:(id)afrom to:(id)ato {
	%log;
	icon = nil;
	return %orig;
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