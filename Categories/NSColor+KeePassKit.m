//
//  NSColor+KeePassKit.m
//  MacPass
//
//  Created by Michael Starke on 05.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "NSColor+KeePassKit.h"
#import "NSString+Hexdata.h"

@implementation NSColor (KeePassKit)

+ (NSColor *)colorWithHexString:(NSString *)hex {
  if([hex hasPrefix:@"#"]) {
    hex = [hex substringFromIndex:1];
  }
  NSData *hexData = [hex dataFromHexString];
  return [self colorWithData:hexData];
}

+ (NSColor *)colorWithData:(NSData *)data {
  if([data length] != 3 && [data length] != 4) {
    return nil; // Unsupported data format
  }
  uint8_t red,green,blue;
  [data getBytes:&red range:NSMakeRange(0, 1)];
  [data getBytes:&green range:NSMakeRange(1, 1)];
  [data getBytes:&blue range:NSMakeRange(2, 1)];
  
  if(red > 255 || green > 255 || blue > 255) {
    return nil;
  }
  
  return [NSColor colorWithCalibratedRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

+ (NSString *)hexStringFromColor:(NSColor *)color {
  return [color hexString];
}

- (NSString *)hexString {
  NSColor *rgbColor = [self colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
  if(!rgbColor) {
    return nil;
  }
  return [NSString stringWithFormat:@"#%02X%02X%02X",
          (int)([rgbColor redComponent] * 255),
          (int)([rgbColor greenComponent] * 255),
          (int)([rgbColor blueComponent] * 255)];
}

- (NSData *)colorData {
  NSColor *rgbColor = [self colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
  if(!rgbColor) {
    return nil;
  }
  uint8_t color[4] = { 0 };
  color[0] = (uint8_t)[rgbColor redComponent]*255;
  color[1] = (uint8_t)[rgbColor greenComponent]*255;
  color[2] = (uint8_t)[rgbColor blueComponent]*255;
  return [NSData dataWithBytes:&color length:4];
}

@end