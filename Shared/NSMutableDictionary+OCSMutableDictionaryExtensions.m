
@implementation NSMutableDictionary (OCSMutableDictionaryExtensions)
-(void)ocs_addExistingEntriesWithKeys:keys fromDictionary:(NSDictionary*)dict {
    if (!keys) keys=dict.allKeys;
    for (id key in keys) {
        id val=dict[key];
        if (val) self[key]=val; // what was this good for?!? It CANNOT be nil, or can it?
    }
}
-(void)ocs_addNewEntriesWithKeys:keys fromDictionary:(NSDictionary*)dict {
    if (!keys) keys=dict.allKeys;
    for (id key in keys) if (!self[key]) {
        id val=dict[key];
        if (val) self[key]=val;
    }
}
@end
