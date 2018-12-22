// The MIT License (MIT)
//
// Copyright (c) 2015-2016 forkingdog ( https://github.com/forkingdog )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "UITableView+FDKeyedHeightCache.h"
#import <objc/runtime.h>

@interface FDKeyedHeightCache ()
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *mutableHeightsByKeyForPortrait;
@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *mutableHeightsByKeyForLandscape;
@end

@implementation FDKeyedHeightCache


/**
 初始化方法

 @return <#return value description#>
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableHeightsByKeyForPortrait = [NSMutableDictionary dictionary];
        _mutableHeightsByKeyForLandscape = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary<id<NSCopying>, NSNumber *> *)mutableHeightsByKeyForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.mutableHeightsByKeyForPortrait: self.mutableHeightsByKeyForLandscape;
}

// 是否存在通过key 获取缓存高度
- (BOOL)existsHeightForKey:(id<NSCopying>)key {
    NSNumber *number = self.mutableHeightsByKeyForCurrentOrientation[key];
    return number && ![number isEqualToNumber:@-1];
}


/**
 缓存高度 通过key

 @param height <#height description#>
 @param key <#key description#>
 */
- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key {
    self.mutableHeightsByKeyForCurrentOrientation[key] = @(height);
}


/**
 通过key 获取高度

 @param key <#key description#>
 @return <#return value description#>
 */
- (CGFloat)heightForKey:(id<NSCopying>)key {
#if CGFLOAT_IS_DOUBLE
    return [self.mutableHeightsByKeyForCurrentOrientation[key] doubleValue];
#else
    return [self.mutableHeightsByKeyForCurrentOrientation[key] floatValue];
#endif
}


/**
 清除这个key 所缓存的height

 @param key <#key description#>
 */
- (void)invalidateHeightForKey:(id<NSCopying>)key {
    [self.mutableHeightsByKeyForPortrait removeObjectForKey:key];
    [self.mutableHeightsByKeyForLandscape removeObjectForKey:key];
}


/**
 清除所有的缓存height
 */
- (void)invalidateAllHeightCache {
    [self.mutableHeightsByKeyForPortrait removeAllObjects];
    [self.mutableHeightsByKeyForLandscape removeAllObjects];
}

@end

@implementation UITableView (FDKeyedHeightCache)

- (FDKeyedHeightCache *)fd_keyedHeightCache {
    FDKeyedHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [FDKeyedHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end
