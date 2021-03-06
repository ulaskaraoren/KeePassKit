//
//  KPKBinaryCipherInformation.m
//  KeePassKit
//
//  Created by Michael Starke on 21.07.13.
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

#import "KPKLegacyHeaderReader.h"
#import "KPKLegacyFormat.h"
#import "KPKLegacyHeaderUtility.h"
#import "KPKFormat.h"

#import "KPKErrors.h"

@interface KPKLegacyHeaderReader () {
  KPKLegacyHeader _header;
  NSData *_data;
}

@end

@implementation KPKLegacyHeaderReader

- (id)init {
  self = [super init];
  if(self) {
    
  }
  return self;
}

- (id)initWithData:(NSData *)data error:(NSError *__autoreleasing *)error {
  self = [super init];
  if(self) {
    _data = data;
    if(![self _parseHeader:error]) {
      _data = nil;
      self = nil;
      return nil;
    }
  }
  return self;
}

- (NSUInteger)numberOfEntries {
  return _header.entries;
}

- (NSUInteger)numberOfGroups {
  return _header.groups;
}

- (NSData *)dataWithoutHeader {
  NSUInteger headerSize = sizeof(KPKLegacyHeader);
  return [_data subdataWithRange:NSMakeRange(headerSize, [_data length] - headerSize)];
}

- (void)writeHeaderData:(NSMutableData *)data {
  NSAssert(NO, @"Not implemented");
  return;
}

- (BOOL)_parseHeader:(NSError **)error {
  // Read in the header
  if([_data length] < sizeof(KPKLegacyHeader)) {
    KPKCreateError(error, KPKErrorHeaderCorrupted, @"ERROR_HEADER_CORRUPTED", "");
    return NO;
  }
  [_data getBytes:&_header range:NSMakeRange(0, sizeof(KPKLegacyHeader))];
  /*
   Signature Check was done by KPKFormat to determine the correct Cryptor
   */
  
  // Check the version
  _header.version = CFSwapInt32LittleToHost(_header.version);
  if ((_header.version & 0xFFFFFF00) != (KPK_LEGACY_FILE_VERSION & 0xFFFFFF00)) {
    KPKCreateError(error, KPKErrorUnsupportedDatabaseVersion, @"ERROR_UNSUPPORTED_DATABASER_VERSION", "");
  }
  
  // Check the encryption algorithm
  _header.flags = CFSwapInt32LittleToHost(_header.flags);
  if (!(_header.flags & KPKLegacyEncryptionRijndael)) {
    KPKCreateError(error, KPKErrorUnsupportedCipher, @"ERROR_UNSUPPORTED_CIPHER", "");
    @throw [NSException exceptionWithName:@"IOException" reason:@"Unsupported algorithm" userInfo:nil];
  }
  
  _masterSeed = [[NSData alloc] initWithBytes:_header.masterSeed length:sizeof(_header.masterSeed)];
  _encryptionIV = [[NSData alloc] initWithBytes:_header.encryptionIv length:sizeof(_header.encryptionIv)];
  
  _header.groups = CFSwapInt32LittleToHost(_header.groups);
  _header.entries = CFSwapInt32LittleToHost(_header.entries);
  
  _contentsHash = [[NSData alloc] initWithBytes:_header.contentsHash length:sizeof(_header.contentsHash)];
  _transformSeed = [[NSData alloc] initWithBytes:_header.masterSeed2 length:sizeof(_header.masterSeed2)];
  
  _rounds = CFSwapInt32LittleToHost(_header.keyEncRounds);
  
  // Compute a sha256 hash of the header up to but not including the contentsHash
  _headerHash = [KPKLegacyHeaderUtility hashForHeader:&_header];;
  return YES;
}

@end
