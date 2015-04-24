//
//  NAHtmlConverter.m
//
//  Created by Nikita Nagajnik on 24/10/14.
//

#import "NAHtmlConverter.h"
#import "NSString+HTML.h"

@implementation NAAttrOptions

@end

@interface NAHtmlConverter ()

@property (strong, nonatomic) NAAttrOptions *options;

@end

@implementation NAHtmlConverter

+ (instancetype)converterByOptions:(NAAttrOptions *)options
{
    return [[self.class alloc] initByOptions:options];
}

- (instancetype)initByOptions:(NAAttrOptions *)options
{
    if (self = [super init]) {
        _options = options;
    }
    return self;
}

- (NSAttributedString *)convertHtml:(NSString *)text
{
    if (text.length == 0) {
        return nil;
    }
    
    text = [text stringByDecodingHTMLEntities];
    
    NSDictionary *boldAttributes = @{NSFontAttributeName: self.options.boldFont};
    NSDictionary *emphasisAttributes = @{NSFontAttributeName: self.options.emphasisFont};
    NSDictionary *underlineAttributes = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
    
    NSDictionary *tagsAttributes = @{
                                  @"b": boldAttributes,
                                  @"em": emphasisAttributes,
                                  @"i": emphasisAttributes,
                                  @"u": underlineAttributes
                                  };
    
    return [self convertHtml:text tagsAttributes:tagsAttributes];
}

- (NSAttributedString *)convertHtml:(NSString *)text tagsAttributes:(NSDictionary *)tagsAttributes
{
    if (text.length == 0) {
        return nil;
    }
    return [[NSAttributedString alloc] initWithAttributedString:[self _convertHtml:text
                                                                    tagsAttributes:tagsAttributes]];
}

- (NSMutableAttributedString *)_convertHtml:(NSString *)text tagsAttributes:(NSDictionary *)tagsAttributes
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:text];
    
    [tagsAttributes enumerateKeysAndObjectsUsingBlock:^(NSString *tag, NSDictionary *attributes, BOOL *stop) {
        NSString *expression = [self createRegexFromTag:tag];
        [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *attribute, id value, BOOL *stop) {
            [self replaceExpression:expression inString:result byAttributes:attributes];
        }];
        
        [result.mutableString replaceOccurrencesOfString:[self createOpenTagFromTag:tag] withString:@""
                                                 options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
        
        [result.mutableString replaceOccurrencesOfString:[self createCloseTagFromTag:tag] withString:@""
                                                 options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
        
        [result.mutableString replaceOccurrencesOfString:@"<br>" withString:@"\n"
                                                 options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
    }];
    
    return result;
}

- (NSString *)createRegexFromTag:(NSString *)tag
{
    NSString *openTag = [self createOpenTagFromTag:tag];
    NSString *closeTag = [self createCloseTagFromTag:tag];
    
    return [NSString stringWithFormat:@"%@(.+?)%@", openTag, closeTag];
}

- (NSString *)createOpenTagFromTag:(NSString *)tag
{
    return [NSString stringWithFormat:@"<%@>", tag];
}

- (NSString *)createCloseTagFromTag:(NSString *)tag
{
    return [NSString stringWithFormat:@"</%@>", tag];
}

- (NSArray *)replaceExpression:(NSString *)expression
                      inString:(NSMutableAttributedString *)attrString byAttributes:(NSDictionary *)attributes
{
    NSArray *ranges = [self findMatchesInString:attrString.string expression:expression];
    
    [ranges enumerateObjectsUsingBlock:^(NSValue *rangeValue, NSUInteger idx, BOOL *stop) {
        [attrString addAttributes:attributes range:[rangeValue rangeValue]];
    }];
    
    return ranges;
}

- (NSArray *)findMatchesInString:(NSString *)text expression:(NSString *)expression
{
    NSError *error = nil;
    NSMutableArray *matches = [NSMutableArray array];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive                                 error:&error];
    [regex enumerateMatchesInString:text
                            options:0
                              range:NSMakeRange(0, [text length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                             [matches addObject:[NSValue valueWithRange:match.range]];
                         }];
    
    return [NSArray arrayWithArray:matches];
}

@end
