#MAX_FMDB
> 基于FMDB 封装

[MAXFMDB shareManager:^(MAXFMDB *manager) {
     
     // 建表
     manager.create_sqls(@[@"myTable",
     MAX_integer_pk(@"id"),
     MAX_text(@"name"),
     MAX_integer(@"age")]);
     }];
     
    
    
    
    /*
     [MAXFMDB shareManager:^(MAXFMDB *manager) {
     
     // 插入数据
     manager.insert(@[@"myTable",
     @{@"id":@"001"},
     @{@"name":@"zhangsan"},
     @{@"age":@"18"}]);
     }];
     */
    
    
    /*
     [MAXFMDB shareManager:^(MAXFMDB *manager) {
     
     // 获取所有数据
     NSArray *results = manager.findAll(@"myTable", [UserModel class]);
     
     // 刷新UI
     [manager main_queue:^{
     // ...
     }];
     }];
     */
    
    
    /*
     [MAXFMDB shareManager:^(MAXFMDB *manager) {
     
     manager.create_model([UserModel class], @"myTable", @"name");
     }];
     */
    
    
    // [MAXFMDB share]().create_model([UserModel class], @"myTable", @"name");
    
    
    UserModel *model = [UserModel new];
    model.name = @"小王";
    model.age = 18;
    model.id = 1001;
    
    [MAXFMDB share]().insert_model(model, @"myTable");
