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

#import "Argentum.h"
#import "ArgentumWindowDecorator.h"


#define APP_MENU_ORIGIN_X_OFFSET 43
#define APP_MENU_WIDTH_OFFSET 288


__attribute__((used))
static void swizzle(Class class, SEL originalSelector, SEL swizzledSelector) {
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        IMP originalImp = method_getImplementation(originalMethod);
        IMP swizzledImp = method_getImplementation(swizzledMethod);

        class_replaceMethod(class, swizzledSelector, originalImp, method_getTypeEncoding(originalMethod));
        class_replaceMethod(class, originalSelector, swizzledImp, method_getTypeEncoding(swizzledMethod));
}

@implementation Argentum

- (id<GSWindowDecorator>) windowDecorator {
	return ArgentumWindowDecorationView.self;
}

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

- (NSRect) modifyRect: (NSRect)aRect
	   forMenu: (NSMenu *)aMenu
	   isHorizontal: (BOOL) horizontal {
	if (horizontal) {
		aRect.origin.x += APP_MENU_ORIGIN_X_OFFSET;
		aRect.size.width -= (APP_MENU_WIDTH_OFFSET + APP_MENU_ORIGIN_X_OFFSET);
	}

	return aRect;
}

- (CGFloat) proposedTitleWidth: (CGFloat)proposedWidth
		   forMenuView: (NSMenuView *)aMenuView {
	return proposedWidth + 4;
}


- (NSString *) keyForKeyEquivalent: (NSString *)aString
{
	return aString.uppercaseString;
}

- (void) drawTitleForMenuItemCell: (NSMenuItemCell *)cell
                        withFrame: (NSRect)cellFrame
                           inView: (NSView *)controlView
                            state: (GSThemeControlState)state
                     isHorizontal: (BOOL)isHorizontal
{

// In the case of an app menu, that is, a menu item in a horizontal menu
// the title of which is equal to the name of the app, the title should
// be drawn bold. We can substitute -[_drawAttributedText:inframe:] for
// -[_drawText:inFrame] to make that work -- but first, we have to detect
// the app menu.

	NSString *menuTitle = cell.menuItem.title;
	NSString *appTitle = [NSBundle.mainBundle.localizedInfoDictionary objectForKey: @"ApplicationName"];
	NSString *paddedAppTitle = [appTitle stringByAppendingString: @"   "];

	NSMutableDictionary *attrs = NSMutableDictionary.dictionary;

	attrs[NSFontAttributeName] = [NSFont boldSystemFontOfSize: 0.0];

	NSAttributedString *boldTitle = [[NSAttributedString alloc] initWithString: paddedAppTitle
									attributes: attrs];

	if (isHorizontal == YES && [menuTitle isEqualToString: paddedAppTitle]) {
		NSRect frame = [cell titleRectForBounds: cellFrame];
		frame.size.width += 10;
		[cell _drawAttributedText: boldTitle
				  inFrame: frame];

	} else {
		[cell _drawText: [[cell menuItem] title]
		inFrame: [cell titleRectForBounds: cellFrame]];
	}
}

- (NSString *) proposedTitle: (NSString *)title
		 forMenuItem: (NSMenuItem *)menuItem
{
 	NSString *appTitle = [NSBundle.mainBundle.localizedInfoDictionary objectForKey: @"ApplicationName"];
	//NSString *padding = @" ";

	if ([title isEqualToString: appTitle]) {
		return [title stringByAppendingString: @"   "];
	} else {
		return title;
		//return [[padding stringByAppendingString: title] stringByAppendingString: padding];
	}
}

- (NSButton *) standardWindowButton: (NSWindowButton)button
		       forStyleMask: (NSUInteger) mask
{
	NSButton *result = [super standardWindowButton: button
					  forStyleMask: mask];

	if (result != nil) {
		result.bordered = NO;
	}

	return result;
}

- (void) setFrameForCloseButton: (NSButton *)closeButton
		       viewSize: (NSSize)viewSize
{
  NSSize buttonSize = [[closeButton image] size];
  buttonSize = NSMakeSize(buttonSize.width + 3, buttonSize.height + 3);
  
  [closeButton setFrame: NSMakeRect(4,
                   		   (viewSize.height - buttonSize.height) / 2,
  		                    buttonSize.width, 
				    buttonSize.height)];
}

- (NSRect) closeButtonFrameForBounds: (NSRect)bounds
{
  GSTheme *theme = [GSTheme theme];

  return NSMakeRect([theme titlebarPaddingLeft], 
		     bounds.size.height - [theme titlebarButtonSize] - [theme titlebarPaddingTop], 
		    [theme titlebarButtonSize], 
		    [theme titlebarButtonSize]);
}

- (NSRect) miniaturizeButtonFrameForBounds: (NSRect)bounds
{
  GSTheme *theme = [GSTheme theme];

  return NSMakeRect([theme titlebarButtonSize] + [theme titlebarPaddingLeft] + 1, 
		     bounds.size.height - [theme titlebarButtonSize] - [theme titlebarPaddingTop], 
		    [theme titlebarButtonSize], 
		    [theme titlebarButtonSize]);
}
@end
