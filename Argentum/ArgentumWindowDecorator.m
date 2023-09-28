/* 
   ArgentumWindowDecorator.m

   Copyright (C) 2023 Kyle J Cardoza

   Author: Kyle J Cardoza <Kyle.Cardoza@icloud.com>
   Date: September 2024
   
   This file is part of the Argentum theme for Agora Desktop.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/ 

#import <AppKit/NSImage.h>
#import <AppKit/NSImageView.h>
#import <GNUstepGUI/GSWindowDecorationView.h>
#import "Argentum.h"
#import "ArgentumWindowDecorator.h"

@interface GSStandardWindowDecorationView (Private)

- (void) updateRects;

- (void) resetWindowButtons;

- (void) close: (ArgentumWindowDecorationView *) sender;

- (void) miniaturize: (ArgentumWindowDecorationView *) sender;

- (void) zoom: (ArgentumWindowDecorationView *) sender;

@end

@implementation ArgentumWindowDecorationView

- (id) initWithFrame: (NSRect) frame
	      window: (NSWindow *) win
{
	self = [super initWithFrame: frame window: win]; 

	if (self == nil) {
		return nil;
	}

	if (closeButton == nil) {
		closeButton = [NSWindow standardWindowButton: NSWindowCloseButton 
						forStyleMask: win.styleMask];
	}

	if (win.styleMask & NSClosableWindowMask) {
		hasCloseButton = YES;

		closeButton.image = [NSImage imageNamed: @"common_Close"];
		closeButton.alternateImage = [NSImage imageNamed: @"common_CloseH"];

		closeButton.target = self;
		closeButton.action = @selector(close:);
	} else {
		closeButton.image = [NSImage imageNamed: @"common_DisabledWindowButton"];
		closeButton.alternateImage = [NSImage imageNamed: @"common_DisabledWindowButton"];
		closeButton.action = NULL;
	}
	
	[self addSubview: closeButton];

	if (miniaturizeButton == nil) {
		miniaturizeButton = [NSWindow standardWindowButton: NSWindowMiniaturizeButton 
						      forStyleMask: win.styleMask];
	}

	if (win.styleMask & NSMiniaturizableWindowMask) {
		hasMiniaturizeButton = YES;

		miniaturizeButton.image = [NSImage imageNamed: @"common_Miniaturize"];
		miniaturizeButton.alternateImage = [NSImage imageNamed: @"common_MiniaturizeH"];

		miniaturizeButton.target = self;
		miniaturizeButton.action = @selector(miniaturize:);
	} else {
		miniaturizeButton.image = [NSImage imageNamed: @"common_DisabledWindowButton"];
		miniaturizeButton.image = [NSImage imageNamed: @"common_DisabledWindowButton"];
	}
	
	[self addSubview: miniaturizeButton];

	if (self.zoomButton == nil) {
		self.zoomButton = [NSWindow standardWindowButton: NSWindowZoomButton 
					            forStyleMask: win.styleMask];
	}

	if (win.styleMask & NSResizableWindowMask) {
		hasResizeBar = YES;
		self.hasZoomButton = YES;
		
		self.zoomButton.image = [NSImage imageNamed: @"common_Zoom"];
		self.zoomButton.alternateImage = [NSImage imageNamed: @"common_ZoomH"];

		self.zoomButton.target = self;
		self.zoomButton.action = @selector(zoom:);
	} else {
		self.zoomButton.image = [NSImage imageNamed: @"common_DisabledWindowButton"];
		self.zoomButton.image = [NSImage imageNamed: @"common_DisabledWindowButton"];
	}

	[self addSubview: self.zoomButton];

	[self updateRects];

	return self;
}

- (void) updateRects
{
	Argentum *theme = (Argentum *) GSTheme.theme;

	[super updateRects];

	if (self.hasZoomButton) {
		self.zoomButton.frame = [theme zoomButtonFrameForBounds: self.bounds];
	}
}

- (void) viewWillMoveToWindow: (NSWindow *) newWindow {
	[self clearTrackingRects];
}

- (void)resetCursorRects {
	[super resetCursorRects];
	[self clearTrackingRects];
	[self setTrackingRects];
}

- (void) clearTrackingRects {
	if ( [self window] && self.stoplightTrackingRect ) {
		[self removeTrackingRect: self.stoplightTrackingRect];
	}
}

- (void) setTrackingRects {
	NSRect stoplightRect = NSMakeRect(closeButton.frame.origin.x - 4,
				          closeButton.frame.origin.y -4,
					  self.zoomButton.frame.origin.x + self.zoomButton.frame.size.width + 4,
					  self.zoomButton.frame.origin.y + self.zoomButton.frame.size.height + 4);
	self.stoplightTrackingRect = [self addTrackingRect: stoplightRect
             					     owner: self
                        			  userData: nil 
                    			      assumeInside: NO];
}

- (void) viewDidMoveToWindow {
	[self setTrackingRects];
}

- (void) mouseEntered: (NSEvent *) theEvent
{
	self.mouseInView = YES;
	self.windowWasAcceptingMouseEvents = self.window.acceptsMouseMovedEvents;
	self.window.acceptsMouseMovedEvents = YES;

	[self highlightWindowButtons];

	[self displayIfNeeded];
}

- (void) mouseExited: (NSEvent *) theEvent {
	[self resetWindowButtons];

	self.mouseInView = NO;
   	self.window.acceptsMouseMovedEvents = self.windowWasAcceptingMouseEvents;
	[self setNeedsDisplay:YES];
}

- (void) resetWindowButtons {
	closeButton.image = [NSImage imageNamed: @"common_Close"];
	miniaturizeButton.image = [NSImage imageNamed: @"common_Miniaturize"];
	self.zoomButton.image = [NSImage imageNamed: @"common_Zoom"];
}

- (void) highlightWindowButtons {
	closeButton.image = [NSImage imageNamed: @"common_CloseH"];
	miniaturizeButton.image = [NSImage imageNamed: @"common_MiniaturizeH"];
	self.zoomButton.image = [NSImage imageNamed: @"common_ZoomH"];
}

- (void) close: (ArgentumWindowDecorationView *) sender {
	[window performClose: self];
	
	[self resetWindowButtons];
	
	self.needsDisplay = YES;
	
	[self displayIfNeeded];
}

- (void) miniaturize: (ArgentumWindowDecorationView *) sender {
	[window performMiniaturize: self];
	
	[self resetWindowButtons];
	
	self.needsDisplay = YES;
	
	[self displayIfNeeded];

}

- (void) zoom: (ArgentumWindowDecorationView *) sender {
	[window performZoom: self];
	
	[self resetWindowButtons];
	
	self.needsDisplay = YES;
	
	[self displayIfNeeded];
}

@end
