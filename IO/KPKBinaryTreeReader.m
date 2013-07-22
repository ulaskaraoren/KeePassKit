//
//  KPKBinaryTreeReader.m
//  KeePassKit
//
//  Created by Michael Starke on 20.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "KPKBinaryTreeReader.h"
#import "KPKLegacyHeaderReader.h"

@interface KPKBinaryTreeReader () {
  NSData *_data;
  KPKLegacyHeaderReader *_cipherInfo;
}

@end

@implementation KPKBinaryTreeReader

- (id)initWithData:(NSData *)data chipherInformation:(KPKLegacyHeaderReader *)cipherInfo {
  self = [super init];
  if(self) {
    _data = data;
    _cipherInfo = cipherInfo;
  }
  return self;
}

- (KPKTree *)tree {
  /*
  levels = [[NSMutableArray alloc] initWithCapacity:numGroups];
  groups = [[NSMutableArray alloc] initWithCapacity:numGroups];
  entries = [[NSMutableArray alloc] initWithCapacity:numEntries];
  
  @try {
    // Parse groups
    [self readGroups:aesInputStream];
    
    // Parse entries
    [self readEntries:aesInputStream];
    
    // Build the tree
    return [self buildTree];
  } @finally {
    aesInputStream = nil;
  }*/
  return nil;
}

@end