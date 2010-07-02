//
//  displays.h
//  jrk's Commands
//
//  Created by Jonathan Ragan-Kelley on 6/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSScriptCommand.h>

@interface NSApplication(JRKScripting)

- (NSArray *)orderedDisplays;

@end

@interface JRKDisplay : NSObject {
    @private
    CGDirectDisplayID _did;
    CGRect _bounds;
    BOOL _hasMenuBar;
}

- (id)initWithCGDisplayID:(CGDirectDisplayID)did;
- (void) dealloc;

- (NSString*)name;
- (CGRect)bounds;
- (UInt32)xPosition;
- (UInt32)yPosition;
- (UInt32)width;
- (UInt32)height;
- (BOOL)isMainDisplay;
- (unsigned)hash;
- (BOOL)isEqual:(id)anObject;
        
@end

@interface JRKGetDisplaysCommand : NSScriptCommand {
}

+ (NSArray *)getDisplays;
+ (id) alloc;
- (void) dealloc;
- (id)performDefaultImplementation;

@end
