//
//  MAXFMDBUnit.m
//  FMDB-Runtime
//
//  Created by max on 16/7/26.
//  Copyright © 2016年 MAX. All rights reserved.
//

#import "MAXFMDBUnit.h"
#import "MAXFMDBMacro.h"

@implementation MAXFMDBUnit

NSString * FORMAT(NSString *fieldName, NSString *type)
{
    return [NSString stringWithFormat:@"%@ %@", fieldName, type];
}


NSString * MAX_text(NSString *fieldName)
{
    return FORMAT(fieldName, MAX_TEXT);
}

NSString * MAX_integer(NSString *fieldName)
{
    return FORMAT(fieldName, MAX_INTEGER);
}

NSString * MAX_float(NSString *fieldName)
{
    return FORMAT(fieldName, MAX_FLOAT);
}

NSString * MAX_double(NSString *fieldName)
{
    return FORMAT(fieldName, MAX_DOUBLE);
}


NSString * MAX_text_pk(NSString *fieldName)
{
    return MAXFORMAT(MAX_text(fieldName), MAX_SQL_PK);
}

NSString * MAX_integer_pk(NSString *fieldName)
{
    return FORMAT(MAX_integer(fieldName), MAX_SQL_PK);
}

NSString * MAX_float_pk(NSString *fieldName)
{
    return FORMAT(MAX_float(fieldName), MAX_SQL_PK);
}

NSString * MAX_double_pk(NSString *fieldName)
{
    return FORMAT(MAX_double(fieldName), MAX_SQL_PK);
}

@end
