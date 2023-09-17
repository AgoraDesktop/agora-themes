/* 
   NSMenuView+ArgentumTheme.m

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
#import <GNUstepGUI/GSTitleView.h>
#import "ArgentumTheme.h"


typedef struct _GSCellRect {
  NSRect rect;
} GSCellRect;

#define GSI_ARRAY_TYPES         0
#define GSI_ARRAY_TYPE          GSCellRect

#define GSI_ARRAY_NO_RETAIN
#define GSI_ARRAY_NO_RELEASE

#ifdef GSIArray
#undef GSIArray
#endif
#include <GNUstepBase/GSIArray.h>

static NSMapTable *viewInfo = 0;

#define cellRects ((GSIArray)NSMapGet(viewInfo, self))

#define HORIZONTAL_MENU_RIGHT_PADDING 4
#define HORIZONTAL_MENU_LEFT_PADDING 4

@interface NSMenuView (ArgentumTheme)

- (void) AGTSizeToFit;

@end

@implementation NSMenuView (ArgentumTheme)

+ (void) load {
	static BOOL loaded = NO;

	if (loaded == NO) {
		swizzle(self.class, @selector(sizeToFit), @selector(AGTSizeToFit));
	}

}

- (CGFloat) heightForItem: (NSInteger) idx
{
  NSMenuItemCell *cell = [self menuItemCellForItemAtIndex: idx];

  if (cell != nil)
    {
      NSMenuItem *item = [cell menuItem];
      
      if ([item isSeparatorItem])
	{
	  return [[GSTheme theme] menuSeparatorHeight];
	}
    }
  return _cellSize.height;
}

- (CGFloat) totalHeight
{
  CGFloat total = 0;
  NSUInteger i = 0;

  for (i = 0; i < [_itemCells count]; i++)
    {
      total += [self heightForItem: i];
    }
  return total;
}

- (void) AGTSizeToFit
{
  BOOL isPullDown =
    [_attachedMenu _ownedByPopUp] && [[_attachedMenu _owningPopUp] pullsDown];
  if (_horizontal == YES)
    {
      unsigned i;
      unsigned howMany = [_itemCells count];
      float currentX = HORIZONTAL_MENU_LEFT_PADDING;
//      NSRect scRect = [[NSScreen mainScreen] frame];
      GSIArrayRemoveAllItems(cellRects);
/*
      scRect.size.height = [NSMenuView menuBarHeight];
      [self setFrameSize: scRect.size];
      _cellSize.height = scRect.size.height;
*/
      _cellSize.height = [NSMenuView menuBarHeight];
      if (howMany && isPullDown)
        {
          GSCellRect elem;
          elem.rect = NSMakeRect (currentX,
                                  0,
                                  (2 * _horizontalEdgePad),
                                  [self heightForItem: 0]);
          GSIArrayAddItem(cellRects, (GSIArrayItem)elem);
          currentX += 2 * _horizontalEdgePad;
        }
      for (i = isPullDown ? 1 : 0; i < howMany; i++)
        {
          GSCellRect elem;
          NSMenuItemCell *aCell = [self menuItemCellForItemAtIndex: i];
          float titleWidth = [aCell titleWidth] + 4;

          if ([aCell imageWidth])
            {
              titleWidth += [aCell imageWidth] + GSCellTextImageXDist;
            }
          elem.rect = NSMakeRect (currentX,
                                  0,
                                  (titleWidth + (2 * _horizontalEdgePad)),
                                  [self heightForItem: i]);
          GSIArrayAddItem(cellRects, (GSIArrayItem)elem);
          currentX += titleWidth + (2 * _horizontalEdgePad);
        }
    }
  else
    {
      unsigned i;
      unsigned howMany = [_itemCells count];
      unsigned wideTitleView = 1;
      float    neededImageAndTitleWidth = 0.0;
      float    neededKeyEquivalentWidth = 0.0;
      float    neededStateImageWidth = 0.0;
      float    accumulatedOffset = 0.0;
      float    popupImageWidth = 0.0;
      float    menuBarHeight = 0.0;
      if (_titleView)
        {
          NSMenu *m = [_attachedMenu supermenu];
          NSMenuView *r = [m menuRepresentation];
          neededImageAndTitleWidth = [_titleView titleSize].width;
          if (r != nil && [r isHorizontal] == YES)
            {
              NSMenuItemCell *msr;
              msr = [r menuItemCellForItemAtIndex:
                [m indexOfItemWithTitle: [_attachedMenu title]]];
              neededImageAndTitleWidth
                = [msr titleWidth] + GSCellTextImageXDist;
            }
          if (_titleView)
            menuBarHeight = [[self class] menuBarHeight];
          else
            menuBarHeight += _leftBorderOffset;
        }
      else
        {
          menuBarHeight += _leftBorderOffset;
        }
      for (i = isPullDown ? 1 : 0; i < howMany; i++)
        {
          float aStateImageWidth;
          float aTitleWidth;
          float anImageWidth;
          float anImageAndTitleWidth;
          float aKeyEquivalentWidth;
          NSMenuItemCell *aCell = [self menuItemCellForItemAtIndex: i];
          
          // State image area.
          aStateImageWidth = [aCell stateImageWidth];
          
          // Title and Image area.
          aTitleWidth = [aCell titleWidth];
          anImageWidth = [aCell imageWidth];
          
          // Key equivalent area.
          aKeyEquivalentWidth = [aCell keyEquivalentWidth];
          
          switch ([aCell imagePosition])
            {
              case NSNoImage: 
                anImageAndTitleWidth = aTitleWidth;
                break;
                
              case NSImageOnly: 
                anImageAndTitleWidth = anImageWidth;
                break;
                
              case NSImageLeft: 
              case NSImageRight: 
                anImageAndTitleWidth
                  = anImageWidth + aTitleWidth + GSCellTextImageXDist;
                break;
                
              case NSImageBelow: 
              case NSImageAbove: 
              case NSImageOverlaps: 
              default: 
                if (aTitleWidth > anImageWidth)
                  anImageAndTitleWidth = aTitleWidth;
                else
                  anImageAndTitleWidth = anImageWidth;
                break;
            }
          
          if (aStateImageWidth > neededStateImageWidth)
            neededStateImageWidth = aStateImageWidth;
          
          if (anImageAndTitleWidth > neededImageAndTitleWidth)
            neededImageAndTitleWidth = anImageAndTitleWidth;
                    
          if (aKeyEquivalentWidth > neededKeyEquivalentWidth)
            neededKeyEquivalentWidth = aKeyEquivalentWidth;
          
          // Title view width less than item's left part width
          if ((anImageAndTitleWidth + aStateImageWidth) 
              > neededImageAndTitleWidth)
            wideTitleView = 0;
          
          // Popup menu has only one item with nibble or arrow image
          if (anImageWidth)
            popupImageWidth = anImageWidth;
        }
      if (isPullDown && howMany)
        howMany -= 1;
      
      // Cache the needed widths.
      _stateImageWidth = neededStateImageWidth;
      _imageAndTitleWidth = neededImageAndTitleWidth;
      _keyEqWidth = neededKeyEquivalentWidth;
      
      accumulatedOffset = _horizontalEdgePad;
      if (howMany)
        {
          // Calculate the offsets and cache them.
          if (neededStateImageWidth)
            {
              _stateImageOffset = accumulatedOffset;
              accumulatedOffset += neededStateImageWidth += _horizontalEdgePad;
            }
          
          if (neededImageAndTitleWidth)
            {
              _imageAndTitleOffset = accumulatedOffset;
              accumulatedOffset += neededImageAndTitleWidth;
            }
          
          if (wideTitleView)
            {
              _keyEqOffset = accumulatedOffset = neededImageAndTitleWidth
                + (3 * _horizontalEdgePad);
            }
          else
            {
              _keyEqOffset = accumulatedOffset += (2 * _horizontalEdgePad);
            }
          accumulatedOffset += neededKeyEquivalentWidth + _horizontalEdgePad; 
          
          if ([_attachedMenu supermenu] != nil && neededKeyEquivalentWidth < 8)
            {
              accumulatedOffset += 8 - neededKeyEquivalentWidth;
            }
        }
      else
        {
          accumulatedOffset += neededImageAndTitleWidth + 3 + 2;
          if ([_attachedMenu supermenu] != nil)
            accumulatedOffset += 15;
        }
      
      // Calculate frame size.
      if (_needsSizing)
        {
          // Add the border width: 1 for left, 2 for right sides
          _cellSize.width = accumulatedOffset + 3;
        }
      if ([_attachedMenu _ownedByPopUp])
        {
          _keyEqOffset = _cellSize.width - _keyEqWidth - popupImageWidth;
        }
      [self setFrameSize: NSMakeSize(_cellSize.width + _leftBorderOffset, 
                                     [self totalHeight] 
                                     + menuBarHeight)];
      [_titleView setFrame: NSMakeRect (0, [self totalHeight],
                                        NSWidth (_bounds), menuBarHeight)];
    }
  _needsSizing = NO;
}

@end

