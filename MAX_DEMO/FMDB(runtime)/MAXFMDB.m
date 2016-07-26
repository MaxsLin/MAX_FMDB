//
//  MAXFMDB.m
//  FMDB-Runtime
//
//  Created by max on 16/7/26.
//  Copyright © 2016年 MAX. All rights reserved.
//

#import "MAXFMDB.h"
#import <objc/runtime.h>
#import "FMDB.h"
static MAXFMDB *DBManager = nil;
@implementation MAXFMDB
{
    FMDatabaseQueue *_dbQueue;
}

+ (void)shareManager:(void(^)(MAXFMDB *manager))manager
{
    NSLog(@"%@", NSHomeDirectory());
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        DBManager = [[MAXFMDB alloc] init];
    });
    
    if (manager) {
        manager(DBManager);
    }
}

+ (MAXFMDB *(^)())share
{
    return ^(){
        
        [self shareManager:nil];
        
        return DBManager;
    };
}

- (instancetype)init
{
    if (self = [super init]) {
        
        // 1. 获取沙盒路径
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        // 获取项目名
        NSString *executableFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey];
        
        // 拼接数据库的名称
        path = [path stringByAppendingPathComponent:[executableFile stringByAppendingString:@".db"]];
        
        // 2. 创建数据库队列
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return self;
}

// 通过模型建表
- (void (^)(__weak Class cls, NSString *tbName, NSString *pk))create_model
{
    return ^(Class cls, NSString *tbName, NSString *pk){
        
        id dic = [self getClassProperty:cls];
        
        NSArray *types = dic[MAX_PROPERTY_YTPE];
        NSArray *names = dic[MAX_PROPERTY_NAME];
        
        // 语句
        NSString *sql = MAXFORMAT(@"%@ %@", MAX_SQL_CREATE, tbName);
        
        for (int i = 0; i < types.count; i++)
        {
            if (0 == i && (i != types.count - 1))
            {
                if ([pk isEqualToString:names[i]])
                    sql = [sql stringByAppendingFormat:@"(%@ %@ %@,", names[i], types[i], MAX_SQL_PK];
                else
                    sql = [sql stringByAppendingFormat:@"(%@ %@,", names[i], types[i]];
            }
            else if (i == (types.count - 1))
            {
                if ([pk isEqualToString:names[i]])
                    sql = [sql stringByAppendingFormat:@"%@ %@ %@)", names[i], types[i], MAX_SQL_PK];
                else
                    sql = [sql stringByAppendingFormat:@"%@ %@)", names[i], types[i]];
            }
            else
            {
                if ([pk isEqualToString:names[i]])
                    sql = [sql stringByAppendingFormat:@"%@ %@,", names[i], types[i]];
                else
                    sql = [sql stringByAppendingFormat:@"%@ %@ %@,", names[i], types[i], MAX_SQL_PK];
            }
        }
        
        //        NSLog(@"%@", sql);
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            
            if (![db executeUpdate:sql])
            {
                NSLog(@"MAXFMDB 创建 %@ 表失败!", tbName);
            }
        }];
    };
}

// 建表
- (void (^)(NSArray *sqls))create_sqls
{
    return ^(NSArray *sqls){
        
        // 语句
        NSString *sql = MAX_SQL_CREATE;
        
        for (int i = 0; i < sqls.count; i++)
        {
            if (0 == i)
            {
                sql = [sql stringByAppendingFormat:@" %@(", sqls[i]];
            }
            else if (i == (sqls.count - 1))
            {
                sql = [sql stringByAppendingFormat:@"%@)", sqls[i]];
            }
            else
            {
                sql = [sql stringByAppendingFormat:@"%@,", sqls[i]];
            }
        }
        
        //        NSLog(@"%@", sql);
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            
            if (![db executeUpdate:sql])
            {
                NSLog(@"MAXFMDB 创建 %@ 表失败!", sqls[0]);
            }
        }];
    };
}

// 插入数据
- (void (^)(NSArray *sqls))insert_sqls;
{
    return ^(NSArray *sqls){
        
        NSMutableArray *keys = [NSMutableArray new];
        NSMutableArray *values = [NSMutableArray new];
        
        // ?
        NSString *placeholder = @"";
        
        for (int i = 1; i < sqls.count; i++)
        {
            for (id key in sqls[i])
            {
                [keys addObject:key];
                [values addObject:sqls[i][key]];
            }
            
            if (1 == i) {
                placeholder = [placeholder stringByAppendingString:@"?"];
            } else if (i == sqls.count - 1) {
                placeholder = [placeholder stringByAppendingString:@",?)"];
            } else {
                placeholder = [placeholder stringByAppendingString:@",?"];
            }
        }
        
        // 语句
        NSString *sql = MAX_SQL_INSERT;
        
        for (int i = 0; i < sqls.count; i++)
        {
            if (0 == i)
            {
                sql = [sql stringByAppendingFormat:@" %@(", sqls[i]];
            }
            else if (i == (sqls.count - 1))
            {
                sql = [sql stringByAppendingFormat:@"%@)VALUES(", keys[i - 1]];
            }
            else
            {
                sql = [sql stringByAppendingFormat:@"%@,", keys[i - 1]];
            }
        }
        
        sql = [sql stringByAppendingString:placeholder];
        
        //        NSLog(@"%@", sql);
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            
            if (![db executeUpdate:sql withArgumentsInArray:values])
            {
                NSLog(@"MAXFMDB 插入 %@ 表中的数据失败!", sqls[0]);
            }
        }];
    };
}

- (void (^)(__weak id model, NSString *tbName))insert_model
{
    return ^(id model, NSString *tbName){
        
        // 获取表中所有字段
        NSArray *fields = [self tableFields:tbName];
        NSArray *property = [self getClassProperty:[model class]][MAX_PROPERTY_NAME];
        
        NSMutableArray *values = [NSMutableArray new];
        
        NSString *sql = MAXFORMAT(@"%@ %@", MAX_SQL_INSERT, tbName);
        
        for (int i = 0; i < fields.count; i++)
        {
            if (i == 0)
                sql = [sql stringByAppendingFormat:@"(%@,", fields[i]];
            else if (i == (fields.count - 1))
                sql = [sql stringByAppendingFormat:@"%@)", fields[i]];
            else
                sql = [sql stringByAppendingFormat:@"%@,", fields[i]];
            
            // 过滤
            if ([property containsObject:fields[i]]) {
                // 将值存入数组
                [values addObject:[model valueForKey:fields[i]]];
            } else {
                [values addObject:@""];
            }
        }
        
        // VALUES
        sql = [sql stringByAppendingString:@"VALUES"];
        
        for (int i = 0; i < fields.count; i++)
        {
            if (i == 0)
                sql = [sql stringByAppendingString:@"(?,"];
            else if (i == (fields.count - 1))
                sql = [sql stringByAppendingString:@"?)"];
            else
                sql = [sql stringByAppendingString:@"?,"];
        }
        
        //        NSLog(@"%@", sql);
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            
            if (![db executeUpdate:sql withArgumentsInArray:values])
            {
                NSLog(@"MAXFMDB 插入 %@ 表中的数据失败!", tbName);
            }
        }];
    };
}

// 获取表中的所有数据
- (NSArray * (^)(NSString *tableName, __weak Class cls))findAll
{
    return ^(NSString *tableName, __weak Class cls) {
        
        // 创建要返回的数组
        NSMutableArray *data = [NSMutableArray new];
        
        // 查询结果集
        [_dbQueue inDatabase:^(FMDatabase *db) {
            
            // 根据表名查询数据库
            NSString *sql = MAXFORMAT(@"%@ %@", MAX_SQL_SELECT_ALL, tableName);
            
            FMResultSet *set = [db executeQuery:sql];
            
            unsigned int count = 0;
            // 获取model中的所有属性列表
            Ivar *ivars = class_copyIvarList(cls, &count);
            
            
            // 遍历
            while ([set next])
            {
                // 根据传进来的类cls，创建对应的对象并保存
                id obj = [[cls alloc] init];
                
                Ivar ivar;
                const char *ivarType;
                
                NSString *type;
                NSString *proName;
                NSString *name;
                
                // 遍历所有的属性变量
                for (int i = 0; i < count; i++)
                {
                    // 得到该属性
                    ivar = ivars[i];
                    
                    // 获取变量类型
                    ivarType =  ivar_getTypeEncoding(ivar);
                    
                    // 转为NSString类型，用于判断
                    type = [NSString stringWithCString:ivarType encoding:NSUTF8StringEncoding];
                    
                    // 获取变量名
                    proName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
                    
                    //                    NSLog(@"(%@) --- (%@)", proName, type);
                    
                    // 去掉前面的第一个"_"
                      name = [proName substringFromIndex:1];
                    
                    // 判断属性类型，这里仅考虑了几个常用的NSString,int,float,BOOL类型
                    /*
                     i -- int
                     B -- BOOL
                     f -- float
                     d -- double
                     q -- NSInteger
                     @"NSNumber" -- NSNumber
                     @"NSString" -- NSString
                     @"NSMutableArray" -- NSMutableArray
                     @"NSMutableDictionary" -- NSMutableDictionary
                     */
                    if ([type hasPrefix:@"@\"NSString\""])
                    {
                        // 这是NSString类型
                        // 使用setValue:forKey:来设置值
                        [obj setValue:[set stringForColumn:name] forKey:name];
                    }
                    else if ([type hasPrefix:@"i"] || [type hasPrefix:@"q"])
                    {
                        // 这是NSInteger和int类型
                        [obj setValue:@([set intForColumn:name]) forKey:name];
                    }
                    else if ([type hasPrefix:@"f"] || [type hasPrefix:@"d"])
                    {
                        // 这是float和double类型
                        [obj setValue:@([set doubleForColumn:name]) forKey:name];
                    }
                    else if ([type hasPrefix:@"B"])
                    {
                        // 这是BOOL类型
                        [obj setValue:@([set boolForColumn:name]) forKey:name];
                    }
                }
                
                // 释放
                free(ivars);
                
                // 将值保存到数组中
                [data addObject:obj];
            }
        }];
        
        return data;
    };
}


// 回到主线程
- (void)main_queue:(void(^)())queue
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        queue();
    });
}

// 查询某个表的所有字段名和信息
- (NSArray *)tableFields:(NSString *)tableName
{
    NSMutableArray *fields = [NSMutableArray new];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        // 查询某个表的所有字段名和信息
        NSString *sql = MAXFORMAT(@"%@(%@)", MAX_SQL_PRAGMA, tableName);
        
        FMResultSet *set = [db executeQuery:sql];
        
        while ([set next]) {
            
            //            NSLog(@"xxx--%@", [set stringForColumn:@"name"]);
            
            [fields addObject:[set stringForColumn:@"name"]];
        }
    }];
    
    return fields;
}

// 获取class所有属性和类型
- (NSDictionary *)getClassProperty:(Class)cls
{
    // 存储列名和列类型的可变数组
    NSMutableArray *propertyNames = [NSMutableArray array];
    NSMutableArray *propertyTypes = [NSMutableArray array];
    
    unsigned int outCount, i;
    
    // 获取属性和类型
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    
    // 属性名称和类型
    NSString *propertyName;
    NSString *propertyType;
    
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        
        // 获取属性名
        propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        // 获取属性类型
        propertyType = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        
        [propertyNames addObject:propertyName];
        
        //        NSLog(@"%@ -- %@", propertyName, propertyType);
        
        // 判断类型
        /*
         int -- Ti
         BOOL -- TB
         float -- Tf
         double -- Td
         NSInteger -- Tq
         NSString -- T@"NSString"
         NSNumber -- T@"NSNumber"
         NSMutableArray -- T@"NSMutableArray"
         NSMutableDictionary -- T@"NSMutableDictionary"
         */
        if ([propertyType hasPrefix:@"T@"])
        {
            // 这是NSString类型
            [propertyTypes addObject:MAX_TEXT];
        }
        else if ([propertyType hasPrefix:@"Ti"] || [propertyType hasPrefix:@"Tq"] || [propertyType hasPrefix:@"TB"])
        {
            // 这是INTEGER类型
            [propertyTypes addObject:MAX_INTEGER];
        }
        else if ([propertyType hasPrefix:@"Tf"] || [propertyType hasPrefix:@"Td"])
        {
            // 这是浮点类型
            [propertyTypes addObject:MAX_DOUBLE];
        }
    }
    
    // 释放
    free(properties);
    
    return  [NSDictionary dictionaryWithObjectsAndKeys:propertyNames,MAX_PROPERTY_NAME,propertyTypes,MAX_PROPERTY_YTPE, nil];
}
@end
