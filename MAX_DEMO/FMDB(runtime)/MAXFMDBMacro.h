//
//  MAXFMDBMacro.h
//  FMDB-Runtime
//
//  Created by max on 16/7/26.
//  Copyright © 2016年 MAX. All rights reserved.
//

#ifndef MAXFMDBMacro_h
#define MAXFMDBMacro_h

#define MAXFORMAT(fmt, ...) [NSString stringWithFormat:(fmt), ##__VA_ARGS__]

#define MAX_TEXT     @"TEXT"
#define MAX_FLOAT    @"FLOAT"
#define MAX_DOUBLE   @"DOUBLE"
#define MAX_INTEGER  @"INTEGER"

#define MAX_PROPERTY_NAME @"MAX_PROPERTY_NAME"
#define MAX_PROPERTY_YTPE @"MAX_PROPERTY_TYPE"

#define MAX_SQL_CREATE       @"CREATE TABLE IF NOT EXISTS"
#define MAX_SQL_PK           @"PRIMARY KEY NOT NULL"
#define MAX_SQL_INSERT       @"INSERT INTO"
#define MAX_SQL_SELECT_ALL   @"SELECT * FROM"
#define MAX_SQL_PRAGMA       @"PRAGMA TABLE_INFO"

/**
 * 重写NSLog，Debug模式下打印日志和当前行数
 * 防止release版本中含有多余的打印信息
 */
#if DEBUG
#define NSLog(fmt, ...) fprintf(stderr,"\nline:%d content:%s\n", __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(fmt, ...) nil
#endif

#endif /* MAXFMDBMacro_h */
