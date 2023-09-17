/* 
   ArgentumTheme.m

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

#import "ArgentumTheme.h"

void swizzle(Class class, SEL originalSelector, SEL swizzledSelector) {
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        IMP originalImp = method_getImplementation(originalMethod);
        IMP swizzledImp = method_getImplementation(swizzledMethod);

        class_replaceMethod(class, swizzledSelector, originalImp, method_getTypeEncoding(originalMethod));
        class_replaceMethod(class, originalSelector, swizzledImp, method_getTypeEncoding(swizzledMethod));
}

@implementation ArgentumTheme

- (BOOL) menuShouldShowIcon
{
	return NO; 
}

- (NSColor *) menuBorderColor
{
	return self.menuItemBackgroundColor;
}

- (NSColor *) menuBarBorderColor {
	return NSColor.clearColor;
}

- (NSColor *) menuBorderColorForEdge: (NSRectEdge) edge 
			isHorizontal: (BOOL) horizontal
{
	if (horizontal && edge == NSMinYEdge) {
		return NSColor.clearColor;
    	} else if (edge == NSMinXEdge || edge == NSMaxYEdge) {
      		return NSColor.clearColor;
    	} else {
  		return nil;
	}
}

- (void) drawTitleForMenuItemCell: (NSMenuItemCell *) cell
                        withFrame: (NSRect) cellFrame
                           inView: (NSView *) controlView
                            state: (GSThemeControlState) state
                     isHorizontal: (BOOL) isHorizontal
{

// In the case of an app menu, that is, a menu item in a horizontal menu
// the title of which is equal to the name of the app, the title should
// be drawn bold. We can substitute -[_drawAttributedText:inframe:] for
// -[_drawText:inFrame] to make that work -- but first, we have to detect
// the app menu.

	NSString *menuTitle = cell.menuItem.title;
	NSString *appTitle = [NSBundle.mainBundle.localizedInfoDictionary objectForKey: @"ApplicationName"];

  	NSMutableString *mutableAppTitle = [NSMutableString stringWithCapacity: appTitle.length + 5];

	[mutableAppTitle appendString: appTitle];
	[mutableAppTitle appendString: @"   "];

	NSMutableDictionary *attrs = NSMutableDictionary.dictionary;

	attrs[NSFontAttributeName] = [NSFont boldSystemFontOfSize: 0.0];

	NSAttributedString *boldTitle = [[NSAttributedString alloc] initWithString: mutableAppTitle
									attributes: attrs];

	if (isHorizontal == YES && [menuTitle isEqualToString: mutableAppTitle]) {
		[cell _drawAttributedText: boldTitle
				  inFrame: [cell titleRectForBounds: cellFrame]];

	} else {
		[cell _drawText: [[cell menuItem] title]
		inFrame: [cell titleRectForBounds: cellFrame]];
	}
}

@end
