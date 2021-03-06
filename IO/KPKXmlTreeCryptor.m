//
//  KPKXmlDataCryptor.m
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

#import "KPKXmlTreeCryptor.h"
#import "KPKXmlHeaderReader.h"
#import "KPKCompositeKey.h"
#import "KPKVersion.h"
#import "KPKErrors.h"
#import "KPKXmlFormat.h"
#import "KPKTree.h"
#import "KPKMetaData.h"

#import "NSData+CommonCrypto.h"
#import "NSData+HashedData.h"
#import "NSData+Gzip.h"

#import "KPKXmlTreeReader.h"
#import "KPKXmlTreeWriter.h"
#import "KPKXmlHeaderWriter.h"

#import "DDXMLDocument.h"

#import <CommonCrypto/CommonCryptor.h>

@implementation KPKXmlTreeCryptor

+ (KPKTree *)decryptTreeData:(NSData *)data withPassword:(KPKCompositeKey *)password error:(NSError **)error {
  KPKXmlHeaderReader *headerReader = [[KPKXmlHeaderReader alloc] initWithData:data error:error];
  if(!headerReader) {
    return nil;
  }
  
  /*
   Create the Key
   Supply the Data found in the header
   */
  NSData *keyData = [password finalDataForVersion:KPKXmlVersion
                                       masterSeed:headerReader.masterSeed
                                    transformSeed:headerReader.transformSeed
                                           rounds:headerReader.rounds];
  
  /*
   The datastream is AES encrypted. Decrypt using the supplied
   */
  CCCryptorStatus cryptoError = kCCSuccess;
  NSData *aesDecrypted = [[headerReader dataWithoutHeader] decryptedDataUsingAlgorithm:kCCAlgorithmAES128
                                                                                   key:keyData
                                                                  initializationVector:headerReader.encryptionIV
                                                                               options:kCCOptionPKCS7Padding
                                                                                 error:&cryptoError];
  if(cryptoError != kCCSuccess) {
    KPKCreateError(error, KPKErrorDecryptionFaild, @"ERROR_DECRYPTION_FAILED", "");
    return nil;
  }
  /*
   Compare the first Streambytes with the ones stores in the header
   */
  NSData *startBytes = [aesDecrypted subdataWithRange:NSMakeRange(0, 32)];
  if(![headerReader.streamStartBytes isEqualToData:startBytes]) {
    KPKCreateError(error, KPKErrorPasswordAndOrKeyfileWrong, @"ERROR_PASSWORD_OR_KEYFILE_WRONG", "");
    return nil;
  }
  /*
   The Stream is Hashed, read the data and verify it.
   If the Stream was Gzipped, uncrompress it.
   */
  NSData *unhashedData = [[aesDecrypted subdataWithRange:NSMakeRange(32, [aesDecrypted length] - 32)] unhashedData];
  if(headerReader.compressionAlgorithm == KPKCompressionGzip) {
    unhashedData = [unhashedData gzipInflate];
  }
  
  if(!unhashedData) {
    KPKCreateError(error, KPKErrorIntegrityCheckFaild, @"ERROR_INTEGRITY_CHECK_FAILED", "");
    return nil;
  }
  KPKXmlTreeReader *reader = [[KPKXmlTreeReader alloc] initWithData:unhashedData headerReader:headerReader];
  return [reader tree:error];
}

+ (NSData *)encryptTree:(KPKTree *)tree password:(KPKCompositeKey *)password error:(NSError *__autoreleasing *)error {
  
  NSMutableData *data = [[NSMutableData alloc] init];
  
  KPKXmlTreeWriter *treeWriter = [[KPKXmlTreeWriter alloc] initWithTree:tree];
  NSData *xmlData = [[treeWriter protectedXmlDocument] XMLDataWithOptions:DDXMLNodeCompactEmptyElement];
  if(!xmlData) {
    // create Error
    return nil;
  }
  NSData *key = [password finalDataForVersion:KPKXmlVersion
                                   masterSeed:treeWriter.headerWriter.masterSeed
                                transformSeed:treeWriter.headerWriter.transformSeed
                                       rounds:treeWriter.tree.metaData.rounds];
  
  
  NSMutableData *contentData = [[NSMutableData alloc] initWithData:treeWriter.headerWriter.streamStartBytes];
  if(tree.metaData.compressionAlgorithm == KPKCompressionGzip) {
    xmlData = [xmlData gzipDeflate];
  }
  NSData *hashedData = [xmlData hashedDataWithBlockSize:1024*1024];
  [contentData appendData:hashedData];
  NSData *encryptedData = [contentData dataEncryptedUsingAlgorithm:kCCAlgorithmAES128
                                                              key:key
                                             initializationVector:treeWriter.headerWriter.encryptionIv
                                                          options:kCCOptionPKCS7Padding
                                                            error:NULL];
  [treeWriter.headerWriter writeHeaderData:data];
  [data appendData:encryptedData];
  return data;
}

@end
