//
//  MAXFMDBUnit.h
//  FMDB-Runtime
//
//  Created by max on 16/7/26.
//  Copyright © 2016年 MAX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAXFMDBUnit : NSObject

/**
 * TEXT数据类型和字段名
 */
NSString * MAX_text(NSString *fieldName);

/**
 * INTEGER数据类型和字段名
 */
NSString * MAX_integer(NSString *fieldName);

/**
 * FLOAT数据类型和字段名
 */
NSString * MAX_float(NSString *fieldName);

/**
 * DOUBLE数据类型和字段名
 */
NSString * MAX_double(NSString *fieldName);


/**
 * TEXT PRIMARY KEY数据类型和字段名
 */
NSString * MAX_text_pk(NSString *fieldName);

/**
 * INTEGER PRIMARY KEY数据类型和字段名
 */
NSString * MAX_integer_pk(NSString *fieldName);

/**
 * FLOAT PRIMARY KEY数据类型和字段名
 */
NSString * MAX_float_pk(NSString *fieldName);

/**
 * DOUBLE PRIMARY KEY数据类型和字段名
 */
NSString * MAX_double_pk(NSString *fieldName);

@end
