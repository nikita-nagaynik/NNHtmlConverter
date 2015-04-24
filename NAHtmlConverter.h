//
//  NAHtmlConverter.h
//
//  Created by Nikita Nagajnik on 24/10/14.
//

@interface NAAttrOptions : NSObject

@property (strong, nonatomic) UIFont *boldFont;
@property (strong, nonatomic) UIFont *emphasisFont;

@end


@interface NAHtmlConverter : NSObject

+ (instancetype)converterByOptions:(NAAttrOptions *)options;

- (NSAttributedString *)convertHtml:(NSString *)text;
- (NSAttributedString *)convertHtml:(NSString *)text tagsAttributes:(NSDictionary *)tagsAttributes;

@end