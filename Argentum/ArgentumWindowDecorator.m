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
#import "Argentum.h"
#import "ArgentumWindowDecorator.h"

@implementation ArgentumWindowDecorationView

- (id) initWithFrame: (NSRect)frame
	      window: (NSWindow *)w
{
	if (self = [super initWithFrame: frame
				 window: w]) {

		self.hasZoomButton = NO;

		NSUInteger styleMask;
		styleMask = [w styleMask];
  		

		if (styleMask & NSResizableWindowMask)
  		{
			self.hasZoomButton = YES; 
			self.zoomButton = [NSWindow standardWindowButton: NSWindowZoomButton 
                              				    forStyleMask: styleMask];
			[self.zoomButton setTarget: w];
			[self addSubview: self.zoomButton];
		}

		[self updateRects];

	}

	return self;
}

- (void) updateRects
{
  GSTheme *theme = [GSTheme theme];

  if (hasTitleBar)
    {
      CGFloat titleHeight = [theme titlebarHeight];

      titleBarRect = NSMakeRect(0.0, [self bounds].size.height - titleHeight,
	[self bounds].size.width, titleHeight);
    }
  if (hasResizeBar)
    {
      resizeBarRect = NSMakeRect(0.0, 0.0, [self bounds].size.width, [theme resizebarHeight]);
    }
  if (hasCloseButton)
    {
      NSRect closeButtonFrame = [[GSTheme theme] closeButtonFrameForBounds: [self bounds]];
      [closeButton setFrame: closeButtonFrame];
    }
  else
    {
        closeButtonRect = NSZeroRect;
    }

  if (hasMiniaturizeButton)
    {
      NSRect miniaturizeButtonFrame = [[GSTheme theme] miniaturizeButtonFrameForBounds: [self bounds]];
      [miniaturizeButton setFrame: miniaturizeButtonFrame];
    }
  else
    {
        miniaturizeButtonRect = NSZeroRect;
    }

  if (self.hasZoomButton) {
      Argentum *theme = (Argentum *) [GSTheme theme];
      NSRect zoomButtonFrame = [theme zoomButtonFrameForBounds: [self bounds]];
      [self.zoomButton setFrame: zoomButtonFrame];
  }

}

@end

