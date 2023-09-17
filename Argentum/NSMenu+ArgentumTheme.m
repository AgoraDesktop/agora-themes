/* 
   NSMenu+ArgentumTheme.m

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

#import <AppKit/AppKit.h>
#import <GNUstepGUI/GSTheme.h>
#import "ArgentumTheme.h"

#define APP_MENU_OFFSET_LEFT 35
#define APP_MENU_OFFSET_RIGHT 288

@interface NSMenu (ArgentumTheme)

- (void) AGTSetGeometry;

- (void) AGTSizeToFit;

- (void) AGTOrganizeMenu;

@end

@implementation NSMenu (ArgentumTheme)

// When this method category is loaded, the methods it implements will replace their counterparts
// in the class's default implementation.
+ (void) load {
	static BOOL loaded = NO;
	
	if (loaded == NO) {
		swizzle(self.class, @selector(_setGeometry), @selector(AGTSetGeometry));
		swizzle(self.class, @selector(sizeToFit), @selector(AGTSizeToFit));
		swizzle(self.class, @selector(_organizeMenu), @selector(AGTOrganizeMenu));
		loaded = YES;
	}
}

- (void) AGTSetGeometry {
	NSPoint        origin;

	if (_menu.horizontal == YES) {
		NSRect screenFrame = NSScreen.mainScreen.frame;
		
		// We push the origin of the app menu over to the right, to make room for the system menu.
		origin = NSMakePoint (APP_MENU_OFFSET_LEFT, screenFrame.size.height - _aWindow.frame.size.height + 1);
		origin.y += screenFrame.origin.y;
		[_aWindow setFrameOrigin: origin];
		[_bWindow setFrameOrigin: origin];	
	} else if ((_aWindow != nil) && (_aWindow.screen != nil)) {
		origin = NSMakePoint(0, _aWindow.screen.visibleFrame.size.height - _aWindow.frame.size.height);
		[_aWindow setFrameOrigin: origin];
		[_bWindow setFrameOrigin: origin];
	}
}

- (void) AGTSizeToFit {
	NSRect oldWindowFrame;
	NSRect newWindowFrame;
	NSRect menuFrame;

	[_view sizeToFit];

	menuFrame = _view.frame;

	// Main
	oldWindowFrame = _aWindow.frame;
	newWindowFrame = [NSWindow frameRectForContentRect: menuFrame
					         styleMask: _aWindow.styleMask];

	if (oldWindowFrame.size.height > 1) {
		newWindowFrame.origin = NSMakePoint(oldWindowFrame.origin.x,
						    oldWindowFrame.origin.y + oldWindowFrame.size.height - newWindowFrame.size.height);
	}	

	if (NSApp.mainMenu == self) { 
		// We reduce the width of the app menu to make room on the right for the 
		// global menubar to show through.
		newWindowFrame.size.width -= (APP_MENU_OFFSET_RIGHT + APP_MENU_OFFSET_LEFT);
	}	

	[_aWindow setFrame: newWindowFrame 
		   display: NO];

	// Transient
	oldWindowFrame = _bWindow.frame;
	newWindowFrame = [NSWindow frameRectForContentRect: menuFrame
     						 styleMask: _bWindow.styleMask];
	if (oldWindowFrame.size.height > 1) {
		newWindowFrame.origin = NSMakePoint(oldWindowFrame.origin.x,
						    oldWindowFrame.origin.y + oldWindowFrame.size.height - newWindowFrame.size.height);
	}

	[_bWindow setFrame: newWindowFrame display: NO];

	if (_popUpButtonCell == nil) {
		[_view setFrameOrigin: NSMakePoint(0, 0)];
	}

	[_view setNeedsDisplay: YES];
}

- (void) AGTOrganizeMenu
{
  NSString *infoString = _(@"Info");
  NSString *servicesString = _(@"Services");
  int i;
  if ([NSApp mainMenu] == self)
    {
      NSString *appTitle;
      NSMutableString *mutableAppTitle;
      NSMenu *appMenu;
      id <NSMenuItem> appItem;

      appTitle = [[[NSBundle mainBundle] localizedInfoDictionary]
                     objectForKey: @"ApplicationName"];
      if (nil == appTitle)
        {
          appTitle = [[NSProcessInfo processInfo] processName];
        }
      appItem = [self itemWithTitle: appTitle];
      appMenu = [appItem submenu];
      if (_menu.horizontal == YES)
        {
          NSMutableArray *itemsToMove;

	  mutableAppTitle = [NSMutableString stringWithCapacity: appTitle.length + 5];

	  [mutableAppTitle appendString: appTitle];
	  [mutableAppTitle appendString: @"   "];

          itemsToMove = [NSMutableArray new];
	
	  if (appMenu == nil)
            {
              [self insertItemWithTitle: mutableAppTitle
                    action: NULL
                    keyEquivalent: @"" 
                    atIndex: 0];
              appItem = [self itemAtIndex: 0];
              appMenu = [NSMenu new];
              [self setSubmenu: appMenu forItem: appItem];
              RELEASE(appMenu);
            }
          else
            {
              int index = [self indexOfItem: appItem];
              
              if (index != 0)
                {
                  RETAIN (appItem);
		  appItem.title = mutableAppTitle;
                  [self removeItemAtIndex: index];
                  [self insertItem: appItem atIndex: 0];
                  RELEASE (appItem);
                }
            }
	  // Collect all simple items plus "Info" and "Services"
          for (i = 1; i < [_items count]; i++)
            {
              NSMenuItem *anItem = [_items objectAtIndex: i];
              NSString *title = [anItem title];
              NSMenu *submenu = [anItem submenu];
              if (submenu == nil)
                {
                  [itemsToMove addObject: anItem];
                }
              else
                {
                  // The menu may not be localized, so we have to 
                  // check both the English and the local version.
                  if ([title isEqual: @"Info"] ||
                      [title isEqual: @"Services"] ||
                      [title isEqual: infoString] ||
                      [title isEqual: servicesString])
                    {
                      [itemsToMove addObject: anItem];
                    }
                }
            }
          
          for (i = 0; i < [itemsToMove count]; i++)
            {
              NSMenuItem *anItem = [itemsToMove objectAtIndex: i];
              [self removeItem: anItem];
              [appMenu addItem: anItem];
            }

          RELEASE(itemsToMove);
        }      
      else 
        {
          [appItem setImage: nil];
          if (appMenu != nil)
            {
              NSArray	*array = [NSArray arrayWithArray: [appMenu itemArray]];
              /* 
               * Everything above the Serives menu goes into the info submenu,
               * the rest into the main menu.
               */
              int k = [appMenu indexOfItemWithTitle: servicesString];
              // The menu may not be localized, so we have to 
              // check both the English and the local version.
              if (k == -1)
                k = [appMenu indexOfItemWithTitle: @"Services"];
              if ((k > 0) && ([[array objectAtIndex: k - 1] isSeparatorItem]))
                k--;
              if (k == 1)
                {
                  // Exactly one info item
                  NSMenuItem *anItem = [array objectAtIndex: 0];
                  [appMenu removeItem: anItem];
                  [self insertItem: anItem atIndex: 0];
                }
              else if (k > 1)
                {
                  id <NSMenuItem> infoItem;
                  NSMenu *infoMenu;
                  // Multiple info items, add a submenu for them
                  [self insertItemWithTitle: infoString
                        action: NULL
                        keyEquivalent: @"" 
                        atIndex: 0];
                  infoItem = [self itemAtIndex: 0];
                  infoMenu = [NSMenu new];
                  [self setSubmenu: infoMenu forItem: infoItem];
                  RELEASE(infoMenu);
                  for (i = 0; i < k; i++)
                    {
                      NSMenuItem *anItem = [array objectAtIndex: i];
                  
                      [appMenu removeItem: anItem];
                      [infoMenu addItem: anItem];
                    }
                }
              else
                {
                  // No service menu, or it is the first item.
                  // We still look for an info item.
                  NSMenuItem *anItem = [array objectAtIndex: 0];
                  NSString *title = [anItem title];
                  // The menu may not be localized, so we have to 
                  // check both the English and the local version.
                  if ([title isEqual: @"Info"] ||
                      [title isEqual: infoString])
                    {
                      [appMenu removeItem: anItem];
                      [self insertItem: anItem atIndex: 0];
                      k = 1;
                    }
                  else
                    {
                      k = 0;
                    }
                }
              // Copy the remaining entries.
              for (i = k; i < [array count]; i++)
                {
                  NSMenuItem *anItem = [array objectAtIndex: i];
                  
                  [appMenu removeItem: anItem];
                  [self addItem: anItem];
                }
              [self removeItem: appItem];
            }
        }  
    }
  // recurse over all submenus
  for (i = 0; i < [_items count]; i++)
    {
      NSMenuItem *anItem = [_items objectAtIndex: i];
      NSMenu *submenu = [anItem submenu];
      if (submenu != nil)
        {
          if ([submenu isTransient])
            {
              [submenu closeTransient];
            }
          [submenu close];
          [submenu AGTOrganizeMenu];
        }
    }
  [[self menuRepresentation] update];
  [self sizeToFit];
}

@end
