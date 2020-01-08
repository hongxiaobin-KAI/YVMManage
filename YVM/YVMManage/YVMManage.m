//
//  YVMManage.m
//  YVM
//
//  Created by mac on 2019/12/26.
//  Copyright © 2019 Xiaobin Hong. All rights reserved.
//

#import "YVMManage.h"

#import "YVMControlConfig.h"
#import "NSObject+YVM.h"

#import <objc/message.h>

@implementation YVMManage

+ (void)fillView:(id)view model:(id)model {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([model class], &count);
    
    for (NSInteger i = 0; i < count; i++) {
        objc_property_t propertyValue = properties[i];
        
        const char *propertyName = property_getName(propertyValue);
        
        NSString *propertyNameStr = [NSString stringWithUTF8String:propertyName];
        NSString *setPropertyNameStr = @"";
        if (propertyNameStr.length == 0) {
            return;
        } else if (propertyNameStr.length == 1) {
            setPropertyNameStr = [NSString stringWithFormat:@"set%@:",[propertyNameStr capitalizedString]];
        } else {
            setPropertyNameStr = [NSString stringWithFormat:@"set%@%@:",[[propertyNameStr substringWithRange:NSMakeRange(0, 1)] uppercaseString],[propertyNameStr substringWithRange:NSMakeRange(1, propertyNameStr.length - 1)]];
        }
        
        SEL setSeletor = NSSelectorFromString(setPropertyNameStr);
        if ([view respondsToSelector:setSeletor]) {
            NSString *name = @(propertyName);
            id value = [model valueForKey:name];
            if ([value isKindOfClass:[NSString class]]) {
                ((void(*)(id, SEL, NSString *))objc_msgSend)(view, setSeletor, value);
                
            } else if ([value isKindOfClass:[NSAttributedString class]]){
                ((void(*)(id, SEL, NSAttributedString *))objc_msgSend)(view, setSeletor, value);
                
            } else if ([value isKindOfClass:[NSNumber class]]) {
                NSString *type = @([value objCType]);
                if(strcmp([value objCType], @encode(long long)) == 0) {
                    ((void(*)(id, SEL, NSInteger))objc_msgSend)(view, setSeletor, [value integerValue]);
                    
                } else if (strcmp([value objCType], @encode(long)) == 0) {
                    ((void(*)(id, SEL, NSInteger))objc_msgSend)(view, setSeletor, [value integerValue]);
                    
                } else if (strcmp([value objCType], @encode(long)) == 0) {
                    ((void(*)(id, SEL, int))objc_msgSend)(view, setSeletor, [value intValue]);
                    
                } else if (strcmp([value objCType], @encode(double)) == 0) {
                    ((void(*)(id, SEL, CGFloat))objc_msgSend)(view, setSeletor, [value floatValue]);
                    
                } else if (strcmp([value objCType], @encode(float)) == 0) {
                    ((void(*)(id, SEL, CGFloat))objc_msgSend)(view, setSeletor, [value doubleValue]);
                    
                } else if (strcmp([value objCType], @encode(bool)) == 0) {
                    ((void(*)(id, SEL, BOOL))objc_msgSend)(view, setSeletor, [value boolValue]);
                    
                } else if ([type isEqualToString:@"c"] && ([value integerValue] == 1 || [value integerValue] == 0)) {
                    ((void(*)(id, SEL, BOOL))objc_msgSend)(view, setSeletor, [value boolValue]);
                    
                }
                
            } else if ([value isKindOfClass:[NSArray class]]) {
                ((void(*)(id, SEL, NSArray *))objc_msgSend)(view, setSeletor, value);
                
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                ((void(*)(id, SEL, NSDictionary *))objc_msgSend)(view, setSeletor, value);
                
            } else if ([value isKindOfClass:[NSValue class]]) {
                if (strcmp([value objCType], @encode(CGSize)) == 0) {
                    ((void(*)(id, SEL, CGSize))objc_msgSend)(view, setSeletor, [(NSValue *)value CGSizeValue]);
                    
                } else if (strcmp([value objCType], @encode(CGPoint)) == 0) {
                    ((void(*)(id, SEL, CGPoint))objc_msgSend)(view, setSeletor, [(NSValue *)value CGPointValue]);
                    
                } else if (strcmp([value objCType], @encode(CGRect)) == 0) {
                    ((void(*)(id, SEL, CGRect))objc_msgSend)(view, setSeletor, [(NSValue *)value CGRectValue]);
                    
                } else if (strcmp([value objCType], @encode(UIEdgeInsets)) == 0) {
                    ((void(*)(id, SEL, UIEdgeInsets))objc_msgSend)(view, setSeletor, [(NSValue *)value UIEdgeInsetsValue]);
                    
                } else if (strcmp([value objCType], @encode(CGVector)) == 0) {
                    ((void(*)(id, SEL, CGVector))objc_msgSend)(view, setSeletor, [(NSValue *)value CGVectorValue]);
                    
                } else if (strcmp([value objCType], @encode(CGAffineTransform)) == 0) {
                    ((void(*)(id, SEL, CGAffineTransform))objc_msgSend)(view, setSeletor, [(NSValue *)value CGAffineTransformValue]);
                    
                } else if (strcmp([value objCType], @encode(UIOffset)) == 0) {
                    ((void(*)(id, SEL, UIOffset))objc_msgSend)(view, setSeletor, [(NSValue *)value UIOffsetValue]);
                    
                } else {
                    if (@available(iOS 11.0, *)) {
                        if (strcmp([value objCType], @encode(NSDirectionalEdgeInsets)) == 0) {
                            ((void(*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(view, setSeletor, [(NSValue *)value directionalEdgeInsetsValue]);
                            
                        }
                    }
                }
            } else if ([value isKindOfClass:[UIColor class]]) {
                ((void(*)(id, SEL, UIColor *))objc_msgSend)(view, setSeletor, value);
            } else if ([value isKindOfClass:[UIImage class]]) {
                ((void(*)(id, SEL, UIImage *))objc_msgSend)(view, setSeletor, value);
            }
        }
    }
    
    free(properties);
}

+ (void)fillView:(id)view config:(id)config {
    if ([config isKindOfClass:[YVMControlConfig class]]) {
        YVMControlConfig *controlConfig = (YVMControlConfig *)config;
        UIControl *control = [view viewWithTag:controlConfig.type.integerValue];
        if ([control isKindOfClass:[UIControl class]] && controlConfig.target != nil) {
            NSString *methodName = controlConfig.methodName;
            SEL sel = NSSelectorFromString(methodName);
            if ([controlConfig.target respondsToSelector:sel]) {
                [control addTarget:controlConfig.target action:sel forControlEvents:controlConfig.event];
                [control setYvmType:controlConfig.type];
                [control setYvmIndex:@(controlConfig.indexRow).stringValue];
                [control setYvmSection:@(controlConfig.section).stringValue];
            }
        }
    }
}

@end
