//
//  KPKDataStreamer.h
//  KeePassKit
//
//  Created by Michael Starke on 24.07.13.
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

#import <Foundation/Foundation.h>

@interface KPKDataStreamReader : NSObject

- (id)initWithData:(NSData *)data;

- (NSData *)dataWithLength:(NSUInteger)length;
- (NSString *)stringWithLenght:(NSUInteger)length encoding:(NSStringEncoding)encoding;
- (void)readBytes:(void *)buffer length:(NSUInteger)length;
- (uint8_t)readByte;
- (uint16_t)read2Bytes;
- (uint32_t)read4Bytes;
- (uint64_t)read8Bytes;
- (NSUInteger)integer;

- (NSUInteger)location;
- (void)skipBytes:(NSUInteger)numberOfBytes;
- (BOOL)endOfData;
- (NSUInteger)countOfReadableBytes;
- (void)reset;

@end
