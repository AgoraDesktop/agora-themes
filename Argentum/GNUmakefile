#
#  Top level makefile for GNUstep Backend
#
#  Copyright (C) 2009-2010 Free Software Foundation, Inc.
#
#  Author: Riccardo Mottola
#
#  This file is part of the Argentum theme for Agora Desktop.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; see the file COPYING.LIB.
#  If not, see <http://www.gnu.org/licenses/> or write to the 
#  Free Software Foundation, 51 Franklin Street, Fifth Floor, 
#  Boston, MA 02110-1301, USA.

ifeq ($(GNUSTEP_MAKEFILES),)
 GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
endif

ifeq ($(GNUSTEP_MAKEFILES),)
  $(error You need to set GNUSTEP_MAKEFILES before compiling!)
endif


include $(GNUSTEP_MAKEFILES)/common.make

PACKAGE_NAME = Argentum
BUNDLE_NAME = Argentum
BUNDLE_EXTENSION = .theme
VERSION = 1
GNUSTEP_INSTALLATION_DOMAIN = SYSTEM

Argentum_INSTALL_DIR=$(GNUSTEP_LIBRARY)/Themes
Argentum_PRINCIPAL_CLASS = ArgentumTheme
ADDITIONAL_OBJC_LIBS=

Argentum_OBJC_FILES = \
		Argentum.m \
		ArgentumWindowDecorator.m
#
# Resource files
#
Argentum_RESOURCE_FILES = \
		Resources/ArgentumTheme.png \
		Resources/Argentum_preview_128.tiff \
		Resources/ThemeImages \
		Resources/ThemeTiles \
		Resources/ThemeColors.clr \
		Resources/ThemeExtraColors.clr \
		Resources/ThemeExtraHighlightedColors.clr

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/bundle.make

-include GNUmakefile.postamble

