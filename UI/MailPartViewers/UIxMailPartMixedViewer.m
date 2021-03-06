/*
  Copyright (C) 2007-2015 Inverse inc.
  Copyright (C) 2004-2005 SKYRIX Software AG

  This file is part of SOGo.

  SOGo is free software; you can redistribute it and/or modify it under
  the terms of the GNU Lesser General Public License as published by the
  Free Software Foundation; either version 2, or (at your option) any
  later version.

  SOGo is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
  License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with OGo; see the file COPYING.  If not, write to the
  Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.
*/

#import <Foundation/NSDictionary.h>

#import <UI/MailerUI/WOContext+UIxMailer.h>

#import "UIxMailRenderingContext.h"
#import "UIxMailPartMixedViewer.h"

@implementation UIxMailPartMixedViewer

- (void)dealloc {
  [self->childInfo release];
  [super dealloc];
}

/* caches */

- (void)resetBodyInfoCaches {
  [self->childInfo release]; self->childInfo = nil;
  [super resetBodyInfoCaches];
}

/* accessors */

- (void)setChildInfo:(id)_info {
  ASSIGN(self->childInfo, _info);
}
- (id)childInfo {
  return self->childInfo;
}

- (void) setChildIndex: (NSUInteger) _index {
  self->childIndex = _index;
}
- (NSUInteger) childIndex {
  return self->childIndex;
}

- (NSString *)childPartName {
  return [NSString stringWithFormat: @"%u",
                   (unsigned int) ([self childIndex] + 1)];
  char buf[8];
  sprintf(buf, "%d", [self childIndex] + 1);
  return [NSString stringWithCString:buf];
}

- (id)childPartPath {
  NSArray *pp;

  pp = [self partPath];
  return [pp count] > 0
    ? (id)[pp arrayByAddingObject:[self childPartName]]
    : (id)[NSArray arrayWithObject:[self childPartName]];
}

/* nested viewers */

- (id)contentViewerComponent {
  id info;
  
  info = [self childInfo];
  return [[[self context] mailRenderingContext] viewerForBodyInfo:info];
}

- (id) renderedPart {
  id info, viewer;
  NSArray *parts;
  NSMutableArray *renderedParts;
  NSUInteger i, max;

  parts = [[self bodyInfo] objectForKey: @"parts"];
  max = [parts count];
  renderedParts = [NSMutableArray arrayWithCapacity: max];
  for (i = 0; i < max; i++)
    {
      [self setChildIndex: i];
      [self setChildInfo: [parts objectAtIndex: i]];
      info = [self childInfo];
      viewer = [[[self context] mailRenderingContext] viewerForBodyInfo: info];
      [viewer setBodyInfo: info];
      [viewer setPartPath: [self childPartPath]];
      [renderedParts addObject: [viewer renderedPart]];
    }

  return [NSDictionary dictionaryWithObjectsAndKeys:
                         [self className], @"type",
                       renderedParts, @"content",
                       nil];
}

@end /* UIxMailPartMixedViewer */
