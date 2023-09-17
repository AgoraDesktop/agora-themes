/* 
   NSMenuItemCell+ArgentumTheme.m

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

@interface NSMenuItemCell (ArgentumTheme)

- (NSString*) AGTKeyEquivalentString; 

@end


@implementation NSMenuItemCell (ArgentumTheme)

+ (void) load {
	static BOOL loaded = NO;

	if (loaded == NO) {
		swizzle(self.class, @selector(_keyEquivalentString), @selector(AGTKeyEquivalentString));
	}
}

- (NSString*) AGTKeyEquivalentString {
	NSString *key = _menuItem.keyEquivalent;
	unsigned int modMask = _menuItem.keyEquivalentModifierMask;
  	unichar uchar;
  
	if ((key == nil) || [key isEqualToString: @""]) {
    		return key;
	}
  
	uchar = [key characterAtIndex: 0];
	
	if (uchar >= 0xF700) {
		// FIXME: At the moment we are not able to handle function keys
      		// as key equivalent
      		return nil;
    	}

	if (modMask != 0) {
		NSString *controlKeyString = @"^";
		NSString *alternateKeyString = @"⌥";
		NSString *shiftKeyString = @"⇧";
		NSString *commandKeyString = @"⌘";

		key = [NSString stringWithFormat:@"%@%@%@%@%@",
					(modMask & NSControlKeyMask) ? controlKeyString : @"",
					(modMask & NSAlternateKeyMask) ? alternateKeyString : @"",
					(modMask & NSShiftKeyMask) ? shiftKeyString : @"",
					(modMask & NSCommandKeyMask) ? commandKeyString : @"",
					key.uppercaseString];
 	} else {
		key = key.uppercaseString;
	}

	return key;
}

@end
