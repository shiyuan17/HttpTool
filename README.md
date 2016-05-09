# HttpTool
IOS网络请求库，基于AFN封装，带缓存处理,提供优化的处理方式。   
更新日志：   
1.移除TMCache,改用UserDefault进行缓存，有需要的话可以随时替换，把对应的[USER_DEFAULT setObject: forKey:];替换成[TMCache shareManager] setObject: forKey:];即可。   
2.添加对保存对象的加密   
3.解决网络状态检查有误
   
如有更好的建议或者发现bug请联系qq:1213423761