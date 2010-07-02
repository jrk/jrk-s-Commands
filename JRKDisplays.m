//
//  displays.m
//  jrk's Commands
//
//  Created by Jonathan Ragan-Kelley on 6/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "JRKDisplays.h"
#include <ApplicationServices/ApplicationServices.h>

static NSArray *displays = NULL;

@implementation NSApplication(JRKScripting)

- (NSArray *)orderedDisplays {
    return [JRKGetDisplaysCommand getDisplays];
}

@end

@implementation JRKDisplay
- (id)initWithCGDisplayID:(CGDirectDisplayID)__did
{
    NSLog(@"initWithCGDisplayID %d\n", __did);
    _did = __did;

    _bounds = CGDisplayBounds(_did);
    NSLog(@"Width: %d, Height: %d\n", [self width], [self height]);
    NSLog(@"\nx0: %d, y0: %d\n", [self xPosition], [self yPosition]);
    
    _hasMenuBar = (CGMainDisplayID() == _did);
    NSLog(@"hasMenuBar: %s", _hasMenuBar?"true":"false");
    
    return self;
}

- (void) dealloc {
    NSLog(@"Deallocating %@", self);
    [super dealloc];
}

- (NSString*)name {
    return [NSString stringWithFormat:@"display %x", _did];
}

- (CGRect)bounds {
    return _bounds;
}

- (UInt32)xPosition {
    return [self bounds].origin.x;
}

- (UInt32)yPosition {
    return [self bounds].origin.y;
}

- (UInt32)width {
    return [self bounds].size.width;
}

- (UInt32)height {
    return [self bounds].size.height;
}

- (BOOL)isMainDisplay
{
    return _hasMenuBar;
}

- (unsigned)hash {
    NSData *d = [NSData dataWithBytesNoCopy:&_bounds length:sizeof(_bounds)];
    unsigned h = [d hash];
    h = h ^ [[self name] hash];
    if (_hasMenuBar) h = ~h;
    return h;
}

- (BOOL)isEqual:(id)anObject {
    return ([self hash] == [anObject hash]);
}


//@end

//@implementation JRKDisplay (JRKScriptingExtras)

// These are methods that we probably wouldn't bother with if we weren't scriptable.

- (NSScriptObjectSpecifier *)objectSpecifier {
    NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)[NSScriptClassDescription classDescriptionForClass:[NSApp class]];
    return [[[NSIndexSpecifier alloc] initWithContainerClassDescription:containerClassDesc containerSpecifier:nil key:@"orderedDisplays" index:[displays indexOfObject:self]] autorelease];
}

@end

@implementation JRKGetDisplaysCommand
+ (NSArray *)getDisplays
{
    if (displays) return [displays retain]; // NOTE: _need_ to retain here, or else fuckage happens after first run...
    displays = [[NSArray alloc] init];
    
    static const CGDisplayCount MAX_DISPLAYS = 2;
    CGDirectDisplayID disps[MAX_DISPLAYS];
    CGDisplayCount numDisplays = -1;
    int i;
    
    CGGetActiveDisplayList(MAX_DISPLAYS, disps, &numDisplays);

    for (i = 0; i < numDisplays; i++) {
        NSLog(@"Display %d [of %d]: %d\n", i, numDisplays, disps[i]);
        displays = [displays arrayByAddingObject:[[JRKDisplay alloc] initWithCGDisplayID:disps[i]]];
    }

    NSScriptObjectSpecifier *s = [[displays lastObject] objectSpecifier];
    JRKDisplay *disp = [s objectsByEvaluatingSpecifier];
    NSLog(@"reconsituted width: %d\n", [disp width]);
    
    s = [[displays lastObject] objectSpecifier];
    disp = [s objectsByEvaluatingSpecifier];
    NSLog(@"reconsituted width: %d\n", [disp width]);
    
    /*
    // attempt to dynamically rebuild the array, in case the screen layout is changed...this is risky
    if (!displays || [displays isEqualToArray:curDisplays]) {
        NSLog(@"Mismatched or missing displays object -- recreating.");
        //[displays release];
        displays = curDisplays;
    }
    */
    return displays;
    //id it = [displaysArr lastObject];
    //NSLog(@"Returning 0x%x, with width: %d", it, [it width]);
    //return [it name];
}

- (id)performDefaultImplementation {
    return (id)[[JRKGetDisplaysCommand getDisplays] description];
}

+ (id) alloc {
    NSLog(@"Allocating %@", self);
    return [super alloc];
}

- (void) dealloc {
    NSLog(@"Deallocating %@", self);
    [super dealloc];
}
@end
